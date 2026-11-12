/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
import CachyOS.UI

Window {
    id: root

    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    width: CachyTheme.windowWidthUtility
    height: CachyTheme.windowHeightUtility
    minimumWidth: CachyTheme.windowWidthDialog
    minimumHeight: 400

    property bool showTrafficLights: true
    property bool showTitleBarDivider: true
    property bool showWindowFrame: true
    property bool closable: true
    property bool minimizable: true
    property bool maximizable: true
    property bool resizable: true
    property alias windowTitle: titleLabel.text
    default property alias contentData: contentHost.data
    property alias sidebar: sidebarHost.data
    property alias sidebarHeaderActions: sidebarHeaderTrailingArea.data
    property int sidebarWidth: 240
    property bool sidebarVisible: true
    readonly property bool hasSidebar: sidebarHost.children.length > 0 && root.sidebarVisible

    property alias headerLeading: headerLeadingArea.data
    property alias headerCenter: headerCenterArea.data
    property alias headerActions: headerTrailingArea.data
    property alias overlay: overlayContainer.data
    property int cornerRadius: CachyTheme.radiusWindow
    property color backgroundColor: "transparent"
    property int contentMargin: CachyTheme.marginWindow
    property bool contentPadded: false

    CachyWindowBlur.enabled: root.showWindowFrame

    Item {
        id: windowSurface
        anchors.fill: parent

        // Full-window squircle mask for edge-to-edge sidebars & content (macOS 27 Golden Gate)
        Item {
            id: windowMask
            anchors.fill: parent
            visible: false
            layer.enabled: true

            Rectangle {
                anchors.fill: parent
                radius: root.cornerRadius
                color: "white"
            }
        }

        // 1. Translucent Liquid Glass Background (macOS Golden Gate)
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            radius: root.cornerRadius
            color: root.backgroundColor !== "transparent" ? root.backgroundColor : CachyTheme.windowBackground
            visible: root.showWindowFrame
        }

        // 2. Liquid Glass Internal Gloss Sheen & Specular Highlights
        Rectangle {
            id: glossSheen
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            visible: root.showWindowFrame
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.16 * (1.0 - CachyTheme.glassOpacity * 0.4)) }
                GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, 0.04) }
                GradientStop { position: 0.75; color: Qt.rgba(1, 1, 1, 0.01) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
            }
        }

        // Masked interior container so edge-to-edge sidebars and content respect 20px squircle corners
        Item {
            id: interiorClippedContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: windowMask
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // =============================================================
                // A. Edge-to-Edge Golden Gate Sidebar (when sidebar is populated)
                // =============================================================
                Rectangle {
                    id: sidebarPane
                    visible: root.hasSidebar
                    Layout.preferredWidth: root.hasSidebar ? root.sidebarWidth : 0
                    Layout.fillHeight: true
                    color: CachyTheme.sidebarBackground

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Sidebar 44px Top Header (Traffic Lights on left, Sidebar Actions on right)
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.showTrafficLights ? CachyTheme.titleBarHeight : 0
                            visible: root.showTrafficLights

                            DragHandler {
                                target: null
                                cursorShape: Qt.ClosedHandCursor
                                onActiveChanged: if (active) root.startSystemMove()
                            }

                            CachyTrafficLights {
                                anchors.left: parent.left
                                anchors.leftMargin: root.contentMargin
                                anchors.verticalCenter: parent.verticalCenter
                                window: root
                                closable: root.closable
                                minimizable: root.minimizable
                                maximizable: root.maximizable
                            }

                            Item {
                                id: sidebarHeaderTrailingArea
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                width: childrenRect.width
                            }
                        }

                        // Sidebar Content Host
                        Item {
                            id: sidebarHost
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    // Full-height 1px Hard Divider on right edge of sidebar
                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 1
                        color: CachyTheme.hardDividerColor
                    }
                }

                // =============================================================
                // B. Main Window Column (44px Titlebar/Toolbar + Content Area)
                // =============================================================
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    // 3. macOS Titlebar / Toolbar (44px Golden Gate)
                    Item {
                        id: titleBar
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.preferredHeight: root.showTrafficLights ? CachyTheme.titleBarHeight : 0
                        visible: root.showTrafficLights
                        z: 10

                        // Titlebar Drag Handler (moves the frameless window)
                        DragHandler {
                            id: windowDrag
                            target: null
                            cursorShape: Qt.ClosedHandCursor
                            onActiveChanged: {
                                if (active) {
                                    root.startSystemMove();
                                }
                            }
                        }

                        // Double tap on titlebar to maximize / restore
                        TapHandler {
                            enabled: root.maximizable
                            onDoubleTapped: {
                                if (root.visibility === Window.Maximized) {
                                    root.showNormal();
                                } else {
                                    root.showMaximized();
                                }
                            }
                        }

                        // Leading: Traffic Lights (if no sidebar) + Optional Leading Area (e.g. chevrons < >)
                        Row {
                            id: leadingRow
                            objectName: "cachyHeaderLeading"
                            anchors.left: parent.left
                            anchors.leftMargin: root.hasSidebar ? 14 : root.contentMargin
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            spacing: 12

                            CachyTrafficLights {
                                id: trafficLights
                                visible: !root.hasSidebar
                                anchors.verticalCenter: parent.verticalCenter
                                window: root
                                closable: root.closable
                                minimizable: root.minimizable
                                maximizable: root.maximizable
                            }

                            Item {
                                id: headerLeadingArea
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                width: childrenRect.width
                            }
                        }

                        // Center: Window Title or Custom Center Item (e.g. Siri Orb Pill, File Name)
                        Item {
                            id: headerCenterContainer
                            objectName: "cachyHeaderCenter"
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter

                            // The title band is exactly the free space left between the leading
                            // and the trailing clusters. Sizing the container to that band (instead
                            // of approximating it from the cluster widths) guarantees that the
                            // title can NEVER overlap the header actions, whatever the window
                            // width is: the title elides inside the band instead of overflowing.
                            readonly property real bandLeft: leadingRow.x + leadingRow.width
                            readonly property real bandRight: headerTrailingArea.x
                            readonly property real bandWidth: Math.max(0, bandRight - bandLeft)

                            x: bandLeft
                            width: bandWidth

                            Item {
                                id: headerCenterArea
                                objectName: "cachyHeaderCenterArea"
                                anchors.fill: parent
                            }

                            Text {
                                id: titleLabel
                                objectName: "cachyHeaderTitle"
                                anchors.centerIn: parent
                                text: root.title
                                color: CachyTheme.textPrimary
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                elide: Text.ElideMiddle
                                visible: headerCenterArea.children.length === 0
                                width: Math.min(implicitWidth, parent.width)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Trailing: Header Actions (Flush at 18px from right edge)
                        Item {
                            id: headerTrailingArea
                            objectName: "cachyHeaderTrailing"
                            anchors.right: parent.right
                            anchors.rightMargin: root.contentMargin
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            width: childrenRect.width
                        }

                        // Golden Gate "Hard-Style" Titlebar Bottom Divider (1px visible border)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            visible: root.showTitleBarDivider
                            color: CachyTheme.hardDividerColor
                        }
                    }

                    // 4. Client Content Area
                    Item {
                        id: contentArea
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true
                        Layout.leftMargin: root.contentPadded ? root.contentMargin : 0
                        Layout.rightMargin: root.contentPadded ? root.contentMargin : 0
                        Layout.bottomMargin: root.contentPadded ? root.contentMargin : 0
                        Layout.topMargin: (root.contentPadded && !root.showTrafficLights) ? root.contentMargin : 0

                        Item {
                            id: contentHost
                            anchors.fill: parent
                        }
                    }
                }
            }
        }

        // =====================================================================
        // Window Overlay Host (Full-window modals, Siri halo shader, etc.)
        // =====================================================================
        Item {
            id: overlayContainer
            anchors.fill: parent
            z: 999990
        }

        // =====================================================================
        // 5. Continuous Specular Rim (1px perimeter squircle overlay)
        // =====================================================================
        Rectangle {
            id: specularRim
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            border.width: 1
            border.color: CachyTheme.specularBorder
            visible: root.showWindowFrame
            z: 999998
        }

        // =====================================================================
        // 6. Universal Edge & Corner Resize Handlers for Wayland
        // =====================================================================
        Item {
            id: resizeLayer
            anchors.fill: parent
            z: 999999
            visible: root.resizable && root.visibility !== Window.Maximized && root.visibility !== Window.FullScreen

            Repeater {
                // [edges, x and y fractions, full width, full height]
                model: [
                    [Qt.LeftEdge, 0, 0, 0, 1], [Qt.RightEdge, 1, 0, 0, 1], [Qt.TopEdge, 0, 0, 1, 0], [Qt.BottomEdge, 0, 1, 1, 0],
                    [Qt.LeftEdge | Qt.TopEdge, 0, 0, 0, 0], [Qt.RightEdge | Qt.TopEdge, 1, 0, 0, 0],
                    [Qt.LeftEdge | Qt.BottomEdge, 0, 1, 0, 0], [Qt.RightEdge | Qt.BottomEdge, 1, 1, 0, 0]
                ]

                Item {
                    required property var modelData
                    readonly property int edges: modelData[0]
                    readonly property int size: (modelData[3] || modelData[4] ? 1 : 2) * 8

                    x: modelData[1] * (parent.width - size)
                    y: modelData[2] * (parent.height - size)
                    width: modelData[3] ? parent.width : size
                    height: modelData[4] ? parent.height : size

                    HoverHandler {
                        cursorShape: {
                            const e = parent.edges;
                            if (e === (Qt.LeftEdge | Qt.TopEdge) || e === (Qt.RightEdge | Qt.BottomEdge)) return Qt.SizeFDiagCursor;
                            if (e === (Qt.RightEdge | Qt.TopEdge) || e === (Qt.LeftEdge | Qt.BottomEdge)) return Qt.SizeBDiagCursor;
                            return e & (Qt.LeftEdge | Qt.RightEdge) ? Qt.SizeHorCursor : Qt.SizeVerCursor;
                        }
                    }

                    DragHandler {
                        target: null
                        onActiveChanged: if (active) root.startSystemResize(parent.edges)
                    }
                }
            }
        }
    }
}
