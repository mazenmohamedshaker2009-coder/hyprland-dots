import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../" 1.0

Item {
    id: root

    property int currentWorkspace:
        Hyprland.focusedWorkspace
        ? parseInt(Hyprland.focusedWorkspace.name)
        : 1

    implicitWidth: 6 * 28 + 5 * 6
    implicitHeight: 24

    Row {
        anchors.fill: parent

        spacing: 6

        Repeater {
            model: 6

            Rectangle {
                width: 28
                height: 24

                radius: 6

                color: index === activeIndex
                    ? Qt.alpha(Theme.text, 0.35)
                    : Qt.alpha(Theme.text, 0.08)

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent

                    color: Theme.text

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeS
                    font.bold: true

                    text: {
                        if (index < 5)
                            return index + 1

                        return currentWorkspace > 6
                            ? currentWorkspace
                            : 6
                    }
                }
            }
        }
    }

    property int activeIndex:
        currentWorkspace <= 6
        ? currentWorkspace - 1
        : 5
}
