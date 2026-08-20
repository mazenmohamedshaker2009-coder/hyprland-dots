import QtQuick
import Quickshell.Wayland
import "../../" 1.0

Item {
    id: root

    required property var toplevel

    // =========================================================
    // Active State
    //
    // TopView only works while Workspace Preview is active.
    // =========================================================

    visible:
     Main.workSpacePrevActive &&
        root.toplevel !== null


    // =========================================================
    // Live Window Capture
    // =========================================================

    ScreencopyView {

        anchors.fill:
            parent

        captureSource:
            root.toplevel

        live:
            Main.workSpacePrevActive
    }
}
