$result = python scripts/windows/parse-base64-json.py $env:DATA
$json = $result | ConvertFrom-Json
$env:CF_TUNNEL = $json.CF_TUNNEL
$env:JUPYTER_TOKEN = $json.JUPYTER_TOKEN
$env:GH_CICYBOT_TOKEN = $json.GH_CICYBOT_TOKEN
$env:TEST = $json.TEST

echo $env:TEST
