import QtQuick
import Quickshell.Io

Item {
    id: manageConnection

    property string targetSsid: ""
    property string targetPassword: ""
    property bool targetIsSecured: false
    property var currentCallback: null

    function debug(message) {
        console.log("[BARY-MANAGE]", message)
    }

    function handleConnection(ssid, isSecured, password, callback) {
        targetSsid = ssid
        targetIsSecured = isSecured
        targetPassword = password || ""
        currentCallback = callback

        debug(
            "handleConnection:"
            + " ssid=[" + targetSsid + "]"
            + " secured=" + targetIsSecured
            + " passwordProvided="
            + (targetPassword !== "")
        )

        checkProcess.activeDevice = ""
        checkProcess.foundTarget = false
        checkProcess.errorOutput = ""

        checkProcess.running = false
        checkProcess.running = true
    }

    function connectNetwork() {
        if (
            targetIsSecured &&
            targetPassword === ""
        ) {
            debug(
                "Secured network with no password."
                + " Checking saved profile."
            )

            checkSavedNetwork()
            return
        }

        var command = [
            "nmcli",
            "--wait",
            "40",
            "device",
            "wifi",
            "connect",
            targetSsid
        ]

        if (targetIsSecured) {
            command.push("password")
            command.push(targetPassword)
        }

        debug(
            "Starting new Wi-Fi connection:"
            + " " + command.join(" ")
        )

        actionProcess.action = "connecting"
        actionProcess.errorOutput = ""
        actionProcess.stdoutOutput = ""

        actionProcess.running = false
        actionProcess.command = command
        actionProcess.running = true
    }

    function checkSavedNetwork() {
        savedNetworkOutput = ""
        savedNetworkError = ""

        savedNetworkProcess.running = false

        savedNetworkProcess.command = [
            "nmcli",
            "-g",
            "802-11-wireless.ssid",
            "connection",
            "show",
            targetSsid
        ]

        debug(
            "Checking saved profile:"
            + " nmcli -g 802-11-wireless.ssid connection show ["
            + targetSsid
            + "]"
        )

        savedNetworkProcess.running = true
    }

    function connectSavedNetwork() {
        var command = [
            "nmcli",
            "--wait",
            "40",
            "connection",
            "up",
            "id",
            targetSsid
        ]

        debug(
            "SAVED PROFILE FOUND"
        )

        debug(
            "Starting saved connection:"
            + " " + command.join(" ")
        )

        actionProcess.action = "connecting"
        actionProcess.errorOutput = ""
        actionProcess.stdoutOutput = ""

        actionProcess.running = false
        actionProcess.command = command
        actionProcess.running = true
    }

    function disconnectNetwork(device) {
        var command = [
            "nmcli",
            "device",
            "disconnect",
            device
        ]

        debug(
            "Disconnecting device ["
            + device
            + "]"
        )

        debug(
            "Command:"
            + " " + command.join(" ")
        )

        actionProcess.action = "disconnecting"
        actionProcess.errorOutput = ""
        actionProcess.stdoutOutput = ""

        actionProcess.running = false
        actionProcess.command = command
        actionProcess.running = true
    }

    function finish(success, message) {
        debug(
            "FINISH:"
            + " success=" + success
            + " message=[" + message + "]"
        )

        if (!currentCallback)
            return

        var callback = currentCallback

        currentCallback = null

        targetSsid = ""
        targetPassword = ""
        targetIsSecured = false

        callback(
            success,
            message
        )
    }

    property string savedNetworkOutput: ""
    property string savedNetworkError: ""

    Process {
        id: checkProcess

        property string activeDevice: ""
        property bool foundTarget: false
        property string errorOutput: ""

        command: [
            "nmcli",
            "-t",
            "-f",
            "ACTIVE,SSID,DEVICE",
            "device",
            "wifi"
        ]

        stdout: SplitParser {
            onRead: function(data) {
                debug(
                    "Active-check stdout:"
                    + " [" + data + "]"
                )

                var lines =
                    data.trim().split(/\r?\n/)

                for (
                    var i = 0;
                    i < lines.length;
                    i++
                ) {
                    var line =
                        lines[i].trim()

                    if (line === "")
                        continue

                    var parts =
                        line.split(":")

                    if (parts.length < 3)
                        continue

                    var active =
                        parts[0].trim()

                    var ssid =
                        parts[1].trim()

                    var device =
                        parts.slice(2)
                        .join(":")
                        .trim()

                    debug(
                        "Active-check parsed:"
                        + " active=[" + active + "]"
                        + " ssid=[" + ssid + "]"
                        + " device=[" + device + "]"
                    )

                    if (
                        active === "yes" &&
                        ssid === targetSsid
                    ) {
                        checkProcess.activeDevice =
                            device

                        checkProcess.foundTarget =
                            true

                        debug(
                            "TARGET IS CURRENTLY CONNECTED"
                        )
                    }
                }
            }
        }

        stderr: SplitParser {
            onRead: function(data) {
                checkProcess.errorOutput += data

                debug(
                    "Active-check stderr:"
                    + " [" + data + "]"
                )
            }
        }

        onExited: function(exitCode, exitStatus) {
            var device =
                checkProcess.activeDevice

            var foundTarget =
                checkProcess.foundTarget

            var error =
                checkProcess.errorOutput.trim()

            debug(
                "Active-check finished:"
                + " exitCode=" + exitCode
                + " exitStatus=" + exitStatus
            )

            if (error !== "") {
                debug(
                    "Active-check error:"
                    + " [" + error + "]"
                )
            }

            checkProcess.activeDevice = ""
            checkProcess.foundTarget = false
            checkProcess.errorOutput = ""

            if (
                exitCode === 0 &&
                foundTarget &&
                device !== ""
            ) {
                debug(
                    "Target is connected."
                    + " Disconnecting."
                )

                disconnectNetwork(device)
                return
            }

            debug(
                "Target is not connected."
                + " Connecting."
            )

            connectNetwork()
        }
    }

    Process {
        id: savedNetworkProcess

        running: false

        stdout: SplitParser {
            onRead: function(data) {
                savedNetworkOutput += data

                debug(
                    "Saved-profile stdout:"
                    + " [" + data + "]"
                )
            }
        }

        stderr: SplitParser {
            onRead: function(data) {
                savedNetworkError += data

                debug(
                    "Saved-profile stderr:"
                    + " [" + data + "]"
                )
            }
        }

        onExited: function(exitCode, exitStatus) {
            var output =
                savedNetworkOutput.trim()

            var error =
                savedNetworkError.trim()

            debug(
                "Saved-profile check finished:"
                + " exitCode=" + exitCode
                + " exitStatus=" + exitStatus
            )

            debug(
                "Saved-profile output:"
                + " [" + output + "]"
            )

            if (error !== "") {
                debug(
                    "Saved-profile error:"
                    + " [" + error + "]"
                )
            }

            savedNetworkOutput = ""
            savedNetworkError = ""

            if (
                exitCode === 0 &&
                output === targetSsid
            ) {
                debug(
                    "MATCH!"
                    + " Saved profile belongs to ["
                    + targetSsid
                    + "]"
                )

                connectSavedNetwork()
                return
            }

            debug(
                "NO SAVED PROFILE FOUND for ["
                + targetSsid
                + "]"
            )

            finish(
                false,
                "Password required"
            )
        }
    }

    Process {
        id: actionProcess

        property string action: ""
        property string errorOutput: ""
        property string stdoutOutput: ""

        stdout: SplitParser {
            onRead: function(data) {
                actionProcess.stdoutOutput += data

                debug(
                    "Action stdout:"
                    + " [" + data + "]"
                )
            }
        }

        stderr: SplitParser {
            onRead: function(data) {
                actionProcess.errorOutput += data

                debug(
                    "Action stderr:"
                    + " [" + data + "]"
                )
            }
        }

        onExited: function(exitCode, exitStatus) {
            var error =
                actionProcess.errorOutput.trim()

            var output =
                actionProcess.stdoutOutput.trim()

            debug(
                "Action finished:"
                + " action=[" + actionProcess.action + "]"
                + " exitCode=" + exitCode
                + " exitStatus=" + exitStatus
            )

            debug(
                "Action stdout:"
                + " [" + output + "]"
            )

            debug(
                "Action stderr:"
                + " [" + error + "]"
            )

            if (
                actionProcess.action ===
                "connecting"
            ) {
                if (exitCode === 0) {
                    debug(
                        "CONNECT SUCCESS"
                    )

                    finish(
                        true,
                        output !== ""
                        ? output
                        : "Connected Successfully"
                    )
                } else {
                    debug(
                        "CONNECT FAILED"
                    )

                    finish(
                        false,
                        error !== ""
                        ? error
                        : "Connection failed"
                    )
                }

                actionProcess.action = ""
                actionProcess.errorOutput = ""
                actionProcess.stdoutOutput = ""

                return
            }

            if (
                actionProcess.action ===
                "disconnecting"
            ) {
                if (exitCode === 0) {
                    debug(
                        "DISCONNECT SUCCESS"
                    )

                    finish(
                        true,
                        output !== ""
                        ? output
                        : "Disconnected Successfully"
                    )
                } else {
                    debug(
                        "DISCONNECT FAILED"
                    )

                    finish(
                        false,
                        error !== ""
                        ? error
                        : "Disconnection failed"
                    )
                }

                actionProcess.action = ""
                actionProcess.errorOutput = ""
                actionProcess.stdoutOutput = ""

                return
            }

            actionProcess.action = ""
            actionProcess.errorOutput = ""
            actionProcess.stdoutOutput = ""
        }
    }
}
