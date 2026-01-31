Write-Host "ENV DATA: $env:DATA"
python scripts/windows/parse-base64-json.py $env:DATA
