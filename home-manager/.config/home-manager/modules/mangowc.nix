{pkgs, ...}: {
  # Create the mangowc config directory and file
  home.file.".config/mango/config.conf".text = ''
    # ============================================
    # MANGOWC CONFIGURATION
    # Auto-generated from Nix Home Manager
    # ============================================

    # ============================================
    # ENVIRONMENT VARIABLES
    # ============================================
    env=XCURSOR_SIZE,24
    env=QT_QPA_PLATFORM,wayland;xcb
    env=QT_QPA_PLATFORMTHEME,qt5ct
    env=QT_AUTO_SCREEN_SCALE_FACTOR,1
    env=GTK_IM_MODULE,fcitx
    env=QT_IM_MODULE,fcitx
    env=SDL_IM_MODULE,fcitx
    env=XMODIFIERS,@im=fcitx
    env=GLFW_IM_MODULE,ibus

    # ============================================
    # WINDOW EFFECTS (Disabled - matching Sway)
    # ============================================
    blur=1
    blur_layer=1
    blur_optimized=1
    blur_params_num_passes=2
    blur_params_radius=5
    blur_params_noise=0.02
    blur_params_brightness=0.9
    blur_params_contrast=0.9
    blur_params_saturation=1.2
    shadows=1
    shadow_only_floating=0
    layer_shadows=0
    shadows_size=10
    shadows_blur=15
    shadows_position_x=0
    shadows_position_y=0
    shadowscolor=0x000000ff
    border_radius=7
    no_radius_when_single=1
    focused_opacity=1.0
    unfocused_opacity=1.0

    # ============================================
    # ANIMATIONS (Enabled - smooth like Sway)
    # ============================================
    animations=1
    layer_animations=0
    animation_type_open=slide
    animation_type_close=slide
    layer_animation_type_open=slide
    layer_animation_type_close=slide
    animation_fade_in=1
    animation_fade_out=1
    tag_animation_direction=1
    zoom_initial_ratio=0.3
    zoom_end_ratio=0.8
    fadein_begin_opacity=0.5
    fadeout_begin_opacity=0.8
    animation_duration_move=200
    animation_duration_open=200
    animation_duration_tag=200
    animation_duration_close=200
    animation_duration_focus=0
    animation_curve_open=0.46,1.0,0.29,1
    animation_curve_move=0.46,1.0,0.29,1
    animation_curve_tag=0.46,1.0,0.29,1
    animation_curve_close=0.08,0.92,0,1
    animation_curve_focus=0.46,1.0,0.29,1
    animation_curve_opafadein=0.46,1.0,0.29,1
    animation_curve_opafadeout=0.5,0.5,0.5,0.5

    # ============================================
    # SCROLLER LAYOUT (Using tile instead)
    # ============================================
    scroller_structs=20
    scroller_default_proportion=0.8
    scroller_focus_center=0
    scroller_prefer_center=0
    edge_scroller_pointer_focus=1
    scroller_ignore_proportion_single=0
    scroller_default_proportion_single=1.0
    scroller_proportion_preset=0.5,0.8,1.0

    # ============================================
    # MASTER-STACK LAYOUT (Default tile layout)
    # ============================================
    new_is_master=1
    default_mfact=0.55
    default_nmaster=1
    smartgaps=1
    center_master_overspread=0
    center_when_single_stack=1

    # ============================================
    # OVERVIEW SETTINGS (Disabled - not in Sway)
    # ============================================
    hotarea_size=10
    enable_hotarea=0
    ov_tab_mode=0
    overviewgappi=5
    overviewgappo=30

    # ============================================
    # MISCELLANEOUS SETTINGS
    # ============================================
    xwayland_persistence=1
    syncobj_enable=0
    adaptive_sync=0
    allow_shortcuts_inhibit=1
    allow_tearing=0
    allow_lock_transparent=0
    axis_bind_apply_timeout=100
    focus_on_activate=1
    inhibit_regardless_of_visibility=0
    sloppyfocus=1
    warpcursor=1
    focus_cross_monitor=0
    exchange_cross_monitor=0
    scratchpad_cross_monitor=0
    focus_cross_tag=0
    view_current_to_back=1
    enable_floating_snap=0
    snap_distance=30
    cursor_size=24
    cursor_theme=
    no_border_when_single=1
    cursor_hide_timeout=3
    drag_tile_to_tile=0
    single_scratchpad=1
    circle_layout=

    # ============================================
    # KEYBOARD SETTINGS
    # ============================================
    repeat_rate=50
    repeat_delay=200
    numlockon=1

    # ============================================
    # TRACKPAD & MOUSE SETTINGS
    # ============================================
    disable_trackpad=0
    tap_to_click=1
    tap_and_drag=1
    drag_lock=1
    trackpad_natural_scrolling=0
    disable_while_typing=1
    left_handed=0
    middle_button_emulation=0
    swipe_min_threshold=20
    mouse_natural_scrolling=0
    accel_profile=2
    accel_speed=0.0
    scroll_method=1
    click_method=1
    send_events_mode=0
    button_map=0

    # ============================================
    # APPEARANCE (Gaps disabled like Sway)
    # ============================================
    gappih=10
    gappiv=10
    gappoh=10
    gappov=10
    scratchpad_width_ratio=0.8
    scratchpad_height_ratio=0.9
    borderpx=0
    rootcolor=0x000000ff
    bordercolor=0x444444ff
    focuscolor=0xad741fff
    maximizescreencolor=0x89aa61ff
    urgentcolor=0xad401fff
    scratchpadcolor=0x516c93ff
    globalcolor=0xb153a7ff
    overlaycolor=0x14a57cff

    # ============================================
    # TAG RULES
    # ============================================
    tagrule=id:1,layout_name:tile
    tagrule=id:2,layout_name:tile
    tagrule=id:3,layout_name:tile
    tagrule=id:4,layout_name:tile
    tagrule=id:5,layout_name:tile
    tagrule=id:6,layout_name:tile
    tagrule=id:7,layout_name:tile
    tagrule=id:8,layout_name:tile
    tagrule=id:9,layout_name:tile

    # ============================================
    # WINDOW RULES
    # ============================================
    # Add your window-specific rules here
    # Example:
    # windowrule=isfloating:1,appid:pavucontrol

    # ============================================
    # MONITOR RULES
    # ============================================
    monitorrule=eDP-1,0.55,1,tile,0,1,0,0,2560,1600,240
    monitorrule=HDMI-A-1,0.55,1,tile,0,1,2560,0,1920,1080,60

    # ============================================
    # EXEC-ONCE (Startup applications)
    # ============================================
    exec-once=numlockwl
    exec-once=fnott
    exec-once=udiskie
    exec-once=nm-applet
    exec-once=autotiling-rs
    exec-once=wl-paste --type text --watch cliphist store
    exec-once=wl-paste --type image --watch cliphist store
    exec-once=swaybg
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
    exec-once=gamemoded
    exec-once=avizo-service
    exec-once=swayidle
    exec-once=swaync
    exec-once=swww-daemon
    exec-once=sway-alttab
    exec-once=waybar

    # ============================================
    # KEY BINDINGS
    # ============================================
    keymode=default

    # Basic applications
    bind=SUPER,q,spawn,kitty
    bind=SUPER,d,spawn,rofi -show drun
    bind=SUPER,c,killclient
    bind=SUPER+SHIFT,c,reload_config
    bind=SUPER,l,spawn,swaylock -C ~/.config/swaylock/config
    bind=SUPER,g,spawn,new-wallpaper
    bind=SUPER,b,spawn,~/dotfiles/bruh.sh --dunst
    bind=SUPER,Insert,spawn,cliphist list | bemenu | cliphist decode | wl-copy

    # Focus direction (arrow keys)
    bind=SUPER,Left,focusdir,left
    bind=SUPER,Down,focusdir,down
    bind=SUPER,Up,focusdir,up
    bind=SUPER,Right,focusdir,right

    # Move windows (arrow keys with Shift)
    bind=SUPER+SHIFT,Left,exchange_client,left
    bind=SUPER+SHIFT,Down,exchange_client,down
    bind=SUPER+SHIFT,Up,exchange_client,up
    bind=SUPER+SHIFT,Right,exchange_client,right

    # Workspace/Tag switching (tags 1-9 map to workspaces 1-9, tag 0 maps to workspace 10)
    bind=SUPER,1,view,1
    bind=SUPER,2,view,2
    bind=SUPER,3,view,3
    bind=SUPER,4,view,4
    bind=SUPER,5,view,5
    bind=SUPER,6,view,6
    bind=SUPER,7,view,7
    bind=SUPER,8,view,8
    bind=SUPER,9,view,9
    bind=SUPER,0,view,0

    # Move window to workspace/tag
    bind=SUPER+SHIFT,1,tag,1
    bind=SUPER+SHIFT,2,tag,2
    bind=SUPER+SHIFT,3,tag,3
    bind=SUPER+SHIFT,4,tag,4
    bind=SUPER+SHIFT,5,tag,5
    bind=SUPER+SHIFT,6,tag,6
    bind=SUPER+SHIFT,7,tag,7
    bind=SUPER+SHIFT,8,tag,8
    bind=SUPER+SHIFT,9,tag,9
    bind=SUPER+SHIFT,0,tag,0

    # Layout controls
    bind=SUPER+SHIFT,v,togglefloating
    bind=SUPER,f,togglefullscreen
    bind=SUPER,r,setkeymode,resize

    # Media keys
    bind=NONE,XF86AudioRaiseVolume,spawn,volumectl up
    bind=NONE,XF86AudioLowerVolume,spawn,volumectl down
    bind=NONE,XF86AudioMute,spawn,volumectl toggle-mute
    bind=NONE,XF86AudioMicMute,spawn,volumectl -m toggle-mute
    bind=NONE,XF86Launch3,spawn,playerctl play-pause
    bind=NONE,XF86AudioPlay,spawn,playerctl play-pause
    bind=NONE,XF86MonBrightnessUp,spawn,lightctl up
    bind=NONE,XF86MonBrightnessDown,spawn,lightctl down
    bind=NONE,XF86TouchpadToggle,toggle_trackpad_enable

    # Screenshot
    bind=SUPER+SHIFT,s,spawn,~/dotfiles/swayscreenshot.sh

    # ============================================
    # RESIZE MODE
    # ============================================
    keymode=resize
    bind=NONE,Left,smartresizewin,left
    bind=NONE,Up,smartresizewin,up
    bind=NONE,Right,smartresizewin,right
    bind=NONE,Down,smartresizewin,down
    bind=NONE,Return,setkeymode,default
    bind=NONE,Escape,setkeymode,default

    # ============================================
    # BACK TO DEFAULT MODE
    # ============================================
    keymode=default

    # ============================================
    # MOUSE BINDINGS
    # ============================================
    mousebind=SUPER,btn_left,moveresize,curmove
    mousebind=SUPER,btn_right,moveresize,curresize
    mousebind=SUPER+CTRL,btn_right,killclient
    mousebind=NONE,btn_middle,togglemaximizescreen,0

    # ============================================
    # GESTURE BINDINGS (Touchpad gestures)
    # ============================================
    gesturebind=none,left,3,focusdir,left
    gesturebind=none,right,3,focusdir,right
    gesturebind=none,up,3,focusdir,up
    gesturebind=none,down,3,focusdir,down
    gesturebind=none,left,4,viewtoleft_have_client
    gesturebind=none,right,4,viewtoright_have_client

    # ============================================
    # AXIS BINDINGS (Mouse wheel)
    # ============================================
    # Uncomment if you want mouse wheel workspace switching
    # axisbind=SUPER,UP,viewtoleft_have_client
    # axisbind=SUPER,DOWN,viewtoright_have_client
  '';

  # Ensure mango config directory exists
  home.file.".config/mango/.keep".text = "";
}
