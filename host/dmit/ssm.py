import http.client
import json

HOST = "127.0.0.1"
PORTS = [6665, 6666]  # check both ports
STATS_PATH = "/server/v1/stats"

THRESHOLD_BYTES_50 = 50 * 1024 ** 3   # 实际100GB
THRESHOLD_BYTES_100 = 100 * 1024 ** 3 # 实际200GB
THRESHOLD_UNLIMITED = 420 * 1024 ** 3 # 实际840GB/所有流量

USER_THRESHOLDS = {
    "BrunuhVille": THRESHOLD_BYTES_100,
    "mlyxshi": THRESHOLD_UNLIMITED,
}

def get_stats(port):
    conn = http.client.HTTPConnection(HOST, port)
    conn.request("GET", STATS_PATH)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET {STATS_PATH} failed with status {response.status} on port {port}")
    data = response.read()
    return json.loads(data)

def delete_user(username, port):
    conn = http.client.HTTPConnection(HOST, port)
    path = f"/users/{username}"
    conn.request("DELETE", path)
    response = conn.getresponse()
    if response.status == 200:
        print(f"[DELETED] {username} deleted successfully on port {port}.")
    else:
        print(f"[ERROR] Failed to delete {username} on port {port}. Status: {response.status}")

def check_and_delete_users():
    for port in PORTS:
        try:
            data = get_stats(port)
            for user in data.get("users", []):
                username = user["username"]
                total_bytes = user["downlinkBytes"] + user["uplinkBytes"]
                gb = total_bytes / (1024 ** 3)

                # 获取该用户的阈值，默认用 实际100GB
                threshold = USER_THRESHOLDS.get(username, THRESHOLD_BYTES_50)

                print(f"[PORT {port}] User: {username}, Total Bytes: {total_bytes}, Threshold: {gb:.2f} GB / {int(threshold / (1024 ** 3))} GB")

                if total_bytes > threshold:
                    delete_user(username, port)
        except Exception as e:
            print(f"[EXCEPTION][PORT {port}] {e}")

if __name__ == "__main__":
    check_and_delete_users()
