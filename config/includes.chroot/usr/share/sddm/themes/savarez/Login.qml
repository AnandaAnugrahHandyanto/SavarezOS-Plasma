/*
 * SavarezOS Login Component
 * Copyright (C) 2026 Ananda Anugrah H
 * License: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

ColumnLayout {
    id: loginLayout
    spacing: 20
    width: 320

    Image {
        id: logo
        source: "savarez-logo.png"
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 128
        Layout.preferredHeight: 128
        fillMode: Image.PreserveAspectFit
    }

    Text {
        text: textConstants.welcomeText.arg(sddm.hostName)
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 24
        color: "white"
    }

    ComboBox {
        id: name
        Layout.fillWidth: true
        model: userModel
        textRole: "name"
        currentIndex: userModel.lastIndex
        font.pixelSize: 14
        
        delegate: ItemDelegate {
            width: parent.width
            text: model.name
            font.pixelSize: 14
            highlighted: parent.highlightedIndex === index
        }
    }

    TextField {
        id: passwordBox
        Layout.fillWidth: true
        echoMode: TextInput.Password
        placeholderText: textConstants.password
        font.pixelSize: 14
        focus: true

        onAccepted: sddm.login(name.currentText, passwordBox.text, sessionIndex)
    }

    Button {
        id: loginButton
        text: textConstants.login
        Layout.fillWidth: true
        onClicked: sddm.login(name.currentText, passwordBox.text, sessionIndex)
    }
}
