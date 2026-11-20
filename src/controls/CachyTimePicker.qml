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
        if (root.is24Hour) {
            var h = (root.hour + delta) % 24;
            if (h < 0) h += 24;
            root.hour = h;
        } else {
            var h = root.hour + delta;
            while (h > 12) h -= 12;
            while (h < 1) h += 12;
            root.hour = h;
        }
        root.timeSelected(root.hour, root.minute);
    }

    function stepMinute(delta: int) {
        var m = (root.minute + delta) % 60;
        while (m < 0) m += 60;
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
                id: hourCard
                Layout.preferredWidth: 64
                Layout.preferredHeight: 70
                radius: CachyTheme.radiusSmall
                color: hourMouseArea.containsMouse ? CachyPalette.cardBackgroundHover : Qt.rgba(0, 0, 0, 0.12)
                border.width: 1
                border.color: hourMouseArea.containsMouse ? CachyTheme.accentColor : CachyPalette.specularBorder

                Behavior on color { ColorAnimation { duration: CachyTheme.animFast } }
                Behavior on border.color { ColorAnimation { duration: CachyTheme.animFast } }

                MouseArea {
                    id: hourMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onWheel: (wheel) => {
                        wheel.accepted = true;
                        root.stepHour(wheel.angleDelta.y > 0 ? 1 : -1);
                    }
                    onClicked: (mouse) => {
                        if (mouse.y < height / 2) {
                            root.stepHour(1);
                        } else {
                            root.stepHour(-1);
                        }
                    }
                }

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
                            color: (hourMouseArea.containsMouse && hourMouseArea.mouseY < 24) ? CachyTheme.accentColor : CachyPalette.textSecondary
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
                            color: (hourMouseArea.containsMouse && hourMouseArea.mouseY > 46) ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }
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
                id: minuteCard
                Layout.preferredWidth: 64
                Layout.preferredHeight: 70
                radius: CachyTheme.radiusSmall
                color: minuteMouseArea.containsMouse ? CachyPalette.cardBackgroundHover : Qt.rgba(0, 0, 0, 0.12)
                border.width: 1
                border.color: minuteMouseArea.containsMouse ? CachyTheme.accentColor : CachyPalette.specularBorder

                Behavior on color { ColorAnimation { duration: CachyTheme.animFast } }
                Behavior on border.color { ColorAnimation { duration: CachyTheme.animFast } }

                MouseArea {
                    id: minuteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onWheel: (wheel) => {
                        wheel.accepted = true;
                        var step = (wheel.modifiers & Qt.ShiftModifier) ? 5 : 1;
                        root.stepMinute(wheel.angleDelta.y > 0 ? step : -step);
                    }
                    onClicked: (mouse) => {
                        if (mouse.y < height / 2) {
                            root.stepMinute(1);
                        } else {
                            root.stepMinute(-1);
                        }
                    }
                }

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
                            color: (minuteMouseArea.containsMouse && minuteMouseArea.mouseY < 24) ? CachyTheme.accentColor : CachyPalette.textSecondary
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
                            color: (minuteMouseArea.containsMouse && minuteMouseArea.mouseY > 46) ? CachyTheme.accentColor : CachyPalette.textSecondary
                        }
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
