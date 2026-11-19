/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property string iconGlyph: ""
    property color iconColor: CachyTheme.accentColor
    property bool squircleIconBadge: false
    property string badgeText: ""
    property bool selected: false
    property bool showText: {
        let w = Window.window;
        if (w && w.sidebarCollapsible !== undefined && w.sidebarCollapsible) {
            return !w.sidebarCollapsed;
        }
        return true;
    }
    property color selectedHighlightColor: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.09)

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 32
    radius: 8

    color: {
        if (root.selected) return root.selectedHighlightColor;
        if (itemHover.hovered) return CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04);
        return "transparent";
    }

    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler {
        id: itemHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: itemTap
        onTapped: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.showText ? 10 : 0
        anchors.rightMargin: root.showText ? 10 : 0
        spacing: root.showText ? 10 : 0

        // Golden Gate Colorful Sidebar Icon (Squircle badge in System Settings, colorful vector icon in Finder/Shortcuts)
        Rectangle {
            readonly property string resolvedIcon: root.iconName.length > 0 ? root.iconName : root.iconGlyph
            visible: resolvedIcon.length > 0
            Layout.alignment: root.showText ? (Qt.AlignLeft | Qt.AlignVCenter) : Qt.AlignCenter
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: 6
            color: root.squircleIconBadge ? root.iconColor : "transparent"

            CachyIcon {
                id: vectorIcon
                anchors.centerIn: parent
                name: parent.resolvedIcon
                size: root.squircleIconBadge ? 13 : 15
                color: root.squircleIconBadge ? "#FFFFFF" : root.iconColor
                visible: valid
            }

            Text {
                anchors.centerIn: parent
                text: root.iconGlyph
                font.pixelSize: root.squircleIconBadge ? 13 : 15
                color: root.squircleIconBadge ? "#FFFFFF" : root.iconColor
                visible: !vectorIcon.valid && root.iconGlyph.length > 0
            }
        }

        // Golden Gate Sidebar Label: Bold when actively selected
        Text {
            Layout.fillWidth: true
            visible: root.showText
            text: root.text
            color: CachyPalette.text
            font.pixelSize: 13
            font.bold: root.selected
            font.weight: root.selected ? Font.Bold : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Optional trailing count badge (e.g. Shortcuts library counts)
        Text {
            visible: root.showText && root.badgeText.length > 0
            text: root.badgeText
            color: CachyPalette.textSecondary
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    CachyTooltip {
        visible: !root.showText && itemHover.hovered && root.text.length > 0
        text: root.text
    }
}
