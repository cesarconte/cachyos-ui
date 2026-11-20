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
    readonly property bool isCollapsed: Boolean(root.targetWindow && (root.targetWindow.sidebarCollapsed || (root.targetWindow.sidebarVisible !== undefined && !root.targetWindow.sidebarVisible)))

    iconName: root.isCollapsed ? "sidebar-expand-symbolic" : "sidebar-collapse-symbolic"
    tooltipText: root.isCollapsed ? CachyI18n.i18n("Expand Sidebar") : CachyI18n.i18n("Collapse Sidebar")
    visible: Boolean(root.targetWindow && (root.targetWindow.sidebarCollapsible || root.targetWindow.hasSidebar !== undefined))

    onClicked: {
        if (root.targetWindow) {
            if (typeof root.targetWindow.toggleSidebar === "function") {
                root.targetWindow.toggleSidebar();
            } else if (root.targetWindow.sidebarCollapsible && typeof root.targetWindow.toggleSidebarCollapse === "function") {
                root.targetWindow.toggleSidebarCollapse();
            } else if (root.targetWindow.sidebarVisible !== undefined) {
                root.targetWindow.sidebarVisible = !root.targetWindow.sidebarVisible;
            }
        }
    }
}
