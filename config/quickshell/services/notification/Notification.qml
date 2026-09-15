pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
id: root

property var latestNotification: null
property var notificationServer: server

property int notificationEventCount: 0
property int latestNotificationChangeCount: 0
property int trackedChangeCount: 0
property int closedEventCount: 0

function timestamp() {
    return Date.now()
}

function objectInfo(notification) {
    if (!notification)
        return "NULL"

    return (
        "object=" + notification
        + " | app=[" + (notification.appName || "") + "]"
        + " | summary=[" + (notification.summary || "") + "]"
        + " | body=[" + (notification.body || "") + "]"
        + " | tracked=" + notification.tracked
        + " | id=" + (
            notification.id !== undefined
                ? notification.id
                : "undefined"
        )
    )
}

function hasContent(value) {
    return (
        value !== undefined &&
        value !== null &&
        String(value).trim() !== ""
    )
}

function dumpTrackedNotifications(reason) {
    console.log(
        "[BARY-NOTIFY][TRACKED-DUMP]",
        "reason=[" + reason + "]"
    )

    if (!server.trackedNotifications) {
        console.log(
            "[BARY-NOTIFY][TRACKED-DUMP]",
            "trackedNotifications = NULL"
        )
        return
    }

    console.log(
        "[BARY-NOTIFY][TRACKED-DUMP]",
        "count=" + server.trackedNotifications.length
    )

    for (
        var i = 0;
        i < server.trackedNotifications.length;
        i++
    ) {
        var notification =
            server.trackedNotifications[i]

        console.log(
            "[BARY-NOTIFY][TRACKED-DUMP]",
            "[" + i + "]",
            root.objectInfo(notification)
        )
    }
}

onLatestNotificationChanged: {
    latestNotificationChangeCount++

    console.log(
        "[BARY-NOTIFY][LATEST-CHANGED]",
        "time=" + root.timestamp(),
        "count=" + latestNotificationChangeCount
    )

    console.log(
        "[BARY-NOTIFY][LATEST-CHANGED]",
        "old/new latest object=",
        root.latestNotification
    )

    if (!root.latestNotification) {
        console.log(
            "[BARY-NOTIFY][LATEST-CHANGED]",
            "LATEST IS NULL"
        )
        return
    }

    console.log(
        "[BARY-NOTIFY][LATEST-CHANGED]",
        root.objectInfo(
            root.latestNotification
        )
    )
}

NotificationServer {
    id: server

    bodySupported: true
    imageSupported: true

    Component.onCompleted: {
        console.log(
            "[BARY-NOTIFY][SERVER]",
            "NotificationServer CREATED",
            "time=" + root.timestamp()
        )

        root.dumpTrackedNotifications(
            "server-created"
        )
    }

    Component.onDestruction: {
        console.log(
            "[BARY-NOTIFY][SERVER]",
            "NotificationServer DESTROYED",
            "time=" + root.timestamp()
        )
    }

    onNotification: function(notification) {
        root.notificationEventCount++

        console.log(
            ""
        )

        console.log(
            "=================================================="
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "EVENT #" + root.notificationEventCount,
            "time=" + root.timestamp()
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "RAW OBJECT:",
            notification
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "INFO:",
            root.objectInfo(notification)
        )

        if (!notification) {
            console.log(
                "[BARY-NOTIFY][ON-NOTIFICATION]",
                "!!! NULL NOTIFICATION !!!"
            )

            console.log(
                "=================================================="
            )

            return
        }

        var summary =
            notification.summary || ""

        var body =
            notification.body || ""

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "summary=[" + summary + "]"
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "body=[" + body + "]"
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "appName=[" +
            (notification.appName || "") +
            "]"
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "tracked BEFORE=" +
            notification.tracked
        )

        if (
            !root.hasContent(summary) &&
            !root.hasContent(body)
        ) {
            console.log(
                "[BARY-NOTIFY][ON-NOTIFICATION]",
                "!!! EMPTY NOTIFICATION REJECTED !!!"
            )

            root.dumpTrackedNotifications(
                "empty-notification-rejected"
            )

            console.log(
                "=================================================="
            )

            return
        }

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "VALID NOTIFICATION"
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "Setting tracked=true..."
        )

        notification.tracked = true

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "tracked AFTER=" +
            notification.tracked
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "Setting latestNotification..."
        )

        root.latestNotification =
            notification

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "latestNotification NOW:",
            root.objectInfo(
                root.latestNotification
            )
        )

        root.dumpTrackedNotifications(
            "after-onNotification"
        )

        console.log(
            "[BARY-NOTIFY][ON-NOTIFICATION]",
            "Notification:",
            notification.appName,
            summary,
            body
        )

        console.log(
            "=================================================="
        )
    }

    onTrackedNotificationsChanged: {
        root.trackedChangeCount++

        console.log(
            ""
        )

        console.log(
            "[BARY-NOTIFY][TRACKED-CHANGED]",
            "EVENT #" +
            root.trackedChangeCount,
            "time=" + root.timestamp()
        )

        console.log(
            "[BARY-NOTIFY][TRACKED-CHANGED]",
            "count=" +
            server.trackedNotifications.length
        )

        root.dumpTrackedNotifications(
            "trackedNotifications-changed"
        )
    }
}

Component.onCompleted: {
    console.log(
        ""
    )

    console.log(
        "##################################################"
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "Notification singleton CREATED",
        "time=" + root.timestamp()
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "latestNotification=",
        root.latestNotification
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "notificationServer=",
        root.notificationServer
    )

    root.dumpTrackedNotifications(
        "root-created"
    )

    console.log(
        "##################################################"
    )

    console.log(
        ""
    )
}

Component.onDestruction: {
    console.log(
        ""
    )

    console.log(
        "##################################################"
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "Notification singleton DESTROYED",
        "time=" + root.timestamp()
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "notificationEventCount=" +
        root.notificationEventCount
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "latestNotificationChangeCount=" +
        root.latestNotificationChangeCount
    )

    console.log(
        "[BARY-NOTIFY][ROOT]",
        "trackedChangeCount=" +
        root.trackedChangeCount
    )

    console.log(
        "##################################################"
    )

    console.log(
        ""
    )
}

}

