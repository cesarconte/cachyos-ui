/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Complete tabbed container combining CachyTabBar and a synchronized view stack
 * (inspired by FishUI TabView.qml).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

ColumnLayout {
    id: root

    property alias tabs: tabBar.tabs
    property alias currentIndex: tabBar.currentIndex
    property alias closable: tabBar.closable
    property alias showAddButton: tabBar.showAddButton
    default property alias contentData: viewsHost.data

    signal tabClicked(int index)
    signal tabCloseRequested(int index)
    signal addTabRequested()

    spacing: CachyTheme.spacingSmall

    function syncViews() {
        for (let i = 0; i < viewsHost.children.length; ++i) {
            const child = viewsHost.children[i];
            child.width = Qt.binding(() => viewsHost.width);
            child.height = Qt.binding(() => viewsHost.height);
            child.visible = (i === root.currentIndex);
        }
    }

    CachyTabBar {
        id: tabBar
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        onTabClicked: (idx) => root.tabClicked(idx)
        onTabCloseRequested: (idx) => root.tabCloseRequested(idx)
        onAddTabRequested: root.addTabRequested()
        onCurrentIndexChanged: root.syncViews()
    }

    Item {
        id: viewsHost
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.fillHeight: true
        onChildrenChanged: root.syncViews()
    }

    Component.onCompleted: root.syncViews()
}
