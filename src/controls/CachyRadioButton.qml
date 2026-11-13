/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Circular radio button control of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.RadioButton {
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
        radius: 9
        color: control.checked
            ? (control.enabled ? control.accentColor : CachyPalette.textMuted)
            : (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))
        border.width: control.checked ? 0 : 1
        border.color: radioHover.hovered ? CachyTheme.accentColor : CachyPalette.specularBorder

        scale: control.pressed ? 0.90 : 1.0
        Behavior on scale {
            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutQuad }
        }
        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 7
            height: 7
            radius: 3.5
            color: "#FFFFFF"
            visible: control.checked
            scale: control.checked ? 1.0 : 0.0
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
        color: control.enabled ? CachyPalette.text : CachyPalette.textMuted
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    HoverHandler {
        id: radioHover
        cursorShape: Qt.PointingHandCursor
    }
}
