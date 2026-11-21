/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Liquid Glass context & dropdown menu of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T
import CachyOS.UI

T.Menu {
    id: control

    readonly property Window hostWindow: menuListView.itemWindow

    function ensureInWindowBounds(): void {
        if (!control.opened) {
            return;
        }
        const hostWin = control.hostWindow;
        if (!hostWin || hostWin.width <= 0) {
            return;
        }
        const parentItem = control.parent;
        const winLeftInParent = parentItem ? parentItem.mapFromItem(null, control.margins, 0).x : control.margins;
        const winRightInParent = parentItem ? parentItem.mapFromItem(null, hostWin.width - control.margins, 0).x : (hostWin.width - control.margins);
        const maxX = Math.max(winLeftInParent, winRightInParent - control.width);
        if (control.x > maxX) {
            control.x = maxX;
        } else if (control.x < winLeftInParent) {
            control.x = winLeftInParent;
        }
    }

    implicitWidth: {
        const desired = Math.max(
            180,
            implicitBackgroundWidth + leftInset + rightInset,
            implicitContentWidth + leftPadding + rightPadding,
            contentItem.implicitWidth + leftPadding + rightPadding
        );
        const hostWin = control.hostWindow;
        const maxAllowed = hostWin && hostWin.width > 0
            ? Math.max(180, hostWin.width - (margins * 2) - 12)
            : 480;
        return Math.min(desired, maxAllowed);
    }
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    margins: 6
    padding: 5

    onOpened: {
        control.ensureInWindowBounds();
        Qt.callLater(control.ensureInWindowBounds);
    }
    onWidthChanged: control.ensureInWindowBounds()

    delegate: CachyMenuItem {}

    contentItem: ListView {
        id: menuListView

        readonly property Window itemWindow: Window.window

        implicitWidth: {
            let maxW = 0;
            const visItems = menuListView.contentItem.visibleChildren;
            for (let i = 0; i < visItems.length; ++i) {
                const child = visItems[i];
                if (child && child.visible && child.implicitWidth > maxW) {
                    maxW = child.implicitWidth;
                }
            }
            if (maxW <= 0) {
                const allItems = menuListView.contentItem.children;
                for (let j = 0; j < allItems.length; ++j) {
                    const fallbackChild = allItems[j];
                    if (fallbackChild && fallbackChild.visible && fallbackChild.implicitWidth > maxW) {
                        maxW = fallbackChild.implicitWidth;
                    }
                }
            }
            if (maxW <= 0) {
                for (let k = 0; k < control.count; ++k) {
                    const item = control.itemAt(k);
                    if (item && item.visible && item.implicitWidth > maxW) {
                        maxW = item.implicitWidth;
                    }
                }
            }
            return Math.ceil(maxW);
        }
        implicitHeight: contentHeight
        model: control.contentModel
        interactive: itemWindow ? contentHeight + control.topPadding + control.bottomPadding > itemWindow.height : false
        clip: true
        currentIndex: control.currentIndex
        spacing: 2
    }

    background: Item {
        implicitWidth: 180
        implicitHeight: 36

        Rectangle {
            id: menuBgCard
            anchors.fill: parent
            radius: 14
            color: CachyPalette.sheetBackground
            border.width: 1
            border.color: CachyPalette.specularBorder
            visible: false
        }

        MultiEffect {
            property bool auditBleed: true
            anchors.fill: menuBgCard
            source: menuBgCard
            shadowEnabled: true
            shadowBlur: 0.55
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
            shadowColor: Qt.rgba(0, 0, 0, CachyPalette.isDark ? 0.50 : 0.20)
        }
    }
}
