/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Selectable label of the CachyOS.UI design system: a read-only text that can
 * be selected with the mouse and that reports the links that are clicked.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

TextEdit {
    id: root

    readOnly: true
    selectByMouse: true
    selectByKeyboard: true
    activeFocusOnTab: false

    textFormat: TextEdit.AutoText
    color: CachyTheme.textPrimary
    selectedTextColor: "#FFFFFF"
    selectionColor: CachyTheme.accentColor
    font.pixelSize: 12
}
