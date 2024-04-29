if status is-interactive
    # Commands to run in interactive sessions can go here

pfetch
set -g fish_greeting
end
fish_config theme choose Old\ School
thefuck --alias | source
starship init fish | source
alias drake='neovide' 
