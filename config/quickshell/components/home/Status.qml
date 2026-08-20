import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../services/status/"
import "../../" 1.0

Row {
    spacing: 10
    anchors.verticalCenter: parent.verticalCenter

    Battary {id: battery}
    Brightness {id: brightness}
    Aduio {id: aduio}


    Rectangle {
     width: 22; height: 22; color: "transparent"
     anchors.verticalCenter: parent.verticalCenter
        Image {
            anchors.fill: parent
            source: "../../assets/icons/battery.svg"
            sourceSize.width: 22; sourceSize.height: 22
        }
    }
    
    Text {
     text:{return Main.battary} 
     color: "white"
     font.pixelSize: 12
     anchors.verticalCenter: parent.verticalCenter
    }


    Rectangle {
     width: 22; height: 22; color: "transparent"
     anchors.verticalCenter: parent.verticalCenter
    
        Image {
            anchors.fill: parent
            source: "../../assets/icons/sun.svg"
            sourceSize.width: 22; sourceSize.height: 22
        }
    }

    Text {
        text:{return Main.brightness} 
        color: "white"
        font.pixelSize: 12
        anchors.verticalCenter: parent.verticalCenter
    }











    Rectangle {
     width: 22; height: 22; color: "transparent"
     anchors.verticalCenter: parent.verticalCenter
      
        Image {
            anchors.fill: parent
            source: "../../assets/icons/sound.svg"
            sourceSize.width: 22; sourceSize.height: 22
        }
    }

    Text {
        text:{return Main.aduio}
        color: "white"
        font.pixelSize: 12
        anchors.verticalCenter: parent.verticalCenter
    }
}
