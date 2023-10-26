if status is-interactive
    # Commands to run in interactive sessions can go here
#pfetch
nerdfetch
set -g fish_greeting
end

thefuck --alias | source
starship init fish | source
alias drake='neovide' 
