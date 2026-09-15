import QtQuick
import Quickshell
import Quickshell.Io
import "../../" 1.0

Item {
    id: toggleService

    property bool isBluetoothActive: false
    property bool pendingBluetoothState: false

    Process {
        id: bluetoothToggleProcess

        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                toggleService.isBluetoothActive =
                    pendingBluetoothState

                if (!pendingBluetoothState)
                    Main.bluetoothMenuShown = false
            } else {
                toggleService.isBluetoothActive =
                    !pendingBluetoothState
            }
        }
    }

    Process {
        id: bluetoothInitCheck

        command: [
            "bluetoothctl",
            "show"
        ]

        running: true

        stdout: SplitParser {
            onRead: function(data) {
                var state = data.trim()

                if (state === "Powered: yes")
                    toggleService.isBluetoothActive = true
                else if (state === "Powered: no")
                    toggleService.isBluetoothActive = false
            }
        }
    }

    function toggleBluetooth() {
        pendingBluetoothState =
            !isBluetoothActive

        bluetoothToggleProcess.command = [
            "bluetoothctl",
            "power",
            pendingBluetoothState ? "on" : "off"
        ]

        bluetoothToggleProcess.running = true
    }
}
