import json
import http.client
import subprocess
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes

HOSTS = [("127.0.0.1", 6666), ("127.0.0.1", 6665)]
STATS_PATH = "/server/v1/stats"

with open("/secret/ssm-bot") as f:
    BOT_TOKEN = f.read().strip()

def get_stats(host: str, port: int):
    conn = http.client.HTTPConnection(host, port)
    conn.request("GET", STATS_PATH)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET {STATS_PATH} on {host}:{port} failed with status {response.status}")
    data = response.read()
    return json.loads(data)

async def ssm_traffic(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        all_users = {}

        # Gather stats from all hosts
        for host, port in HOSTS:
            data = get_stats(host, port)
            users = data.get("users", [])
            for user in users:
                username = user.get("username", "<unknown>")
                if username not in all_users:
                    all_users[username] = {
                        "uplinkBytes": 0,
                        "downlinkBytes": 0
                    }
                all_users[username]["uplinkBytes"] += user.get("uplinkBytes", 0)
                all_users[username]["downlinkBytes"] += user.get("downlinkBytes", 0)

        # Convert dict to list and sort
        merged_users = [
            {
                "username": username,
                "uplinkBytes": u["uplinkBytes"],
                "downlinkBytes": u["downlinkBytes"]
            }
            for username, u in all_users.items()
        ]
        merged_users.sort(key=lambda u: u["uplinkBytes"] + u["downlinkBytes"], reverse=True)

        output_lines = []
        for user in merged_users:
            username = user["username"]
            up = user["uplinkBytes"]
            down = user["downlinkBytes"]
            total = up + down
            gb = total / (1024 ** 3)
            output_lines.append(
                f"{username}:\n"
                f"  ↑ {up} Bytes\n"
                f"  ↓ {down} Bytes\n"
                f"  Σ {total} Bytes | {gb:.2f} GB\n"
            )

        output = "\n".join(output_lines)

        await update.message.reply_text(f"```\n{output}\n```", parse_mode="Markdown")
    except Exception as e:
        await update.message.reply_text(f"[EXCEPTION] {e}")

async def real_traffic(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        result = subprocess.check_output(
            "/run/current-system/sw/bin/vnstat --oneline -i eth0 | /run/current-system/sw/bin/awk -F ';' '{{print $11}}'",
            shell=True,
            text=True
        ).strip()
        await update.message.reply_text(f"Real Traffic: {result}")
    except subprocess.CalledProcessError as e:
        await update.message.reply_text(f"[ERROR] Failed to get real traffic: {e}")

app = ApplicationBuilder().token(BOT_TOKEN).build()
app.add_handler(CommandHandler("traffic", ssm_traffic))
app.add_handler(CommandHandler("all", real_traffic))
app.run_polling()
