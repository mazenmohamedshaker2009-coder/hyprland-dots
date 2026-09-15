import QtQuick
import Quickshell.Io
import "../../" 1.0

Item {
id: fetchService

property string connectedDeviceName: ""
property bool isConnected: false
property alias model: bluetoothModel
property string rawOutput: ""
property bool scanning: false

property var pendingAddresses: []
property int pendingIndex: 0

property int verificationAttempt: 0
property int maxVerificationAttempts: 5
property int verificationInterval: 120

property string verificationAddress: ""
property bool verificationExpectedConnected: false
property bool verificationActive: false

ListModel {
    id: bluetoothModel
}

Process {
    id: scanProcess

    running: false

    command: [
        "bluetoothctl",
        "--timeout",
        "3",
        "scan",
        "on"
    ]

    onExited: function(exitCode, exitStatus) {
        fetchService.startDeviceList()
    }
}

Process {
    id: deviceProcess

    running: false

    property string output: ""

    stdout: SplitParser {
        onRead: function(data) {
            deviceProcess.output += data + "\n"
        }
    }

    onExited: function(exitCode, exitStatus) {
        var output =
            deviceProcess.output

        deviceProcess.output = ""

        if (exitCode !== 0) {
            fetchService.finishRefresh()

            return
        }

        fetchService.parseDevices(output)
    }
}

Process {
    id: infoProcess

    running: false

    property string targetAddress: ""
    property string infoOutput: ""

    stdout: SplitParser {
        onRead: function(data) {
            infoProcess.infoOutput +=
                data + "\n"
        }
    }

    onExited: function(exitCode, exitStatus) {
        var address =
            infoProcess.targetAddress

        var output =
            infoProcess.infoOutput

        infoProcess.infoOutput = ""
        infoProcess.targetAddress = ""

        if (exitCode === 0) {
            fetchService.applyDeviceInfo(
                address,
                output
            )
        }

        fetchService.processNextDevice()
    }
}

Process {
    id: verificationProcess

    running: false

    property string output: ""

    stdout: SplitParser {
        onRead: function(data) {
            verificationProcess.output +=
                data + "\n"
        }
    }

    onExited: function(exitCode, exitStatus) {
        var output =
            verificationProcess.output

        verificationProcess.output = ""

        if (exitCode !== 0) {
            fetchService.retryVerification()

            return
        }

        var connected =
            fetchService.parseConnectedState(
                output
            )

        if (
            connected ===
            fetchService.verificationExpectedConnected
        ) {
            fetchService.verificationActive = false

            fetchService.applyDeviceInfo(
                fetchService.verificationAddress,
                output
            )

            fetchService.updateConnectionState()

            fetchService.scanning = false

            return
        }

        fetchService.retryVerification()
    }
}

Timer {
    id: verificationTimer

    interval:
        fetchService.verificationInterval

    repeat: false

    onTriggered: {
        fetchService.runVerification()
    }
}

function refresh() {
    if (scanning)
        return

    if (scanProcess.running)
        return

    if (deviceProcess.running)
        return

    if (infoProcess.running)
        return

    if (verificationProcess.running)
        return

    verificationTimer.stop()

    verificationActive = false
    verificationAddress = ""
    verificationAttempt = 0

    scanning = true

    rawOutput = ""

    scanProcess.running = true
}

function refreshFast() {
    if (scanning)
        return

    if (scanProcess.running)
        return

    if (deviceProcess.running)
        return

    if (infoProcess.running)
        return

    if (verificationProcess.running)
        return

    verificationTimer.stop()

    verificationActive = false
    verificationAddress = ""
    verificationAttempt = 0

    scanning = true

    startDeviceList()
}

function refreshAfterAction(
    address,
    expectedConnected
) {
    if (!address)
        return

    verificationAddress = address
    verificationExpectedConnected =
        expectedConnected

    verificationAttempt = 0
    verificationActive = true

    verificationTimer.stop()

    if (
        scanProcess.running ||
        deviceProcess.running ||
        infoProcess.running ||
        verificationProcess.running
    ) {
        return
    }

    scanning = true

    runVerification()
}

function startDeviceList() {
    if (deviceProcess.running)
        return

    deviceProcess.output = ""

    deviceProcess.command = [
        "bluetoothctl",
        "devices"
    ]

    deviceProcess.running = true
}

function parseDevices(output) {
    var trimmed =
        output.trim()

    if (trimmed === "") {
        bluetoothModel.clear()

        pendingAddresses = []
        pendingIndex = 0

        connectedDeviceName = ""
        isConnected = false

        finishRefresh()

        return
    }

    var lines =
        trimmed.split(/\r?\n/)

    var devices = {}

    for (
        var i = 0;
        i < lines.length;
        i++
    ) {
        var line =
            lines[i].trim()

        if (!line)
            continue

        if (!line.startsWith("Device "))
            continue

        var parts =
            line.split(" ")

        if (parts.length < 3)
            continue

        var address =
            parts[1]

        var name =
            parts.slice(2)
                .join(" ")
                .trim()

        if (!address || !name)
            continue

        devices[address] = {
            deviceName: name,
            deviceAddress: address,
            deviceStatus: "available",
            deviceSignal: "--",
            isConnected: false
        }
    }

    var result =
        Object.values(devices)

    bluetoothModel.clear()

    pendingAddresses = []
    pendingIndex = 0

    for (
        var j = 0;
        j < result.length;
        j++
    ) {
        bluetoothModel.append(
            result[j]
        )

        pendingAddresses.push(
            result[j].deviceAddress
        )
    }

    connectedDeviceName = ""
    isConnected = false

    processNextDevice()
}

function processNextDevice() {
    if (infoProcess.running)
        return

    if (
        pendingIndex >=
        pendingAddresses.length
    ) {
        updateConnectionState()

        if (verificationActive) {
            verificationTimer.restart()
            return
        }

        finishRefresh()

        return
    }

    var address =
        pendingAddresses[pendingIndex]

    pendingIndex++

    infoProcess.targetAddress =
        address

    infoProcess.infoOutput = ""

    infoProcess.command = [
        "bluetoothctl",
        "info",
        address
    ]

    infoProcess.running = true
}

function applyDeviceInfo(
    address,
    output
) {
    var connected = false
    var paired = false
    var signal = "--"
    var name = ""

    var lines =
        output.trim()
            .split(/\r?\n/)

    for (
        var i = 0;
        i < lines.length;
        i++
    ) {
        var line =
            lines[i].trim()

        if (!line)
            continue

        if (line.startsWith("Name:")) {
            name =
                line.substring(5).trim()
        }

        if (
            line ===
            "Connected: yes"
        ) {
            connected = true
        }

        if (
            line ===
            "Paired: yes"
        ) {
            paired = true
        }

        if (
            line.startsWith("RSSI:")
        ) {
            var rssi =
                parseInt(
                    line.substring(5)
                        .trim()
                )

            if (!isNaN(rssi))
                signal =
                    rssi + " dBm"
        }
    }

    var index = -1

    for (
        var j = 0;
        j < bluetoothModel.count;
        j++
    ) {
        if (
            bluetoothModel.get(j)
                .deviceAddress ===
            address
        ) {
            index = j
            break
        }
    }

    if (index === -1)
        return

    if (name !== "") {
        bluetoothModel.setProperty(
            index,
            "deviceName",
            name
        )
    }

    bluetoothModel.setProperty(
        index,
        "deviceSignal",
        signal
    )

    bluetoothModel.setProperty(
        index,
        "isConnected",
        connected
    )

    bluetoothModel.setProperty(
        index,
        "deviceStatus",
        connected
            ? "connected"
            : paired
                ? "paired"
                : "available"
    )
}

function parseConnectedState(
    output
) {
    var lines =
        output.trim()
            .split(/\r?\n/)

    for (
        var i = 0;
        i < lines.length;
        i++
    ) {
        var line =
            lines[i].trim()

        if (
            line ===
            "Connected: yes"
        ) {
            return true
        }

        if (
            line ===
            "Connected: no"
        ) {
            return false
        }
    }

    return false
}

function runVerification() {
    if (!verificationActive)
        return

    if (verificationProcess.running)
        return

    if (
        verificationAddress === ""
    ) {
        verificationActive = false
        finishRefresh()
        return
    }

    if (
        verificationAttempt >=
        maxVerificationAttempts
    ) {
        verificationActive = false

        updateConnectionState()

        scanning = false

        return
    }

    verificationAttempt++

    verificationProcess.output = ""

    verificationProcess.command = [
        "bluetoothctl",
        "info",
        verificationAddress
    ]

    verificationProcess.running = true
}

function retryVerification() {
    if (!verificationActive)
        return

    if (
        verificationAttempt >=
        maxVerificationAttempts
    ) {
        verificationActive = false

        updateConnectionState()

        scanning = false

        return
    }

    verificationTimer.restart()
}

function updateConnectionState() {
    connectedDeviceName = ""
    isConnected = false

    for (
        var i = 0;
        i < bluetoothModel.count;
        i++
    ) {
        var device =
            bluetoothModel.get(i)

        if (device.isConnected) {
            connectedDeviceName =
                device.deviceName

            isConnected = true

            break
        }
    }
}

function finishRefresh() {
    verificationTimer.stop()

    verificationActive = false

    updateConnectionState()

    scanning = false
}

Component.onCompleted: {
    refresh()
}

}

