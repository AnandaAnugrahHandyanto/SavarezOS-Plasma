import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Page {
    title: "About SavarezOS"

    Column {
        anchors.centerIn: parent
        spacing: 18

        Image {
            source: "/usr/share/icons/hicolor/scalable/apps/savarez-logo.png"
            width: 128
            height: 128
        }

        Kirigami.Heading {
            text: "SavarezOS Plasma"
            level: 1
        }

        Kirigami.Label {
            text: "Version: 1.0 Beta"
        }

        Kirigami.Label {
            text: "Independent Linux Distribution"
        }

        Kirigami.Label {
            text: "Built by SavarezOS Project"
        }

        Kirigami.Label {
            text: "https://savarezos.org"
        }
    }
}
