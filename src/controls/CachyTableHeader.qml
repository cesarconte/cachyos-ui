/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Sortable table header bar of the CachyOS.UI design system
 * (connects directly to CachySortFilterProxyModel).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    /// List of column descriptors:
    /// `[{ role: "name", title: "Nombre", width: 220, fillWidth: true }, ...]`
    property var columns: []
    property string sortRole: ""
    property int sortOrder: Qt.AscendingOrder

    signal sortRequested(string role, int order)

    implicitWidth: 480
    implicitHeight: 30
    color: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.03)
    radius: CachyTheme.radiusSmall

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        Repeater {
            model: root.columns

            Item {
                id: colItem
                required property var modelData
                required property int index

                readonly property string roleName: String(modelData.role ?? "")
                readonly property string titleText: String(modelData.title ?? modelData.label ?? "")
                readonly property int colWidth: Number(modelData.width ?? 120)
                readonly property bool isFill: Boolean(modelData.fillWidth ?? (index === 0))
                readonly property bool isSorted: root.sortRole.length > 0 && root.sortRole === roleName

                Layout.fillWidth: isFill
                Layout.minimumWidth: isFill ? 60 : colWidth
                Layout.preferredWidth: colWidth
                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    radius: 5
                    color: colHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: colItem.titleText
                        font.pixelSize: 11
                        font.weight: colItem.isSorted ? Font.Bold : Font.DemiBold
                        color: colItem.isSorted ? CachyPalette.accentText : CachyPalette.textSecondary
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    CachyIcon {
                        visible: colItem.isSorted
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        name: root.sortOrder === Qt.AscendingOrder ? "sort-asc" : "sort-desc"
                        size: 12
                        color: CachyTheme.accentColor
                    }
                }

                Rectangle {
                    visible: colItem.index < root.columns.length - 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 14
                    color: CachyPalette.dividerColor
                }

                HoverHandler {
                    id: colHover
                    enabled: colItem.roleName.length > 0
                    cursorShape: colItem.roleName.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                }

                TapHandler {
                    enabled: colItem.roleName.length > 0
                    onTapped: {
                        if (root.sortRole === colItem.roleName) {
                            root.sortOrder = (root.sortOrder === Qt.AscendingOrder)
                                ? Qt.DescendingOrder
                                : Qt.AscendingOrder;
                        } else {
                            root.sortRole = colItem.roleName;
                            root.sortOrder = Qt.AscendingOrder;
                        }
                        root.sortRequested(root.sortRole, root.sortOrder);
                    }
                }
            }
        }
    }

    CachyDivider {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }
}
