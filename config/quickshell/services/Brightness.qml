pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../" 1.0

Singleton {
    id: root

    property int value: 0
    property bool initialized: false

    signal changed(int value)

    // الخاصية الداخلية للإضاءة التي تُرجع قيمة الخاصية العامة من Main
    property bool brightnessInternalRequest: {
        return Main.brightnessInternalRequest;
    }

    function readValue() {
        console.log("[Brightness] brightnessInternalRequest:", root.brightnessInternalRequest);
        if (root.brightnessInternalRequest)
            return

        reader.running = true
    }

    Process {
        id: reader

        command: [
            "sh",
            "-c",
            "value=$(cat /sys/class/backlight/intel_backlight/brightness); " +
            "max=$(cat /sys/class/backlight/intel_backlight/max_brightness); " +
            "echo $((value * 100 / max))"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[Brightness Reader Stream] brightnessInternalRequest:", root.brightnessInternalRequest);
                if (root.brightnessInternalRequest)
                    return

                const newValue = parseInt(text.trim())

                if (isNaN(newValue))
                    return

                if (!root.initialized) {
                    root.value = newValue
                    root.initialized = true
                    return
                }

                if (newValue !== root.value) {
                    root.value = newValue
                    root.changed(newValue)
                }
            }
        }
    }

    Process {
        id: monitor

        command: [
            "udevadm",
            "monitor",
            "--udev",
            "--subsystem-match=backlight"
        ]

        stdout: SplitParser {
            onRead: data => {
                console.log("[Brightness Monitor] brightnessInternalRequest:", root.brightnessInternalRequest);
                if (root.brightnessInternalRequest)
                    return

                if (data.includes("intel_backlight"))
                    root.readValue()
            }
        }
    }

    Component.onCompleted: {
        root.readValue()
        monitor.running = true
    }
}
