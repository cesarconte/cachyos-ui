/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachywindowblur.h"
#include <KWindowEffects>
#include <QQuickItem>

CachyWindowBlur::CachyWindowBlur(QObject *parent)
    : QObject(parent)
{
    if (auto *window = qobject_cast<QQuickWindow *>(parent)) {
        m_window = window;
    } else if (auto *item = qobject_cast<QQuickItem *>(parent)) {
        m_window = item->window();
        connect(item, &QQuickItem::windowChanged, this, [this](QQuickWindow *win) {
            m_window = win;
            applyBlur();
        });
    }

    if (m_window) {
        connect(m_window, &QQuickWindow::visibleChanged, this, &CachyWindowBlur::applyBlur);
        applyBlur();
    }
}

void CachyWindowBlur::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }
    m_enabled = enabled;
    Q_EMIT enabledChanged();
    applyBlur();
}

void CachyWindowBlur::applyBlur()
{
    if (!m_window) {
        return;
    }

    KWindowEffects::enableBlurBehind(m_window, m_enabled);
    KWindowEffects::enableBackgroundContrast(m_window, m_enabled);
}

CachyWindowBlur *CachyWindowBlur::qmlAttachedProperties(QObject *object)
{
    return new CachyWindowBlur(object);
}
