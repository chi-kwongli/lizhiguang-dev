[CmdletBinding()]
param([string]$TaskName = 'lizhiguang-dev-auto-sync')

$ErrorActionPreference = 'Stop'
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
Write-Output "已移除自动同步任务：$TaskName"
