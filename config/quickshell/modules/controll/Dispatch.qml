
import QtQuick
import Quickshell
import Quickshell.Io
import "../../" 1.0
import "../../js/ChangePage.js" as ChangePage

Item {
    id: root

    IpcHandler {
        target: "control"

        function control() {
            console.log(
                "Dispatch: control received"
            )

            root.dispatchControl()
        }
    }

    function dispatchControl() {

        console.log(
            "Dispatch: executing control action"
        )

        if (
            Main.currentPage === "control"
        ) {

            Main.wifiMenuShown = false
            Main.bluetoothMenuShown = false
            Main.audioInternalRequest = false
            Main.brightnessInternalRequest = false

            ChangePage.changePage(
                Main.lastPage
            )

        } else {

            Main.audioInternalRequest = true
            Main.brightnessInternalRequest = true

            ChangePage.changePage(
                "control"
            )
        }
    }
}
