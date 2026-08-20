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
        target: "workDispatch"

        function workspaces() {

            console.log(
                "Dispatch: workspaces received"
            )

            root.dispatchWorkspaces()
        }
    }


    // =========================================================
    // Dispatch
    // =========================================================

    function dispatchWorkspaces() {

        console.log(
            "Dispatch: executing workspaces action"
        )


        if (
            Main.currentPage === "windowPreview"
        ) {

            // =============================================
            // Close Workspace Preview
            // =============================================

            Main.workSpacePrevActive = false

            ChangePage.changePage(
                Main.lastPage
            )

        } else {

            // =============================================
            // Open Workspace Preview
            // =============================================

            Main.workSpacePrevActive = true

            ChangePage.changePage(
                "windowPreview"
            )
        }
    }
}
