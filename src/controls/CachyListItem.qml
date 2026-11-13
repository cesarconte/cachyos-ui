/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Universal rich list item of the CachyOS.UI design system
 * (Vuetify v-list-item equivalent for Dolphin, Transmission, settings lists).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string statusText: ""
    property string iconName: ""
    property color iconColor: CachyTheme.accentColor
    property bool squircleIconBadge: false

    /// When >= 0.0 and <= 1.0, renders an inline CachyProgressBar (ideal for
    /// Transmission torrents, file transfers or package installations).
    property real progressValue: -1.0
    property color progressColor: CachyTheme.accentColor

    property string badgeText: ""
    property string badgeType: "neutral"

    property bool selected: false
    property bool showDivider: false
    default property alias trailingActions: trailingHost.data

    signal clicked()
    signal doubleClicked()
    signal contextMenuRequested(real x, real y)

    readonly property bool hasProgress: root.progressValue >= 0.0

    implicitWidth: 360
    implicitHeight: Math.max(root.hasProgress ? 62 : 48, mainRow.implicitHeight + 16)
    radius: CachyTheme.radiusSmall

    color: {
        if (root.selected) {
            return CachyTheme.withAlpha(CachyTheme.accentColor, CachyPalette.isDark ? 0.24 : 0.16);
        }
        if (rowHover.hovered) {
            return CachyPalette.cardBackgroundHover;
        }
        return "transparent";
    }

    border.width: root.selected ? 1 : 0
    border.color: CachyTheme.withAlpha(CachyTheme.accentColor, 0.45)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    HoverHandler {
        id: rowHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
        onDoubleTapped: root.doubleClicked()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: (eventPoint) => {
            root.contextMenuRequested(eventPoint.position.x, eventPoint.position.y);
        }
    }

    RowLayout {
        id: mainRow
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: CachyTheme.spacingMedium

        // Leading icon or squircle badge
        Rectangle {
            visible: root.iconName.length > 0
            Layout.preferredWidth: root.squircleIconBadge ? 32 : 24
            Layout.preferredHeight: root.squircleIconBadge ? 32 : 24
            Layout.alignment: Qt.AlignVCenter
            radius: root.squircleIconBadge ? 8 : 0
            color: root.squircleIconBadge ? root.iconColor : "transparent"

            CachyIcon {
                anchors.centerIn: parent
                name: root.iconName
                size: root.squircleIconBadge ? 18 : 20
                color: root.squircleIconBadge ? "#FFFFFF" : root.iconColor
            }
        }

        // Center column: Title (+ badge + status), optional progress bar, subtitle
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: CachyTheme.spacingSmall

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.title
                    font.pixelSize: 13
                    font.weight: root.selected ? Font.Bold : Font.DemiBold
                    color: CachyPalette.text
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                CachyBadge {
                    visible: root.badgeText.length > 0
                    text: root.badgeText
                    badgeType: root.badgeType
                }

                Text {
                    visible: root.statusText.length > 0
                    text: root.statusText
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: CachyPalette.textSecondary
                    verticalAlignment: Text.AlignVCenter
                }
            }

            CachyProgressBar {
                visible: root.hasProgress
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                value: Math.max(0.0, Math.min(1.0, root.progressValue))
                accentColor: root.progressColor
            }

            Text {
                visible: root.subtitle.length > 0
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: root.subtitle
                font.pixelSize: 11
                color: CachyPalette.textSecondary
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Trailing custom actions (e.g. pause/resume/delete buttons)
        RowLayout {
            id: trailingHost
            Layout.alignment: Qt.AlignVCenter
            spacing: 6
            visible: trailingHost.children.length > 0
        }
    }

    CachyDivider {
        visible: root.showDivider && !root.selected
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        inset: root.iconName.length > 0 ? 48 : 12
    }
}
