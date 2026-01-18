Write-Host "Current username: $env:USERNAME"

curl -fsSL api.myip.com | python -m json.tool
python --version

# 3proxy
# Download config
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cicybot/personal/refs/heads/main/assets/3proxy_v1.cfg" -OutFile "$env:USERPROFILE\3proxy.cfg"

# Download 3proxy
Invoke-WebRequest -Uri "https://github.com/3proxy/3proxy/releases/download/0.9.5/3proxy-0.9.5-x64.zip" -OutFile "$env:USERPROFILE\3proxy.zip"

# Extract
Expand-Archive -Path "$env:USERPROFILE\3proxy.zip" -DestinationPath "$env:USERPROFILE\3proxy" -Force

# Start 3proxy (detached)
Start-Process -FilePath "$env:USERPROFILE\3proxy\bin64\3proxy.exe" -ArgumentList "$env:USERPROFILE\3proxy.cfg" -WindowStyle Hidden

Write-Host "Waiting for 3proxy to start..."
Start-Sleep -Seconds 1

### -------- HEALTH CHECKS -------- ###

Write-Host "`n=== Checking process ==="
$proc = Get-Process -Name 3proxy -ErrorAction SilentlyContinue
if (-not $proc) {
  Write-Error "3proxy process NOT running"
  exit 1
}
Write-Host "3proxy running with PID $($proc.Id)"

Write-Host "`n=== Checking listening ports ==="
$ports = @(3128,1080)
foreach ($p in $ports) {
  $net = netstat -ano | findstr ":$p"
  if ($net) {
      Write-Host "Port $p is LISTENING"
      $net
  } else {
      Write-Warning "Port $p not open"
  }
}

Write-Host "`n=== Proxy connectivity test (HTTP) ==="
try {
  $result = curl.exe -fsLS -x http://127.0.0.1:3128 https://api.myip.com --max-time 10
  Write-Host "Success:"
  Write-Host $result
} catch {
  Write-Warning "Curl proxy test failed"
}


# Configure Core RDP Settings and firewall
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 0 -Force
netsh advfirewall firewall delete rule name="RDP-Tailscale"
netsh advfirewall firewall add rule name="RDP-Tailscale" dir=in action=allow protocol=TCP localport=3389
Restart-Service -Name TermService -Force

# Change current user password
net user $env:USERNAME $env:JUPYTER_TOKEN

# Add current user to Administrators and Remote Desktop Users
# Add-LocalGroupMember -Group "Administrators" -Member $env:USERNAME
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $env:USERNAME

# Verify RDP port 3389

$testResult = Test-NetConnection -ComputerName 127.0.0.1 -Port 3389
if (-not $testResult.TcpTestSucceeded) { throw "TCP connection to 3389 failed" }
Write-Host "TCP connectivity successful!"

# Install Cloudflared
$tsUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi"
$installerPath = "$env:TEMP\cloudflared.msi"
Invoke-WebRequest -Uri $tsUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i","`"$installerPath`"","/quiet","/norestart" -Wait
Remove-Item $installerPath -Force

# Establish Cloudflared Connection
& "C:\Program Files (x86)\cloudflared\cloudflared.exe" service install $env:CF_TUNNEL

npm i -g opencode-ai

opencode -v

#Jupyter
pip install jupyterlab
jupyter --version
Write-Host "started Jupyter"
# Run Jupyter Lab as user "ton" using PsExec
$runAsCommand = "jupyter lab --IdentityProvider.token=$env:JUPYTER_TOKEN --ip=0.0.0.0 --port=8888 --ServerApp.allow_remote_access=True --ServerApp.trust_xheaders=True --no-browser"
c:\PSTools\PsExec.exe -accepteula -u ton -p $env:JUPYTER_TOKEN cmd /c "start /b $runAsCommand"

Write-Host "Jupyter to started"
