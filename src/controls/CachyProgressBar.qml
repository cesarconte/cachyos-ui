/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.ProgressBar {
    id: control

    implicitWidth: 200
    implicitHeight: 6

    property color accentColor: CachyTheme.accentColor

    background: Rectangle {
        anchors.fill: parent
        radius: Math.round(height / 2)
        color: CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
    }

    contentItem: Item {
        anchors.fill: parent

        Rectangle {
            id: fillBar
            height: parent.height
            radius: Math.round(height / 2)
            color: control.accentColor

            width: control.indeterminate ? parent.width * 0.35 : Math.max(0, control.visualPosition * parent.width)

            // Indeterminate animation
            SequentialAnimation on x {
                running: control.indeterminate && control.visible
                loops: Animation.Infinite
                NumberAnimation {
                    from: -fillBar.width
                    to: control.width
                    duration: 1100
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }
}
