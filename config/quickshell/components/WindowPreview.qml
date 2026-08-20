import QtQuick
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../" 1.0
import "../services/"
import "../modules/workSpaces/"

Item {
    id: root

    width: 1200
    height: 500


    // =========================================================
    // Workspace Overview Active State
    //
    // Main.workSpacePrevActive controls whether the expensive
    // workspace preview UI exists at all.
    //
    // false:
    //     Loader destroys the complete workspace preview tree.
    //
    // true:
    //     Workspace preview tree is created and initialized.
    // =========================================================

    readonly property bool active:
        Main.workSpacePrevActive




            // =====================================================
            // Dispatch
            // =====================================================

            Dispatch {}




    // =========================================================
    // Drag Configuration
    // =========================================================

    readonly property real dragThreshold: 8


    // =========================================================
    // Workspace Preview
    // =========================================================

    Loader {

        id: workspaceLoader

        anchors.fill: parent

        active:
            root.active

        asynchronous:
            false

        sourceComponent:
            workspacePreviewComponent
    }


    // =========================================================
    // Workspace Preview Component
    // =========================================================

    Component {

        id: workspacePreviewComponent


        Item {

            id: previewRoot

            anchors.fill: parent


            // =====================================================
            // Workspace Grid
            // =====================================================

            GridView {

                id: workspaceGrid

                anchors.fill: parent

                anchors.leftMargin: 60
                anchors.topMargin: 20
                anchors.bottomMargin: 20

                clip: false

                model: 8

                cellWidth:
                    (width - anchors.leftMargin) / 4

                cellHeight:
                    height / 2

                interactive: false


                // =================================================
                // Workspace
                // =================================================

                delegate: Item {

                    id: workspacePreview


                    property int workspaceId:
                        index + 1


                    width:
                        workspaceGrid.cellWidth

                    height:
                        workspaceGrid.cellHeight


                    // =============================================
                    // Workspace Stacking
                    // =============================================

                    z:
                        DragManager.dragging &&
                        DragManager.sourceWorkspace ===
                            workspacePreview.workspaceId
                            ? 1000000
                            : 0


                    // =============================================
                    // Workspace Geometry
                    // =============================================

                    property real workspaceX:
                        x +
                        workspaceGrid.x +
                        workspaceBackground.x


                    property real workspaceY:
                        y +
                        workspaceGrid.y +
                        workspaceBackground.y


                    property real workspaceWidth:
                        workspaceBackground.width


                    property real workspaceHeight:
                        workspaceBackground.height


                    // =============================================
                    // Workspace Center
                    // =============================================

                    property real workspaceCenterX:
                        workspaceX +
                        workspaceWidth / 2


                    property real workspaceCenterY:
                        workspaceY +
                        workspaceHeight / 2


                    // =============================================
                    // Register Workspace Geometry
                    // =============================================

                    function registerDragGeometry() {

                        DragManager.registerWorkspace(

                            workspacePreview.workspaceId,

                            workspacePreview.workspaceX,

                            workspacePreview.workspaceY,

                            workspacePreview.workspaceWidth,

                            workspacePreview.workspaceHeight
                        )
                    }


                    // =============================================
                    // Geometry Updates
                    // =============================================

                    onXChanged:
                        registerDragGeometry()

                    onYChanged:
                        registerDragGeometry()

                    onWidthChanged:
                        registerDragGeometry()

                    onHeightChanged:
                        registerDragGeometry()


                    // =============================================
                    // Workspace Background
                    // =============================================

                    Rectangle {

                        id: workspaceBackground

                        anchors.fill: parent

                        anchors.margins: 8

                        radius: 24

                        z: 0

                        color: "transparent"

                        clip: true


                        // =========================================
                        // Wallpaper
                        // =========================================

                        Image {

                            id: workspaceWallpaper

                            anchors.fill: parent

                            source: "file://" + Quickshell.env("HOME")
                                + "/.config/quickshell/data/.wallpaper"

                            fillMode:
                                Image.PreserveAspectCrop

                            asynchronous: true

                            cache: true

                            smooth: true


                            // =====================================
                            // Rounded Wallpaper
                            // =====================================

                            layer.enabled: true

                            layer.effect:

                                OpacityMask {

                                    maskSource:

                                        Rectangle {

                                            width:
                                                workspaceWallpaper.width

                                            height:
                                                workspaceWallpaper.height

                                            radius:
                                                workspaceBackground.radius

                                            color:
                                                "white"
                                        }
                                }
                        }
                    }


                    // =============================================
                    // Workspace Click Area
                    // =============================================

                    MouseArea {

                        id: workspaceMouseArea

                        anchors.fill:
                            workspaceBackground

                        z: 50

                        hoverEnabled: true

                        acceptedButtons:
                            Qt.LeftButton

                        cursorShape:
                            containsMouse
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor


                        onClicked: {

                            root.focusWorkspace(
                                workspacePreview.workspaceId
                            )
                        }
                    }


                    // =============================================
                    // Initialization
                    // =============================================

                    Component.onCompleted: {

                        registerDragGeometry()


                        TopViewManager.setPreviewSize(

                            workspaceBackground.width,

                            workspaceBackground.height
                        )
                    }


                    // =============================================
                    // Windows Group
                    // =============================================

                    Item {

                        id: windowsGroup

                        anchors.fill:
                            workspaceBackground

                        z: 100


                        // =========================================
                        // Workspace Windows
                        // =========================================

                        property var workspaceWindows:

                            TopViewManager.windowsForWorkspace(

                                workspacePreview.workspaceId
                            )


                        // =========================================
                        // Render Windows
                        // =========================================

                        Repeater {

                            model:
                                windowsGroup.workspaceWindows


                            delegate: Item {

                                id: windowPreview


                                required property var modelData


                                // =================================
                                // Window Data
                                // =================================

                                property string windowAddress:
                                    String(modelData.address)


                                property int currentWorkspace:
                                    workspacePreview.workspaceId


                                property var windowToplevel:
                                    modelData.toplevel


                                // =================================
                                // Icon Data
                                // =================================

                                property string windowIcon:
                                    modelData.icon
                                        ? String(modelData.icon)
                                        : ""


                                // =================================
                                // Normal Geometry
                                // =================================

                                property real normalX:
                                    Number(modelData.x)


                                property real normalY:
                                    Number(modelData.y)


                                // =================================
                                // Mouse State
                                // =================================

                                property bool dragStarted:
                                    false


                                property real pressX:
                                    0


                                property real pressY:
                                    0


                                // =================================
                                // Drag State
                                // =================================

                                property bool isDraggedWindow:

                                    DragManager.dragging &&

                                    DragManager.draggedAddress ===
                                        windowPreview.windowAddress


                                // =================================
                                // Window Stacking
                                // =================================

                                z:

                                    isDraggedWindow
                                        ? 1000000000
                                        : 0


                                // =================================
                                // Window Geometry
                                // =================================

                                x:

                                    isDraggedWindow

                                        ? DragManager.draggedX -

                                          windowsGroup.mapToItem(
                                              previewRoot,
                                              0,
                                              0
                                          ).x

                                        : normalX


                                y:

                                    isDraggedWindow

                                        ? DragManager.draggedY -

                                          windowsGroup.mapToItem(
                                              previewRoot,
                                              0,
                                              0
                                          ).y

                                        : normalY


                                width:
                                    Number(modelData.width)


                                height:
                                    Number(modelData.height)


                                visible:
                                    modelData.toplevel !== null


                                // =================================
                                // Toplevel Container
                                // =================================

                                Item {

                                    id: toplevelContainer

                                    anchors.fill:
                                        parent

                                    z: 100


                                    // =================================
                                    // Real TopView
                                    // =================================

                                    TopView {

                                        id: topView

                                        anchors.fill:
                                            parent

                                        toplevel:
                                            windowPreview.windowToplevel

                                        z: 1000000


                                        // =============================
                                        // Rounded TopView
                                        // =============================

                                        layer.enabled: true

                                        layer.effect:

                                            OpacityMask {

                                                maskSource:

                                                    Rectangle {

                                                        width:
                                                            topView.width

                                                        height:
                                                            topView.height

                                                        radius:
                                                            10

                                                        color:
                                                            "white"
                                                    }
                                            }
                                    }


                                    // =================================
                                    // Application Icon
                                    // =================================

                                    Image {

                                        id: applicationIcon

                                        anchors.centerIn:
                                            parent

                                        width:
                                            Math.min(
                                                parent.width,
                                                parent.height
                                            ) * 0.22

                                        height:
                                            width

                                        source:
                                            windowPreview.windowIcon

                                        fillMode:
                                            Image.PreserveAspectFit

                                        asynchronous:
                                            true

                                        cache:
                                            true

                                        smooth:
                                            true

                                        visible:
                                            source !== "" &&
                                            status === Image.Ready

                                        z:
                                            1000001
                                    }


                                    // =================================
                                    // Hover Overlay
                                    // =================================

                                    Rectangle {

                                        id: hoverOverlay

                                        anchors.fill:
                                            parent

                                        radius:
                                            10

                                        color:
                                            "#FFFFFF"

                                        opacity:

                                            windowMouseArea.containsMouse
                                                ? 0.16
                                                : 0

                                        z:
                                            1000002


                                        Behavior on opacity {

                                            NumberAnimation {
                                                duration: 120
                                            }
                                        }
                                    }


                                    // =================================
                                    // Border
                                    // =================================

                                    Rectangle {

                                        id: windowBorder

                                        anchors.fill:
                                            parent

                                        color:
                                            "transparent"

                                        radius:
                                            10

                                        border.color:
                                            "#CCFFFFFF"

                                        border.width:
                                            2

                                        z:
                                            1000003
                                    }


                                    // =================================
                                    // Window Mouse Area
                                    // =================================

                                    MouseArea {

                                        id: windowMouseArea

                                        anchors.fill:
                                            parent

                                        hoverEnabled:
                                            true

                                        acceptedButtons:
                                            Qt.LeftButton

                                        preventStealing:
                                            true

                                        z:
                                            1000004


                                        // =============================
                                        // Cursor
                                        // =============================

                                        cursorShape:

                                            DragManager.dragging &&
                                            DragManager.draggedAddress ===
                                                windowPreview.windowAddress

                                                ? Qt.SizeAllCursor

                                                : containsMouse
                                                    ? Qt.PointingHandCursor
                                                    : Qt.ArrowCursor


                                        // =============================
                                        // PRESS
                                        // =============================

                                        onPressed:
                                            function(mouse) {

                                            windowPreview.dragStarted =
                                                false

                                            windowPreview.pressX =
                                                mouse.x

                                            windowPreview.pressY =
                                                mouse.y
                                        }


                                        // =============================
                                        // MOVE
                                        // =============================

                                        onPositionChanged:
                                            function(mouse) {

                                            if (!pressed)
                                                return


                                            if (
                                                !windowPreview.dragStarted
                                            ) {

                                                const dx =
                                                    mouse.x -
                                                    windowPreview.pressX

                                                const dy =
                                                    mouse.y -
                                                    windowPreview.pressY

                                                const distanceSquared =
                                                    dx * dx +
                                                    dy * dy


                                                if (
                                                    distanceSquared <
                                                    root.dragThreshold *
                                                    root.dragThreshold
                                                ) {
                                                    return
                                                }


                                                windowPreview.dragStarted =
                                                    true


                                                const mouseInRoot =
                                                    windowPreview.mapToItem(
                                                        previewRoot,
                                                        mouse.x,
                                                        mouse.y
                                                    )


                                                const windowInRoot =
                                                    windowPreview.mapToItem(
                                                        previewRoot,
                                                        0,
                                                        0
                                                    )


                                                const grabOffsetX =
                                                    mouseInRoot.x -
                                                    windowInRoot.x


                                                const grabOffsetY =
                                                    mouseInRoot.y -
                                                    windowInRoot.y


                                                DragManager.startDrag({

                                                    address:
                                                        windowPreview.windowAddress,

                                                    workspaceId:
                                                        windowPreview.currentWorkspace,

                                                    windowX:
                                                        windowInRoot.x,

                                                    windowY:
                                                        windowInRoot.y,

                                                    width:
                                                        windowPreview.width,

                                                    height:
                                                        windowPreview.height,

                                                    mouseX:
                                                        mouseInRoot.x,

                                                    mouseY:
                                                        mouseInRoot.y,

                                                    localMouseX:
                                                        grabOffsetX,

                                                    localMouseY:
                                                        grabOffsetY
                                                })
                                            }


                                            if (
                                                !windowPreview.dragStarted
                                            ) {
                                                return
                                            }


                                            if (
                                                !DragManager.dragging
                                            ) {
                                                return
                                            }


                                            if (
                                                DragManager.draggedAddress !==
                                                windowPreview.windowAddress
                                            ) {
                                                return
                                            }


                                            const mouseInRoot =
                                                windowPreview.mapToItem(
                                                    previewRoot,
                                                    mouse.x,
                                                    mouse.y
                                                )


                                            DragManager.updateDrag({

                                                mouseX:
                                                    mouseInRoot.x,

                                                mouseY:
                                                    mouseInRoot.y
                                            })
                                        }


                                        // =============================
                                        // RELEASE
                                        // =============================

                                        onReleased:
                                            function(mouse) {

                                            if (
                                                !windowPreview.dragStarted
                                            ) {

                                                root.focusWorkspace(

                                                    windowPreview.currentWorkspace
                                                )

                                                return
                                            }


                                            if (
                                                !DragManager.dragging
                                            ) {

                                                windowPreview.dragStarted =
                                                    false

                                                return
                                            }


                                            if (
                                                DragManager.draggedAddress !==
                                                windowPreview.windowAddress
                                            ) {

                                                windowPreview.dragStarted =
                                                    false

                                                return
                                            }


                                            const mouseInRoot =
                                                windowPreview.mapToItem(
                                                    previewRoot,
                                                    mouse.x,
                                                    mouse.y
                                                )


                                            DragManager.finishDrag({

                                                mouseX:
                                                    mouseInRoot.x,

                                                mouseY:
                                                    mouseInRoot.y
                                            })


                                            windowPreview.dragStarted =
                                                false
                                        }


                                        // =============================
                                        // CANCEL
                                        // =============================

                                        onCanceled: {

                                            if (
                                                DragManager.dragging &&
                                                DragManager.draggedAddress ===
                                                    windowPreview.windowAddress
                                            ) {

                                                DragManager.cancelDrag()
                                            }


                                            windowPreview.dragStarted =
                                                false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


            // =====================================================
            // HyprData -> TopViewManager Synchronization
            // =====================================================

            Timer {

                id:
                    hyprDataRefreshTimer

                interval:
                    50

                repeat:
                    false


                onTriggered: {

                    TopViewManager.refresh()
                }
            }


            // =====================================================
            // Listen To HyprData
            // =====================================================

            Connections {

                target:
                    HyprData


                // =================================================
                // Windows changed
                // =================================================

                function onWindowsChanged() {

                    hyprDataRefreshTimer.restart()
                }


                // =================================================
                // Address lookup changed
                // =================================================

                function onWindowByAddressChanged() {

                    hyprDataRefreshTimer.restart()
                }
            }


            // =====================================================
            // Update Preview Size
            // =====================================================

            function updatePreviewSize() {

                if (
                    workspaceGrid.width <= 0 ||
                    workspaceGrid.height <= 0
                ) {
                    return
                }


                const previewWidth =
                    workspaceGrid.cellWidth -
                    16


                const previewHeight =
                    workspaceGrid.cellHeight -
                    16


                TopViewManager.setPreviewSize(

                    previewWidth,

                    previewHeight
                )
            }


            // =====================================================
            // Preview Size Changes
            // =====================================================

            onWidthChanged: {
                updatePreviewSize()
            }


            onHeightChanged: {
                updatePreviewSize()
            }


            // =====================================================
            // Initial Preview Setup
            // =====================================================

            Component.onCompleted: {

                updatePreviewSize()


                Qt.callLater(() => {

                    TopViewManager.refresh()

                })
            }
        }
    }


    // =========================================================
    // Focus Workspace
    // =========================================================

    function focusWorkspace(workspaceId) {

        if (
            workspaceId === undefined ||
            workspaceId === null
        ) {
            return
        }


        const id =
            Number(workspaceId)


        if (
            !Number.isFinite(id) ||
            id < 1
        ) {
            return
        }


        focusProcess.command = [

            "hyprctl",

            "eval",

            "hl.dispatch(hl.dsp.focus({ workspace = " +
            String(id) +
            " }))"
        ]


        focusProcess.running =
            true
    }


    // =========================================================
    // Focus Process
    // =========================================================

    Process {

        id:
            focusProcess

        command:
            []


        stderr:

            StdioCollector {

                onStreamFinished: {

                    if (
                        text &&
                        text.trim() !== ""
                    ) {

                        console.log(
                            "Workspace focus error:",
                            text
                        )
                    }
                }
            }
    }
}
