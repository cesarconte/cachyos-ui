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

    // Canonical segment metrics.
    //
    // The segment width is measured from the labels (TextMetrics) instead of
    // being derived from the laid-out children. Deriving it from the children
    // creates a binding cycle:
    //     implicitWidth -> segmentsRow.implicitWidth -> child widths
    //                   -> segmentsRow.width -> control.width -> implicitWidth
    // which makes the control spin at 100% CPU during creation.
    readonly property real segmentWidth: {
        var widest = 0;
        for (var i = 0; i < metricsHost.children.length; ++i) {
            var item = metricsHost.children[i];
            if (item && item.implicitWidth > widest) {
                widest = item.implicitWidth;
            }
        }
        return widest > 0 ? widest + 24 : 44;
    }

    implicitWidth: root.model.length > 0 ? (root.model.length * root.segmentWidth) + 8 : 28
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
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 3
            // Explicit width: deriving it from the children would close a
            // binding cycle (implicitWidth -> contentWidth -> child widths).
            width: Math.max(0, bg.width - 6)

            Repeater {
                model: root.model

                Item {
                    id: segmentItem
                    width: root.model.length > 0 ? (segmentsRow.width / root.model.length) : 0
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

    // Off-screen label metrics used to size the control without creating a
    // binding cycle with the laid-out segments.
    Item {
        id: metricsHost
        visible: false
        width: 0
        height: 0

        Repeater {
            model: root.model

            Text {
                required property var modelData
                font.pixelSize: 12
                text: modelData
            }
        }
    }
}
