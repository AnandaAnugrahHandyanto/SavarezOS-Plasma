/*
 * SavarezOS Background Component
 * Copyright (C) 2026 Ananda Anugrah H
 * License: GPL-2.0-or-later
 */

import QtQuick 2.15

Item {
    id: background
    anchors.fill: parent

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background || "login.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: config.color || "#000000"
        opacity: backgroundImage.status == Image.Error ? 1 : 0
    }
}
