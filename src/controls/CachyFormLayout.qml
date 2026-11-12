/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Form layout of the CachyOS.UI design system: the rows of a settings form.
 *
 * It replaces the Kirigami form layout with the metrics of the design system.
 * The children are the fields themselves; the data holders of the form (the
 * `FormData` items) are not graphical and therefore are ignored by the layout,
 * exactly as the Kirigami layout did.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

ColumnLayout {
    id: root

    spacing: CachyTheme.spacingSmall
    columnSpacing: CachyTheme.spacingMedium
}
