pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../" 1.0


Singleton {
    id: root


    // =========================================================
    // Drag State
    // =========================================================

    property bool dragging: false

    property string draggedAddress: ""

    property int sourceWorkspace: -1

    property int targetWorkspace: -1


    // =========================================================
    // Dragged Window Size
    // =========================================================

    property real draggedWidth: 0
    property real draggedHeight: 0


    // =========================================================
    // Mouse Position
    //
    // Coordinates are relative to WindowPreview root.
    // =========================================================

    property real mouseX: 0
    property real mouseY: 0


    // =========================================================
    // Grab Offset
    //
    // Exact point where the user grabbed the window.
    // =========================================================

    property real mouseOffsetX: 0
    property real mouseOffsetY: 0


    // =========================================================
    // Dragged Window Visual Position
    // =========================================================

    property real draggedX: 0
    property real draggedY: 0


    // =========================================================
    // Preview Geometry
    // =========================================================

    property real previewX: 0
    property real previewY: 0

    property real previewWidth: 0
    property real previewHeight: 0


    // =========================================================
    // Workspace Geometry
    //
    // workspaceGeometry[id] = {
    //     x,
    //     y,
    //     width,
    //     height,
    //     centerX,
    //     centerY
    // }
    // =========================================================

    property var workspaceGeometry: ({ })


    // =========================================================
    // Set Preview Geometry
    // =========================================================

    function setPreviewGeometry(
        x,
        y,
        width,
        height
    ) {

        root.previewX = Number(x)
        root.previewY = Number(y)

        root.previewWidth = Number(width)
        root.previewHeight = Number(height)
    }


    // =========================================================
    // Register Workspace
    // =========================================================

    function registerWorkspace(
        workspaceId,
        x,
        y,
        width,
        height
    ) {

        if (workspaceId === undefined)
            return


        const id =
            Number(workspaceId)

        const workspaceX =
            Number(x)

        const workspaceY =
            Number(y)

        const workspaceWidth =
            Number(width)

        const workspaceHeight =
            Number(height)


        let geometry =
            root.workspaceGeometry


        geometry[id] = {

            x: workspaceX,
            y: workspaceY,

            width: workspaceWidth,
            height: workspaceHeight,

            centerX:
                workspaceX +
                workspaceWidth / 2,

            centerY:
                workspaceY +
                workspaceHeight / 2
        }


        root.workspaceGeometry =
            Object.assign({}, geometry)
    }


    // =========================================================
    // Clear Workspaces
    // =========================================================

    function clearWorkspaces() {

        root.workspaceGeometry = {}
    }


    // =========================================================
    // Start Drag
    // =========================================================

    function startDrag(data) {

        if (!data)
            return

        if (!data.address)
            return


        const workspaceId =
            Number(data.workspaceId)

        const width =
            Number(data.width)

        const height =
            Number(data.height)

        const mouseX =
            Number(data.mouseX)

        const mouseY =
            Number(data.mouseY)

        const localMouseX =
            Number(data.localMouseX)

        const localMouseY =
            Number(data.localMouseY)

        const windowX =
            Number(data.windowX)

        const windowY =
            Number(data.windowY)


        if (
            !Number.isFinite(workspaceId) ||
            workspaceId < 1
        ) {
            return
        }


        if (
            !Number.isFinite(mouseX) ||
            !Number.isFinite(mouseY)
        ) {
            return
        }


        // -----------------------------------------------------
        // Store drag state.
        // -----------------------------------------------------

        root.dragging = true

        root.draggedAddress =
            String(data.address)

        root.sourceWorkspace =
            workspaceId

        root.draggedWidth =
            width

        root.draggedHeight =
            height


        // -----------------------------------------------------
        // Absolute mouse position.
        // -----------------------------------------------------

        root.mouseX =
            mouseX

        root.mouseY =
            mouseY


        // -----------------------------------------------------
        // Exact grab point inside window.
        // -----------------------------------------------------

        root.mouseOffsetX =
            localMouseX

        root.mouseOffsetY =
            localMouseY


        // -----------------------------------------------------
        // Initial window position.
        // -----------------------------------------------------

        root.draggedX =
            windowX

        root.draggedY =
            windowY


        // -----------------------------------------------------
        // Initial target.
        // -----------------------------------------------------

        root.targetWorkspace =
            root.findTargetWorkspace(
                root.mouseX,
                root.mouseY
            )
    }


    // =========================================================
    // Update Drag
    // =========================================================

    function updateDrag(data) {

        if (!root.dragging)
            return

        if (!data)
            return


        const newMouseX =
            Number(data.mouseX)

        const newMouseY =
            Number(data.mouseY)


        if (
            !Number.isFinite(newMouseX) ||
            !Number.isFinite(newMouseY)
        ) {
            return
        }


        // -----------------------------------------------------
        // Update absolute mouse position.
        // -----------------------------------------------------

        root.mouseX =
            newMouseX

        root.mouseY =
            newMouseY


        // -----------------------------------------------------
        // Move visual window.
        //
        // The original grab point remains under the cursor.
        // -----------------------------------------------------

        root.draggedX =
            root.mouseX -
            root.mouseOffsetX

        root.draggedY =
            root.mouseY -
            root.mouseOffsetY


        // -----------------------------------------------------
        // Detect target workspace.
        // -----------------------------------------------------

        root.targetWorkspace =
            root.findTargetWorkspace(
                root.mouseX,
                root.mouseY
            )
    }


    // =========================================================
    // Find Target Workspace
    // =========================================================

    function findTargetWorkspace(
        mouseX,
        mouseY
    ) {

        const px =
            Number(mouseX)

        const py =
            Number(mouseY)


        if (
            !Number.isFinite(px) ||
            !Number.isFinite(py)
        ) {
            return -1
        }


        let bestWorkspace = -1

        let bestDistance = Infinity


        const workspaces =
            root.workspaceGeometry


        for (const id in workspaces) {

            const workspace =
                workspaces[id]


            if (!workspace)
                continue


            // -------------------------------------------------
            // Pointer is inside workspace.
            // Highest priority.
            // -------------------------------------------------

            const inside =
                px >= workspace.x &&
                px <=
                    workspace.x +
                    workspace.width &&

                py >= workspace.y &&
                py <=
                    workspace.y +
                    workspace.height


            if (inside) {

                return Number(id)
            }


            // -------------------------------------------------
            // Otherwise find nearest workspace center.
            // -------------------------------------------------

            const dx =
                px -
                workspace.centerX

            const dy =
                py -
                workspace.centerY


            const distance =
                Math.sqrt(
                    dx * dx +
                    dy * dy
                )


            if (
                distance <
                bestDistance
            ) {

                bestDistance =
                    distance

                bestWorkspace =
                    Number(id)
            }
        }


        return bestWorkspace
    }


    // =========================================================
    // Finish Drag
    // =========================================================

    function finishDrag(data) {

        if (!root.dragging)
            return


        // -----------------------------------------------------
        // Update final mouse position.
        // -----------------------------------------------------

        if (data) {

            if (
                data.mouseX !== undefined
            ) {

                const finalX =
                    Number(data.mouseX)

                if (
                    Number.isFinite(finalX)
                ) {

                    root.mouseX =
                        finalX
                }
            }


            if (
                data.mouseY !== undefined
            ) {

                const finalY =
                    Number(data.mouseY)

                if (
                    Number.isFinite(finalY)
                ) {

                    root.mouseY =
                        finalY
                }
            }
        }


        // -----------------------------------------------------
        // Calculate final destination.
        // -----------------------------------------------------

        const destination =
            root.findTargetWorkspace(
                root.mouseX,
                root.mouseY
            )


        const source =
            root.sourceWorkspace


        const address =
            root.draggedAddress


        root.targetWorkspace =
            destination


        // -----------------------------------------------------
        // Stop visual drag immediately.
        // -----------------------------------------------------

        root.dragging = false


        // -----------------------------------------------------
        // Invalid destination.
        // -----------------------------------------------------

        if (
            destination < 1 ||
            source < 1 ||
            !address
        ) {

            root.targetWorkspace = -1

            root.resetDrag()

            return
        }


        // -----------------------------------------------------
        // Same workspace.
        // -----------------------------------------------------

        if (
            destination === source
        ) {

            root.targetWorkspace = -1

            root.resetDrag()

            return
        }


        // -----------------------------------------------------
        // Move actual Hyprland window.
        // -----------------------------------------------------

        root.moveWindow(
            address,
            destination
        )
    }


    // =========================================================
    // Cancel Drag
    // =========================================================

    function cancelDrag() {

        root.dragging = false

        root.targetWorkspace = -1

        root.resetDrag()
    }


    // =========================================================
    // Move Window
    //
    // Current Hyprland Lua backend syntax:
    //
    // hyprctl dispatch
    // "hl.dsp.window.move({
    //      workspace = 3,
    //      window = 'address:...',
    //      follow = false
    // })"
    //
    // `follow = false` keeps us on the current workspace.
    // =========================================================

    function moveWindow(
        address,
        workspaceId
    ) {

        if (!address)
            return

        const destination =
            Number(workspaceId)


        if (
            !Number.isFinite(destination) ||
            destination < 1
        ) {
            return
        }


        const selector =
            "address:" +
            String(address)


        const luaCommand =
            "hl.dsp.window.move({" +
            "workspace = " +
            String(destination) +
            ", window = '" +
            selector +
            "', follow = false" +
            "})"


        console.log(
            "DragManager: moving",
            selector,
            "to workspace",
            destination
        )


        moveProcess.command = [

            "hyprctl",

            "dispatch",

            luaCommand
        ]


        moveProcess.running = true
    }


    // =========================================================
    // Hyprland Move Process
    // =========================================================

    Process {

        id: moveProcess

        command: []


        stdout:
            StdioCollector {

                onStreamFinished: {

                    const output =
                        text
                            ? text.trim()
                            : ""


                    console.log(
                        "DragManager hyprctl:",
                        output
                    )


                    // -------------------------------------------------
                    // Give Hyprland a moment to update the clients.
                    // -------------------------------------------------

                    refreshTimer.restart()
                }
            }


        stderr:
            StdioCollector {

                onStreamFinished: {

                    const error =
                        text
                            ? text.trim()
                            : ""


                    if (error !== "") {

                        console.log(
                            "DragManager hyprctl error:",
                            error
                        )
                    }
                }
            }
    }


    // =========================================================
    // Refresh Timer
    // =========================================================

    Timer {

        id: refreshTimer

        interval:
            100

        repeat:
            false


        onTriggered: {

            console.log(
                "DragManager: refreshing TopViewManager"
            )


            // -----------------------------------------------------
            // Re-read Hyprland windows and rebuild preview data.
            // -----------------------------------------------------

            TopViewManager.refresh()


            // -----------------------------------------------------
            // Clear drag state after refresh request.
            // -----------------------------------------------------

            root.targetWorkspace =
                -1

            root.resetDrag()
        }
    }


    // =========================================================
    // Reset Drag State
    // =========================================================

    function resetDrag() {

        root.draggedAddress =
            ""

        root.sourceWorkspace =
            -1

        root.draggedWidth =
            0

        root.draggedHeight =
            0

        root.mouseX =
            0

        root.mouseY =
            0

        root.mouseOffsetX =
            0

        root.mouseOffsetY =
            0

        root.draggedX =
            0

        root.draggedY =
            0
    }
}
