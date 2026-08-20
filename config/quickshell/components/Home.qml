import QtQuick
import QtQuick.Controls
import Quickshell 
import "../" 1.0
import "home"
import "../js/ChangePage.js" as ChangePage
import "../services/swiper"

Item {
    id: root

    Swiper {
        id: swiper
        anchors.fill: parent
        maxPages: 3 

        onCurrentIndexChanged: {
            if (currentIndex === 0) {
                ChangePage.changePage("homeClock")
                Main.lastPage = "homeClock"
            } else if (currentIndex === 1) {
                ChangePage.changePage("homeWork")
                Main.lastPage = "homeWork"
            }else if (currentIndex === 2) {
                ChangePage.changePage("homeStatus")
                Main.lastPage = "homeStatus"
            }
        }

        Component.onCompleted: {
            ChangePage.changePage("homeClock")
        }




        Item {
            width: root.width
            height: root.height
            x: 0
            visible: swiper.currentIndex === 0
            
            Rectangle {
                anchors.fill: parent
                color: "#00000000" 
            }
            
            Clock {
                id: clock 
                anchors.centerIn: parent
            }
        }

        Item {
            width: root.width
            height: root.height
            x: root.width
            visible: swiper.currentIndex === 1


            Rectangle {
                anchors.fill: parent
                color: "#00000000" 
            }

            Workspace {
                id: workspace 
                anchors.centerIn: parent
            }
        }


        Item {
            width: root.width
            height: root.height
            x: root.width * 2
            visible: swiper.currentIndex === 2 


            Rectangle {
                anchors.fill: parent
                color: "#00000000" 
            }

            Status {
                id: status 
                anchors.centerIn: parent
            }
    }
    }
}
