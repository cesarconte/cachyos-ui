/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Modal dialog overlay of the CachyOS.UI design system (Golden Gate / Liquid
 * Glass): a translucent scrim with a centered sheet card, a title, a body and
 * footer action buttons.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    anchors.fill: parent
    visible: false
    z: 100

    property string title: ""
    property string subtitle: ""
    property int preferredWidth: 360
    property bool showCancelButton: true
    property string cancelText: CachyI18n.i18n("Cancel")
    property list<QtObject> customFooterActions: []

    default property alias content: bodyColumn.data

    function open() {
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    // Scrim
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.32)

        TapHandler {
            onTapped: root.close()
        }
    }

    // Dialog sheet card
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - (CachyTheme.marginWindow * 2), root.preferredWidth)
        height: cardColumn.implicitHeight + (CachyTheme.marginCard * 2)
        radius: CachyTheme.radiusLarge
        color: CachyTheme.sheetBackground
        border.width: 1
        border.color: CachyTheme.specularBorder

        // Prevent clicks inside the card from dismissing the scrim
        TapHandler {}

        ColumnLayout {
            id: cardColumn
            anchors.fill: parent
            anchors.margins: CachyTheme.marginCard
            spacing: CachyTheme.spacingMedium

            CachyHeading {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: root.title.length > 0
                text: root.title
                level: 3
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: root.subtitle.length > 0
                text: root.subtitle
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: CachyTheme.textSecondary
            }

            ColumnLayout {
                id: bodyColumn
                Layout.fillWidth: true
                spacing: CachyTheme.spacingSmall
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: CachyTheme.spacingSmall

                Item {
                    Layout.fillWidth: true
                }

                CachyButton {
                    visible: root.showCancelButton
                    text: root.cancelText
                    onClicked: root.close()
                }

                Repeater {
                    model: root.customFooterActions

                    CachyButton {
                        required property var modelData
                        text: modelData.text ?? ""
                        iconName: modelData.icon && modelData.icon.name ? modelData.icon.name : ""
                        enabled: modelData.enabled !== false
                        visible: modelData.visible !== false
                        primary: true
                        onClicked: modelData.trigger()
                    }
                }
            }
        }
    }
}
