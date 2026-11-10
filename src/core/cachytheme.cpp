/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachytheme.h"

CachyTheme::CachyTheme(QObject *parent)
    : QObject(parent)
{
    if (auto *styleHints = QGuiApplication::styleHints()) {
        connect(styleHints, &QStyleHints::colorSchemeChanged, this, &CachyTheme::onColorSchemeChanged);
    }
}

bool CachyTheme::isDark() const
{
    if (auto *styleHints = QGuiApplication::styleHints()) {
        return styleHints->colorScheme() == Qt::ColorScheme::Dark;
    }
    return true; // Predeterminado a modo oscuro si no está definido
}

QColor CachyTheme::windowBackground() const
{
    return isDark()
        ? QColor::fromRgbF(0.11, 0.11, 0.13, 0.88)
        : QColor::fromRgbF(0.96, 0.96, 0.97, 0.90);
}

QColor CachyTheme::cardBackground() const
{
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.08)
        : QColor::fromRgbF(1.0, 1.0, 1.0, 0.65);
}

QColor CachyTheme::cardBackgroundHover() const
{
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.14)
        : QColor::fromRgbF(1.0, 1.0, 1.0, 0.85);
}

QColor CachyTheme::specularBorder() const
{
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.14)
        : QColor::fromRgbF(0.0, 0.0, 0.0, 0.10);
}

QColor CachyTheme::textPrimary() const
{
    return isDark()
        ? QColor(255, 255, 255, 240)
        : QColor(0, 0, 0, 230);
}

QColor CachyTheme::textSecondary() const
{
    return isDark()
        ? QColor(255, 255, 255, 160)
        : QColor(0, 0, 0, 150);
}

QColor CachyTheme::textMuted() const
{
    return isDark()
        ? QColor(255, 255, 255, 95)
        : QColor(0, 0, 0, 90);
}

QColor CachyTheme::dividerColor() const
{
    return isDark()
        ? QColor::fromRgbF(1.0, 1.0, 1.0, 0.10)
        : QColor::fromRgbF(0.0, 0.0, 0.0, 0.08);
}

void CachyTheme::onColorSchemeChanged()
{
    Q_EMIT themeChanged();
}
