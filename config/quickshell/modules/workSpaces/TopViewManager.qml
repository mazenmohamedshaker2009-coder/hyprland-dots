pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import "../../" 1.0

Singleton {
    id: root


    // =========================================================
    // Active State
    //
    // TopViewManager remains loaded as a Singleton,
    // but does not perform expensive work while inactive.
    // =========================================================

    readonly property bool active:
     Main.workSpacePrevActive


    // =========================================================
    // Public data
    // =========================================================

    /*
     * workspaceWindows[workspaceId] = [
     * {
     *     address,
     *     workspaceId,
     *     icon,
     *     toplevel,
     *     x,
     *     y,
     *     width,
     *     height
     * }
     * ]
     */
    property var workspaceWindows: ({})


    /*
     * أبعاد خلية الـ workspace داخل الـ Preview.
     */
    property real previewWidth: 0
    property real previewHeight: 0


    /*
     * Scale الحقيقي للنافذة داخل الـ Preview.
     */
    property real previewScale: 0.25


    // =========================================================
    // Set preview size
    // =========================================================

    function setPreviewSize(width, height) {

        if (!root.active)
            return


        if (width <= 0 || height <= 0)
            return


        root.previewWidth = width
        root.previewHeight = height


        root.rebuildGeometry()
    }


    // =========================================================
    // Get workspace windows
    // =========================================================

    function windowsForWorkspace(workspaceId) {

        if (!root.active)
            return []


        return root.workspaceWindows[workspaceId] || []
    }


    // =========================================================
    // Refresh process
    // =========================================================

    Process {
        id: clientsProcess

        command: [
            "hyprctl",
            "-j",
            "clients"
        ]


        stdout: StdioCollector {

            onStreamFinished: {

                /*
                 * Overview could have been closed while
                 * hyprctl was still running.
                 *
                 * Ignore the result.
                 */

                if (!root.active)
                    return


                if (
                    !text ||
                    text.trim() === ""
                ) {
                    return
                }


                let clients


                try {

                    clients =
                        JSON.parse(text)

                } catch (error) {

                    console.log(
                        "TopViewManager: JSON parse error:",
                        error
                    )

                    return
                }


                if (!Array.isArray(clients))
                    return


                root.processClients(clients)
            }
        }
    }


    // =========================================================
    // Raw window data
    // =========================================================

    property var sourceWindows: []


    // =========================================================
    // Process clients
    // =========================================================

    function processClients(clients) {

        if (!root.active)
            return


        if (!Array.isArray(clients))
            return


        const windows = []


        for (const client of clients) {

            if (!root.active)
                return


            const workspaceId =
                client.workspace?.id


            if (workspaceId === undefined)
                continue


            const address =
                normalizeAddress(
                    client.address
                )


            if (!address)
                continue


            const toplevel =
                findToplevel(address)


            if (!toplevel)
                continue


            // =================================================
            // Application Icon
            //
            // HyprData is the single source of truth.
            // =================================================

            const hyprWindow =
                HyprData.windowByAddress[address]


            const icon =
                hyprWindow &&
                hyprWindow.icon !== undefined &&
                hyprWindow.icon !== null
                    ? String(hyprWindow.icon)
                    : ""


            windows.push({

                address:
                    address,

                workspaceId:
                    workspaceId,

                icon:
                    icon,

                sourceX:
                    client.at?.[0] ?? 0,

                sourceY:
                    client.at?.[1] ?? 0,

                sourceWidth:
                    client.size?.[0] ?? 0,

                sourceHeight:
                    client.size?.[1] ?? 0,

                toplevel:
                    toplevel
            })
        }


        root.sourceWindows =
            windows


        root.rebuildGeometry()
    }


    // =========================================================
    // Find real Wayland Toplevel
    // =========================================================

    function findToplevel(address) {

        if (!root.active)
            return null


        const toplevels =
            ToplevelManager.toplevels.values


        for (const toplevel of toplevels) {

            if (!root.active)
                return null


            const hyprland =
                toplevel.HyprlandToplevel


            if (!hyprland)
                continue


            const topAddress =
                normalizeAddress(
                    hyprland.address
                )


            if (
                topAddress &&
                topAddress === address
            ) {

                return toplevel
            }
        }


        return null
    }


    // =========================================================
    // Normalize address
    // =========================================================

    function normalizeAddress(address) {

        if (!address)
            return ""


        let value =
            String(address).toLowerCase()


        if (!value.startsWith("0x"))
            value = "0x" + value


        return value
    }


    // =========================================================
    // Rebuild geometry
    // =========================================================

    function rebuildGeometry() {

        if (!root.active)
            return


        if (
            root.previewWidth <= 0 ||
            root.previewHeight <= 0
        ) {
            return
        }


        const grouped = {}


        // -----------------------------------------------------
        // Group windows by workspace
        // -----------------------------------------------------

        for (
            const window of root.sourceWindows
        ) {

            if (!root.active)
                return


            const id =
                window.workspaceId


            if (!grouped[id])
                grouped[id] = []


            grouped[id].push(window)
        }


        const result = {}


        // -----------------------------------------------------
        // Calculate each workspace independently
        // -----------------------------------------------------

        for (
            const workspaceId in grouped
        ) {

            if (!root.active)
                return


            const windows =
                grouped[workspaceId]


            if (windows.length === 0)
                continue


            let minX = Infinity
            let minY = Infinity

            let maxX = -Infinity
            let maxY = -Infinity


            // -------------------------------------------------
            // Bounding box
            // -------------------------------------------------

            for (
                const window of windows
            ) {

                minX =
                    Math.min(
                        minX,
                        window.sourceX
                    )


                minY =
                    Math.min(
                        minY,
                        window.sourceY
                    )


                maxX =
                    Math.max(
                        maxX,
                        window.sourceX +
                        window.sourceWidth
                    )


                maxY =
                    Math.max(
                        maxY,
                        window.sourceY +
                        window.sourceHeight
                    )
            }


            const sourceWidth =
                Math.max(
                    1,
                    maxX - minX
                )


            const sourceHeight =
                Math.max(
                    1,
                    maxY - minY
                )


            // -------------------------------------------------
            // Calculate scale
            // -------------------------------------------------

            const fitScale =
                Math.min(
                    root.previewWidth /
                    sourceWidth,

                    root.previewHeight /
                    sourceHeight
                )


            const scale =
                Math.min(
                    root.previewScale,
                    fitScale
                )


            const groupWidth =
                sourceWidth *
                scale


            const groupHeight =
                sourceHeight *
                scale


            const groupX =
                (
                    root.previewWidth -
                    groupWidth
                ) / 2


            const groupY =
                (
                    root.previewHeight -
                    groupHeight
                ) / 2


            // -------------------------------------------------
            // Final geometry
            // -------------------------------------------------

            result[workspaceId] =
                windows.map(window => {

                    return {

                        address:
                            window.address,

                        workspaceId:
                            window.workspaceId,

                        icon:
                            window.icon || "",

                        toplevel:
                            window.toplevel,

                        x:
                            groupX +
                            (
                                window.sourceX -
                                minX
                            ) * scale,

                        y:
                            groupY +
                            (
                                window.sourceY -
                                minY
                            ) * scale,

                        width:
                            window.sourceWidth *
                            scale,

                        height:
                            window.sourceHeight *
                            scale
                    }
                })
        }


        root.workspaceWindows =
            result
    }


    // =========================================================
    // Refresh
    // =========================================================

    function refresh() {

        /*
         * IMPORTANT:
         *
         * Never refresh while Overview is inactive.
         *
         * This prevents:
         *
         * - hyprctl process
         * - Hyprland.refreshToplevels()
         * - geometry rebuilding
         */

        if (!root.active)
            return


        /*
         * تحديث بيانات HyprlandToplevel.
         */

        Hyprland.refreshToplevels()


        /*
         * وبعدها نقرأ clients.
         */

        clientsProcess.running =
            true
    }


    // =========================================================
    // Workspace Preview Active State
    // =========================================================

    Connections {

        target:
            Main


        function onWorkSpacePrevActiveChanged() {

            /*
             * Overview opened.
             *
             * Load fresh data now.
             */

            if (
                Main.workSpacePrevActive
            ) {

                Qt.callLater(() => {

                    root.refresh()

                })

                return
            }


            /*
             * Overview closed.
             *
             * Stop expensive work.
             *
             * Clear preview data so old objects are not
             * kept alive unnecessarily.
             */

            root.workspaceWindows = {}
            root.sourceWindows = []
        }
    }


    // =========================================================
    // Hyprland events
    // =========================================================

    Connections {

        target:
            Hyprland


        function onRawEvent(event) {

            /*
             * Completely ignore Hyprland events while
             * Workspace Preview is inactive.
             */

            if (!root.active)
                return


            const name =
                event.name


            if (
                name === "openwindow" ||
                name === "openwindowv2" ||

                name === "closewindow" ||
                name === "closewindowv2" ||

                name === "movewindow" ||
                name === "movewindowv2" ||

                name === "changefloatingmode" ||

                name === "fullscreen" ||

                name === "workspace" ||
                name === "workspacev2"
            ) {

                root.refresh()
            }
        }
    }


    // =========================================================
    // Toplevel list changed
    // =========================================================

    Connections {

        target:
            ToplevelManager


        function onToplevelsChanged() {

            /*
             * Ignore changes while Overview is inactive.
             */

            if (!root.active)
                return


            /*
             * الـ Toplevel الحقيقي ممكن يظهر بعد
             * وصول حدث Hyprland مباشرة.
             *
             * لذلك نعيد المطابقة.
             */

            root.refresh()
        }
    }


    // =========================================================
    // Initial load
    // =========================================================

    Component.onCompleted: {

        if (!root.active) {

            return
        }


        Qt.callLater(() => {

            root.refresh()

        })
    }
}
