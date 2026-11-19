/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Slide-in Off-Canvas Drawer of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Supports Left, Right, and Bottom edges with smooth GPU transitions, scrim dimming,
 * and keyboard dismissal.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    // ── Public Properties ──────────────────────────────────────────────────
    property int edge: Qt.RightEdge // Qt.LeftEdge, Qt.RightEdge, Qt.BottomEdge
    property int drawerSize: 320
    property bool opened: false
    property bool modal: true
    property string title: ""

    default property alias content: drawerContentHost.data

    // ── Public Signals & Methods ───────────────────────────────────────────
    signal closed()

    function open() {
        root.opened = true;
    }

    function close() {
        root.opened = false;
        root.closed();
    }

    function toggle() {
        if (root.opened) root.close();
        else root.open();
    }

    anchors.fill: parent
    visible: root.opened || drawerAnimX.running || drawerAnimY.running
    z: 90

    readonly property real closedX: {
        if (root.edge === Qt.LeftEdge) return -root.drawerSize;
        if (root.edge === Qt.RightEdge) return root.width;
        return 0;
    }

    readonly property real openedX: {
        if (root.edge === Qt.LeftEdge) return 0;
        if (root.edge === Qt.RightEdge) return root.width - root.drawerSize;
        return 0;
    }

    readonly property real closedY: {
        if (root.edge === Qt.BottomEdge) return root.height;
        return 0;
    }

    readonly property real openedY: {
        if (root.edge === Qt.BottomEdge) return root.height - root.drawerSize;
        return 0;
    }

    // Scrim
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.32)
        opacity: root.opened ? 1.0 : 0.0
        visible: root.modal

        Behavior on opacity {
            NumberAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Drawer Surface Card
    Rectangle {
        id: drawerCard
        x: root.opened ? root.openedX : root.closedX
        y: root.opened ? root.openedY : root.closedY

        width: (root.edge === Qt.BottomEdge) ? root.width : root.drawerSize
        height: (root.edge === Qt.BottomEdge) ? root.drawerSize : root.height

        color: CachyPalette.sheetBackground
        border.width: 1
        border.color: CachyPalette.specularBorder

        Behavior on x {
            NumberAnimation { id: drawerAnimX; duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
        }

        Behavior on y {
            NumberAnimation { id: drawerAnimY; duration: CachyTheme.animNormal; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: CachyTheme.marginWindow
            spacing: CachyTheme.spacingMedium

            // Drawer Header
            RowLayout {
                Layout.fillWidth: true
                visible: root.title.length > 0 || closeBtn.visible

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.title
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: CachyPalette.text
                    elide: Text.ElideRight
                }

                CachyToolbarButton {
                    id: closeBtn
                    iconName: "close"
                    tooltipText: CachyI18n.i18n("Cerrar panel")
                    onClicked: root.close()
                }
            }

            // Divider if title is present
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: CachyPalette.hardDividerColor
                visible: root.title.length > 0
            }

            // Content Host
            Item {
                id: drawerContentHost
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Keys.onEscapePressed: root.close()
}
