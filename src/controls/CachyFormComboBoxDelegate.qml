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
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.label
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyTheme.textPrimary
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
