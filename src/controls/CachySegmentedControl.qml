/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    property var model: []
    property int currentIndex: 0

    implicitWidth: segmentsRow.implicitWidth + 8
    implicitHeight: 32

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: CachyTheme.isDark ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        border.color: CachyTheme.specularBorder

        // Sliding indicator pill
        Rectangle {
            id: indicator
            y: 3
            height: parent.height - 6
            width: root.model.length > 0 ? (parent.width - 6) / root.model.length : 0
            x: 3 + (root.currentIndex * width)
            radius: CachyTheme.radiusSmall - 2
            color: CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.18) : "#FFFFFF"
            border.width: 0.5
            border.color: CachyTheme.specularBorder

            Behavior on x {
                NumberAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
            }
        }

        Row {
            id: segmentsRow
            anchors.fill: parent
            anchors.margins: 3

            Repeater {
                model: root.model

                Item {
                    id: segmentItem
                    width: (segmentsRow.width) / (root.model.length || 1)
                    height: segmentsRow.height

                    required property var modelData
                    required property int index

                    Text {
                        anchors.centerIn: parent
                        text: segmentItem.modelData
                        font.pixelSize: 12
                        font.weight: root.currentIndex === segmentItem.index ? Font.DemiBold : Font.Normal
                        color: root.currentIndex === segmentItem.index ? CachyTheme.textPrimary : CachyTheme.textSecondary
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.currentIndex = segmentItem.index
                    }
                }
            }
        }
    }
}
