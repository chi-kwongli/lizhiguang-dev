[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)] [string]$Remote,
  [string]$Branch = 'main',
  [int]$DebounceSeconds = 3
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Sync = Join-Path $PSScriptRoot 'sync-github.ps1'
$watcher = New-Object IO.FileSystemWatcher $Root
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite, Size, DirectoryName'
$ignored = @('.git', '__pycache__', '.venv', 'node_modules')
$pending = $false
$lastEvent = Get-Date

$action = {
  $path = $Event.SourceEventArgs.FullPath
  if ($ignored | Where-Object { $path -like "*\$_\*" -or $path -like "*\$_" }) { return }
  $script:pending = $true
  $script:lastEvent = Get-Date
}
foreach ($eventName in @('Created', 'Changed', 'Deleted', 'Renamed')) {
  Register-ObjectEvent $watcher $eventName -Action $action | Out-Null
}
Write-Output "正在监听：$Root"
try {
  while ($true) {
    Start-Sleep -Seconds 1
    if ($pending -and ((Get-Date) - $lastEvent).TotalSeconds -ge $DebounceSeconds) {
      $pending = $false
      try {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $Sync -Remote $Remote -Branch $Branch
      } catch { Write-Warning "自动同步失败：$($_.Exception.Message)" }
    }
  }
} finally {
  $watcher.EnableRaisingEvents = $false
  $watcher.Dispose()
}
