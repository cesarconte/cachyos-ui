/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Precision Time Picker of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Clean digital glass steppers for hours and minutes with mouse wheel, chevron step,
 * AM/PM segmented toggle, and keyboard accessibility.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property int hour: 12
    property int minute: 0
    property bool is24Hour: true
    property string amPm: "AM"

    // ── Public Signals ─────────────────────────────────────────────────────
    signal timeSelected(int hour, int minute)

    implicitWidth: root.is24Hour ? 190 : 260
    implicitHeight: 90

    function pad2(n: int): string {
        return (n < 10 ? "0" : "") + String(n);
    }

    function stepHour(delta: int) {
        var maxH = root.is24Hour ? 24 : 12;
        var minH = root.is24Hour ? 0 : 1;
        var h = root.hour + delta;
        if (h >= maxH) h = minH;
        else if (h < minH) h = maxH - 1;
        root.hour = h;
        root.timeSelected(root.hour, root.minute);
    }

    function stepMinute(delta: int) {
        var m = root.minute + delta;
        if (m >= 60) m = 0;
        else if (m < 0) m = 59;
        root.minute = m;
        root.timeSelected(root.hour, root.minute);
    }

    Rectangle {
        anchors.fill: parent
        radius: CachyTheme.radiusMedium
        color: CachyPalette.cardBackground
        border.width: 1
        border.color: CachyPalette.specularBorder

        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            // ── Hour Stepper Card ──────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 70
                radius: CachyTheme.radiusSmall
                color: hourHover.containsMouse ? CachyPalette.cardBackgroundHover : Qt.rgba(0, 0, 0, 0.12)
                border.width: 1
                border.color: CachyPalette.specularBorder

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        CachyIcon {
                            anchors.centerIn: parent
                            size: 14
                            name: "chevron-up"
                            color: hourUpHover.containsMouse ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }

                        MouseArea {
                            id: hourUpHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stepHour(1)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.pad2(root.hour)
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: CachyPalette.text
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        CachyIcon {
                            anchors.centerIn: parent
                            size: 14
                            name: "chevron-down"
                            color: hourDownHover.containsMouse ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }

                        MouseArea {
                            id: hourDownHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stepHour(-1)
                        }
                    }
                }

                MouseArea {
                    id: hourHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onWheel: (wheel) => {
                        root.stepHour(wheel.angleDelta.y > 0 ? 1 : -1);
                    }
                }
            }

            // ── Colon Separator ────────────────────────────────────────────
            Text {
                text: ":"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: CachyPalette.textMuted
            }

            // ── Minute Stepper Card ────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 70
                radius: CachyTheme.radiusSmall
                color: minuteHover.containsMouse ? CachyPalette.cardBackgroundHover : Qt.rgba(0, 0, 0, 0.12)
                border.width: 1
                border.color: CachyPalette.specularBorder

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        CachyIcon {
                            anchors.centerIn: parent
                            size: 14
                            name: "chevron-up"
                            color: minuteUpHover.containsMouse ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }

                        MouseArea {
                            id: minuteUpHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stepMinute(1)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.pad2(root.minute)
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: CachyPalette.text
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        CachyIcon {
                            anchors.centerIn: parent
                            size: 14
                            name: "chevron-down"
                            color: minuteDownHover.containsMouse ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }

                        MouseArea {
                            id: minuteDownHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stepMinute(-1)
                        }
                    }
                }

                MouseArea {
                    id: minuteHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onWheel: (wheel) => {
                        root.stepMinute(wheel.angleDelta.y > 0 ? 1 : -1);
                    }
                }
            }

            // ── AM / PM Toggle (if !is24Hour) ──────────────────────────────
            CachySegmentedControl {
                visible: !root.is24Hour
                Layout.preferredWidth: 64
                model: ["AM", "PM"]
                currentIndex: root.amPm === "AM" ? 0 : 1
                onCurrentIndexChanged: {
                    root.amPm = currentIndex === 0 ? "AM" : "PM";
                    root.timeSelected(root.hour, root.minute);
                }
            }
        }
    }
}
