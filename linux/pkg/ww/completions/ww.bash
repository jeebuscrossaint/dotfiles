# bash completion for ww - Wayland wallpaper setter

_ww() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-o --output -m --mode -c --color -l --loop -S --slideshow -i --interval \
          -r --random -R --recursive -t --transition -d --duration -f --fps \
          -D --daemon -L --list-outputs -v --version -h --help"

    case "${prev}" in
        -o|--output)
            # Get list of outputs from ww
            local outputs=$(ww --list-outputs 2>/dev/null | grep -oP '^\s+\K[^ ]+' || echo "")
            COMPREPLY=( $(compgen -W "${outputs}" -- ${cur}) )
            return 0
            ;;
        -m|--mode)
            COMPREPLY=( $(compgen -W "fit fill stretch center tile" -- ${cur}) )
            return 0
            ;;
        -t|--transition)
            local transitions="none fade slide-left slide-right slide-up slide-down \
                             zoom-in zoom-out circle-open circle-close \
                             wipe-left wipe-right wipe-up wipe-down \
                             dissolve pixelate"
            COMPREPLY=( $(compgen -W "${transitions}" -- ${cur}) )
            return 0
            ;;
        -c|--color)
            # Suggest common colors
            COMPREPLY=( $(compgen -W "'#000000' '#FFFFFF' '#282828' '#FF5733'" -- ${cur}) )
            return 0
            ;;
        -i|--interval)
            COMPREPLY=( $(compgen -W "60 120 300 600" -- ${cur}) )
            return 0
            ;;
        -d|--duration)
            COMPREPLY=( $(compgen -W "0.5 1.0 1.5 2.0 2.5 3.0" -- ${cur}) )
            return 0
            ;;
        -f|--fps)
            COMPREPLY=( $(compgen -W "15 30 60 120 144 240" -- ${cur}) )
            return 0
            ;;
    esac

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    # Complete with files for wallpaper path
    COMPREPLY=( $(compgen -f -- ${cur}) )
    return 0
}

complete -F _ww ww
