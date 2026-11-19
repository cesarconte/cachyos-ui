/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Modal dialog layer of the CachyOS.UI design system: the stack of dialogs
 * that are shown over the content of a window.
 *
 * It offers the same API as the layer stack of Kirigami (`push`, `pop`,
 * `depth`) so the applications can be migrated mechanically. The dialogs are
 * created as children of the layer and fill it.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Item {
    id: root

    /// The dialogs that are currently open, from the bottom to the top.
    property list<Item> dialogs: []

    /// Number of open dialogs.
    readonly property int depth: root.dialogs.length

    /// The dialog on top.
    readonly property Item currentDialog: root.dialogs.length > 0 ? root.dialogs[root.dialogs.length - 1] : null

    visible: root.dialogs.length > 0

    /// Opens a dialog and returns it.
    function push(component, properties) {
        if (!component) {
            return null;
        }
        if (component.status === Component.Error) {
            console.warn("CachyDialogLayer failed to load component:", component.errorString());
            return null;
        }
        const dialog = component.createObject(root, properties || {});
        if (!dialog) {
            console.warn("CachyDialogLayer: createObject returned null for component");
            return null;
        }
        // The dialogs are shown over the whole content of the window, as the
        // modal layers of the toolkit of the desktop do.
        dialog.anchors.fill = root;
        root.dialogs.push(dialog);
        return dialog;
    }

    /// Closes the dialog on top.
    function pop() {
        if (root.dialogs.length === 0) {
            return;
        }
        const dialog = root.dialogs.pop();
        dialog.destroy();
    }

    /// Closes every dialog.
    function clear() {
        while (root.dialogs.length > 0) {
            const dialog = root.dialogs.pop();
            dialog.destroy();
        }
    }

    // Solid backdrop so the page underneath does not show through the modal
    // layer: the scrim on top of it dismisses the dialog on tap.
    Rectangle {
        anchors.fill: parent
        color: CachyPalette.isDark ? Qt.rgba(0.12, 0.12, 0.15, 1.0) : Qt.rgba(0.97, 0.97, 0.99, 1.0)
    }

    // Scrim: dismisses the dialog on top.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.18)

        TapHandler {
            onTapped: root.pop()
        }
    }
}
