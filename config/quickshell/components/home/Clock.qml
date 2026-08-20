import QtQuick
import Quickshell
import "../../" 1.0

Text {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeM
    font.bold: true

    text: Qt.formatDateTime(clock.date, "hh:mm")
}
