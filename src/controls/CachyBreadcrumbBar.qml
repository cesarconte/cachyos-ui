/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Interactive path / breadcrumb bar for file managers (Dolphin) and
 * hierarchical views in the CachyOS.UI design system.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    /// Filesystem or logical path (e.g. "/home/cesar/Proyectos").
    property string path: "/"
    /// Optional explicit segments override; when empty, derived from `path`.
    property var customSegments: []
    property bool showFolderIcon: true

    signal pathClicked(string targetPath, int index)

    readonly property var effectiveSegments: {
        if (root.customSegments && root.customSegments.length > 0) {
            return root.customSegments;
        }
        const cleaned = root.path.replace(/^\/+|\/+$/g, "");
        if (cleaned.length === 0) {
            return [{ label: "/", fullPath: "/" }];
        }
        const parts = cleaned.split("/");
        const out = [];
        let acc = "";
        for (let i = 0; i < parts.length; ++i) {
            acc += "/" + parts[i];
            out.push({ label: parts[i], fullPath: acc });
        }
        return out;
    }

    implicitWidth: Math.max(160, row.implicitWidth + 16)
    implicitHeight: 30
    radius: CachyTheme.radiusSmall
    color: CachyPalette.surfacePill
    border.width: 1
    border.color: CachyPalette.specularBorder
    clip: true

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 2

        CachyIcon {
            visible: root.showFolderIcon
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            Layout.rightMargin: 2
            name: "folder"
            size: 14
            color: CachyPalette.accentText
        }

        Repeater {
            model: root.effectiveSegments

            RowLayout {
                id: crumbDelegate
                required property var modelData
                required property int index

                readonly property bool isLast: index === root.effectiveSegments.length - 1
                readonly property string labelText: typeof modelData === "object"
                    ? String(modelData.label ?? "")
                    : String(modelData ?? "")
                readonly property string targetPath: typeof modelData === "object"
                    ? String(modelData.fullPath ?? modelData.label ?? "")
                    : String(modelData ?? "")

                Layout.fillWidth: isLast
                Layout.minimumWidth: 0
                spacing: 2

                CachyIcon {
                    visible: crumbDelegate.index > 0
                    Layout.preferredWidth: 11
                    Layout.preferredHeight: 11
                    name: "chevron-right"
                    size: 11
                    color: CachyPalette.textMuted
                }

                Rectangle {
                    Layout.fillWidth: crumbDelegate.isLast
                    Layout.minimumWidth: 0
                    Layout.preferredWidth: crumbText.implicitWidth + 10
                    Layout.preferredHeight: 22
                    radius: 5
                    color: crumbHover.hovered ? CachyPalette.cardBackgroundHover : "transparent"

                    Text {
                        id: crumbText
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        text: crumbDelegate.labelText
                        font.pixelSize: 12
                        font.weight: crumbDelegate.isLast ? Font.DemiBold : Font.Normal
                        color: crumbDelegate.isLast ? CachyPalette.text : CachyPalette.textSecondary
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideMiddle
                    }

                    HoverHandler {
                        id: crumbHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.pathClicked(crumbDelegate.targetPath, crumbDelegate.index)
                    }
                }
            }
        }
    }
}
