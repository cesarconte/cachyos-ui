/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Row of a form that acts as a button, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

import QtQuick.Templates as T

T.AbstractButton {
    id: root

    property string description: ""

    Layout.fillWidth: true
    implicitHeight: Math.max(root.description.length > 0 ? 52 : 40, Math.ceil(contentRow.implicitHeight) + topPadding + bottomPadding)
    leftPadding: CachyTheme.spacingMedium
    rightPadding: CachyTheme.spacingMedium
    topPadding: 8
    bottomPadding: 8

    contentItem: RowLayout {
        id: contentRow
        spacing: CachyTheme.spacingSmall

        CachyIcon {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            name: root.icon.name
            size: 20
            color: CachyPalette.text
            visible: root.icon.name.length > 0 && valid
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: root.text
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                font.weight: Font.Medium
                color: CachyPalette.text
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: root.description.length > 0
                text: root.description
                wrapMode: Text.WordWrap
                font.pixelSize: 11
                color: CachyPalette.textMuted
            }
        }

        CachyIcon {
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            name: "go-next-symbolic"
            size: 14
            color: CachyPalette.textMuted
            opacity: 0.5
        }
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: root.hovered ? CachyPalette.cardBackgroundHover : "transparent"

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
