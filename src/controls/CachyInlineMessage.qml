/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Inline message of the CachyOS.UI design system: a short notice shown
 * inside a surface, with an icon and the text of the notice.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    /// Name of the icon in the Plasma icon theme (Breeze).
    property string iconName: "dialog-information"
    /// Text of the notice.
    property string text: ""
    /// Type of the notice: "information", "warning" or "error".
    property string messageType: "information"

    readonly property color accent: messageType === "error"
        ? "#FF3B30"
        : (messageType === "warning" ? "#FF9500" : CachyTheme.accentColor)

    implicitHeight: layout.implicitHeight + 16
    implicitWidth: layout.implicitWidth + 16
    radius: CachyTheme.radiusSmall
    color: CachyTheme.withAlpha(accent, 0.10)
    border.width: 1
    border.color: CachyTheme.withAlpha(accent, 0.28)

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 8
        spacing: CachyTheme.spacingSmall

        CachyIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            name: root.iconName
            fallback: root.messageType === "error" ? "error" : (root.messageType === "warning" ? "warning" : "info")
            size: 16
            color: root.accent
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.text
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyPalette.text
        }
    }
}
