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

    Layout.fillWidth: true
    implicitHeight: 40
    padding: 0

    contentItem: RowLayout {
        spacing: CachyTheme.spacingSmall

        Image {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            visible: root.icon.name.length > 0
            source: root.icon.name.length > 0 ? CachyTheme.iconUrl(root.icon.name) : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.text
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            font.weight: Font.Medium
            color: CachyTheme.textPrimary
        }
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: root.hovered ? CachyTheme.cardBackgroundHover : "transparent"

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
