import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services"
import "../services/wifi"
import "../services/bluetooth"
import "../services/status/"
import "../modules/controll/"
import "../" 1.0

Item {
    id: root

    readonly property color controlTint:
        Theme.controllColor

    Dispatch {}

    Toggle {
        id: toggleService
    }

    ToggleService {
        id: bluetoothToggleService
    }

    ManageAudioService {
        id: audioService
    }

    ManageBrightnessService {
        id: brightnessService
    }

    Battary {
        id: batteryService
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            spacing: 8

            RowLayout {
                Layout.alignment:
                    Qt.AlignLeft |
                    Qt.AlignVCenter

                spacing: 8

                Text {
                    id: clockText

                    SystemClock {
                        id: clock
                        precision: SystemClock.Minutes
                    }

                    color:
                        Theme.text

                    font.family:
                        Theme.fontFamily

                    font.pixelSize:
                        Theme.fontSizeM

                    font.bold:
                        true

                    text:
                        Qt.formatDateTime(
                            clock.date,
                            "hh:mm"
                        )
                }

                Text {
                    id: dateText

                    color:
                        Qt.alpha(
                            Theme.text,
                            0.5
                        )

                    font.family:
                        Theme.fontFamily

                    font.pixelSize:
                        Theme.fontSizeXS

                    font.weight:
                        Font.Light

                    text:
                        Qt.formatDateTime(
                            clock.date,
                            "ddd, dd MMM"
                        )
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment:
                    Qt.AlignRight |
                    Qt.AlignVCenter

                spacing: 6

                Image {
                    id: batteryIcon

                    width: 20
                    height: 20

                    fillMode:
                        Image.PreserveAspectFit

                    source: {
                        if (Main.battary === "charging")
                            return "../assets/icons/battery-charging.svg"

                        let value =
                            parseInt(
                                Main.battary
                                    .replace("%", "")
                            )

                        if (isNaN(value))
                            return "../assets/icons/battery-empty.svg"

                        if (value > 60)
                            return "../assets/icons/battery-full.svg"

                        if (value > 25)
                            return "../assets/icons/battery-half.svg"

                        return "../assets/icons/battery-empty.svg"
                    }
                }

                Text {
                    id: batteryText

                    visible:
                        Main.battary !== "charging"

                    color:
                        Theme.text

                    font.family:
                        Theme.fontFamily

                    font.pixelSize:
                        Theme.fontSizeXS

                    font.bold:
                        true

                    text:
                        Main.battary
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                id: wifiRect

                Layout.fillWidth: true
                Layout.preferredHeight: 70

                color:
                    isFlashing
                    ? (
                        flashState
                        ? Qt.lighter(
                            root.controlTint,
                            1.05
                        )
                        : Qt.alpha(
                            root.controlTint,
                            0.65
                        )
                    )
                    : (
                        !toggleService.isWifiActive
                        ? Qt.alpha(
                            root.controlTint,
                            0.35
                        )
                        : (
                            wifiMouse.containsMouse
                            ? Qt.lighter(
                                root.controlTint,
                                1.03
                            )
                            : root.controlTint
                        )
                    )

                radius: 20

                property bool isFlashing: false
                property bool flashState: false

                SequentialAnimation {
                    id: flashAnimation

                    running: false
                    loops: 4

                    PropertyAction {
                        target: wifiRect
                        property: "isFlashing"
                        value: true
                    }

                    NumberAnimation {
                        target: wifiRect
                        property: "flashState"
                        from: 0
                        to: 1
                        duration: 150
                    }

                    NumberAnimation {
                        target: wifiRect
                        property: "flashState"
                        from: 1
                        to: 0
                        duration: 150
                    }

                    onFinished: {
                        wifiRect.isFlashing = false
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                MouseArea {
                    id: wifiMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    acceptedButtons:
                        Qt.LeftButton |
                        Qt.RightButton

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        if (
                            mouse.button ===
                            Qt.RightButton
                        ) {
                            Main.wifiMenuShown =
                                !Main.wifiMenuShown
                            return
                        }

                        flashAnimation.restart()
                        toggleService.toggleWifi()
                    }
                }

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        radius:
                            width / 2

                        color:
                            Qt.alpha(
                                Theme.text,
                                0.18
                            )

                        Image {
                            source:
                                "../assets/icons/wifi.svg"

                            anchors.centerIn:
                                parent

                            width: 20
                            height: 20

                            fillMode:
                                Image.PreserveAspectFit
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text:
                                "Wi-Fi"

                            color:
                                !toggleService.isWifiActive
                                ? Theme.text
                                : Qt.alpha(
                                    Theme.background,
                                    0.95
                                )

                            font.family:
                                Theme.fontFamily

                            font.pixelSize:
                                16

                            font.bold:
                                true
                        }

                        Text {
                            text:
                                toggleService.isWifiActive
                                ? "connected"
                                : "disabled"

                            color:
                                !toggleService.isWifiActive
                                ? Theme.text
                                : Qt.alpha(
                                    Theme.background,
                                    0.65
                                )

                            font.family:
                                Theme.fontFamily

                            font.pixelSize:
                                11
                        }
                    }
                }
            }

            Rectangle {
                id: btRect

                Layout.fillWidth: true
                Layout.preferredHeight: 70

                color:
                    isFlashing
                    ? (
                        flashState
                        ? Qt.lighter(
                            root.controlTint,
                            1.05
                        )
                        : Qt.alpha(
                            root.controlTint,
                            0.65
                        )
                    )
                    : (
                        !bluetoothToggleService.isBluetoothActive
                        ? Qt.alpha(
                            root.controlTint,
                            0.35
                        )
                        : (
                            btMouse.containsMouse
                            ? Qt.lighter(
                                root.controlTint,
                                1.03
                            )
                            : root.controlTint
                        )
                    )

                radius: 20

                property bool isFlashing: false
                property bool flashState: false

                SequentialAnimation {
                    id: bluetoothFlashAnimation

                    running: false
                    loops: 4

                    PropertyAction {
                        target: btRect
                        property: "isFlashing"
                        value: true
                    }

                    NumberAnimation {
                        target: btRect
                        property: "flashState"
                        from: 0
                        to: 1
                        duration: 150
                    }

                    NumberAnimation {
                        target: btRect
                        property: "flashState"
                        from: 1
                        to: 0
                        duration: 150
                    }

                    onFinished: {
                        btRect.isFlashing = false
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                MouseArea {
                    id: btMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    acceptedButtons:
                        Qt.LeftButton |
                        Qt.RightButton

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        if (
                            mouse.button ===
                            Qt.RightButton
                        ) {
                            Main.bluetoothMenuShown =
                                !Main.bluetoothMenuShown
                            return
                        }

                        bluetoothFlashAnimation.restart()
                        bluetoothToggleService.toggleBluetooth()
                    }
                }

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        radius:
                            width / 2

                        color:
                            Qt.alpha(
                                Theme.text,
                                0.18
                            )

                        Image {
                            source:
                                "../assets/icons/bluetooth.svg"

                            anchors.centerIn:
                                parent

                            width: 20
                            height: 20

                            fillMode:
                                Image.PreserveAspectFit
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text:
                                "Bluetooth"

                            color:
                                !bluetoothToggleService.isBluetoothActive
                                ? Theme.text
                                : Qt.alpha(
                                    Theme.background,
                                    0.95
                                )

                            font.family:
                                Theme.fontFamily

                            font.pixelSize:
                                16

                            font.bold:
                                true
                        }

                        Text {
                            text:
                                bluetoothToggleService.isBluetoothActive
                                ? "connected"
                                : "disabled"

                            color:
                                !bluetoothToggleService.isBluetoothActive
                                ? Theme.text
                                : Qt.alpha(
                                    Theme.background,
                                    0.65
                                )

                            font.family:
                                Theme.fontFamily

                            font.pixelSize:
                                11
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 40

                color:
                    Qt.alpha(
                        root.controlTint,
                        0.18
                    )

                radius: 20

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 16

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Image {
                            source:
                                "../assets/icons/sound.svg"

                            anchors.centerIn:
                                parent

                            width: 20
                            height: 20

                            fillMode:
                                Image.PreserveAspectFit

                            opacity:
                                audioService.muted
                                ? 0.4
                                : 1.0
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                audioService.toggleMute()
                            }
                        }
                    }

                    Rectangle {
                        id: soundSliderTrack

                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        color:
                            Qt.alpha(
                                root.controlTint,
                                0.18
                            )

                        radius: 20
                        clip: true

                        Rectangle {
                            id: soundFill

                            width:
                                soundSliderTrack.width *
                                audioService.volume

                            height:
                                parent.height

                            color:
                                audioService.muted
                                ? Qt.alpha(
                                    root.controlTint,
                                    0.5
                                )
                                : root.controlTint

                            radius: 20
                        }

                        MouseArea {
                            id: soundMouseArea

                            anchors.fill:
                                parent

                            cursorShape:
                                Qt.PointingHandCursor

                            function updateVolumeFromMouse(mouse) {
                                let localX = mouse.x
                                let parentItem = mouse.item

                                while (
                                    parentItem &&
                                    parentItem !==
                                    soundSliderTrack
                                ) {
                                    localX += parentItem.x
                                    parentItem =
                                        parentItem.parent
                                }

                                let ratio =
                                    Math.max(
                                        0,
                                        Math.min(
                                            1,
                                            localX /
                                            soundSliderTrack.width
                                        )
                                    )

                                audioService.setVolume(
                                    Math.round(
                                        ratio * 100
                                    )
                                )
                            }

                            onPressed: (mouse) =>
                                updateVolumeFromMouse(mouse)

                            onPositionChanged: (mouse) => {
                                if (pressed)
                                    updateVolumeFromMouse(mouse)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40

                color:
                    Qt.alpha(
                        root.controlTint,
                        0.18
                    )

                radius: 20

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 16

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Image {
                            source:
                                "../assets/icons/sun.svg"

                            anchors.centerIn:
                                parent

                            width: 20
                            height: 20

                            fillMode:
                                Image.PreserveAspectFit
                        }
                    }

                    Rectangle {
                        id: brightnessSliderTrack

                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        color:
                            Qt.alpha(
                                root.controlTint,
                                0.18
                            )

                        radius: 20
                        clip: true

                        Rectangle {
                            id: brightnessFill

                            width:
                                brightnessSliderTrack.width *
                                (
                                    brightnessService.brightness /
                                    100.0
                                )

                            height:
                                parent.height

                            color:
                                root.controlTint

                            radius: 20
                        }

                        MouseArea {
                            id: brightnessMouseArea

                            anchors.fill:
                                parent

                            cursorShape:
                                Qt.PointingHandCursor

                            function updateBrightnessFromMouse(mouse) {
                                let localX = mouse.x
                                let parentItem = mouse.item

                                while (
                                    parentItem &&
                                    parentItem !==
                                    brightnessSliderTrack
                                ) {
                                    localX += parentItem.x
                                    parentItem =
                                        parentItem.parent
                                }

                                var ratio =
                                    Math.max(
                                        0,
                                        Math.min(
                                            1,
                                            localX /
                                            brightnessSliderTrack.width
                                        )
                                    )

                                brightnessService.setBrightness(
                                    Math.round(
                                        ratio * 100
                                    )
                                )
                            }

                            onPressed: (mouse) =>
                                updateBrightnessFromMouse(mouse)

                            onPositionChanged: (mouse) => {
                                if (pressed)
                                    updateBrightnessFromMouse(mouse)
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: notificationsListView

            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            clip: true

            boundsBehavior:
                Flickable.StopAtBounds

            boundsMovement:
                Flickable.StopAtBounds

            flickableDirection:
                Flickable.VerticalFlick

            property int dismissedCount: 0

            onCountChanged: {
                if (dismissedCount > count)
                    dismissedCount = count
            }

            model:
                Notification.notificationServer
                ? Notification.notificationServer.trackedNotifications
                : null

            delegate: Item {
                id: notify

                required property var modelData

                width:
                    notificationsListView.width

                height:
                    dismissed
                    ? 0
                    : 70

                visible:
                    !dismissed

                property bool dismissed: false

                Behavior on height {
                    NumberAnimation {
                        duration: 120

                        easing.type:
                            Easing.InOutQuad
                    }
                }

                Rectangle {
                    id: notificationCard

                    anchors.fill:
                        parent

                    radius: 22

                    color:
                        mouseArea.containsMouse
                        ? Qt.alpha(
                            Theme.background,
                            0.94
                        )
                        : Theme.background

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Row {
                        anchors.fill:
                            parent

                        anchors.leftMargin:
                            14

                        anchors.rightMargin:
                            18

                        spacing: 12

                        Item {
                            width: 32
                            height: 32

                            anchors.verticalCenter:
                                parent.verticalCenter

                            Rectangle {
                                anchors.fill:
                                    parent

                                radius: 13

                                color:
                                    Qt.alpha(
                                        Theme.text,
                                        0.07
                                    )

                                Image {
                                    anchors.centerIn:
                                        parent

                                    width: 20
                                    height: 20

                                    source:
                                        "../assets/icons/notification.svg"

                                    fillMode:
                                        Image.PreserveAspectFit
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            width:
                                parent.width - 54

                            spacing: 4

                            Text {
                                width:
                                    parent.width

                                text:
                                    modelData.summary ||
                                    modelData.appName ||
                                    "Notification"

                                color:
                                    Qt.alpha(
                                        Theme.text,
                                        0.5
                                    )

                                font.family:
                                    Theme.fontFamily

                                font.pixelSize:
                                    Theme.fontSizeS

                                font.bold:
                                    true

                                maximumLineCount:
                                    1

                                elide:
                                    Text.ElideRight

                                clip:
                                    true
                            }

                            Text {
                                width:
                                    parent.width

                                text:
                                    modelData.body ||
                                    ""

                                color:
                                    Theme.text

                                font.family:
                                    Theme.fontFamily

                                font.pixelSize:
                                    Theme.fontSizeXS

                                font.bold:
                                    true

                                maximumLineCount:
                                    1

                                elide:
                                    Text.ElideRight

                                clip:
                                    true
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill:
                            parent

                        hoverEnabled:
                            true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            if (!notify.dismissed) {
                                notify.dismissed = true
                                notificationsListView.dismissedCount++
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn:
                    parent

                visible:
                    !Notification.notificationServer ||
                    notificationsListView.count === 0 ||
                    notificationsListView.dismissedCount >=
                        notificationsListView.count

                text:
                    "No Notifications"

                color:
                    Qt.alpha(
                        Theme.text,
                        0.5
                    )

                font.family:
                    Theme.fontFamily

                font.pixelSize:
                    Theme.fontSizeS

                font.bold:
                    true
            }
        }
    }
}
