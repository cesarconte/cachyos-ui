/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Document tab button of the CachyOS.UI design system
 * (inspired by FishUI TabButton.qml & window_tab_bar.cpp).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property bool selected: false
    property bool closable: true

    signal clicked()
    signal closeClicked()

    implicitWidth: 168
    implicitHeight: 30
    radius: CachyTheme.radiusSmall
    color: {
        if (root.selected) {
            return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.16) : "#FFFFFF";
        }
        if (tabHover.hovered) {
            return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05);
        }
        return "transparent";
    }
    border.width: root.selected ? 1 : 0
    border.color: CachyTheme.specularBorder

    Behavior on color {
        ColorAnimation { duration: CachyTheme.animFast }
    }

    HoverHandler {
        id: tabHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 6

        CachyIcon {
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            name: root.iconName
            size: 14
            color: root.selected ? CachyTheme.accentColor : CachyTheme.textSecondary
            visible: root.iconName.length > 0 && valid
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.text
            font.pixelSize: 12
            font.weight: root.selected ? Font.DemiBold : Font.Normal
            color: root.selected ? CachyTheme.textPrimary : CachyTheme.textSecondary
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            visible: root.closable
            opacity: (tabHover.hovered || root.selected || closeHover.hovered) ? 1.0 : 0.0
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            radius: 4
            color: closeHover.hovered
                ? (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12))
                : "transparent"

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }

            CachyIcon {
                anchors.centerIn: parent
                name: "close"
                size: 10
                color: CachyTheme.textSecondary
            }

            HoverHandler {
                id: closeHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.closeClicked()
            }
        }
    }
}
