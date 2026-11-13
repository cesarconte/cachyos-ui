/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    id: root

    title: "Liquid Glass — Ajustes del Sistema"
    width: CachyTheme.windowWidthSettings
    height: CachyTheme.windowHeightSettings
    sidebarWidth: 235

    property int activeNavIndex: 0

    // Golden Gate "< | >" Navigation Pill in Toolbar Leading Area
    headerLeading: [
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 58
            height: 28
            radius: 14
            color: CachyTheme.surfacePill
            border.width: 1
            border.color: CachyTheme.specularBorder

            Row {
                anchors.centerIn: parent
                spacing: 8

                CachyIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "chevron-left"
                    size: 14
                    color: CachyTheme.textPrimary
                }
                Rectangle {
                    width: 1
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: CachyTheme.dividerColor
                }
                CachyIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "chevron-right"
                    size: 14
                    color: CachyTheme.textMuted
                }
            }
        }
    ]

    // 1. Golden Gate Edge-to-Edge Sidebar with Colorful Squircle Badges & Bold Selection
    sidebar: [
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 14
            spacing: 10

            CachyTextField {
                Layout.fillWidth: true
                isSearch: true
                placeholderText: "Search"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Repeater {
                    model: [
                        { label: "Appearance & Glass", icon: "appearance", color: "#1C1C1E" },
                        { label: "Desktop & Dock", icon: "desktop", color: "#007AFF" },
                        { label: "Displays", icon: "display", color: "#0A84FF" },
                        { label: "Kity & Intelligence", icon: "sparkles", color: "#AF52DE" },
                        { label: "Búsqueda", icon: "search", color: "#8E8E93" },
                        { label: "Notifications", icon: "bell", color: "#FF3B30" },
                        { label: "Sound (PipeWire)", icon: "volume", color: "#FF2D55" },
                        { label: "Focus", icon: "moon", color: "#5856D6" }
                    ]

                    CachySidebarItem {
                        required property var modelData
                        required property int index

                        text: modelData.label
                        iconName: modelData.icon
                        iconColor: modelData.color
                        squircleIconBadge: true
                        selected: root.activeNavIndex === index
                        selectedHighlightColor: index === 3 ? "#9B4DCA" : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.09))
                        onClicked: root.activeNavIndex = index
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: CachyTheme.accentColor

                    Text {
                        anchors.centerIn: parent
                        text: "C"
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 14
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true

                    Text {
                        text: "Cesar"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: CachyTheme.textPrimary
                    }
                    Text {
                        text: "CachyOS UI"
                        font.pixelSize: 11
                        color: CachyTheme.textSecondary
                    }
                }
            }
        }
    ]

    // 2. Main Content Area (Transparent over Golden Gate Liquid Glass)
    contentData: [
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: CachyTheme.marginWindow
            spacing: 16

            // Golden Gate "Choose your glass" Card (from Ars Technica Review)
            CachyCard {
                Layout.fillWidth: true

                contentItem: ColumnLayout {
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Liquid Glass"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            Text {
                                text: "Slide from clear to tinted to reveal content beneath or add more opacity."
                                font.pixelSize: 12
                                color: CachyTheme.textSecondary
                            }
                        }

                        Text {
                            text: CachyTheme.glassOpacity < 0.25
                                ? "Glassiest"
                                : (CachyTheme.glassOpacity > 0.75 ? "Maximum Tint" : "Medium Glassy (Default)")
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: CachyTheme.accentColor
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: "transparent"
                            border.width: 1.5
                            border.color: CachyTheme.textSecondary
                        }

                        CachySlider {
                            id: glassOpacitySlider
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: Math.round(CachyTheme.glassOpacity * 100)
                            onValueChanged: {
                                CachyTheme.glassOpacity = value / 100.0;
                            }
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: CachyTheme.textSecondary
                            border.width: 1.5
                            border.color: CachyTheme.textSecondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CachyButton {
                            text: "Glassiest (0%)"
                            flat: true
                            onClicked: glassOpacitySlider.value = 0
                        }
                        CachyButton {
                            text: "Medium Glassy (50%)"
                            flat: true
                            onClicked: glassOpacitySlider.value = 50
                        }
                        CachyButton {
                            text: "Maximum Tint (100%)"
                            flat: true
                            onClicked: glassOpacitySlider.value = 100
                        }
                    }
                }
            }

            // Segmented Control
            CachySegmentedControl {
                Layout.fillWidth: true
                model: ["Auto", "Light", "Dark", "Golden Gate Glass"]
                currentIndex: 3
            }

            // Inputs & Progress Bar Card
            CachyCard {
                Layout.fillWidth: true

                contentItem: ColumnLayout {
                    spacing: 14

                    Text {
                        text: "Controles Interactivos Golden Gate"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: CachyTheme.textPrimary
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        CachyTextField {
                            Layout.fillWidth: true
                            placeholderText: "Search or Ask..."
                            text: "CachyOS Liquid Glass"
                            showClearButton: true
                        }

                        CachyButton {
                            text: "Apply"
                            primary: true
                        }
                    }

                    CachyDivider {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        Text {
                            text: "AFM 3 Core Model Status:"
                            font.pixelSize: 12
                            color: CachyTheme.textSecondary
                        }

                        CachyProgressBar {
                            Layout.fillWidth: true
                            value: 0.82
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    ]
}
