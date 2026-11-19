/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

CachyToolbarButton {
    id: root

    property Window targetWindow: Window.window
    readonly property bool isCollapsed: Boolean(root.targetWindow && root.targetWindow.sidebarCollapsed)

    iconName: root.isCollapsed ? "sidebar-expand-symbolic" : "sidebar-collapse-symbolic"
    tooltipText: root.isCollapsed ? CachyI18n.i18n("Expand Sidebar") : CachyI18n.i18n("Collapse Sidebar")
    visible: Boolean(root.targetWindow && root.targetWindow.sidebarCollapsible)

    onClicked: {
        if (root.targetWindow && typeof root.targetWindow.toggleSidebarCollapse === "function") {
            root.targetWindow.toggleSidebarCollapse();
        }
    }
}
