[CmdletBinding()]
param([string]$TaskName = 'lizhiguang-dev-auto-sync')

$ErrorActionPreference = 'Stop'
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
$shortcutPath = Join-Path ([Environment]::GetFolderPath('Startup')) "$TaskName.lnk"
if (Test-Path -LiteralPath $shortcutPath) {
  Remove-Item -LiteralPath $shortcutPath -Force
}
Write-Output "已移除自动同步任务或 Startup 启动项：$TaskName"
