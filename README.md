# lizhiguang-dev

lizhiguang 的个人编程开发协作 skill，适用于代码修改、排障、架构优化、测试、Git 交付和部署，并持续沉淀协作偏好。

## 安装

### Codex / CC GUI

```powershell
$skillRoot = "$env:USERPROFILE\.codex\skills"
git clone https://github.com/chi-kwongli/lizhiguang-dev.git "$skillRoot\lizhiguang-dev"
```

已有目录更新：

```powershell
git -C "$env:USERPROFILE\.codex\skills\lizhiguang-dev" pull --ff-only
```

重启 Codex 或在 CC GUI 的 Skills 页面点击刷新，调用名称为 `$lizhiguang-dev`。

### Linux / WSL

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/chi-kwongli/lizhiguang-dev.git ~/.codex/skills/lizhiguang-dev
```

## 自动同步到 GitHub

首次配置远端并推送：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-github.ps1 -Remote https://github.com/chi-kwongli/lizhiguang-dev.git
```

脚本使用 Git Credential Manager 或 SSH 认证，不把 Token 写进 URL、日志或仓库。

启动文件监听同步：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\watch-and-sync.ps1 -Remote https://github.com/chi-kwongli/lizhiguang-dev.git
```

监听进程发现 skill 文件变化后会自动追加 `CHANGELOG.md`、提交并推送。停止监听可关闭对应 PowerShell 进程；需要长期运行时可通过任务计划程序在登录时启动。

安装为当前 Windows 用户的登录任务（推荐）：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-auto-sync.ps1 -Remote https://github.com/chi-kwongli/lizhiguang-dev.git
```

移除自动同步任务：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\uninstall-auto-sync.ps1
```

## 更新日志

每次自动同步会追加到 [CHANGELOG.md](CHANGELOG.md)，长期偏好仍记录在 `references/learning-log.md`。更新日志不记录密码、Token、Cookie 或业务数据。
