/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "cachytheme.h"

#include <QDir>
#include <QFile>
#include <QHash>
#include <QIcon>
#include <QSettings>
#include <QSysInfo>
#include <QStandardPaths>
#include <QUrl>
#include <QtMath>

#include <kcoreaddons.h>
#include <KIconLoader>
#include <KIconTheme>

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

    connect(KIconLoader::global(), &KIconLoader::iconLoaderSettingsChanged, this, [this]() {
        Q_EMIT themeChanged();
        Q_EMIT iconThemeChanged();
    });
    connect(KIconLoader::global(), &KIconLoader::iconChanged, this, [this](int) {
        Q_EMIT themeChanged();
        Q_EMIT iconThemeChanged();
    });
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

void CachyTheme::setThemeMode(int mode)
{
    if (m_themeMode != mode) {
        m_themeMode = mode;
        Q_EMIT themeChanged();
    }
}

bool CachyTheme::isDark() const
{
    if (m_themeMode == 1) {
        return false;
    }
    if (m_themeMode == 2 || m_themeMode == 3) {
        return true;
    }
    if (auto *styleHints = QGuiApplication::styleHints()) {
        const auto scheme = styleHints->colorScheme();
        if (scheme == Qt::ColorScheme::Dark) {
            return true;
        }
        if (scheme == Qt::ColorScheme::Light) {
            return false;
        }
    }
    return QGuiApplication::palette().color(QPalette::Window).lightnessF() < 0.5;
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

QColor CachyTheme::contentBackground() const
{
    // Canonical macOS Golden Gate grouped window content canvas.
    // 100% opaque to guarantee zero wallpaper bleedthrough and crisp
    // contrast across notes, lists, grouped settings and charts.
    if (isDark()) {
        return QColor(28, 28, 30); // #1C1C1E, 100% opaque
    } else {
        return QColor(242, 242, 247); // #F2F2F7, 100% opaque
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

QColor CachyTheme::focusRingColor() const
{
    return withAlpha(accentColor(), isDark() ? 0.65 : 0.50);
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

QString CachyTheme::iconThemeName() const
{
    return KIconTheme::current();
}

static QString findThemeIconPath(const QString &iconName)
{
    if (iconName.isEmpty()) {
        return QString();
    }

    const bool isExplicitSymbolic = iconName.endsWith(QLatin1String("-symbolic"));
    // Freedesktop action icons in toolbars/menus typically prefer symbolic variants for MultiEffect tinting
    const bool isAction = iconName.startsWith(QLatin1String("edit-")) ||
                          iconName.startsWith(QLatin1String("document-")) ||
                          iconName.startsWith(QLatin1String("window-")) ||
                          iconName.startsWith(QLatin1String("view-")) ||
                          iconName.startsWith(QLatin1String("go-")) ||
                          iconName.startsWith(QLatin1String("format-")) ||
                          iconName.startsWith(QLatin1String("tools-"));

    if (isExplicitSymbolic || isAction) {
        const QString symbolicName = isExplicitSymbolic ? iconName : (iconName + QStringLiteral("-symbolic"));
        QString path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Panel, true);
        if (path.isEmpty()) {
            path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Toolbar, true);
        }
        if (path.isEmpty()) {
            path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Desktop, true);
        }
        if (!path.isEmpty()) {
            return path;
        }
    }

    // Search regular full-color icon across standard groups: Desktop, Place, MimeType, Toolbar, Panel, Small
    QString path = KIconLoader::global()->iconPath(iconName, KIconLoader::Desktop, true);
    if (path.isEmpty()) {
        path = KIconLoader::global()->iconPath(iconName, KIconLoader::Place, true);
    }
    if (path.isEmpty()) {
        path = KIconLoader::global()->iconPath(iconName, KIconLoader::MimeType, true);
    }
    if (path.isEmpty()) {
        path = KIconLoader::global()->iconPath(iconName, KIconLoader::Toolbar, true);
    }
    if (path.isEmpty()) {
        path = KIconLoader::global()->iconPath(iconName, KIconLoader::Panel, true);
    }
    if (path.isEmpty()) {
        path = KIconLoader::global()->iconPath(iconName, KIconLoader::Small, true);
    }
    if (!path.isEmpty()) {
        return path;
    }

    // Fallback to symbolic variant if regular icon was not found
    if (!isExplicitSymbolic && !isAction) {
        const QString symbolicName = iconName + QStringLiteral("-symbolic");
        path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Panel, true);
        if (path.isEmpty()) {
            path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Toolbar, true);
        }
        if (path.isEmpty()) {
            path = KIconLoader::global()->iconPath(symbolicName, KIconLoader::Desktop, true);
        }
    }
    return path;
}

QString CachyTheme::iconUrl(const QString &name, const QString &fallback) const
{
    if (name.isEmpty()) {
        return QString();
    }

    if (name.startsWith(QStringLiteral("qrc:/")) || name.startsWith(QStringLiteral("file://"))) {
        return name;
    }

    // 1. Embedded CachyOS.UI structural vector icons (qrc:/CachyOS/UI/icons/*.svg):
    // always available in memory with zero disk I/O for standard design system
    // controls (chevrons, sliders, waveforms, window buttons).
    const QString builtinResource = QStringLiteral(":/CachyOS/UI/icons/") + name + QStringLiteral(".svg");
    if (QFile::exists(builtinResource)) {
        return QStringLiteral("qrc") + builtinResource;
    }

    // 2. Resolve from active system icon theme (e.g. MacTahoe, Breeze, etc.)
    // via KIconLoader. This ensures user-selected icon themes in System Settings
    // (such as MacTahoe folders, places, and mimetypes) take top precedence.
    const QString themeIconPath = findThemeIconPath(name);
    if (!themeIconPath.isEmpty()) {
        return QUrl::fromLocalFile(themeIconPath).toString();
    }

    // 3. Structural builtin alias check: map canonical freedesktop names
    // to embedded CachyOS.UI vector icons as fallback if the active desktop theme
    // does not provide the icon.
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
        {QStringLiteral("settings-configure"), QStringLiteral("settings")},
        {QStringLiteral("preferences-system"), QStringLiteral("settings")},
        {QStringLiteral("window-pin"), QStringLiteral("pin")},
        {QStringLiteral("user-trash"), QStringLiteral("trash")},
        {QStringLiteral("edit-delete"), QStringLiteral("trash")},
        {QStringLiteral("view-list-icons"), QStringLiteral("grid")},
        {QStringLiteral("view-list-details"), QStringLiteral("list")},
        {QStringLiteral("media-playback-start"), QStringLiteral("play")},
        {QStringLiteral("media-playback-pause"), QStringLiteral("pause")},
        {QStringLiteral("office-chart-bar"), QStringLiteral("chart-bar")},
        {QStringLiteral("view-financial-transfer"), QStringLiteral("chart-bar")},
        {QStringLiteral("preferences-system-time"), QStringLiteral("hourglass")},
        {QStringLiteral("chronometer"), QStringLiteral("hourglass")},
        {QStringLiteral("notifications-disabled"), QStringLiteral("bell-off")},
        {QStringLiteral("security-high"), QStringLiteral("shield-check")},
        {QStringLiteral("user-identity"), QStringLiteral("user")},
        {QStringLiteral("accessories-text-editor"), QStringLiteral("book")},
        {QStringLiteral("applications-other"), QStringLiteral("apps")},
        {QStringLiteral("system-run"), QStringLiteral("apps")},
    };
    if (const QString alias = builtinAliases.value(name); !alias.isEmpty()) {
        const QString aliasResource = QStringLiteral(":/CachyOS/UI/icons/") + alias + QStringLiteral(".svg");
        if (QFile::exists(aliasResource)) {
            return QStringLiteral("qrc") + aliasResource;
        }
    }

    // 4. Fallback lookup if specified
    if (!fallback.isEmpty() && fallback != name) {
        return iconUrl(fallback);
    }

    return QString();
}

void CachyTheme::onColorSchemeChanged()
{
    Q_EMIT themeChanged();
}
