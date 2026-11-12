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
    /// State of the switch.
    property bool checked: false

    signal toggled(bool checked)

    Layout.fillWidth: true
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: rowHover.hovered ? CachyTheme.cardBackgroundHover : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        spacing: CachyTheme.spacingMedium

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.label.length > 0 ? root.label : root.text
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyTheme.textPrimary
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
        onTapped: root.toggled(!root.checked)
    }
}
