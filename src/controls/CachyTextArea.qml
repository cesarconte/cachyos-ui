/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Multi-line text area control of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import CachyOS.UI

T.TextArea {
    id: control

    implicitWidth: Math.max(220, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(76, contentHeight + topPadding + bottomPadding)

    leftPadding: 12
    rightPadding: 12
    topPadding: 10
    bottomPadding: 10

    wrapMode: TextEdit.Wrap
    selectByMouse: true
    selectByKeyboard: true
    clip: true

    color: control.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
    placeholderTextColor: CachyTheme.textMuted
    selectedTextColor: "#FFFFFF"
    selectionColor: CachyTheme.accentColor
    font.pixelSize: 13

    background: Rectangle {
        radius: CachyTheme.radiusSmall
        color: CachyTheme.isDark ? Qt.rgba(0, 0, 0, 0.32) : Qt.rgba(0, 0, 0, 0.06)
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus
            ? CachyTheme.accentColor
            : (areaHover.hovered ? CachyTheme.withAlpha(CachyTheme.specularBorder, 0.40) : CachyTheme.specularBorder)

        Behavior on border.color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        HoverHandler {
            id: areaHover
            cursorShape: Qt.IBeamCursor
        }
    }
}
