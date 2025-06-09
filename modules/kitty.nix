{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    settings = {
      # Font Settings
      font_size = 10.0;
      
      # Size Settings
      adjust_line_height = 2;
      adjust_column_width = 0;
      
      # Underline Settings
      #modify_font = [
      #  "underline_position 5"
      #  "underline_thickness 150%"
      #  "strikethrough_position 2px"
      #];
      
      # Cursor Settings
      cursor_shape = "beam";
      cursor_blink_interval = 0.5;
      cursor_stop_blinking_after = 15.0;
      
      # URL Settings
      url_color = "#0000ff";
      url_style = "double";
      open_url_modifiers = "ctrl+shift";
      open_url_with = "zen";
      copy_on_select = "yes";
      
      # Mouse Settings
      click_interval = 0.5;
      mouse_hide_wait = 0;
      focus_follows_mouse = "no";
      
      # Performance Settings
      repaint_delay = 20;
      input_delay = 2;
      sync_to_monitor = "no";
      
      # Window Border Settings
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";
      
      # Shell Settings
      shell = ".";
      close_on_child_death = "no";
      allow_remote_control = "yes";
      term = "xterm-256color";
      
      # Window Settings
      remember_window_size = "no";
      initial_window_width = 780;
      initial_window_height = 460;
      window_border_width = 0;
      window_margin_width = 0;
      window_padding_width = 0;
      inactive_text_alpha = 1.0;
      
      # Tab Bar Settings
      tab_bar_min_tabs = 1;
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      
      # Mark Settings (Marked Text)
      mark1_foreground = "#1E1E2E";
      mark1_background = "#B4BEFE";
      mark2_foreground = "#1E1E2E";
      mark2_background = "#CBA6F7";
      mark3_foreground = "#1E1E2E";
      mark3_background = "#74C7EC";
      
      # Title Bar Settings
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
    };
    
    # Mouse bindings can be defined in extraConfig
    extraConfig = ''
      # Mouse Bindings
      mouse_map right press ungrabbed paste_from_selection
    '';
    
    # Keyboard shortcuts
    keybindings = {
      "alt+shift+v" = "paste_from_clipboard";
      "alt+shift+s" = "paste_from_selection";
      "alt+shift+c" = "copy_to_clipboard";
      "shift+insert" = "paste_from_selection";
      
      "alt+shift+up" = "scroll_line_up";
      "alt+shift+down" = "scroll_line_down";
      "alt+shift+k" = "scroll_line_up";
      "alt+shift+j" = "scroll_line_down";
      "alt+shift+page_up" = "scroll_page_up";
      "alt+shift+page_down" = "scroll_page_down";
      "alt+shift+home" = "scroll_home";
      "alt+shift+end" = "scroll_end";
      "alt+shift+h" = "show_scrollback";
      
      "alt+shift+enter" = "new_window";
      "alt+shift+n" = "new_os_window";
      "alt+shift+w" = "close_window";
      "alt+shift+]" = "next_window";
      "alt+shift+[" = "previous_window";
      "alt+shift+f" = "move_window_forward";
      "alt+shift+b" = "move_window_backward";
      "alt+shift+`" = "move_window_to_top";
      "alt+shift+1" = "first_window";
      "alt+shift+2" = "second_window";
      "alt+shift+3" = "third_window";
      "alt+shift+4" = "fourth_window";
      "alt+shift+5" = "fifth_window";
      "alt+shift+6" = "sixth_window";
      "alt+shift+7" = "seventh_window";
      "alt+shift+8" = "eighth_window";
      "alt+shift+9" = "ninth_window";
      "alt+shift+0" = "tenth_window";
      
      "alt+shift+right" = "next_tab";
      "alt+shift+left" = "previous_tab";
      "alt+shift+t" = "new_tab";
      "alt+shift+q" = "close_tab";
      "alt+shift+l" = "next_layout";
      "alt+shift+." = "move_tab_forward";
      "alt+shift+," = "move_tab_backward";
      "ctrl+shift+alt+t" = "set_tab_title";
      
      "alt+shift+equal" = "increase_font_size";
      "alt+shift+minus" = "decrease_font_size";
      "alt+shift+backspace" = "restore_font_size";
      "alt+shift+f11" = "set_font_size 11.0";
      "alt+shift+f6" = "set_font_size 16.0";
    };
    
    # Shell integration
    shellIntegration = {
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
