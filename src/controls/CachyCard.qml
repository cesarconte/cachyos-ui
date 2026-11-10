/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.Control {
    id: root

    property alias radius: bgRect.radius
    property alias color: bgRect.color
    property alias border: bgRect.border
    property bool interactive: false
    signal clicked()

    leftPadding: CachyTheme.spacingMedium
    rightPadding: CachyTheme.spacingMedium
    topPadding: CachyTheme.spacingMedium
    bottomPadding: CachyTheme.spacingMedium

    implicitWidth: Math.max(120, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: Math.max(40, (contentItem ? contentItem.implicitHeight : 0) + topPadding + bottomPadding)

    background: Rectangle {
        id: bgRect
        radius: CachyTheme.radiusMedium
        color: root.interactive && hoverHandler.hovered
            ? CachyTheme.cardBackgroundHover
            : CachyTheme.cardBackground
        border.width: 1
        border.color: CachyTheme.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        HoverHandler {
            id: hoverHandler
            enabled: root.interactive
            cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        }

        TapHandler {
            enabled: root.interactive
            onTapped: root.clicked()
        }
    }
}
