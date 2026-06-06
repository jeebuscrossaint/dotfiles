function fish_prompt
    set -l last_status $status
    set -l last_duration $CMD_DURATION

    # ── top line ──────────────────────────────────────────────
    # hostname
    set_color --bold cyan
    printf '%s' $hostname
    set_color normal

    printf ' '
    set_color brblack
    printf 'in'
    set_color normal
    printf ' '

    # directory
    set_color --bold magenta
    printf '%s' (prompt_pwd -D 3)
    set_color normal

    # git — single subprocess for branch + status + ahead/behind
    set -l git_info (git status --porcelain --branch 2>/dev/null)
    if test -n "$git_info"
        set -l branch_line $git_info[1]
        set -l branch (string match -rg '^## (\S+?)(?:\.\.\.|\s|$)' $branch_line)

        if test -n "$branch" -a "$branch" != HEAD
            printf ' '
            set_color brblack
            printf 'on'
            set_color normal
            printf ' '
            set_color --bold magenta
            printf ' %s' $branch
            set_color normal

            # dirty indicators from remaining lines
            if test (count $git_info) -gt 1
                set -l rest $git_info[2..]
                set -l indicators ''
                string match -qr '^\?\?' $rest; and set indicators $indicators'?'
                string match -qr '^.[MD]' $rest; and set indicators $indicators'!'
                string match -qr '^[MADRCU]' $rest; and set indicators $indicators'+'
                if test -n "$indicators"
                    printf ' '
                    set_color --bold red
                    printf '[%s]' $indicators
                    set_color normal
                end
            end

            # ahead/behind from branch line (e.g. "## main...origin/main [ahead 1, behind 2]")
            set -l ahead (string match -rg 'ahead (\d+)' $branch_line)
            set -l behind (string match -rg 'behind (\d+)' $branch_line)
            if test -n "$ahead" -o -n "$behind"
                printf ' '
                set_color --bold red
                test -n "$ahead"; and printf '⇡%s' $ahead
                test -n "$behind"; and printf '⇣%s' $behind
                set_color normal
            end
        end
    end

    # duration
    if test $last_duration -ge 500
        printf ' '
        set_color --bold yellow
        if test $last_duration -ge 60000
            printf 'took %dm%ds' (math --scale=0 $last_duration / 60000) (math --scale=0 "($last_duration % 60000) / 1000")
        else if test $last_duration -ge 1000
            printf 'took %.1fs' (math $last_duration / 1000.0)
        else
            printf 'took %dms' $last_duration
        end
        set_color normal
    end

    printf '\n'

    # ── prompt character ──────────────────────────────────────
    if test $last_status -eq 0
        set_color --bold green
    else
        set_color --bold red
    end
    printf '❯ '
    set_color normal
end
