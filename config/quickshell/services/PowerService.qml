pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    function shutdown() {
        Quickshell.execDetached([
            "systemctl",
            "poweroff"
        ])
    }

    function reboot() {
        Quickshell.execDetached([
            "systemctl",
            "reboot"
        ])
    }

    function logout() {
        Quickshell.execDetached([
            "hyprctl",
            "dispatch",
            "hl.dsp.exit()"
        ])
    }
}
