/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * macOS 27 Golden Gate pill toggle switch of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Switch {
    id: control

    readonly property int trackWidth: 38
    readonly property int trackHeight: 22

    spacing: CachyTheme.spacingSmall
    implicitWidth: control.text.length > 0
        ? Math.max(control.trackWidth, contentItem.implicitWidth)
        : control.trackWidth
    implicitHeight: Math.max(control.trackHeight, control.text.length > 0 ? contentItem.implicitHeight : control.trackHeight)

    property color activeColor: CachyTheme.accentColor

    /// When it is false the switch only reflects the state: the state is
    /// owned by another item (a row of a form, for instance) that handles the
    /// interaction by itself.
    property bool interactive: true

    enabled: control.interactive

    indicator: Rectangle {
        id: track
        x: control.leftPadding
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)
        width: control.text.length > 0 ? control.trackWidth : control.availableWidth
        height: control.text.length > 0 ? control.trackHeight : control.availableHeight
        radius: Math.round(height / 2)
        color: control.checked
            ? control.activeColor
            : (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.14))

        border.width: control.checked ? 0 : 1
        border.color: CachyPalette.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
        }

        // Subtle Golden Gate top specular sheen on active track
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: control.checked
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.20) }
                GradientStop { position: 0.55; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }

        // macOS 27 Golden Gate elongated horizontal pill thumb
        Rectangle {
            id: thumb
            height: Math.max(10, parent.height - 4)
            width: Math.min(parent.width - 10, Math.round(height * 1.28))
            x: control.checked ? (parent.width - width - 2) : 2
            anchors.verticalCenter: parent.verticalCenter
            radius: Math.round(height / 2)
            color: "#FFFFFF"
            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.14)

            scale: control.pressed ? 0.94 : 1.0

            Behavior on x {
                NumberAnimation {
                    duration: CachyTheme.animNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.05
                }
            }

            Behavior on scale {
                NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutQuad }
            }
        }
    }

    contentItem: Text {
        leftPadding: control.trackWidth + (control.text.length > 0 ? control.spacing : 0)
        text: control.text
        visible: control.text.length > 0
        font.pixelSize: 13
        color: control.enabled ? CachyPalette.text : CachyPalette.textMuted
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    HoverHandler {
        enabled: control.interactive
        cursorShape: Qt.PointingHandCursor
    }
}
