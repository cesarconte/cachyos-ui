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
