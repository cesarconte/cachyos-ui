/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Empty state of the CachyOS.UI design system: a tinted icon above the
 * explanatory text. It replaces the Kirigami placeholder message with the
 * tokens of the design system.
 *
 * The state can offer a helpful action (a button) and any extra content
 * (the buttons of a confirmation, for instance).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Name of the icon in the Plasma icon theme (Breeze).
    property string iconName: ""
    /// Explanatory text of the empty state.
    property string text: ""
    /// Size of the icon in pixels.
    property int iconSize: 48
    /// Action offered by the empty state: an object with `text`, `iconName`
    /// and `onTriggered`.
    property var helpfulAction: null
    /// Extra content of the empty state (the buttons of a confirmation).
    default property alias extraContent: extraColumn.data

    implicitWidth: Math.max(160, root.text.length > 0 ? 240 : root.iconSize)
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        width: Math.min(parent.width, root.implicitWidth)
        spacing: CachyTheme.spacingSmall

        // Icon badge
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            radius: root.iconSize / 2
            color: CachyTheme.withAlpha(CachyTheme.textPrimary, 0.06)
            visible: root.iconName.length > 0

            CachyIcon {
                anchors.centerIn: parent
                name: root.iconName
                size: Math.round(root.iconSize * 0.55)
                color: CachyTheme.textSecondary
            }
        }

        Text {
            id: rootTextLabel
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            visible: root.text.length > 0
            text: root.text
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            color: CachyTheme.textMuted
        }

        ColumnLayout {
            id: extraColumn
            Layout.alignment: Qt.AlignHCenter
            spacing: CachyTheme.spacingSmall
            visible: extraColumn.children.length > 0
        }

        CachyButton {
            Layout.alignment: Qt.AlignHCenter
            visible: root.helpfulAction !== null
            text: root.helpfulAction ? (root.helpfulAction.text ?? "") : ""
            onClicked: {
                if (root.helpfulAction && root.helpfulAction.onTriggered) {
                    root.helpfulAction.onTriggered();
                }
            }
        }
    }
}
