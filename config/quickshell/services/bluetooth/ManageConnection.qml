import QtQuick
import Quickshell.Io

Item {
    id: manageConnection

    property string targetAddress: ""
    property bool targetIsConnected: false
    property var currentCallback: null

    function debug(message) {
        console.log(
            "[BARY-BLUETOOTH-MANAGE]",
            message
        )
    }

    function handleConnection(
        address,
        isConnected,
        callback
    ) {
        if (actionProcess.running) {
            debug(
                "Another Bluetooth action is already running."
            )

            if (callback) {
                callback(
                    false,
                    "Another Bluetooth action is already running"
                )
            }

            return
        }

        targetAddress = address
        targetIsConnected = isConnected
        currentCallback = callback

        debug(
            "handleConnection:"
            + " address=[" + targetAddress + "]"
            + " connected=" + targetIsConnected
        )

        if (
            targetAddress === ""
        ) {
            finish(
                false,
                "Invalid Bluetooth device address"
            )

            return
        }

        if (targetIsConnected)
            disconnectDevice()
        else
            connectDevice()
    }

    function connectDevice() {
        var command = [
            "bluetoothctl",
            "connect",
            targetAddress
        ]

        debug(
            "Connecting:"
            + " " + command.join(" ")
        )

        actionProcess.action = "connecting"
        actionProcess.errorOutput = ""
        actionProcess.stdoutOutput = ""

        actionProcess.command = command
        actionProcess.running = true
    }

    function disconnectDevice() {
        var command = [
            "bluetoothctl",
            "disconnect",
            targetAddress
        ]

        debug(
            "Disconnecting:"
            + " " + command.join(" ")
        )

        actionProcess.action = "disconnecting"
        actionProcess.errorOutput = ""
        actionProcess.stdoutOutput = ""

        actionProcess.command = command
        actionProcess.running = true
    }

    function finish(success, message) {
        debug(
            "FINISH:"
            + " success=" + success
            + " message=[" + message + "]"
        )

        var callback =
            currentCallback

        currentCallback = null

        targetAddress = ""
        targetIsConnected = false

        if (callback)
            callback(
                success,
                message
            )
    }

    Process {
        id: actionProcess

        running: false

        property string action: ""
        property string errorOutput: ""
        property string stdoutOutput: ""

        stdout: SplitParser {
            onRead: function(data) {
                actionProcess.stdoutOutput +=
                    data

                debug(
                    "Action stdout:"
                    + " [" + data + "]"
                )
            }
        }

        stderr: SplitParser {
            onRead: function(data) {
                actionProcess.errorOutput +=
                    data

                debug(
                    "Action stderr:"
                    + " [" + data + "]"
                )
            }
        }

        onExited: function(
            exitCode,
            exitStatus
        ) {
            var action =
                actionProcess.action

            var output =
                actionProcess.stdoutOutput.trim()

            var error =
                actionProcess.errorOutput.trim()

            debug(
                "Action finished:"
                + " action=[" + action + "]"
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

            if (action === "connecting") {
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
                        : output !== ""
                        ? output
                        : "Connection failed"
                    )
                }
            }

            else if (
                action ===
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
                        : output !== ""
                        ? output
                        : "Disconnection failed"
                    )
                }
            }

            else {
                finish(
                    false,
                    "Unknown Bluetooth action"
                )
            }

            actionProcess.action = ""
            actionProcess.errorOutput = ""
            actionProcess.stdoutOutput = ""
        }
    }
}

