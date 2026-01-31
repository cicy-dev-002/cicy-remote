import base64
import json
import sys

def parse_base64_json(base64_data):
    decoded = base64.b64decode(base64_data).decode('utf-8')
    return json.loads(decoded)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        data = parse_base64_json(sys.argv[1])
        print(json.dumps(data, indent=2))
    else:
        print("Usage: python parse-base64-json.py <base64_encoded_json>")
