/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Card of the CachyOS.UI design system: the surface that groups the rows of a form.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    implicitWidth: Math.max(320, contentColumn.implicitWidth + (CachyTheme.marginCard * 2))
    implicitHeight: contentColumn.implicitHeight + (CachyTheme.marginCard * 2)
    radius: CachyTheme.radiusMedium
    color: CachyTheme.cardBackground
    border.width: 1
    border.color: CachyTheme.specularBorder

    default property alias content: contentColumn.data

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: CachyTheme.marginCard
        spacing: CachyTheme.spacingSmall
    }
}
