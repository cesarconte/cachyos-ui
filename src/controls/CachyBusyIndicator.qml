/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * GPU vector busy indicator of the CachyOS.UI design system
 * (inspired by FishUI BusyIndicator.qml).
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import CachyOS.UI

Item {
    id: root

    property bool running: true
    property int size: 22
    property color color: CachyTheme.accentColor

    implicitWidth: root.size
    implicitHeight: root.size
    visible: root.running

    Shape {
        id: spinner
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        RotationAnimator on rotation {
            running: root.running && root.visible
            from: 0
            to: 360
            duration: 850
            loops: Animation.Infinite
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: CachyTheme.withAlpha(root.color, 0.20)
            strokeWidth: Math.max(2, Math.round(root.size * 0.11))
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: spinner.width / 2
                centerY: spinner.height / 2
                radiusX: (spinner.width / 2) - 2
                radiusY: (spinner.height / 2) - 2
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: Math.max(2, Math.round(root.size * 0.11))
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: spinner.width / 2
                centerY: spinner.height / 2
                radiusX: (spinner.width / 2) - 2
                radiusY: (spinner.height / 2) - 2
                startAngle: -90
                sweepAngle: 250
            }
        }
    }
}
