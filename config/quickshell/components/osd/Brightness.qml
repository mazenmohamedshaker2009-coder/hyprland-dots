import QtQuick
import Quickshell
import "../../js/ChangePage.js" as ChangePage
import "../../" 1.0

Item {

    Connections {
        target: BrightnessService

        function onChanged(value) {

            Main.osdBrightness = value

            ChangePage.changePage("osdBrightness")
            osdTimer.restart()
        }
    }

    Timer {
        id: osdTimer

        interval: 5000
        repeat: false

        onTriggered: {
            ChangePage.changePage(
                Main.lastPage && Main.lastPage.trim() !== ""
                    ? Main.lastPage
                    : "homeClock"
            )
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        radius: 22

        Rectangle {
            id: iconContainer

            width: 22
            height: 22

            color: "transparent"

            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent

                source: "../../assets/icons/sun.svg"

                sourceSize.width: 22
                sourceSize.height: 22

                fillMode: Image.PreserveAspectFit
            }
        }

        Rectangle {
            id: bar

            width: 240
            height: 4

            radius: 2

            anchors.left: iconContainer.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            color: "#858b8b"

            Rectangle {
                id: progress

                width: bar.width * (Main.osdBrightness / 100)
                height: parent.height

                radius: parent.radius

                color: "#e5eaea"

                Behavior on width {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
