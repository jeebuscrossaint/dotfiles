function sudo --description 'sudo, but refuses to run hyprpm'
    # `sudo hyprpm` is the one command that quietly breaks this setup. hyprpm's
    # cache lives in /var/cache/hyprpm/$USER, and a single root run leaves
    # state.toml and the built .so files owned by root. After that every later
    # hyprpm call fails to write its state -- and worse, the state it cannot
    # rewrite still claims the plugins are current, so `hyprpm update` reports
    # "up-to-date" and skips the rebuild. The plugins then silently stop loading
    # on the next aquamarine bump, with nothing pointing at the cause.
    #
    # It is refused rather than warned about because there is no case where it is
    # the right thing to do: hyprpm builds and loads plugins for YOUR session.
    if test (count $argv) -gt 0
        for arg in $argv
            switch $arg
                case '-*'
                    continue
                case hyprpm
                    echo "sudo: refusing to run hyprpm as root." >&2
                    echo "  It leaves /var/cache/hyprpm/$USER owned by root, and the" >&2
                    echo "  stale state then makes hyprpm update skip the rebuild." >&2
                    echo "  Run it as yourself:  hyprpm $argv[2..]" >&2
                    return 1
                case '*'
                    break
            end
        end
    end
    command sudo $argv
end
