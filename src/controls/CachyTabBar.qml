/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Document tab bar of the CachyOS.UI design system
 * (inspired by FishUI TabBar.qml & window_tab_bar.cpp).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    /// List of strings or objects `{ title: "...", iconName: "...", closable: true }`.
    property var tabs: []
    property int currentIndex: 0
    property bool closable: true
    property bool showAddButton: true

    signal tabClicked(int index)
    signal tabCloseRequested(int index)
    signal addTabRequested()

    implicitWidth: 420
    implicitHeight: 36
    radius: CachyTheme.radiusSmall
    color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.22) : Qt.rgba(0, 0, 0, 0.05)
    border.width: 1
    border.color: CachyPalette.specularBorder

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: root.tabs

            CachyTabButton {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.minimumWidth: 64
                Layout.maximumWidth: 220
                Layout.fillHeight: true

                readonly property bool isObj: typeof modelData === "object" && modelData !== null
                text: isObj ? String(modelData.title ?? modelData.text ?? "") : String(modelData ?? "")
                iconName: isObj ? String(modelData.iconName ?? modelData.icon ?? "") : ""
                closable: isObj && modelData.closable !== undefined ? Boolean(modelData.closable) : root.closable
                selected: root.currentIndex === index

                onClicked: {
                    root.currentIndex = index;
                    root.tabClicked(index);
                }
                onCloseClicked: root.tabCloseRequested(index)
            }
        }

        Item {
            Layout.fillWidth: root.tabs.length === 0
        }

        Rectangle {
            visible: root.showAddButton
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 6
            color: addHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"

            CachyIcon {
                anchors.centerIn: parent
                name: "add"
                size: 14
                color: CachyPalette.text
            }

            HoverHandler {
                id: addHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.addTabRequested()
            }
        }
    }
}
