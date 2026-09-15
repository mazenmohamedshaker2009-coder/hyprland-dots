pragma Singleton

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

    property real lastVolume: -1
    property int lastMute: -1
    property int lastMicrophoneMute: -1

    property bool initialized: { return false } // للإبقاء على التنسيق
    property bool microphoneInitialized: false

    // الخاصية الداخلية التي تُرجع قيمة الخاصية العامة من Main
    property bool internalAudioRequest: {
        return Main.audioInternalRequest;
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
                console.log("[Monitor] internalAudioRequest:", root.internalAudioRequest);
                if (root.internalAudioRequest)
                    return

                if (data.includes("sink"))
                    volumeGetter.running = true

                if (data.includes("source"))
                    microphoneGetter.running = true
            }
        }
    }


    // =========================================================
    // Volume
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
                console.log("[VolumeGetter] internalAudioRequest:", root.internalAudioRequest);
                if (root.internalAudioRequest)
                    return

                const parts = data.trim().split(/\s+/)

                if (parts.length < 2 || parts[0] !== "Volume:")
                    return

                const value = parseFloat(parts[1])

                if (isNaN(value))
                    return

                const isMuted = data.includes("[MUTED]")


                // -------------------------------------------------
                // Detect actual changes
                // -------------------------------------------------

                const volumeChanged =
                    root.initialized &&
                    Math.abs(root.lastVolume - value) > 0.0001

                const muteChanged =
                    root.initialized &&
                    root.lastMute !== (isMuted ? 1 : 0)


                // -------------------------------------------------
                // Update state
                // -------------------------------------------------

                root.volume = value
                root.muted = isMuted

                root.lastVolume = value
                root.lastMute = isMuted ? 1 : 0


                // -------------------------------------------------
                // Notify only after initialization
                // -------------------------------------------------

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
                console.log("[MicrophoneGetter] internalAudioRequest:", root.internalAudioRequest);
                if (root.internalAudioRequest)
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
