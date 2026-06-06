fastfetch
Set-Alias -Name jit -Value git
Set-Alias -Name cl -Value clear
Invoke-Expression (&scoop-search --hook)

# Remove any PS alias that has a matching executable in PATH (lets uutils win)
Get-Alias | Where-Object {
    Get-Command $_.Name -CommandType Application -ErrorAction SilentlyContinue
} | ForEach-Object {
    Remove-Item "Alias:\$($_.Name)" -Force -ErrorAction SilentlyContinue
}
