/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Liquid Glass context & dropdown menu of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Menu {
    id: control

    implicitWidth: Math.max(180, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    margins: 6
    padding: 5

    delegate: CachyMenuItem {}

    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        interactive: Window.window ? contentHeight > Window.window.height : false
        clip: true
        currentIndex: control.currentIndex
        spacing: 2
    }

    background: Rectangle {
        implicitWidth: 180
        implicitHeight: 36
        radius: CachyTheme.radiusMedium
        color: CachyTheme.sheetBackground
        border.width: 1
        border.color: CachyTheme.specularBorder
    }
}
