/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * About page of the CachyOS.UI design system: the icon, the name, the
 * version and the links of an application, shown as a modal page.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyScrollablePage {
    id: root

    /// Name of the application.
    property string appTitle: ""

    /// Version of the application.
    property string appVersion: ""

    /// Name of the icon in the Plasma icon theme (Breeze).
    property string iconName: ""

    /// Description of the application.
    property string description: ""

    /// Links of the application: a list of objects with `text` and `url`.
    property var links: []

    /// Emitted when the user asks to close the page.
    signal closeRequested()

    contentColumn.spacing: CachyTheme.spacingMedium

    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: CachyTheme.spacingLarge
        spacing: CachyTheme.spacingMedium

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 96
            Layout.preferredHeight: 96
            source: root.iconName.length > 0 ? CachyTheme.iconUrl(root.iconName) : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        CachyHeading {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            horizontalAlignment: Text.AlignHCenter
            text: root.appTitle
            level: 2
        }

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            visible: root.appVersion.length > 0
            horizontalAlignment: Text.AlignHCenter
            text: root.appVersion
            font.pixelSize: 12
            color: CachyPalette.textMuted
        }

        CachySelectableLabel {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            visible: root.description.length > 0
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: root.description
        }
    }

    CachyFormCard {
        Layout.fillWidth: true
        Layout.leftMargin: CachyTheme.marginWindow
        Layout.rightMargin: CachyTheme.marginWindow

        Repeater {
            model: root.links

            CachyFormButtonDelegate {
                required property var modelData
                text: modelData.text
                onClicked: Qt.openUrlExternally(modelData.url)
            }
        }
    }

    footer: Item {
        implicitHeight: 56

        CachyButton {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: CachyI18n.i18n("Close")
            pillStyle: true
            onClicked: {
                root.closeRequested();
                if (root.pageStack && root.pageStack.layers && root.pageStack.layers.depth > 0) {
                    root.pageStack.layers.pop();
                } else if (root.parent && typeof root.parent.pop === "function") {
                    root.parent.pop();
                }
            }
        }
    }
}
