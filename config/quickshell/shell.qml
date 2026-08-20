import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

import "." 1.0
import "components"
import "components/osd"


ShellRoot {

    // ========================================================
    // MAIN BARY PANEL
    // ========================================================

    PanelWindow {
        id: root

        aboveWindows: true
        exclusiveZone: 44

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: Theme.panelTop + 10
            bottom: Theme.panelBottom
            left: 0
            right: 0
        }

        implicitWidth: screen ? screen.width : 1920

        implicitHeight:
            rect.height +
            Theme.panelTop +
            Theme.panelBottom

        color: "transparent"


        // ========================================================
        // BARY STARTUP GREETING
        // ========================================================

Process {
    id: startupNotification

    command: [
        "sh",
        "-c",
        "notify-send -a Bary 'Hello' \"Welcome, $USER\""
    ]

    Component.onCompleted: {
        running = true
    }
}


        Item {
            id: container

            anchors.fill: parent


            Rectangle {
                id: rect

                anchors.horizontalCenter: parent.horizontalCenter

                y: 0

                width: Theme.panelWidth

                implicitHeight: Theme.panelHeight
                height: implicitHeight

                color: Theme.panelBackground

                radius: Theme.radius

                topLeftRadius:
                    Theme.radiusTop !== undefined
                    ? Theme.radiusTop
                    : Theme.radius

                topRightRadius:
                    Theme.radiusTop !== undefined
                    ? Theme.radiusTop
                    : Theme.radius

                bottomLeftRadius:
                    Theme.radiusBottom !== undefined
                    ? Theme.radiusBottom
                    : Theme.radius

                bottomRightRadius:
                    Theme.radiusBottom !== undefined
                    ? Theme.radiusBottom
                    : Theme.radius

                clip: true

                layer.enabled: true
                layer.smooth: true


                // =================================================
                // WIDTH ANIMATION
                // =================================================

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }


                // =================================================
                // HOME
                // =================================================

                Home {
                    visible:
                        Main.currentPage === "homeClock" ||
                        Main.currentPage === "homeWork" ||
                        Main.currentPage === "homeStatus"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // NOTIFICATION
                // =================================================

                Notification {
                    visible:
                        Main.currentPage === "notify"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // AUDIO
                // =================================================

                Aduio {
                    visible:
                        Main.currentPage === "osdAduio"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                AduioMute {
                    visible:
                        Main.currentPage === "osdAudioMute"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                AduioUnmute {
                    visible:
                        Main.currentPage === "osdAudioUnmute"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // MICROPHONE
                // =================================================

                MicMute {
                    visible:
                        Main.currentPage === "osdMicMute"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                MicUnmute {
                    visible:
                        Main.currentPage === "osdMicUnmute"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // BRIGHTNESS
                // =================================================

                Brightness {
                    visible:
                        Main.currentPage === "osdBrightness"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // WALLPAPER SELECTOR
                // =================================================

                WallpaperSelector {
                    visible:
                        Main.currentPage === "wallPicker"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }


                // =================================================
                // WINDOW PREVIEW
                // =================================================

                WindowPreview {
                    visible:
                        Main.currentPage === "windowPreview"

                    anchors.fill: parent

                    anchors.margins:
                        Theme.panelPadding !== undefined
                        ? Theme.panelPadding
                        : 0
                }
            }
        }
    }


    // ========================================================
    // POWER WINDOW
    // ========================================================

    PanelWindow {
        id: powerWindow

        visible:
            Main.currentPage === "power"

        WlrLayershell.layer:
            WlrLayer.Top

        WlrLayershell.keyboardFocus:
            Main.currentPage === "power"
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        aboveWindows: true
        exclusiveZone: 0
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        margins {
            top: Theme.panelTop - 40
            bottom: Theme.panelBottom
            left: 0
            right: 0
        }

        implicitWidth: screen ? screen.width : 1920
        implicitHeight: screen ? screen.height : 1080


        Item {
            id: powerContainer

            width: Theme.panelWidth
            height: Theme.panelHeight

            anchors.horizontalCenter: parent.horizontalCenter

            y: -10

            Power {
                anchors.centerIn: parent
            }
        }
    }
}
