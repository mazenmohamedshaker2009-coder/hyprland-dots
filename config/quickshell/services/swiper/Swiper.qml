import QtQuick
import QtQuick.Controls
import Quickshell 

Item {
    id: root

    property int currentIndex: 0
    property int maxPages: 3 
    
    default property alias content: container.data
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }
    
    Item {
        id: container
        width: root.width * root.maxPages
        height: root.height
        
        x: -(root.currentIndex * root.width)

        layer.enabled: true
        layer.smooth: true

        Behavior on x {
            enabled: !mouseAction.isDragging      

            NumberAnimation { 
                duration: 255 
                easing.type: Easing.OutCubic 
            }
        }
    }

    MousAction {
        id: mouseAction
        anchors.fill: parent

        currentIndex: root.currentIndex
        maxPages: root.maxPages
        container: container

        onCurrentIndexChanged: {
            root.currentIndex = mouseAction.currentIndex
        }
    }
}
