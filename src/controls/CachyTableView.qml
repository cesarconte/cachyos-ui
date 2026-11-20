/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Sortable, virtualized Data Table of the CachyOS.UI design system.
 * Connects seamlessly with CachyTableHeader and CachySortFilterProxyModel.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as T
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Columns specification:
    /// `[{ role: "name", title: "Nombre", width: 200, fillWidth: true, type: "text" }, ...]`
    /// Supported cell types: "text" (default), "icon", "badge", "progress", "checkbox"
    property var columns: []

    /// Data model (QAbstractItemModel, CachySortFilterProxyModel, or ListModel)
    property alias model: listView.model

    /// Visual customization
    property bool showHeader: true
    property bool framed: true
    property real rowHeight: 34
    property bool alternatingRows: false

    /// Selection
    property int currentIndex: -1
    property var selectedIndices: []
    property bool multiSelect: false

    /// Empty state
    property string emptyText: qsTr("No hay elementos")
    property string emptyIcon: "folder"

    /// Column sorting state
    property string sortRole: ""
    property int sortOrder: Qt.AscendingOrder

    /// Signals
    signal rowClicked(int index, var rowData)
    signal rowDoubleClicked(int index, var rowData)
    signal contextMenuRequested(int index, real mouseX, real mouseY)
    signal sortRequested(string role, int order)

    function getRowData(index) {
        if (!root.model) return {};
        if (typeof root.model.get === "function") {
            return root.model.get(index);
        }
        return {};
    }

    implicitWidth: 540
    implicitHeight: 320

    // Frame styling
    Rectangle {
        id: frameBackground
        anchors.fill: parent
        radius: CachyTheme.radiusSmall
        color: root.framed ? (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(0, 0, 0, 0.02)) : "transparent"
        border.width: root.framed ? 1 : 0
        border.color: CachyPalette.specularBorder
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 1. Table Header
            CachyTableHeader {
                id: tableHeader
                visible: root.showHeader && root.columns.length > 0
                Layout.fillWidth: true
                columns: root.columns
                sortRole: root.sortRole
                sortOrder: root.sortOrder

                onSortRequested: (role, order) => {
                    root.sortRole = role;
                    root.sortOrder = order;
                    root.sortRequested(role, order);

                    // Auto-sync with CachySortFilterProxyModel if present
                    if (root.model) {
                        if (typeof root.model.sortByRole === "function") {
                            root.model.sortByRole(role, order);
                        } else if (typeof root.model.sortRoleName !== "undefined") {
                            root.model.sortRoleName = role;
                            root.model.sortOrder = order;
                        }
                    }
                }
            }

            // 2. Virtualized Rows View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: root.currentIndex

                    T.ScrollBar.vertical: T.ScrollBar {
                        id: verticalScrollBar
                        policy: listView.contentHeight > listView.height ? T.ScrollBar.AsNeeded : T.ScrollBar.AlwaysOff
                        width: 6
                        active: listView.moving || listView.flicking || rowHoverArea.hovered
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: verticalScrollBar.pressed
                                ? CachyTheme.accentColor
                                : (CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(0, 0, 0, 0.24))
                            opacity: verticalScrollBar.active ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                        }
                    }

                    HoverHandler {
                        id: rowHoverArea
                    }

                    delegate: Item {
                        id: rowDelegate
                        required property int index
                        required property var model

                        width: listView.width
                        height: root.rowHeight

                        readonly property bool isSelected: root.currentIndex === index || root.selectedIndices.indexOf(index) !== -1

                        // Row background pill
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: 6

                            color: {
                                if (rowDelegate.isSelected) {
                                    return Qt.rgba(CachyTheme.accentColor.r, CachyTheme.accentColor.g, CachyTheme.accentColor.b, 0.22);
                                }
                                if (rowHover.hovered) {
                                    return CachyPalette.cardBackgroundHover;
                                }
                                if (root.alternatingRows && (rowDelegate.index % 2 === 1)) {
                                    return CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(0, 0, 0, 0.02);
                                }
                                return "transparent";
                            }

                            border.width: rowDelegate.isSelected ? 1 : 0
                            border.color: rowDelegate.isSelected ? Qt.rgba(CachyTheme.accentColor.r, CachyTheme.accentColor.g, CachyTheme.accentColor.b, 0.45) : "transparent"

                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        // Row Columns Content
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 0

                            Repeater {
                                model: root.columns

                                Item {
                                    id: cellItem
                                    required property var modelData
                                    required property int index

                                    readonly property string roleName: String(modelData.role ?? "")
                                    readonly property string cellType: String(modelData.type ?? "text")
                                    readonly property int colWidth: Number(modelData.width ?? 120)
                                    readonly property bool isFill: Boolean(modelData.fillWidth ?? (index === 0))

                                    // Extract data from row model
                                    readonly property var rawValue: {
                                        if (rowDelegate.model && roleName.length > 0) {
                                            if (typeof rowDelegate.model[roleName] !== "undefined") {
                                                return rowDelegate.model[roleName];
                                            }
                                        }
                                        return "";
                                    }

                                    Layout.fillWidth: cellItem.isFill
                                    Layout.minimumWidth: cellItem.isFill ? 60 : cellItem.colWidth
                                    Layout.preferredWidth: cellItem.colWidth
                                    Layout.fillHeight: true

                                    // Cell Type 1: Text (Default)
                                    Text {
                                        visible: cellItem.cellType === "text"
                                        anchors.fill: parent
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 4
                                        text: String(cellItem.rawValue ?? "")
                                        font.pixelSize: 12
                                        color: rowDelegate.isSelected ? CachyPalette.text : CachyPalette.textSecondary
                                        font.weight: rowDelegate.isSelected ? Font.Medium : Font.Normal
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Cell Type 2: Icon + Text
                                    RowLayout {
                                        visible: cellItem.cellType === "icon"
                                        anchors.fill: parent
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 4
                                        spacing: 6

                                        CachyIcon {
                                            size: 16
                                            name: String(cellItem.rawValue ?? "")
                                            color: rowDelegate.isSelected ? CachyTheme.accentColor : CachyPalette.text
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.minimumWidth: 0
                                            text: String(cellItem.rawValue ?? "")
                                            font.pixelSize: 12
                                            color: rowDelegate.isSelected ? CachyPalette.text : CachyPalette.textSecondary
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    // Cell Type 3: Badge / Chip
                                    CachyBadge {
                                        visible: cellItem.cellType === "badge"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 4
                                        text: String(cellItem.rawValue ?? "")
                                        badgeType: {
                                            const v = String(cellItem.rawValue ?? "").toLowerCase();
                                            if (v.includes("ok") || v.includes("complet") || v.includes("activo") || v.includes("éxito")) return "success";
                                            if (v.includes("err") || v.includes("fallo") || v.includes("cancel")) return "error";
                                            if (v.includes("warn") || v.includes("pend") || v.includes("espera")) return "warning";
                                            return "neutral";
                                        }
                                    }

                                    // Cell Type 4: Progress Bar
                                    CachyProgressBar {
                                        visible: cellItem.cellType === "progress"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 8
                                        value: Number(cellItem.rawValue ?? 0)
                                    }

                                    // Cell Type 5: Checkbox
                                    CachyCheckBox {
                                        visible: cellItem.cellType === "checkbox"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 4
                                        checked: Boolean(cellItem.rawValue)
                                    }
                                }
                            }
                        }

                        // Bottom hairline divider between rows
                        Rectangle {
                            visible: !root.alternatingRows && rowDelegate.index < listView.count - 1
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            height: 1
                            color: CachyPalette.isDark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)
                        }

                        HoverHandler {
                            id: rowHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: {
                                root.currentIndex = rowDelegate.index;
                                if (root.multiSelect) {
                                    let copy = [...root.selectedIndices];
                                    const pos = copy.indexOf(rowDelegate.index);
                                    if (pos === -1) {
                                        copy.push(rowDelegate.index);
                                    } else {
                                        copy.splice(pos, 1);
                                    }
                                    root.selectedIndices = copy;
                                }
                                let rData = root.getRowData(rowDelegate.index);
                                if (Object.keys(rData).length === 0 && rowDelegate.model) {
                                    rData = rowDelegate.model;
                                }
                                root.rowClicked(rowDelegate.index, rData);
                            }
                            onDoubleTapped: {
                                let rData = root.getRowData(rowDelegate.index);
                                if (Object.keys(rData).length === 0 && rowDelegate.model) {
                                    rData = rowDelegate.model;
                                }
                                root.rowDoubleClicked(rowDelegate.index, rData);
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.RightButton
                            onTapped: (eventPoint) => {
                                root.currentIndex = rowDelegate.index;
                                root.contextMenuRequested(rowDelegate.index, eventPoint.position.x, eventPoint.position.y);
                            }
                        }
                    }

                    // Empty Placeholder Message
                    CachyPlaceholderMessage {
                        anchors.centerIn: parent
                        visible: listView.count === 0
                        width: Math.min(parent.width - 40, 320)
                        iconName: root.emptyIcon
                        text: root.emptyText
                    }
                }
            }
        }
    }
}
