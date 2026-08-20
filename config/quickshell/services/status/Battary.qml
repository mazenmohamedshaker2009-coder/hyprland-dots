import QtQuick
import Quickshell
import Quickshell.Io
import "../.." 1.0

Item {
    Process {
        id: batteryProc

        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                Main.battary = text.trim() + "%"
            }
        }
    }
}
