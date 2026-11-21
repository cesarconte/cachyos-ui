/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Search field of the CachyOS.UI design system: a text field with a
 * magnifier and a quick clean button.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

CachyTextField {
    id: control

    isSearch: true
    pillStyle: true
    implicitWidth: 240
    implicitHeight: 28

    Keys.onEscapePressed: control.clear()
}
