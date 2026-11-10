/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    property alias radius: cardBg.radius
    property alias color: cardBg.color
    property alias border: cardBg.border
    default property alias content: container.data

    property bool interactive: false
    property bool hovered: hoverHandler.hovered
    signal clicked()

    implicitWidth: container.implicitWidth + (CachyTheme.spacingMedium * 2)
    implicitHeight: container.implicitHeight + (CachyTheme.spacingMedium * 2)

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: CachyTheme.radiusMedium
        color: root.interactive && root.hovered
            ? CachyTheme.cardBackgroundHover
            : CachyTheme.cardBackground
        border.width: 1
        border.color: CachyTheme.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        Item {
            id: container
            anchors.fill: parent
            anchors.margins: CachyTheme.spacingMedium
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
