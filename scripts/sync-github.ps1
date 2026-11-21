[CmdletBinding()]
param(
  [string]$Remote = '',
  [string]$Branch = 'main',
  [string]$Message = '',
  [switch]$SkipChangelog
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

if (-not (Test-Path (Join-Path $Root '.git'))) { git init -b $Branch }
if ($Remote) {
  $origin = git remote get-url origin 2>$null
  if ($LASTEXITCODE -ne 0) { git remote add origin $Remote }
  elseif ($origin -ne $Remote) { git remote set-url origin $Remote }
}
if (-not (git remote get-url origin 2>$null)) {
  throw '未配置 GitHub 远端。请使用 -Remote https://github.com/OWNER/lizhiguang-dev.git。'
}

if (-not $Message) { $Message = "chore: 更新个人开发 skill $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" }

# 先查看待提交文件；仅日志自身变化时不重复追加日志，避免 watcher 形成循环提交。
$changedBeforeLog = @(git status --short | Where-Object { $_ -and ($_ -notmatch '^\s*[MADRCU?!]{1,2}\s+CHANGELOG\.md$') })
if (-not $SkipChangelog -and $changedBeforeLog.Count -gt 0) {
  $changelogPath = Join-Path $Root 'CHANGELOG.md'
  $date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $changedFiles = ($changedBeforeLog | ForEach-Object { $_.Substring([Math]::Min(3, $_.Length)).Trim() }) -join ', '
  $entry = "`n- $date - $Message - 文件：$changedFiles"
  Add-Content -LiteralPath $changelogPath -Value $entry -Encoding UTF8
}

git add -A
$pending = git diff --cached --name-only
if (-not $pending) { Write-Output '没有文件变化，不提交。'; exit 0 }
git commit -m $Message
if ((git branch --show-current) -ne $Branch) { git branch -M $Branch }
git push -u origin $Branch
Write-Output "已推送：$Branch"
