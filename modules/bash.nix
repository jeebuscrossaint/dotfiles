{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    # Environment variables (equivalent to fish shellInit)
    sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      GSK_RENDERER = "ngl";
      NIXPKGS_ALLOW_UNFREE = "1";
      EDITOR = "vim";
      XCURSOR_THEME = "rose-pine-cursor";
      XCURSOR_SIZE = "24";
    };
    
    # Shell aliases (equivalent to fish shellAliases)
    shellAliases = {
      jit = "git";
      ls = "lsd";
      cl = "clear";
      htop = "btop";
      "11" = "ping 1.1.1.1";
      xcopy = "xclip -sel clip";
      ppctl = "powerprofilesctl";
      update-nixos = "pushd $HOME/dotfiles && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake . && popd";
      new-wallpaper = "swww img \"$(find ~/wallpapers/ -type f -print0 | shuf -z -n 1)\"";
      display-update = "xrandr --output DP-2 --auto --output HDMI-0 --auto --right-of DP-2 && xrandr --output HDMI-0 --mode 1920x1080 --rate 144.00";
    };
    
    # Bash-specific options
    historyControl = [ "ignoredups" "ignorespace" ];
    historySize = 100000;
    historyFileSize = 100000;
    
    # Shell options (equivalent to fish interactiveShellInit)
    initExtra = ''
      # Custom bash settings
      set -o vi  # Use vi mode (optional, remove if you prefer emacs mode)
      
      # Better history
      shopt -s histappend
      shopt -s cmdhist
      shopt -s histreedit
      shopt -s histverify
      
      # Check window size after each command
      shopt -s checkwinsize
      
      # Enable extended globbing
      shopt -s extglob
      
      # Case-insensitive globbing
      shopt -s nocaseglob
      
      # Autocorrect typos in path names
      shopt -s cdspell
      shopt -s dirspell 2> /dev/null
      
      # Enable recursive globbing with **
      shopt -s globstar 2> /dev/null
      
      # Custom functions (equivalent to fish functions)
      findheader() {
        if [ $# -eq 0 ]; then
          echo "Usage: findheader <header_name>"
          return 1
        fi
        find /usr/include /usr/local/include -name "$1" 2>/dev/null
      }
      
      colorview() {
        if [ $# -eq 0 ]; then
          echo "Usage: colorview <hex_color>"
          return 1
        fi
        
        local hex="$1"
        # Remove # if present
        hex="''${hex#\#}"
        
        # Extract RGB components
        local r="''${hex:0:2}"
        local g="''${hex:2:2}"
        local b="''${hex:4:2}"
        
        # Convert hex to decimal
        local r_dec=$((16#$r))
        local g_dec=$((16#$g))  
        local b_dec=$((16#$b))
        
        # Display the color
        printf "\033[48;2;%d;%d;%dm     \033[0m %s\n" "$r_dec" "$g_dec" "$b_dec" "$hex"
      }
      
      # Better ls colors
      if [ -x "$(command -v dircolors)" ]; then
        eval "$(dircolors -b)"
      fi
      
      # Initialize starship prompt
      if command -v starship &> /dev/null; then
        eval "$(starship init bash)"
      fi
      
      # Initialize zoxide
      if command -v zoxide &> /dev/null; then
        eval "$(zoxide init bash)"
      fi
      
      # Run microfetch on startup (only in interactive shells)
      if [[ $- == *i* ]] && command -v pfetch &> /dev/null; then
        pfetch
      fi
      
      # Better tab completion
      bind "set completion-ignore-case on"
      bind "set completion-map-case on"
      bind "set show-all-if-ambiguous on"
      bind "set mark-symlinked-directories on"
      
      # Use fzf for reverse search if available
      if command -v fzf &> /dev/null; then
        # Set up fzf key bindings and fuzzy completion
        if [ -f /usr/share/fzf/key-bindings.bash ]; then
          source /usr/share/fzf/key-bindings.bash
        elif [ -f ~/.fzf/shell/key-bindings.bash ]; then
          source ~/.fzf/shell/key-bindings.bash
        fi
        
        if [ -f /usr/share/fzf/completion.bash ]; then
          source /usr/share/fzf/completion.bash
        elif [ -f ~/.fzf/shell/completion.bash ]; then
          source ~/.fzf/shell/completion.bash
        fi
        
        # Custom fzf options
        export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
        export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
      fi
      
      # Custom prompt (fallback if starship is not available)
      if ! command -v starship &> /dev/null; then
        # Simple colored prompt
        if [ "$EUID" -ne 0 ]; then
          PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        else
          PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\# '
        fi
      fi
    '';
    
    # Bash profile (runs for login shells)
    profileExtra = ''
      # Add any login-specific configuration here
      # This runs for login shells only
      
      # Ensure PATH includes common directories
      for dir in "$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/go/bin"; do
        if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
          export PATH="$dir:$PATH"
        fi
      done
    '';
    
    # Bash logout (runs when bash login shell exits)
    logoutExtra = ''
      # Clear the screen on logout
      clear
    '';
  };
  
  # Make sure starship is configured for bash
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  
  # Make sure zoxide is configured for bash
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [];
  };
  
  # Enable fzf for bash
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "find . -type f";
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
    historyWidgetOptions = [ "--sort" "--exact" ];
  };
  
  # Make sure these packages are available
  home.packages = with pkgs; [
    lsd
    btop
    xclip
    bat  # For fzf preview
    tree # For fzf directory preview
    # Add other packages you use
  ];
  
  # Additional readline configuration for better bash experience
  programs.readline = {
    enable = true;
    extraConfig = ''
      # Use Vi mode
      set editing-mode vi
      set keymap vi-command
      
      # Show vi mode in prompt
      set show-mode-in-prompt on
      set vi-ins-mode-string "\1\e[6 q\2"
      set vi-cmd-mode-string "\1\e[2 q\2"
      
      # Case insensitive completion
      set completion-ignore-case on
      set completion-map-case on
      
      # Show all completions immediately
      set show-all-if-ambiguous on
      set show-all-if-unmodified on
      
      # Append slash to directories
      set mark-directories on
      set mark-symlinked-directories on
      
      # Don't ring bell
      set bell-style none
      
      # Use colors for completion
      set colored-stats on
      set colored-completion-prefix on
      
      # Better word boundaries
      set skip-completed-text on
      
      # History search
      "\e[A": history-search-backward
      "\e[B": history-search-forward
      "\e[C": forward-char
      "\e[D": backward-char
      
      # Ctrl+left/right for word movement
      "\e[1;5C": forward-word
      "\e[1;5D": backward-word
      
      # Alt+left/right for word movement (alternative)
      "\e\e[C": forward-word
      "\e\e[D": backward-word
      
      # Page up/down for history search
      "\e[5~": history-search-backward
      "\e[6~": history-search-forward
      
      # Home/End keys
      "\e[H": beginning-of-line
      "\e[F": end-of-line
      "\e[1~": beginning-of-line
      "\e[4~": end-of-line
      
      # Delete key
      "\e[3~": delete-char
      
      # Ctrl+w to delete word backward
      "\C-w": backward-kill-word
      
      # Ctrl+u to delete line backward
      "\C-u": backward-kill-line
      
      # Ctrl+k to delete line forward
      "\C-k": kill-line
      
      # Tab completion cycling
      "\t": menu-complete
      "\e[Z": menu-complete-backward
    '';
  };
}
