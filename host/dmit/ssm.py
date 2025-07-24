import http.client
import json

# Config
HOST = "127.0.0.1"
PORT = 7777
STATS_PATH = "/server/v1/stats"
uPSK = "R/Qsc0cRzQpdnrl6/EsGUQ=="
THRESHOLD_BYTES = 125 * 1024 ** 3  # 单向125GB，双向250GB

def get_stats():
    conn = http.client.HTTPConnection(HOST, PORT)
    conn.request("GET", STATS_PATH)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET /stats failed with status {response.status}")
    data = response.read()
    return json.loads(data)

def patch_user(username):
    conn = http.client.HTTPConnection(HOST, PORT)
    path = f"/users/{username}"
    payload = json.dumps({"uPSK": uPSK})
    headers = {
        "Content-Type": "application/json"
    }
    conn.request("PATCH", path, body=payload, headers=headers)
    response = conn.getresponse()
    if response.status == 200:
        print(f"[PATCHED] {username} updated successfully.")
    else:
        print(f"[ERROR] Failed to patch {username}. Status: {response.status}")

def check_and_patch_users():
    try:
        data = get_stats()
        for user in data.get("users", []):
            username = user["username"]
            total_bytes = user["downlinkBytes"] + user["uplinkBytes"]
            gb = total_bytes / (1024 ** 3)
            print(f"[INFO] User: {username}, Total Bytes: {total_bytes} ({gb:.2f} GB)")

            if total_bytes > THRESHOLD_BYTES:
                patch_user(username)
    except Exception as e:
        print(f"[EXCEPTION] {e}")

if __name__ == "__main__":
    check_and_patch_users()
