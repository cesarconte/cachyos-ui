/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Numeric spin box control of the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property int from: 0
    property int to: 100
    property int value: 0
    property int stepSize: 1
    property string prefix: ""
    property string suffix: ""
    property bool editable: true

    signal valueModified(int value)

    function setValueClamped(nextVal) {
        const clamped = Math.max(root.from, Math.min(root.to, Math.round(nextVal)));
        if (clamped !== root.value) {
            root.value = clamped;
            root.valueModified(clamped);
        }
    }

    implicitWidth: 132
    implicitHeight: 32
    radius: CachyTheme.radiusSmall
    color: CachyTheme.isDark ? Qt.rgba(0, 0, 0, 0.30) : Qt.rgba(0, 0, 0, 0.06)
    border.width: valueInput.activeFocus ? 1.5 : 1
    border.color: valueInput.activeFocus ? CachyTheme.accentColor : CachyTheme.specularBorder

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 2

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 6
            color: decTap.pressed
                ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.25)
                : (decHover.hovered ? CachyTheme.cardBackgroundHover : "transparent")
            enabled: root.value > root.from

            CachyIcon {
                anchors.centerIn: parent
                name: "remove"
                size: 12
                color: parent.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
            }

            HoverHandler {
                id: decHover
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                id: decTap
                enabled: parent.enabled
                onTapped: root.setValueClamped(root.value - root.stepSize)
            }
        }

        TextInput {
            id: valueInput
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            readOnly: !root.editable
            selectByMouse: true
            color: root.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
            selectionColor: CachyTheme.accentColor
            selectedTextColor: "#FFFFFF"
            font.pixelSize: 13
            font.weight: Font.Medium
            text: activeFocus ? String(root.value) : (root.prefix + String(root.value) + root.suffix)

            onEditingFinished: {
                const parsed = parseInt(text, 10);
                if (!isNaN(parsed)) {
                    root.setValueClamped(parsed);
                }
                text = Qt.binding(() => valueInput.activeFocus
                    ? String(root.value)
                    : (root.prefix + String(root.value) + root.suffix));
            }
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 6
            color: incTap.pressed
                ? CachyTheme.withAlpha(CachyTheme.accentColor, 0.25)
                : (incHover.hovered ? CachyTheme.cardBackgroundHover : "transparent")
            enabled: root.value < root.to

            CachyIcon {
                anchors.centerIn: parent
                name: "add"
                size: 12
                color: parent.enabled ? CachyTheme.textPrimary : CachyTheme.textMuted
            }

            HoverHandler {
                id: incHover
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            TapHandler {
                id: incTap
                enabled: parent.enabled
                onTapped: root.setValueClamped(root.value + root.stepSize)
            }
        }
    }
}
