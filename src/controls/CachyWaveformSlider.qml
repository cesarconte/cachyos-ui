/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Audio Waveform / Precision Timeline Scrubber of the CachyOS.UI design system.
 * Renders an interactive audio scrubber with progress fill, hover seek preview,
 * and high-performance canvas or bar rendering.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property real position: 0.0 // 0.0 to 1.0
    property real duration: 0.0 // seconds or ms
    property color progressColor: CachyTheme.accentColor
    property color trackColor: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
    property bool interactive: true
    property var waveSamples: [0.3, 0.5, 0.8, 0.4, 0.6, 0.9, 0.7, 0.4, 0.8, 0.5, 0.6, 0.9, 0.8, 0.4, 0.7, 0.5, 0.3, 0.6, 0.8, 0.5]

    // ── Public Signals ─────────────────────────────────────────────────────
    signal seekRequested(real targetPosition)

    implicitWidth: 240
    implicitHeight: 28

    Rectangle {
        id: trackBg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 4
        radius: 2
        color: root.trackColor

        // Progress bar fill
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0.0, Math.min(1.0, root.position))
            radius: 2
            color: root.progressColor
        }
    }

    // Interactive waveform peaks
    Row {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: Math.max(2, (parent.width - (root.waveSamples.length * 3)) / root.waveSamples.length)

        Repeater {
            model: root.waveSamples

            Item {
                id: waveBar
                required property var modelData
                required property int index

                width: 3
                height: root.height

                readonly property real barProgress: waveBar.index / Math.max(1, root.waveSamples.length)
                readonly property bool isPlayed: barProgress <= root.position
                readonly property real barHeight: Math.max(4, root.height * Number(waveBar.modelData))

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: waveBar.barHeight
                    radius: 1.5
                    color: waveBar.isPlayed ? root.progressColor : root.trackColor

                    Behavior on color {
                        ColorAnimation { duration: CachyTheme.animFast }
                    }
                }
            }
        }
    }

    // Thumb / Handle
    Rectangle {
        id: handle
        x: Math.max(0, Math.min(root.width - width, (root.width * root.position) - (width / 2)))
        anchors.verticalCenter: parent.verticalCenter
        width: scrubMouse.containsMouse || scrubMouse.pressed ? 12 : 8
        height: width
        radius: width / 2
        color: "#FFFFFF"
        border.width: 1
        border.color: CachyTheme.accentColor

        Behavior on width {
            NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: scrubMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.interactive

        function updateSeek(mouseX: real) {
            var p = Math.max(0.0, Math.min(1.0, mouseX / root.width));
            root.position = p;
            root.seekRequested(p);
        }

        onClicked: (mouse) => updateSeek(mouse.x)
        onPositionChanged: (mouse) => {
            if (pressed) {
                updateSeek(mouse.x);
            }
        }
    }

    WheelHandler {
        target: root
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        enabled: root.interactive
        onWheel: (event) => {
            let delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x;
            if (delta === 0) return;
            let step = 0.05;
            let p = Math.max(0.0, Math.min(1.0, root.position + (delta > 0 ? step : -step)));
            root.position = p;
            root.seekRequested(p);
        }
    }
}
