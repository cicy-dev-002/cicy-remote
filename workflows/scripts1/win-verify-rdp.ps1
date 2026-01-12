# Verify RDP port 3389

$testResult = Test-NetConnection -ComputerName 127.0.0.1 -Port 3389
if (-not $testResult.TcpTestSucceeded) { throw "TCP connection to 3389 failed" }
Write-Host "TCP connectivity successful!"
