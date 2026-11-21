/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import CachyOS.UI

T.Button {
    id: control

    property bool primary: false
    property alias accent: control.primary
    property bool destructive: false
    property bool pillStyle: false
    property string iconName: ""

    readonly property string effectiveIconName: control.iconName.length > 0 ? control.iconName : control.icon.name
    readonly property color effectiveContentColor: {
        if (!control.enabled) return CachyPalette.textMuted;
        if (control.primary || control.destructive) return "#FFFFFF";
        if (control.flat) return CachyPalette.isDark ? "#5AB0FF" : CachyTheme.accentColor;
        return CachyPalette.text;
    }

    leftPadding: control.text.length > 0 ? (control.pillStyle ? 18 : 16) : 10
    rightPadding: control.text.length > 0 ? (control.pillStyle ? 18 : 16) : 10
    topPadding: 6
    bottomPadding: 6

    implicitWidth: Math.max(control.text.length > 0 ? 84 : 36, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding)
    implicitHeight: 32

    scale: control.pressed ? 0.96 : (btnHover.hovered ? 1.01 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutCubic }
    }

    background: Rectangle {
        radius: control.pillStyle ? Math.round(height / 2) : CachyTheme.radiusSmall
        color: {
            if (control.flat) {
                return btnHover.hovered ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.15) : "transparent";
            }
            if (control.destructive) {
                return control.pressed ? Qt.darker("#FF3B30", 1.15) : "#FF3B30";
            }
            if (control.primary) {
                return control.pressed ? Qt.darker(CachyTheme.accentColor, 1.15) : CachyTheme.accentColor;
            }
            // Standard Button
            if (btnHover.hovered) {
                return CachyPalette.cardBackgroundHover;
            }
            return CachyPalette.cardBackground;
        }

        border.width: control.flat ? 0 : 1
        border.color: (control.primary || control.destructive)
            ? Qt.rgba(1, 1, 1, 0.22)
            : CachyPalette.specularBorder

        Behavior on color {
            ColorAnimation { duration: CachyTheme.animFast }
        }

        // Golden Gate Liquid Glass top specular sheen
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, parent.radius - 1)
            visible: !control.flat
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, (control.primary || control.destructive) ? 0.24 : 0.14) }
                GradientStop { position: 0.55; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }
    }

    contentItem: Item {
        implicitWidth: innerRow.implicitWidth
        implicitHeight: innerRow.implicitHeight

        RowLayout {
            id: innerRow
            anchors.centerIn: parent
            width: Math.min(parent.width, implicitWidth)
            spacing: 6

            CachyIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                name: control.effectiveIconName
                size: 16
                color: control.effectiveContentColor
                visible: control.effectiveIconName.length > 0 && valid
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignVCenter
                visible: control.text.length > 0
                text: control.text
                color: control.effectiveContentColor
                font.pixelSize: 13
                font.weight: control.primary ? Font.DemiBold : Font.Normal
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    HoverHandler {
        id: btnHover
        cursorShape: Qt.PointingHandCursor
    }
}
