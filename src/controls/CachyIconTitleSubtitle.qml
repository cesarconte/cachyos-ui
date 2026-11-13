/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Item with an icon, a title and a subtitle, in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

import QtQuick.Templates as T

T.AbstractButton {
    id: root

    /// Main text.
    property string title: ""
    /// Secondary text.
    property string subtitle: ""
    /// Whether the item is the current one.
    property bool selected: false

    implicitWidth: 200
    implicitHeight: 48

    contentItem: RowLayout {
        spacing: CachyTheme.spacingSmall

        CachyIcon {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            name: root.icon.name
            size: 22
            color: root.selected ? CachyPalette.accentText : CachyPalette.text
            visible: root.icon.name.length > 0 && valid
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 0

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: root.title
                elide: Text.ElideRight
                font.pixelSize: 13
                font.weight: root.selected ? Font.Bold : Font.DemiBold
                color: root.selected ? CachyPalette.accentText : CachyPalette.text
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: root.subtitle.length > 0
                text: root.subtitle
                elide: Text.ElideRight
                font.pixelSize: 11
                color: CachyPalette.textMuted
            }
        }
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: root.checked || root.selected
            ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.16)
            : (root.hovered ? CachyPalette.cardBackgroundHover : "transparent")
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
