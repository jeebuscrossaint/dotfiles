# Labwc configuration for Home Manager with Stylix integration
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # Extract stylix colors (remove '#' prefix for direct use in XML/config)
  removeHash = color: removePrefix "#" color;
  
  # Window Manager colors (following stylix style guide)
  unfocusedBorder = removeHash config.lib.stylix.colors.withHashtag.base03;
  focusedBorder = removeHash config.lib.stylix.colors.withHashtag.base0D;
  urgentBorder = removeHash config.lib.stylix.colors.withHashtag.base08;
  rootColor = removeHash config.lib.stylix.colors.withHashtag.base00;
  backgroundColor = removeHash config.lib.stylix.colors.withHashtag.base00;
  textColor = removeHash config.lib.stylix.colors.withHashtag.base05;
  activeTextColor = removeHash config.lib.stylix.colors.withHashtag.base07;
  accentColor = removeHash config.lib.stylix.colors.withHashtag.base0D;
  inactiveColor = removeHash config.lib.stylix.colors.withHashtag.base02;
in
{
  # Main labwc configuration file
  xdg.configFile."labwc/rc.xml".text = ''
    <?xml version="1.0"?>
    <labwc_config>
      <!-- Core settings -->
      <core>
        <decoration>server</decoration>
        <gap>10</gap>
        <adaptiveSync>no</adaptiveSync>
      </core>

      <!-- Theme settings with Stylix colors -->
      <theme>
        <name>Clearlooks</name>
        <cornerRadius>0</cornerRadius>
        <keepBorder>yes</keepBorder>
        <font place="ActiveWindow">
          <name>sans</name>
          <size>10</size>
        </font>
      </theme>

      <!-- Keyboard settings -->
      <keyboard>
        <numlock>on</numlock>
        <repeatRate>50</repeatRate>
        <repeatDelay>200</repeatDelay>
        
        <!-- Default keybindings -->
        <default />
        
        <!-- Basic keybindings -->
        <keybind key="W-q">
          <action name="Execute" command="kitty" />
        </keybind>
        
        <keybind key="W-d">
          <action name="Execute" command="rofi -show drun" />
        </keybind>
        
        <keybind key="W-c">
          <action name="Close" />
        </keybind>
        
        <keybind key="W-S-c">
          <action name="Reconfigure" />
        </keybind>
        
        <keybind key="W-l">
          <action name="Execute" command="swaylock -C ~/.config/swaylock/config" />
        </keybind>
        
        <keybind key="W-g">
          <action name="Execute" command="new-wallpaper" />
        </keybind>
        
        <keybind key="W-b">
          <action name="Execute" command="~/dotfiles/bruh.sh --dunst" />
        </keybind>
        
        <keybind key="W-Insert">
          <action name="Execute" command="sh -c 'cliphist list | bemenu | cliphist decode | wl-copy'" />
        </keybind>
        
        <!-- Focus bindings -->
        <keybind key="W-Left">
          <action name="Focus" direction="left" />
        </keybind>
        
        <keybind key="W-Down">
          <action name="Focus" direction="down" />
        </keybind>
        
        <keybind key="W-Up">
          <action name="Focus" direction="up" />
        </keybind>
        
        <keybind key="W-Right">
          <action name="Focus" direction="right" />
        </keybind>
        
        <!-- Move bindings -->
        <keybind key="W-S-Left">
          <action name="Move" direction="left" />
        </keybind>
        
        <keybind key="W-S-Down">
          <action name="Move" direction="down" />
        </keybind>
        
        <keybind key="W-S-Up">
          <action name="Move" direction="up" />
        </keybind>
        
        <keybind key="W-S-Right">
          <action name="Move" direction="right" />
        </keybind>
        
        <!-- Workspace bindings -->
        <keybind key="W-1">
          <action name="GoToDesktop" to="1" />
        </keybind>
        <keybind key="W-2">
          <action name="GoToDesktop" to="2" />
        </keybind>
        <keybind key="W-3">
          <action name="GoToDesktop" to="3" />
        </keybind>
        <keybind key="W-4">
          <action name="GoToDesktop" to="4" />
        </keybind>
        <keybind key="W-5">
          <action name="GoToDesktop" to="5" />
        </keybind>
        <keybind key="W-6">
          <action name="GoToDesktop" to="6" />
        </keybind>
        <keybind key="W-7">
          <action name="GoToDesktop" to="7" />
        </keybind>
        <keybind key="W-8">
          <action name="GoToDesktop" to="8" />
        </keybind>
        <keybind key="W-9">
          <action name="GoToDesktop" to="9" />
        </keybind>
        <keybind key="W-0">
          <action name="GoToDesktop" to="10" />
        </keybind>
        
        <!-- Move to workspace bindings -->
        <keybind key="W-S-1">
          <action name="SendToDesktop" to="1" follow="no" />
        </keybind>
        <keybind key="W-S-2">
          <action name="SendToDesktop" to="2" follow="no" />
        </keybind>
        <keybind key="W-S-3">
          <action name="SendToDesktop" to="3" follow="no" />
        </keybind>
        <keybind key="W-S-4">
          <action name="SendToDesktop" to="4" follow="no" />
        </keybind>
        <keybind key="W-S-5">
          <action name="SendToDesktop" to="5" follow="no" />
        </keybind>
        <keybind key="W-S-6">
          <action name="SendToDesktop" to="6" follow="no" />
        </keybind>
        <keybind key="W-S-7">
          <action name="SendToDesktop" to="7" follow="no" />
        </keybind>
        <keybind key="W-S-8">
          <action name="SendToDesktop" to="8" follow="no" />
        </keybind>
        <keybind key="W-S-9">
          <action name="SendToDesktop" to="9" follow="no" />
        </keybind>
        <keybind key="W-S-0">
          <action name="SendToDesktop" to="10" follow="no" />
        </keybind>
        
        <!-- Layout bindings -->
        <keybind key="W-S-v">
          <action name="ToggleFloating" />
        </keybind>
        
        <keybind key="W-f">
          <action name="ToggleFullscreen" />
        </keybind>
        
        <!-- Media keys -->
        <keybind key="XF86AudioRaiseVolume">
          <action name="Execute" command="volumectl up" />
        </keybind>
        
        <keybind key="XF86AudioLowerVolume">
          <action name="Execute" command="volumectl down" />
        </keybind>
        
        <keybind key="XF86AudioMute">
          <action name="Execute" command="volumectl toggle-mute" />
        </keybind>
        
        <keybind key="XF86AudioMicMute">
          <action name="Execute" command="volumectl -m toggle-mute" />
        </keybind>
        
        <keybind key="XF86Launch3">
          <action name="Execute" command="playerctl play-pause" />
        </keybind>
        
        <keybind key="XF86AudioPlay">
          <action name="Execute" command="playerctl play-pause" />
        </keybind>
        
        <keybind key="XF86MonBrightnessUp">
          <action name="Execute" command="lightctl up" />
        </keybind>
        
        <keybind key="XF86MonBrightnessDown">
          <action name="Execute" command="lightctl down" />
        </keybind>
        
        <!-- Screenshot -->
        <keybind key="W-S-s">
          <action name="Execute" command="~/dotfiles/swayscreenshot.sh" />
        </keybind>
      </keyboard>

      <!-- Mouse bindings -->
      <mouse>
        <default />
        
        <!-- Window dragging with Super key -->
        <context name="Frame">
          <mousebind button="W-Left" action="Press">
            <action name="Focus" />
            <action name="Raise" />
          </mousebind>
          <mousebind button="W-Left" action="Drag">
            <action name="Move" />
          </mousebind>
        </context>
        
        <!-- Window resizing with Super+Right click -->
        <context name="Frame">
          <mousebind button="W-Right" action="Press">
            <action name="Focus" />
            <action name="Raise" />
          </mousebind>
          <mousebind button="W-Right" action="Drag">
            <action name="Resize" />
          </mousebind>
        </context>
      </mouse>

      <!-- Focus settings -->
      <focus>
        <followMouse>yes</followMouse>
        <followMouseRequiresMovement>no</followMouseRequiresMovement>
        <raiseOnFocus>no</raiseOnFocus>
      </focus>

      <!-- Desktops (workspaces) -->
      <desktops number="10" />

      <!-- Window snapping -->
      <snapping>
        <range>1</range>
        <topMaximize>yes</topMaximize>
      </snapping>

      <!-- Window rules -->
      <windowRules>
        <!-- Add your window rules here if needed -->
      </windowRules>
    </labwc_config>
  '';

  # Autostart configuration
  xdg.configFile."labwc/autostart" = {
    executable = true;
    text = ''
      #!/bin/sh
      
      # System services
      numlockwl &
      fnott &
      udiskie &
      nm-applet &
      
      # Clipboard manager
      wl-paste --type text --watch cliphist store &
      wl-paste --type image --watch cliphist store &
      
      # Background
      swaybg &
      swww-daemon &
      
      # D-Bus activation environment
      dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
      
      # Other services
      gamemoded &
      avizo-service &
      swayidle &
      swaync &
      
      # Status bar
      waybar &

      woled --lock &
    '';
  };

  # Environment configuration
  xdg.configFile."labwc/environment".text = ''
    # Wayland environment variables
    XDG_CURRENT_DESKTOP=labwc
    XDG_SESSION_TYPE=wayland
    XDG_SESSION_DESKTOP=labwc
  '';

  # Themerc (window decoration theme) with Stylix colors
  xdg.configFile."labwc/themerc".text = ''
    # ============================================
    # LABWC THEME - Styled with Stylix
    # Following the stylix style guide:
    # - Unfocused window border: base03
    # - Focused window border: base0D
    # - Background: base00
    # - Text: base05
    # ============================================
    
    # Window border colors
    border.width: 2
    border.color: #${unfocusedBorder}
    
    # Active window (focused)
    window.active.title.bg.color: #${backgroundColor}
    window.active.label.text.color: #${activeTextColor}
    window.active.button.unpressed.image.color: #${activeTextColor}
    window.active.button.hover.image.color: #${accentColor}
    window.active.border.color: #${focusedBorder}
    
    # Inactive window (unfocused)
    window.inactive.title.bg.color: #${inactiveColor}
    window.inactive.label.text.color: #${textColor}
    window.inactive.button.unpressed.image.color: #${textColor}
    window.inactive.button.hover.image.color: #${accentColor}
    window.inactive.border.color: #${unfocusedBorder}
    
    # Padding
    padding.height: 3
    padding.width: 3
    
    # Menu colors
    menu.items.bg.color: #${backgroundColor}
    menu.items.text.color: #${textColor}
    menu.items.active.bg.color: #${accentColor}
    menu.items.active.text.color: #${activeTextColor}
    menu.border.width: 1
    menu.border.color: #${focusedBorder}
    
    # OSD (On-Screen Display)
    osd.bg.color: #${backgroundColor}
    osd.border.color: #${focusedBorder}
    osd.border.width: 1
    osd.label.text.color: #${textColor}
  '';
}