import QtQuick
import Quickshell.Io
import "../../" 1.0

Item {
    id: fetchService

    property string connectedNetworkName: ""
    property bool isConnected: false
    property alias model: wifiModel
    property string rawOutput: ""

    ListModel {
        id: wifiModel
    }

    Process {
        id: rescanProcess

        running: false

        command: [
            "nmcli",
            "device",
            "wifi",
            "rescan"
        ]

        onExited: function(exitCode, exitStatus) {
            fetchService.startWifiList()
        }
    }

    Process {
        id: wifiProcess

        running: false

        stdout: SplitParser {
            onRead: function(data) {
                fetchService.rawOutput += data + "\n"
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                fetchService.rawOutput = ""
                fetchService.connectedNetworkName = ""
                fetchService.isConnected = false
                wifiModel.clear()
                return
            }

            fetchService.parseNetworks(
                fetchService.rawOutput
            )

            fetchService.rawOutput = ""
        }
    }

    function refresh() {
        if (rescanProcess.running)
            return

        if (wifiProcess.running)
            return

        rawOutput = ""

        rescanProcess.running = false
        rescanProcess.running = true
    }

    function startWifiList() {
        if (wifiProcess.running)
            return

        rawOutput = ""

        wifiProcess.command = [
            "nmcli",
            "-t",
            "-f",
            "SSID,ACTIVE,BARS,SECURITY",
            "dev",
            "wifi",
            "list"
        ]

        wifiProcess.running = true
    }

    function parseNetworks(output) {
        var lines = output.trim().split(/\r?\n/)
        var networks = {}
        var activeSsid = ""

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            if (!line)
                continue

            var parts = line.split(":")

            if (parts.length < 4)
                continue

            var ssid = parts[0].trim()
            var active = parts[1].trim() === "yes"
            var bars = parts[2].trim()
            var security = parts.slice(3).join(":").trim()

            if (ssid === "")
                ssid = "Hidden Network"

            var strength = "0%"

            if (bars.includes("█"))
                strength = "100%"
            else if (bars.includes("▆"))
                strength = "75%"
            else if (bars.includes("▄"))
                strength = "50%"
            else if (bars.includes("▂"))
                strength = "25%"

            var status = "open network"

            if (active) {
                status = "connected"
                activeSsid = ssid
            } else if (
                security !== "" &&
                security !== "--"
            ) {
                status = "secured"
            }

            if (networks[ssid]) {
                if (active) {
                    networks[ssid].isConnected = true
                    networks[ssid].netStatus = "connected"
                    activeSsid = ssid
                }

                continue
            }

            networks[ssid] = {
                netName: ssid,
                netStatus: status,
                netStrength: strength,
                isConnected: active
            }
        }

        var result = Object.values(networks)

        result.sort(function(a, b) {
            return Number(b.isConnected) -
                   Number(a.isConnected)
        })

        wifiModel.clear()

        for (var j = 0; j < result.length; j++)
            wifiModel.append(result[j])

        connectedNetworkName = activeSsid
        isConnected = activeSsid !== ""
    }

    Component.onCompleted: {
        refresh()
    }
}
