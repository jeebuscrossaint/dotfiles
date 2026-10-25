-- Hyprland 0.56 config. Every option hl.config() accepts is listed below, so
-- anything can be changed in place; values not worth changing sit at the default.
--
-- Colours/fonts come from coat (coat-colors.lua beside this file).
-- Check without applying:  Hyprland --verify-config
-- Saving this file reloads it; so does Super+Shift+C.

local ok, c = pcall(require, "coat-colors")
if not ok then
	-- No coat fragment yet (fresh box, or `coat set` never ran): neutral fallback.
	c = {
		base00 = "rgba(1d1f21ff)", base03 = "rgba(707880ff)", base05 = "rgba(c5c8c6ff)",
		base08 = "rgba(cc6666ff)", base09 = "rgba(de935fff)", base0A = "rgba(f0c674ff)", base0C = "rgba(8abeb7ff)",
		base0D = "rgba(81a2beff)", base0E = "rgba(b294bbff)", shadow = "rgba(00000099)",
	}
end

local home = os.getenv("HOME")

-- hyprlock.conf sources these. coat runs `hyprctl reload` after every theme
-- change, so rewriting them here keeps the lock screen on the current scheme.
local lock = io.open(home .. "/.config/hypr/hyprlock-colors.conf", "w")
if lock then
	lock:write("$font = ", c.font_sans or "Sans", "\n")
	for k, v in pairs(c) do
		local hex = k:match("^base0%x$") and v:match("rgba%((%x%x%x%x%x%x)")
		if hex then
			lock:write("$", k, " = ", hex, "\n")
		end
	end
	lock:close()
end
local terminal = "kitty"
local mod = "SUPER"

-- fuzzel sized from the real screen: fuzzel.ini's 2560x1600 numbers, scaled.
-- A plain command, so it works on the right of a pipe.
local fb = io.open("/sys/class/graphics/fb0/virtual_size")
local sw, sh = (fb and fb:read("l") or "2560,1600"):match("(%d+),(%d+)")
if fb then
	fb:close()
end
local fuzzel = ("fuzzel --width=%d --line-height=%d"):format(sw * 50 // 2560, sh * 26 // 1600)

------------------------------------------------------------------- monitors
local edp = {
	output = "eDP-1",
	mode = "2560x1600@240",
	position = "0x0",
	scale = 1,
	transform = 0,
	bitdepth = 10,
	vrr = 0, -- 0 off, 1 on, 2 fullscreen only, 3 fullscreen video/game
	cm = "srgb", -- auto, srgb, wide, edid, hdr, hdredid (Super+F5 flips srgb <-> hdr)
	sdr_eotf = "default",
	supports_wide_color = 0, -- -1 off, 0 auto, 1 on
	supports_hdr = 1, -- the EDID under-reports; the connector does HDR
	max_luminance = 616,
	max_avg_luminance = 400,
	min_luminance = 0.0005,
	sdr_max_luminance = 220, -- what SDR white maps to in HDR; 80 looks dim
	sdr_min_luminance = 0.0,
	sdrbrightness = 1.0,
	sdrsaturation = 1.0,
	-- icc = "/path/to/profile.icc",
	-- mirror = "HDMI-A-1",
	-- reserved_area = 0,
	-- disabled = true,
}
hl.monitor(edp)
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@30", position = "2560x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

------------------------------------------------------------------------ env
hl.env("PATH", home .. "/.local/bin:" .. home .. "/.cargo/bin:" .. os.getenv("PATH"))
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_THEME", "WhiteSur-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "WhiteSur-cursors")
hl.env("HYPRCURSOR_SIZE", "24")

------------------------------------------------------------------ autostart
-- conky exits when its output disappears (lid close), so it is supervised.
-- Both panels share one loop: if either dies the other is killed too, so they
-- always come back up together instead of drifting apart.
-- ~/.cache/conky.off (Super+P) parks the loop instead of restarting it.
local conky_loop = "c=" .. home .. "/.cache; while :; do if [ -e $c/conky.off ]; then sleep 0.2; else"
	.. " conky >> $c/conky.log 2>&1 & r=$!;"
	.. " conky -c " .. home .. "/.config/conky/conky-left.conf >> $c/conky-left.log 2>&1 & l=$!;"
	.. " wait -n; kill $r $l 2>/dev/null; wait; sleep 3; fi; done"

hl.on("hyprland.start", function()
	for _, cmd in ipairs({
		"dbus-update-activation-environment --all",
		"/usr/lib/hyprpolkitagent/hyprpolkitagent",
		"audio-ensure",
		"dunst",
		"udiskie",
		"nvibrant 0 0 0 0",
--		"swaybg -m fill -i " .. home .. "/walls/mountain/a_mountain_with_snow_on_top_02.jpg",
		"hyprsunset",
		"battery-watch",
		"rog-control-center --background --autostart",
		conky_loop,
		-- Lock at 5 min, blank at 5:30 (OLED). hypridle.conf.
		"hypridle",
		"wl-paste --type text --watch cliphist store",
		"wl-paste --type image --watch cliphist store",
		"wl-clip-persist --clipboard regular",
		"/opt/activitywatch/aw-server-rust/aw-server-rust",
		"aw-awatcher",
		"hyprpm reload -n",
	}) do
		hl.exec_cmd(cmd)
	end
end)

-------------------------------------------------------------------- options
hl.config({
	general = {
		border_size = 2,
		gaps_in = 15,
		gaps_out = 25,
		float_gaps = 0,
		gaps_workspaces = 0,
		col = {
			active_border = { colors = { c.base0D }, angle = 0 },
			inactive_border = c.base03,
			nogroup_border = c.base03,
			nogroup_border_active = c.base0E,
		},
		layout = "dwindle",
		no_focus_fallback = false,
		resize_on_border = true,
		extend_border_grab_area = 15,
		hover_icon_on_border = true,
		allow_tearing = false,
		resize_corner = 0,
		snap = {
			enabled = true,
			window_gap = 10,
			monitor_gap = 10,
			border_overlap = false,
			respect_gaps = false,
		},
		modal_parent_blocking = true,
		locale = "",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2.0, -- 2 circle, 4 squircle
		active_opacity = 1.0,
		inactive_opacity = 0.90,
		fullscreen_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 40,
			render_power = 2, -- broad, soft falloff
			sharp = false,
			color = c.shadow,
			color_inactive = c.shadow,
			offset = { 0, 12 },
			scale = 1.0,
		},
		glow = {
			enabled = false,
			range = 10,
			render_power = 3,
			color = c.base0D,
			color_inactive = c.base03,
		},
		dim_modal = true,
		dim_inactive = false,
		dim_strength = 0.0,
		dim_special = 0.0,
		dim_around = 0.4, -- strength for layer/window rules with dim_around (fuzzel)
		screen_shader = "",
		border_part_of_window = false,
		blur = {
			enabled = true,
			size = 5,
			passes = 4,
			ignore_opacity = true,
			new_optimizations = true,
			xray = false,
			noise = 0.0117,
			contrast = 1.0,
			brightness = 1.0,
			vibrancy = 0.0,
			vibrancy_darkness = 0.0,
			special = false,
			popups = true,
			popups_ignorealpha = 0.2,
			input_methods = false,
			input_methods_ignorealpha = 0.2,
		},
		motion_blur = {
			enabled = true,
			samples = 64, -- the max; more copies per frame, smoother trail
		},
	},

	animations = {
		enabled = true,
		workspace_wraparound = false,
	},

	input = {
		kb_model = "",
		kb_layout = "us",
		kb_variant = "",
		kb_options = "",
		kb_rules = "",
		kb_file = "",
		numlock_by_default = false,
		resolve_binds_by_sym = false,
		repeat_rate = 50,
		repeat_delay = 200,
		sensitivity = 0.0,
		accel_profile = "flat", -- mice; the touchpad gets adaptive via hl.device below
		force_no_accel = false,
		rotation = 0,
		left_handed = false,
		scroll_points = "",
		scroll_method = "",
		scroll_button = 0,
		scroll_button_lock = false,
		scroll_factor = 1.0,
		natural_scroll = false,
		follow_mouse = 1, -- 0 off, 1 focus follows mouse, 2 click to focus keys, 3 fully detached
		follow_mouse_threshold = 0.0,
		focus_on_close = 0, -- 0 next in layout, 1 under cursor, 2 most recent
		mouse_refocus = true,
		float_switch_override_focus = 1,
		special_fallthrough = false,
		off_window_axis_events = 1,
		emulate_discrete_scroll = 1,
		follow_mouse_shrink = 0,
		touchpad = {
			disable_while_typing = true,
			natural_scroll = true, -- macOS-style on the touchpad, mouse wheel stays normal
			scroll_factor = 1.0,
			middle_button_emulation = false,
			tap_button_map = "",
			clickfinger_behavior = true, -- two-finger click = right click, three = middle
			tap_to_click = true,
			drag_lock = 0,
			tap_and_drag = true,
			flip_x = false,
			flip_y = false,
			drag_3fg = 0,
		},
		touchdevice = {
			transform = 0,
			-- output = "eDP-1", -- unset = auto
			enabled = true,
		},
		virtualkeyboard = {
			share_states = 2,
			release_pressed_on_close = false,
		},
		tablet = {
			transform = 0,
			output = "",
			region_position = { 0, 0 },
			absolute_region_position = false,
			region_size = { 0, 0 },
			relative_input = false,
			left_handed = false,
			active_area_size = { 0, 0 },
			active_area_position = { 0, 0 },
		},
		tablettool = {
			eraser_button_mode = 0,
			eraser_button_override = 0,
			pressure_range_min = -1.0,
			pressure_range_max = -1.0,
		},
	},

	gestures = {
		workspace_swipe_distance = 300,
		workspace_swipe_touch = false,
		workspace_swipe_invert = true,
		workspace_swipe_touch_invert = false,
		workspace_swipe_min_speed_to_force = 30,
		workspace_swipe_cancel_ratio = 0.5,
		workspace_swipe_create_new = true,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_forever = false,
		workspace_swipe_use_r = false,
		close_max_timeout = 1000,
		scrolling = {
			move_snap_to_grid = true,
			move_snap_cursor = true,
		},
	},

	group = {
		insert_after_current = true,
		focus_removed_window = true,
		merge_groups_on_drag = true,
		merge_groups_on_groupbar = true,
		col = {
			border_active = c.base0D,
			border_inactive = c.base03,
			border_locked_active = c.base09,
			border_locked_inactive = c.base03,
		},
		auto_group = true,
		drag_into_group = 1, -- 0 off, 1 on, 2 only onto the groupbar
		merge_floated_into_tiled_on_groupbar = false,
		group_on_movetoworkspace = false,
		groupbar = {
			enabled = true,
			disable_when_only = false,
			font_family = c.font_sans or "",
			font_weight_active = "bold",
			font_weight_inactive = "normal",
			font_size = 10,
			gradients = false,
			height = 16,
			indicator_gap = 0,
			indicator_height = 3,
			stacked = false,
			priority = 3,
			render_titles = true,
			scrolling = true,
			middle_click_close = true,
			rounding = 2,
			rounding_power = 2.0,
			gradient_rounding = 4,
			gradient_rounding_power = 2.0,
			round_only_edges = true,
			gradient_round_only_edges = true,
			text_color = c.base05,
			text_color_inactive = c.base03,
			text_color_locked_active = c.base05,
			text_color_locked_inactive = c.base03,
			col = {
				active = c.base0D,
				inactive = c.base03,
				locked_active = c.base09,
				locked_inactive = c.base03,
			},
			gaps_out = 2,
			gaps_in = 2,
			keep_upper_gap = true,
			text_offset = 0,
			text_padding = 0,
			blur = false,
		},
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		col = { splash = c.base05 },
		font_family = c.font_sans or "Sans",
		splash_font_family = "",
		force_default_wallpaper = 0,
		vrr = 0, -- global fallback; per-monitor vrr wins
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		name_vk_after_proc = true,
		always_follow_on_dnd = true,
		layers_hog_keyboard_focus = true,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		disable_autoreload = false,
		enable_swallow = true,
		swallow_regex = "^(kitty)$",
		swallow_exception_regex = "^(wev)$",
		focus_on_activate = true,
		mouse_move_focuses_monitor = true,
		allow_session_lock_restore = true,
		session_lock_xray = false,
		session_lock_blur = false,
		background_color = c.base00,
		close_special_on_empty = true,
		on_focus_under_fullscreen = 2, -- 0 keep fullscreen focused, 1 take over, 2 unfullscreen
		exit_window_retains_fullscreen = false,
		initial_workspace_tracking = 1,
		initial_workspace_token_timeout = 10,
		middle_click_paste = true,
		render_unfocused_fps = 15,
		disable_xdg_env_checks = false,
		disable_hyprland_guiutils_check = false,
		disable_watchdog_warning = false,
		lockdead_screen_delay = 1000,
		enable_anr_dialog = true,
		anr_missed_pings = 5,
		screencopy_force_8b = true,
		disable_scale_notification = false,
		size_limits_tiled = false,
	},

	binds = {
		pass_mouse_when_bound = false,
		scroll_event_delay = 300,
		workspace_back_and_forth = false,
		hide_special_on_workspace_change = false,
		allow_workspace_cycles = false,
		workspace_center_on = 1,
		focus_preferred_method = 0,
		ignore_group_lock = false,
		movefocus_cycles_fullscreen = false,
		movefocus_cycles_groupfirst = false,
		disable_keybind_grabbing = false,
		window_direction_monitor_fallback = true,
		allow_pin_fullscreen = false,
		drag_threshold = 0,
	},

	xwayland = {
		enabled = true,
		use_nearest_neighbor = true,
		force_zero_scaling = false,
		create_abstract_socket = false,
	},

	opengl = {
		nvidia_anti_flicker = true,
	},

	render = {
		direct_scanout = 0, -- 0 off, 1 on, 2 games only
		expand_undersized_textures = true,
		xp_mode = false,
		ctm_animation = 2,
		cm_enabled = true,
		send_content_type = true,
		cm_auto_hdr = 1, -- fullscreen HDR content flips the output to HDR on its own
		new_render_scheduling = true, -- triple-buffers when a frame runs late; 240 Hz leaves ~4 ms
		non_shader_cm = 2,
		cm_sdr_eotf = "default",
		commit_timing_enabled = true,
		icc_vcgt_enabled = true,
		use_shader_blur_blend = false,
		use_fp16 = 2,
		keep_unmodified_copy = 2,
		non_shader_cm_interop = 2,
		fp16_sdr_tf = 0,
	},

	cursor = {
		invisible = false,
		no_hardware_cursors = 2,
		no_break_fs_vrr = 2,
		min_refresh_rate = 24,
		hotspot_padding = 0,
		inactive_timeout = 3,
		no_warps = false,
		persistent_warps = false,
		warp_on_change_workspace = 0, -- 0 off, 1 warp to the last focused window, 2 always
		warp_on_toggle_special = 0,
		default_monitor = "",
		zoom_factor = 1.0,
		zoom_rigid = false,
		zoom_disable_aa = false,
		zoom_detached_camera = true,
		enable_hyprcursor = true,
		hide_on_key_press = true,
		hide_on_touch = true,
		hide_on_tablet = false,
		use_cpu_buffer = 2,
		sync_gsettings_theme = true,
		warp_back_after_non_mouse_input = false,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
		enforce_permissions = false,
	},

	debug = {
		overlay = false,
		damage_blink = false,
		gl_debugging = false,
		disable_logs = false, -- logs land in $XDG_RUNTIME_DIR/hypr/
		disable_time = true,
		damage_tracking = 2,
		enable_stdout_logs = false,
		manual_crash = 0,
		suppress_errors = false,
		disable_scale_checks = false,
		error_limit = 5,
		error_position = 0,
		colored_stdout_logs = true,
		log_damage = false,
		pass = false,
		full_cm_proto = false,
		ds_handle_same_buffer = true,
		ds_handle_same_buffer_fifo = true,
		fifo_pending_workaround = false,
		render_solitary_wo_damage = false,
		vfr = true,
		-- invalidate_fp16 = 1,
	},

	layout = {
		single_window_aspect_ratio = { 0, 0 },
		single_window_aspect_ratio_tolerance = 0.1,
	},

	dwindle = {
		force_split = 0, -- 0 follow mouse, 1 left/top, 2 right/bottom
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,
		permanent_direction_override = false,
		special_scale_factor = 0.9,
		split_width_multiplier = 1.0,
		use_active_for_splits = true,
		default_split_ratio = 1.0,
		split_bias = 0,
		precise_mouse_move = false,
	},

	master = {
		allow_small_split = false,
		special_scale_factor = 1.0,
		mfact = 0.55,
		new_status = "slave", -- master, slave, inherit
		new_on_top = false,
		new_on_active = "none", -- before, after, none
		orientation = "left", -- left, right, top, bottom, center
		slave_count_for_center_master = 2,
		center_master_fallback = "left",
		center_ignores_reserved = false,
		smart_resizing = true,
		drop_at_cursor = true,
		always_keep_position = false,
		focus_master_on_close = false,
	},

	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.5,
		focus_fit_method = 1, -- 0 center, 1 fit
		follow_focus = true,
		follow_min_visible = 0.4,
		explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
		direction = "right",
		wrap_focus = true,
		wrap_swapcol = true,
	},

	experimental = {
		wp_cm_1_2 = false,
	},

	input_capture = {
		capture_modifiers = false,
		enforce_barriers = true,
	},

	quirks = {
		prefer_hdr = 0,
		skip_non_kms_dmabuf_formats = false,
	},
})

----------------------------------------------------------------- animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeOutCubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
for _, a in ipairs({
	{ "global", "easeOutQuint" },
	{ "windows", "easeOutQuint", nil, 1.8 }, -- window leaves run faster: longer per-frame moves, longer motion-blur trails
	{ "windowsIn", "easeOutQuint", "slidefade 75%", 1.8 },
	{ "windowsOut", "linear", "slidefade 80%", 1.8 },
	{ "windowsMove", "easeOutCubic", nil, 1.8 },
	{ "layers", "easeOutQuint" },
	{ "layersIn", "easeOutQuint", "fade" },
	{ "layersOut", "linear", "fade" },
	{ "fade", "quick" },
	{ "fadeIn", "almostLinear" },
	{ "fadeOut", "almostLinear" },
	{ "fadeSwitch", "almostLinear" },
	{ "fadeShadow", "almostLinear" },
	{ "fadeGlow", "almostLinear" },
	{ "fadeDim", "almostLinear" },
	{ "fadeLayers", "almostLinear" },
	{ "fadeLayersIn", "almostLinear" },
	{ "fadeLayersOut", "almostLinear" },
	{ "fadePopups", "almostLinear" },
	{ "fadePopupsIn", "almostLinear" },
	{ "fadePopupsOut", "almostLinear" },
	{ "fadeDpms", "quick" },
	{ "border", "easeOutQuint" },
	{ "workspaces", "easeOutCubic", "slide" },
	{ "workspacesIn", "easeOutCubic", "slide" },
	{ "workspacesOut", "easeOutCubic", "slide" },
	{ "specialWorkspace", "easeInOutCubic", "slidefadevert 20%" },
	{ "specialWorkspaceIn", "easeInOutCubic", "slidefadevert 20%" },
	{ "specialWorkspaceOut", "easeInOutCubic", "slidefadevert 20%" },
	{ "zoomFactor", "quick" },
	{ "monitorAdded", "easeOutQuint" },
}) do
	hl.animation({ leaf = a[1], enabled = true, speed = a[4] or 2.6, bezier = a[2], style = a[3] })
end

hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "shadowangle", enabled = false })
hl.animation({ leaf = "glowangle", enabled = false })

------------------------------------------------------- devices and gestures
hl.device({ name = "asup1207:00-093a:3012-touchpad", accel_profile = "adaptive" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "scratch" })
-- 3-finger up is the overview's own gesture, set where the plugin is configured.

---------------------------------------------------------------------- rules
-- Smart gaps: a lone
-- tiled window (w[tv1]) or a maximized one (f[1], Super+F) fills the monitor
-- with no gaps, border or rounding. Floating windows keep theirs.
local zero_gaps = { top = 0, right = 0, bottom = 0, left = 0 }
for _, ws in ipairs({ "w[tv1]", "f[1]" }) do
	hl.workspace_rule({ workspace = ws, gaps_out = zero_gaps, gaps_in = zero_gaps })
	hl.window_rule({ name = "smart-" .. ws, match = { float = false, workspace = ws }, border_size = 0, rounding = 0 })
end

hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})
hl.window_rule({
	name = "float-dialogs",
	match = { title = "^(Open File|Save File|Save As|Choose Files?|Select a File)$" },
	float = true,
	center = true,
})
hl.window_rule({ name = "pinentry", match = { class = "^(pinentry-.*)$" }, float = true, stay_focused = true })
hl.window_rule({ name = "pip", match = { title = "^Picture-in-Picture$" }, float = true, pin = true })
hl.window_rule({ name = "translucent", match = { class = "^(com.microsoft.VSCode)$" }, opacity = "0.90 override 0.90 override" })
-- Anything fullscreen (video, games) holds off hypridle's lock and blank.
hl.window_rule({ name = "fullscreen-awake", match = { class = ".*" }, idle_inhibit = "fullscreen" })
hl.window_rule({ name = "webcam-opaque", match = { class = "^(guvcview)$" }, opacity = "1.0 override 1.0 override" })

-- Namespaces: fuzzel = launcher, dunst = notifications, slurp = selection.
hl.layer_rule({ name = "blur-launcher", match = { namespace = "^(fuzzel|launcher)$" }, blur = true, ignore_alpha = 0.2, dim_around = true, animation = "popin 90%" })
hl.layer_rule({ name = "blur-notifications", match = { namespace = "^(notifications|dunst)$" }, blur = true, ignore_alpha = 0.2, animation = "slide" })
-- Keeps frost and the close animation out of screenshots.
hl.layer_rule({ name = "selection", match = { namespace = "^selection$" }, no_anim = true })

------------------------------------------------------------------- helpers
local function notify(id, text)
	hl.exec_cmd("notify-send -a hyprland -h string:x-dunst-stack-tag:" .. id .. " -t 1500 '" .. text .. "'")
end

-- One key that means "wider/narrower" in whichever layout the workspace runs.
local grow_msg = { dwindle = "splitratio ", master = "mfact ", scrolling = "colresize " }
local function grow(delta)
	local ws = hl.get_active_workspace()
	local msg = grow_msg[ws and ws.tiled_layout or "dwindle"] or grow_msg.dwindle
	hl.dispatch(hl.dsp.layout(msg .. (delta > 0 and "+" or "") .. delta))
end

-- Per-workspace layout. Each switch is a runtime
-- workspace rule, so a config reload puts every workspace back on dwindle.
local layouts = { "dwindle", "scrolling", "master" }
local layout_rules = {}
local function cycle_layout()
	local ws = hl.get_active_workspace()
	if not ws then
		return
	end
	local i = 1
	for n, l in ipairs(layouts) do
		if l == ws.tiled_layout then
			i = n
		end
	end
	local next_layout = layouts[i % #layouts + 1]
	if layout_rules[ws.id] then
		layout_rules[ws.id]:set_enabled(false)
	end
	layout_rules[ws.id] = hl.workspace_rule({ workspace = tostring(ws.id), layout = next_layout })
	notify("layout", next_layout)
end

local gaps = { inner = 5, outer = 10, on = true }
local function set_gaps(di, do_)
	gaps.inner = math.max(0, gaps.inner + di)
	gaps.outer = math.max(0, gaps.outer + do_)
	local i, o = gaps.on and gaps.inner or 0, gaps.on and gaps.outer or 0
	hl.config({ general = { gaps_in = i, gaps_out = o } })
end

local hdr = false
local function toggle_hdr()
	hdr = not hdr
	edp.cm = hdr and "hdr" or "srgb"
	hl.monitor(edp)
	notify("hdr", hdr and "HDR on" or "HDR off")
end

-- Every regular window into a fuzzel list; picking one focuses it.
local window_picker = "hyprctl clients -j | jq -r '.[] | select(.workspace.id > 0)"
	.. " | \"\\(.class) — \\(.title)\\t\\(.address)\"' | " .. fuzzel
	.. " --dmenu --prompt 'window ' --with-nth=1 --accept-nth=2"
	.. " | xargs -r -I{} hyprctl dispatch 'hl.dsp.focus({ window = \"address:{}\" })'"

------------------------------------------------------------------- keybinds
-- apps
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("firefox-developer-edition"))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(fuzzel))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | " .. fuzzel .. " --dmenu --prompt 'clip ' | cliphist decode | wl-copy"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd(window_picker))
local shots = "mkdir -p ~/Pictures/Screenshots; "
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(shots
	.. [[f=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; grim -g "$(slurp)" "$f" && wl-copy < "$f"]]))
-- satty expands ~ and the date format in --output-filename itself.
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(shots
	.. [[grim -g "$(slurp)" - | satty --filename - --output-filename '~/Pictures/Screenshots/%Y%m%d_%H%M%S.png' --copy-command wl-copy --early-exit]]))
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a -n -r"))

-- theme
hl.bind(mod .. " + T", hl.dsp.exec_cmd([[s=$(coat list --no-preview | awk '/Slug:/{print $2}' | sort -u | ]]
	.. fuzzel .. [[ --dmenu --prompt 'theme ') && coat set "$s" >/dev/null 2>&1 && notify-send -t 2000 '󰏘  Theme' "switched to $s"]]))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd([[coat random -y >/dev/null 2>&1; notify-send -t 2000 '󰏘  Theme' "switched to $(awk '$1=="scheme:"{print $2}' ~/.local/state/coat/state.yaml)"]]))
hl.bind(mod .. " + ALT + T", hl.dsp.exec_cmd("coat match"))

-- session
hl.bind(mod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd(
	"if [ -e " .. home .. "/.cache/conky.off ]; then rm -f " .. home .. "/.cache/conky.off;"
		.. " else touch " .. home .. "/.cache/conky.off; pkill -x conky; fi"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mod .. " + F5", toggle_hdr)

-- toggles (osd tracks state itself, so the trackpad must stay an osd bind)
hl.bind(mod .. " + ALT + N", hl.dsp.exec_cmd("osd nightlight"))
hl.bind(mod .. " + ALT + bracketleft", hl.dsp.exec_cmd("osd nightlight warmer"))
hl.bind(mod .. " + ALT + bracketright", hl.dsp.exec_cmd("osd nightlight cooler"))
hl.bind(mod .. " + ALT + V", hl.dsp.exec_cmd("osd touchpad"))
hl.bind("XF86Launch1", hl.dsp.exec_cmd("rog-control-center"))

-- window state
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + X", hl.dsp.window.kill())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Fullscreen as far as the app knows, still tiled as far as the layout knows.
hl.bind(mod .. " + A", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Y", hl.dsp.window.pin())
hl.bind(mod .. " + U", hl.dsp.window.pseudo())
hl.bind(mod .. " + SHIFT + O", hl.dsp.window.center())

-- scratchpad and minimize, both special workspaces
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))
hl.bind(mod .. " + minus", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.workspace.toggle_special("minimized"))

-- groups (tabs)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + ALT + G", hl.dsp.group.lock({ action = "toggle" }))
hl.bind(mod .. " + Tab", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.group.prev())

-- overview (if hyprpm has it loaded)
hl.bind(mod .. " + O", function()
	if hl.plugin.scrolloverview then
		hl.plugin.scrolloverview.overview("toggle all")
	elseif hl.plugin.overview then
		hl.plugin.overview.toggle()
	end
end)
hl.bind(mod .. " + Z", function()
	if hl.plugin.macos_zoom then
		hl.plugin.macos_zoom.adjust("toggle")
	end
end)

-- focus
for _, d in ipairs({ { "left", "H" }, { "right", "L" }, { "up", "K" }, { "down", "J" } }) do
	hl.bind(mod .. " + " .. d[1], hl.dsp.focus({ direction = d[1] }))
	hl.bind(mod .. " + SHIFT + " .. d[1], hl.dsp.window.swap({ direction = d[1] }))
	hl.bind(mod .. " + SHIFT + " .. d[2], hl.dsp.window.swap({ direction = d[1] }))
end
hl.bind(mod .. " + J", hl.dsp.window.cycle_next())
hl.bind(mod .. " + K", hl.dsp.window.cycle_next({ next = false }))
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind("ALT + SHIFT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
	hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(mod .. " + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mod .. " + period", hl.dsp.focus({ monitor = "r" }))
hl.bind(mod .. " + SHIFT + comma", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- floating move / resize (on SUPER so apps keep Ctrl+Shift+arrows)
for _, d in ipairs({ { "left", -50, 0 }, { "right", 50, 0 }, { "up", 0, -50 }, { "down", 0, 50 } }) do
	hl.bind(mod .. " + CTRL + " .. d[1], hl.dsp.window.move({ x = d[2], y = d[3], relative = true }), { repeating = true })
	hl.bind(mod .. " + CTRL + SHIFT + " .. d[1], hl.dsp.window.resize({ x = d[2], y = d[3], relative = true }), { repeating = true })
end

-- layout
hl.bind(mod .. " + backslash", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + Space", cycle_layout)

-- Resize mode: arrows or hjkl resize the focused window until Escape/Return.
hl.bind(mod .. " + R", function()
	hl.dispatch(hl.dsp.submap("resize"))
	notify("submap", "resize: arrows/hjkl, Esc to finish")
end)
hl.define_submap("resize", function()
	for _, d in ipairs({ { "right", "L", 40, 0 }, { "left", "H", -40, 0 }, { "down", "J", 0, 40 }, { "up", "K", 0, -40 } }) do
		hl.bind(d[1], hl.dsp.window.resize({ x = d[3], y = d[4], relative = true }), { repeating = true })
		hl.bind(d[2], hl.dsp.window.resize({ x = d[3], y = d[4], relative = true }), { repeating = true })
	end
	hl.bind("Escape", hl.dsp.submap("reset"))
	hl.bind("Return", hl.dsp.submap("reset"))
end)
hl.bind(mod .. " + ALT + period", function() grow(0.05) end, { repeating = true })
hl.bind(mod .. " + ALT + comma", function() grow(-0.05) end, { repeating = true })
hl.bind(mod .. " + ALT + L", function() set_gaps(1, 2) end, { repeating = true })
hl.bind(mod .. " + ALT + H", function() set_gaps(-1, -2) end, { repeating = true })
hl.bind(mod .. " + ALT + 0", function()
	gaps.on = not gaps.on
	set_gaps(0, 0)
end)

-- workspaces: Super+N go, Super+Shift+N send (stay), Super+Ctrl+N send and follow
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
	hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + ALT + left", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mod .. " + ALT + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + ALT + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mod .. " + ALT + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

-- mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + mouse:274", hl.dsp.window.float({ action = "toggle" }))

-- media and hardware keys. A dispatcher object with locked = true never fires,
-- so these are wrapped in functions.
for _, m in ipairs({
	{ "XF86AudioRaiseVolume", "osd volume up", true },
	{ "XF86AudioLowerVolume", "osd volume down", true },
	{ "XF86AudioMute", "osd volume mute" },
	{ "XF86AudioMicMute", "osd mic mute" },
	{ "XF86AudioPlay", "osd playpause" },
	{ "XF86AudioPause", "osd playpause" },
	{ "XF86Launch3", "osd playpause" },
	{ "XF86AudioNext", "osd next" },
	{ "XF86AudioPrev", "osd prev" },
	{ "XF86MonBrightnessUp", "osd brightness up", true },
	{ "XF86MonBrightnessDown", "osd brightness down", true },
	{ "XF86KbdBrightnessUp", "osd kbd up", true },
	{ "XF86KbdBrightnessDown", "osd kbd down", true },
	{ "XF86TouchpadToggle", "osd touchpad" },
	-- Binding these doesn't swallow them: xkb has already toggled the LED.
	{ "Caps_Lock", "osd capslock", false, true },
	{ "Num_Lock", "osd numlock", false, true },
}) do
	hl.bind(m[1], function()
		hl.exec_cmd(m[2])
	end, { locked = true, repeating = m[3] or false, non_consuming = m[4] or false })
end

-------------------------------------------------------------------- plugins

local function coat_alpha(color, alpha)
	return color:gsub("rgba%((%x%x%x%x%x%x)%x%x%)", "rgba(%1" .. alpha .. ")")
end

local overview_panel = coat_alpha(c.base00, "d9")
local overview_panel_border = coat_alpha(c.base03, "aa")
local overview_active = coat_alpha(c.base03, "e6")
local overview_inactive = coat_alpha(c.base00, "b3")
local overview_active_border = coat_alpha(c.base0D, "ff")
local overview_inactive_border = coat_alpha(c.base03, "88")

for _, p in ipairs(hl.get_loaded_plugins()) do
	if p.name == "hyprglass" then
		-- Liquid glass on translucent windows and layers; replaces Hyprland's blur
		-- on what it covers. Tint is the scheme's background at low alpha.
		local hg = hl.plugin.hyprglass
		hg.config({
			enabled = true,
			manage_window_blur = true, -- sets noblur on glassed windows so cached blur can't hide the glass
			skip_opaque_windows = true,
			blur_fold = true,
			default_theme = "dark", -- dark, light
			default_preset = "pomme", -- Apple Liquid Glass look-alike; also default, high_contrast, subtle, clear, glass
			blur_strength = 2.0, -- x12 px
			blur_iterations = 3, -- 1-5
			noise_strength = 0.0,
			refraction_strength = 0.6,
			refraction_flow = 0.0,
			refraction_spread = 1.0,
			chromatic_aberration = 0.5,
			fresnel_strength = 0.6,
			fresnel_tint = 0.0,
			fresnel_color = 0xffffff00,
			specular_strength = 0.8,
			specular_angle = 0.0,
			bevel_strength = 0.0,
			bevel_size = 6.0,
			bevel_color = 0xffffff00,
			bevel_tint = 0.0,
			bevel_angle = 315.0,
			bevel_shadow = 0.0,
			glass_opacity = 1.0,
			edge_thickness = 0.06,
			edge_thickness_px = 0.0,
			edge_height = 0.0,
			fresnel_reflection = 0.0,
			tint_color = tonumber((c.base00:match("rgba%((%x%x%x%x%x%x)") or "8899aa") .. "22", 16),
			lens_distortion = 0.5,
			self_sample = 0.0,
			xray = 0,
			focus_light = 0.0,
			focus_light_color = 0xffffff00,
			frost = 0.0,
			frost_blur = 3.0,
			dark = {
				brightness = 0.82,
				contrast = 0.90,
				saturation = 0.80,
				vibrancy = 0.15,
				vibrancy_darkness = 0.0,
				adaptive_dim = 0.4,
				adaptive_boost = 0.0,
			},
			light = {
				brightness = 1.12,
				contrast = 0.92,
				saturation = 0.85,
				vibrancy = 0.12,
				vibrancy_darkness = 0.0,
				adaptive_dim = 0.0,
				adaptive_boost = 0.4,
			},
			layers = { enabled = false }, -- on: closing fuzzel/dunst overshoots bright for ~250ms (v0.11.0)
		})
		-- Extends the built-in preset: only the keys set here change.
		hg.preset("pomme", { blur_iterations = 4, blur_strength = 2.0 })
		-- fuzzel and dunst, used once layers are enabled again
		hg.layer("launcher", { preset = "pomme" })
		hg.layer("notifications", { preset = "pomme" })
	elseif p.name == "scrolloverview" then
		-- niri-style: the desktop zooms out to a strip of workspaces.
		hl.config({
			plugin = {
				scrolloverview = {
					gesture_distance = 300,
					scale = 0.5,
					workspace_gap = 50,
					layout = "vertical", -- vertical, horizontal, auto (per monitor orientation)
					cross_monitor_drag = false,
					wallpaper = 0, -- 0 global, 1 per workspace, 2 both
					blur = true,
					shadow = {
						enabled = true,
						range = 50,
						render_power = 3,
						-- color unset: decoration.shadow.color
					},
					input = {
						scroll_event_delay = 200,
						touchpad_scroll_factor = 1.0,
						left_handed = 2, -- 2 follows input.left_handed
						scrolling_mode = 0,
						drag_mode = 0,
						drag_threshold = 10,
					},
				},
			},
		})
		hl.plugin.scrolloverview.gesture({ fingers = 3, direction = "up" })
	elseif p.name == "Hyprspace" then
		hl.gesture({ fingers = 3, direction = "up", action = function() hl.plugin.overview.toggle() end })
		hl.config({
			plugin = {
				overview = {
					panelColor = overview_panel,
					panelBorderColor = overview_panel_border,
					workspaceActiveBackground = overview_active,
					workspaceInactiveBackground = overview_inactive,
					workspaceActiveBorder = overview_active_border,
					workspaceInactiveBorder = overview_inactive_border,
					disableBlur = false,
					panelBorderWidth = 1,
					workspaceBorderSize = 1,
					workspaceMargin = 12,
					centerAligned = 1,
					hideRealLayers = 1,
					overrideGaps = 1,
					gapsIn = 15,
					gapsOut = 25,
					onBottom = true,
					autoDrag = true,
				},
			},
		})
	elseif p.name == "hyprbars" then
		hl.config({
			plugin = {
				hyprbars = {
					enabled = false,
				},
			},
		})
	elseif p.name == "hyprfocus" then
		hl.config({
			plugin = {
				hyprfocus = {
					enable = true,
					animate_floating = true,
					keyboard_focus_animation = "flash",
					mouse_focus_animation = "flash",
					fade_opacity = 0.8,
				},
			},
		})
	elseif p.name == "dynamic-cursors" then
		hl.config({
			plugin = {
				dynamic_cursors = {
					enabled = false, -- software cursor: costs frames at 240 Hz
					mode = "tilt",
					threshold = 2,
					tilt = {
						limit = 4500,
						activation = "negative_quadratic",
						window = 100,
						full = 35,
					},
					shake = {
						enabled = true,
						threshold = 6.0,
						base = 4.0,
						speed = 4.0,
						influence = 0.0,
						limit = 0.0,
						timeout = 2000,
						effects = false,
						ipc = false,
					},
					hyprcursor = {
						enabled = true,
						nearest = 1,
						resolution = -1,
						fallback = "clientside",
					},
				},
			},
		})
	end
end
