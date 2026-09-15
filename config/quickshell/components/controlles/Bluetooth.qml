import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../services/bluetooth"
import "../../" 1.0

Item {
id: bluetoothRoot

property string targetDevice: ""
property string actionType: ""
property string failureMessage: ""
property bool actionRunning: false

FetchService {
    id: bluetoothService
}

ManageConnection {
    id: manageService
}

property bool scanning:
    bluetoothService.scanning

function resetState() {
    targetDevice = ""
    actionType = ""
    failureMessage = ""
    actionRunning = false
}

function refreshDevices() {
    if (bluetoothService.scanning)
        return

    bluetoothService.refresh()
}

function handleDeviceClick(
    deviceName,
    deviceAddress,
    isConnected
) {
    if (bluetoothRoot.actionRunning)
        return

    if (bluetoothRoot.scanning)
        return

    targetDevice = deviceName

    actionType =
        isConnected
        ? "disconnecting"
        : "connecting"

    failureMessage = ""
    actionRunning = true

    manageService.handleConnection(
        deviceAddress,
        isConnected,
        function(success, message) {

            bluetoothRoot.refreshDevices()

            if (success) {
                bluetoothRoot.actionRunning = false

                bluetoothRoot.actionType = ""

                bluetoothRoot.failureMessage = ""

                refreshAfterActionTimer.restart()

                return
            }

            bluetoothRoot.actionRunning = false

            bluetoothRoot.actionType = "failed"

            bluetoothRoot.failureMessage =
                message || "Bluetooth action failed"

            refreshAfterActionTimer.restart()

            failTimer.restart()
        }
    )
}

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 20

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: "Bluetooth"
            color: "white"

            font.family:
                Theme.fontFamily !== undefined
                ? Theme.fontFamily
                : ""

            font.pixelSize: 24
            font.bold: true

            Layout.fillWidth: true
        }

        Item {
            width: 32
            height: 32

            Rectangle {
                anchors.fill: parent
                radius: 8

                color:
                    rescanMouseArea.containsMouse
                    ? Qt.rgba(1, 1, 1, 0.10)
                    : Qt.rgba(1, 1, 1, 0.04)

                visible:
                    !bluetoothRoot.scanning &&
                    !bluetoothRoot.actionRunning

                Image {
                    anchors.centerIn: parent

                    width: 18
                    height: 18

                    source:
                        "../../assets/icons/reload.svg"

                    fillMode:
                        Image.PreserveAspectFit

                    opacity:
                        rescanMouseArea.containsMouse
                        ? 1.0
                        : 0.75
                }

                MouseArea {
                    id: rescanMouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    enabled:
                        !bluetoothRoot.scanning &&
                        !bluetoothRoot.actionRunning

                    onClicked: {
                        bluetoothRoot.refreshDevices()
                    }
                }
            }

            Row {
                anchors.centerIn: parent

                spacing: 4

                visible:
                    bluetoothRoot.scanning ||
                    bluetoothRoot.actionRunning

                Repeater {
                    model: 3

                    delegate: Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5

                        color: "white"

                        opacity:
                            dotAnimation.currentIndex === index
                            ? 1.0
                            : 0.25
                    }
                }
            }

            Timer {
                id: dotAnimation

                property int currentIndex: 0

                interval: 180
                repeat: true

                running:
                    bluetoothRoot.scanning ||
                    bluetoothRoot.actionRunning

                onTriggered: {
                    currentIndex =
                        (currentIndex + 1) % 3
                }

                onRunningChanged: {
                    if (!running)
                        currentIndex = 0
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        visible:
            !bluetoothRoot.scanning &&
            !bluetoothRoot.actionRunning &&
            bluetoothService.model.count === 0

        Text {
            anchors.centerIn: parent

            text: "No Devices are found"

            color: "#888888"

            font.pixelSize: 16
        }
    }

    ListView {
        id: listView

        Layout.fillWidth: true
        Layout.fillHeight: true

        visible:
            bluetoothService.model.count > 0

        clip: true

        spacing: 12

        model:
            bluetoothService.model

        delegate: Rectangle {
            width:
                listView.width

            height: 55

            radius: 12

            color:
                mouseArea.containsMouse
                ? Qt.rgba(1, 1, 1, 0.08)
                : Qt.rgba(1, 1, 1, 0.04)

            RowLayout {
                anchors.fill: parent

                anchors.leftMargin: 15
                anchors.rightMargin: 15

                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: 3

                    Text {
                        text:
                            model.deviceName

                        color: "white"

                        font.pixelSize: 15

                        font.bold:
                            model.isConnected
                    }

                    Text {
                        text: {
                            var isTarget =
                                bluetoothRoot.targetDevice ===
                                model.deviceName

                            if (isTarget) {
                                if (
                                    bluetoothRoot.actionType ===
                                    "connecting"
                                ) {
                                    return "Connecting..."
                                }

                                if (
                                    bluetoothRoot.actionType ===
                                    "disconnecting"
                                ) {
                                    return "Disconnecting..."
                                }

                                if (
                                    bluetoothRoot.actionType ===
                                    "failed"
                                ) {
                                    return bluetoothRoot.failureMessage
                                }
                            }

                            return model.isConnected
                                ? "Connected"
                                : model.deviceStatus
                        }

                        color: {
                            var isTarget =
                                bluetoothRoot.targetDevice ===
                                model.deviceName

                            if (
                                isTarget &&
                                bluetoothRoot.actionType ===
                                "failed"
                            ) {
                                return "#ef4444"
                            }

                            if (
                                isTarget &&
                                (
                                    bluetoothRoot.actionType ===
                                    "connecting" ||
                                    bluetoothRoot.actionType ===
                                    "disconnecting"
                                )
                            ) {
                                return "#eab308"
                            }

                            return model.isConnected
                                ? "#22c55e"
                                : "#888888"
                        }

                        font.pixelSize: 11
                    }
                }

                Text {
                    text:
                        model.deviceSignal

                    color:
                        "#888888"

                    font.pixelSize: 14
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent

                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                enabled:
                    !bluetoothRoot.scanning &&
                    !bluetoothRoot.actionRunning

                onClicked: {
                    bluetoothRoot.handleDeviceClick(
                        model.deviceName,
                        model.deviceAddress,
                        model.isConnected
                    )
                }
            }
        }
    }
}

Timer {
    id: refreshAfterActionTimer

    interval: 150

    repeat: false

    onTriggered: {
        if (
            !bluetoothRoot.actionRunning &&
            !bluetoothRoot.scanning
        ) {
            bluetoothRoot.refreshDevices()
        }
    }
}

Timer {
    id: failTimer

    interval: 4000

    repeat: false

    onTriggered: {
        if (
            bluetoothRoot.actionType ===
            "failed"
        ) {
            bluetoothRoot.resetState()
        }
    }
}

}

