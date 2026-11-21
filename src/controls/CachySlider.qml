/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Slider {
    id: control

    implicitWidth: 220
    implicitHeight: 28

    property color accentColor: CachyTheme.accentColor

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)
        width: control.availableWidth
        height: 4
        radius: 2
        color: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.12)

        Rectangle {
            width: Math.max(0, control.visualPosition * parent.width)
            height: parent.height
            radius: 2
            color: control.enabled ? control.accentColor : CachyPalette.textMuted
        }
    }

    handle: Rectangle {
        x: control.leftPadding + Math.round(control.visualPosition * (control.availableWidth - width))
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)
        width: 22
        height: 14
        radius: 7
        color: "#FFFFFF"
        border.width: 0.5
        border.color: Qt.rgba(0, 0, 0, 0.18)

        scale: control.pressed ? 1.06 : (handleHover.hovered ? 1.03 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutQuad }
        }

        HoverHandler {
            id: handleHover
            cursorShape: Qt.PointingHandCursor
        }
    }
}
