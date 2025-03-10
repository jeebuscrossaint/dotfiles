Invoke-Expression (&starship init powershell)
pfetch
Set-Alias -Name jit -Value git
Set-Alias -Name ls -Value lsd
Set-Alias -Name cl -Value clear
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
$env:Path += ";c:\users\amarnath\scoop\apps\python\current\lib\site-packages"
Import-Module ~\winwal\winwal.psm1
$env:Path += ";$env:APPDATA\Python\Python313\Scripts"
Invoke-Expression (&scoop-search --hook)
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
