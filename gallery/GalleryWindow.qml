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
    width: 860
    height: 580
    showTrafficLights: false // Botones integrados en la barra lateral estilo macOS

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
                // Translucidez real Liquid Glass sobre KWin Wayland Blur
                color: CachyTheme.isDark ? Qt.rgba(0.10, 0.10, 0.12, 0.50) : Qt.rgba(0.95, 0.95, 0.97, 0.65)

                // Borde divisor derecho sutil de 1px
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14

                    // Botones de semáforo vectoriales oficiales macOS Golden Gate
                    CachyTrafficLights {
                        Layout.topMargin: 4
                        Layout.bottomMargin: 6
                        window: root
                    }

                    // Navegación de la barra lateral
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
                                    : (isHovered ? (CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.06)) : "transparent")

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

                    // Perfil de usuario inferior
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            color: CachyTheme.accentColor

                            Text {
                                anchors.centerIn: parent
                                text: "C"
                                color: "#FFFFFF"
                                font.bold: true
                                font.pixelSize: 15
                            }
                        }

                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Text {
                                text: "Cesar"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: CachyTheme.textPrimary
                            }
                            Text {
                                text: "CachyOS BORE Linux"
                                font.pixelSize: 11
                                color: CachyTheme.textSecondary
                            }
                        }
                    }
                }
            }

            // =========================================================
            // 2. MAIN CONTENT AREA (macOS Satin Surface)
            // =========================================================
            Rectangle {
                id: mainContent
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: CachyTheme.isDark ? Qt.rgba(0.12, 0.12, 0.14, 0.94) : Qt.rgba(0.97, 0.97, 0.98, 0.96)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    // Cabecera de contenido
                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

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

                        contentItem: ColumnLayout {
                            spacing: 16

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
                                    Layout.preferredWidth: 170
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
                                    Layout.preferredWidth: 170
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
                    }

                    // Tarjeta 2: Botones de Acción
                    CachyCard {
                        Layout.fillWidth: true

                        contentItem: ColumnLayout {
                            spacing: 16

                            Text {
                                text: "Controles y Acciones del Sistema"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: CachyTheme.textPrimary
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

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
