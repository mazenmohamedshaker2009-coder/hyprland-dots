-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
hl.on("hyprland.start", function ()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("awww-daemon")
    -- Bary (QuickShell) provides the bar, notifications, wallpaper picker,
    -- and workspace overview; it replaces Waybar, SwayNC, Wlogout, and Hyprexpo.
    hl.exec_cmd("qs")
end)
