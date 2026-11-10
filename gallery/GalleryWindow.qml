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

    title: "CachyOS UI Component Gallery"
    width: 620
    height: 600

    contentData: [
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: CachyTheme.spacingLarge
            spacing: CachyTheme.spacingMedium

            // Header info
            RowLayout {
                Layout.fillWidth: true
                spacing: CachyTheme.spacingMedium

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "CachyOS Design System"
                        font.pixelSize: 20
                        font.bold: true
                        color: CachyTheme.textPrimary
                    }

                    Text {
                        text: "Exact macOS Golden Gate aesthetics with CachyOS BORE speed & zero overhead"
                        font.pixelSize: 12
                        color: CachyTheme.textSecondary
                    }
                }

                CachySwitch {
                    id: systemSwitch
                    checked: true
                }
            }

            // Segmented Control
            CachySegmentedControl {
                Layout.fillWidth: true
                model: ["General", "Efectos & Vidrio", "Audio & PipeWire", "Perfiles"]
                currentIndex: 0
            }

            // Card 1: Sliders & Switches
            CachyCard {
                Layout.fillWidth: true

                content: [
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: CachyTheme.spacingMedium

                        Text {
                            text: "Controles Continuos (Liquid Sliders)"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: CachyTheme.textPrimary
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: CachyTheme.spacingMedium

                            Text {
                                text: "Volumen Maestro"
                                Layout.preferredWidth: 140
                                font.pixelSize: 12
                                color: CachyTheme.textSecondary
                            }

                            CachySlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 75
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: CachyTheme.spacingMedium

                            Text {
                                text: "Translucidez de Vidrio"
                                Layout.preferredWidth: 140
                                font.pixelSize: 12
                                color: CachyTheme.textSecondary
                            }

                            CachySlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: 88
                            }
                        }
                    }
                ]
            }

            // Card 2: Interactive Buttons
            CachyCard {
                Layout.fillWidth: true

                content: [
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: CachyTheme.spacingMedium

                        Text {
                            text: "Acciones & Botones Táctiles"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: CachyTheme.textPrimary
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: CachyTheme.spacingSmall

                            CachyButton {
                                text: "Aceptar"
                                primary: true
                            }

                            CachyButton {
                                text: "Secundario"
                            }

                            CachyButton {
                                text: "Cancelar"
                                flat: true
                            }

                            Item { Layout.fillWidth: true }

                            CachyButton {
                                text: "Eliminar"
                                destructive: true
                            }
                        }
                    }
                ]
            }

            Item { Layout.fillHeight: true }

            // Footer Status
            Text {
                text: "KWin 6.8 Wayland Blur Activo • Qt 6.12 • C++23 Nativo"
                font.pixelSize: 11
                color: CachyTheme.textMuted
                Layout.alignment: Qt.AlignHCenter
            }
        }
    ]
}
