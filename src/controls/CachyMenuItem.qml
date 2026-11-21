/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Menu item of the CachyOS.UI design system, with icon, keyboard shortcut
 * hint, checkable state and destructive action coloring.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import CachyOS.UI

T.MenuItem {
    id: control

    property string iconName: ""
    property string shortcutText: ""
    property bool destructive: false

    readonly property string effectiveIconName: control.iconName.length > 0 ? control.iconName : control.icon.name
    readonly property color fgColor: {
        if (!control.enabled) return CachyPalette.textMuted;
        if (control.destructive) return (control.highlighted || itemHover.hovered) ? "#FFFFFF" : "#FF3B30";
        if (control.highlighted || itemHover.hovered) return "#FFFFFF";
        return CachyPalette.text;
    }

    implicitWidth: Math.max(160, Math.ceil(row.implicitWidth) + leftPadding + rightPadding + 4)
    implicitHeight: 30
    leftPadding: 10
    rightPadding: 10
    topPadding: 4
    bottomPadding: 4

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: {
            if (!control.enabled) return "transparent";
            if (control.highlighted || itemHover.hovered) {
                return control.destructive ? "#FF3B30" : CachyTheme.accentColor;
            }
            return "transparent";
        }
    }

    contentItem: RowLayout {
        id: row
        spacing: 8

        CachyIcon {
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            name: control.checkable ? "check" : control.effectiveIconName
            size: 14
            color: control.fgColor
            visible: control.checkable || (control.effectiveIconName.length > 0 && valid)
            opacity: control.checkable ? (control.checked ? 1.0 : 0.0) : 1.0
        }

        Text {
            id: labelText
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: control.text
            font.pixelSize: 13
            color: control.fgColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            Layout.leftMargin: 12
            visible: control.shortcutText.length > 0
            text: control.shortcutText
            font.pixelSize: 11
            color: (control.highlighted || itemHover.hovered)
                ? Qt.rgba(1, 1, 1, 0.80)
                : CachyPalette.textMuted
            verticalAlignment: Text.AlignVCenter
        }
    }

    HoverHandler {
        id: itemHover
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
