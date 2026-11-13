/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Liquid Glass tooltip popup of the CachyOS.UI design system
 * (inspired by FishUI PopupTips.qml).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.ToolTip {
    id: control

    x: parent ? Math.round((parent.width - implicitWidth) / 2) : 0
    y: -implicitHeight - 6

    implicitWidth: Math.max(40, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(26, contentItem.implicitHeight + topPadding + bottomPadding)

    leftPadding: 10
    rightPadding: 10
    topPadding: 5
    bottomPadding: 5

    delay: 450
    timeout: 4500

    contentItem: Text {
        text: control.text
        font.pixelSize: 12
        color: CachyPalette.text
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: CachyPalette.sheetBackground
        border.width: 1
        border.color: CachyPalette.specularBorder
    }
}
