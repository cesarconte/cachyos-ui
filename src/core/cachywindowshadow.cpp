/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachywindowshadow.h"

#include <QGuiApplication>
#include <QHash>
#include <QImage>
#include <QPainter>
#include <QPainterPath>
#include <QQuickItem>
#include <QtMath>

namespace {

struct ShadowTileSet {
    QList<KWindowShadowTile::Ptr> tiles; // 8 perimeter tiles: T, TR, R, BR, B, BL, L, TL
    QMargins padding;
};

struct CacheKey {
    int radiusPx;
    int strengthPercent;
    int dprPercent;

    bool operator==(const CacheKey &other) const noexcept
    {
        return radiusPx == other.radiusPx
            && strengthPercent == other.strengthPercent
            && dprPercent == other.dprPercent;
    }
};

size_t qHash(const CacheKey &key, size_t seed = 0) noexcept
{
    return qHashMulti(seed, key.radiusPx, key.strengthPercent, key.dprPercent);
}

/**
 * Separable 3-pass box blur over the alpha channel of a QImage (approximates
 * a true Gaussian kernel in O(W*H) independent of the blur radius).
 */
void blurAlphaChannel(QImage &img, int radius)
{
    if (radius < 2) {
        return;
    }

    const int w = img.width();
    const int h = img.height();
    const int alphaOffset = (QSysInfo::ByteOrder == QSysInfo::BigEndian) ? 0 : 3;

    QVector<uint8_t> temp(qMax(w, h));

    for (int pass = 0; pass < 3; ++pass) {
        // Horizontal pass
        for (int y = 0; y < h; ++y) {
            uint8_t *line = img.scanLine(y);
            int sum = 0;
            const int window = 2 * radius + 1;

            for (int i = -radius; i <= radius; ++i) {
                const int x = qBound(0, i, w - 1);
                sum += line[x * 4 + alphaOffset];
            }
            for (int x = 0; x < w; ++x) {
                temp[x] = static_cast<uint8_t>(sum / window);
                const int left = qMax(0, x - radius);
                const int right = qMin(w - 1, x + radius + 1);
                sum += line[right * 4 + alphaOffset] - line[left * 4 + alphaOffset];
            }
            for (int x = 0; x < w; ++x) {
                line[x * 4 + alphaOffset] = temp[x];
            }
        }

        // Vertical pass
        for (int x = 0; x < w; ++x) {
            int sum = 0;
            const int window = 2 * radius + 1;
            const int byteCol = x * 4 + alphaOffset;

            for (int i = -radius; i <= radius; ++i) {
                const int y = qBound(0, i, h - 1);
                sum += img.scanLine(y)[byteCol];
            }
            for (int y = 0; y < h; ++y) {
                temp[y] = static_cast<uint8_t>(sum / window);
                const int top = qMax(0, y - radius);
                const int bottom = qMin(h - 1, y + radius + 1);
                sum += img.scanLine(bottom)[byteCol] - img.scanLine(top)[byteCol];
            }
            for (int y = 0; y < h; ++y) {
                img.scanLine(y)[byteCol] = temp[y];
            }
        }
    }
}

KWindowShadowTile::Ptr makeTile(const QImage &img)
{
    auto tile = KWindowShadowTile::Ptr::create();
    tile->setImage(img);
    return tile;
}

ShadowTileSet buildShadowTileSet(qreal cornerRadius, qreal strength, qreal dpr)
{
    static QHash<CacheKey, ShadowTileSet> s_cache;

    const CacheKey key{
        qMax(0, qRound(cornerRadius)),
        qBound(0, qRound(strength * 100.0), 200),
        qMax(100, qRound(dpr * 100.0)),
    };

    if (auto it = s_cache.constFind(key); it != s_cache.constEnd()) {
        return *it;
    }

    const int blurRadius = 28;
    const int offsetY = 6;
    const int marginLeft = blurRadius;
    const int marginRight = blurRadius;
    const int marginTop = blurRadius - offsetY;
    const int marginBottom = blurRadius + offsetY;

    const int innerRadius = qMax(4, key.radiusPx);
    // The inner box needs a 1x1 stretchable center pixel plus the two corners
    const int boxWidth = innerRadius * 2 + 1;
    const int boxHeight = innerRadius * 2 + 1;

    const int totalWidth = marginLeft + boxWidth + marginRight;
    const int totalHeight = marginTop + boxHeight + marginBottom;

    QImage canvas(qRound(totalWidth * dpr), qRound(totalHeight * dpr), QImage::Format_ARGB32_Premultiplied);
    canvas.setDevicePixelRatio(dpr);
    canvas.fill(Qt::transparent);

    const QRectF innerRect(marginLeft, marginTop, boxWidth, boxHeight);

    // 1. Draw the solid shadowcaster shifted vertically by offsetY
    {
        QPainter p(&canvas);
        p.setRenderHint(QPainter::Antialiasing);
        p.setPen(Qt::NoPen);
        const int alpha = qBound(0, qRound(96.0 * qBound(0.0, strength, 1.5)), 220);
        p.setBrush(QColor(0, 0, 0, alpha));
        p.drawRoundedRect(innerRect.translated(0, offsetY), cornerRadius, cornerRadius);
    }

    // 2. Blur the alpha channel and convert back to premultiplied black
    blurAlphaChannel(canvas, qMax(2, qRound((blurRadius / 2.2) * dpr)));
    {
        QPainter p(&canvas);
        p.setCompositionMode(QPainter::CompositionMode_SourceIn);
        p.fillRect(QRectF(0, 0, totalWidth, totalHeight), Qt::black);
    }

    // 3. Punch out the interior rounded window so translucent Liquid Glass
    // windows are never darkened by their own drop shadow
    {
        QPainter p(&canvas);
        p.setRenderHint(QPainter::Antialiasing);
        p.setPen(Qt::NoPen);
        p.setBrush(Qt::black);
        p.setCompositionMode(QPainter::CompositionMode_DestinationOut);
        p.drawRoundedRect(innerRect.adjusted(0.5, 0.5, -0.5, -0.5), cornerRadius, cornerRadius);
    }

    // 4. Slice the 9-patch around the central 1x1 logical pixel
    const int cx = qRound((marginLeft + innerRadius) * dpr);
    const int cy = qRound((marginTop + innerRadius) * dpr);
    const int cw = qMax(1, qRound(1.0 * dpr));
    const int ch = qMax(1, qRound(1.0 * dpr));
    const int rightWidth = canvas.width() - (cx + cw);
    const int bottomHeight = canvas.height() - (cy + ch);

    ShadowTileSet result;
    result.tiles = {
        makeTile(canvas.copy(cx, 0, cw, cy)),                         // 0: Top
        makeTile(canvas.copy(cx + cw, 0, rightWidth, cy)),            // 1: Top-Right
        makeTile(canvas.copy(cx + cw, cy, rightWidth, ch)),           // 2: Right
        makeTile(canvas.copy(cx + cw, cy + ch, rightWidth, bottomHeight)), // 3: Bottom-Right
        makeTile(canvas.copy(cx, cy + ch, cw, bottomHeight)),         // 4: Bottom
        makeTile(canvas.copy(0, cy + ch, cx, bottomHeight)),          // 5: Bottom-Left
        makeTile(canvas.copy(0, cy, cx, ch)),                         // 6: Left
        makeTile(canvas.copy(0, 0, cx, cy)),                          // 7: Top-Left
    };
    result.padding = QMargins(marginLeft, marginTop, marginRight, marginBottom);

    s_cache.insert(key, result);
    return result;
}

} // namespace

CachyWindowShadow::CachyWindowShadow(QObject *parent)
    : QObject(parent)
    , m_shadow(new KWindowShadow(this))
{
    if (auto *win = qobject_cast<QQuickWindow *>(parent)) {
        setWindow(win);
    } else if (auto *item = qobject_cast<QQuickItem *>(parent)) {
        setWindow(item->window());
        connect(item, &QQuickItem::windowChanged, this, &CachyWindowShadow::setWindow);
    }
}

CachyWindowShadow::~CachyWindowShadow()
{
    destroyShadow();
}

void CachyWindowShadow::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }
    m_enabled = enabled;
    Q_EMIT enabledChanged();
    applyShadow();
}

void CachyWindowShadow::setRadius(qreal radius)
{
    if (qFuzzyCompare(m_radius, radius)) {
        return;
    }
    m_radius = radius;
    Q_EMIT radiusChanged();
    applyShadow();
}

void CachyWindowShadow::setStrength(qreal strength)
{
    if (qFuzzyCompare(m_strength, strength)) {
        return;
    }
    m_strength = strength;
    Q_EMIT strengthChanged();
    applyShadow();
}

void CachyWindowShadow::setWindow(QQuickWindow *window)
{
    if (m_window == window) {
        return;
    }
    if (m_window) {
        disconnect(m_window, nullptr, this, nullptr);
    }
    destroyShadow();
    m_window = window;
    if (m_window) {
        connect(m_window, &QQuickWindow::visibleChanged, this, &CachyWindowShadow::applyShadow);
        applyShadow();
    }
    Q_EMIT windowChanged();
}

void CachyWindowShadow::destroyShadow()
{
    if (m_shadow && m_shadow->isCreated()) {
        m_shadow->destroy();
    }
}

void CachyWindowShadow::applyShadow()
{
    destroyShadow();

    if (!m_window || !m_enabled || !m_window->isVisible() || m_strength <= 0.0) {
        return;
    }

    const qreal effectiveRadius = m_window->property("cornerRadius").isValid()
        ? m_window->property("cornerRadius").toReal()
        : m_radius;
    const qreal dpr = m_window->effectiveDevicePixelRatio() > 0.0
        ? m_window->effectiveDevicePixelRatio()
        : (qApp ? qApp->devicePixelRatio() : 1.0);

    const ShadowTileSet tileSet = buildShadowTileSet(effectiveRadius, m_strength, dpr);
    if (tileSet.tiles.size() < 8) {
        return;
    }

    m_shadow->setWindow(m_window);
    m_shadow->setTopTile(tileSet.tiles[0]);
    m_shadow->setTopRightTile(tileSet.tiles[1]);
    m_shadow->setRightTile(tileSet.tiles[2]);
    m_shadow->setBottomRightTile(tileSet.tiles[3]);
    m_shadow->setBottomTile(tileSet.tiles[4]);
    m_shadow->setBottomLeftTile(tileSet.tiles[5]);
    m_shadow->setLeftTile(tileSet.tiles[6]);
    m_shadow->setTopLeftTile(tileSet.tiles[7]);
    m_shadow->setPadding(tileSet.padding);
    m_shadow->create();
}

CachyWindowShadow *CachyWindowShadow::qmlAttachedProperties(QObject *object)
{
    return new CachyWindowShadow(object);
}
