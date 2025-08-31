import http.client
import json
from collections import defaultdict

HOST = "127.0.0.1"
PORT = 6666
ENDPOINT = [
    "/server/v1",
    "/mux/server/v1",
    "/warp/server/v1",
]

THRESHOLD_BYTES_50 = 50 * 1024 ** 3
THRESHOLD_BYTES_100 = 100 * 1024 ** 3
THRESHOLD_UNLIMITED = 420 * 1024 ** 3

USER_THRESHOLDS = {
    "BrunuhVille": THRESHOLD_BYTES_100,
    "mlyxshi": THRESHOLD_UNLIMITED,
}

def get_stats(endpoint):
    stats_path = endpoint + "/stats"
    conn = http.client.HTTPConnection(HOST, PORT)
    conn.request("GET", stats_path)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET {stats_path} failed with status {response.status}")
    data = response.read()
    return json.loads(data)

def delete_user(username, endpoint):
    delete_path = endpoint + f"/users/{username}"
    conn = http.client.HTTPConnection(HOST, PORT)
    conn.request("DELETE", delete_path)
    response = conn.getresponse()

    if response.status == 200:
        print(f"[DELETED] {username} from {delete_path} successfully")
    elif response.status == 404:
        print(f"[NOT FOUND] {username} not found at {delete_path}")
    else:
        print(f"[ERROR] Failed to delete {username} from {delete_path}. Status: {response.status}")

def check_and_delete_users():
    aggregated = defaultdict(lambda: {"downlinkBytes": 0, "uplinkBytes": 0, "endpoints": set()})
    
    # 聚合每个用户的流量，同时记录出现的 endpoint
    for endpoint in ENDPOINT:
        try:
            data = get_stats(endpoint)
            for user in data.get("users", []):
                username = user["username"]
                aggregated[username]["downlinkBytes"] += user.get("downlinkBytes", 0)
                aggregated[username]["uplinkBytes"] += user.get("uplinkBytes", 0)
                aggregated[username]["endpoints"].add(endpoint)
        except Exception as e:
            print(f"[EXCEPTION] Failed to fetch stats from {endpoint}: {e}")
    
    # 检查合并后的用户流量并执行删除
    for username, stats in aggregated.items():
        total_bytes = stats["downlinkBytes"] + stats["uplinkBytes"]
        gb = total_bytes / (1024 ** 3)
        threshold = USER_THRESHOLDS.get(username, THRESHOLD_BYTES_50)

        print(f"User: {username}, Total Bytes: {total_bytes} ({gb:.2f} GB), Threshold: {int(threshold / (1024 ** 3))} GB")

        if total_bytes > threshold:
            for endpoint in stats["endpoints"]:
                delete_user(username, endpoint)

if __name__ == "__main__":
    check_and_delete_users()
