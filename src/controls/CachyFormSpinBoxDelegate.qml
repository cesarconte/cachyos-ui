/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Form row with a label and a CachySpinBox, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    property string label: ""
    property alias from: spin.from
    property alias to: spin.to
    property alias value: spin.value
    property alias stepSize: spin.stepSize
    property alias prefix: spin.prefix
    property alias suffix: spin.suffix

    signal valueModified(int value)

    Layout.fillWidth: true
    implicitHeight: 40

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

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.label
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyPalette.text
        }

        CachySpinBox {
            id: spin
            onValueModified: (val) => root.valueModified(val)
        }
    }

    HoverHandler {
        id: rowHover
    }
}
