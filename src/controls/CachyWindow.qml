/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import CachyOS.UI

Window {
    id: root

    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    property bool showTrafficLights: true
    property bool closable: true
    property bool minimizable: true
    property bool maximizable: true
    property alias windowTitle: titleLabel.text
    property alias contentData: contentArea.data
    property int cornerRadius: CachyTheme.radiusWindow

    CachyWindowBlur.enabled: true

    Rectangle {
        id: windowSurface
        anchors.fill: parent
        radius: root.cornerRadius
        color: CachyTheme.windowBackground
        border.width: 1
        border.color: CachyTheme.specularBorder
        clip: true

        // Drag Handler to drag the window by titlebar or empty space
        DragHandler {
            id: windowDrag
            target: null
            onActiveChanged: {
                if (active) {
                    root.startSystemMove();
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // macOS Traffic Light TitleBar
            Item {
                id: titleBar
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                visible: root.showTrafficLights

                Row {
                    id: trafficLights
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    property bool hovered: lightsHover.hovered

                    HoverHandler {
                        id: lightsHover
                    }

                    // Close Button (Red)
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.closable ? CachyTheme.closeButton : CachyTheme.textMuted
                        opacity: root.closable ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 8
                            font.bold: true
                            color: Qt.rgba(0, 0, 0, 0.6)
                            visible: trafficLights.hovered && root.closable
                        }

                        TapHandler {
                            enabled: root.closable
                            onTapped: root.close()
                        }
                    }

                    // Minimize Button (Yellow)
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.minimizable ? CachyTheme.minimizeButton : CachyTheme.textMuted
                        opacity: root.minimizable ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: "–"
                            font.pixelSize: 10
                            font.bold: true
                            color: Qt.rgba(0, 0, 0, 0.6)
                            visible: trafficLights.hovered && root.minimizable
                        }

                        TapHandler {
                            enabled: root.minimizable
                            onTapped: root.showMinimized()
                        }
                    }

                    // Maximize / Zoom Button (Green)
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.maximizable ? CachyTheme.maximizeButton : CachyTheme.textMuted
                        opacity: root.maximizable ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.pixelSize: 10
                            font.bold: true
                            color: Qt.rgba(0, 0, 0, 0.6)
                            visible: trafficLights.hovered && root.maximizable
                        }

                        TapHandler {
                            enabled: root.maximizable
                            onTapped: {
                                if (root.visibility === Window.Maximized) {
                                    root.showNormal();
                                } else {
                                    root.showMaximized();
                                }
                            }
                        }
                    }
                }

                // Window Title (Centered)
                Text {
                    id: titleLabel
                    anchors.centerIn: parent
                    text: root.title
                    color: CachyTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            // Client Content Area
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
