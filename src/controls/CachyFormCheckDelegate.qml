/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Row of a form with a label and a switch, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Text of the label.
    property string label: ""
    /// Fallback text of the label.
    property string text: ""
    /// Subtitle or secondary description.
    property string description: ""
    /// State of the switch.
    property bool checked: false

    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: Math.max(root.description.length > 0 ? 52 : 40, Math.ceil(contentRow.implicitHeight) + 16)

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: rowHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"
    }

    RowLayout {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: CachyTheme.spacingMedium
        anchors.rightMargin: CachyTheme.spacingMedium
        spacing: CachyTheme.spacingMedium

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: root.label.length > 0 ? root.label : root.text
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                font.weight: Font.Medium
                color: CachyPalette.text
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: root.description.length > 0
                text: root.description
                wrapMode: Text.WordWrap
                font.pixelSize: 11
                color: CachyPalette.textMuted
            }
        }

        CachySwitch {
            checked: root.checked
            // The state belongs to the row: the switch only reflects it.
            interactive: false
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
