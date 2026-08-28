-- ~/.config/hypr/hyprland.lua — the Lua port of hyprland.conf.
--
-- NOT ACTIVE unless Hyprland is started with `--config` pointing here, or
-- hyprland.conf is moved aside. Both files are kept: the .conf is the fallback,
-- and coat writes the colours for both on every apply.
--
-- Verify without applying:  Hyprland --config ~/.config/hypr/hyprland.lua --verify-config
--
-- What Lua buys over hyprlang: the workspace binds are a loop instead of 40
-- hand-written lines, and the animation table is data you can iterate.

local c = require("coat-colors")

local terminal = "kitty"
local menu     = "menu-run"   -- the .desktop wrapper, so the launcher can be swapped
local mod      = "SUPER"

------------------------------------------------------------------ monitors
-- bitdepth 10 keeps the 10-bit OLED output.
hl.monitor({ output = "eDP-1",     mode = "2560x1600@240", position = "0x0",    scale = 1, bitdepth = 10 })
hl.monitor({ output = "HDMI-A-1",  mode = "3840x2160@30",  position = "2560x0", scale = 1, bitdepth = 10 })
hl.monitor({ output = "",          mode = "preferred",     position = "auto",   scale = "auto" })

----------------------------------------------------------------------- env
-- The eDP panel is wired to the Intel iGPU in Hybrid mode, so Intel MUST be
-- primary: it scans out with no cross-GPU copy. Making NVIDIA primary renders on
-- the dGPU then copies every frame back (reverse PRIME) and stutters at 240Hz.
-- aquamarine wants the REAL cardN nodes and rejects by-path symlinks.
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("LIBVA_DRIVER_NAME", "iHD")
-- GTK4's Vulkan renderer picks the discrete GPU when both are present.
hl.env("GSK_RENDERER", "gl")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("HYPRCURSOR_THEME", "macOS")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "macOS")
hl.env("XCURSOR_SIZE", "24")

----------------------------------------------------------------- autostart
hl.on("hyprland.start", function()
    local once = {
        "dbus-update-activation-environment --all",
        "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
        "/usr/lib/xdg-desktop-portal-hyprland",
        "/usr/libexec/xdg-desktop-portal",
        "hypridle",
        "waybar -c /home/amarnath/.config/waybar/config-hyprland.jsonc",
        "fnott",
        "awww-daemon",
        "start-polkit",
        -- NOT a bare artix-pipewire-launcher: that skips wireplumber and leaves a
        -- stack that looks alive with only a null sink behind it.
        "audio-ensure",
        "refresh-paru-completions",
        "battery-watch",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
        "wl-clip-persist --clipboard regular",
        "hyprpm reload -n",
        "hyprpm-check",
    }
    for _, cmd in ipairs(once) do hl.exec_cmd(cmd) end
end)

--------------------------------------------------------------------- input
hl.config({
    input = {
        kb_layout    = "us",
        repeat_delay = 200,
        repeat_rate  = 50,
        follow_mouse = 1,
        sensitivity  = 0,
        accel_profile = "flat",
        touchpad = { natural_scroll = false },
    },
    cursor = { inactive_timeout = 3 },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- The 4-finger-up -> gloview overview gesture does NOT port. hl.gesture accepts
-- only workspace, move, float, fullscreen and fullscreen_state -- there is no
-- dispatcher action, and dispatch/exec/command are all rejected too. $mod+A still
-- opens the overview; this is the one thing hyprland.conf can do and this cannot.

-- accel_profile flat above is for mice only.
hl.device({ name = "asup1207:00-093a:3012-touchpad", accel_profile = "adaptive", natural_scroll = false })

------------------------------------------------------------ look and feel
-- gaps_in is HALF mango's gappi: Hyprland puts it on each window's own edge, so
-- two neighbours make 30px of gutter.
hl.config({
    general = {
        border_size = 0,
        gaps_in     = 15,
        gaps_out    = 15,
        layout      = "dwindle",
        resize_on_border = false,
        col = {
            -- THREE stops with the first and last the same colour: a symmetric
            -- gradient has no seam. base03 for inactive -- base01/02/04/06 sit
            -- near base00 in many schemes and the border disappears.
            active_border   = { colors = { c.base0D, c.base0C, c.base0D }, angle = 45 },
            inactive_border = c.base03,
        },
    },

    dwindle = { preserve_split = false },

    decoration = {
        rounding = 10,
        -- Squircle: 2.0 is a circular arc, higher is a superellipse.
        rounding_power = 4.0,
        active_opacity   = 1.0,
        inactive_opacity = 0.90,
        dim_inactive = false,
        blur = {
            enabled = true,
            size = 10, passes = 3,
            noise = 0.02, contrast = 1.0, brightness = 0.95,
            vibrancy = 0.25, vibrancy_darkness = 0.0,
            new_optimizations = true,
            -- Blur what is behind a translucent window rather than skipping it.
            ignore_opacity = true,
            popups = true, special = true,
            -- xray blurs the WALLPAPER through everything, flattening the stack.
            xray = false,
        },
        shadow = {
            enabled = true,
            range = 30, render_power = 10,
            offset = "0 0", scale = 4.0,
            color = c.shadow,
        },
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

---------------------------------------------------------------- animations
-- No overshoot anywhere: every curve ends at 1.00 and approaches from below.
hl.curve("macOut",  { type = "bezier", points = { {0.22, 1.00}, {0.36, 1.00} } })
hl.curve("macStd",  { type = "bezier", points = { {0.25, 0.10}, {0.25, 1.00} } })
hl.curve("macFade", { type = "bezier", points = { {0.50, 0.50}, {0.75, 1.00} } })

hl.config({ animations = { enabled = true } })

-- A table, not 24 near-identical lines. Windows slide so a new one travels in
-- from the nearest edge while its neighbours slide over -- they read as pushing
-- each other rather than one appearing on top.
local anims = {
    { "global",       4,   "macOut"  },
    { "windows",      4,   "macOut",  "slide" },
    { "windowsIn",    4,   "macOut",  "slide" },
    { "windowsOut",   4,   "macOut",  "slide" },
    { "windowsMove",  4,   "macOut",  "slide" },
    { "border",       4,   "macStd"  },
    { "layers",       4,   "macOut",  "popin 96%" },
    { "layersIn",     4,   "macOut",  "popin 96%" },
    { "layersOut",    2.7, "macOut",  "popin 96%" },
    { "fade",         4,   "macFade" },
    { "fadeIn",       4,   "macFade" },
    { "fadeOut",      4,   "macFade" },
    { "fadeSwitch",   2.7, "macFade" },
    { "fadeShadow",   4,   "macFade" },
    { "fadeDim",      2.7, "macFade" },
    { "fadeLayers",   4,   "macFade" },
    { "fadeLayersIn", 4,   "macFade" },
    { "fadeLayersOut",2.7, "macFade" },
    { "workspaces",     4, "macOut",  "slide" },
    { "workspacesIn",   4, "macOut",  "slide" },
    { "workspacesOut",  4, "macOut",  "slide" },
    { "specialWorkspace", 4, "macOut", "slidefadevert 30%" },
    { "zoomFactor",   4,   "macOut"  },
}
for _, a in ipairs(anims) do
    hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end
-- OFF: border_size is 0, so this rotated a gradient on a border zero pixels wide
-- while repainting the focused window every frame and defeating vfr.
hl.animation({ leaf = "borderangle", enabled = false, speed = 80, bezier = "linear" })

--------------------------------------------------------------------- rules
hl.window_rule({ name = "float-dialogs", match = { title = "^(Open File|Save File|Choose Files|Save As)$" }, float = true })
hl.window_rule({ name = "pip-pin",       match = { title = "Picture-in-Picture" }, pin = true })

-- One strip of glass the full width of the bar, with the islands sitting on it.
for _, ns in ipairs({ "waybar", "fnott", "notifications", "launcher" }) do
    hl.layer_rule({ name = "blur-" .. ns, match = { namespace = "^" .. ns .. "$" }, blur = true })
end

-------------------------------------------------------------------- plugins
-- NOTE: `--verify-config` reports these as unknown keys, because it does not load
-- plugins. They should apply at runtime once hyprpm has loaded them -- check with
-- `hyprctl getoption plugin:hyprbars:bar_height` after switching.
hl.config({
    plugin = {
        gloview = {
            strip_offset = 46,
            backdrop_color      = c.ov_backdrop,
            strip_active_border = c.ov_accent,
            select_border       = c.ov_accent,
            hover_border        = c.ov_accent2,
        },
        hyprbars = {
            bar_height = 28,
            bar_color  = c.surface,
            bar_blur   = true,
            ["col.text"] = c.base05,
            bar_text_size = 12,
            bar_text_font = "MartianMono Nerd Font Mono",
            bar_text_weight = 600,
            bar_text_align = "center",
            bar_title_enabled = true,
            bar_buttons_alignment = "left",
            bar_padding = 12,
            bar_button_padding = 8,
            icon_on_hover = true,
            inactive_button_color = c.base03,
            bar_part_of_window = true,
            bar_precedence_over_border = true,
        },
    },
})

------------------------------------------------------------------ keybinds
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("pkill -SIGUSR1 -x waybar"))  -- NEVER SIGUSR2: it aborts waybar
hl.bind(mod .. " + T", hl.dsp.exec_cmd("theme-pick"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("theme-random"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("osd nightlight"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot && sfx screenshot"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("screenshot-edit"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | menu -i -p clip | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + A", hl.dsp.exec_cmd("hyprctl dispatch gloview:toggle"))
hl.bind(mod .. " + G", hl.dsp.exec_cmd("hyprctl dispatch togglegroup"))
hl.bind(mod .. " + backslash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + U", hl.dsp.window.pseudo())
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

for _, d in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. d, hl.dsp.focus({ direction = d }))
    hl.bind(mod .. " + SHIFT + " .. d, hl.dsp.window.move({ direction = d }))
end

-- 20 lines of workspace binds become 4.
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media and brightness. `osd` performs the change AND draws the notification, so
-- there is no OSD daemon to die and take the keys with it. locked = works while
-- the session is locked; repeating = holding the key repeats.
local media = {
    { "XF86AudioRaiseVolume",  "osd volume up",       true  },
    { "XF86AudioLowerVolume",  "osd volume down",     true  },
    { "XF86AudioMute",         "osd volume mute",     false },
    { "XF86AudioMicMute",      "osd mic mute",        false },
    { "XF86AudioPlay",         "osd playpause",       false },
    { "XF86Launch3",           "osd playpause",       false },
    { "XF86AudioNext",         "osd next",            false },
    { "XF86AudioPrev",         "osd prev",            false },
    { "XF86MonBrightnessUp",   "osd brightness up",   true  },
    { "XF86MonBrightnessDown", "osd brightness down", true  },
    { "XF86KbdBrightnessUp",   "osd kbd up",          true  },
    { "XF86KbdBrightnessDown", "osd kbd down",        true  },
    { "XF86TouchpadToggle",    "osd touchpad",        false },
    -- Binding a lock key does not stop it working: xkb processes the keycode and
    -- pushes the LED before the compositor declines to forward it.
    { "Caps_Lock",             "osd capslock",        false },
    { "Num_Lock",              "osd numlock",         false },
}
for _, m in ipairs(media) do
    hl.bind(m[1], hl.dsp.exec_cmd(m[2]), { locked = true, repeating = m[3] })
end

-- Lid: blank the panel, do not suspend. What actually suspends is elogind --
-- HandleLidSwitch in /etc/elogind/logind.conf.
hl.bind("switch:on:Lid",  hl.dsp.exec_cmd("hyprctl dispatch dpms off"), { locked = true })
hl.bind("switch:off:Lid", hl.dsp.exec_cmd("hyprctl dispatch dpms on"),  { locked = true })
