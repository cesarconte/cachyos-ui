/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import CachyOS.UI

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property string tooltipText: ""
    property bool checkable: false
    property bool checked: false
    property bool pillStyle: true
    /// Filled with the accent colour: the primary action of a surface.
    property bool primary: false

    signal clicked()
    /// Emitted when a checkable button is toggled. It carries the intended new
    /// state; the button never writes `checked` by itself, because that would
    /// destroy the binding the application sets on it and desynchronise the
    /// control from its backend.
    signal toggled(bool checked)

    implicitWidth: root.text.length > 0 || root.iconName.length > 0 ? contentRow.implicitWidth + 18 : 28
    implicitHeight: 28
    radius: height / 2

    readonly property bool isHovered: btnHover.hovered
    readonly property bool isPressed: btnTap.pressed

    scale: root.isPressed ? 0.94 : (root.isHovered ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutBack
        }
    }

    color: {
        if (root.primary) return CachyTheme.accentColor;
        if (root.checked) return Qt.rgba(CachyTheme.accentColor.r, CachyTheme.accentColor.g, CachyTheme.accentColor.b, 0.22);
        if (root.isPressed) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.14);
        if (root.isHovered) return CachyTheme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08);
        if (root.pillStyle) return CachyTheme.surfacePill;
        return "transparent";
    }

    border.width: (root.pillStyle || root.checked || root.isHovered || root.primary) ? 1 : 0
    border.color: root.primary ? CachyTheme.accentColor : (root.checked ? CachyTheme.accentColor : CachyTheme.specularBorder)

    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler {
        id: btnHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: btnTap
        onTapped: {
            if (root.checkable) {
                root.toggled(!root.checked);
            }
            root.clicked();
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        // Themed or built-in vector icon, tinted with the semantic color of the button.
        CachyIcon {
            id: iconHolder
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 16
            color: root.primary ? "#FFFFFF" : (root.checked ? CachyTheme.accentColor : CachyTheme.textPrimary)
            visible: root.iconName.length > 0 && valid
        }

        Text {
            visible: root.text.length > 0
            text: root.text
            color: root.primary ? "#FFFFFF" : (root.checked ? CachyTheme.accentColor : CachyTheme.textPrimary)
            font.pixelSize: 13
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ToolTip.visible: root.isHovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 450
}
