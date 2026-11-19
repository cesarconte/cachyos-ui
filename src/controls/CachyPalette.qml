/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Effective palette of the CachyOS.UI design system.
 *
 * WHY THIS EXISTS
 *
 * A component must always be legible against the surface it is painted on.
 * That surface is not always painted by us:
 *
 *   * An APPLICATION paints it itself (`CachyWindow`), so the colour scheme
 *     of the application (`QStyleHints::colorScheme()`) describes it.
 *   * A PLASMOIDE is drawn inside `plasmashell`, on a surface that PLASMA
 *     paints: the panel, or the applet popup with its translucency and blur.
 *     There, the effective surface is described by the Plasma DESKTOP theme
 *     (the `colors` file of the active theme), which is not necessarily the
 *     same as the application colour scheme.
 *
 * With the macOS-GoldenGate theme the desktop theme is always dark with
 * white foregrounds (`ForegroundNormal=252,252,252`) while the application
 * scheme may well be light. Deriving the colours from the application
 * scheme therefore renders BLACK text on a DARK popup, and light surfaces on
 * a dark one: unreadable, and visually broken.
 *
 * `Kirigami.Theme` describes the surface that is actually visible in both
 * cases (the Plasma desktop theme inside `plasmashell`, the application
 * palette inside an application), so it is the correct single source for
 * every colour of the design system.
 *
 * The tones below reproduce EXACTLY the CachyTheme semantics (same alphas,
 * same Liquid Glass interpolation over `glassOpacity`), but keyed on the
 * darkness of the real surface instead of the application colour scheme.
 * Inside an application both agree, so nothing changes there; inside a
 * plasmoide the palette follows the theme of the panel it is drawn on.
 */

pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami
import CachyOS.UI

QtObject {
    // ── Foreground ─────────────────────────────────────────────────────────

    /// Primary foreground: the colour of the surface the content sits on.
    readonly property color text: Kirigami.Theme.textColor

    /// Secondary foreground (labels, hints, column headers).
    readonly property color textSecondary: Qt.rgba(text.r, text.g, text.b, 0.72)

    /// Muted foreground (decorative text, disabled hints).
    readonly property color textMuted: Qt.rgba(text.r, text.g, text.b, 0.48)

    // ── Semantics ──────────────────────────────────────────────────────────

    readonly property color accentColor: CachyTheme.accentColor
    readonly property color successColor: CachyTheme.successColor
    readonly property color warningColor: CachyTheme.warningColor
    readonly property color errorColor: CachyTheme.errorColor

    /// Accent colour meant to be used AS TEXT on the current surface.
    /// The base accent (#0A84FF) only reaches 3.1:1 over a light surface, so
    /// on a light surface a darker variant of the same hue is used instead
    /// (4.9:1); over a dark surface the base accent is already legible
    /// (4.6:1) and is kept, so the brand colour is preserved.
    readonly property color accentText: isDark ? accentColor : Qt.darker(accentColor, 1.28)

    // ── Surfaces (Liquid Glass) ───────────────────────────────────────────

    /// Whether the surface the content sits on is a dark one. The background
    /// is composited over the wallpaper first, so the alpha is resolved
    /// against a neutral backdrop before measuring its luminance.
    readonly property bool isDark: {
        const bg = Kirigami.Theme.backgroundColor;
        const r = bg.r * bg.a + 0.5 * (1 - bg.a);
        const g = bg.g * bg.a + 0.5 * (1 - bg.a);
        const b = bg.b * bg.a + 0.5 * (1 - bg.a);
        return (0.2126 * r + 0.7152 * g + 0.0722 * b) < 0.5;
    }

    readonly property real glassOpacity: CachyTheme.glassOpacity

    /// Translucent card surface.
    readonly property color cardBackground: isDark
        ? Qt.rgba(1, 1, 1, 0.06 + (glassOpacity * 0.08))
        : Qt.rgba(1, 1, 1, 0.45 + (glassOpacity * 0.32))

    /// Translucent card surface in its hovered state.
    readonly property color cardBackgroundHover: isDark
        ? Qt.rgba(1, 1, 1, 0.12 + (glassOpacity * 0.08))
        : Qt.rgba(1, 1, 1, 0.72 + (glassOpacity * 0.20))

    /// Translucent pill surface (toolbar buttons).
    readonly property color surfacePill: isDark
        ? Qt.rgba(1, 1, 1, 0.10 + (glassOpacity * 0.12))
        : Qt.rgba(1, 1, 1, 0.50 + (glassOpacity * 0.30))

    /// Main window surface.
    readonly property color windowBackground: isDark
        ? Qt.rgba(0.11, 0.11, 0.14, 0.24 + (glassOpacity * 0.44))
        : Qt.rgba(0.96, 0.97, 1.00, 0.30 + (glassOpacity * 0.46))

    /// Dense material for floating panels (popovers, sheets, menus).
    readonly property color sheetBackground: isDark
        ? Qt.rgba(0.12, 0.12, 0.15, 0.88 + (glassOpacity * 0.10))
        : Qt.rgba(0.98, 0.98, 1.00, 0.92 + (glassOpacity * 0.06))

    // ── Borders and dividers ──────────────────────────────────────────────

    /// Refractive 1 px border of the surfaces.
    readonly property color specularBorder: {
        const factor = 1.0 - (glassOpacity * 0.35);
        return isDark
            ? Qt.rgba(1, 1, 1, 0.18 * factor)
            : Qt.rgba(0, 0, 0, 0.12 * factor);
    }

    /// Structural 1 px divider (title bar, sidebar).
    readonly property color hardDividerColor: isDark
        ? Qt.rgba(1, 1, 1, 0.14)
        : Qt.rgba(0, 0, 0, 0.12);

    /// Subtle content divider.
    readonly property color dividerColor: isDark
        ? Qt.rgba(1, 1, 1, 0.10)
        : Qt.rgba(0, 0, 0, 0.08);

    // ── Interaction & Accessibility ────────────────────────────────────────

    /// Focus ring for accessible keyboard navigation.
    readonly property color focusRing: CachyTheme.focusRingColor

    /// Subtle hover overlay for interactive items.
    readonly property color hoverOverlay: isDark
        ? Qt.rgba(1, 1, 1, 0.08)
        : Qt.rgba(0, 0, 0, 0.05);

    /// Subtle pressed overlay for interactive items.
    readonly property color pressedOverlay: isDark
        ? Qt.rgba(1, 1, 1, 0.16)
        : Qt.rgba(0, 0, 0, 0.10);
}
