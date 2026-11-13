/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Canonical Golden Gate "< | >" navigation pill for window headers.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Rectangle {
    id: root

    property bool canGoBack: true
    property bool canGoForward: false

    signal backClicked()
    signal forwardClicked()

    implicitWidth: 58
    implicitHeight: 28
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: CachyTheme.surfacePill
    border.width: 1
    border.color: CachyTheme.specularBorder

    Row {
        anchors.fill: parent

        Item {
            width: Math.floor((parent.width - 1) / 2)
            height: parent.height

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: height / 2
                color: backHover.hovered && root.canGoBack ? CachyTheme.cardBackgroundHover : "transparent"
            }

            CachyIcon {
                anchors.centerIn: parent
                name: "chevron-left"
                size: 14
                color: root.canGoBack ? CachyTheme.textPrimary : CachyTheme.textMuted
            }

            HoverHandler {
                id: backHover
                cursorShape: root.canGoBack ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                enabled: root.canGoBack
                onTapped: root.backClicked()
            }
        }

        Rectangle {
            width: 1
            height: 12
            anchors.verticalCenter: parent.verticalCenter
            color: CachyTheme.dividerColor
        }

        Item {
            width: Math.floor((parent.width - 1) / 2)
            height: parent.height

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: height / 2
                color: fwdHover.hovered && root.canGoForward ? CachyTheme.cardBackgroundHover : "transparent"
            }

            CachyIcon {
                anchors.centerIn: parent
                name: "chevron-right"
                size: 14
                color: root.canGoForward ? CachyTheme.textPrimary : CachyTheme.textMuted
            }

            HoverHandler {
                id: fwdHover
                cursorShape: root.canGoForward ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                enabled: root.canGoForward
                onTapped: root.forwardClicked()
            }
        }
    }
}
