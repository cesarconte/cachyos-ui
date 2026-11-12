/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import CachyOS.UI

Item {
    id: root

    property Window window: Window.window
    property bool active: root.window ? root.window.active : true
    property bool closable: true
    property bool minimizable: true
    property bool maximizable: true

    implicitWidth: 55 // 3 botones de 13px + 2 espaciados de 8px
    implicitHeight: 16

    // HoverHandler que abarca la zona de los 3 botones como conjunto
    readonly property bool rowHovered: zoneHover.hovered

    HoverHandler {
        id: zoneHover
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        // =====================================================================
        // 1. CLOSE BUTTON (Red — Golden Gate Glassy + Bouncy Expand on Click)
        // =====================================================================
        Rectangle {
            id: closeBtn
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: closeTap.pressed
            readonly property bool isHovered: root.rowHovered

            scale: closeBtn.isPressed ? 1.18 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: closeBtn.isPressed ? 90 : 220
                    easing.type: closeBtn.isPressed ? Easing.OutQuad : Easing.OutBack
                    easing.overshoot: 2.2
                }
            }

            color: {
                if (!root.closable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (closeBtn.isPressed) return Qt.lighter("#FF5F56", 1.06);
                if (root.active || closeBtn.isHovered) return "#FF5F56";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.75
            border.color: (root.active || closeBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            // Subtly glassy top-left specular crescent (CachyOS)
            Rectangle {
                anchors.fill: parent
                anchors.margins: 0.75
                radius: width / 2
                visible: root.active || closeBtn.isHovered
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.42) }
                    GradientStop { position: 0.48; color: Qt.rgba(1, 1, 1, 0.06) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
                }
            }

            // Vector Glyphs (Exact CachyOS Stroke)
            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.closable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.68)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    startX: 3.8; startY: 3.8
                    PathLine { x: 9.2; y: 9.2 }
                }

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.68)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    startX: 9.2; startY: 3.8
                    PathLine { x: 3.8; y: 9.2 }
                }
            }

            TapHandler {
                id: closeTap
                enabled: root.closable
                onTapped: if (root.window) root.window.close()
            }
        }

        // =====================================================================
        // 2. MINIMIZE BUTTON (Yellow — Golden Gate Glassy + Bouncy Expand)
        // =====================================================================
        Rectangle {
            id: minBtn
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: minTap.pressed
            readonly property bool isHovered: root.rowHovered

            scale: minBtn.isPressed ? 1.18 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: minBtn.isPressed ? 90 : 220
                    easing.type: minBtn.isPressed ? Easing.OutQuad : Easing.OutBack
                    easing.overshoot: 2.2
                }
            }

            color: {
                if (!root.minimizable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (minBtn.isPressed) return Qt.lighter("#FFBD2E", 1.06);
                if (root.active || minBtn.isHovered) return "#FFBD2E";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.75
            border.color: (root.active || minBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 0.75
                radius: width / 2
                visible: root.active || minBtn.isHovered
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.42) }
                    GradientStop { position: 0.48; color: Qt.rgba(1, 1, 1, 0.06) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
                }
            }

            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.minimizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.68)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    startX: 3.2; startY: 6.5
                    PathLine { x: 9.8; y: 6.5 }
                }
            }

            TapHandler {
                id: minTap
                enabled: root.minimizable
                onTapped: if (root.window) root.window.showMinimized()
            }
        }

        // =====================================================================
        // 3. ZOOM / FULLSCREEN BUTTON (Green — Golden Gate Glassy + Bouncy)
        // =====================================================================
        Rectangle {
            id: maxBtn
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: maxTap.pressed
            readonly property bool isHovered: root.rowHovered

            scale: maxBtn.isPressed ? 1.18 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: maxBtn.isPressed ? 90 : 220
                    easing.type: maxBtn.isPressed ? Easing.OutQuad : Easing.OutBack
                    easing.overshoot: 2.2
                }
            }

            color: {
                if (!root.maximizable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (maxBtn.isPressed) return Qt.lighter("#27C93F", 1.06);
                if (root.active || maxBtn.isHovered) return "#27C93F";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.75
            border.color: (root.active || maxBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 0.75
                radius: width / 2
                visible: root.active || maxBtn.isHovered
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.42) }
                    GradientStop { position: 0.48; color: Qt.rgba(1, 1, 1, 0.06) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.14) }
                }
            }

            // Fullscreen Two Opposite Diagonal Arrows
            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.maximizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                // Top-right arrow
                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.68)
                    strokeWidth: 1.10
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: 6.8; startY: 3.8
                    PathLine { x: 9.2; y: 3.8 }
                    PathLine { x: 9.2; y: 6.2 }
                }

                // Bottom-left arrow
                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.68)
                    strokeWidth: 1.10
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: 6.2; startY: 9.2
                    PathLine { x: 3.8; y: 9.2 }
                    PathLine { x: 3.8; y: 6.8 }
                }
            }

            TapHandler {
                id: maxTap
                enabled: root.maximizable
                onTapped: {
                    if (!root.window) return;
                    if (root.window.visibility === Window.Maximized) {
                        root.window.showNormal();
                    } else {
                        root.window.showMaximized();
                    }
                }
            }
        }
    }
}
