Invoke-Expression (&starship init powershell)
fastfetch
Set-Alias -Name jit -Value git
Set-Alias -Name cl -Value clear
Invoke-Expression (&scoop-search --hook)
