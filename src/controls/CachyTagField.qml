/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Universal Tag/Chip Field of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Displays removable tag chips with an inline text input that accepts new tags
 * upon pressing Enter, comma, or space.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property var tags: []
    property string placeholderText: CachyI18n.i18n("Añadir etiqueta...")
    property alias inputText: input.text
    property bool readOnly: false
    property color tagColor: CachyTheme.accentColor

    // ── Public Signals ─────────────────────────────────────────────────────
    signal tagAdded(string tag)
    signal tagRemoved(int index)

    function addTag(tagText: string) {
        var clean = tagText.trim();
        if (clean.length === 0) return;
        var current = Array.from(root.tags);
        if (current.indexOf(clean) === -1) {
            current.push(clean);
            root.tags = current;
            root.tagAdded(clean);
        }
        input.text = "";
    }

    function removeTag(idx: int) {
        var current = Array.from(root.tags);
        if (idx >= 0 && idx < current.length) {
            current.splice(idx, 1);
            root.tags = current;
            root.tagRemoved(idx);
        }
    }

    implicitWidth: 320
    implicitHeight: Math.max(36, flowLayout.implicitHeight + 12)
    radius: CachyTheme.radiusSmall
    color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(1, 1, 1, 0.60)
    border.width: 1
    border.color: input.activeFocus ? CachyTheme.accentColor : CachyPalette.specularBorder

    Behavior on border.color {
        ColorAnimation { duration: CachyTheme.animFast }
    }

    Flow {
        id: flowLayout
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        Repeater {
            model: root.tags

            Item {
                id: tagChip
                required property var modelData
                required property int index

                width: chipBg.width
                height: chipBg.height

                Rectangle {
                    id: chipBg
                    width: chipRow.implicitWidth + 16
                    height: 24
                    radius: 12
                    color: CachyTheme.withAlpha(root.tagColor, CachyPalette.isDark ? 0.22 : 0.14)
                    border.width: 1
                    border.color: CachyTheme.withAlpha(root.tagColor, 0.40)

                    RowLayout {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: String(tagChip.modelData)
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: CachyPalette.text
                        }

                        Item {
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            visible: !root.readOnly

                            CachyIcon {
                                anchors.centerIn: parent
                                size: 10
                                name: "close"
                                color: closeHover.containsMouse ? CachyTheme.accentColor : CachyPalette.textSecondary
                            }

                            MouseArea {
                                id: closeHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.removeTag(tagChip.index)
                            }
                        }
                    }
                }
            }
        }

        // Inline Input
        TextInput {
            id: input
            width: Math.max(placeholderItem.implicitWidth + 12, 100)
            height: 24
            verticalAlignment: TextInput.AlignVCenter
            font.pixelSize: 12
            color: CachyPalette.text
            visible: !root.readOnly

            Text {
                id: placeholderItem
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.placeholderText
                font.pixelSize: 12
                color: CachyPalette.textMuted
                visible: !input.text.length && !input.activeFocus
            }

            onAccepted: root.addTag(input.text)

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Comma || event.key === Qt.Key_Space) {
                    event.accepted = true;
                    root.addTag(input.text);
                } else if (event.key === Qt.Key_Backspace && input.text.length === 0 && root.tags.length > 0) {
                    event.accepted = true;
                    root.removeTag(root.tags.length - 1);
                }
            }
        }
    }
}
