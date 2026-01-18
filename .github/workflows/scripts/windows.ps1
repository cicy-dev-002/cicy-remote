Write-Host "Starting system info check..."
Write-Host "Current username: $env:USERNAME"
Write-Host "Fetching public IP..."
curl -fsSL api.myip.com | python -m json.tool
Write-Host "Checking Python version..."
python --version
Write-Host "System info check completed."

Write-Host "Starting 3proxy setup..."
Write-Host "Downloading 3proxy config..."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cicybot/personal/refs/heads/main/assets/3proxy_v1.cfg" -OutFile "$env:USERPROFILE\3proxy.cfg"
Write-Host "3proxy config downloaded."

Write-Host "Downloading 3proxy binary..."
Invoke-WebRequest -Uri "https://github.com/3proxy/3proxy/releases/download/0.9.5/3proxy-0.9.5-x64.zip" -OutFile "$env:USERPROFILE\3proxy.zip"
Write-Host "3proxy binary downloaded."

Write-Host "Extracting 3proxy..."
Expand-Archive -Path "$env:USERPROFILE\3proxy.zip" -DestinationPath "$env:USERPROFILE\3proxy" -Force
Write-Host "3proxy extracted."

Write-Host "Starting 3proxy service..."
Start-Process -FilePath "$env:USERPROFILE\3proxy\bin64\3proxy.exe" -ArgumentList "$env:USERPROFILE\3proxy.cfg" -WindowStyle Hidden
Write-Host "3proxy started."

Write-Host "Waiting for 3proxy to start..."
Start-Sleep -Seconds 1
Write-Host "Starting 3proxy health checks..."

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
  Write-Host "Checking port $p..."
  $net = netstat -ano | findstr ":$p"
  if ($net) {
      Write-Host "Port $p is LISTENING"
      $net
  } else {
      Write-Warning "Port $p not open"
  }
}
Write-Host "Port checks completed."

Write-Host "`n=== Proxy connectivity test (HTTP) ==="
Write-Host "Testing proxy connectivity..."
try {
  $result = curl.exe -fsLS -x http://127.0.0.1:3128 https://api.myip.com --max-time 10
  Write-Host "Success:"
  Write-Host $result
} catch {
  Write-Warning "Curl proxy test failed"
}
Write-Host "Proxy test completed."


Write-Host "Starting RDP configuration..."
Write-Host "Configuring RDP settings..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 0 -Force
Write-Host "RDP settings configured."

Write-Host "Configuring firewall for RDP..."
netsh advfirewall firewall delete rule name="RDP-Tailscale"
netsh advfirewall firewall add rule name="RDP-Tailscale" dir=in action=allow protocol=TCP localport=3389
Write-Host "Firewall configured."

Write-Host "Restarting RDP service..."
Restart-Service -Name TermService -Force
Write-Host "RDP service restarted."

Write-Host "Changing current user password..."
net user $env:USERNAME $env:JUPYTER_TOKEN
Write-Host "Password changed."

Write-Host "Adding current user to groups..."
# Add-LocalGroupMember -Group "Administrators" -Member $env:USERNAME
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $env:USERNAME
Write-Host "User added to Remote Desktop Users group."

Write-Host "Verifying RDP port 3389..."
$testResult = Test-NetConnection -ComputerName 127.0.0.1 -Port 3389
if (-not $testResult.TcpTestSucceeded) { throw "TCP connection to 3389 failed" }
Write-Host "TCP connectivity successful!"

Write-Host "Installing Cloudflared..."
$tsUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi"
$installerPath = "$env:TEMP\cloudflared.msi"
Write-Host "Downloading Cloudflared installer..."
Invoke-WebRequest -Uri $tsUrl -OutFile $installerPath
Write-Host "Running installer..."
Start-Process msiexec.exe -ArgumentList "/i","`"$installerPath`"","/quiet","/norestart" -Wait
Remove-Item $installerPath -Force
Write-Host "Cloudflared installed."

Write-Host "Establishing Cloudflared connection..."
& "C:\Program Files (x86)\cloudflared\cloudflared.exe" service install $env:CF_TUNNEL
Write-Host "Cloudflared service installed."

pip install pyautogui

Write-Host "Installing JupyterLab..."
pip install jupyterlab
Write-Host "JupyterLab installed."

Write-Host "Checking Jupyter version..."
jupyter --version
Write-Host "Jupyter version checked."

# Write-Host "Starting Jupyter Lab..."
# Start-Process `
# -FilePath "jupyter" `
# -ArgumentList @(
#   "lab",
#   "--IdentityProvider.token=$env:JUPYTER_TOKEN",
#   "--ip=0.0.0.0",
#   "--port=8888",
#   "--ServerApp.allow_remote_access=True",
#   "--ServerApp.trust_xheaders=True",
#   "--no-browser"
# ) `
# -WindowStyle Hidden
# Write-Host "Jupyter Lab started."

Write-Host "Installing opencode-ai..."
npm i -g opencode-ai
Write-Host "opencode-ai installed."

Write-Host "Checking opencode version..."
opencode -v
Write-Host "opencode version checked."
#
Write-Host "Cloning electron-headless repository..."
git clone --branch mcp --single-branch https://github.com/cicybot/electron-headless.git d:\electron-mcp
Write-Host "Repository cloned."

Write-Host "Installing dependencies..."
cd d:\electron-mcp\app
npm install
Write-Host "Dependencies installed."
#
Write-Host "Building project..."
npm run build
Write-Host "Project built."

Start-Sleep -Seconds 1