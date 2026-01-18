$processNames = @("3proxy","electron", "cloudflared")
$ports = @(3128, 8888, 3389)
$startTime = Get-Date
$runDuration = New-TimeSpan -Hours 5 -Minutes 30  # 5 hours 30 minutes

while ($true) {
    Write-Host "=======================================`n"

    # ----- Process status -----
    foreach ($name in $processNames) {
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($procs) {
            Write-Host "=== $name ==="
            foreach ($p in $procs) {
                Write-Host "PID: $($p.Id) | CPU: $($p.CPU) | Memory(MB): $([math]::Round($p.WorkingSet/1MB,2)) | StartTime: $($p.StartTime)"
            }
        }
        else {
            Write-Host "$name process not running."
        }
    }

    # ----- Port status -----
    foreach ($port in $ports) {
        Write-Host "`n--- Checking port $port ---"
        $lines = netstat -ano | findstr ":$port"
        if ($lines) {
            $lines
        }
        else {
            Write-Host "Port $port is not listening."
        }
    }

    # Check if runtime has exceeded 5h30m
    $elapsedTime = (Get-Date) - $startTime
    if ($elapsedTime -gt $runDuration) {
        Write-Host "`n[$(Get-Date)] Runtime limit reached (5h30m). Stopping monitoring."
        break
    }

    Write-Host "`n[$(Get-Date)] Active - Runtime: $($elapsedTime.ToString('hh\:mm\:ss')) - Use Ctrl+C to terminate"
    Start-Sleep -Seconds 300
}