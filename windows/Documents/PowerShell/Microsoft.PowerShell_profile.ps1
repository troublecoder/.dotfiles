Import-Module -Name Microsoft.WinGet.CommandNotFound

oh-my-posh init pwsh | Invoke-Expression
uv generate-shell-completion powershell | Out-String | Invoke-Expression
uvx --generate-shell-completion powershell | Out-String | Invoke-Expression
