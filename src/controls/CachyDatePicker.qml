/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Month Calendar Date Picker of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Compact, accessible, macOS-style calendar grid with smooth date selection,
 * today marker, month traversal, and keyboard/mouse interaction.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property date selectedDate: new Date()
    property date displayedDate: new Date(selectedDate)
    property bool showTodayButton: true

    // ── Public Signals ─────────────────────────────────────────────────────
    signal dateSelected(date selected)

    implicitWidth: 320
    implicitHeight: 320

    readonly property var monthNames: [
        CachyI18n.i18n("Enero"), CachyI18n.i18n("Febrero"), CachyI18n.i18n("Marzo"),
        CachyI18n.i18n("Abril"), CachyI18n.i18n("Mayo"), CachyI18n.i18n("Junio"),
        CachyI18n.i18n("Julio"), CachyI18n.i18n("Agosto"), CachyI18n.i18n("Septiembre"),
        CachyI18n.i18n("Octubre"), CachyI18n.i18n("Noviembre"), CachyI18n.i18n("Diciembre")
    ]

    readonly property var dayLabels: [
        CachyI18n.i18n("Lu"), CachyI18n.i18n("Ma"), CachyI18n.i18n("Mi"),
        CachyI18n.i18n("Ju"), CachyI18n.i18n("Vi"), CachyI18n.i18n("Sá"), CachyI18n.i18n("Do")
    ]

    function setMonth(delta: int) {
        var d = new Date(root.displayedDate);
        d.setMonth(d.getMonth() + delta);
        root.displayedDate = d;
    }

    function goToToday() {
        var now = new Date();
        root.displayedDate = new Date(now);
        root.selectedDate = new Date(now);
        root.dateSelected(root.selectedDate);
    }

    function isSameDay(d1: date, d2: date): bool {
        return d1.getFullYear() === d2.getFullYear() &&
               d1.getMonth() === d2.getMonth() &&
               d1.getDate() === d2.getDate();
    }

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusMedium
        color: CachyPalette.cardBackground
        border.width: 1
        border.color: CachyPalette.specularBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // ── Header: Month / Year + Navigation ──────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.monthNames[root.displayedDate.getMonth()] + " " + root.displayedDate.getFullYear()
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: CachyPalette.text
                    elide: Text.ElideRight
                }

                CachyButton {
                    text: CachyI18n.i18n("Hoy")
                    visible: root.showTodayButton
                    Layout.preferredHeight: 26
                    onClicked: root.goToToday()
                }

                CachyToolbarButton {
                    iconName: "chevron-left"
                    tooltipText: CachyI18n.i18n("Mes anterior")
                    onClicked: root.setMonth(-1)
                }

                CachyToolbarButton {
                    iconName: "chevron-right"
                    tooltipText: CachyI18n.i18n("Mes siguiente")
                    onClicked: root.setMonth(1)
                }
            }

            // ── Day of Week Headers ────────────────────────────────────────
            Row {
                Layout.fillWidth: true
                spacing: (root.width - 24 - (7 * 32)) / 6

                Repeater {
                    model: root.dayLabels

                    Item {
                        required property string modelData
                        width: 32
                        height: 20

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: CachyPalette.textMuted
                        }
                    }
                }
            }

            // ── Days Grid (6 weeks x 7 days = 42 cells) ────────────────────
            GridLayout {
                id: daysGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 4
                columnSpacing: (root.width - 24 - (7 * 32)) / 6

                Repeater {
                    model: 42

                    Item {
                        id: cellItem
                        required property int index

                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32

                        readonly property date cellDate: {
                            var year = root.displayedDate.getFullYear();
                            var month = root.displayedDate.getMonth();
                            var firstDay = new Date(year, month, 1);
                            // Monday is 1 in JS, Sunday is 0 -> adjust Monday=0..Sunday=6
                            var dayOfWeek = (firstDay.getDay() + 6) % 7;
                            var startOffset = 1 - dayOfWeek;
                            return new Date(year, month, startOffset + cellItem.index);
                        }

                        readonly property bool isCurrentMonth: cellDate.getMonth() === root.displayedDate.getMonth()
                        readonly property bool isSelected: root.isSameDay(cellDate, root.selectedDate)
                        readonly property bool isToday: root.isSameDay(cellDate, new Date())

                        Rectangle {
                            anchors.fill: parent
                            radius: 16

                            color: {
                                if (cellItem.isSelected) return CachyTheme.accentColor;
                                if (cellHover.containsMouse) return CachyPalette.cardBackgroundHover;
                                return "transparent";
                            }

                            border.width: (cellItem.isToday && !cellItem.isSelected) ? 1 : 0
                            border.color: CachyTheme.accentColor

                            Behavior on color {
                                ColorAnimation { duration: CachyTheme.animFast }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: String(cellItem.cellDate.getDate())
                                font.pixelSize: 12
                                font.weight: cellItem.isSelected ? Font.Bold : (cellItem.isToday ? Font.DemiBold : Font.Normal)
                                color: {
                                    if (cellItem.isSelected) return "#FFFFFF";
                                    if (!cellItem.isCurrentMonth) return CachyPalette.textMuted;
                                    return CachyPalette.text;
                                }
                            }
                        }

                        MouseArea {
                            id: cellHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedDate = new Date(cellItem.cellDate);
                                root.dateSelected(root.selectedDate);
                            }
                        }
                    }
                }
            }
        }
    }
}
