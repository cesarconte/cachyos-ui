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

    // macOS Tahoe (26): 14pt buttons, 22pt centre-to-centre (8pt gap), 16pt left inset
    implicitWidth: 58 // 3 * 14 + 2 * 8
    implicitHeight: 14

    readonly property bool rowHovered: zoneHover.hovered

    HoverHandler {
        id: zoneHover
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        // =====================================================================
        // 1. CLOSE BUTTON (Red)
        // =====================================================================
        Rectangle {
            id: closeBtn
            width: 14
            height: 14
            radius: 7

            readonly property bool isPressed: closeTap.pressed
            readonly property bool isHovered: root.rowHovered

            property color outerColor: {
                if (!root.closable) return "#4F5154";
                if (closeBtn.isPressed) return "#CB0518";
                if (root.active || closeBtn.isHovered) return "#F2001B";
                return "#4F5154";
            }
            property color innerColor: {
                if (!root.closable) return "#45474A";
                if (closeBtn.isPressed) return "#D44C50";
                if (root.active || closeBtn.isHovered) return "#FF5C60";
                return "#45474A";
            }

            color: closeBtn.innerColor
            border.width: 0.5
            border.color: closeBtn.outerColor

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }

            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.closable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: closeBtn.isPressed ? "#6A2728" : "#802F31"
                    strokeWidth: 2.25
                    capStyle: ShapePath.RoundCap

                    startX: 4.5; startY: 4.5
                    PathLine { x: 9.5; y: 9.5 }
                }

                ShapePath {
                    strokeColor: closeBtn.isPressed ? "#6A2728" : "#802F31"
                    strokeWidth: 2.25
                    capStyle: ShapePath.RoundCap

                    startX: 9.5; startY: 4.5
                    PathLine { x: 4.5; y: 9.5 }
                }
            }

            TapHandler {
                id: closeTap
                enabled: root.closable
                onTapped: if (root.window) root.window.close()
            }
        }

        // =====================================================================
        // 2. MINIMIZE BUTTON (Yellow)
        // =====================================================================
        Rectangle {
            id: minBtn
            width: 14
            height: 14
            radius: 7

            readonly property bool isPressed: minTap.pressed
            readonly property bool isHovered: root.rowHovered

            property color outerColor: {
                if (!root.minimizable) return "#4F5154";
                if (minBtn.isPressed) return "#C89200";
                if (root.active || minBtn.isHovered) return "#EFAE00";
                return "#4F5154";
            }
            property color innerColor: {
                if (!root.minimizable) return "#45474A";
                if (minBtn.isPressed) return "#D0A505";
                if (root.active || minBtn.isHovered) return "#FAC800";
                return "#45474A";
            }

            color: minBtn.innerColor
            border.width: 0.5
            border.color: minBtn.outerColor

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }

            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.minimizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: minBtn.isPressed ? "#68530B" : "#7E640C"
                    strokeWidth: 2.0
                    capStyle: ShapePath.RoundCap

                    startX: 4.0; startY: 7.0
                    PathLine { x: 10.0; y: 7.0 }
                }
            }

            TapHandler {
                id: minTap
                enabled: root.minimizable
                onTapped: if (root.window) root.window.showMinimized()
            }
        }

        // =====================================================================
        // 3. ZOOM / FULLSCREEN BUTTON (Green)
        // =====================================================================
        Rectangle {
            id: maxBtn
            width: 14
            height: 14
            radius: 7

            readonly property bool isPressed: maxTap.pressed
            readonly property bool isHovered: root.rowHovered

            property color outerColor: {
                if (!root.maximizable) return "#4F5154";
                if (maxBtn.isPressed) return "#008F03";
                if (root.active || maxBtn.isHovered) return "#00AC00";
                return "#4F5154";
            }
            property color innerColor: {
                if (!root.maximizable) return "#45474A";
                if (maxBtn.isPressed) return "#2EA44B";
                if (root.active || maxBtn.isHovered) return "#35C759";
                return "#45474A";
            }

            color: maxBtn.innerColor
            border.width: 0.5
            border.color: maxBtn.outerColor

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }

            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.maximizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                // Top-left triangle
                ShapePath {
                    fillColor: maxBtn.isPressed ? "#195225" : "#1E632D"
                    strokeColor: "transparent"
                    strokeWidth: 0

                    startX: 4.0; startY: 4.0
                    PathLine { x: 9.0; y: 4.0 }
                    PathLine { x: 4.0; y: 9.0 }
                    PathLine { x: 4.0; y: 4.0 }
                }

                // Bottom-right triangle
                ShapePath {
                    fillColor: maxBtn.isPressed ? "#195225" : "#1E632D"
                    strokeColor: "transparent"
                    strokeWidth: 0

                    startX: 10.0; startY: 10.0
                    PathLine { x: 5.0; y: 10.0 }
                    PathLine { x: 10.0; y: 5.0 }
                    PathLine { x: 10.0; y: 10.0 }
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
