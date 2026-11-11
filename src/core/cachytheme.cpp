/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachytheme.h"

#include <QDir>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>
#include <QtMath>

CachyTheme::CachyTheme(QObject *parent)
    : QObject(parent)
{
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

void CachyTheme::onColorSchemeChanged()
{
    Q_EMIT themeChanged();
}
