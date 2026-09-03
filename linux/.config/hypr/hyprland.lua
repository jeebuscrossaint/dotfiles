-- ~/.config/hypr/hyprland.lua — THE Hyprland config.
--
-- Hyprland 0.56 picks this up with no --config flag:
--   [cfg] Using lua config found at ~/.config/hypr/hyprland.lua
-- The hyprlang hyprland.conf it was ported from is deleted, not kept as a
-- fallback -- it only ever collected stale edits that did nothing.
--
-- Colours AND the font come from coat via require("coat-colors"): c.base0X,
-- c.font, c.font_size. Never write a font family or a colour literal here.
-- One exception, marked at the site: the window shadow is a fixed neutral dark.
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
-- 240Hz, always. The ProMotion-style switcher that used to drop this to 60Hz on
-- battery is gone at the user's request: the measured saving was ~1.6W (15.3 ->
-- 13.7) in Hybrid MUX with the dGPU asleep, which is real but not worth a panel
-- that visibly changes character every time the charger moves. Do not reinstate
-- it as an optimisation.
-- HDR. The panel does support it, and the EDID is a red herring: its DisplayID
-- 2.0 block advertises no colour-space/EOTF combination at all, so parsing the
-- EDID says "no HDR". The DRM connector says otherwise, which is what counts --
-- aquamarine logs it at startup:
--
--   drm: connector eDP-1 crtc supports HDR (8)
--   drm: connector eDP-1 crtc supports Colorspace (514)
--
-- render:cm_enabled and render:cm_auto_hdr are already on by default in 0.56,
-- and auto_hdr means the output only switches into HDR when a surface actually
-- asks for it -- the desktop stays SDR the rest of the time, so this is not a
-- permanent change in how everything looks.
--
-- sdr_max_luminance is the one that matters. It is what SDR white maps to once
-- the output IS in HDR mode, and the default of 80 nits is why Linux HDR is
-- famous for looking washed out and dim: the whole desktop drops to 80 nits the
-- moment a video goes HDR. 220 is in the right region for a DisplayHDR True
-- Black panel; raise it if SDR still looks flat next to HDR content.
--
-- bitdepth 10 is NOT hdr and never was: that is precision (1024 steps per
-- channel instead of 256), not transfer function or gamut. It was already set.
hl.monitor({
	output = "eDP-1",
	mode = "2560x1600@240",
	position = "0x0",
	scale = 1,
	bitdepth = 10,
	supports_hdr = true,
	sdr_max_luminance = 220,
	sdr_min_luminance = 0.0,
})
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@30", position = "2560x0", scale = 1, bitdepth = 10 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

----------------------------------------------------------------------- env
-- Which card the panel hangs off is decided by the BIOS MUX
-- (asus-nb-wmi/gpu_mux_mode: 1=Hybrid -> eDP on Intel, 0=Discrete -> eDP on the
-- dGPU). Flipping it in setup moves eDP-1 between cards, and a hardcoded node
-- strands Hyprland on a GPU with zero connected outputs: it starts, grabs the
-- card, finds no output and renders into the void. Looks exactly like a freeze.
-- So resolve the scanout card from which one actually has the panel attached.
-- aquamarine wants the REAL cardN node and rejects by-path symlinks.
local function panel_card()
	local f = io.popen("grep -l '^connected$' /sys/class/drm/card*-eDP-*/status 2>/dev/null")
	if not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	return line and line:match("/(card%d+)%-eDP")
end

local function vendor_of(card)
	local f = io.open("/sys/class/drm/" .. card .. "/device/vendor")
	if not f then
		return nil
	end
	local v = f:read("*l")
	f:close()
	return v
end

local scanout = panel_card() or "card1"
local nvidia_primary = vendor_of(scanout) == "0x10de"

hl.env("AQ_DRM_DEVICES", "/dev/dri/" .. scanout)

if nvidia_primary then
	-- Discrete MUX. The dGPU drives the panel, so the loaders must NOT be
	-- pinned to Mesa/Intel -- doing that renders the compositor on a GPU that
	-- cannot reach the display. RTD3 is moot in this mode anyway: the card is
	-- the scanout engine, it can never park in D3cold. HDMI-A-1 works here,
	-- since it was always wired to the dGPU.
	hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("NVD_BACKEND", "direct")
else
	-- Hybrid MUX. Intel is primary: it scans out with no cross-GPU copy, where
	-- making NVIDIA primary would render on the dGPU and copy every frame back
	-- (reverse PRIME), stuttering at 240Hz.
	--
	-- The dGPU node is deliberately not in AQ_DRM_DEVICES. Listing it made
	-- aquamarine open /dev/dri/cardN + /dev/nvidia0 at backend init and hold
	-- them for the life of the session, pinning the RTX 4070 at D0 forever:
	-- 39h uptime, 576ms of PCI runtime suspend. Dropping it lets fine-grained
	-- RTD3 park the card in D3cold and wake it on demand for prime-run.
	-- The price: HDMI-A-1 hangs off the dGPU and is dead in this mode. USB-C/DP
	-- is on the Intel side (card*-DP-1..4) and still works.
	--
	-- Dropping the card still left Hyprland opening renderD129 + /dev/nvidia0,
	-- because libglvnd enumerates EVERY EGL vendor at init and NVIDIA's ICD
	-- instantiates a device merely by being listed. One open handle holds the
	-- card at D0. Pinning the loaders to Mesa/Intel keeps NVIDIA untouched
	-- until asked. Inherited by every child, so prime-run (shadowed in
	-- ~/.local/bin) flips both back to the NVIDIA ICDs for the one process
	-- that wants the dGPU.
	hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json")
	hl.env("VK_DRIVER_FILES", "/usr/share/vulkan/icd.d/intel_icd.json")
	hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
	hl.env("LIBVA_DRIVER_NAME", "iHD")
end
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
-- PATH must be set HERE, not left to whatever launched the compositor.
--
-- Almost every keybind below runs a script from ~/.local/bin -- osd, lock,
-- menu-run, screenshot, theme-pick -- and greetd starts Hyprland with a login
-- environment that does not include it. The result is not an error anywhere: the
-- binds fire, the exec fails silently, and it looks exactly like "no keybinds
-- work". A TTY login happened to work only because fish had already prepended it
-- before exec'ing Hyprland.
--
-- Prepended so a script here still shadows a system binary of the same name,
-- which is the point of `menu`, `lock` and `prime-run`.
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. os.getenv("HOME") .. "/.cargo/bin:" .. os.getenv("PATH"))

hl.on("hyprland.start", function()
	local once = {
		"dbus-update-activation-environment --all",
		"dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
		"/usr/lib/xdg-desktop-portal-hyprland",
		"/usr/libexec/xdg-desktop-portal",
		"hypridle",
		-- Full brightness at login. The firmware brings the panel up at about a
		-- quarter and nothing else was setting it; brightnessctl is in /usr/bin,
		-- so this works regardless of the PATH problem above.
		"brightnessctl --quiet set 100%",
		-- The Quickshell shell: menu bar, Control Centre, Spotlight, the dmenu
		-- Picker and the notification server. waybar and fnott are both gone
		-- from this list -- the bar carries their modules now, and only one
		-- process can own org.freedesktop.Notifications. hyprlock still stands.
		-- QT_QPA_PLATFORMTHEME=gtk3 is what points Qt's icon lookup at the GTK
		-- icon theme -- WhiteSur-dark -- instead of leaving it on hicolor. It is
		-- set here and not globally so it only affects the shell.
		"env QT_QPA_PLATFORMTHEME=gtk3 qs",
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

-- Four fingers up for Mission Control, which is the macOS gesture exactly. The
-- action field takes a FUNCTION as well as one of the built-in names, so a
-- gesture can call anything -- there is no need for the dispatcher to be one
-- Hyprland already knows about.
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd("qs ipc call mission toggle")
	end,
})

-- accel_profile flat above is for mice only.
hl.device({ name = "asup1207:00-093a:3012-touchpad", accel_profile = "adaptive", natural_scroll = false })

------------------------------------------------------------ look and feel
-- gaps_in is HALF mango's gappi: Hyprland puts it on each window's own edge, so
-- two neighbours make 30px of gutter.
-- Opacity variant of the scheme's shadow slot, not a recoloured one: the hue
-- still comes from coat, only the alpha changes.
local shadow_inactive = (c.shadow:gsub("%x%x%)$", "38)"))

hl.config({
	general = {
		border_size = 0,
		gaps_in = 25,
		gaps_out = 15,
		layout = "dwindle",
		resize_on_border = true,
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
		inactive_opacity = 1.0,
		dim_inactive = false,
		blur = {
			enabled = false,
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
			-- Small range, HIGH render_power -- the opposite of the macOS 70/1 spec
			-- that was here before. Falloff is exponential in render_power, so at 3
			-- nearly all the darkness sits in the first few pixels and the tail is
			-- gone well inside a 15px gap. 70/1 instead spread a flat wash across the
			-- whole gutter, which is why it read as mud instead of as a shadow, and
			-- why it needed gaps nobody wants. This is what the rices actually run:
			-- range 15-30, power 2-3, small or no offset.
			range = 24,
			render_power = 3,
			-- Enough drop to lift the window off the wallpaper without implying a
			-- light source the rest of the theme does not have.
			offset = "0 0",
			-- Scheme slot, used literally. An unfocused window gets the same colour at
			-- a much lower alpha so it sits closer to the surface -- and fadeShadow in
			-- the animation table cross-fades the two, so a focus change is a change
			-- in HEIGHT, not just in opacity. That transition is the whole point of
			-- turning shadows back on.
			color = c.shadow,
			-- color_inactive = shadow_inactive,
			color_inactive = c.shadow,
		},
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		-- Off by default, which means a keyboard/mouse resize snapped its geometry
		-- every frame and never touched the windowsMove curve. On, a resize is the
		-- same animated travel as any other geometry change.
		animate_manual_resizes = true,
		-- The window eases toward the cursor through windowsMove instead of being
		-- pinned to it. Reads as weight; revert this one first if it reads as lag.
		animate_mouse_windowdragging = true,
	},
})

-- The 3-finger swipe above is the one interaction that tracks a finger rather
-- than playing a canned curve, so it is worth tuning. `gestures:workspace_swipe`
-- itself is gone in 0.56 (hl.gesture replaced it) but these knobs still feed it.
hl.config({
	gestures = {
		-- Finger travel for one full workspace. Below the 300 default the
		-- workspace moves further per mm, which reads as lighter.
		workspace_swipe_distance = 250,
		-- Keep swiping past the first workspace to cross several in one motion,
		-- instead of the gesture ending at each boundary.
		workspace_swipe_forever = true,
		-- How fast a flick has to be to commit the switch on its own. The 30
		-- default swallowed slow drags and snapped them back.
		workspace_swipe_min_speed_to_force = 15,
		-- Fraction of the distance that commits rather than reverts. 0.5 meant a
		-- swipe stopped just short of halfway undid itself.
		workspace_swipe_cancel_ratio = 0.35,
	},
})

---------------------------------------------------------------- animations
-- No overshoot anywhere: every curve ends at 1.00 and approaches from below.
hl.curve("macOut", { type = "bezier", points = { { 0.25, 0.90 }, { 0.32, 1.00 } } })
hl.curve("macStd", { type = "bezier", points = { { 0.25, 0.10 }, { 0.25, 1.00 } } })
hl.curve("macFade", { type = "bezier", points = { { 0.50, 0.50 }, { 0.75, 1.00 } } })
-- Geometry changes get their own curve. macOut is so front-loaded it is nearly a
-- step: fine for a window sliding in from an edge, wrong for one resizing to the
-- whole screen, where it lurches and then crawls. A real S -- slow out of rest,
-- sustained middle, soft settle -- keeps the motion continuous for the full 250ms.
-- The tail is where "sweepy" lives: the second control point sits at x=0.06 so
-- the last few percent of travel spends a long time landing. Same 250ms as
-- everything else, but it glides in rather than arriving.
hl.curve("macMove", { type = "bezier", points = { { 0.32, 0.00 }, { 0.06, 1.00 } } })

hl.config({ animations = { enabled = true } })

-- A table, not 24 near-identical lines. Windows slide so a new one travels in
-- from the nearest edge while its neighbours slide over -- they read as pushing
-- each other rather than one appearing on top.
--
-- macOut vs macMove is a distance call, not a taste call. macOut is nearly a step,
-- which reads as snappy over a few pixels and as a lurch over a few hundred. So
-- anything crossing the screen -- geometry changes, workspace slides -- takes
-- macMove, and the layer popins stay on macOut because `popin 96%` travels 4% of
-- a surface and an S-curve there just feels like dragging.
-- STYLE is where this reads as Linux rather than macOS, more than any duration.
-- `slide` is a tiling-WM idiom: the window travels in from an edge and the
-- neighbours shove over. macOS never does that. A window appears by scaling up
-- from about 90% AT ITS FINAL POSITION with a fade -- no travel at all -- and
-- leaves by scaling slightly down and fading. `popin` is exactly that, and the
-- percentage is the start scale.
--
-- 90% not 80%: at 80% the scale is a visible zoom and reads as Android. macOS is
-- a small, quick settle you feel more than see.
local anims = {
	{ "global", 2.5, "macOut" },
	{ "windows", 2.5, "macOut", "popin 90%" },
	{ "windowsIn", 2.5, "macOut", "popin 90%" },
	-- Slower than the rest on purpose: a close is the one animation with no
	-- successor state to look at, so at the common duration it was over before
	-- the eye caught it.
	-- fadeOut MUST match -- at alpha 0 the geometry is still animating but
	-- invisible, so the shorter of the two is the duration you actually see.
	-- Closing scales DOWN slightly rather than sliding away, and only to 92%:
	-- past that it becomes a shrink-into-nothing, which is a Windows gesture.
	{ "windowsOut", 3.0, "macFade", "popin 92%" },
	{ "windowsMove", 2.5, "macMove", "slide" },
	{ "border", 2.5, "macStd" },
	{ "layers", 2.5, "macOut", "popin 96%" },
	{ "layersIn", 2.5, "macOut", "popin 96%" },
	{ "layersOut", 1.7, "macOut", "popin 96%" },
	{ "fade", 2.5, "macFade" },
	{ "fadeIn", 2.5, "macFade" },
	{ "fadeOut", 3.5, "macFade" },
	{ "fadeSwitch", 1.7, "macFade" },
	{ "fadeShadow", 2.5, "macFade" },
	{ "fadeDim", 1.7, "macFade" },
	{ "fadeLayers", 2.5, "macFade" },
	{ "fadeLayersIn", 2.5, "macFade" },
	{ "fadeLayersOut", 1.7, "macFade" },
	-- Spaces are the one thing macOS animates SLOWLY, and deliberately: the whole
	-- desktop slides as a single sheet over roughly 400ms. At 250ms it reads as a
	-- cut rather than a movement, which is what made workspace switching feel
	-- un-Mac even with the right curve.
	{ "workspaces", 4.0, "macMove", "slide" },
	{ "workspacesIn", 4.0, "macMove", "slide" },
	{ "workspacesOut", 4.0, "macMove", "slide" },
	-- A sheet coming down, so it gets the sheet timing rather than the window one.
	{ "specialWorkspace", 3.0, "macMove", "slidefadevert 20%" },
	{ "zoomFactor", 2.5, "macOut" },
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


-- Blur only the surfaces meant to read as glass. Every qs-* namespace is one:
-- the shell paints translucent surfaces and relies on the compositor to frost
-- what is behind them, so a missing namespace here is a panel that looks flat
-- and see-through rather than one that looks broken -- which is exactly why it
-- is easy to miss. Layer blur is opt-in in Hyprland; the namespace IS the rule.
--
-- (waybar was deliberately absent from this list: its window was transparent and
-- each module an rgba island, so blurring the layer frosted the wallpaper behind
-- every slab instead of behind the bar.)
for _, ns in ipairs({
	"notifications",
	"launcher",
	"qs-bar",
	"qs-dock",
	"qs-popover",
	"qs-hud",
	"qs-mission",
	"qs-spotlight",
	"qs-picker",
	"qs-notifications",
}) do
	hl.layer_rule({ name = "blur-" .. ns, match = { namespace = "^" .. ns .. "$" }, blur = true })
end

-------------------------------------------------------------------- plugins
-- None. dynamic-cursors, hyprbars and gloview were all enabled and all unused in
-- practice, so they are disabled in hyprpm too (`hyprpm list` to confirm) -- the
-- config keys below them are gone with them. Re-enabling any of these means both
-- `hyprpm enable <repo>/<plugin>` AND restoring its block here; git log has them.

------------------------------------------------------------------ keybinds
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
-- Cmd+Space, near enough. mod+D above reaches the same launcher: `menu-run` is
-- Spotlight now, so the swap away from fuzzel needed no keybind change at all.
-- `menu`, the dmenu-style picker for scripts, is the shell's Picker component.
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call spotlight toggle"))
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("lock"))
-- hyprlock, kept deliberately. hypridle still calls it, and it is the way back
-- if the shell's lock ever misbehaves -- a lock is the one component where the
-- failure mode is a machine you cannot get into.
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("lock"))
-- Was waybar's SIGUSR1 show/hide toggle. waybar is gone; the equivalent gesture
-- now opens Control Centre, which is where the sliders and the load readouts
-- that used to live in the bar ended up.
hl.bind(mod .. " + P", hl.dsp.exec_cmd("qs ipc call control toggle"))
-- Mission Control. Ctrl+Up on a Mac; mod+Up here, since the arrow keys are
-- otherwise only used for focus movement with a modifier this bind does not use.
hl.bind(mod .. " + up", hl.dsp.exec_cmd("qs ipc call mission toggle"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd("theme-pick"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("theme-random"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("osd nightlight"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot && sfx screenshot"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("screenshot-edit"))
-- Clipboard history is a mode of the launcher now, not a shell pipeline into a
-- dmenu. Same cliphist store underneath; the palette does the listing, the
-- filtering and the decode.
hl.bind(mod .. " + V", hl.dsp.exec_cmd("qs ipc call spotlight search 'c '"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
-- mode "maximized" keeps the bar and gaps; "fullscreen" hides them. These are
-- hyprlang's `fullscreen, 1` and `fullscreen, 0` -- the Lua names are the two
-- the API accepts ("maximize" is rejected).
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" })) -- muscle memory
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
		{ "left", -20, 0 },
		{ "right", 20, 0 },
		{ "up", 0, -20 },
		{ "down", 0, 20 },
		{ "H", -20, 0 },
		{ "L", 20, 0 },
		{ "K", 0, -20 },
		{ "J", 0, 20 },
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
		hl.exec_cmd(m[2])
	end, { locked = true, repeating = m[3] })
end

-- Config-drawn OSD. hl.notification is compositor-side: no D-Bus, no daemon, no
-- fork. It does NOT replace the notification daemon -- the Quickshell shell
-- serves *application* notifications over D-Bus, which Hyprland does not
-- implement. This is config feedback only.
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
		bar = "   "
			.. string.rep("\u{2588}", filled)
			.. string.rep("\u{2591}", 10 - filled)
			.. "   "
			.. value
			.. "/"
			.. maxv
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

-- XF86KbdBrightnessUp/Down are bound but the laptop never emits them: an
-- input.keyboard.key log caught volume (xkb 123) arriving while xkb 238/237
-- never appeared once, and asusd is not running to intercept them. The Super
-- binds are the ones that actually work; the XF86 ones cost nothing and start
-- working the day the keycode shows up.
hl.bind("XF86KbdBrightnessUp", function()
	kbd_backlight(1)
end, { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", function()
	kbd_backlight(-1)
end, { locked = true, repeating = true })
hl.bind(mod .. " + bracketright", function()
	kbd_backlight(1)
end, { repeating = true })
hl.bind(mod .. " + bracketleft", function()
	kbd_backlight(-1)
end, { repeating = true })

-- Screen-share indicator. Payload shape is undocumented, so it is read
-- defensively: boolean, string and table forms all resolve to a single bool.
-- A badge is cheap insurance against the "was I still sharing?" question.
local share_notif

hl.on("screenshare.state", function(e)
	local active
	local t = type(e)
	if t == "boolean" then
		active = e
	elseif t == "number" then
		active = e ~= 0
	elseif t == "string" then
		active = e ~= "" and e ~= "0" and e ~= "false" and e ~= "off"
	elseif t == "table" then
		active = e.sharing or e.state or e.active or e.enabled or false
		if type(active) == "string" then
			active = active ~= "" and active ~= "0" and active ~= "false"
		end
	else
		active = false
	end

	if share_notif then
		pcall(function()
			share_notif:dismiss()
		end)
		share_notif = nil
	end
	if active then
		share_notif = hl.notification.create({
			text = "  SCREEN IS BEING SHARED",
			duration = 3600000,
			color = c.base08,
			font_size = 16,
		})
	end
end)

-- Lid: blank the panel, do not suspend. What actually suspends is elogind --
-- HandleLidSwitch in /etc/elogind/logind.conf.
hl.bind("switch:on:Lid", function()
	hl.exec_cmd("hyprctl dispatch dpms off")
end, { locked = true })
hl.bind("switch:off:Lid", function()
	hl.exec_cmd("hyprctl dispatch dpms on")
end, { locked = true })
