/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * macOS 27 Golden Gate Liquid Glass thick capsule slider for Control Center.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Slider {
    id: control

    implicitWidth: 220
    implicitHeight: 32

    property string iconName: ""
    property color accentColor: CachyTheme.accentColor
    property color fillColor: "#FFFFFF"
    property color fillIconColor: "#1C1C1E"
    property bool showValueToolTip: true

    hoverEnabled: true

    background: Rectangle {
        id: track
        x: control.leftPadding
        y: control.topPadding
        width: control.availableWidth
        height: control.availableHeight
        radius: height / 2
        clip: true
        color: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        border.color: control.visualFocus ? control.accentColor : CachyPalette.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        // Base icon (in dark/unfilled area)
        CachyIcon {
            id: baseIcon
            x: Math.round(control.height * 0.28)
            anchors.verticalCenter: parent.verticalCenter
            size: Math.round(control.height * 0.48)
            name: control.iconName
            color: CachyPalette.textSecondary
            visible: control.iconName.length > 0
        }

        // Luminous fill capsule
        Rectangle {
            id: fillRect
            x: 0
            y: 0
            height: parent.height
            width: Math.max(0, Math.min(parent.width, control.visualPosition * parent.width))
            radius: height / 2
            clip: true
            color: control.enabled ? control.fillColor : CachyPalette.textMuted

            // Duplicate icon inside fill (revealed seamlessly by clip with dark contrast)
            CachyIcon {
                x: baseIcon.x
                y: Math.round((fillRect.height - height) / 2)
                size: baseIcon.size
                name: control.iconName
                color: control.fillIconColor
                visible: control.iconName.length > 0
            }
        }

        // Specular top highlight (Liquid Glass)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: 0.5
            color: Qt.rgba(1, 1, 1, 0.20)
        }
    }

    handle: Item {
        x: control.leftPadding + Math.round(control.visualPosition * (control.availableWidth - width))
        y: control.topPadding
        width: 0
        height: control.availableHeight
    }

    WheelHandler {
        target: control
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
            if (delta === 0) return;
            let step = (control.to - control.from) / 20.0;
            if (control.stepSize > 0) step = control.stepSize;
            let newVal = control.value + (delta > 0 ? step : -step);
            let minVal = Math.min(control.to, control.from);
            let maxVal = Math.max(control.to, control.from);
            control.value = Math.max(minVal, Math.min(maxVal, newVal));
            control.moved();
        }
    }

    HoverHandler {
        id: sliderHover
        cursorShape: Qt.PointingHandCursor
    }
}
