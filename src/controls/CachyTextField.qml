/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.TextField {
    id: control

    property string leadingIcon: ""
    property bool showClearButton: true
    property bool isSearch: false

    implicitWidth: Math.max(180, contentWidth + leftPadding + rightPadding)
    implicitHeight: 32

    leftPadding: (control.isSearch || control.leadingIcon.length > 0) ? 32 : 12
    rightPadding: (control.showClearButton && control.length > 0) ? 32 : 12
    topPadding: 6
    bottomPadding: 6

    color: control.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
    placeholderTextColor: CachyTheme.textMuted
    selectedTextColor: "#FFFFFF"
    selectionColor: CachyTheme.accentColor
    verticalAlignment: TextInput.AlignVCenter
    font.pixelSize: 13

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: CachyTheme.isDark ? Qt.rgba(0, 0, 0, 0.32) : Qt.rgba(0, 0, 0, 0.06)
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? CachyTheme.accentColor
            : (fieldHover.hovered ? CachyTheme.withAlpha(CachyTheme.specularBorder, 0.40) : CachyTheme.specularBorder)

        Behavior on border.color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        HoverHandler {
            id: fieldHover
            cursorShape: Qt.IBeamCursor
        }
    }

    // Leading Icon (Search Magnifier or Custom) - Capa z: 10
    Text {
        z: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: control.isSearch ? "🔍" : control.leadingIcon
        font.pixelSize: 11
        color: CachyTheme.textSecondary
        visible: control.isSearch || control.leadingIcon.length > 0
    }

    // Clear Button (Quick Clean ✕) - Capa z: 10 interactiva
    Rectangle {
        id: clearBtn
        z: 10
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        radius: 8
        color: clearMouse.containsMouse
            ? (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(0, 0, 0, 0.28))
            : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.15))
        visible: control.showClearButton && control.length > 0

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 8
            font.bold: true
            color: CachyTheme.textPrimary
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                control.clear();
                control.forceActiveFocus();
            }
        }
    }
}
