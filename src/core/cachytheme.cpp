/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachytheme.h"

#include <QDir>
#include <QFile>
#include <QHash>
#include <QSettings>
#include <QSysInfo>
#include <QStandardPaths>
#include <QUrl>
#include <QtMath>

#include <kcoreaddons.h>

static void ensureBuiltinIconsInitialized()
{
    static const bool initialized = []() {
        Q_INIT_RESOURCE(cachyosui_icons);
        return true;
    }();
    Q_UNUSED(initialized);
}

CachyTheme::CachyTheme(QObject *parent)
    : QObject(parent)
{
    ensureBuiltinIconsInitialized();
    m_configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/cachyosuirc");
    loadSettings();

    if (QFile::exists(m_configPath)) {
        m_configWatcher.addPath(m_configPath);
    }
    connect(&m_configWatcher, &QFileSystemWatcher::fileChanged, this, [this](const QString &path) {
        loadSettings();
        if (QFile::exists(path) && !m_configWatcher.files().contains(path)) {
            m_configWatcher.addPath(path);
        }
    });

    if (auto *styleHints = QGuiApplication::styleHints()) {
        connect(styleHints, &QStyleHints::colorSchemeChanged, this, &CachyTheme::onColorSchemeChanged);
    }
}

void CachyTheme::loadSettings()
{
    QSettings settings(m_configPath, QSettings::IniFormat);
    const qreal loaded = qBound(0.0, settings.value(QStringLiteral("LiquidGlass/glassOpacity"), 0.5).toDouble(), 1.0);
    if (!qFuzzyCompare(m_glassOpacity, loaded)) {
        m_glassOpacity = loaded;
        Q_EMIT themeChanged();
    }
}

void CachyTheme::saveSettings()
{
    QSettings settings(m_configPath, QSettings::IniFormat);
    settings.setValue(QStringLiteral("LiquidGlass/glassOpacity"), m_glassOpacity);
    settings.sync();
    if (QFile::exists(m_configPath) && !m_configWatcher.files().contains(m_configPath)) {
        m_configWatcher.addPath(m_configPath);
    }
}

void CachyTheme::setGlassOpacity(qreal value)
{
    const qreal clamped = qBound(0.0, value, 1.0);
    if (qFuzzyCompare(m_glassOpacity, clamped)) {
        return;
    }
    m_glassOpacity = clamped;
    saveSettings();
    Q_EMIT themeChanged();
}

bool CachyTheme::isDark() const
{
    if (auto *styleHints = QGuiApplication::styleHints()) {
        return styleHints->colorScheme() == Qt::ColorScheme::Dark;
    }
    return true;
}

QColor CachyTheme::windowBackground() const
{
    // Interpolates from Glassiest (0.0) -> Medium Glassy default (0.5) -> Maximum Tint (1.0)
    if (isDark()) {
        const qreal alpha = 0.24 + (m_glassOpacity * 0.44); // 0.24 -> 0.46 (at 0.5) -> 0.68
        return QColor::fromRgbF(0.11, 0.11, 0.14, alpha);
    } else {
        const qreal alpha = 0.30 + (m_glassOpacity * 0.46); // 0.30 -> 0.53 (at 0.5) -> 0.76
        return QColor::fromRgbF(0.96, 0.97, 1.00, alpha);
    }
}

QColor CachyTheme::sidebarBackground() const
{
    // Edge-to-edge sidebar in Golden Gate: slightly deeper/more translucent than main content
    if (isDark()) {
        const qreal alpha = 0.18 + (m_glassOpacity * 0.36);
        return QColor::fromRgbF(0.08, 0.08, 0.11, alpha);
    } else {
        const qreal alpha = 0.22 + (m_glassOpacity * 0.40);
        return QColor::fromRgbF(0.91, 0.93, 0.97, alpha);
    }
}

QColor CachyTheme::surfacePill() const
{
    if (isDark()) {
        const qreal alpha = 0.10 + (m_glassOpacity * 0.12);
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    } else {
        const qreal alpha = 0.50 + (m_glassOpacity * 0.30);
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    }
}

QColor CachyTheme::cardBackground() const
{
    if (isDark()) {
        const qreal alpha = 0.06 + (m_glassOpacity * 0.08); // 0.06 -> 0.10 -> 0.14
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    } else {
        const qreal alpha = 0.45 + (m_glassOpacity * 0.32); // 0.45 -> 0.61 -> 0.77
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    }
}

QColor CachyTheme::cardBackgroundHover() const
{
    if (isDark()) {
        const qreal alpha = 0.12 + (m_glassOpacity * 0.08);
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    } else {
        const qreal alpha = 0.72 + (m_glassOpacity * 0.20);
        return QColor::fromRgbF(1.0, 1.0, 1.0, alpha);
    }
}

QColor CachyTheme::sheetBackground() const
{
    // Floating panels (popovers, sheets, menus) need a denser material than the
    // regular cards so their content stays legible over arbitrary backdrops.
    if (isDark()) {
        const qreal alpha = 0.88 + (m_glassOpacity * 0.10); // 0.88 -> 0.93 -> 0.98
        return QColor::fromRgbF(0.12, 0.12, 0.15, alpha);
    } else {
        const qreal alpha = 0.92 + (m_glassOpacity * 0.06); // 0.92 -> 0.95 -> 0.98
        return QColor::fromRgbF(0.98, 0.98, 1.00, alpha);
    }
}

QColor CachyTheme::specularBorder() const
{
    // Slightly more refractive when glassier, subtler when tinted
    const qreal factor = 1.0 - (m_glassOpacity * 0.35);
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.18 * factor)
        : QColor::fromRgbF(0.0, 0.0, 0.0, 0.12 * factor);
}

QColor CachyTheme::hardDividerColor() const
{
    // Golden Gate "hard-style" visible titlebar & sidebar border
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.14)
        : QColor::fromRgbF(0.0, 0.0, 0.0, 0.12);
}

QColor CachyTheme::textPrimary() const
{
    return isDark()
        ? QColor(255, 255, 255, 242)
        : QColor(0, 0, 0, 232);
}

QColor CachyTheme::textSecondary() const
{
    return isDark()
        ? QColor(255, 255, 255, 165)
        : QColor(0, 0, 0, 155);
}

QColor CachyTheme::textMuted() const
{
    return isDark()
        ? QColor(255, 255, 255, 98)
        : QColor(0, 0, 0, 92);
}

QColor CachyTheme::dividerColor() const
{
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.10)
        : QColor::fromRgbF(0.0, 0.0, 0.0, 0.08);
}

QString CachyTheme::distroName() const
{
    // The distribution the application is running on, read from the platform
    // (os-release). Applications use it to brand themselves with CachyOS
    // instead of hardcoding any vendor name.
    const QString name = QSysInfo::prettyProductName().trimmed();
    return name.isEmpty() ? QStringLiteral("Linux") : name;
}

QString CachyTheme::desktopShell() const
{
    // KDE Frameworks and Plasma share the same major generation, so the
    // framework version identifies the desktop shell generation.
    const QStringList parts = KCoreAddons::versionString().split(QLatin1Char('.'));
    const QString major = parts.value(0).trimmed();
    return QStringLiteral("Plasma %1").arg(major.isEmpty() ? QStringLiteral("6") : major);
}

QString CachyTheme::iconUrl(const QString &name, const QString &fallback) const
{
    if (name.isEmpty()) {
        return QString();
    }

    if (name.startsWith( QStringLiteral("qrc:/")) || name.startsWith(QStringLiteral("file://"))) {
        return name;
    }

    // 1. Embedded CachyOS.UI structural vector icons (FishUI style): always
    // available in memory with zero disk I/O and immune to missing themes.
    const QString builtinResource = QStringLiteral(":/CachyOS/UI/icons/") + name + QStringLiteral(".svg");
    if (QFile::exists(builtinResource)) {
        return QStringLiteral("qrc") + builtinResource;
    }

    const QStringList roots = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);

    // 2. The icon themes shipped with Plasma (Breeze) and the freedesktop
    // fallback (hicolor) are searched explicitly. The symbolic variant is
    // preferred: it is monochrome and can be tinted with the colour of the
    // interface, so it follows the colour scheme of the desktop.
    static const QStringList directories = {
        QStringLiteral("/icons/hicolor/symbolic/apps/"),
        QStringLiteral("/icons/breeze/symbolic/apps/"),
        QStringLiteral("/icons/breeze/actions/scalable/"),
        QStringLiteral("/icons/breeze/apps/scalable/"),
        QStringLiteral("/icons/hicolor/scalable/apps/"),
    };
    // The remaining categories of the Breeze theme.
    static const QStringList breezeCategories = {
        QStringLiteral("actions"),
        QStringLiteral("apps"),
        QStringLiteral("places"),
        QStringLiteral("emotes"),
        QStringLiteral("status"),
        QStringLiteral("devices"),
        QStringLiteral("mimetypes"),
        QStringLiteral("preferences"),
        QStringLiteral("categories"),
    };
    static const QStringList breezeSizes = {
        QStringLiteral("24"),
        QStringLiteral("22"),
        QStringLiteral("16"),
        QStringLiteral("32"),
        QStringLiteral("48"),
        QStringLiteral("64"),
        QStringLiteral("scalable"),
    };
    static const QStringList suffixes = {
        QStringLiteral("-symbolic.svg"),
        QStringLiteral(".svg"),
    };

    for (const QString &root : roots) {
        for (const QString &directory : directories) {
            for (const QString &suffix : suffixes) {
                const QString candidate = root + directory + name + suffix;
                if (QFile::exists(candidate)) {
                    return QUrl::fromLocalFile(candidate).toString();
                }
            }
        }
        for (const QString &category : breezeCategories) {
            for (const QString &size : breezeSizes) {
                for (const QString &suffix : suffixes) {
                    const QString candidate = root + QStringLiteral("/icons/breeze/") + category + QLatin1Char('/') + size + QLatin1Char('/') + name + suffix;
                    if (QFile::exists(candidate)) {
                        return QUrl::fromLocalFile(candidate).toString();
                    }
                }
            }
        }
    }

    // 3. Freedesktop alias fallback to embedded structural icons when the
    // desktop icon theme is absent or incomplete.
    static const QHash<QString, QString> builtinAliases = {
        {QStringLiteral("dialog-information"), QStringLiteral("info")},
        {QStringLiteral("dialog-warning"), QStringLiteral("warning")},
        {QStringLiteral("dialog-error"), QStringLiteral("error")},
        {QStringLiteral("dialog-ok-apply"), QStringLiteral("check")},
        {QStringLiteral("emblem-checked"), QStringLiteral("check")},
        {QStringLiteral("window-close"), QStringLiteral("close")},
        {QStringLiteral("dialog-close"), QStringLiteral("close")},
        {QStringLiteral("edit-clear"), QStringLiteral("clear")},
        {QStringLiteral("edit-find"), QStringLiteral("search")},
        {QStringLiteral("search"), QStringLiteral("search")},
        {QStringLiteral("list-add"), QStringLiteral("add")},
        {QStringLiteral("list-remove"), QStringLiteral("remove")},
        {QStringLiteral("view-refresh"), QStringLiteral("refresh")},
        {QStringLiteral("go-previous"), QStringLiteral("chevron-left")},
        {QStringLiteral("go-next"), QStringLiteral("chevron-right")},
        {QStringLiteral("go-up"), QStringLiteral("chevron-up")},
        {QStringLiteral("go-down"), QStringLiteral("chevron-down")},
        {QStringLiteral("configure"), QStringLiteral("settings")},
        {QStringLiteral("preferences-system"), QStringLiteral("settings")},
        {QStringLiteral("window-pin"), QStringLiteral("pin")},
        {QStringLiteral("user-trash"), QStringLiteral("trash")},
        {QStringLiteral("edit-delete"), QStringLiteral("trash")},
        {QStringLiteral("view-list-icons"), QStringLiteral("grid")},
        {QStringLiteral("view-list-details"), QStringLiteral("list")},
        {QStringLiteral("media-playback-start"), QStringLiteral("play")},
        {QStringLiteral("media-playback-pause"), QStringLiteral("pause")},
    };
    if (const QString alias = builtinAliases.value(name); !alias.isEmpty()) {
        const QString aliasResource = QStringLiteral(":/CachyOS/UI/icons/") + alias + QStringLiteral(".svg");
        if (QFile::exists(aliasResource)) {
            return QStringLiteral("qrc") + aliasResource;
        }
    }

    // 4. The icon does not exist: the fallback is resolved instead, so the
    // interface never shows a hole where an icon was expected.
    if (!fallback.isEmpty() && fallback != name) {
        return iconUrl(fallback);
    }

    return QString();
}

void CachyTheme::onColorSchemeChanged()
{
    Q_EMIT themeChanged();
}
