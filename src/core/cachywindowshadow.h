/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QObject>
#include <QQuickWindow>
#include <KWindowShadow>
#include <qqmlregistration.h>

/**
 * Compositor-backed drop shadow for frameless CachyOS.UI windows and popups.
 *
 * Inspired by Cutefish's FishUI WindowShadow: instead of rendering a costly
 * blur shader every frame inside the QML scene graph, CachyWindowShadow
 * renders a symmetrical 9-patch Gaussian shadow texture once in C++ (with the
 * interior rounded rectangle masked out via DestinationOut so translucent
 * Liquid Glass surfaces are never darkened by their own shadow) and hands the
 * tiles to KWin via KWindowShadow.
 */
class CachyWindowShadow : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(CachyWindowShadow)

    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(qreal strength READ strength WRITE setStrength NOTIFY strengthChanged)
    Q_PROPERTY(QQuickWindow *window READ window WRITE setWindow NOTIFY windowChanged)

public:
    explicit CachyWindowShadow(QObject *parent = nullptr);
    ~CachyWindowShadow() override;

    bool isEnabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    qreal radius() const { return m_radius; }
    void setRadius(qreal radius);

    qreal strength() const { return m_strength; }
    void setStrength(qreal strength);

    QQuickWindow *window() const { return m_window; }
    void setWindow(QQuickWindow *window);

    static CachyWindowShadow *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void enabledChanged();
    void radiusChanged();
    void strengthChanged();
    void windowChanged();

private:
    void applyShadow();
    void destroyShadow();

    bool m_enabled{true};
    qreal m_radius{20.0};
    qreal m_strength{1.0};
    QQuickWindow *m_window{nullptr};
    KWindowShadow *m_shadow{nullptr};
};
