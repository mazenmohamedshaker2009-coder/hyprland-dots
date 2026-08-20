import QtQuick
import Qt.labs.folderlistmodel
import Quickshell

Item {
    id: root

    property url folder:
        "file://" + Quickshell.env("HOME") + "/Wallpapers"

    property alias model: wallpaperModel

    FolderListModel {
        id: wallpaperModel

        folder: root.folder

        showDirs: false
        showFiles: true

        nameFilters: [
            "*.png",
            "*.jpg",
            "*.jpeg",
            "*.webp",
            "*.PNG",
            "*.JPG",
            "*.JPEG",
            "*.WEBP"
        ]

        sortField: FolderListModel.Name
        sortReversed: false

        onStatusChanged: {
            console.log(
                "Wallpaper folder status:",
                status
            )
        }

        onCountChanged: {
            console.log(
                "Wallpaper count:",
                count
            )
        }
    }

    Component.onCompleted: {
        console.log(
            "Wallpaper folder:",
            root.folder
        )
    }
}