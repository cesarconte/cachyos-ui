/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import CachyOS.UI

Window {
    id: root

    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    width: CachyTheme.windowWidthUtility
    height: CachyTheme.windowHeightUtility
    minimumWidth: CachyTheme.windowWidthDialog
    minimumHeight: 400

    property bool showTrafficLights: true
    property bool closable: true
    property bool minimizable: true
    property bool maximizable: true
    property alias windowTitle: titleLabel.text
    property alias contentData: contentArea.data
    property int cornerRadius: CachyTheme.radiusWindow
    property color backgroundColor: "transparent"

    CachyWindowBlur.enabled: true

    Item {
        id: windowSurface
        anchors.fill: parent

        // Drag Handler to drag the window by titlebar or empty space
        DragHandler {
            id: windowDrag
            target: null
            onActiveChanged: {
                if (active) {
                    root.startSystemMove();
                }
            }
        }

        // Fondo redondeado si se especifica backgroundColor
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            radius: root.cornerRadius
            color: root.backgroundColor
            visible: root.backgroundColor !== "transparent"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // macOS Traffic Light TitleBar
            Item {
                id: titleBar
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: 44
                visible: root.showTrafficLights

                CachyTrafficLights {
                    anchors.left: parent.left
                    anchors.leftMargin: CachyTheme.marginWindow
                    anchors.verticalCenter: parent.verticalCenter
                    window: root
                    closable: root.closable
                    minimizable: root.minimizable
                    maximizable: root.maximizable
                }

                // Window Title (Centered)
                Text {
                    id: titleLabel
                    anchors.centerIn: parent
                    text: root.title
                    color: CachyTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            // Client Content Area
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.fillHeight: true
            }
        }

        // Borde exterior especular continuo de 1px sobre las 4 esquinas redondeadas
        Rectangle {
            id: specularRim
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            border.width: 1
            border.color: CachyTheme.specularBorder
            z: 100
        }
    }
}
