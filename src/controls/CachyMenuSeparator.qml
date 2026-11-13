/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Horizontal separator inside a CachyMenu.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.MenuSeparator {
    id: control

    implicitWidth: 160
    implicitHeight: 9
    padding: 0

    contentItem: Rectangle {
        implicitWidth: 160
        implicitHeight: 1
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        color: CachyPalette.dividerColor
    }
}
