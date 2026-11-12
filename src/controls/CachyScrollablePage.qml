/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Scrollable page of the CachyOS.UI design system.
 *
 * It replaces the Kirigami scrollable page: the content is scrollable, an
 * optional band of content can be shown above it (a search field, typically)
 * and another one below it (the actions of the page).
 *
 * The page is a plain item, so it can be pushed into any container of the
 * design system (the page stack of the window) without depending on the
 * navigation chrome of any toolkit.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import CachyOS.UI

Item {
    id: root

    /// Title of the page: the window header shows it.
    property string title: ""

    /// The stack of pages that shows this page, when it is shown in one.
    /// The pages that navigate use it to open other pages.
    property var pageStack: null

    /// Item shown above the content (a search field, typically).
    property Item header: null

    /// Item shown below the content (the actions of the page, typically).
    property Item footer: null

    /// The content of the page.
    default property alias content: pageColumn.data

    /// The flickable that scrolls the content.
    readonly property alias flickable: scrollFlickable

    /// The column that holds the content of the page.
    readonly property alias contentColumn: pageColumn

    implicitWidth: 480
    implicitHeight: 360

    // ---------------------------------------------------------------------
    // Upper band
    // ---------------------------------------------------------------------
    Item {
        id: headerHost
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.header ? root.header.implicitHeight + 10 : 0
        visible: root.header !== null
        z: 2

        CachyDivider {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: headerHost.height > 0
        }
    }

    // ---------------------------------------------------------------------
    // Lower band
    // ---------------------------------------------------------------------
    Item {
        id: footerHost
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.footer ? root.footer.implicitHeight : 0
        visible: root.footer !== null
        z: 2

        CachyDivider {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            visible: footerHost.height > 0
        }
    }

    // ---------------------------------------------------------------------
    // Scrollable content
    // ---------------------------------------------------------------------
    Flickable {
        id: scrollFlickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerHost.visible ? headerHost.bottom : parent.top
        anchors.bottom: footerHost.visible ? footerHost.top : parent.bottom
        contentWidth: width
        contentHeight: pageColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 1500
        maximumFlickVelocity: 5000

        QQC2.ScrollBar.vertical: QQC2.ScrollBar {
            policy: QQC2.ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: pageColumn
            width: scrollFlickable.width
            spacing: 0
        }
    }

    Component.onCompleted: {
        // The header and the footer are declared as properties, so they are
        // created as children of the page: they are moved to their band.
        if (root.header) {
            root.header.parent = headerHost;
            root.header.anchors.left = headerHost.left;
            root.header.anchors.right = headerHost.right;
            root.header.anchors.top = headerHost.top;
        }
        if (root.footer) {
            root.footer.parent = footerHost;
            root.footer.anchors.fill = footerHost;
        }

        // A list view is a scrollable content by itself: it occupies the whole
        // viewport and scrolls its own items instead of the page.
        for (const child of pageColumn.children) {
            if (child instanceof Flickable) {
                child.Layout.fillWidth = true;
                child.Layout.preferredHeight = Qt.binding(() => scrollFlickable.height);
                child.Layout.minimumHeight = Qt.binding(() => scrollFlickable.height);
                child.keyNavigationEnabled = true;
            }
        }
    }
}
