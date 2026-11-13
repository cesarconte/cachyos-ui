/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * File drag-and-drop container of the CachyOS.UI design system
 * (inspired by FishUI file_drop_area.cpp).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    /// Optional list of lowercase file extensions (e.g. ["torrent", "iso"]).
    /// When empty, any file/URL is accepted.
    property var acceptedExtensions: []
    property string placeholderTitle: CachyI18n.i18n("Arrastra archivos aquí")
    property string placeholderSubtitle: ""
    property string iconName: "download"
    readonly property bool containsDrag: dropArea.containsDrag
    default property alias contentData: contentHost.data

    signal filesDropped(var urls)

    function matchesExtensions(urlList) {
        if (!root.acceptedExtensions || root.acceptedExtensions.length === 0) {
            return urlList.length > 0;
        }
        for (let i = 0; i < urlList.length; ++i) {
            const path = String(urlList[i]).toLowerCase();
            for (let j = 0; j < root.acceptedExtensions.length; ++j) {
                const ext = String(root.acceptedExtensions[j]).toLowerCase().replace(/^\./, "");
                if (path.endsWith("." + ext)) {
                    return true;
                }
            }
        }
        return false;
    }

    implicitWidth: 280
    implicitHeight: 140
    radius: CachyTheme.radiusMedium
    color: dropArea.containsDrag
        ? CachyTheme.withAlpha(CachyTheme.accentColor, CachyPalette.isDark ? 0.18 : 0.12)
        : (contentHost.children.length === 0 ? CachyPalette.cardBackground : "transparent")
    border.width: dropArea.containsDrag || contentHost.children.length === 0 ? 1.5 : 0
    border.color: dropArea.containsDrag ? CachyTheme.accentColor : CachyPalette.specularBorder

    Behavior on color {
        ColorAnimation { duration: CachyTheme.animFast }
    }

    Item {
        id: contentHost
        anchors.fill: parent
    }

    // Default placeholder when used as a standalone drop zone
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.max(0, parent.width - 24)
        spacing: 6
        visible: contentHost.children.length === 0 || dropArea.containsDrag

        CachyIcon {
            Layout.alignment: Qt.AlignHCenter
            name: root.iconName
            size: 28
            color: dropArea.containsDrag ? CachyPalette.accentText : CachyPalette.textSecondary
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.placeholderTitle
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: dropArea.containsDrag ? CachyPalette.accentText : CachyPalette.text
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Text {
            visible: root.placeholderSubtitle.length > 0
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: root.placeholderSubtitle
            font.pixelSize: 11
            color: CachyPalette.textMuted
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent

        onEntered: (drag) => {
            if (!drag.hasUrls || !root.matchesExtensions(drag.urls)) {
                drag.accepted = false;
            }
        }

        onDropped: (drop) => {
            if (drop.hasUrls && root.matchesExtensions(drop.urls)) {
                root.filesDropped(drop.urls);
                drop.acceptProposedAction();
            }
        }
    }
}
