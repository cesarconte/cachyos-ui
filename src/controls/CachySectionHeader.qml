/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Section header of the CachyOS.UI design system: the title of a group of
 * items inside a list or a surface.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Text {
    id: root

    text: ""
    font.pixelSize: 11
    font.weight: Font.DemiBold
    color: CachyPalette.textMuted
    elide: Text.ElideRight
}
