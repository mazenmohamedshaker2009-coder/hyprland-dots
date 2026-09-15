import QtQuick
import Quickshell
import Quickshell.Io

import "../" 1.0

Item {
    id: root

    signal volumeUpdated(real volume)
    signal muteUpdated(bool muted)
    signal microphoneMuteUpdated(bool muted)

    property real volume: 0
    property bool muted: false
    property bool microphoneMuted: false

    property bool audioInternalRequest: false

    property real lastVolume: -1
    property int lastMute: -1
    property int lastMicrophoneMute: -1

    property bool initialized: false
    property bool microphoneInitialized: false

    // =========================================================
    // Control Functions (Setter Methods - Silent & Precise)
    // =========================================================
    
    function setVolume(val) {
        root.audioInternalRequest = true;

        let percentage = Math.max(0, Math.min(100, val)) / 100.0;
        
        // تحديث محلي فوري لسلاسة السلايدر بدون أي تأخير
        root.volume = percentage;
        root.lastVolume = percentage;
        root.volumeUpdated(percentage);

        volumeSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percentage.toFixed(2)];
        volumeSetter.running = true;
    }

    function toggleMute() {
        root.audioInternalRequest = true;

        let targetState = root.muted ? "0" : "1";
        let newMuteState = !root.muted;

        // تحديث محلي فوري لحالة الكتم
        root.muted = newMuteState;
        root.lastMute = newMuteState ? 1 : 0;
        root.muteUpdated(newMuteState);

        muteToggleProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", targetState];
        muteToggleProcess.running = true;
    }

    // Process لتنفيذ تغيير الصوت (بدون تايمر، فك القفل فور انتهاء الـ Process)
    Process {
        id: volumeSetter
        running: false
        onRunningChanged: {
            if (!running) {
                root.audioInternalRequest = false;
            }
        }
    }

    // Process لتنفيذ كتم الصوت
    Process {
        id: muteToggleProcess
        running: false
        onRunningChanged: {
            if (!running) {
                root.audioInternalRequest = false;
            }
        }
    }


    // =========================================================
    // PulseAudio / PipeWire event monitor
    // =========================================================

    Process {
        id: monitor

        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (root.audioInternalRequest)
                    return

                if (data.includes("sink"))
                    volumeGetter.running = true

                if (data.includes("source"))
                    microphoneGetter.running = true
            }
        }
    }


    // =========================================================
    // Volume Getter
    // =========================================================

    Process {
        id: volumeGetter

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (root.audioInternalRequest)
                    return

                const parts = data.trim().split(/\s+/)

                if (parts.length < 2 || parts[0] !== "Volume:")
                    return

                const value = parseFloat(parts[1])

                if (isNaN(value))
                    return

                const isMuted = data.includes("[MUTED]")

                const volumeChanged =
                    root.initialized &&
                    Math.abs(root.lastVolume - value) > 0.0001

                const muteChanged =
                    root.initialized &&
                    root.lastMute !== (isMuted ? 1 : 0)

                root.volume = value
                root.muted = isMuted

                root.lastVolume = value
                root.lastMute = isMuted ? 1 : 0

                if (volumeChanged)
                    root.volumeUpdated(value)

                if (muteChanged)
                    root.muteUpdated(isMuted)

                root.initialized = true
            }
        }
    }


    // =========================================================
    // Microphone
    // =========================================================

    Process {
        id: microphoneGetter

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SOURCE@"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (root.audioInternalRequest)
                    return

                const isMuted = data.includes("[MUTED]")
                const state = isMuted ? 1 : 0

                const changed =
                    root.microphoneInitialized &&
                    root.lastMicrophoneMute !== state

                root.microphoneMuted = isMuted
                root.lastMicrophoneMute = state

                if (changed)
                    root.microphoneMuteUpdated(isMuted)

                root.microphoneInitialized = true
            }
        }
    }


    // =========================================================
    // Initial state
    // =========================================================

    Component.onCompleted: {
        volumeGetter.running = true
        microphoneGetter.running = true
    }
}
