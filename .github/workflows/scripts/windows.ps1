#Step 2: System info
curl -fsSL api.myip.com | python -m json.tool
python --version




      - name: Add Electron to PATH
        shell: pwsh
        run: |
          $electronPath = "~\electron"
          "$electronPath" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

      - name: Check Electron version
        run: electron.exe -v
        shell: pwsh

      - name: Setup and test 3Proxy
        shell: pwsh
        run: |
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
              $result = curl.exe -x http://127.0.0.1:3128 https://api.myip.com --max-time 10
              Write-Host "Success:"
              Write-Host $result
          } catch {
              Write-Warning "Curl proxy test failed"
          }

      - name: Configure Core RDP Settings
        shell: pwsh
        run: .github/workflows/scripts/win-configure-rdp.ps1

      - name: Create RDP User with Secure Password
        shell: pwsh
        env:
          JUPYTER_TOKEN: ${{ secrets.JUPYTER_TOKEN }}
        run: .github/workflows/scripts/win-create-user.ps1

      - name: Verify RDP Accessibility
        shell: pwsh
        run: .github/workflows/scripts/win-verify-rdp.ps1

      - name: Install Cloudflared
        shell: pwsh
        run: .github/workflows/scripts/win-install-cloudflared.ps1

      - name: Establish Cloudflared Connection
        shell: pwsh
        env:
          CF_TUNNEL: ${{ secrets.WIN_CF_TUNNEL }}
        run: .github/workflows/scripts/win-establish-cf.ps1


      - name: Get npm cache directory
        id: npm-cache-dir
        shell: pwsh
        run: echo "dir=$(npm config get cache)" >> ${env:GITHUB_OUTPUT}

      - uses: actions/cache@v4
        id: npm-cache # use this to check for `cache-hit` ==> if: steps.npm-cache.outputs.cache-hit != 'true'
        with:
          path: ${{ steps.npm-cache-dir.outputs.dir }}
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      - name: Run electron
        shell: pwsh
        run: |

#          git clone https://github.com/cicybot/electron-headless.git
#          npm install electron -g
#          cd electron-headless
#          sh electron.sh
#          cd run
#          Xvfb :1 -screen 0 1280x1024x24 &
#          export DISPLAY=:1
#
#          cd c:\
#          git clone https://github.com/cicybot/electron-headless.git
#          cd electron-headless\electron
#          npm install -d
#          electron -v
#          Start-Process `
#             -FilePath "electron" `
#             -ArgumentList @(
#               "."
#             ) `
#             -WindowStyle Hidden

      - name: Restore pip cache
        id: cache-pip
        uses: actions/cache@v4
        with:
          path: ~\appdata\local\pip\cache
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-

      - name: Install Jupyter and Run Jupyter in backend
        shell: pwsh
        env:
          JUPYTER_TOKEN: ${{ secrets.JUPYTER_TOKEN }}
        run: |
          pip install jupyterlab
          jupyter --version
          # Run Jupyter Lab in background (detached)
          Start-Process `
            -FilePath "jupyter" `
            -ArgumentList @(
              "lab",
              "--IdentityProvider.token=$env:JUPYTER_TOKEN",
              "--ip=0.0.0.0",
              "--port=8888",
              "--ServerApp.allow_remote_access=True",
              "--ServerApp.trust_xheaders=True",
              "--no-browser"
            ) `
            -WindowStyle Hidden
      - name: Maintain Connection
        shell: pwsh
        run: |
          $processNames = @("3proxy","electron", "jupyter", "cloudflared")
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
          }
