{ config, pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    
    # Environment variables
    envFile.text = ''
      $env.QT_QPA_PLATFORMTHEME = "qt5ct"
      $env.GSK_RENDERER = "ngl"
      $env.NIXPKGS_ALLOW_UNFREE = "1"
      $env.EDITOR = "vim"
      $env.XCURSOR_THEME = "rose-pine-cursor"
      $env.XCURSOR_SIZE = "24"
    '';
    
    # Main configuration
    configFile.text = ''
      # Check if we're in a TTY and set console font
      if (tty | complete | get exit_code) == 0 {
        if ($env.TERM? | default "" | str contains "linux") {
          try {
            setfont Lat2-Terminus16
          } catch {
            # Silently continue if setfont fails
          }
        }
      }
      
      # Remove default greeting
      $env.config = {
        show_banner: false
        
        # History configuration
        history: {
          max_size: 100_000
          sync_on_enter: true
          file_format: "plaintext"
        }
        
        # Completion configuration
        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "fuzzy"
        }
        
        # Table configuration
        table: {
          mode: rounded
          index_mode: always
          show_empty: true
          padding: { left: 1, right: 1 }
          trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
          }
        }
        
        # Error handling
        error_style: "fancy"
        
        # Color configuration
        use_ansi_coloring: true
        
        # Cursor shape
        cursor_shape: {
          emacs: line
          vi_insert: block
          vi_normal: underscore
        }
        
        # Edit mode
        edit_mode: emacs
        
        # Shell integration
        shell_integration: {
          osc2: true
          osc7: true
          osc8: true
          osc9_9: false
          osc133: true
          osc633: true
          reset_application_mode: true
        }
        
        # Render right prompt on new line
        render_right_prompt_on_last_line: false
        
        # Use kitty protocol
        use_kitty_protocol: false
        
        # Highlight matching brackets
        highlight_resolved_externals: false
        
        # Recursion limit
        recursion_limit: 50
        
        # Plugin configuration
        plugin_gc: {
          default: {
            enabled: true
            stop_after: 10sec
          }
          plugins: {}
        }
        
        # Hooks
        hooks: {
          pre_prompt: [{ ||
            null  # Replace with actual hook code
          }]
          pre_execution: [{ ||
            null  # Replace with actual hook code  
          }]
          env_change: {
            PWD: [{|before, after|
              null  # Replace with actual hook code
            }]
          }
          display_output: "if (term size).columns >= 100 { table -e } else { table }"
          command_not_found: { ||
            null  # Replace with actual hook code
          }
        }
        
        # Menus
        menus: [
          {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
          }
          {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
          }
          {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
          }
        ]
        
        # Keybindings
        keybindings: [
          {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
              until: [
                { send: menu name: completion_menu }
                { send: menunext }
                { edit: complete }
              ]
            }
          }
          {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
          }
          {
            name: help_menu
            modifier: none
            keycode: f1
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: help_menu }
          }
          {
            name: completion_previous_menu
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menuprevious }
          }
          {
            name: next_page_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: { send: menupagenext }
          }
          {
            name: undo_or_previous_page_menu
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
              until: [
                { send: menupageprevious }
                { edit: undo }
              ]
            }
          }
          {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }
          }
          {
            name: cancel_command
            modifier: control
            keycode: char_c
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrlc }
          }
          {
            name: quit_shell
            modifier: control
            keycode: char_d
            mode: [emacs, vi_normal, vi_insert]
            event: { send: ctrld }
          }
          {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_normal, vi_insert]
            event: { send: clearscreen }
          }
          {
            name: search_history
            modifier: control
            keycode: char_q
            mode: [emacs, vi_normal, vi_insert]
            event: { send: searchhistory }
          }
          {
            name: open_command_editor
            modifier: control
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: openeditor }
          }
          {
            name: move_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: menuup}
                {send: up}
              ]
            }
          }
          {
            name: move_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: menudown}
                {send: down}
              ]
            }
          }
          {
            name: move_left
            modifier: none
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: menuleft}
                {send: left}
              ]
            }
          }
          {
            name: move_right_or_take_history_hint
            modifier: none
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: historyhintcomplete}
                {send: menuright}
                {send: right}
              ]
            }
          }
          {
            name: move_one_word_left
            modifier: control
            keycode: left
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movewordleft}
          }
          {
            name: move_one_word_right_or_take_history_hint
            modifier: control
            keycode: right
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: historyhintwordcomplete}
                {edit: movewordright}
              ]
            }
          }
          {
            name: move_to_line_start
            modifier: none
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
          }
          {
            name: move_to_line_start
            modifier: control
            keycode: char_a
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
          }
          {
            name: move_to_line_end_or_take_history_hint
            modifier: none
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: historyhintcomplete}
                {edit: movetolineend}
              ]
            }
          }
          {
            name: move_to_line_end_or_take_history_hint
            modifier: control
            keycode: char_e
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: historyhintcomplete}
                {edit: movetolineend}
              ]
            }
          }
          {
            name: move_to_line_start
            modifier: control
            keycode: home
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolinestart}
          }
          {
            name: move_to_line_end
            modifier: control
            keycode: end
            mode: [emacs, vi_normal, vi_insert]
            event: {edit: movetolineend}
          }
          {
            name: move_up
            modifier: control
            keycode: char_p
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: menuup}
                {send: up}
              ]
            }
          }
          {
            name: move_down
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: {
              until: [
                {send: menudown}
                {send: down}
              ]
            }
          }
          {
            name: delete_one_character_backward
            modifier: none
            keycode: backspace
            mode: [emacs, vi_insert]
            event: {edit: backspace}
          }
          {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
            mode: [emacs, vi_insert]
            event: {edit: backspaceword}
          }
          {
            name: delete_one_character_forward
            modifier: none
            keycode: delete
            mode: [emacs, vi_insert]
            event: {edit: delete}
          }
          {
            name: delete_one_character_forward
            modifier: control
            keycode: char_h
            mode: [emacs, vi_insert]
            event: {edit: backspace}
          }
          {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: {edit: backspaceword}
          }
          {
            name: move_left
            modifier: none
            keycode: backspace
            mode: vi_normal
            event: {edit: moveleft}
          }
          {
            name: newline_or_run_command
            modifier: none
            keycode: enter
            mode: emacs
            event: {send: enter}
          }
          {
            name: move_left
            modifier: control
            keycode: char_b
            mode: emacs
            event: {
              until: [
                {send: menuleft}
                {send: left}
              ]
            }
          }
          {
            name: move_right_or_take_history_hint
            modifier: control
            keycode: char_f
            mode: emacs
            event: {
              until: [
                {send: historyhintcomplete}
                {send: menuright}
                {send: right}
              ]
            }
          }
          {
            name: redo_change
            modifier: control
            keycode: char_g
            mode: emacs
            event: {edit: redo}
          }
          {
            name: undo_change
            modifier: control
            keycode: char_z
            mode: emacs
            event: {edit: undo}
          }
          {
            name: paste_before
            modifier: control
            keycode: char_y
            mode: emacs
            event: {edit: pastecutbufferbefore}
          }
          {
            name: cut_word_left
            modifier: control
            keycode: char_w
            mode: emacs
            event: {edit: cutwordleft}
          }
          {
            name: cut_line_to_end
            modifier: control
            keycode: char_k
            mode: emacs
            event: {edit: cuttoend}
          }
          {
            name: cut_line_from_start
            modifier: control
            keycode: char_u
            mode: emacs
            event: {edit: cutfromstart}
          }
          {
            name: swap_graphemes
            modifier: control
            keycode: char_t
            mode: emacs
            event: {edit: swapgraphemes}
          }
          {
            name: move_one_word_left
            modifier: alt
            keycode: left
            mode: emacs
            event: {edit: movewordleft}
          }
          {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: right
            mode: emacs
            event: {
              until: [
                {send: historyhintwordcomplete}
                {edit: movewordright}
              ]
            }
          }
          {
            name: move_one_word_left
            modifier: alt
            keycode: char_b
            mode: emacs
            event: {edit: movewordleft}
          }
          {
            name: move_one_word_right_or_take_history_hint
            modifier: alt
            keycode: char_f
            mode: emacs
            event: {
              until: [
                {send: historyhintwordcomplete}
                {edit: movewordright}
              ]
            }
          }
          {
            name: delete_one_word_forward
            modifier: alt
            keycode: char_d
            mode: emacs
            event: {edit: deleteword}
          }
          {
            name: delete_one_word_backward
            modifier: alt
            keycode: backspace
            mode: emacs
            event: {edit: backspaceword}
          }
          {
            name: cut_word_to_right
            modifier: alt
            keycode: char_d
            mode: emacs
            event: {edit: cutwordright}
          }
          {
            name: upper_case_word
            modifier: alt
            keycode: char_u
            mode: emacs
            event: {edit: uppercaseword}
          }
          {
            name: lower_case_word
            modifier: alt
            keycode: char_l
            mode: emacs
            event: {edit: lowercaseword}
          }
          {
            name: capitalize_char
            modifier: alt
            keycode: char_c
            mode: emacs
            event: {edit: capitalizechar}
          }
        ]
      }
      
      # Custom aliases (equivalent to fish shellAliases)
      alias jit = git
      alias cl = clear
      alias htop = btop
      alias xcopy = xclip -sel clip
      alias ppctl = powerprofilesctl
      #alias display-update = xrandr --output DP-2 --auto --output HDMI-0 --auto --right-of DP-2; xrandr --output HDMI-0 --mode 1920x1080 --rate 144.00
      
      def colorview [hex: string] {
        let clean_hex = ($hex | str replace -r "^#?" "")
        let r = ($clean_hex | str substring 0..2)
        let g = ($clean_hex | str substring 2..4)
        let b = ($clean_hex | str substring 4..6)
        
        let r_dec = ("0x" + $r | into int)
        let g_dec = ("0x" + $g | into int)
        let b_dec = ("0x" + $b | into int)
        
        print $"\u{001b}[48;2;($r_dec);($g_dec);($b_dec)m     \u{001b}[0m ($clean_hex)"
      }
      
      # Run microfetch on startup
      microfetch
    '';
    
    # Shell aliases can also be defined here for simpler cases
    shellAliases = {
      # You can put simple aliases here instead of in configFile.text if preferred
    };
  };
  
  # Make sure starship is configured for nushell
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
  
  # Make sure zoxide is configured for nushell
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    options = [];
  };
  
  # Make sure these packages are available
  home.packages = with pkgs; [
    lsd
    btop
    xclip
    # Add other packages you use
  ];
}
