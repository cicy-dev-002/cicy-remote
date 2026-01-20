$processNames = @("3proxy","electron","jupyter", "cloudflared")
$ports = @(3128, 3389, 3456, 8888)
$startTime = Get-Date
$runDuration = New-TimeSpan -Hours 5 -Minutes 30  # 5 hours 30 minutes
$monitorFile = "C:\running.txt"  # 监控文件路径

while ($true) {
    Write-Host "=======================================`n"
    Write-Host "[$(Get-Date)] Monitoring started. Checking processes, ports and monitor file...`n"

    # ----- 检查监控文件是否存在 -----
    if (-not (Test-Path -Path $monitorFile -PathType Leaf)) {
        Write-Host "`n======================================="
        Write-Host "[$(Get-Date)] ERROR: Monitor file $monitorFile not found!"
        Write-Host "[$(Get-Date)] Stopping monitoring and exiting loop."
        Write-Host "=======================================`n"
        break
    }

    # ----- Process status -----
    foreach ($name in $processNames) {
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($procs) {
            Write-Host "=== $name ==="
            foreach ($p in $procs) {
                # 处理可能无法获取StartTime的情况（某些系统进程可能没有StartTime）
                $startTimeStr = if ($p.StartTime) { $p.StartTime.ToString() } else { "N/A" }
                Write-Host "PID: $($p.Id) | CPU: $($p.CPU) | Memory(MB): $([math]::Round($p.WorkingSet/1MB,2)) | StartTime: $startTimeStr"
            }
        }
        else {
            Write-Host "$name process not running."
        }
    }

    # ----- Port status -----
    foreach ($port in $ports) {
        Write-Host "`n--- Checking port $port ---"
        # 使用更可靠的端口检查方法，避免netstat兼容性问题
        try {
            $tcpListeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
            $udpListeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveUdpListeners()

            $tcpListening = $tcpListeners | Where-Object { $_.Port -eq $port }
            $udpListening = $udpListeners | Where-Object { $_.Port -eq $port }

            if ($tcpListening) {
                Write-Host "TCP Port $port is listening on:"
                $tcpListening | ForEach-Object { Write-Host "  - $($_.Address):$($_.Port)" }
            }
            if ($udpListening) {
                Write-Host "UDP Port $port is listening on:"
                $udpListening | ForEach-Object { Write-Host "  - $($_.Address):$($_.Port)" }
            }
            if (-not $tcpListening -and -not $udpListening) {
                Write-Host "Port $port is not listening (TCP/UDP)."
            }
        }
        catch {
            Write-Host "Error checking port $port : $_"
        }
    }

    # Check if runtime has exceeded 5h30m
    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime -gt $runDuration) {
        Write-Host "`n======================================="
        Write-Host "[$(Get-Date)] Runtime limit reached (5h30m)."
        Write-Host "[$(Get-Date)] Stopping monitoring."
        Write-Host "=======================================`n"
        break
    }

    Write-Host "`n======================================="
    Write-Host "[$(Get-Date)] Active - Runtime: $($elapsedTime.ToString('hh\:mm\:ss'))"
    Write-Host "[$(Get-Date)] Monitor file exists: $monitorFile"
    Write-Host "[$(Get-Date)] Next check in 5 minutes (Ctrl+C to terminate)"
    Write-Host "=======================================`n`n"

    Start-Sleep -Seconds 300
}