/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Page of a form in the CachyOS.UI design system: a scrollable column of cards
 * with an optional header and footer.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

CachyScrollablePage {
    id: root

    contentColumn.spacing: CachyTheme.spacingMedium
}
