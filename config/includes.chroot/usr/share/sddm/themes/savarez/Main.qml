/*
 * SavarezOS Login Theme
 * Copyright (C) 2026 Ananda Anugrah H <savarezos>
 *
 * Based on SDDM Breeze Theme
 * Copyright (C) 2026 KDE Community
 *
 * License: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1600
    height: 900

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {
        }
        function onLoginFailed() {
            passwordBox.text = ""
            passwordBox.focus = true
        }
    }

    Background {
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: primaryScreen

        Login {
            anchors.centerIn: parent
        }
    }
}
