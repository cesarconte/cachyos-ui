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

    title: "Ajustes del Sistema - CachyOS UI"
    width: 820
    height: 560
    showTrafficLights: false // Implementamos los botones en la barra lateral integrada

    property int activeNavIndex: 0

    contentData: [
        RowLayout {
            anchors.fill: parent
            spacing: 0

            // =========================================================
            // 1. SIDEBAR TRANSLÚCIDA (macOS Vibrancy / Liquid Glass)
            // =========================================================
            Rectangle {
                id: sidebar
                Layout.preferredWidth: 230
                Layout.fillHeight: true
                color: CachyTheme.isDark ? Qt.rgba(0.14, 0.14, 0.16, 0.65) : Qt.rgba(0.92, 0.92, 0.94, 0.75)
                border.width: 0

                // Línea divisoria vertical sutil de 1px a la derecha
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // Botones de semáforo macOS integrados en la barra lateral
                    Row {
                        id: trafficLights
                        spacing: 8
                        Layout.topMargin: 4
                        Layout.bottomMargin: 8

                        property bool hovered: lightsHover.hovered
                        HoverHandler { id: lightsHover }

                        // Cerrar
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 6.5
                            color: trafficLights.hovered ? "#FF5F56" : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20))
                            border.width: 0.5
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 8
                                font.bold: true
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: trafficLights.hovered
                            }
                            TapHandler { onTapped: root.close() }
                        }

                        // Minimizar
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 6.5
                            color: trafficLights.hovered ? "#FFBD2E" : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20))
                            border.width: 0.5
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -1
                                text: "–"
                                font.pixelSize: 10
                                font.bold: true
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: trafficLights.hovered
                            }
                            TapHandler { onTapped: root.showMinimized() }
                        }

                        // Maximizar / Zoom
                        Rectangle {
                            width: 13
                            height: 13
                            radius: 6.5
                            color: trafficLights.hovered ? "#27C93F" : (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.20))
                            border.width: 0.5
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 10
                                font.bold: true
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: trafficLights.hovered
                            }
                            TapHandler {
                                onTapped: {
                                    if (root.visibility === Window.Maximized) root.showNormal();
                                    else root.showMaximized();
                                }
                            }
                        }
                    }

                    // Lista de secciones estilo macOS
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: [
                                { label: "Aspecto & Vidrio", icon: "🎨" },
                                { label: "Sonido (PipeWire)", icon: "🔊" },
                                { label: "Rendimiento CachyOS", icon: "⚡" },
                                { label: "Pantallas & Wayland", icon: "🖥️" },
                                { label: "Privacidad & Seguridad", icon: "🔒" }
                            ]

                            Rectangle {
                                id: navItem
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 8

                                required property var modelData
                                required property int index

                                readonly property bool isSelected: root.activeNavIndex === index
                                readonly property bool isHovered: navHover.hovered

                                color: isSelected
                                    ? CachyTheme.accentColor
                                    : (isHovered ? (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)) : "transparent")

                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Text {
                                        text: navItem.modelData.icon
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        text: navItem.modelData.label
                                        font.pixelSize: 13
                                        font.weight: navItem.isSelected ? Font.DemiBold : Font.Normal
                                        color: navItem.isSelected ? "#FFFFFF" : CachyTheme.textPrimary
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                HoverHandler { id: navHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.activeNavIndex = navItem.index }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Perfil de usuario inferior estilo macOS
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
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: CachyTheme.textPrimary
                            }
                            Text {
                                text: "CachyOS BORE Linux"
                                font.pixelSize: 10
                                color: CachyTheme.textSecondary
                            }
                        }
                    }
                }
            }

            // =========================================================
            // 2. MAIN CONTENT AREA (macOS Content Surface)
            // =========================================================
            Rectangle {
                id: mainContent
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: CachyTheme.isDark ? Qt.rgba(0.11, 0.11, 0.13, 0.94) : Qt.rgba(0.97, 0.97, 0.98, 0.96)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    // Cabecera de contenido
                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "Aspecto & Vidrio Líquido"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }

                            Text {
                                text: "Diseño nativo pixel-perfect sobre KWin 6.8 Wayland y Qt 6.12"
                                font.pixelSize: 12
                                color: CachyTheme.textSecondary
                            }
                        }

                        CachySwitch {
                            checked: true
                        }
                    }

                    // Selector Segmentado macOS
                    CachySegmentedControl {
                        Layout.fillWidth: true
                        model: ["Automático", "Modo Claro", "Modo Oscuro", "Liquid Glass"]
                        currentIndex: 3
                    }

                    // Tarjeta 1: Sliders de Vidrio y Audio
                    CachyCard {
                        Layout.fillWidth: true

                        content: [
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 14

                                Text {
                                    text: "Parámetros de Refracción & Vidrio"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: CachyTheme.textPrimary
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Displacement (Refracción)"
                                        Layout.preferredWidth: 160
                                        font.pixelSize: 12
                                        color: CachyTheme.textSecondary
                                    }

                                    CachySlider {
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 100
                                        value: 65
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    Text {
                                        text: "Saturación de Fondo (120%)"
                                        Layout.preferredWidth: 160
                                        font.pixelSize: 12
                                        color: CachyTheme.textSecondary
                                    }

                                    CachySlider {
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 100
                                        value: 85
                                    }
                                }
                            }
                        ]
                    }

                    // Tarjeta 2: Botones de Acción
                    CachyCard {
                        Layout.fillWidth: true

                        content: [
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 14

                                Text {
                                    text: "Controles y Acciones del Sistema"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: CachyTheme.textPrimary
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    CachyButton {
                                        text: "Guardar Ajustes"
                                        primary: true
                                    }

                                    CachyButton {
                                        text: "Restablecer"
                                    }

                                    CachyButton {
                                        text: "Ayuda"
                                        flat: true
                                    }

                                    Item { Layout.fillWidth: true }

                                    CachyButton {
                                        text: "Descartar"
                                        destructive: true
                                    }
                                }
                            }
                        ]
                    }

                    Item { Layout.fillHeight: true }

                    // Barra inferior de estado
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "KWin Wayland Blur: Activo • C++23 • Cero WebViews • Latencia < 1ms"
                            font.pixelSize: 11
                            color: CachyTheme.textMuted
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "cachyos-ui v0.1.0"
                            font.pixelSize: 11
                            color: CachyTheme.textMuted
                        }
                    }
                }
            }
        }
    ]
}
