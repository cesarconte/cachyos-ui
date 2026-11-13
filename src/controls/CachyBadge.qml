/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Compact status chip / badge of the CachyOS.UI design system
 * (Vuetify v-chip / v-badge equivalent).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    /// Semantic variant: "neutral", "accent", "success", "warning", "error".
    property string badgeType: "neutral"
    property bool closable: false

    signal closeClicked()

    readonly property color tintColor: {
        if (root.badgeType === "error") return "#FF3B30";
        if (root.badgeType === "warning") return "#FF9500";
        if (root.badgeType === "success") return "#34C759";
        if (root.badgeType === "accent") return CachyTheme.accentColor;
        return CachyTheme.textSecondary;
    }

    implicitWidth: Math.max(24, contentRow.implicitWidth + 16)
    implicitHeight: 22
    radius: height / 2
    color: root.badgeType === "neutral"
        ? CachyTheme.surfacePill
        : CachyTheme.withAlpha(root.tintColor, CachyTheme.isDark ? 0.22 : 0.14)
    border.width: 1
    border.color: root.badgeType === "neutral"
        ? CachyTheme.specularBorder
        : CachyTheme.withAlpha(root.tintColor, 0.38)

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        CachyIcon {
            Layout.preferredWidth: 11
            Layout.preferredHeight: 11
            name: root.iconName
            size: 11
            color: root.badgeType === "neutral" ? CachyTheme.textSecondary : root.tintColor
            visible: root.iconName.length > 0 && valid
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.text
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: root.badgeType === "neutral" ? CachyTheme.textPrimary : root.tintColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            visible: root.closable
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12

            CachyIcon {
                anchors.centerIn: parent
                name: "close"
                size: 9
                color: root.badgeType === "neutral" ? CachyTheme.textSecondary : root.tintColor
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.closeClicked()
            }
        }
    }
}
