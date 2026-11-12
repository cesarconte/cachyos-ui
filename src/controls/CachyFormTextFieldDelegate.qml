/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Row of a form with a label and a text field, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Text of the label.
    property string label: ""
    /// Text of the field.
    property alias text: inputField.text
    /// Emitted when the user accepts the value.
    signal accepted()

    Layout.fillWidth: true
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: rowHover.hovered ? CachyTheme.cardBackgroundHover : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: CachyTheme.spacingMedium
        anchors.rightMargin: CachyTheme.spacingMedium
        spacing: CachyTheme.spacingMedium

        Text {
            Layout.preferredWidth: 140
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            text: root.label
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyTheme.textSecondary
        }

        CachyTextField {
            id: inputField
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            font.pixelSize: 12
            onAccepted: root.accepted()
        }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }
}
