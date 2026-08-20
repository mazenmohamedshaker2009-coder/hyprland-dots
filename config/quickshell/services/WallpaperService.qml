import QtQuick
import Quickshell.Io
import Quickshell

Item {
    id: root

    property string scriptPath:
    Quickshell.env("HOME") + "/.config/quickshell/scripts/set_wallpaper.sh"

    function setWallpaper(path) {

        console.log("Applying wallpaper:", path)

        wallpaperProcess.command = [
            "/usr/bin/bash",
            root.scriptPath,
            path
        ]

        wallpaperProcess.running = true
    }

    Process {
        id: wallpaperProcess

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.log("SCRIPT:", text)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.warn("SCRIPT ERROR:", text)
            }
        }
    }
}
