/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Liquid Glass dropdown selector of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import CachyOS.UI

T.ComboBox {
    id: control

    implicitWidth: Math.max(150, contentItem.implicitWidth + leftPadding + rightPadding + 28)
    implicitHeight: 32

    leftPadding: 12
    rightPadding: 28
    topPadding: 6
    bottomPadding: 6

    font.pixelSize: 13

    delegate: T.ItemDelegate {
        id: itemDelegate
        width: ListView.view ? ListView.view.width : control.width
        implicitWidth: Math.ceil(delegateRow.implicitWidth) + 8
        implicitHeight: 30

        required property var model
        required property var modelData
        required property int index

        readonly property string itemLabel: {
            if (control.textRole.length > 0 && itemDelegate.model && itemDelegate.model[control.textRole] !== undefined) {
                return String(itemDelegate.model[control.textRole]);
            }
            if (control.textRole.length > 0 && itemDelegate.modelData && itemDelegate.modelData[control.textRole] !== undefined) {
                return String(itemDelegate.modelData[control.textRole]);
            }
            return String(itemDelegate.modelData ?? "");
        }

        highlighted: control.highlightedIndex === itemDelegate.index

        background: Rectangle {
            radius: CachyTheme.radiusSmall
            color: itemDelegate.highlighted || itemHover.hovered
                ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.20)
                : "transparent"
        }

        contentItem: RowLayout {
            id: delegateRow
            spacing: 8

            CachyIcon {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                Layout.leftMargin: 6
                name: "check"
                size: 13
                color: CachyTheme.accentColor
                opacity: control.currentIndex === itemDelegate.index ? 1.0 : 0.0
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.rightMargin: 8
                text: itemDelegate.itemLabel
                color: control.currentIndex === itemDelegate.index ? CachyPalette.accentText : CachyPalette.text
                font.pixelSize: 13
                font.weight: control.currentIndex === itemDelegate.index ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        HoverHandler {
            id: itemHover
            cursorShape: Qt.PointingHandCursor
        }

        onClicked: {
            control.currentIndex = itemDelegate.index;
            control.activated(itemDelegate.index);
            control.popup.close();
        }
    }

    indicator: Column {
        x: control.width - width - 10
        y: Math.round((control.height - height) / 2)
        spacing: -2

        CachyIcon {
            name: "chevron-up"
            size: 9
            color: control.enabled ? CachyPalette.textSecondary : CachyPalette.textMuted
        }

        CachyIcon {
            name: "chevron-down"
            size: 9
            color: control.enabled ? CachyPalette.textSecondary : CachyPalette.textMuted
        }
    }

    contentItem: Text {
        text: control.displayText
        font: control.font
        color: control.enabled ? CachyPalette.text : CachyPalette.textMuted
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: comboHover.hovered ? CachyPalette.cardBackgroundHover : CachyPalette.cardBackground
        border.width: control.visualFocus || control.popup.visible ? 1.5 : 1
        border.color: control.visualFocus || control.popup.visible
            ? CachyTheme.accentColor
            : CachyPalette.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }
    }

    popup: T.Popup {
        y: control.height + 4
        width: {
            const hostWin = control.Window.window;
            const maxAllowed = hostWin && hostWin.width > 0
                ? Math.max(control.width, hostWin.width - 24)
                : 480;
            return Math.min(maxAllowed, Math.max(control.width, 160, Math.ceil(comboListView.maxDelegateWidth) + 10));
        }
        implicitHeight: Math.min(260, contentItem.implicitHeight + 10)
        padding: 5

        contentItem: ListView {
            id: comboListView
            readonly property real maxDelegateWidth: {
                let maxW = 0;
                const visItems = comboListView.contentItem.visibleChildren;
                for (let i = 0; i < visItems.length; ++i) {
                    const child = visItems[i];
                    if (child && child.visible && child.implicitWidth > maxW) {
                        maxW = child.implicitWidth;
                    }
                }
                return maxW;
            }
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            spacing: 2

            QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                policy: QQC2.ScrollBar.AsNeeded
            }
        }

        background: Item {
            Rectangle {
                id: comboPopupBg
                anchors.fill: parent
                radius: 14
                color: CachyPalette.sheetBackground
                border.width: 1
                border.color: CachyPalette.specularBorder
                visible: false
            }

            MultiEffect {
                property bool auditBleed: true
                anchors.fill: comboPopupBg
                source: comboPopupBg
                shadowEnabled: true
                shadowBlur: 0.55
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
                shadowColor: Qt.rgba(0, 0, 0, CachyPalette.isDark ? 0.50 : 0.20)
            }
        }
    }

    HoverHandler {
        id: comboHover
        cursorShape: Qt.PointingHandCursor
    }
}
