/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Dual/multi-pane split view with a 1px reactive Golden Gate handle
 * (for Dolphin dual-pane F3 view or Transmission details inspector).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.SplitView {
    id: control

    implicitWidth: 480
    implicitHeight: 320

    handle: Rectangle {
        implicitWidth: control.orientation === Qt.Horizontal ? 5 : control.width
        implicitHeight: control.orientation === Qt.Horizontal ? control.height : 5
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: control.orientation === Qt.Horizontal ? 1 : parent.width
            height: control.orientation === Qt.Horizontal ? parent.height : 1
            color: T.SplitHandle.pressed || T.SplitHandle.hovered
                ? CachyTheme.accentColor
                : CachyPalette.hardDividerColor

            Behavior on color {
                ColorAnimation { duration: CachyTheme.animFast }
            }
        }
    }
}
