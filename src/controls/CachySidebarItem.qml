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
    property bool circularIconBadge: false
    property string badgeText: ""
    property bool selected: false
    property bool accentSelected: false
    property bool showText: {
        let w = Window.window;
        if (w && w.sidebarCollapsible !== undefined && w.sidebarCollapsible) {
            return !w.sidebarCollapsed;
        }
        return true;
    }
    property color selectedHighlightColor: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.09)

    readonly property bool hasBadge: root.squircleIconBadge || root.circularIconBadge
    readonly property bool isAccentPill: root.accentSelected && root.selected

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 32
    radius: 8

    color: {
        if (root.isAccentPill) return CachyTheme.accentColor;
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

        // Golden Gate Colorful Sidebar Icon (Squircle in Settings, Circle in Reminders/Passwords, flat vector in Finder)
        Rectangle {
            readonly property string resolvedIcon: root.iconName.length > 0 ? root.iconName : root.iconGlyph
            visible: resolvedIcon.length > 0
            Layout.alignment: root.showText ? (Qt.AlignLeft | Qt.AlignVCenter) : Qt.AlignCenter
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: root.circularIconBadge ? 11 : 6
            color: root.hasBadge ? root.iconColor : "transparent"

            CachyIcon {
                id: vectorIcon
                anchors.centerIn: parent
                name: parent.resolvedIcon
                size: root.circularIconBadge ? 12 : (root.squircleIconBadge ? 13 : 15)
                color: root.hasBadge ? "#FFFFFF" : (root.isAccentPill ? "#FFFFFF" : root.iconColor)
                visible: valid
            }

            Text {
                anchors.centerIn: parent
                text: root.iconGlyph
                font.pixelSize: root.circularIconBadge ? 12 : (root.squircleIconBadge ? 13 : 15)
                color: root.hasBadge ? "#FFFFFF" : (root.isAccentPill ? "#FFFFFF" : root.iconColor)
                visible: !vectorIcon.valid && root.iconGlyph.length > 0
            }
        }

        // Golden Gate Sidebar Label: Bold when actively selected
        Text {
            Layout.fillWidth: true
            visible: root.showText
            text: root.text
            color: root.isAccentPill ? "#FFFFFF" : CachyPalette.text
            font.pixelSize: 13
            font.bold: root.selected
            font.weight: root.selected ? Font.Bold : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        // Optional trailing count badge (e.g. Shortcuts / Reminders library counts)
        Text {
            visible: root.showText && root.badgeText.length > 0
            text: root.badgeText
            color: root.isAccentPill ? Qt.rgba(1, 1, 1, 0.85) : CachyPalette.textSecondary
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    CachyTooltip {
        visible: !root.showText && itemHover.hovered && root.text.length > 0
        text: root.text
    }
}
