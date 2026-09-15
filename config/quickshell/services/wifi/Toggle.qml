import QtQuick
import Quickshell
import Quickshell.Io
import "../../" 1.0

Item {
    id: toggleService

    property bool isWifiActive: false
    property bool pendingWifiState: false

    Process {
        id: wifiToggleProcess

        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                toggleService.isWifiActive = pendingWifiState

                if (!pendingWifiState)
                    Main.wifiMenuShown = false
            } else {
                toggleService.isWifiActive = !pendingWifiState
            }
        }
    }

    Process {
        id: wifiInitCheck

        command: [
            "nmcli",
            "radio",
            "wifi"
        ]

        running: true

        stdout: SplitParser {
            onRead: function(data) {
                var state = data.trim()

                if (state === "enabled")
                    toggleService.isWifiActive = true
                else if (state === "disabled")
                    toggleService.isWifiActive = false
            }
        }
    }

    function toggleWifi() {
        pendingWifiState = !isWifiActive

        wifiToggleProcess.command = [
            "nmcli",
            "radio",
            "wifi",
            pendingWifiState ? "on" : "off"
        ]

        wifiToggleProcess.running = true
    }
}
