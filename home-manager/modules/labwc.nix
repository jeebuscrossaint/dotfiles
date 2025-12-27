# Labwc configuration for Home Manager inspired by Sway config
{pkgs, lib, ...}: {

  # Main labwc configuration file
  xdg.configFile."labwc/rc.xml".text = ''
    <?xml version="1.0"?>
    <labwc_config>
      <!-- Core settings -->
      <core>
        <decoration>server</decoration>
        <gap>0</gap>
        <adaptiveSync>no</adaptiveSync>
      </core>

      <!-- Theme settings -->
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
        <repeatRate>25</repeatRate>
        <repeatDelay>300</repeatDelay>
        
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
    '';
  };

  # Environment configuration
  xdg.configFile."labwc/environment".text = ''
    # Wayland environment variables
    XDG_CURRENT_DESKTOP=labwc
    XDG_SESSION_TYPE=wayland
    XDG_SESSION_DESKTOP=labwc
  '';

  # Themerc (window decoration theme)
  xdg.configFile."labwc/themerc".text = ''
    # Window border
    border.width: 1
    border.color: #333333
    
    # Title bar (we're disabling it)
    window.active.title.bg.color: #2e3440
    window.inactive.title.bg.color: #3b4252
    
    # Window buttons
    window.active.button.unpressed.image.color: #d8dee9
    window.inactive.button.unpressed.image.color: #4c566a
    
    # Padding
    padding.height: 3
    padding.width: 3
    
    # Menu
    menu.items.bg.color: #2e3440
    menu.items.text.color: #d8dee9
    menu.items.active.bg.color: #5e81ac
    menu.items.active.text.color: #eceff4
  '';
}
