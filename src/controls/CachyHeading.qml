/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Heading of the CachyOS.UI design system: a text with the semantic levels of
 * the Golden Gate scale. It is a drop-in replacement of the Kirigami heading
 * (`level` 1..5) with the tokens of the design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Text {
    id: root

    /// Semantic level: 1 (page title) .. 5 (caption).
    property int level: 3

    readonly property real scale: [1.65, 1.35, 1.15, 1.0, 0.9][Math.max(0, Math.min(4, level - 1))]

    font.pixelSize: Math.round(13 * scale)
    font.weight: level <= 2 ? Font.DemiBold : (level === 3 ? Font.Medium : Font.Normal)
    color: CachyTheme.textPrimary

    // Long headings must never overflow their container.
    elide: Text.ElideRight
}
