/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Item {
    id: root

    property int orientation: Qt.Horizontal
    property int inset: 0
    property color color: CachyPalette.dividerColor

    implicitWidth: orientation === Qt.Horizontal ? 100 : 1
    implicitHeight: orientation === Qt.Horizontal ? 1 : 100

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: root.orientation === Qt.Horizontal ? root.inset : 0
        anchors.rightMargin: root.orientation === Qt.Horizontal ? root.inset : 0
        anchors.topMargin: root.orientation === Qt.Vertical ? root.inset : 0
        anchors.bottomMargin: root.orientation === Qt.Vertical ? root.inset : 0
        color: root.color
    }
}
