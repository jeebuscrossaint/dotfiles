{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ls = "lsd";
      cl = "clear";
      "11" = "ping 1.1.1.1";
      xcopy = "xclip -sel clip";
      update-nixos = "pushd $HOME/dotfiles && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake . && popd";
    };
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "command-not-found" ];
    };
    
initExtra = ''
      # Command correction - the cool "did you mean" feature
      setopt CORRECT                    # Correct commands
      setopt CORRECT_ALL               # Correct all arguments
      
      # Cool history features
      setopt HIST_VERIFY               # Show command with history expansion before running
      setopt SHARE_HISTORY            # Share history across sessions
      setopt HIST_IGNORE_DUPS         # Don't save duplicates
      setopt HIST_FIND_NO_DUPS        # Don't find duplicates in search
      setopt HIST_IGNORE_SPACE        # Don't save commands starting with space
      
      # Cool globbing features
      setopt EXTENDED_GLOB            # Extended globbing patterns
      setopt GLOB_DOTS               # Include dotfiles in globbing
      
      # Cool cd features
      setopt AUTO_CD                 # Just type directory name to cd
      setopt AUTO_PUSHD             # Automatically pushd when cd
      setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
      
      # Make corrections more interactive
      export SPROMPT="Correct %F{red}%R%f to %F{green}%r%f? [nyae] "
      
      # Cool key bindings
      bindkey '^[[A' history-search-backward    # Up arrow searches history
      bindkey '^[[B' history-search-forward     # Down arrow searches history
      bindkey '^R' history-incremental-search-backward  # Ctrl+R for search
      
      # Make tab completion cooler
      zstyle ':completion:*' menu select                    # Visual menu for completion
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}  # Colorful completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
      zstyle ':completion:*' rehash true                    # Auto-find new programs
      
      # Git aliases that are sick
      alias gst="git status"
      alias gco="git checkout" 
      alias gcb="git checkout -b"
      alias gp="git push"
      alias gl="git pull"
      alias ga="git add"
      alias gc="git commit"
      alias gd="git diff"
      alias glog="git log --oneline --graph --decorate"
      
      # Directory shortcuts
      alias ..="cd .."
      alias ...="cd ../.."
      alias ....="cd ../../.."
      
      # Make cd history accessible with "d"
      alias d="dirs -v"
      for index ({1..9}) alias "$index"="cd +''${index}"; unset index
      
      pfetch
    '';

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
  };
}
