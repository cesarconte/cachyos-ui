/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Horizontal separator inside a CachyMenu.
 *
 * macOS Golden Gate metrics: an 11 px tall row with a single 1 px hairline
 * centered vertically, inset horizontally so it aligns with the menu item
 * labels (menu padding 5 + item padding 10 = 15 px from the menu edge).
 *
 * The hairline lives inside a wrapper Item: T.Control resizes its contentItem
 * to the full available height, so using the Rectangle directly as
 * contentItem turned the hairline into a solid band as tall as the separator.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.MenuSeparator {
    id: control

    /// Horizontal inset of the hairline on each side.
    property real inset: 10

    implicitWidth: 160
    implicitHeight: 11
    padding: 0

    contentItem: Item {
        implicitWidth: 160
        implicitHeight: 1

        Rectangle {
            x: control.inset
            width: Math.max(0, parent.width - control.inset * 2)
            height: 1
            y: Math.round((parent.height - height) / 2)
            color: CachyPalette.dividerColor
        }
    }
}
