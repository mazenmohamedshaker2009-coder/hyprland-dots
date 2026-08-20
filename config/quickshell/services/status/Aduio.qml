import QtQuick
import Quickshell
import Quickshell.Io
import "../.." 1.0

Item {
    Process {
        id: aduioProc

        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                Main.aduio= text.trim() + "%"
            }
        }
    }
}
