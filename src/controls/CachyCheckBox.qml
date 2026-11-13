/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Squircle checkbox control of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.CheckBox {
    id: control

    implicitWidth: Math.max(18, indicator.width + (control.text.length > 0 ? spacing + contentItem.implicitWidth : 0))
    implicitHeight: Math.max(24, contentItem.implicitHeight)
    spacing: CachyTheme.spacingSmall

    property color accentColor: CachyTheme.accentColor

    indicator: Rectangle {
        x: control.leftPadding
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)
        width: 18
        height: 18
        radius: 5
        color: control.checked
            ? (control.enabled ? control.accentColor : CachyTheme.textMuted)
            : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))
        border.width: control.checked ? 0 : 1
        border.color: boxHover.hovered ? CachyTheme.accentColor : CachyTheme.specularBorder

        scale: control.pressed ? 0.90 : 1.0
        Behavior on scale {
            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutQuad }
        }
        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        CachyIcon {
            anchors.centerIn: parent
            name: "check"
            size: 12
            color: "#FFFFFF"
            visible: control.checked
            scale: control.checked ? 1.0 : 0.4
            Behavior on scale {
                NumberAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutBack; easing.overshoot: 1.8 }
            }
        }
    }

    contentItem: Text {
        leftPadding: control.indicator.width + (control.text.length > 0 ? control.spacing : 0)
        text: control.text
        visible: control.text.length > 0
        font.pixelSize: 13
        color: control.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    HoverHandler {
        id: boxHover
        cursorShape: Qt.PointingHandCursor
    }
}
