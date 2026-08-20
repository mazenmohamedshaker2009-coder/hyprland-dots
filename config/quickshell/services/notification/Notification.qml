pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property var latestNotification: null

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true

        onNotification: function(notification) {
            notification.tracked = true
            root.latestNotification = notification

            console.log(
                "Notification:",
                notification.appName,
                notification.summary,
                notification.body
            )
        }
    }

    function send(summary, body) {
        const notification = Qt.createQmlObject(`
            import Quickshell.Services.Notifications

            Notification {
                summary: "${summary}"
                body: "${body}"
            }
        `, root)

        notification.tracked = true
        notification.send()
    }

Component.onCompleted: {
    send("Hello", Quickshell.env("USER"))
}
}
