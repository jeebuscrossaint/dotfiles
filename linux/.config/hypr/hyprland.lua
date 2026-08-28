-- ~/.config/hypr/hyprland.lua — the Lua port of hyprland.conf.
--
-- THIS FILE IS THE LIVE CONFIG. Hyprland 0.56 prefers hyprland.lua over
-- hyprland.conf whenever both exist and picks it up with no --config flag:
--   [cfg] Using lua config found at ~/.config/hypr/hyprland.lua
-- So edits to hyprland.conf do NOTHING while this file is here. Both are kept
-- because coat writes the colours for both on every apply, but the .conf is a
-- fallback you have to move this file aside to reach -- not a parallel config.
--
-- Verify without applying:  Hyprland --config ~/.config/hypr/hyprland.lua --verify-config
--
-- What Lua buys over hyprlang: the workspace binds are a loop instead of 40
-- hand-written lines, and the animation table is data you can iterate.

local c = require("coat-colors")

local terminal = "kitty"
local menu = "menu-run" -- the .desktop wrapper, so the launcher can be swapped
local mod = "SUPER"

------------------------------------------------------------------ monitors
-- bitdepth 10 keeps the 10-bit OLED output.
hl.monitor({ output = "eDP-1", mode = "2560x1600@240", position = "0x0", scale = 1, bitdepth = 10 })
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@30", position = "2560x0", scale = 1, bitdepth = 10 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

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
		-- hyprfocus is disabled in hyprpm, not here: its focus hook segfaults the
		-- compositor on every window focus (fullWindowFocus -> rawWindowFocus ->
		-- SEGV in hyprfocus.so). Both copies crash -- daxisunder's and hyprwm's --
		-- so it is not the fork, it is the hyprutils skew: Hyprland 0.56.1-3 is
		-- built against hyprutils 0.14.0 while the system runs 0.14.1, and plugins
		-- rebuilt now compile against 0.14.1 headers. Same-soname (.so.13), so
		-- nothing catches it until the signal machinery dereferences garbage.
		-- Retry hyprfocus after Hyprland is rebuilt against 0.14.1 (extra/hyprland
		-- 0.56.2-1 or later), then: hyprpm enable daxisunder/hyprfocus
		"hyprpm reload -n",
		"hyprpm-check",
	}
	for _, cmd in ipairs(once) do
		hl.exec_cmd(cmd)
	end
end)

--------------------------------------------------------------------- input
hl.config({
	input = {
		kb_layout = "us",
		repeat_delay = 200,
		repeat_rate = 50,
		follow_mouse = 1,
		sensitivity = 0,
		accel_profile = "flat",
		touchpad = { natural_scroll = false },
	},
	cursor = { inactive_timeout = 3 },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- action takes a Lua function, so plugin dispatchers ARE reachable from a
-- gesture -- hl.gesture's string actions are only workspace/move/float/
-- fullscreen/fullscreen_state, which is what made this look unportable.
hl.gesture({ fingers = 4, direction = "up", action = function() hl.plugin.gloview.toggle() end })

-- accel_profile flat above is for mice only.
hl.device({ name = "asup1207:00-093a:3012-touchpad", accel_profile = "adaptive", natural_scroll = false })

------------------------------------------------------------ look and feel
-- gaps_in is HALF mango's gappi: Hyprland puts it on each window's own edge, so
-- two neighbours make 30px of gutter.
hl.config({
	general = {
		border_size = 0,
		gaps_in = 15,
		gaps_out = 15,
		layout = "dwindle",
		resize_on_border = false,
		col = {
			-- THREE stops with the first and last the same colour: a symmetric
			-- gradient has no seam. base03 for inactive -- base01/02/04/06 sit
			-- near base00 in many schemes and the border disappears.
			active_border = { colors = { c.base0D, c.base0C, c.base0D }, angle = 45 },
			inactive_border = c.base03,
		},
	},

	dwindle = { preserve_split = false },

	decoration = {
		rounding = 10,
		-- Squircle: 2.0 is a circular arc, higher is a superellipse.
		rounding_power = 4.0,
		active_opacity = 1.0,
		inactive_opacity = 0.90,
		dim_inactive = false,
		blur = {
			enabled = true,
			size = 10,
			passes = 3,
			noise = 0.02,
			contrast = 1.0,
			brightness = 0.95,
			vibrancy = 0.25,
			vibrancy_darkness = 0.0,
			new_optimizations = true,
			-- Blur what is behind a translucent window rather than skipping it.
			ignore_opacity = true,
			popups = true,
			special = true,
			-- xray blurs the WALLPAPER through everything, flattening the stack.
			xray = false,
		},
		shadow = {
			enabled = true,
			range = 30,
			render_power = 10,
			offset = "0 0",
			scale = 4.0,
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
hl.curve("macOut", { type = "bezier", points = { { 0.22, 1.00 }, { 0.36, 1.00 } } })
hl.curve("macStd", { type = "bezier", points = { { 0.25, 0.10 }, { 0.25, 1.00 } } })
hl.curve("macFade", { type = "bezier", points = { { 0.50, 0.50 }, { 0.75, 1.00 } } })

hl.config({ animations = { enabled = true } })

-- A table, not 24 near-identical lines. Windows slide so a new one travels in
-- from the nearest edge while its neighbours slide over -- they read as pushing
-- each other rather than one appearing on top.
local anims = {
	{ "global", 4, "macOut" },
	{ "windows", 4, "macOut", "slide" },
	{ "windowsIn", 4, "macOut", "slide" },
	{ "windowsOut", 4, "macOut", "slide" },
	{ "windowsMove", 4, "macOut", "slide" },
	{ "border", 4, "macStd" },
	{ "layers", 4, "macOut", "popin 96%" },
	{ "layersIn", 4, "macOut", "popin 96%" },
	{ "layersOut", 2.7, "macOut", "popin 96%" },
	{ "fade", 4, "macFade" },
	{ "fadeIn", 4, "macFade" },
	{ "fadeOut", 4, "macFade" },
	{ "fadeSwitch", 2.7, "macFade" },
	{ "fadeShadow", 4, "macFade" },
	{ "fadeDim", 2.7, "macFade" },
	{ "fadeLayers", 4, "macFade" },
	{ "fadeLayersIn", 4, "macFade" },
	{ "fadeLayersOut", 2.7, "macFade" },
	{ "workspaces", 4, "macOut", "slide" },
	{ "workspacesIn", 4, "macOut", "slide" },
	{ "workspacesOut", 4, "macOut", "slide" },
	{ "specialWorkspace", 4, "macOut", "slidefadevert 30%" },
	{ "zoomFactor", 4, "macOut" },
}
for _, a in ipairs(anims) do
	hl.animation({ leaf = a[1], enabled = true, speed = a[2], bezier = a[3], style = a[4] })
end
-- OFF: border_size is 0, so this rotated a gradient on a border zero pixels wide
-- while repainting the focused window every frame and defeating vfr.
hl.animation({ leaf = "borderangle", enabled = false, speed = 80, bezier = "linear" })

--------------------------------------------------------------------- rules
hl.window_rule({
	name = "float-dialogs",
	match = { title = "^(Open File|Save File|Choose Files|Save As)$" },
	float = true,
})
hl.window_rule({ name = "pip-pin", match = { title = "Picture-in-Picture" }, pin = true })
-- Floating windows fade instead of sliding. popin scales from a percentage of the
-- final size, so 100% leaves no scaling and only the fadeIn ramp shows -- there is
-- no `fade` window style to ask for. Tiled windows keep the slide, which is what
-- makes them read as pushing each other; a float has nothing to push.
hl.window_rule({ name = "float-fade", match = { float = true }, animation = "popin 100%" })

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
			backdrop_color = c.ov_backdrop,
			strip_active_border = c.ov_accent,
			select_border = c.ov_accent,
			hover_border = c.ov_accent2,
		},
		-- x86_64 only. stretch squishes the cursor in the direction of motion.
		-- Dialled back from stock: nothing else here overshoots, and the default
		-- limit smeared the pointer far enough to read as a glitch at 240Hz.
		-- Namespace is dynamic_cursors with an UNDERSCORE. hyprlang spells it
		-- `dynamic-cursors`; the Lua bridge maps the hyphen to an underscore and
		-- rejects the hyphenated form as an unknown config key. With the underscore
		-- `hyprctl getoption plugin:dynamic-cursors:mode` reports set: true.
		dynamic_cursors = {
			enabled = true,
			mode = "stretch",
			threshold = 2, -- min angle change (deg) before reshaping
			stretch = {
				-- No `function` key: `hyprctl getoption plugin:dynamic-cursors:stretch:function`
				-- says "no such option". The conf carries a key this build dropped.
				limit = 2000,
			},
			-- Hyprcursor shapes rather than a rasterised xcursor, so the stretched
			-- pointer stays sharp -- HYPRCURSOR_THEME is set at the top of this file.
			hyprcursor = { nearest = false },
			shake = { enabled = false },
		},

		-- Subtle flash on focus change. Lineage matters: VortexCoyote/hyprfocus is
		-- unmaintained, daxisunder's fork is the one that tracks current Hyprland,
		-- and hyprwm/hyprland-plugins ships its OWN hyprfocus (a different plugin,
		-- same name). These keys are written for daxisunder's -- enabling the hyprwm
		-- one instead segfaults the compositor on the first focus change.
		-- COMMENTED 2026-08-27: hyprfocus is disabled in hyprpm (it segfaults on
		-- window focus under the hyprutils 0.14.0/0.14.1 skew), so these keys are
		-- unknown and only produce error-overlay noise. Restore together with
		-- `hyprpm enable daxisunder/hyprfocus`.
		-- hyprfocus = {
		-- enabled = true,
		-- animate_floating = true,
		-- animate_workspacechange = true,
		-- focus_animation = "flash",
		-- -- Dip FAST, recover SLOW. 0.70 because inactive_opacity is 0.90 -- the
		-- -- dip has to go clearly below where the eye is coming from.
		-- flash = {
		-- flash_opacity = 0.70,
		-- in_bezier = "focusIn",
		-- in_speed = 0.6,
		-- out_bezier = "focusOut",
		-- out_speed = 1.8,
		-- },
		-- },

		-- Traffic-light buttons are not set here: hyprlang's `hyprbars-button =`
		-- lines become hl.plugin.hyprbars.add_button() calls, in the deferred
		-- block further down -- that API only exists once the plugin has loaded.
		hyprbars = {
			bar_height = 28,
			bar_color = c.surface,
			bar_blur = true,
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

-- hyprfocus takes two `bezier =` lines. A Lua table cannot repeat a key, and a
-- list value is silently DROPPED (no key registers at all -- verified against
-- --verify-config), so each curve needs its own hl.config call. 1.00, not 1.05,
-- on the last control point: an overshoot there sprang the focus flash past its
-- target opacity and let it settle back.
-- hl.config({ plugin = { hyprfocus = { bezier = "focusIn, 0.15, 0.85, 0.30, 1.00" } } })
-- hl.config({ plugin = { hyprfocus = { bezier = "focusOut, 0.20, 0.60, 0.35, 1.00" } } })

-- macOS traffic lights. hl.plugin.hyprbars only exists once the plugin is
-- loaded, and hyprpm's exec-once runs AFTER this file is parsed -- so load it
-- here. hl.plugin.load is idempotent (hyprpm loading it again returns ok), and
-- doing it synchronously beats hl.timer, which segfaults `--verify-config`.
-- pcall'd so a missing .so costs the buttons, not the whole config.
-- Actions must be Lua-form dispatches: `hyprctl dispatch killactive` fails on a
-- Lua config, `hyprctl dispatch 'hl.dsp.window.close()'` works.
pcall(hl.plugin.load, "/var/cache/hyprpm/amarnath/hyprland-plugins/hyprbars.so")
if hl.plugin and hl.plugin.hyprbars then
	local function button(bg, icon, action)
		hl.plugin.hyprbars.add_button({ bg_color = bg, fg_color = c.base00, size = 12, icon = icon, action = action })
	end
	button(c.base08, "×", "hyprctl dispatch 'hl.dsp.window.close()'")
	button(c.base0A, "−", [[hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:magic" })']])
	button(c.base0B, "+", [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })']])
end

------------------------------------------------------------------ keybinds
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("pgrep -x swaylock >/dev/null || swaylock -f"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("pkill -SIGUSR1 -x waybar")) -- NEVER SIGUSR2: it aborts waybar
hl.bind(mod .. " + T", hl.dsp.exec_cmd("theme-pick"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("theme-random"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("osd nightlight"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot && sfx screenshot"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("screenshot-edit"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | menu -i -p clip | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
-- mode "maximized" keeps the bar and gaps; "fullscreen" hides them. These are
-- hyprlang's `fullscreen, 1` and `fullscreen, 0` -- the Lua names are the two
-- the API accepts ("maximize" is rejected).
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" })) -- muscle memory
-- gloview:toggle has no hl.dsp entry, but the plugin exports its own Lua API.
-- Wrapped in a function so hl.plugin resolves when the key is pressed, not when
-- this file is parsed -- the plugin is not loaded yet at parse time.
hl.bind(mod .. " + A", function() hl.plugin.gloview.toggle() end)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
-- hyprlang's `changegroupactive, f`. hl.dsp.group.active takes only a numeric
-- index, so forward/back go through group.next/prev instead.
hl.bind(mod .. " + Tab", hl.dsp.group.next())
-- Alt+Tab. cyclenext moves focus and bringactivetotop raises it -- without the
-- second, a floating window takes focus while staying buried.
-- Native dispatchers, NOT `exec hyprctl dispatch ...`: on a Lua config hyprctl
-- wraps its argument as hl.dispatch(<arg>) and parses it as Lua, so every
-- `hyprctl dispatch cyclenext` errors with "expected a dispatcher". The bind
-- fired and the command failed, which is why Alt+Tab did nothing.
-- Two binds per key, exactly as the conf had two `bind = ALT, Tab` lines.
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.bring_to_top())
hl.bind(mod .. " + backslash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + U", hl.dsp.window.pseudo())
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

for _, d in ipairs({ "left", "right", "up", "down" }) do
	hl.bind(mod .. " + " .. d, hl.dsp.focus({ direction = d }))
	hl.bind(mod .. " + SHIFT + " .. d, hl.dsp.window.move({ direction = d }))
end

-- Vim keys for moving windows. The conf binds these on SHIFT only -- there is
-- no plain $mod+HJKL focus bind to match.
for _, v in ipairs({ { "H", "left" }, { "J", "down" }, { "K", "up" }, { "L", "right" } }) do
	hl.bind(mod .. " + SHIFT + " .. v[1], hl.dsp.window.move({ direction = v[2] }))
end

-- 20 lines of workspace binds become 4.
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize submap. hyprlang used `binde` for key repeat; here that is
-- { repeating = true }. escape and return both leave.
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	for _, r in ipairs({
		{ "left", -20, 0 }, { "right", 20, 0 }, { "up", 0, -20 }, { "down", 0, 20 },
		{ "H", -20, 0 }, { "L", 20, 0 }, { "K", 0, -20 }, { "J", 0, 20 },
	}) do
		hl.bind(r[1], hl.dsp.window.resize({ x = r[2], y = r[3], relative = true }), { repeating = true })
	end
	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("return", hl.dsp.submap("reset"))
end)

-- Submap indicator. A submap is otherwise invisible: you are in a different
-- keymap with nothing on screen saying so. keybinds.submap hands the name as a
-- plain string and "" when leaving, so one handler covers enter, switch and exit.
-- hl.notification.create returns a dismissable object, which is what makes a
-- badge that lasts exactly as long as the submap possible -- the duration is just
-- a ceiling, the dismiss on exit is what actually takes it down.
local submap_hint = {
	resize = "\u{2190}\u{2193}\u{2191}\u{2192} / hjkl resize   esc, return to exit",
}
local submap_notif

local function clear_submap_notif()
	if submap_notif then
		pcall(function()
			submap_notif:dismiss()
		end)
		submap_notif = nil
	end
end

hl.on("keybinds.submap", function(name)
	clear_submap_notif()
	if name == "" then
		return
	end
	submap_notif = hl.notification.create({
		text = "  " .. name:upper() .. "    " .. (submap_hint[name] or ""),
		duration = 3600000,
		color = c.ov_accent,
		font_size = 16,
	})
end)

-- A reload while inside a submap would strand the badge on screen otherwise.
hl.on("config.reloaded", clear_submap_notif)

-- Media and brightness. `osd` performs the change AND draws the notification, so
-- there is no OSD daemon to die and take the keys with it. locked = works while
-- the session is locked; repeating = holding the key repeats.
local media = {
	{ "XF86AudioRaiseVolume", "osd volume up", true },
	{ "XF86AudioLowerVolume", "osd volume down", true },
	{ "XF86AudioMute", "osd volume mute", false },
	{ "XF86AudioMicMute", "osd mic mute", false },
	{ "XF86AudioPlay", "osd playpause", false },
	{ "XF86Launch3", "osd playpause", false },
	{ "XF86AudioNext", "osd next", false },
	{ "XF86AudioPrev", "osd prev", false },
	{ "XF86MonBrightnessUp", "osd brightness up", true },
	{ "XF86MonBrightnessDown", "osd brightness down", true },
	{ "XF86TouchpadToggle", "osd touchpad", false },
	-- Binding a lock key does not stop it working: xkb processes the keycode and
	-- pushes the LED before the compositor declines to forward it.
	{ "Caps_Lock", "osd capslock", false },
	{ "Num_Lock", "osd numlock", false },
}
-- Wrapped in a function rather than passing hl.dsp.exec_cmd(...) straight in.
-- A dispatcher object combined with locked = true silently never fires: the key
-- reaches input handling (input.keyboard.key sees it) and the bind is registered
-- with the right modmask, but the body never runs. The same dispatcher works
-- unlocked ($mod+Q), and a plain Lua function works locked -- so this is the one
-- combination to avoid. Same fix applies to the Lid binds below.
for _, m in ipairs(media) do
	hl.bind(m[1], function()
		hl.dispatch(hl.dsp.exec_cmd(m[2]))
	end, { locked = true, repeating = m[3] })
end

-- Config-drawn OSD. hl.notification is compositor-side: no D-Bus, no daemon, no
-- fork. It does NOT replace fnott -- fnott serves *application* notifications
-- over D-Bus, which Hyprland does not implement. This is config feedback only.
--
-- Only sysfs-backed controls live here. Volume stays in ~/.local/bin/osd because
-- reading it back needs wpctl, and io.popen would fork on the compositor's main
-- thread -- a frame hitch at 240Hz. Screen brightness stays there too: it steps
-- in raw units against a floor, and that logic is worth more than the fork.
local osd_notif

local function osd(text, value, maxv)
	if osd_notif then
		pcall(function()
			osd_notif:dismiss()
		end)
	end
	local bar = ""
	if value and maxv and maxv > 0 then
		local filled = math.floor((value / maxv) * 10 + 0.5)
		bar = "   " .. string.rep("\u{2588}", filled) .. string.rep("\u{2591}", 10 - filled) .. "   " .. value .. "/" .. maxv
	end
	osd_notif = hl.notification.create({
		text = text .. bar,
		duration = 2500,
		color = c.ov_accent,
		font_size = 16,
	})
end

-- Keyboard backlight, read and written straight through sysfs. Four discrete
-- steps, so the bar shows 2/3 rather than a rounded percentage. The write needs
-- flush(): without it the value never reaches the kernel.
local KBD_LED = "/sys/class/leds/asus::kbd_backlight"

local function read_int(path)
	local h = io.open(path, "r")
	if not h then
		return nil
	end
	local v = tonumber(h:read("*l"))
	h:close()
	return v
end

local function kbd_backlight(delta)
	local cur = read_int(KBD_LED .. "/brightness")
	local max = read_int(KBD_LED .. "/max_brightness")
	if not cur or not max or max <= 0 then
		return
	end
	local new = math.max(0, math.min(max, cur + delta))
	if new ~= cur then
		local h = io.open(KBD_LED .. "/brightness", "w")
		if h then
			h:write(tostring(new) .. "\n")
			h:flush()
			h:close()
		else
			return -- not in the input group; leave the LED and the OSD alone
		end
	end
	osd("\u{f030c}  Keyboard", new, max)
end

hl.bind("XF86KbdBrightnessUp", function()
	kbd_backlight(1)
end, { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", function()
	kbd_backlight(-1)
end, { locked = true, repeating = true })

-- Lid: blank the panel, do not suspend. What actually suspends is elogind --
-- HandleLidSwitch in /etc/elogind/logind.conf.
hl.bind("switch:on:Lid", function()
	hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
end, { locked = true })
hl.bind("switch:off:Lid", function()
	hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch dpms on"))
end, { locked = true })
