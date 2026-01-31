$result = python scripts/windows/parse-base64-json.py $env:DATA
$json = $result | ConvertFrom-Json
$env:test1 = $json.test1
$env:test2 = $json.test2
echo $env:test1
echo $env:test2
