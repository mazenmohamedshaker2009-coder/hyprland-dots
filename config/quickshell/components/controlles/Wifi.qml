import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "../../services/wifi"
import "../../" 1.0

Item {
    id: wifiRoot

    property string targetSsid: ""
    property string actionType: ""
    property string failureMessage: ""

    property string pendingSsid: ""
    property bool pendingIsConnected: false
    property bool pendingIsSecured: false

    property bool scanning: false
    property int previousNetworkCount: 0

    FetchService {
        id: wifiService
    }

    ManageConnection {
        id: manageService
    }

    function resetState() {
        targetSsid = ""
        actionType = ""
        failureMessage = ""
    }

    function refreshNetworks() {
        scanning = true
        wifiRoot.previousNetworkCount = wifiService.model.count
        wifiService.refresh()
    }

    function startConnection(ssid, isConnected, isSecured, password) {
        targetSsid = ssid

        actionType =
            isConnected
            ? "disconnecting"
            : "connecting"

        failureMessage = ""

        manageService.handleConnection(
            ssid,
            isSecured,
            password,
            function(success, message) {
                if (success) {
                    resetState()
                    refreshNetworks()
                    return
                }

                actionType = "failed"
                failureMessage =
                    message || "Connection failed"

                failTimer.restart()
            }
        )
    }

    function handleNetworkClick(
        ssid,
        isConnected,
        isSecured
    ) {
        if (isConnected) {
            startConnection(
                ssid,
                true,
                isSecured,
                ""
            )

            return
        }

        if (!isSecured) {
            startConnection(
                ssid,
                false,
                false,
                ""
            )

            return
        }

        pendingSsid = ssid
        pendingIsConnected = isConnected
        pendingIsSecured = isSecured

        savedNetworkProcess.running = false

        savedNetworkProcess.command = [
            "nmcli",
            "-g",
            "802-11-wireless.ssid",
            "connection",
            "show",
            ssid
        ]

        savedNetworkProcess.running = true
    }

    Process {
        id: savedNetworkProcess
        running: false

        stdout: StdioCollector {
            id: savedNetworkCollector
        }

        onExited: function(exitCode, exitStatus) {
            var ssid = pendingSsid
            var isConnected = pendingIsConnected
            var isSecured = pendingIsSecured

            var output =
                savedNetworkCollector.text.trim()

            pendingSsid = ""
            pendingIsConnected = false
            pendingIsSecured = false

            if (
                exitCode === 0 &&
                output === ssid
            ) {
                startConnection(
                    ssid,
                    isConnected,
                    isSecured,
                    ""
                )
                return
            }

            var scriptPath =
                Qt.resolvedUrl(
                    "../../scripts/wifi_dialog.py"
                ).toString()

            if (scriptPath.startsWith("file://"))
                scriptPath =
                    scriptPath.substring(7)

            pendingSsid = ssid
            pendingIsConnected = isConnected
            pendingIsSecured = isSecured

            passwordProcess.running = false

            passwordProcess.command = [
                "python3",
                scriptPath,
                ssid
            ]

            passwordProcess.running = true
        }
    }

    Process {
        id: passwordProcess
        running: false

        stdout: StdioCollector {
            id: passwordCollector
        }

        onExited: function(exitCode, exitStatus) {
            var password =
                passwordCollector.text.trim()

            if (exitCode !== 0 || password === "") {
                pendingSsid = ""
                pendingIsConnected = false
                pendingIsSecured = false
                return
            }

            var ssid = pendingSsid
            var isConnected = pendingIsConnected
            var isSecured = pendingIsSecured

            pendingSsid = ""
            pendingIsConnected = false
            pendingIsSecured = false

            startConnection(
                ssid,
                isConnected,
                isSecured,
                password
            )
        }
    }

    Connections {
        target: wifiService.model

        function onCountChanged() {
            if (!wifiRoot.scanning)
                return

            if (
                wifiService.model.count !==
                wifiRoot.previousNetworkCount
            ) {
                wifiRoot.scanning = false
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Wi-Fi"
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

                    visible: !wifiRoot.scanning

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

                        onClicked: {
                            wifiRoot.refreshNetworks()
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    visible: wifiRoot.scanning

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
                    running: wifiRoot.scanning

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
                wifiService.model.count === 0

            Text {
                anchors.centerIn: parent
                text: "No Networks are found"
                color: "#888888"
                font.pixelSize: 16
            }
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible:
                wifiService.model.count > 0

            clip: true
            spacing: 12
            model: wifiService.model

            delegate: Rectangle {
                width: listView.width
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

                        RowLayout {
                            spacing: 8

                            Text {
                                text: model.netName
                                color: "white"
                                font.pixelSize: 15
                                font.bold:
                                    model.isConnected
                            }
                        }

                        Text {
                            text: {
                                var isTarget =
                                    wifiRoot.targetSsid ===
                                    model.netName

                                if (isTarget) {
                                    if (
                                        wifiRoot.actionType ===
                                        "connecting"
                                    ) {
                                        return "Connecting..."
                                    }

                                    if (
                                        wifiRoot.actionType ===
                                        "disconnecting"
                                    ) {
                                        return "Disconnecting..."
                                    }

                                    if (
                                        wifiRoot.actionType ===
                                        "failed"
                                    ) {
                                        return wifiRoot.failureMessage
                                    }
                                }

                                return model.isConnected
                                    ? "Connected"
                                    : model.netStatus
                            }

                            color: {
                                var isTarget =
                                    wifiRoot.targetSsid ===
                                    model.netName

                                if (
                                    isTarget &&
                                    wifiRoot.actionType ===
                                    "failed"
                                ) {
                                    return "#ef4444"
                                }

                                if (
                                    isTarget &&
                                    (
                                        wifiRoot.actionType ===
                                        "connecting" ||
                                        wifiRoot.actionType ===
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
                        text: model.netStrength
                        color: "#888888"
                        font.pixelSize: 14
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        var status =
                            (model.netStatus || "")
                            .toLowerCase()

                        var isSecured =
                            status.includes("sec") ||
                            status.includes("lock") ||
                            status.includes("wpa") ||
                            status.includes("wep") ||
                            status === "secured"

                        wifiRoot.handleNetworkClick(
                            model.netName,
                            model.isConnected,
                            isSecured
                        )
                    }
                }
            }
        }
    }

    Timer {
        id: failTimer

        interval: 4000
        repeat: false

        onTriggered: {
            if (
                wifiRoot.actionType ===
                "failed"
            ) {
                wifiRoot.resetState()
            }
        }
    }
}
