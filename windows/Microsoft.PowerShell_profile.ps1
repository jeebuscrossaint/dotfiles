Invoke-Expression (&starship init powershell)
pfetch
Set-Alias -Name jit -Value git
Set-Alias -Name ls -Value eza
Set-Alias -Name cl -Value clear
Set-Alias -Name p11 -Value 'ping 1.1.1.1'
Set-Alias -Name gp11 -Value 'ping 1.1.1.1'
Set-Alias -Name cdp -Value 'cd ~/Projects'
Set-Alias -Name lilith -Value '.\Desktop\lilith-launcher-windows-s3.exe'
Set-Alias -Name yasb -Value 'python310 ./yasb/src/main.py'
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
