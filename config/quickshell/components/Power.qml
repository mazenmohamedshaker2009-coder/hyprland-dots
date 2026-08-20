import QtQuick
import Quickshell
import "../" 1.0
import "../modules/power/"

FocusScope {
    id: root

    width: 400
    height: 140

    property int currentIndex: 0

    focus: visible

    // دالة موحدة لتنفيذ الأكشن بناءً على العنصر المحدد حالياً
    function triggerSelectedAction() {
        console.log("SELECT ACTION TRIGGERED:", currentIndex)

        switch (currentIndex) {
        case 0:
            console.log("SHUTDOWN")
            PowerService.shutdown()
            break

        case 1:
            console.log("RESTART")
            PowerService.reboot()
            break

        case 2:
            console.log("LOGOUT")
            PowerService.logout()
            break
        }
    }

    onVisibleChanged: {
        console.log("POWER: visible =", visible)

        if (visible) {
            currentIndex = 0
            forceActiveFocus()
            console.log("POWER: activeFocus =", activeFocus)
        }
    }

    // التعامل الشامل مع جميع أنواع أزرار Enter و Return
    Keys.onPressed: function(event) {
        console.log("POWER KEY:", event.key, event.text)

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            triggerSelectedAction()
            event.accepted = true
        }
    }

    Keys.onLeftPressed: {
        currentIndex--
        if (currentIndex < 0)
            currentIndex = 2
        console.log("POWER LEFT:", currentIndex)
    }

    Keys.onRightPressed: {
        currentIndex++
        if (currentIndex > 2)
            currentIndex = 0
        console.log("POWER RIGHT:", currentIndex)
    }

    Keys.onEscapePressed: {
        console.log("POWER ESCAPE")
    }

    Dispatch {}

    Row {
        anchors.centerIn: parent
        spacing: 20

        // زر Shutdown
        Rectangle {
            width: 110
            height: 110
            radius: 22

            color: root.currentIndex === 0 ? "#28ffffff" : "#18ffffff"

            Image {
                anchors.centerIn: parent

                width: 48
                height: 48

                sourceSize.width: 96
                sourceSize.height: 96

                source: "../assets/icons/power.svg"

                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.currentIndex = 0
                    root.triggerSelectedAction()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        // زر Restart
        Rectangle {
            width: 110
            height: 110
            radius: 22

            color: root.currentIndex === 1 ? "#28ffffff" : "#18ffffff"

            Image {
                anchors.centerIn: parent

                width: 48
                height: 48

                sourceSize.width: 96
                sourceSize.height: 96

                source: "../assets/icons/restart.svg"

                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.currentIndex = 1
                    root.triggerSelectedAction()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        // زر Logout
        Rectangle {
            width: 110
            height: 110
            radius: 22

            color: root.currentIndex === 2 ? "#28ffffff" : "#18ffffff"

            Image {
                anchors.centerIn: parent

                width: 48
                height: 48

                sourceSize.width: 96
                sourceSize.height: 96

                source: "../assets/icons/exit.svg"

                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.currentIndex = 2
                    root.triggerSelectedAction()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }
}
