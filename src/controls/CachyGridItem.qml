/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Universal grid cell for icon/thumbnail views (Dolphin icon view &
 * FishUI cell_layout.cpp equivalent).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconName: "folder"
    property color iconColor: CachyTheme.accentColor
    property string thumbnailSource: ""
    property int iconSize: 44
    property string badgeText: ""
    property bool selected: false

    signal clicked()
    signal doubleClicked()
    signal contextMenuRequested(real x, real y)

    implicitWidth: 108
    implicitHeight: 104
    radius: CachyTheme.radiusMedium

    color: {
        if (root.selected) {
            return CachyTheme.withAlpha(CachyTheme.accentColor, CachyPalette.isDark ? 0.26 : 0.18);
        }
        if (cellHover.hovered) {
            return CachyPalette.cardBackgroundHover;
        }
        return "transparent";
    }

    border.width: root.selected ? 1 : 0
    border.color: CachyTheme.withAlpha(CachyTheme.accentColor, 0.50)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    HoverHandler {
        id: cellHover
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize

            Image {
                id: thumbImage
                anchors.fill: parent
                visible: root.thumbnailSource.length > 0 && status === Image.Ready
                source: root.thumbnailSource
                fillMode: Image.PreserveAspectCrop
                smooth: true
                cache: true
            }

            CachyIcon {
                anchors.centerIn: parent
                visible: !thumbImage.visible
                name: root.iconName
                size: root.iconSize
                color: root.iconColor
                colored: false
            }

            CachyBadge {
                visible: root.badgeText.length > 0
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: root.badgeText
                badgeType: "accent"
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.title
            font.pixelSize: 12
            font.weight: root.selected ? Font.DemiBold : Font.Normal
            color: CachyPalette.text
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            maximumLineCount: 1
        }

        Text {
            visible: root.subtitle.length > 0
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.subtitle
            font.pixelSize: 10
            color: CachyPalette.textMuted
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
