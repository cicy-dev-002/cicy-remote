$tsUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi"
$installerPath = "$env:TEMP\cloudflared.msi"
Invoke-WebRequest -Uri $tsUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i","`"$installerPath`"","/quiet","/norestart" -Wait
Remove-Item $installerPath -Force



