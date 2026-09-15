import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../js/ChangePage.js" as ChangePage
import "../" 1.0

Item {
    id: notify

    property bool dismissed: false

    Connections {
        target: Notification

        function onLatestNotificationChanged() {
            notify.dismissed = false

            ChangePage.changePage("notify")
            notificationTimer.restart()
        }
    }

    Timer {
        id: notificationTimer

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
        id: notificationCard

        anchors.fill: parent

        visible: !notify.dismissed

        radius: 22

        color: "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1

            radius: notificationCard.radius + 1

            color: "transparent"

            border.width: 1
            border.color: Qt.alpha(Theme.text, 0.03)

            z: -1
        }

        Row {
            anchors.fill: parent

            anchors.leftMargin: 14
            anchors.rightMargin: 18

            spacing: 12

            Item {
                width: 32
                height: 32

                anchors.verticalCenter:
                    parent.verticalCenter

                Rectangle {
                    anchors.fill: parent

                    radius: 13

                    color:
                        Qt.alpha(
                            Theme.text,
                            0.07
                        )

                    Image {
                        anchors.centerIn: parent

                        width: 20
                        height: 20

                        source:
                            "../assets/icons/notification.svg"

                        sourceSize.width: 24
                        sourceSize.height: 24

                        fillMode:
                            Image.PreserveAspectFit
                    }
                }
            }

            Column {
                anchors.verticalCenter:
                    parent.verticalCenter

                width:
                    parent.width - 54

                spacing: 4

                Text {
                    width: parent.width

                    text: "Notification"

                    color:
                        Qt.alpha(
                            Theme.text,
                            0.5
                        )

                    font.family:
                        Theme.fontFamily

                    font.pixelSize:
                        Theme.fontSizeS

                    font.bold: true

                    maximumLineCount: 1

                    elide:
                        Text.ElideRight

                    clip: true
                }

                Text {
                    width: parent.width

                    text: {
                        if (!Notification.latestNotification)
                            return ""

                        const summary =
                            Notification.latestNotification.summary || ""

                        const body =
                            Notification.latestNotification.body || ""

                        if (
                            summary !== "" &&
                            body !== ""
                        ) {
                            return (
                                summary +
                                " — " +
                                body
                            )
                        }

                        return summary !== ""
                            ? summary
                            : body
                    }

                    color:
                        Theme.text

                    font.family:
                        Theme.fontFamily

                    font.pixelSize:
                        Theme.fontSizeXS

                    font.bold: true

                    maximumLineCount: 1

                    elide:
                        Text.ElideRight

                    clip: true
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked: {
                notify.dismissed = true
                notificationTimer.stop()

                ChangePage.changePage(
                    Main.lastPage &&
                    Main.lastPage.trim() !== ""
                        ? Main.lastPage
                        : "homeClock"
                )
            }
        }
    }
}
