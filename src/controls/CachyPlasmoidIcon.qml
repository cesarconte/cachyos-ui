/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Canonical icon for a plasmoide, both in the panel and inside the popup.
 *
 * Why not `CachyIcon`? `CachyIcon` resolves the file through
 * `CachyTheme.iconUrl()` and tints it with `MultiEffect` colourisation. Both
 * steps are wrong for a panel icon:
 *
 *   * `CachyTheme.iconUrl()` searches a hard-coded list of Breeze/Hicolor
 *     directories, so it ignores the icon theme the user actually selected
 *     (macOS-GoldenGate, Papirus, …).
 *   * `MultiEffect` colourisation replaces the luminance of the source, so a
 *     symbolic icon whose own `ColorScheme-Text` class is dark (#232629) stays
 *     dark instead of adopting the theme foreground.
 *
 * `Kirigami.Icon` with `isMask: true` does the right thing: it resolves the
 * icon from the Plasma icon theme and paints it as a mask tinted with the
 * host foreground, exactly like every other applet in the panel.
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    /// Name of the icon in the Plasma icon theme (e.g. "games-highscores-symbolic").
    property string iconName: ""
    /// Optional fallback icon name used when `iconName` does not exist.
    property string fallbackIconName: ""
    /// Logical size of the icon in pixels.
    property int iconSize: 16
    /// Tint applied to the icon. Defaults to the host foreground, so the icon
    /// follows the Plasma theme (white in the Golden Gate desktop theme) and
    /// is always legible against the panel.
    property color color: Kirigami.Theme.textColor

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize

    Kirigami.Icon {
        id: icon
        anchors.fill: parent
        source: root.fallbackIconName.length > 0
            ? (root.iconName.length > 0 ? root.iconName : root.fallbackIconName)
            : root.iconName
        fallback: root.fallbackIconName.length > 0 ? root.fallbackIconName : ""
        isMask: true
        color: root.color
    }
}
