import QtQuick
import Quickshell
import Quickshell.Io
import "../.." 1.0

Item {
id: root

property bool chargerStateKnown: false
property bool wasCharging: false

Process {
    id: batteryProc

    command: [
        "cat",
        "/sys/class/power_supply/BAT0/capacity"
    ]

    stdout: StdioCollector {
        onStreamFinished: {
            Main.battary = text.trim() + "%"
        }
    }
}

Process {
    id: chargingProc

    command: [
        "cat",
        "/sys/class/power_supply/BAT0/status"
    ]

    stdout: StdioCollector {
        onStreamFinished: {
            let status = text.trim()
            let isCharging = status === "Charging"

            if (isCharging) {
                Main.battary = "charging"
            } else {
                batteryProc.running = true
            }

            if (root.chargerStateKnown) {
                if (isCharging !== root.wasCharging) {
                    notifyProc.command = [
                        "notify-send",
                        isCharging
                            ? "Charger Connected"
                            : "Charger Disconnected",
                        isCharging
                            ? "Device charging."
                            : "Device not charging"
                    ]

                    notifyProc.running = true
                }
            }

            root.wasCharging = isCharging
            root.chargerStateKnown = true
        }
    }
}

Process {
    id: notifyProc

    command: [
        "notify-send",
        "",
        ""
    ]
}

Process {
    id: powerSupplyListener

    command: [
        "udevadm",
        "monitor",
        "--udev",
        "--subsystem-match=power_supply"
    ]

    running: true

    stdout: SplitParser {
        onRead: function(line) {
            if (line.indexOf("/BAT0") !== -1) {
                chargingProc.running = true
            }
        }
    }
}

Component.onCompleted: {
    chargingProc.running = true
}

}

