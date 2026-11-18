/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Page stack of the CachyOS.UI design system.
 *
 * It offers the same API as the page stack of Kirigami (`push`, `pop`,
 * `removePage`, `clear`, `get`, `depth`, `currentIndex`, `currentItem`,
 * `initialPage` and the modal `layers`) so the applications of the ecosystem
 * can be migrated mechanically, but it does not depend on the Kirigami
 * application window: the pages are plain items stacked inside any container.
 */

pragma ComponentBehavior: Bound

import QtQuick
import CachyOS.UI

Item {
    id: stack

    /// Page shown when the stack is created: a component or the URL of a page.
    property var initialPage: null

    /// Index of the visible page.
    property int currentIndex: 0

    /// The page that is currently visible.
    readonly property Item currentItem: stack.depth > 0 ? pagesHost.children[stack.currentIndex] : null

    /// Number of pages in the stack.
    readonly property int depth: pagesHost.children.length

    /// The pages of the stack, in order.
    readonly property var items: pagesHost.children

    /// Modal dialogs shown over the content.
    readonly property CachyDialogLayer layers: dialogLayer

    /// The page at the bottom of the stack: it is the initial page and it is
    /// never removed while there is another page above it.
    property Item initialPageItem: null

    Item {
        id: pagesHost
        anchors.fill: parent
    }

    CachyDialogLayer {
        id: dialogLayer
        anchors.fill: parent
        z: 10
    }

    /// Shows the current page and hides the others.
    function updateVisibility() {
        const pages = pagesHost.children;
        for (let index = 0; index < pages.length; ++index) {
            pages[index].visible = (index === stack.currentIndex);
        }
    }

    /// Turns a component or an URL into a component.
    ///
    /// A QML `url` is neither a JavaScript string nor a `URL` instance, so the
    /// only reliable test is whether the value already offers the component
    /// API.
    function toComponent(source) {
        if (!source) {
            return null;
        }
        if (typeof source.createObject === "function") {
            return source;
        }
        const comp = Qt.createComponent(String(source));
        if (comp.status === Component.Error) {
            console.warn("CachyPageStack failed to load component:", comp.errorString());
        }
        return comp;
    }

    /// Pushes a page and returns it.
    function push(source, properties) {
        if (!source) {
            return null;
        }
        let page = null;
        if (source.parent !== undefined) {
            // It is already an instantiated Item (e.g. from Kirigami.PagePool)
            page = source;
            page.parent = pagesHost;
            if (properties) {
                for (let k in properties) {
                    page[k] = properties[k];
                }
            }
        } else {
            const component = stack.toComponent(source);
            if (!component) {
                return null;
            }
            page = component.createObject(pagesHost, properties || {});
            if (!page) {
                console.warn("CachyPageStack failed to instantiate page:", component.errorString());
                return null;
            }
        }
        page.anchors.fill = pagesHost;
        page.visible = false;
        stack.currentIndex = pagesHost.children.length - 1;
        stack.updateVisibility();
        return page;
    }

    /// Replaces the current page on top of the stack with a new page.
    function replace(source, properties) {
        if (pagesHost.children.length > 0) {
            stack.pop();
        }
        return stack.push(source, properties);
    }

    /// Navigates back in page history.
    function goBack() {
        if (stack.currentIndex > 0) {
            stack.currentIndex--;
            stack.updateVisibility();
        } else if (stack.depth > 1) {
            stack.pop();
        }
    }

    /// Navigates forward in page history.
    function goForward() {
        if (stack.currentIndex < stack.depth - 1) {
            stack.currentIndex++;
            stack.updateVisibility();
        }
    }

    /// Removes the page at the given index and destroys it.
    function removePage(index) {
        const page = pagesHost.children[index];
        if (!page) {
            return;
        }
        // The initial page is the bottom of the stack: it is kept as long as
        // there is another page above it.
        if (page === stack.initialPageItem && pagesHost.children.length > 1) {
            return;
        }
        page.visible = false;
        page.parent = null;
        page.destroy();
        stack.currentIndex = Math.max(0, Math.min(stack.currentIndex, pagesHost.children.length - 1));
        stack.updateVisibility();

        // The initial page is shown again when the last page above it is
        // removed.
        if (pagesHost.children.length === 0 && stack.initialPage) {
            stack.initialPageItem = stack.push(stack.initialPage, {});
        }
    }

    /// Removes the page at the given index and destroys it. Without an index,
    /// the page on top of the stack is removed.
    function pop(index) {
        if (index === undefined) {
            index = pagesHost.children.length - 1;
        }
        stack.removePage(index);
    }

    /// Removes every page but the initial one, which is the bottom of the
    /// stack.
    function clear() {
        for (let index = pagesHost.children.length - 1; index >= 0; --index) {
            const page = pagesHost.children[index];
            if (page !== stack.initialPageItem) {
                page.visible = false;
                page.parent = null;
                page.destroy();
            }
        }
        stack.currentIndex = 0;
        stack.updateVisibility();
    }

    /// The page at the given index.
    function get(index) {
        return pagesHost.children[index];
    }

    /// Opens a page as a modal dialog over the content.
    function pushDialogLayer(source, properties, dialogProperties) {
        const component = stack.toComponent(source);
        if (!component) {
            return null;
        }
        const merged = Object.assign({}, properties || {}, dialogProperties || {});
        return stack.layers.push(component, merged);
    }

    onCurrentIndexChanged: stack.updateVisibility()

    Component.onCompleted: {
        if (stack.initialPage) {
            stack.initialPageItem = stack.push(stack.initialPage, {});
        }
    }
}
