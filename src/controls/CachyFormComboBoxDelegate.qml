/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Form row with a label and a CachyComboBox, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Label text of the row.
    property string label: ""
    /// Subtitle or secondary description.
    property string description: ""
    /// Model of the combo box.
    property alias model: combo.model
    /// Role name used when the model contains objects.
    property alias textRole: combo.textRole
    /// Currently selected index.
    property alias currentIndex: combo.currentIndex
    /// Currently displayed text.
    readonly property alias currentText: combo.currentText

    signal activated(int index)

    Layout.fillWidth: true
    implicitHeight: root.description.length > 0 ? 52 : 40

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: rowHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"
    }

    RowLayout {
        anchors.fill: parent
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
                text: root.label
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

        CachyComboBox {
            id: combo
            onActivated: (idx) => root.activated(idx)
        }
    }

    HoverHandler {
        id: rowHover
    }
}
