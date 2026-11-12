/*
    SPDX-FileCopyrightText: 2026 CachyOS UI contributors
    SPDX-License-Identifier: GPL-3.0-or-later

    Regression test of the checkable state of CachyToolbarButton.

    The button used to write `checked` itself when tapped. That assignment
    destroyed the binding the application had set on the property, so the
    control silently desynchronised from its backend: after the first click it
    kept a stale local value and ignored any later change of the model.
*/

import QtQuick
import QtTest
import CachyOS.UI

Item {
    id: root

    width: 200
    height: 120

    // The application owns the state; the button only reflects it.
    property bool backendState: false
    property int toggleCount: 0

    CachyToolbarButton {
        id: button
        anchors.centerIn: parent
        text: "T"
        checkable: true
        checked: root.backendState
        onToggled: (nextState) => {
            root.backendState = nextState;
            root.toggleCount += 1;
        }
    }

    TestCase {
        id: testCase
        name: "CachyToolbarButton"
        when: windowShown
        visible: true
        width: 200
        height: 120

        function test_initialStateFollowsTheBackend() {
            verify(button.checked !== undefined);
            compare(button.checked, false);

            root.backendState = true;
            compare(button.checked, true);
        }

        function test_tapEmitsTheIntendedState() {
            root.backendState = false;
            root.toggleCount = 0;
            compare(button.checked, false);

            mouseClick(button, Qt.LeftButton);
            compare(root.toggleCount, 1);
            compare(root.backendState, true);
            compare(button.checked, true);
        }

        function test_tapDoesNotDestroyTheBinding() {
            // The regression: after a tap, the binding set by the application
            // must still be alive, so an external change is still reflected.
            root.backendState = false;
            mouseClick(button, Qt.LeftButton);
            compare(button.checked, true);

            // The backend changes on its own: the button must follow it.
            root.backendState = false;
            compare(button.checked, false);

            root.backendState = true;
            compare(button.checked, true);
        }
    }
}
