[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)] [string]$Remote,
  [string]$Branch = 'main',
  [int]$DebounceSeconds = 3,
  [string]$TaskName = 'lizhiguang-dev-auto-sync'
)

$ErrorActionPreference = 'Stop'
$watcher = Join-Path $PSScriptRoot 'watch-and-sync.ps1'
if (-not (Test-Path -LiteralPath $watcher)) { throw "找不到监听脚本：$watcher" }

$escapedWatcher = $watcher.Replace('"', '\"')
$escapedRemote = $Remote.Replace('"', '\"')
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$escapedWatcher`" -Remote `"$escapedRemote`" -Branch `"$Branch`" -DebounceSeconds $DebounceSeconds"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arguments
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings `
  -Description '登录后自动监听 lizhiguang-dev skill 变更并同步到 GitHub。' -Force | Out-Null
Start-ScheduledTask -TaskName $TaskName
Write-Output "已安装并启动自动同步任务：$TaskName"
