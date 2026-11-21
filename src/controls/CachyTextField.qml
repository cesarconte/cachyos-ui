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
    property bool pillStyle: false

    implicitWidth: Math.max(180, contentWidth + leftPadding + rightPadding)
    implicitHeight: 32

    leftPadding: (control.isSearch || control.leadingIcon.length > 0) ? 32 : (control.pillStyle ? 14 : 12)
    rightPadding: (control.showClearButton && control.length > 0) ? 32 : (control.pillStyle ? 14 : 12)
    topPadding: 6
    bottomPadding: 6

    color: control.enabled ? CachyPalette.text : CachyPalette.textMuted
    placeholderTextColor: CachyPalette.textMuted
    selectedTextColor: "#FFFFFF"
    selectionColor: CachyTheme.accentColor
    verticalAlignment: TextInput.AlignVCenter
    font.pixelSize: 13

    background: Rectangle {
        radius: control.pillStyle ? Math.round(height / 2) : CachyTheme.radiusSmall
        color: control.pillStyle
            ? (control.activeFocus ? CachyPalette.cardBackgroundHover : CachyPalette.surfacePill)
            : (CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.32) : Qt.rgba(0, 0, 0, 0.06))
        border.width: control.activeFocus ? (control.pillStyle ? 1.5 : 2) : 1
        border.color: control.activeFocus
            ? CachyTheme.accentColor
            : (fieldHover.hovered ? CachyTheme.withAlpha(CachyPalette.specularBorder, 0.40) : CachyPalette.specularBorder)

        Behavior on border.color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        HoverHandler {
            id: fieldHover
            cursorShape: Qt.IBeamCursor
        }
    }

    // Leading Icon (Vector Search Magnifier or Named Icon / Glyph) - Capa z: 10
    CachyIcon {
        z: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        name: control.isSearch ? "search" : control.leadingIcon
        size: 14
        color: CachyPalette.textSecondary
        visible: control.isSearch || (control.leadingIcon.length > 0 && valid)
    }

    Text {
        z: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: control.leadingIcon
        font.pixelSize: 11
        color: CachyPalette.textSecondary
        visible: !control.isSearch && control.leadingIcon.length > 0 && CachyTheme.iconUrl(control.leadingIcon).length === 0
    }

    // Placeholder text for QtQuick.Templates.TextField
    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        elide: Text.ElideRight
        visible: control.length === 0 && !control.preeditText && control.placeholderText.length > 0
    }

    // Clear Button (Vector Quick Clean) - Capa z: 10 interactiva
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
            ? (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(0, 0, 0, 0.28))
            : (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.15))
        visible: control.showClearButton && control.length > 0

        CachyIcon {
            anchors.centerIn: parent
            name: "close"
            size: 10
            color: CachyPalette.text
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
