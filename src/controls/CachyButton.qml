/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import CachyOS.UI

T.Button {
    id: control

    property bool primary: false
    property bool destructive: false
    property string iconName: ""

    leftPadding: 16
    rightPadding: 16
    topPadding: 6
    bottomPadding: 6

    implicitWidth: Math.max(84, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: 32

    scale: control.pressed ? 0.96 : (btnHover.hovered ? 1.01 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutCubic }
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: {
            if (control.flat) {
                return btnHover.hovered ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.15) : "transparent";
            }
            if (control.destructive) {
                return control.pressed ? Qt.darker("#FF3B30", 1.15) : "#FF3B30";
            }
            if (control.primary) {
                return control.pressed ? Qt.darker(CachyTheme.accentColor, 1.15) : CachyTheme.accentColor;
            }
            // Standard Button
            if (btnHover.hovered) {
                return CachyTheme.cardBackgroundHover;
            }
            return CachyTheme.cardBackground;
        }

        border.width: control.flat ? 0 : 1
        border.color: (control.primary || control.destructive)
            ? Qt.rgba(1, 1, 1, 0.22)
            : CachyTheme.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }
    }

    contentItem: Text {
        text: control.text
        color: {
            if (!control.enabled) return CachyTheme.textMuted;
            if (control.primary || control.destructive) return "#FFFFFF";
            if (control.flat) return CachyTheme.isDark ? "#409CFF" : CachyTheme.accentColor;
            return CachyTheme.textPrimary;
        }
        font.pixelSize: 13
        font.weight: control.primary ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    HoverHandler {
        id: btnHover
        cursorShape: Qt.PointingHandCursor
    }
}
