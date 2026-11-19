/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Standard text label for the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Inherits from QtQuick.Controls.Label, enforcing consistent typography, palette
 * integration (CachyPalette.text), and smooth rendering across all themes.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import CachyOS.UI

Controls.Label {
    id: root

    color: CachyPalette.text
    font.pixelSize: 13
    renderType: Text.QtRendering
    verticalAlignment: Text.AlignVCenter
}
