import QtQuick
import "../" 1.0
import "../services/"
import "../modules/wallpaperSelector/"
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property string selectedWallpaper: ""

    signal wallpaperSelected(string path)

    Dispatch {}


    // =========================================================
    // SERVICES
    // =========================================================

    FolderList {
        id: folderList
    }

    WallpaperService {
        id: wallpaperService
    }


    // =========================================================
    // WALLPAPER GRID
    // =========================================================

    GridView {
        id: wallpaperGrid

        anchors.fill: parent

        anchors.leftMargin: 100
        anchors.topMargin: 40

        clip: true

        model: folderList.model

        cellWidth: 207.6
        cellHeight: 150.8

        boundsBehavior: Flickable.StopAtBounds


        // =====================================================
        // WALLPAPER CARD
        // =====================================================

        delegate: Item {
            id: wallpaperCard

            width: 173.6
            height: 116.8

            readonly property bool selected:
                root.selectedWallpaper === filePath

            property bool hovered: false


            // =================================================
            // IMAGE MASK
            // =================================================

            Rectangle {
                id: mask

                anchors.fill: parent

                radius: Theme.radius

                color: "white"

                visible: false
            }


            // =================================================
            // IMAGE
            // =================================================

            Image {
                id: wallpaperImage

                anchors.fill: parent

                source: fileUrl

                fillMode: Image.PreserveAspectCrop

                asynchronous: true

                cache: true

                visible: false
            }


            // =================================================
            // MASKED IMAGE
            // =================================================

            OpacityMask {
                anchors.fill: wallpaperImage

                source: wallpaperImage

                maskSource: mask
            }


            // =================================================
            // HOVER
            // =================================================

            Rectangle {
                anchors.fill: parent

                radius: Theme.radius

                color: Theme.text

                opacity:
                    wallpaperCard.hovered
                    ? 0.08
                    : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }


            // =================================================
            // SELECTED BORDER
            // =================================================

            Rectangle {
                anchors.fill: parent

                radius: Theme.radius

                color: "transparent"

                border.width:
                    wallpaperCard.selected
                    ? 3
                    : 0

                border.color:
                    Theme.text

                Behavior on border.width {
                    NumberAnimation {
                        duration: 120
                    }
                }
            }


            // =================================================
            // MOUSE
            // =================================================

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onEntered: {
                    wallpaperCard.hovered = true
                }

                onExited: {
                    wallpaperCard.hovered = false
                }

                onClicked: {

                    if (!filePath)
                        return

                    root.selectedWallpaper = filePath

                    root.wallpaperSelected(filePath)

                    wallpaperService.setWallpaper(filePath)
                }
            }
        }
    }
}