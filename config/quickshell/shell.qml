import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

import "." 1.0
import "components"
import "components/osd"
import "components/controlles"

ShellRoot {

    // ========================================================
    // MAIN BARY PANEL
    // ========================================================

    PanelWindow {
        id: root

        focusable: true
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


            // ========================================================
            // BARY MAIN PANEL BACKGROUND (Using ClippingRectangle & Corner Masks)
            // ========================================================
            
            ClippingRectangle {
                id: rect

                anchors.horizontalCenter: parent.horizontalCenter
                y: 0

                width: Theme.panelWidth
                implicitHeight: Theme.panelHeight
                height: implicitHeight

                color: Theme.panelBackground

                // تطبيق الزوايا السفلية العادية
                radius: Theme.radius !== undefined ? Theme.radius : 12

                layer.enabled: true
                layer.smooth: true


                // =================================================
                // INVERTED TOP CORNERS (الزوايا المقعرة العلوية)
                // =================================================

                // الزاوية المقعرة اليسرى العلوية
                Item {
                    width: 12
                    height: 12
                    x: 0
                    y: 0
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: root.color // نفس لون الشاشة الخلفي لتفريغ الزاوية
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                        }
                    }
                }

                // الزاوية المقعرة اليمنى العلوية
                Item {
                    width: 12
                    height: 12
                    anchors.right: parent.right
                    y: 0
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: root.color
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                        }
                    }
                }


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


                // =================================================
                // CONTROLL
                // =================================================

                Controll {
                    visible:
                        Main.currentPage === "control"

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


// ========================================================
// BLUETOOTH WINDOW
// ========================================================

PanelWindow {
    id: bluetoothWindow

    focusable: true

    visible:
        Main.bluetoothMenuShown &&
        Main.currentPage === "control"

    WlrLayershell.layer:
        WlrLayer.Top

    WlrLayershell.keyboardFocus:
        Main.currentPage === "bluetoothMenu"
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    implicitWidth: 340
    implicitHeight: 290

    anchors {
        top: true
        right: true
    }

    margins {
        top:
            Theme.panelTop * 0.6

        right:
            (
                screen
                ? screen.width -
                    (
                        (screen.width - Theme.panelWidth) *
                        1.2 -
                        0.4
                    )
                : 0
            )
    }

    Rectangle {
        anchors.fill: parent

        color:
            Theme.panelBackground

        radius:
            Theme.radius

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

        Bluetooth {
            anchors.fill: parent

            anchors.margins:
                Theme.panelPadding !== undefined
                ? Theme.panelPadding
                : 10
        }
    }
}
    // ========================================================
    // WIFI WINDOW
    // ========================================================

    PanelWindow {
        id: wifiWindow

        focusable: true 

        visible: Main.wifiMenuShown && Main.currentPage === "control" 

        WlrLayershell.layer:
            WlrLayer.Top

        WlrLayershell.keyboardFocus:
            Main.currentPage === "wifiMenu"
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        aboveWindows: true
        exclusiveZone: 0
        color: "transparent"

        implicitWidth: 340
        implicitHeight: 290

        anchors {
            top: true
            left: true
        }

        margins {
            top: Theme.panelTop * 0.6 
            left: (screen ? screen.width - ((screen.width - Theme.panelWidth) * 1.2 - 0.4) : 0)
        }


        Rectangle {
            anchors.fill: parent
            
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

            Wifi {
                anchors.fill: parent
                anchors.margins:
                    Theme.panelPadding !== undefined
                    ? Theme.panelPadding
                    : 10
            }
        }
    }
}
