import QtQuick
import QtQuick.Controls
import Quickshell 
import "../../" 1.0
import "../../js/ChangePage.js" as ChangePage

Item {
    id: root

    property real startX: 0
    property int currentIndex: 0
    property int maxPages: 1
    property Item container: null

    MouseArea {
        id: dragArea
        anchors.fill: parent

        onPressed: (mouse) => {
            startX = mouse.x
            if (root.container && root.container.Behavior) {
                root.container.Behavior.enabled = false
            }
        }

        onPositionChanged: (mouse) => {
            if (!root.container) return
            var delta = mouse.x - startX
            root.container.x = -(currentIndex * root.width) + delta
        }

        onReleased: (mouse) => {
            if (!root.container) return

            root.container.Behavior.enabled = true

            var dragDistance = mouse.x - startX
            var threshold = root.width / 2 

            var newIndex = currentIndex
            if (dragDistance > threshold && newIndex > 0) {
                newIndex--
            } else if (
                dragDistance < -threshold &&
                newIndex < maxPages - 1
            ) {
                newIndex++
            }

            currentIndex = newIndex

            root.container.x = -(currentIndex * root.width)
        }
    }
}
