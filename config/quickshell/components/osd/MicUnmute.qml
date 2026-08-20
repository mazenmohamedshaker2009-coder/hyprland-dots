import QtQuick
import Quickshell
import "../../js/ChangePage.js" as ChangePage
import "../../" 1.0

Item {

    Connections {
        target: AudioService

        function onMicrophoneMuteUpdated(muted) {
            if (muted)
                return

            ChangePage.changePage("osdMicUnmute")
            osdTimer.restart()
        }
    }

    Timer {
        id: osdTimer

        interval: 1500
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
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent


                source: "../../assets/icons/mic-unmute.svg"

                sourceSize.width: 22
                sourceSize.height: 22

                fillMode: Image.PreserveAspectFit
            }
        }

        Text {
            anchors.left: iconContainer.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: "Microphone Unmuted"

            color: Theme.foreground

            font.pixelSize: 14
            font.bold: true
        }
    }
}
