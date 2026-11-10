/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Switch {
    id: control

    implicitWidth: 44
    implicitHeight: 26

    property color activeColor: "#34C759" // iOS/macOS System Green

    indicator: Rectangle {
        id: track
        anchors.fill: parent
        radius: Math.round(height / 2)
        color: control.checked
            ? control.activeColor
            : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.14))

        border.width: control.checked ? 0 : 1
        border.color: CachyTheme.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: thumb
            x: control.checked ? parent.width - width - 2 : 2
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - 4
            height: parent.height - 4
            radius: Math.round(width / 2)
            color: "#FFFFFF"
            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.15)

            scale: control.pressed ? 0.92 : 1.0

            Behavior on x {
                NumberAnimation {
                    duration: CachyTheme.animNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.1
                }
            }

            Behavior on scale {
                NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutQuad }
            }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
