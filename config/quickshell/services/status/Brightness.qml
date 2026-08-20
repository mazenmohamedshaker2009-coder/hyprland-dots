import QtQuick
import Quickshell
import Quickshell.Io
import "../.." 1.0

Item {
    Process {
    id: brightnessProc

    command: ["sh", "-c", "brightnessctl -m | awk -F, '{print $4}'"]
    
    running: true

        stdout: StdioCollector {
            onStreamFinished: {
                Main.brightness = text.trim()
            }
        }
    }
}
