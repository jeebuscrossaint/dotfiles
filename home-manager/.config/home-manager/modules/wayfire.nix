# Wayfire configuration for Home Manager inspired by Sway config
{pkgs, ...}: {
  wayland.windowManager.wayfire = {
    enable = true;
    xwayland.enable = true;
    # package = pkgs.emptyDirectory;

    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];

    settings = {
      # Core plugins - only essential ones enabled for labwc-like experience
      core = {
        plugins = "animate autostart command decoration move place resize switcher vswitch window-rules wm-actions shadows";
        xwayland = true;
        vwidth = 10;  # 10 workspaces horizontally
        vheight = 1;  # 1 row (like labwc)
        preferred_decoration_mode = "server";
        close_top_view = "<super> KEY_C";
        focus_button_passthrough = true;
        focus_buttons = "BTN_LEFT | BTN_MIDDLE | BTN_RIGHT";
        max_render_time = "-1";
        transaction_timeout = "100";
        # Make workspaces global across all monitors
        vwidth_per_output = false;
        vheight_per_output = false;
      };

      # Input configuration
      input = {
        xkb_layout = "us";
        xkb_variant = "";
        xkb_options = "";
        xkb_model = "";
        xkb_rules = "";
        kb_numlock_default_state = true;
        kb_repeat_delay = "400";
        kb_repeat_rate = "40";
        left_handed_mode = false;
        middle_emulation = false;
        modifier_binding_timeout = "400";
        mouse_accel_profile = "default";
        mouse_cursor_speed = "0.000000";
        mouse_scroll_speed = "1.000000";
        tablet_motion_mode = "default";
        touchpad_accel_profile = "default";
        touchpad_click_method = "default";
        touchpad_cursor_speed = "0.000000";
        touchpad_dwt = true;
        touchpad_dwmw = true;
        touchpad_natural_scroll = false;
        touchpad_scroll_speed = "1.000000";
        touchpad_tap_to_click = true;
      };

      # Output configuration
      eDP-1 = {
        mode = "2560x1600@240000";
        position = "0,0";
        transform = "normal";
        scale = "1.000000";
      };

      "HDMI-A-1" = {
        mode = "1920x1080@60000";
        position = "2560,0";
        transform = "normal";
        scale = "1.000000";
      };

      # Decoration (borders and titlebars)
      decoration = {
       # active_color = "0.5 0.5 0.5 1.0";
       # inactive_color = "0.3 0.3 0.3 1.0";
        border_size = 2;
        title_height = 0;  # No titlebar
        ignore_views = "none";
        button_order = "minimize maximize close";
       # font = "sans";
      };

      # Shadows plugin
      shadows = {
        # Uncomment to customize shadow appearance
        # active_shadow_color = "0.0 0.0 0.0 0.8";
        # inactive_shadow_color = "0.0 0.0 0.0 0.6";
        # shadow_offset_x = "0";
        # shadow_offset_y = "0";
        # shadow_radius = "25";
      };

      # ============================================
      # OPTIONAL PLUGINS (commented out by default)
      # Add these to core.plugins to enable them
      # ============================================

      # Alpha - Window transparency
      # alpha = {
      #   min_value = "0.100000";
      #   modifier = "<super> <alt>";
      # };

      # Annotate - Draw on screen
      # annotate = {
      #   clear_workspace = "<super> <shift> KEY_C";
      #   draw = "<super> BTN_LEFT";
      #   from_center = true;
      #   line_width = "3.000000";
      #   method = "draw";
      #   stroke_color = "1.000000 0.000000 0.000000 1.000000";
      # };

      # Background view - Set background
      # background-view = {
      #   command = "mpv --loop=inf";
      #   file = "";
      #   app_id = "mpvbg";
      # };

      # Blur - Blur windows behind transparent windows
      # blur = {
      #   blur_by_default = "type is \"toplevel\"";
      #   bokeh_degrade = "1";
      #   bokeh_iterations = "15";
      #   bokeh_offset = "5.000000";
      #   box_degrade = "1";
      #   box_iterations = "2";
      #   box_offset = "1.000000";
      #   gaussian_degrade = "1";
      #   gaussian_iterations = "2";
      #   gaussian_offset = "1.000000";
      #   kawase_degrade = "8";
      #   kawase_iterations = "2";
      #   kawase_offset = "2.000000";
      #   method = "kawase";
      #   saturation = "1.000000";
      #   toggle = "none";
      # };

      # Cube - 3D cube workspace switching
      # cube = {
      #   activate = "<super> <alt> BTN_LEFT";
      #   background = "0.100000 0.100000 0.100000 1.000000";
      #   background_mode = "simple";
      #   cubemap_image = "";
      #   deform = "0";
      #   initial_animation = "350";
      #   light = true;
      #   rotate_left = "<super> <ctrl> KEY_LEFT";
      #   rotate_right = "<super> <ctrl> KEY_RIGHT";
      #   skydome_mirror = true;
      #   skydome_texture = "";
      #   speed_spin_horiz = "0.020000";
      #   speed_spin_vert = "0.020000";
      #   speed_zoom = "0.070000";
      #   zoom = "0.100000";
      # };

      # Expo - Workspace overview
      # expo = {
      #   background = "0.100000 0.100000 0.100000 1.000000";
      #   duration = "300";
      #   inactive_brightness = "0.700000";
      #   keyboard_interaction = "true";
      #   offset = "10";
      #   select_workspace_1 = "KEY_1";
      #   select_workspace_2 = "KEY_2";
      #   select_workspace_3 = "KEY_3";
      #   select_workspace_4 = "KEY_4";
      #   select_workspace_5 = "KEY_5";
      #   select_workspace_6 = "KEY_6";
      #   select_workspace_7 = "KEY_7";
      #   select_workspace_8 = "KEY_8";
      #   select_workspace_9 = "KEY_9";
      #   toggle = "<super> KEY_E";
      # };

      # Fisheye - Magnify area around cursor
      # fisheye = {
      #   radius = "450.000000";
      #   toggle = "<super> <ctrl> KEY_F";
      #   zoom = "7.000000";
      # };

      # Force fullscreen - Force apps to go fullscreen
      # force-fullscreen = {
      #   constraint_area = "view";
      #   preserve_aspect = "true";
      #   transparent_behind_views = "true";
      #   x_skew = "0.000000";
      #   y_skew = "0.000000";
      # };

      # Grid - Window tiling/snapping
      # grid = {
      #   duration = "300";
      #   restore = "<super> KEY_DOWN | <super> KEY_KP0";
      #   slot_b = "<super> KEY_KP2";
      #   slot_bl = "<super> KEY_KP1";
      #   slot_br = "<super> KEY_KP3";
      #   slot_c = "<super> KEY_UP | <super> KEY_KP5";
      #   slot_l = "<super> KEY_LEFT | <super> KEY_KP4";
      #   slot_r = "<super> KEY_RIGHT | <super> KEY_KP6";
      #   slot_t = "<super> KEY_KP8";
      #   slot_tl = "<super> KEY_KP7";
      #   slot_tr = "<super> KEY_KP9";
      #   type = "crossfade";
      # };

      # Idle - Screen timeout
      # idle = {
      #   cube_max_zoom = "1.500000";
      #   cube_rotate_speed = "1.000000";
      #   cube_zoom_speed = "1000";
      #   disable_on_fullscreen = "true";
      #   dpms_timeout = "600";
      #   screensaver_timeout = "300";
      #   toggle = "<super> KEY_Z";
      # };

      # Invert - Invert colors
      # invert = {
      #   preserve_hue = "false";
      #   toggle = "<super> KEY_I";
      # };

      # Mag - Magnifier
      # mag = {
      #   default_height = "500";
      #   toggle = "<super> KEY_M";
      #   zoom_level = "75";
      # };

      # Oswitch - Overview workspace switcher
      # oswitch = {
      #   next_output = "<super> KEY_K";
      #   next_output_with_win = "<super> <shift> KEY_K";
      #   prev_output = "<super> KEY_J";
      #   prev_output_with_win = "<super> <shift> KEY_J";
      # };

      # Scale - Window overview
      # scale = {
      #   allow_zoom = "false";
      #   bg_color = "0.000000 0.000000 0.000000 0.500000";
      #   duration = "750";
      #   inactive_alpha = "0.750000";
      #   interact = "false";
      #   middle_click_close = "false";
      #   minimized_alpha = "0.450000";
      #   spacing = "50";
      #   text_color = "0.000000 0.000000 0.000000 1.000000";
      #   title_font_size = "16";
      #   title_overlay = "all";
      #   title_position = "center";
      #   toggle = "none";
      #   toggle_all = "none";
      # };

      # Scale-title-filter - Filter windows by title in scale
      # scale-title-filter = {
      #   bg_color = "0.000000 0.000000 0.000000 0.500000";
      #   case_sensitive = "false";
      #   font_size = "30";
      #   overlay = "true";
      #   share_filter = "false";
      #   text_color = "1.000000 1.000000 1.000000 1.000000";
      # };

      # Simple-tile - Simple tiling
      # simple-tile = {
      #   animation_duration = "300";
      #   button_move = "<super> BTN_LEFT";
      #   button_resize = "<super> BTN_RIGHT";
      #   inner_gap_size = "5";
      #   keep_fullscreen_on_adjacent = "true";
      #   key_focus_above = "<super> KEY_K";
      #   key_focus_below = "<super> KEY_J";
      #   key_focus_left = "<super> KEY_H";
      #   key_focus_right = "<super> KEY_L";
      #   key_toggle = "<super> KEY_T";
      #   outer_horiz_gap_size = "0";
      #   outer_vert_gap_size = "0";
      #   preview_base_border = "0.400000 0.500000 0.600000 0.900000";
      #   preview_base_color = "0.070000 0.050000 0.150000 0.900000";
      #   preview_border_width = "3";
      #   tile_by_default = "all";
      # };

      # Viewport-shot - Screenshot individual workspace
      # viewport-shot = {
      #   capture = "<super> KEY_P";
      #   command = "notify-send \"Screenshot saved\"";
      #   filename = "/tmp/viewport-%F-%T.png";
      # };

      # Water - Water effect on windows
      # water = {
      #   activate = "<super> <ctrl> BTN_LEFT";
      # };

      # Wf-info - Show Wayfire info
      # wf-info = {
      #   text_color = "1.000000 1.000000 1.000000 1.000000";
      #   text_size = "30";
      #   toggle = "<super> <shift> KEY_I";
      # };

      # Winzoom - Zoom into window
      # winzoom = {
      #   dec_x_binding = "<super> <ctrl> KEY_LEFT";
      #   dec_y_binding = "<super> <ctrl> KEY_DOWN";
      #   inc_x_binding = "<super> <ctrl> KEY_RIGHT";
      #   inc_y_binding = "<super> <ctrl> KEY_UP";
      #   modifier = "<super> <ctrl>";
      #   nearest_filtering = "false";
      #   preserve_aspect = "true";
      #   zoom_step = "0.100000";
      # };

      # Wobbly - Wobbly windows when moving
      # wobbly = {
      #   friction = "3.000000";
      #   grid_resolution = "6";
      #   spring_k = "8.000000";
      # };

      # Workspace-names - Name your workspaces
      # workspace-names = {
      #   background_color = "0.133333 0.133333 0.133333 1.000000";
      #   display_duration = "500";
      #   font = "sans-serif";
      #   margin = "0";
      #   position = "center";
      #   show_option_names = "false";
      #   text_color = "1.000000 1.000000 1.000000 1.000000";
      #   text_size = "30";
      # };

      # Zoom - Desktop zoom
      # zoom = {
      #   interpolation_method = "0";
      #   modifier = "<super>";
      #   smoothing_duration = "300";
      #   speed = "0.010000";
      # };

      # ============================================
      # ACTIVE CONFIGURATION (labwc-like)
      # ============================================

      # Window animations (minimal fade)
      animate = {
        close_animation = "fade";
        duration = "200";
        enabled_for = "all";
        fade_duration = "200";
        fade_enabled_for = "all";
        fire_duration = "300";
        fire_enabled_for = "none";
        fire_particle_size = "16.000000";
        fire_particles = "2000";
        open_animation = "fade";
        random_fire_color = "false";
        startup_duration = "600";
        zoom_duration = "200";
        zoom_enabled_for = "none";
      };

      # Window placement
      place = {
        mode = "center";
      };

      # Workspace switching (arrow keys like labwc)
      vswitch = {
        binding_1 = "<super> KEY_1";
        binding_2 = "<super> KEY_2";
        binding_3 = "<super> KEY_3";
        binding_4 = "<super> KEY_4";
        binding_5 = "<super> KEY_5";
        binding_6 = "<super> KEY_6";
        binding_7 = "<super> KEY_7";
        binding_8 = "<super> KEY_8";
        binding_9 = "<super> KEY_9";
        binding_0 = "<super> KEY_0";
        binding_down = "none";
        binding_last = "none";
        binding_left = "none";
        binding_right = "none";
        binding_up = "none";
        binding_win_1 = "<super> <shift> KEY_1";
        binding_win_2 = "<super> <shift> KEY_2";
        binding_win_3 = "<super> <shift> KEY_3";
        binding_win_4 = "<super> <shift> KEY_4";
        binding_win_5 = "<super> <shift> KEY_5";
        binding_win_6 = "<super> <shift> KEY_6";
        binding_win_7 = "<super> <shift> KEY_7";
        binding_win_8 = "<super> <shift> KEY_8";
        binding_win_9 = "<super> <shift> KEY_9";
        binding_win_0 = "<super> <shift> KEY_0";
        duration = "300";
        gap = "20";
        wraparound = "false";
        send_win_down = "none";
        send_win_last = "none";
        send_win_left = "none";
        send_win_right = "none";
        send_win_up = "none";
        with_win_down = "none";
        with_win_last = "none";
        with_win_left = "none";
        with_win_right = "none";
        with_win_up = "none";
      };

      # Move windows (Super + Left mouse like labwc)
      move = {
        activate = "<super> BTN_LEFT";
        enable_snap = "true";
        enable_snap_off = "true";
        join_views = "false";
        preview_base_border = "0.400000 0.500000 0.600000 0.900000";
        preview_base_color = "0.070000 0.050000 0.150000 0.900000";
        preview_border_width = "3";
        quarter_snap_threshold = "50";
        snap_threshold = "10";
        snap_off_threshold = "10";
        workspace_switch_after = "-1";
      };

      # Resize windows (Super + Right mouse like labwc)
      resize = {
        activate = "<super> BTN_RIGHT";
        activate_preserve_aspect = "none";
      };

      # Window switcher (Alt+Tab)
      switcher = {
        next_view = "<alt> KEY_TAB";
        prev_view = "<alt> <shift> KEY_TAB";
        speed = "500";
        view_thumbnail_scale = "1.000000";
      };

      # Fast window switcher
      fast-switcher = {
        activate = "none";
        activate_backward = "none";
        inactive_alpha = "0.700000";
      };

      # Window rules
      window-rules = {
        # Enable titlebar for foot terminal so it can be resized
        foot_titlebar = "on created if app_id is \"foot\" then set decoration \"server\"";
        # Add custom window rules here if needed
        # Example:
        # rule_1 = "on created if app_id is \"firefox\" then set floating true"
      };

      # Command bindings
      command = {
        # Basic bindings
        binding_terminal = "<super> KEY_Q";
        command_terminal = "foot";
        
        binding_launcher = "<super> KEY_D";
        command_launcher = "rofi -show drun";
        
        binding_lock = "<super> KEY_L";
        command_lock = "swaylock -C ~/.config/swaylock/config";
        
        binding_wallpaper = "<super> KEY_G";
        command_wallpaper = "new-wallpaper";
        
        binding_bruh = "<super> KEY_B";
        command_bruh = "~/dotfiles/bruh.sh --dunst";
        
        binding_clipboard = "<super> KEY_INSERT";
        command_clipboard = "sh -c 'cliphist list | bemenu | cliphist decode | wl-copy'";
        
        # Screenshot
        binding_screenshot = "<super> <shift> KEY_S";
        command_screenshot = "~/dotfiles/swayscreenshot.sh";
        
        # Media keys
        binding_volume_up = "KEY_VOLUMEUP";
        command_volume_up = "volumectl up";
        
        binding_volume_down = "KEY_VOLUMEDOWN";
        command_volume_down = "volumectl down";
        
        binding_mute = "KEY_MUTE";
        command_mute = "volumectl toggle-mute";
        
        binding_mic_mute = "KEY_MICMUTE";
        command_mic_mute = "volumectl -m toggle-mute";
        
        binding_play = "KEY_PLAYPAUSE";
        command_play = "playerctl play-pause";
        
        binding_brightness_up = "KEY_BRIGHTNESSUP";
        command_brightness_up = "lightctl up";
        
        binding_brightness_down = "KEY_BRIGHTNESSDOWN";
        command_brightness_down = "lightctl down";
        
        repeatable_binding_volume_up = "none";
        repeatable_binding_volume_down = "none";
      };

      # Window management actions
      wm-actions = {
        minimize = "none";
        send_to_back = "none";
        toggle_always_on_top = "none";
        toggle_fullscreen = "<super> KEY_F";
        toggle_maximize = "none";
        toggle_showdesktop = "none";
        toggle_sticky = "none";
        toggle_floating = "<super> <shift> KEY_V";
      };

      # Autostart programs
      autostart = {
        autostart_wf_shell = false;
        a_numlockwl = "numlockwl";
        b_fnott = "fnott";
        c_udiskie = "udiskie";
        d_nm_applet = "nm-applet";
        e_clipboard_text = "wl-paste --type text --watch cliphist store";
        f_clipboard_image = "wl-paste --type image --watch cliphist store";
        g_swaybg = "swaybg";
        h_swww = "swww-daemon";
        i_dbus = "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
        j_gamemoded = "gamemoded";
        k_avizo = "avizo-service";
        l_swayidle = "swayidle";
        m_swaync = "swaync";
        n_waybar = "waybar";
      };
    };
  };

  # WF-Shell configuration (disabled by default, using waybar instead)
  wayland.windowManager.wayfire.wf-shell = {
    enable = false;
    settings = {
      panel = {
        position = "bottom";
        layer = "bottom";
        height = 32;
        widgets_left = "menu spacing4 launchers spacing4 window-list";
        widgets_center = "clock";
        widgets_right = "spacing4 network spacing4 volume spacing4 battery";
      };

      clock = {
        format = "%H:%M";
        font = "sans 11";
      };

      panel-label = {
        font = "sans 10";
      };
    };
  };
}