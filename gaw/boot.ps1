
# $dir = "C:\project"
# $installerName = "Antigravity_Installer.exe"
# $installerPath = Join-Path $dir $installerName
# $url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.15.8-5724687216017408/windows-x64/Antigravity.exe"

# # 1. 确保目录存在
# if (-not (Test-Path $dir)) {
#     Write-Host "创建目录 $dir..."
#     New-Item -Path $dir -ItemType Directory | Out-Null
# }

# # 2. 检查安装包是否存在
# if (Test-Path $installerPath) {
#     Write-Host "检测到已存在安装包: $installerPath，准备安装..."
# } else {
#     Write-Host "未找到安装包，正在开始下载..."
#     try {
#         Invoke-WebRequest -Uri $url -OutFile $installerPath -ErrorAction Stop
#         Write-Host "下载成功！保存至 $installerPath"
#     } catch {
#         Write-Error "下载过程中出错: $($_.Exception.Message)"
#         exit 1
#     }
# }

# # 3. 运行安装程序
# Write-Host "正在启动安装程序..."
# # 使用 /S 进行静默安装 (Silent)
# $process = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru

# if ($process.ExitCode -eq 0) {
#     Write-Host "安装程序执行完毕。"
# } else {
#     Write-Warning "安装程序返回非零退出代码: $($process.ExitCode)"
# }

# # 4. 验证并启动应用
# $exePath = "$env:LOCALAPPDATA\Programs\Antigravity\Antigravity.exe"
# if (Test-Path $exePath) {
#     Write-Host "Antigravity 已安装，正在启动..."
#     Start-Process -FilePath $exePath
# } else {
#     Write-Warning "未在默认路径发现 Antigravity.exe，可能需要手动完成后续设置。"
# }

# Write-Host "--- 任务完成 ---"


Write-Host "--- 开始 Kiro IDE 部署检查 ---"

$dir = "C:\project"
$installerName = "Kiro_Installer.exe"
$installerPath = Join-Path $dir $installerName
# 更新为 Kiro IDE 的下载地址
$url = "https://prod.download.desktop.kiro.dev/releases/stable/win32-x64/signed/0.8.206/kiro-ide-0.8.206-stable-win32-x64.exe"

# 1. 确保目录存在
if (-not (Test-Path $dir)) {
    Write-Host "创建目录 $dir..."
    New-Item -Path $dir -ItemType Directory | Out-Null
}

# 2. 检查安装包是否存在
if (Test-Path $installerPath) {
    Write-Host "检测到已存在安装包: $installerPath，准备安装..."
} else {
    Write-Host "未找到安装包，正在开始下载..."
    try {
        # 增加 User-Agent 以防止某些服务器拒绝 PowerShell 默认请求
        Invoke-WebRequest -Uri $url -OutFile $installerPath -UserAgent "Mozilla/5.0" -ErrorAction Stop
        Write-Host "下载成功！保存至 $installerPath"
    } catch {
        Write-Error "下载过程中出错: $($_.Exception.Message)"
        exit 1
    }
}

# 3. 运行安装程序
Write-Host "正在启动安装程序..."
# 关键修改：针对 User Installer 在管理员模式下运行，增加 --current-user 参数
# /S 为静默安装，--current-user 尝试跳过管理员环境警告并安装到当前用户目录下
$process = Start-Process -FilePath $installerPath -ArgumentList "/S", "--current-user" -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "安装程序执行完毕。"
} else {
    Write-Warning "安装程序返回非零退出代码: $($process.ExitCode)。如果安装未成功，请检查是否仍弹出权限警告。"
}

# 4. 验证并启动应用
# Kiro 通常安装在 LocalAppData 下的 Programs 文件夹
$exePath = "$env:LOCALAPPDATA\Programs\kiro-ide\Kiro.exe"

if (Test-Path $exePath) {
    Write-Host "Kiro IDE 已安装，正在启动..."
    Start-Process -FilePath $exePath
} else {
    # 备选路径检查（有些版本可能直接在 LocalAppData\kiro-ide）
    $altPath = "$env:LOCALAPPDATA\kiro-ide\Kiro.exe"
    if (Test-Path $altPath) {
        Write-Host "在备选路径发现 Kiro IDE，正在启动..."
        Start-Process -FilePath $altPath
    } else {
        Write-Warning "未在默认路径发现 Kiro.exe，请检查 $env:LOCALAPPDATA 确认安装目录。"
    }
}

Write-Host "--- 任务完成 ---"