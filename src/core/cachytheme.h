/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#pragma once

#include <QColor>
#include <QGuiApplication>
#include <QObject>
#include <QPalette>
#include <QStyleHints>
#include <qqmlregistration.h>

class CachyTheme : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool isDark READ isDark NOTIFY themeChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY themeChanged)
    Q_PROPERTY(QColor windowBackground READ windowBackground NOTIFY themeChanged)
    Q_PROPERTY(QColor cardBackground READ cardBackground NOTIFY themeChanged)
    Q_PROPERTY(QColor cardBackgroundHover READ cardBackgroundHover NOTIFY themeChanged)
    Q_PROPERTY(QColor specularBorder READ specularBorder NOTIFY themeChanged)
    Q_PROPERTY(QColor textPrimary READ textPrimary NOTIFY themeChanged)
    Q_PROPERTY(QColor textSecondary READ textSecondary NOTIFY themeChanged)
    Q_PROPERTY(QColor textMuted READ textMuted NOTIFY themeChanged)
    Q_PROPERTY(QColor dividerColor READ dividerColor NOTIFY themeChanged)

    // Traffic light window buttons
    Q_PROPERTY(QColor closeButton READ closeButton CONSTANT)
    Q_PROPERTY(QColor minimizeButton READ minimizeButton CONSTANT)
    Q_PROPERTY(QColor maximizeButton READ maximizeButton CONSTANT)

    // Metrics
    Q_PROPERTY(int radiusSmall READ radiusSmall CONSTANT)
    Q_PROPERTY(int radiusMedium READ radiusMedium CONSTANT)
    Q_PROPERTY(int radiusLarge READ radiusLarge CONSTANT)
    Q_PROPERTY(int radiusWindow READ radiusWindow CONSTANT)

    Q_PROPERTY(int spacingTiny READ spacingTiny CONSTANT)
    Q_PROPERTY(int spacingSmall READ spacingSmall CONSTANT)
    Q_PROPERTY(int spacingMedium READ spacingMedium CONSTANT)
    Q_PROPERTY(int spacingLarge READ spacingLarge CONSTANT)
    Q_PROPERTY(int spacingHuge READ spacingHuge CONSTANT)

    // Standard Window & Container Metrics (macOS Golden Gate canonical sizing)
    Q_PROPERTY(int windowWidthUtility READ windowWidthUtility CONSTANT)
    Q_PROPERTY(int windowHeightUtility READ windowHeightUtility CONSTANT)
    Q_PROPERTY(int windowWidthSettings READ windowWidthSettings CONSTANT)
    Q_PROPERTY(int windowHeightSettings READ windowHeightSettings CONSTANT)
    Q_PROPERTY(int windowWidthDialog READ windowWidthDialog CONSTANT)
    Q_PROPERTY(int windowHeightDialog READ windowHeightDialog CONSTANT)
    Q_PROPERTY(int marginWindow READ marginWindow CONSTANT)
    Q_PROPERTY(int marginCard READ marginCard CONSTANT)
    Q_PROPERTY(int titleBarHeight READ titleBarHeight CONSTANT)
    Q_PROPERTY(int trafficLightMargin READ trafficLightMargin CONSTANT)

    Q_PROPERTY(int animFast READ animFast CONSTANT)
    Q_PROPERTY(int animNormal READ animNormal CONSTANT)

public:
    explicit CachyTheme(QObject *parent = nullptr);
    ~CachyTheme() override = default;

    bool isDark() const;
    QColor accentColor() const { return QColor(10, 132, 255); } // #0A84FF
    QColor windowBackground() const;
    QColor cardBackground() const;
    QColor cardBackgroundHover() const;
    QColor specularBorder() const;
    QColor textPrimary() const;
    QColor textSecondary() const;
    QColor textMuted() const;
    QColor dividerColor() const;

    QColor closeButton() const { return QColor(255, 95, 86); }     // #FF5F56
    QColor minimizeButton() const { return QColor(255, 189, 46); } // #FFBD2E
    QColor maximizeButton() const { return QColor(39, 201, 63); }   // #27C93F

    int radiusSmall() const { return 8; }
    int radiusMedium() const { return 12; }
    int radiusLarge() const { return 16; }
    int radiusWindow() const { return 22; }

    int spacingTiny() const { return 4; }
    int spacingSmall() const { return 8; }
    int spacingMedium() const { return 12; }
    int spacingLarge() const { return 16; }
    int spacingHuge() const { return 24; }

    // Standard Window Sizing & Margins
    int windowWidthUtility() const { return 540; }
    int windowHeightUtility() const { return 620; }
    int windowWidthSettings() const { return 880; }
    int windowHeightSettings() const { return 640; }
    int windowWidthDialog() const { return 440; }
    int windowHeightDialog() const { return 320; }
    int marginWindow() const { return 18; }
    int marginCard() const { return 14; }
    int titleBarHeight() const { return 44; }
    int trafficLightMargin() const { return 18; }

    int animFast() const { return 180; }
    int animNormal() const { return 260; }

    Q_INVOKABLE QColor withAlpha(const QColor &baseColor, qreal alpha) const {
        return QColor::fromRgbF(baseColor.redF(), baseColor.greenF(), baseColor.blueF(), alpha);
    }

Q_SIGNALS:
    void themeChanged();

private:
    void onColorSchemeChanged();
};
