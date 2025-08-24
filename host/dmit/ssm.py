import http.client
import json

HOST = "127.0.0.1"
PORT = 6666
STATS_PATH = "/server/v1/stats"
THRESHOLD_BYTES_50 = 50 * 1024 ** 3  # 实际100GB
THRESHOLD_BYTES_100 = 100 * 1024 ** 3  # 实际200GB


USER_THRESHOLDS = {
    "BrunuhVille": THRESHOLD_BYTES_200,
}

def get_stats():
    conn = http.client.HTTPConnection(HOST, PORT)
    conn.request("GET", STATS_PATH)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET /stats failed with status {response.status}")
    data = response.read()
    return json.loads(data)

def delete_user(username):
    conn = http.client.HTTPConnection(HOST, PORT)
    path = f"/users/{username}"
    conn.request("DELETE", path)
    response = conn.getresponse()
    if response.status == 200:
        print(f"[DELETED] {username} deleted successfully.")
    else:
        print(f"[ERROR] Failed to delete {username}. Status: {response.status}")

def check_and_delete_users():
    try:
        data = get_stats()
        for user in data.get("users", []):
            username = user["username"]
            total_bytes = user["downlinkBytes"] + user["uplinkBytes"]
            gb = total_bytes / (1024 ** 3)

            # 获取该用户的阈值，默认用 实际100GB
            threshold = USER_THRESHOLDS.get(username, THRESHOLD_BYTES_50)

            print(f"User: {username}, Total Bytes: {total_bytes} ({gb:.2f} GB), Threshold: {threshold / (1024 ** 3)} GB")

            if total_bytes > threshold:
                delete_user(username)
    except Exception as e:
        print(f"[EXCEPTION] {e}")

if __name__ == "__main__":
    check_and_delete_users()
