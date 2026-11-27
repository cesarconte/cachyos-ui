/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Unified vector icon component of the CachyOS.UI design system.
 *
 * Inspired by Cutefish's FishUI Icon: resolves embedded CachyOS.UI SVG icons
 * (`qrc:/CachyOS/UI/icons/*.svg`) as well as desktop theme icons (Breeze /
 * Hicolor) through `CachyTheme.iconUrl()`, and tints monochrome/symbolic
 * icons directly in the Qt 6 RHI scene graph via `MultiEffect` without
 * relying on legacy Qt5Compat.GraphicalEffects.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import CachyOS.UI

Item {
    id: root

    /// Icon name (e.g. "search", "chevron-left", "edit-copy") or explicit URL.
    property string name: ""
    /// Compatibility alias for standard QtQuick / Kirigami icon source
    property alias source: root.name
    /// Optional fallback icon name if `name` is not found.
    property string fallback: ""
    /// Logical width and height of the icon in pixels.
    property int size: 16
    /// Tint color applied when `colored` is true.
    property color color: CachyPalette.text
    /// When true (default), monochrome/symbolic icons are tinted with `color`
    /// via MultiEffect colorization. ALWAYS keep `colored: true` when displaying
    /// monochrome vector icons that must render in a specific color (e.g. #FFFFFF
    /// on top of a colorful background card or squircle badge).
    /// Set to false ONLY for multi-color branded icons (e.g. application logos in
    /// About pages) that already have their own inherent multi-color artwork.
    property bool colored: true

    readonly property string resolvedSource: (CachyTheme.iconThemeName.length >= 0 && root.name.length > 0)
        ? CachyTheme.iconUrl(root.name, root.fallback)
        : ""
    readonly property bool valid: root.resolvedSource.length > 0
    readonly property bool isBuiltinIcon: root.resolvedSource.startsWith("qrc:/CachyOS/UI/icons/")

    implicitWidth: root.size
    implicitHeight: root.size
    width: root.size
    height: root.size
    layer.enabled: !root.isBuiltinIcon && root.colored

    Image {
        id: sourceImage
        anchors.fill: parent
        source: root.resolvedSource
        sourceSize.width: Math.max(1, Math.round(root.width * 2))
        sourceSize.height: Math.max(1, Math.round(root.height * 2))
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: true
        visible: !root.colored
    }

    MultiEffect {
        anchors.fill: sourceImage
        source: sourceImage
        visible: root.colored && root.valid
        // Lifting brightness to 1.0 normalizes dark symbolic icons (#232629)
        // and white builtin SVGs (#FFFFFF) to uniform white luminance before
        // colorization tints the alpha mask to the exact `root.color`.
        // Note: MultiEffect blends toward colorizationColor scaled by its alpha,
        // so pass full opaque RGB here and forward `root.color.a` via opacity.
        brightness: root.isBuiltinIcon ? 0.0 : 1.0
        colorization: 1.0
        colorizationColor: Qt.rgba(root.color.r, root.color.g, root.color.b, 1.0)
        opacity: root.color.a
    }
}
