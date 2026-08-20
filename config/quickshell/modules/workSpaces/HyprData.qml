pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../../" 1.0


Singleton {
    id: hyprdata


    // =========================================================
    // Active State
    //
    // HyprData only works while Workspace Preview is active.
    // =========================================================

    readonly property bool active:
     Main.workSpacePrevActive


    // =========================================================
    // Public data
    // =========================================================

    property var windows: []
    property var addresses: []
    property var windowByAddress: ({ })


    // =========================================================
    // Debug
    // =========================================================

    readonly property bool debug: true


    function debugLog() {

        if (!hyprdata.debug)
            return

        console.log.apply(
            console,
            arguments
        )
    }


    // =========================================================
    // Icon Search Queue
    // =========================================================

    property var iconQueue: []

    property bool iconSearchRunning: false

    property var currentIconRequest: null


    // =========================================================
    // Filesystem Icon Search Process
    // =========================================================

    Process {

        id: iconSearchProcess


        stdout: StdioCollector {

            onStreamFinished: {

                const output =
                    String(text || "")
                        .trim()


                // -------------------------------------------------
                // Ignore result if HyprData became inactive.
                // -------------------------------------------------

                if (!hyprdata.active) {

                    hyprdata.iconSearchRunning =
                        false

                    hyprdata.currentIconRequest =
                        null

                    return
                }


                if (!hyprdata.iconSearchRunning) {

                    debugLog(
                        "ICON SEARCH RESULT IGNORED: process not marked running"
                    )

                    return
                }


                const request =
                    hyprdata.currentIconRequest


                if (!request) {

                    hyprdata.iconSearchRunning =
                        false

                    return
                }


                debugLog(
                    "========================================"
                )

                debugLog(
                    "ICON SEARCH FINISHED"
                )

                debugLog(
                    "address:",
                    request.address
                )

                debugLog(
                    "class:",
                    request.appClass
                )

                debugLog(
                    "title:",
                    request.title
                )

                debugLog(
                    "candidates:",
                    request.candidates.join(", ")
                )

                debugLog(
                    "result:",
                    output
                )

                debugLog(
                    "========================================"
                )


                let icon = ""


                if (output !== "") {

                    icon =
                        "file://" + output


                    debugLog(
                        "ICON FOUND [filesystem]:",
                        icon
                    )

                } else {

                    debugLog(
                        "ICON FILESYSTEM SEARCH: NOT FOUND"
                    )
                }


                // -------------------------------------------------
                // Apply result only while active.
                // -------------------------------------------------

                if (
                    hyprdata.active &&
                    request.address &&
                    icon !== ""
                ) {

                    hyprdata.applyIcon(
                        request.address,
                        icon
                    )
                }


                hyprdata.iconSearchRunning =
                    false


                hyprdata.currentIconRequest =
                    null


                Qt.callLater(() => {

                    if (
                        hyprdata.active
                    ) {

                        hyprdata.processNextIconSearch()
                    }
                })
            }
        }
    }


    // =========================================================
    // Icon Search Paths
    // =========================================================

    readonly property var iconSearchRoots: [

        Quickshell.env("HOME") +
            "/.local/share/icons",

        Quickshell.env("HOME") +
            "/.icons",

        Quickshell.env("HOME") +
            "/.local/share/flatpak/exports/share/icons",

        "/usr/local/share/icons",

        "/usr/share/icons",

        "/usr/share/pixmaps"

    ]


    // =========================================================
    // Get Hyprland Clients
    // =========================================================

    Process {

        id: getClients


        command: [
            "hyprctl",
            "-j",
            "clients"
        ]


        stdout: StdioCollector {

            onStreamFinished: {

                // -------------------------------------------------
                // Ignore output if Overview is no longer active.
                // -------------------------------------------------

                if (!hyprdata.active) {

                    return
                }


                if (
                    !text ||
                    text.trim() === ""
                ) {

                    debugLog(
                        "HyprData: empty hyprctl output"
                    )

                    return
                }


                let clients


                try {

                    clients =
                        JSON.parse(text)

                } catch (error) {

                    console.log(
                        "HyprData: JSON parse error:",
                        error
                    )

                    return
                }


                if (!Array.isArray(clients)) {

                    console.log(
                        "HyprData: clients is not an array"
                    )

                    return
                }


                debugLog(
                    "========================================"
                )

                debugLog(
                    "HyprData: CLIENTS RECEIVED:",
                    clients.length
                )

                debugLog(
                    "========================================"
                )


                const mappedWindows =
                    clients.map(
                        client => {

                            const appClass =
                                String(
                                    client.class || ""
                                )


                            const title =
                                String(
                                    client.title || ""
                                )


                            const address =
                                hyprdata.normalizeAddress(
                                    client.address
                                )


                            // -------------------------------------------------
                            // Try Quickshell icon resolver first
                            // -------------------------------------------------

                            const icon =
                                hyprdata.findIcon(
                                    appClass,
                                    title
                                )


                            debugLog(
                                "WINDOW:",
                                appClass,
                                "| address:",
                                address,
                                "| icon:",
                                icon
                            )


                            return {

                                address:
                                    address,

                                workspace: {
                                    id:
                                        client.workspace
                                            ? client.workspace.id
                                            : -1,

                                    name:
                                        client.workspace
                                            ? client.workspace.name
                                            : ""
                                },

                                monitor:
                                    client.monitor,

                                class:
                                    appClass,

                                title:
                                    title,

                                icon:
                                    icon,

                                position: {
                                    x:
                                        client.at
                                            ? client.at[0]
                                            : 0,

                                    y:
                                        client.at
                                            ? client.at[1]
                                            : 0
                                },

                                size: {
                                    width:
                                        client.size
                                            ? client.size[0]
                                            : 0,

                                    height:
                                        client.size[1]
                                            ? client.size[1]
                                            : 0
                                },

                                floating:
                                    client.floating,

                                pinned:
                                    client.pinned,

                                fullscreen:
                                    client.fullscreen,

                                xwayland:
                                    client.xwayland,

                                focusHistoryID:
                                    client.focusHistoryID
                            }
                        }
                    )


                // =================================================
                // Update windows
                // =================================================

                hyprdata.windows =
                    mappedWindows


                // =================================================
                // Address lookup
                // =================================================

                const byAddress = {}


                for (
                    const window of mappedWindows
                ) {

                    byAddress[
                        hyprdata.normalizeAddress(
                            window.address
                        )
                    ] = window
                }


                hyprdata.windowByAddress =
                    byAddress


                // =================================================
                // Addresses
                // =================================================

                hyprdata.addresses =
                    mappedWindows.map(
                        window =>
                            window.address
                    )


                debugLog(
                    "HyprData:",
                    mappedWindows.length,
                    "windows mapped"
                )


                // =================================================
                // Queue filesystem searches
                // =================================================

                for (
                    const window of mappedWindows
                ) {

                    if (!hyprdata.active)
                        break


                    debugLog(
                        "WINDOW DEBUG:",
                        "address=",
                        window.address,
                        "| class=",
                        window.class,
                        "| title=",
                        window.title,
                        "| icon=",
                        window.icon
                    )


                    if (
                        !window.icon ||
                        String(window.icon).trim() === ""
                    ) {

                        hyprdata.queueIconSearch(
                            window
                        )
                    }
                }
            }
        }
    }


    // =========================================================
    // Active State Control
    // =========================================================

    onActiveChanged: {

        if (!active) {

            // -------------------------------------------------
            // Clear pending icon searches.
            // -------------------------------------------------

            iconQueue = []

            currentIconRequest =
                null

            iconSearchRunning =
                false


            // -------------------------------------------------
            // Stop active processes.
            // -------------------------------------------------

            getClients.running =
                false

            iconSearchProcess.running =
                false


            debugLog(
                "HyprData: INACTIVE - processes stopped"
            )


            return
        }


        // -----------------------------------------------------
        // Overview became active.
        // -----------------------------------------------------

        debugLog(
            "HyprData: ACTIVE - starting refresh"
        )


        Qt.callLater(() => {

            if (
                hyprdata.active
            ) {

                hyprdata.refresh()
            }
        })
    }


    // =========================================================
    // Normalize Address
    // =========================================================

    function normalizeAddress(address) {

        if (
            address === undefined ||
            address === null
        ) {

            return ""
        }


        let value =
            String(address)
                .trim()
                .toLowerCase()


        if (value === "")
            return ""


        if (
            !value.startsWith("0x")
        ) {

            value =
                "0x" + value
        }


        return value
    }


    // =========================================================
    // Find Application Icon
    // =========================================================

    function findIcon(
        appClass,
        title
    ) {

        const originalClass =
            String(
                appClass || ""
            ).trim()


        const originalTitle =
            String(
                title || ""
            ).trim()


        if (
            originalClass === "" &&
            originalTitle === ""
        ) {

            return ""
        }


        const name =
            originalClass.toLowerCase()


        debugLog(
            "ICON RESOLVE:",
            originalClass,
            "| title:",
            originalTitle
        )


        // =====================================================
        // 1. Exact system icon
        // =====================================================

        let icon =
            systemIcon(name)


        if (icon !== "") {

            debugLog(
                "ICON FOUND [exact]:",
                name,
                "=>",
                icon
            )

            return icon
        }


        // =====================================================
        // 2. Desktop entry
        // =====================================================

        try {

            const desktopEntry =
                DesktopEntries.heuristicLookup(
                    originalClass
                )


            if (desktopEntry) {

                const desktopIcon =
                    String(
                        desktopEntry.icon || ""
                    ).trim()


                debugLog(
                    "DESKTOP ENTRY:",
                    desktopEntry.id,
                    "| icon:",
                    desktopIcon
                )


                if (
                    desktopIcon !== ""
                ) {

                    icon =
                        systemIcon(
                            desktopIcon
                        )


                    if (icon !== "") {

                        debugLog(
                            "ICON FOUND [desktop]:",
                            desktopIcon,
                            "=>",
                            icon
                        )

                        return icon
                    }
                }
            }

        } catch (error) {

            debugLog(
                "DesktopEntries lookup failed:",
                error
            )
        }


        // =====================================================
        // 3. Known aliases
        // =====================================================

        const aliases = {

            "google-chrome":
                "google-chrome",

            "google-chrome-stable":
                "google-chrome",

            "chromium":
                "chromium",

            "chromium-browser":
                "chromium",

            "firefox":
                "firefox",

            "firefox-esr":
                "firefox",

            "brave":
                "brave-browser",

            "brave-browser":
                "brave-browser",

            "microsoft-edge":
                "microsoft-edge",

            "code":
                "code",

            "code-oss":
                "code-oss",

            "codium":
                "codium",

            "kitty":
                "kitty",

            "alacritty":
                "Alacritty",

            "foot":
                "foot",

            "konsole":
                "konsole",

            "wezterm":
                "wezterm",

            "gnome-terminal":
                "utilities-terminal",

            "nautilus":
                "org.gnome.Nautilus",

            "org.gnome.nautilus":
                "org.gnome.Nautilus",

            "dolphin":
                "system-file-manager",

            "thunar":
                "Thunar",

            "pcmanfm":
                "system-file-manager",

            "mpv":
                "mpv",

            "vlc":
                "vlc",

            "spotify":
                "spotify"
        }


        if (
            aliases[name] !== undefined
        ) {

            const alias =
                String(
                    aliases[name]
                )


            icon =
                systemIcon(
                    alias
                )


            if (icon !== "") {

                debugLog(
                    "ICON FOUND [alias]:",
                    name,
                    "=>",
                    alias,
                    "=>",
                    icon
                )

                return icon
            }
        }


        // =====================================================
        // 4. Generic classification
        // =====================================================

        icon =
            classifyApplication(
                name,
                originalTitle
            )


        if (icon !== "") {

            debugLog(
                "ICON FOUND [classification]:",
                icon
            )

            return icon
        }


        // =====================================================
        // 5. Filesystem search
        // =====================================================

        debugLog(
            "ICON SEARCH QUEUED:",
            originalClass,
            "| title:",
            originalTitle
        )


        return ""
    }


    // =========================================================
    // System Icon
    // =========================================================

    function systemIcon(name) {

        if (
            !name ||
            String(name).trim() === ""
        ) {

            return ""
        }


        const iconName =
            String(name).trim()


        let result = ""


        try {

            result =
                Quickshell.iconPath(
                    iconName,
                    true
                )

        } catch (error) {

            debugLog(
                "iconPath error:",
                iconName,
                error
            )

            return ""
        }


        if (
            !result ||
            String(result).trim() === ""
        ) {

            debugLog(
                "SYSTEM ICON NOT FOUND:",
                iconName
            )

            return ""
        }


        return String(result)
    }


    // =========================================================
    // Generic Classification
    // =========================================================

    function classifyApplication(
        name,
        title
    ) {

        const value =
            (
                String(name || "") +
                " " +
                String(title || "")
            ).toLowerCase()


        // Browser
        if (
            value.includes("firefox") ||
            value.includes("chrome") ||
            value.includes("chromium") ||
            value.includes("brave") ||
            value.includes("browser") ||
            value.includes("edge")
        ) {

            return firstAvailableIcon([
                "browser",
                "web-browser",
                "internet-web-browser"
            ])
        }


        // Code / IDE
        if (
            value === "code" ||
            value.includes("code") ||
            value.includes("codium") ||
            value.includes("neovim") ||
            value.includes("nvim") ||
            value.includes("vim") ||
            value.includes("emacs") ||
            value.includes("editor") ||
            value.includes("ide")
        ) {

            return firstAvailableIcon([
                "code",
                "visual-studio-code",
                "text-editor",
                "accessories-text-editor"
            ])
        }


        // Terminal
        if (
            value.includes("terminal") ||
            value.includes("kitty") ||
            value.includes("alacritty") ||
            value.includes("wezterm") ||
            value.includes("foot") ||
            value.includes("konsole")
        ) {

            return firstAvailableIcon([
                "utilities-terminal",
                "terminal",
                "kitty"
            ])
        }


        // File manager
        if (
            value.includes("nautilus") ||
            value.includes("dolphin") ||
            value.includes("thunar") ||
            value.includes("pcmanfm") ||
            value.includes("file manager")
        ) {

            return firstAvailableIcon([
                "system-file-manager",
                "folder"
            ])
        }


        // Media
        if (
            value.includes("mpv") ||
            value.includes("vlc") ||
            value.includes("spotify") ||
            value.includes("media") ||
            value.includes("player")
        ) {

            return firstAvailableIcon([
                "multimedia-player",
                "media-player",
                "audio-player"
            ])
        }


        // Settings
        if (
            value.includes("settings") ||
            value.includes("setting") ||
            value.includes("systemsettings")
        ) {

            return firstAvailableIcon([
                "preferences-system",
                "systemsettings"
            ])
        }


        // Text editor
        if (
            value.includes("gedit") ||
            value.includes("kate") ||
            value.includes("text editor")
        ) {

            return firstAvailableIcon([
                "accessories-text-editor",
                "text-editor"
            ])
        }


        return ""
    }


    // =========================================================
    // First Available Icon
    // =========================================================

    function firstAvailableIcon(
        names
    ) {

        for (
            const name of names
        ) {

            const icon =
                systemIcon(name)


            if (icon !== "") {

                debugLog(
                    "CLASSIFICATION ICON:",
                    name,
                    "=>",
                    icon
                )

                return icon
            }
        }


        return ""
    }


    // =========================================================
    // Build Candidate Icon Names
    // =========================================================

    function iconCandidates(
        appClass
    ) {

        const name =
            String(
                appClass || ""
            )
            .trim()
            .toLowerCase()


        const result = []


        function add(value) {

            if (
                !value ||
                String(value).trim() === ""
            ) {

                return
            }


            const normalized =
                String(value).trim()


            if (
                result.indexOf(
                    normalized
                ) === -1
            ) {

                result.push(
                    normalized
                )
            }
        }


        // Exact application class
        add(name)


        // Common transformations
        add(
            name.replace(
                /\./g,
                "-"
            )
        )


        add(
            name.replace(
                /_/g,
                "-"
            )
        )


        // Known aliases
        const aliases = {

            "brave":
                "brave-browser",

            "brave-browser":
                "brave-browser",

            "code":
                "code",

            "code-oss":
                "code-oss",

            "codium":
                "codium",

            "google-chrome":
                "google-chrome",

            "google-chrome-stable":
                "google-chrome",

            "chromium":
                "chromium",

            "firefox-esr":
                "firefox",

            "kitty":
                "kitty",

            "alacritty":
                "alacritty",

            "org.gnome.nautilus":
                "org.gnome.Nautilus",

            "nautilus":
                "org.gnome.Nautilus",

            "dolphin":
                "system-file-manager",

            "pcmanfm":
                "system-file-manager"
        }


        if (
            aliases[name] !== undefined
        ) {

            add(
                aliases[name]
            )
        }


        return result
    }


    // =========================================================
    // Queue Icon Filesystem Search
    // =========================================================

    function queueIconSearch(
        window
    ) {

        if (!hyprdata.active)
            return


        if (!window)
            return


        const address =
            normalizeAddress(
                window.address
            )


        if (!address)
            return


        // -----------------------------------------------------
        // Don't queue same address twice.
        // -----------------------------------------------------

        for (
            const request of iconQueue
        ) {

            if (
                request.address === address
            ) {

                debugLog(
                    "ICON SEARCH ALREADY QUEUED:",
                    address
                )

                return
            }
        }


        if (
            currentIconRequest &&
            currentIconRequest.address === address
        ) {

            debugLog(
                "ICON SEARCH ALREADY RUNNING:",
                address
            )

            return
        }


        const candidates =
            iconCandidates(
                window.class
            )


        if (
            candidates.length === 0
        ) {

            debugLog(
                "ICON SEARCH SKIPPED: no candidates",
                address
            )

            return
        }


        const request = {

            address:
                address,

            appClass:
                String(
                    window.class || ""
                ),

            title:
                String(
                    window.title || ""
                ),

            candidates:
                candidates
        }


        iconQueue.push(
            request
        )


        debugLog(
            "ICON SEARCH QUEUED:",
            request.appClass,
            "| address:",
            request.address,
            "| candidates:",
            candidates.join(", ")
        )


        processNextIconSearch()
    }


    // =========================================================
    // Process Next Icon Search
    // =========================================================

    function processNextIconSearch() {

        if (!hyprdata.active)
            return


        if (
            iconSearchRunning
        ) {

            return
        }


        if (
            iconQueue.length === 0
        ) {

            return
        }


        const request =
            iconQueue.shift()


        currentIconRequest =
            request


        iconSearchRunning =
            true


        // -----------------------------------------------------
        // Escape shell arguments safely.
        // -----------------------------------------------------

        const candidatePattern =
            request.candidates
                .map(
                    name =>
                        name
                            .replace(
                                /[.*+?^${}()|[\]\\]/g,
                                "\\$&"
                            )
                )
                .join("|")


        const roots =
            iconSearchRoots
                .map(
                    path =>
                        "'" +
                        String(path)
                            .replace(
                                /'/g,
                                "'\\''"
                            ) +
                        "'"
                )
                .join(" ")


        // -----------------------------------------------------
        // Search filenames only.
        // -----------------------------------------------------

        const shellCommand =
            "find " +
            roots +
            " -type f " +
            "\\( -iname '*.svg' -o -iname '*.png' -o -iname '*.xpm' \\) " +
            " 2>/dev/null | " +
            "grep -Ei '/(" +
            candidatePattern +
            ")\\.(svg|png|xpm)$' | " +
            "head -n 1"


        debugLog(
            "========================================"
        )

        debugLog(
            "ICON FILESYSTEM SEARCH START"
        )

        debugLog(
            "address:",
            request.address
        )

        debugLog(
            "class:",
            request.appClass
        )

        debugLog(
            "candidates:",
            request.candidates.join(", ")
        )

        debugLog(
            "command:",
            shellCommand
        )

        debugLog(
            "========================================"
        )


        iconSearchProcess.command = [
            "sh",
            "-c",
            shellCommand
        ]


        iconSearchProcess.running =
            true
    }


    // =========================================================
    // Apply Found Icon
    // =========================================================

    function applyIcon(
        address,
        icon
    ) {

        if (!hyprdata.active)
            return


        const normalized =
            normalizeAddress(
                address
            )


        if (!normalized)
            return


        if (!icon)
            return


        debugLog(
            "ICON APPLIED:",
            normalized,
            "=>",
            icon
        )


        const updated =
            hyprdata.windows.map(
                window => {

                    if (
                        normalizeAddress(
                            window.address
                        ) !== normalized
                    ) {

                        return window
                    }


                    return {

                        address:
                            window.address,

                        workspace:
                            window.workspace,

                        monitor:
                            window.monitor,

                        class:
                            window.class,

                        title:
                            window.title,

                        icon:
                            icon,

                        position:
                            window.position,

                        size:
                            window.size,

                        floating:
                            window.floating,

                        pinned:
                            window.pinned,

                        fullscreen:
                            window.fullscreen,

                        xwayland:
                            window.xwayland,

                        focusHistoryID:
                            window.focusHistoryID
                    }
                }
            )


        hyprdata.windows =
            updated


        const byAddress = {}


        for (
            const window of updated
        ) {

            byAddress[
                normalizeAddress(
                    window.address
                )
            ] = window
        }


        hyprdata.windowByAddress =
            byAddress


        debugLog(
            "ICON APPLIED SUCCESSFULLY:",
            normalized
        )
    }


    // =========================================================
    // Refresh
    // =========================================================

    function refresh() {

        // -----------------------------------------------------
        // MASTER GUARD
        //
        // If Workspace Preview is closed,
        // absolutely nothing should start.
        // -----------------------------------------------------

        if (!hyprdata.active) {

            debugLog(
                "HyprData: refresh ignored - inactive"
            )

            return
        }


        debugLog(
            "========================================"
        )

        debugLog(
            "HyprData: REFRESH"
        )

        debugLog(
            "========================================"
        )


        // -----------------------------------------------------
        // Clear pending searches.
        // -----------------------------------------------------

        iconQueue = []


        // -----------------------------------------------------
        // If another icon search is already running,
        // don't start another one.
        // -----------------------------------------------------

        if (
            iconSearchRunning
        ) {

            debugLog(
                "HyprData: filesystem search currently running"
            )
        }


        // -----------------------------------------------------
        // Read Hyprland clients.
        // -----------------------------------------------------

        if (
            !getClients.running
        ) {

            getClients.running =
                true
        }
    }


    // =========================================================
    // Initial Load
    //
    // IMPORTANT:
    //
    // No automatic refresh here.
    //
    // onActiveChanged() controls activation.
    // =========================================================

    Component.onCompleted: {

        debugLog(
            "HyprData: Component.onCompleted"
        )

        debugLog(
            "HyprData: waiting for Workspace Preview activation"
        )
    }
}
