# fish completion for ww - Wayland wallpaper setter

# Modes
complete -c ww -s m -l mode -d 'Scaling mode' -xa 'fit fill stretch center tile'

# Transitions
complete -c ww -s t -l transition -d 'Transition effect' -xa 'none fade slide-left slide-right slide-up slide-down zoom-in zoom-out circle-open circle-close wipe-left wipe-right wipe-up wipe-down dissolve pixelate'

# Output selection
complete -c ww -s o -l output -d 'Set wallpaper for specific output' -xa '(ww --list-outputs 2>/dev/null | string match -r "^\s+\K[^ ]+")'

# Color
complete -c ww -s c -l color -d 'Solid color or letterbox color' -x

# Interval
complete -c ww -s i -l interval -d 'Slideshow interval in seconds' -xa '60 120 300 600'

# Duration
complete -c ww -s d -l duration -d 'Transition duration in seconds' -xa '0.5 1.0 1.5 2.0 2.5 3.0'

# FPS
complete -c ww -s f -l fps -d 'Transition frame rate' -xa '15 30 60 120 144 240'

# Boolean flags
complete -c ww -s l -l loop -d 'Loop animated wallpapers'
complete -c ww -s S -l slideshow -d 'Slideshow mode'
complete -c ww -s r -l random -d 'Random slideshow order'
complete -c ww -s R -l recursive -d 'Scan directories recursively'
complete -c ww -s D -l daemon -d 'Run in background and restore from cache'
complete -c ww -s L -l list-outputs -d 'List available outputs'
complete -c ww -s v -l version -d 'Show version information'
complete -c ww -s h -l help -d 'Show help message'

# File completion for wallpaper paths
complete -c ww -F
