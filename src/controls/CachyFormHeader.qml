/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Section header of a form in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Text {
    id: root

    /// Title of the group.
    property string title: ""

    Layout.fillWidth: true
    Layout.leftMargin: CachyTheme.marginWindow + 6
    Layout.rightMargin: CachyTheme.marginWindow
    Layout.topMargin: CachyTheme.spacingLarge
    Layout.bottomMargin: 4

    text: root.title
    font.pixelSize: 13
    font.weight: Font.DemiBold
    color: CachyPalette.text
    elide: Text.ElideRight
}
