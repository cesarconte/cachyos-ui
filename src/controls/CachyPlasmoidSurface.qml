/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Canonical root surface for KDE Plasma applets / plasmoids.
 *
 * A plasmoide is NOT a window: it lives inside `plasmashell`, on a surface
 * that Plasma itself paints (the panel, or the applet popup with its
 * translucency and blur). That changes two fundamental rules compared to a
 * `CachyWindow`:
 *
 *   1. COLOUR comes from the HOST theme, not from `CachyTheme`. Inside
 *      `plasmashell`, `Kirigami.Theme` resolves to the Plasma desktop theme
 *      (the `colors` file of the active theme), which is what actually paints
 *      the surface the applet is drawn on. `CachyPalette.isDark()` decides with
 *      `QStyleHints::colorScheme()`, which follows the *application* colour
 *      scheme instead, so the two can disagree: with the macOS-GoldenGate
 *      theme the desktop theme is always dark with white foregrounds
 *      (`ForegroundNormal=252,252,252`) while the application scheme may be
 *      light. Using `CachyPalette.text` in that situation renders black
 *      text on a dark popup.
 *
 *   2. The applet must NOT paint its own opaque background. The host already
 *      provides the Liquid Glass surface; painting one hides the blur and
 *      breaks the Golden Gate look.
 *
 * GEOMETRY (radii, spacing, margins) and the ACCENT colour still come from
 * `CachyTheme`, so a plasmoide and an application share exactly the same
 * aesthetic; only the distances are tighter, because an applet has far less
 * room than a window.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import CachyOS.UI

Rectangle {
    id: root

    /// Title shown in the compact header.
    property string title: ""
    /// Secondary line under the title.
    property string subtitle: ""
    /// Name of an icon shown before the title (resolved from the Plasma theme).
    property string iconName: ""
    /// When false the surface is fully transparent and the host shows through.
    /// The default is false: the host already paints the glass.
    property bool framed: false
    /// Actions rendered at the trailing edge of the header.
    property alias headerActions: headerActionsHost.data
    /// Optional footer item, hosted below the body.
    property Item footer: null

    default property alias contentData: bodyColumn.data

    // ── Host palette ───────────────────────────────────────────────────────
    // These come from the Plasma desktop theme, i.e. from the very theme that
    // paints the surface this applet is drawn on. Using them guarantees that
    // the text always contrasts with the background, in any theme and in both
    // light and dark mode.
    readonly property color foreground: Kirigami.Theme.textColor
    readonly property color muted: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.72)
    readonly property color accent: CachyTheme.accentColor

    implicitWidth: 340
    implicitHeight: 420

    radius: root.framed ? CachyTheme.radiusLarge : 0
    color: root.framed ? CachyTheme.windowBackground : "transparent"
    border.width: root.framed ? 1 : 0
    border.color: CachyPalette.specularBorder

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Compact applet header
        Item {
            visible: root.title.length > 0 || headerActionsHost.children.length > 0
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredHeight: 42

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: CachyTheme.marginCard
                anchors.rightMargin: CachyTheme.marginCard
                spacing: CachyTheme.spacingSmall

                Kirigami.Icon {
                    visible: root.iconName.length > 0
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    Layout.alignment: Qt.AlignVCenter
                    source: root.iconName
                    isMask: true
                    color: root.accent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: root.title
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: root.foreground
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: root.subtitle.length > 0
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: root.subtitle
                        font.pixelSize: 10
                        color: root.muted
                        elide: Text.ElideRight
                    }
                }

                RowLayout {
                    id: headerActionsHost
                    spacing: CachyTheme.spacingSmall
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: CachyPalette.hardDividerColor
            }
        }

        // Main body
        ColumnLayout {
            id: bodyColumn
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            Layout.margins: CachyTheme.marginCard
            spacing: CachyTheme.spacingSmall
        }

        // Optional footer host
        Item {
            id: footerHost
            visible: root.footer !== null
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredHeight: root.footer ? root.footer.implicitHeight : 0
        }
    }

    Component.onCompleted: {
        if (root.footer) {
            root.footer.parent = footerHost;
            root.footer.anchors.fill = footerHost;
        }
    }
}
