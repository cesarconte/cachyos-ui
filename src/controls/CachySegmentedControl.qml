/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    property var model: []
    property int currentIndex: 0
    property bool pillStyle: true
    property bool accentSelected: false

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
        if (widest <= 0) return 32;
        if (widest <= 20) return 32;
        return widest + 24;
    }

    implicitWidth: root.model.length > 0 ? (root.model.length * root.segmentWidth) + 8 : 28
    implicitHeight: 32

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.pillStyle ? Math.round(height / 2) : CachyTheme.radiusSmall
        color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        border.color: CachyPalette.specularBorder

        // Sliding indicator pill
        Rectangle {
            id: indicator
            y: 3
            height: parent.height - 6
            width: root.model.length > 0 ? (parent.width - 6) / root.model.length : 0
            x: 3 + (root.currentIndex * width)
            radius: root.pillStyle ? Math.round(height / 2) : (CachyTheme.radiusSmall - 2)
            color: root.accentSelected
                ? CachyTheme.accentColor
                : (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.18) : "#FFFFFF")
            border.width: 0.5
            border.color: root.accentSelected ? Qt.rgba(1, 1, 1, 0.20) : CachyPalette.specularBorder

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

                    readonly property bool isObj: typeof modelData === "object" && modelData !== null
                    readonly property string itemText: isObj ? String(modelData.text ?? modelData.title ?? "") : String(modelData ?? "")
                    readonly property string itemIcon: isObj ? String(modelData.icon ?? modelData.iconName ?? "") : ""
                    readonly property string tooltipText: isObj ? String(modelData.tooltip ?? "") : ""

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        CachyIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: segmentItem.itemIcon.length > 0
                            name: segmentItem.itemIcon
                            size: 15
                            color: root.currentIndex === segmentItem.index
                                ? (root.accentSelected ? "#FFFFFF" : CachyPalette.text)
                                : CachyPalette.textSecondary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: segmentItem.itemText.length > 0
                            text: segmentItem.itemText
                            font.pixelSize: 12
                            font.weight: root.currentIndex === segmentItem.index ? Font.DemiBold : Font.Normal
                            color: root.currentIndex === segmentItem.index
                                ? (root.accentSelected ? "#FFFFFF" : CachyPalette.text)
                                : CachyPalette.textSecondary
                        }
                    }

                    HoverHandler {
                        id: segHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip.visible: segHover.hovered && segmentItem.tooltipText.length > 0
                    ToolTip.text: segmentItem.tooltipText
                    ToolTip.delay: 450

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

            Item {
                id: metricItem
                required property var modelData
                readonly property bool isObj: typeof modelData === "object" && modelData !== null
                readonly property string itemText: isObj ? String(modelData.text ?? modelData.title ?? "") : String(modelData ?? "")
                readonly property string itemIcon: isObj ? String(modelData.icon ?? modelData.iconName ?? "") : ""

                Text {
                    id: mText
                    font.pixelSize: 12
                    text: metricItem.itemText
                }

                implicitWidth: (metricItem.itemIcon.length > 0 ? 18 : 0) + (metricItem.itemText.length > 0 ? mText.implicitWidth + (metricItem.itemIcon.length > 0 ? 4 : 0) : 0)
            }
        }
    }
}
