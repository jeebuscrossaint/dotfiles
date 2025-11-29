{
  config,
  lib,
  pkgs,
  ...
}: {
  # Disable other window managers
  xsession.windowManager.i3.enable = false;
  xsession.windowManager.xmonad.enable = false;

  xsession.windowManager.awesome = {
    # enable = true;
    luaModules = with pkgs.luaPackages; [
      luarocks
      luadbi-mysql
    ];
  };

  home.file.".config/awesome/rc.lua".text = ''
    -- Standard awesome library
    local gears = require("gears")
    local awful = require("awful")
    require("awful.autofocus")
    local wibox = require("wibox")
    local beautiful = require("beautiful")
    local naughty = require("naughty")
    local menubar = require("menubar")
    local hotkeys_popup = require("awful.hotkeys_popup")

    -- Error handling
    if awesome.startup_errors then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, there were errors during startup!",
                         text = awesome.startup_errors })
    end

    do
        local in_error = false
        awesome.connect_signal("debug::error", function (err)
            if in_error then return end
            in_error = true
            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Oops, an error happened!",
                             text = tostring(err) })
            in_error = false
        end)
    end

    -- Variable definitions
    beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
    terminal = "xterm"
    editor = os.getenv("EDITOR") or "nano"
    editor_cmd = terminal .. " -e " .. editor
    modkey = "Mod4"

    -- Layouts
    awful.layout.layouts = {
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.max,
        awful.layout.suit.floating,
    }

    -- Wibar
    local taglist_buttons = gears.table.join(
        awful.button({ }, 1, function(t) t:view_only() end)
    )

    local tasklist_buttons = gears.table.join(
        awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end)
    )

    awful.screen.connect_for_each_screen(function(s)
        -- Each screen has its own tag table
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        
        -- Create an imagebox widget which will contain an icon indicating which layout we're using
        s.mylayoutbox = awful.widget.layoutbox(s)
        
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = taglist_buttons
        }

        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons
        }

        -- Create the wibox (status bar)
        s.mywibox = awful.wibar({ position = "bottom", screen = s })

        -- Add widgets to the wibox
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                wibox.widget.textclock(),
                s.mylayoutbox,
            },
        }
    end)

    -- Key bindings
    globalkeys = gears.table.join(
        -- Main keybindings
        awful.key({ modkey, }, "q", function () awful.spawn(terminal) end,
                  {description = "open terminal", group = "launcher"}),
        awful.key({ modkey, }, "c", function () 
            if client.focus then client.focus:kill() end 
        end, {description = "close window", group = "client"}),
        awful.key({ modkey, }, "d", function () awful.spawn("bemenu-run") end,
                  {description = "run launcher", group = "launcher"}),
        awful.key({ modkey, }, "l", function () awful.spawn("xsecurelock") end,
                  {description = "lock screen", group = "awesome"}),
        awful.key({ modkey, }, "b", function () awful.spawn(os.getenv("HOME") .. "/bruh.sh --dunst") end,
                  {description = "run bruh script", group = "launcher"}),
        awful.key({ modkey, "Shift" }, "s", function () awful.spawn("flameshot gui") end,
                  {description = "screenshot", group = "launcher"}),

        -- Window focus
        awful.key({ modkey, }, "Left", function () awful.client.focus.bydirection("left") end,
                  {description = "focus left", group = "client"}),
        awful.key({ modkey, }, "Down", function () awful.client.focus.bydirection("down") end,
                  {description = "focus down", group = "client"}),
        awful.key({ modkey, }, "Up", function () awful.client.focus.bydirection("up") end,
                  {description = "focus up", group = "client"}),
        awful.key({ modkey, }, "Right", function () awful.client.focus.bydirection("right") end,
                  {description = "focus right", group = "client"}),

        -- Window movement
        awful.key({ modkey, "Shift" }, "Left", function () awful.client.swap.bydirection("left") end,
                  {description = "swap with left client", group = "client"}),
        awful.key({ modkey, "Shift" }, "Down", function () awful.client.swap.bydirection("down") end,
                  {description = "swap with down client", group = "client"}),
        awful.key({ modkey, "Shift" }, "Up", function () awful.client.swap.bydirection("up") end,
                  {description = "swap with up client", group = "client"}),
        awful.key({ modkey, "Shift" }, "Right", function () awful.client.swap.bydirection("right") end,
                  {description = "swap with right client", group = "client"}),

        -- Layout management
        awful.key({ modkey, }, "f", function () 
            if client.focus then 
                client.focus.fullscreen = not client.focus.fullscreen 
                client.focus:raise() 
            end 
        end, {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, }, "p", awful.client.floating.toggle,
                  {description = "toggle floating", group = "client"}),
        awful.key({ modkey, }, "space", function () awful.layout.inc(1) end,
                  {description = "next layout", group = "layout"}),
        awful.key({ modkey, "Shift" }, "space", awful.client.floating.toggle,
                  {description = "toggle floating", group = "client"}),

        -- Media keys
        awful.key({}, "XF86AudioRaiseVolume", function () awful.spawn("volumectl up") end,
                  {description = "volume up", group = "media"}),
        awful.key({}, "XF86AudioLowerVolume", function () awful.spawn("volumectl down") end,
                  {description = "volume down", group = "media"}),
        awful.key({}, "XF86Launch3", function () awful.spawn("playerctl play-pause") end,
                  {description = "play/pause", group = "media"}),
        awful.key({}, "XF86AudioMicMute", function () awful.spawn("volumectl -m toggle-mute") end,
                  {description = "mute mic", group = "media"}),
        awful.key({}, "XF86MonBrightnessUp", function () awful.spawn("lightctl up") end,
                  {description = "brightness up", group = "media"}),
        awful.key({}, "XF86MonBrightnessDown", function () awful.spawn("lightctl down") end,
                  {description = "brightness down", group = "media"}),

        -- Awesome control
        awful.key({ modkey, "Control" }, "r", awesome.restart,
                  {description = "reload awesome", group = "awesome"}),
        awful.key({ modkey, "Shift" }, "e", awesome.quit,
                  {description = "quit awesome", group = "awesome"})
    )

    -- Bind all key numbers to tags
    for i = 1, 9 do
        globalkeys = gears.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9,
                function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then tag:view_only() end
                end,
                {description = "view tag #"..i, group = "tag"}),
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then client.focus:move_to_tag(tag) end
                    end
                end,
                {description = "move focused client to tag #"..i, group = "tag"})
        )
    end

    root.keys(globalkeys)

    -- Rules
    awful.rules.rules = {
        -- All clients
        { rule = { },
          properties = { 
              border_width = 2,
              border_color = beautiful.border_normal,
              focus = awful.client.focus.filter,
              raise = true,
              keys = clientkeys,
              buttons = clientbuttons,
              screen = awful.screen.preferred,
              placement = awful.placement.no_overlap+awful.placement.no_offscreen,
              -- Fix keyboard input for Firefox and other apps
              focusable = true,
              size_hints_honor = false
          }
        },

        -- Floating clients
        { rule_any = {
            class = {
              "rofi",
              "zoom",
            }
          }, properties = { floating = true }
        },
    }

    -- Signals
    client.connect_signal("manage", function (c)
        if awesome.startup and not c.size_hints.user_position
           and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
        
        -- Ensure new clients get focus and can receive input
        if not awesome.startup then
            awful.client.setslave(c)
        end
    end)

    -- Fix focus issues with Firefox and other apps
    client.connect_signal("property::urgent", function(c)
        c.minimized = false
        c:jump_to()
    end)

    client.connect_signal("focus", function(c) 
        c.border_color = beautiful.border_focus 
    end)
    client.connect_signal("unfocus", function(c) 
        c.border_color = beautiful.border_normal 
    end)

    -- Autostart applications
    awful.spawn.with_shell("dex --autostart --environment awesome")
    awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- xsecurelock")
    awful.spawn.with_shell("nm-applet")
    awful.spawn.with_shell("timedatectl set-local-rtc 1 --adjust-system-clock")
    awful.spawn.with_shell("udiskie")
    awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    awful.spawn.with_shell("xclip")
    awful.spawn.with_shell("xdotool key --clearmodifiers Num_Lock")
    awful.spawn.with_shell(".config/lemonbar/lemon.sh")
    awful.spawn.with_shell("autotiling")
    awful.spawn.with_shell("rog-control-center")
    awful.spawn.with_shell("gamescope")
    awful.spawn.with_shell("/usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber")
    awful.spawn.with_shell("numlockx")
    awful.spawn.with_shell("dunst")
    awful.spawn.with_shell("xrandr --output eDP-1 --mode 2560x1600 --rate 240.00 --primary --output HDMI-1-0 --mode 1920x1080 --rate 60.00 --above eDP-1")
    awful.spawn.with_shell("unclutter")

    -- Set environment variables
    awful.spawn.with_shell("export QT_QPA_PLATFORMTHEME=qt6ct")
    awful.spawn.with_shell("export GDK_BACKEND=x11")
    awful.spawn.with_shell("export MOZ_ENABLE_WAYLAND=0")
    awful.spawn.with_shell("export CLUTTER_BACKEND=x11")
    awful.spawn.with_shell("export QT_QPA_PLATFORM=x11")
  '';
}
