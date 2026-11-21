/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Floating Liquid Glass popover of the CachyOS.UI design system (macOS 27
 * Golden Gate), with automatic viewport clamping, directional pointer arrow,
 * soft MultiEffect shadow and scrollable body.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import CachyOS.UI

T.Popup {
    id: root

    property Item anchorItem: null
    /// Side relative to `anchorItem` where the popover prefers to open:
    /// Qt.LeftEdge, Qt.RightEdge, Qt.BottomEdge, or Qt.TopEdge.
    property int preferredEdge: Qt.LeftEdge
    property int preferredWidth: 296
    property int maxHeight: 540
    property bool showArrow: true
    /// Set true while a nested CachyMenu is open so clicking an item in the
    /// child menu does not dismiss the popover via CloseOnPressOutside.
    property bool autoCloseLocked: false
    default property alias content: contentColumn.data

    property int activeEdge: root.preferredEdge
    property real arrowPos: 40

    readonly property Window hostWindow: (root.anchorItem && root.anchorItem.Window.window)
        ? root.anchorItem.Window.window
        : contentFlickable.itemWindow
    readonly property Item hostOverlay: (root.hostWindow && root.hostWindow.overlayItem)
        ? root.hostWindow.overlayItem
        : contentFlickable.qqcOverlay

    readonly property int effectiveWidth: {
        const winW = root.hostOverlay
            ? root.hostOverlay.width
            : (root.hostWindow ? root.hostWindow.width : 800);
        return Math.min(root.preferredWidth, Math.max(200, Math.round(winW) - 28));
    }

    parent: root.hostOverlay
    implicitWidth: root.effectiveWidth
    implicitHeight: contentFlickable.implicitHeight + topPadding + bottomPadding
    width: root.effectiveWidth
    padding: 12
    modal: false
    focus: true
    closePolicy: root.autoCloseLocked
        ? T.Popup.NoAutoClose
        : (T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside)

    function openAt(targetItem: Item) {
        root.anchorItem = targetItem;
        if (root.hostOverlay && root.parent !== root.hostOverlay) {
            root.parent = root.hostOverlay;
        }
        root.updateGeometry();
        root.open();
    }

    onOpened: {
        root.updateGeometry();
        Qt.callLater(root.updateGeometry);
    }

    function updateGeometry() {
        const winW = root.hostOverlay ? root.hostOverlay.width : (root.hostWindow ? root.hostWindow.width : 800);
        const winH = root.hostOverlay ? root.hostOverlay.height : (root.hostWindow ? root.hostWindow.height : 600);
        const margin = 14;
        const gap = root.showArrow ? 12 : 8;
        const popW = root.width > 0 ? root.width : root.preferredWidth;
        const popH = Math.min(contentColumn.implicitHeight + (root.padding * 2), root.maxHeight, Math.max(120, winH - (margin * 2)));

        if (!root.anchorItem || !root.hostOverlay) {
            root.activeEdge = root.preferredEdge;
            root.x = Math.max(margin, Math.round((winW - popW) / 2));
            root.y = Math.max(margin, Math.round((winH - popH) / 2));
            root.arrowPos = Math.round(popH / 2);
            return;
        }

        const topLeft = root.anchorItem.mapToItem(root.hostOverlay, 0, 0);
        const anchorRect = Qt.rect(topLeft.x, topLeft.y, root.anchorItem.width, root.anchorItem.height);
        const centerX = anchorRect.x + (anchorRect.width / 2);
        const centerY = anchorRect.y + (anchorRect.height / 2);

        let edge = root.preferredEdge;
        if (edge === Qt.LeftEdge) {
            if ((anchorRect.x - margin) < (popW + gap) && (winW - anchorRect.right - margin) >= (popW + gap)) {
                edge = Qt.RightEdge;
            }
        } else if (edge === Qt.RightEdge) {
            if ((winW - anchorRect.right - margin) < (popW + gap) && (anchorRect.x - margin) >= (popW + gap)) {
                edge = Qt.LeftEdge;
            }
        } else if (edge === Qt.BottomEdge) {
            if ((winH - anchorRect.bottom - margin) < (popH + gap) && (anchorRect.y - margin) >= (popH + gap)) {
                edge = Qt.TopEdge;
            }
        } else if (edge === Qt.TopEdge) {
            if ((anchorRect.y - margin) < (popH + gap) && (winH - anchorRect.bottom - margin) >= (popH + gap)) {
                edge = Qt.BottomEdge;
            }
        }
        root.activeEdge = edge;

        let targetX = margin;
        let targetY = margin;

        if (edge === Qt.LeftEdge) {
            targetX = anchorRect.x - popW - gap;
            targetY = Math.round(centerY - popH * 0.35);
        } else if (edge === Qt.RightEdge) {
            targetX = anchorRect.right + gap;
            targetY = Math.round(centerY - popH * 0.35);
        } else if (edge === Qt.TopEdge) {
            targetX = Math.round(centerX - (popW / 2));
            targetY = anchorRect.y - popH - gap;
        } else {
            targetX = Math.round(centerX - (popW / 2));
            targetY = anchorRect.bottom + gap;
        }

        root.x = Math.max(margin, Math.min(winW - popW - margin, targetX));
        root.y = Math.max(margin, Math.min(winH - popH - margin, targetY));

        if (edge === Qt.LeftEdge || edge === Qt.RightEdge) {
            root.arrowPos = Math.max(22, Math.min(popH - 22, centerY - root.y));
        } else {
            root.arrowPos = Math.max(22, Math.min(popW - 22, centerX - root.x));
        }
    }

    Connections {
        target: root.hostWindow
        function onWidthChanged() {
            if (root.opened) root.updateGeometry();
        }
        function onHeightChanged() {
            if (root.opened) root.updateGeometry();
        }
    }

    Connections {
        target: root.opened ? root.anchorItem : null
        function onXChanged() { root.updateGeometry(); }
        function onYChanged() { root.updateGeometry(); }
        function onWidthChanged() { root.updateGeometry(); }
        function onHeightChanged() { root.updateGeometry(); }
    }

    background: Item {
        Rectangle {
            id: popoverCardBg
            anchors.fill: parent
            radius: 14
            color: CachyPalette.sheetBackground
            border.width: 1
            border.color: CachyPalette.specularBorder
            visible: false
        }

        MultiEffect {
            property bool auditBleed: true
            anchors.fill: popoverCardBg
            source: popoverCardBg
            shadowEnabled: true
            shadowBlur: 0.6
            shadowVerticalOffset: 5
            shadowHorizontalOffset: 0
            shadowColor: Qt.rgba(0, 0, 0, CachyPalette.isDark ? 0.55 : 0.22)
        }

        // Directional pointer beak aimed at anchorItem
        Item {
            property bool auditBleed: true
            readonly property bool isHorizontalEdge: root.activeEdge === Qt.LeftEdge || root.activeEdge === Qt.RightEdge
            visible: root.showArrow && root.anchorItem !== null
            clip: true

            x: {
                if (root.activeEdge === Qt.LeftEdge) return parent.width - 1;
                if (root.activeEdge === Qt.RightEdge) return -8;
                return Math.round(root.arrowPos - 9);
            }
            y: {
                if (root.activeEdge === Qt.TopEdge) return parent.height - 1;
                if (root.activeEdge === Qt.BottomEdge) return -8;
                return Math.round(root.arrowPos - 9);
            }
            width: isHorizontalEdge ? 9 : 18
            height: isHorizontalEdge ? 18 : 9

            Rectangle {
                property bool auditBleed: true
                width: 11
                height: 11
                rotation: 45
                color: CachyPalette.sheetBackground
                border.width: 1
                border.color: CachyPalette.specularBorder
                x: {
                    if (root.activeEdge === Qt.LeftEdge) return -5.5;
                    if (root.activeEdge === Qt.RightEdge) return 3.5;
                    return 3.5;
                }
                y: {
                    if (root.activeEdge === Qt.TopEdge) return -5.5;
                    if (root.activeEdge === Qt.BottomEdge) return 3.5;
                    return 3.5;
                }
            }
        }
    }

    contentItem: Flickable {
        id: contentFlickable
        readonly property Window itemWindow: Window.window
        readonly property Item qqcOverlay: QQC2.Overlay.overlay
        readonly property real availableWinH: root.hostOverlay
            ? root.hostOverlay.height
            : (root.hostWindow ? root.hostWindow.height : 600)

        implicitWidth: root.width - (root.padding * 2)
        implicitHeight: Math.min(contentColumn.implicitHeight, root.maxHeight - (root.padding * 2), Math.max(80, availableWinH - 52))
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: CachyTheme.spacingSmall

            onImplicitHeightChanged: {
                if (root.opened) {
                    root.updateGeometry();
                }
            }
        }
    }
}
