/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Canonical 28px bottom status bar for file managers (Dolphin), torrent
 * clients (Transmission) and document tools in CachyOS.UI.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string summaryText: ""
    property string secondaryText: ""
    property string leadingIcon: ""
    property bool showTopDivider: true
    default property alias trailingContent: trailingHost.data

    Layout.fillWidth: true
    implicitWidth: 420
    implicitHeight: 28
    color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.16) : Qt.rgba(0, 0, 0, 0.04)

    Rectangle {
        visible: root.showTopDivider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: CachyPalette.hardDividerColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: CachyTheme.marginCard
        anchors.rightMargin: CachyTheme.marginCard
        spacing: CachyTheme.spacingMedium

        CachyIcon {
            visible: root.leadingIcon.length > 0 && valid
            Layout.preferredWidth: 13
            Layout.preferredHeight: 13
            name: root.leadingIcon
            size: 13
            color: CachyPalette.textSecondary
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.summaryText
            font.pixelSize: 11
            color: CachyPalette.textSecondary
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: root.secondaryText.length > 0
            text: root.secondaryText
            font.pixelSize: 11
            font.weight: Font.Medium
            color: CachyPalette.text
            verticalAlignment: Text.AlignVCenter
        }

        RowLayout {
            id: trailingHost
            spacing: CachyTheme.spacingSmall
            visible: trailingHost.children.length > 0
        }
    }
}
