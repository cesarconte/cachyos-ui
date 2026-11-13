/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Non-intrusive floating pill notification of the CachyOS.UI design system
 * (inspired by FishUI Toast.qml).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    property string text: ""
    /// Semantic type: "info", "success", "warning", "error".
    property string messageType: "info"
    /// Auto-hide duration in milliseconds (0 disables auto-hide).
    property int duration: 2800
    property bool closable: true
    property bool active: false
    property bool auditBleed: true

    readonly property color semanticColor: {
        if (root.messageType === "error") return "#FF3B30";
        if (root.messageType === "warning") return "#FF9500";
        if (root.messageType === "success") return "#34C759";
        return CachyTheme.accentColor;
    }

    readonly property string semanticIcon: {
        if (root.messageType === "error") return "error";
        if (root.messageType === "warning") return "warning";
        if (root.messageType === "success") return "success";
        return "info";
    }

    function show(message, type, timeoutMs) {
        if (message !== undefined) root.text = message;
        if (type !== undefined && type.length > 0) root.messageType = type;
        if (timeoutMs !== undefined && timeoutMs >= 0) root.duration = timeoutMs;
        root.active = true;
        if (root.duration > 0) {
            hideTimer.restart();
        }
    }

    function hide() {
        hideTimer.stop();
        root.active = false;
    }

    implicitWidth: Math.min(420, Math.max(160, row.implicitWidth + 28))
    implicitHeight: 36
    radius: height / 2
    color: CachyTheme.sheetBackground
    border.width: 1
    border.color: CachyTheme.withAlpha(root.semanticColor, 0.45)

    visible: opacity > 0.01
    opacity: root.active ? 1.0 : 0.0
    scale: root.active ? 1.0 : 0.92
    z: 999900

    Behavior on opacity {
        NumberAnimation { duration: CachyTheme.animFast; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: CachyTheme.animNormal; easing.type: Easing.OutBack }
    }

    Timer {
        id: hideTimer
        interval: Math.max(400, root.duration)
        repeat: false
        onTriggered: root.active = false
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 8

        CachyIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            name: root.semanticIcon
            size: 16
            color: root.semanticColor
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.text
            font.pixelSize: 12
            font.weight: Font.Medium
            color: CachyTheme.textPrimary
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            visible: root.closable
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            radius: 9
            color: closeHover.hovered ? CachyTheme.cardBackgroundHover : "transparent"

            CachyIcon {
                anchors.centerIn: parent
                name: "close"
                size: 10
                color: CachyTheme.textSecondary
            }

            HoverHandler {
                id: closeHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.hide()
            }
        }
    }
}
