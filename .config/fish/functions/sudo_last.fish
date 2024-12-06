function sudo_last
    eval "sudo " (history --max 1 | head -n 1 | cut -c 8-)
end
