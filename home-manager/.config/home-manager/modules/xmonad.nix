
{
  config,
  lib,
  pkgs,
  ...
}: {
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    
    extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.xmonad-extras
    ];

    config = pkgs.writeText "xmonad.hs" ''
      import XMonad
      import XMonad.Hooks.EwmhDesktops
      import XMonad.Hooks.ManageDocks
      import XMonad.Hooks.ManageHelpers
      import XMonad.Layout.NoBorders
      import XMonad.Layout.Spacing
      import XMonad.Util.EZConfig
      import XMonad.Util.SpawnOnce
      import qualified XMonad.StackSet as W

      main :: IO ()
      main = xmonad $ ewmh $ docks $ def
        { modMask = mod4Mask  -- Use Super (Windows) key
        , terminal = "xterm"
        , borderWidth = 2
        , focusedBorderColor = "#ffffff"
        , normalBorderColor = "#000000"
        , layoutHook = myLayout
        , manageHook = myManageHook
        , startupHook = myStartupHook
        }
        `additionalKeysP` myKeys

      myLayout = avoidStruts 
               $ smartBorders 
               $ spacingRaw True (Border 0 0 0 0) True (Border 0 0 0 0) True
               $ layoutHook def

      myManageHook :: ManageHook
      myManageHook = composeAll
        [ className =? "rofi" --> doFloat
        , className =? "zoom" --> doFloat
        , manageDocks
        ]

      myStartupHook :: X ()
      myStartupHook = do
        spawnOnce "dex --autostart --environment i3"
        spawnOnce "xss-lock --transfer-sleep-lock -- xsecurelock"
        spawnOnce "nm-applet"
        spawnOnce "timedatectl set-local-rtc 1 --adjust-system-clock"
        spawnOnce "udiskie"
        spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
        spawnOnce "xclip"
        spawnOnce "xdotool key --clearmodifiers Num_Lock"
        spawnOnce ".config/lemonbar/lemon.sh"
        spawnOnce "autotiling"
        spawnOnce "rog-control-center"
        spawnOnce "gamescope"
        spawnOnce "/usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber"
        spawnOnce "numlockx"
        spawnOnce "dunst"
        spawnOnce "xrandr --output eDP-1 --mode 2560x1600 --rate 240.00 --primary --output HDMI-1-0 --mode 1920x1080 --rate 60.00 --above eDP-1"
        spawnOnce "unclutter"
        -- Set environment variables
        spawn "export QT_QPA_PLATFORMTHEME=qt6ct"
        spawn "export GDK_BACKEND=x11"
        spawn "export MOZ_ENABLE_WAYLAND=0"
        spawn "export CLUTTER_BACKEND=x11"
        spawn "export QT_QPA_PLATFORM=x11"

      myKeys :: [(String, X ())]
      myKeys =
        -- Main keybindings
        [ ("M-q", spawn "xterm")
        , ("M-c", kill)
        , ("M-p", withFocused $ windows . W.sink)  -- Toggle floating
        , ("M-d", spawn "bemenu-run")
        , ("M-l", spawn "xsecurelock")
        , ("M-b", spawn "~/bruh.sh --dunst")
        , ("M-S-s", spawn "flameshot gui")
        
        -- Window focus
        , ("M-<Left>", windows W.focusUp)
        , ("M-<Down>", windows W.focusDown)
        , ("M-<Up>", windows W.focusUp)
        , ("M-<Right>", windows W.focusDown)
        
        -- Window movement
        , ("M-S-<Left>", windows W.swapUp)
        , ("M-S-<Down>", windows W.swapDown)
        , ("M-S-<Up>", windows W.swapUp)
        , ("M-S-<Right>", windows W.swapDown)
        
        -- Layout management
        , ("M-f", sendMessage ToggleStruts >> sendMessage NextLayout)  -- Fullscreen-like
        , ("M-<Space>", windows W.focusMaster)
        , ("M-S-<Space>", withFocused $ windows . W.sink)  -- Toggle floating
        
        -- Media keys
        , ("<XF86AudioRaiseVolume>", spawn "volumectl up")
        , ("<XF86AudioLowerVolume>", spawn "volumectl down")
        , ("<XF86Launch3>", spawn "playerctl play-pause")
        , ("<XF86AudioMicMute>", spawn "volumectl -m toggle-mute")
        , ("<XF86MonBrightnessUp>", spawn "lightctl up")
        , ("<XF86MonBrightnessDown>", spawn "lightctl down")
        ]
    '';
  };
}
