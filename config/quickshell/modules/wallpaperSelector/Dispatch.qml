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
        target: "wallDispatch"

        function wallpapers() {
            console.log(
                "WallDispatch: wallpapers received"
            )

            root.dispatchWallpapers()
        }
    }

    // =========================================================
    // Dispatch
    // =========================================================

    function dispatchWallpapers() {
        console.log(
            "WallDispatch: executing wallpapers action"
        )

        if (Main.currentPage === "wallPicker") {

            // =================================================
            // Close wallpaper picker
            // =================================================

            ChangePage.changePage(
                Main.lastPage
            )

        } else {

            // =================================================
            // Open wallpaper picker
            // =================================================

            ChangePage.changePage(
                "wallPicker"
            )
        }
    }
}
