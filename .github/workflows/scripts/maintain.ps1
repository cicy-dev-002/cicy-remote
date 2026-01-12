$processNames = @("3proxy","electron", "cloudflared")
$ports = @(3128, 8888, 3389)

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

  Write-Host "`n[$(Get-Date)] Active - Use Ctrl+C in workflow to terminate"
  Start-Sleep -Seconds 300
  break

}
