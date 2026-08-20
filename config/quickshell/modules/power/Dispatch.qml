import QtQuick
import Quickshell
import Quickshell.Io
import "../../" 1.0
import "../../js/ChangePage.js" as ChangePage

Item {
    id: root

    // =========================================================
    // IPC
    // =========================================================

    IpcHandler {
        target: "powerDispatch"

        function power() {
            console.log(
                "Dispatch: power received"
            )

            root.dispatchPower()
        }
    }


    // =========================================================
    // Dispatch
    // =========================================================

    function dispatchPower() {

        console.log(
            "Dispatch: executing power action"
        )

        if (
            Main.currentPage === "power"
        ) {

            // =============================================
            // Close Power Menu
            // =============================================

            ChangePage.changePage(
                Main.lastPage
            )

        } else {

            // =============================================
            // Open Power Menu
            // =============================================

            ChangePage.changePage(
                "power"
            )
        }
    }
}
