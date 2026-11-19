/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Hierarchical Tree View of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * High-performance virtualized tree view based on QtQuick.TreeView with macOS-style
 * chevron disclosure carets, depth indentation guides, and keyboard navigation.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property alias model: treeView.model
    property alias treeViewItem: treeView
    property int rowHeight: 32
    property int indentSize: 18
    property int selectedRow: -1
    property bool alternateBackgrounds: false

    // ── Public Signals ─────────────────────────────────────────────────────
    signal itemClicked(int row, var modelIndex)
    signal itemDoubleClicked(int row, var modelIndex)
    signal contextMenuRequested(int row, real x, real y)

    // ── Forward Methods ────────────────────────────────────────────────────
    function expand(row: int) {
        treeView.expand(row);
    }

    function collapse(row: int) {
        treeView.collapse(row);
    }

    function toggleExpanded(row: int) {
        treeView.toggleExpanded(row);
    }

    function isExpanded(row: int): bool {
        return treeView.isExpanded(row);
    }

    clip: true

    TreeView {
        id: treeView
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        delegate: Item {
            id: treeDelegate
            required property int row
            required property int column
            required property int depth
            required property bool hasChildren
            required property bool isExpanded
            required property var current
            required property var model

            implicitWidth: treeView.width
            implicitHeight: root.rowHeight

            readonly property bool isSelected: root.selectedRow === row
            readonly property string itemText: {
                if (model && model.display !== undefined) return String(model.display);
                if (model && model.name !== undefined) return String(model.name);
                if (model && model.title !== undefined) return String(model.title);
                return "";
            }
            readonly property string itemIcon: {
                if (model && model.iconName !== undefined) return String(model.iconName);
                if (model && model.icon !== undefined) return String(model.icon);
                return hasChildren ? (isExpanded ? "folder-open" : "folder") : "file";
            }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                radius: CachyTheme.radiusSmall

                color: {
                    if (treeDelegate.isSelected) {
                        return CachyTheme.withAlpha(CachyTheme.accentColor, CachyPalette.isDark ? 0.24 : 0.16);
                    }
                    if (rowMouseArea.containsMouse) {
                        return CachyPalette.cardBackgroundHover;
                    }
                    if (root.alternateBackgrounds && (treeDelegate.row % 2 === 1)) {
                        return CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(0, 0, 0, 0.02);
                    }
                    return "transparent";
                }

                border.width: treeDelegate.isSelected ? 1 : 0
                border.color: CachyTheme.withAlpha(CachyTheme.accentColor, 0.45)

                Behavior on color {
                    ColorAnimation { duration: CachyTheme.animFast }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: (treeDelegate.depth * root.indentSize) + 6
                    anchors.rightMargin: 8
                    spacing: 6

                    // Disclosure Caret
                    Item {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        visible: treeDelegate.hasChildren

                        CachyIcon {
                            anchors.centerIn: parent
                            size: 12
                            name: "chevron-right"
                            color: treeDelegate.isSelected ? CachyTheme.accentColor : CachyPalette.textSecondary
                            rotation: treeDelegate.isExpanded ? 90 : 0

                            Behavior on rotation {
                                NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                mouse.accepted = true;
                                treeView.toggleExpanded(treeDelegate.row);
                            }
                        }
                    }

                    // Spacer if leaf item
                    Item {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        visible: !treeDelegate.hasChildren
                    }

                    // Node Icon
                    CachyIcon {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        size: 16
                        name: treeDelegate.itemIcon
                        color: treeDelegate.isSelected ? CachyTheme.accentColor : CachyPalette.text
                        visible: name.length > 0 && valid
                    }

                    // Label
                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: treeDelegate.itemText
                        font.pixelSize: 12
                        font.weight: treeDelegate.isSelected ? Font.Medium : Font.Normal
                        color: treeDelegate.isSelected ? CachyPalette.text : CachyPalette.textSecondary
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            root.contextMenuRequested(treeDelegate.row, mouse.x, mouse.y);
                        } else {
                            root.selectedRow = treeDelegate.row;
                            root.itemClicked(treeDelegate.row, treeDelegate.current);
                        }
                    }

                    onDoubleClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (treeDelegate.hasChildren) {
                                treeView.toggleExpanded(treeDelegate.row);
                            }
                            root.itemDoubleClicked(treeDelegate.row, treeDelegate.current);
                        }
                    }
                }
            }
        }
    }
}
