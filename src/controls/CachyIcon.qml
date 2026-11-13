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
    /// Optional fallback icon name if `name` is not found.
    property string fallback: ""
    /// Logical width and height of the icon in pixels.
    property int size: 16
    /// Tint color applied when `colored` is true.
    property color color: CachyPalette.text
    /// When true (default), monochrome/symbolic icons are tinted with `color`.
    /// Set to false for full-color application icons (e.g. in About pages).
    property bool colored: true

    readonly property string resolvedSource: root.name.length > 0
        ? CachyTheme.iconUrl(root.name, root.fallback)
        : ""
    readonly property bool valid: root.resolvedSource.length > 0

    implicitWidth: root.size
    implicitHeight: root.size
    width: root.size
    height: root.size

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
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
    }
}
