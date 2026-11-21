/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Grouped Liquid Glass capsule container for toolbar action clusters
 * following the macOS 27 Golden Gate toolbar pattern.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Rectangle {
    id: root

    property int spacing: 2
    property int horizontalPadding: 4
    default property alias content: itemsRow.data

    implicitHeight: 28
    implicitWidth: Math.max(implicitHeight, itemsRow.implicitWidth + (root.horizontalPadding * 2))
    radius: Math.round(height / 2)
    color: CachyPalette.surfacePill
    border.width: 1
    border.color: CachyPalette.specularBorder

    Row {
        id: itemsRow
        anchors.centerIn: parent
        spacing: root.spacing
    }
}
