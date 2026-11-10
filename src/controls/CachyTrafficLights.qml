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
    implicitHeight: 14

    // HoverHandler que abarca la zona de los 3 botones como conjunto (macOS style)
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
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: closeTap.pressed
            readonly property bool isHovered: root.rowHovered

            color: {
                if (!root.closable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (closeBtn.isPressed) return Qt.darker("#FF5F56", 1.25);
                if (root.active || closeBtn.isHovered) return "#FF5F56";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            // Vector Glyphs (Exact macOS Golden Gate Stroke)
            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.closable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.65)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    // Diagonal 1: (3.8, 3.8) -> (9.2, 9.2)
                    startX: 3.8; startY: 3.8
                    PathLine { x: 9.2; y: 9.2 }
                }

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.65)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    // Diagonal 2: (9.2, 3.8) -> (3.8, 9.2)
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
        // 2. MINIMIZE BUTTON (Yellow)
        // =====================================================================
        Rectangle {
            id: minBtn
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: minTap.pressed
            readonly property bool isHovered: root.rowHovered

            color: {
                if (!root.minimizable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (minBtn.isPressed) return Qt.darker("#FFBD2E", 1.25);
                if (root.active || minBtn.isHovered) return "#FFBD2E";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.minimizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.65)
                    strokeWidth: 1.15
                    capStyle: ShapePath.RoundCap

                    // Horizontal bar: (3.2, 6.5) -> (9.8, 6.5)
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
        // 3. ZOOM / FULLSCREEN BUTTON (Green)
        // =====================================================================
        Rectangle {
            id: maxBtn
            width: 13
            height: 13
            radius: 6.5

            readonly property bool isPressed: maxTap.pressed
            readonly property bool isHovered: root.rowHovered

            color: {
                if (!root.maximizable) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.15);
                if (maxBtn.isPressed) return Qt.darker("#27C93F", 1.25);
                if (root.active || maxBtn.isHovered) return "#27C93F";
                return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20);
            }

            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.20)

            Behavior on color { ColorAnimation { duration: 140 } }

            // macOS Fullscreen Two Opposite Diagonal Arrows
            Shape {
                anchors.fill: parent
                opacity: (root.rowHovered && root.maximizable) ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                layer.enabled: true
                layer.samples: 4

                // Top-right arrow
                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.65)
                    strokeWidth: 1.10
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: 6.8; startY: 3.8
                    PathLine { x: 9.2; y: 3.8 }
                    PathLine { x: 9.2; y: 6.2 }
                }

                // Bottom-left arrow
                ShapePath {
                    strokeColor: Qt.rgba(0, 0, 0, 0.65)
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
