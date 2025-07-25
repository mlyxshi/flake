import json
import http.client
import subprocess
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes

HOST = "127.0.0.1"
PORT = 6666
STATS_PATH = "/server/v1/stats"

with open("/secret/ssm-bot") as f:
    BOT_TOKEN = f.read().strip()

def get_stats():
    conn = http.client.HTTPConnection(HOST, PORT)
    conn.request("GET", STATS_PATH)
    response = conn.getresponse()
    if response.status != 200:
        raise Exception(f"GET {STATS_PATH} failed with status {response.status}")
    data = response.read()
    return json.loads(data)

async def run_script(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        data = get_stats()
        users = data.get("users", [])
        if not users:
            await update.message.reply_text("No user stats found.")
            return

        # Sort users by total traffic in descending order
        users.sort(key=lambda u: u.get("downlinkBytes", 0) + u.get("uplinkBytes", 0), reverse=True)

        output_lines = []
        for user in users:
            username = user.get("username", "<unknown>")
            total_bytes = user.get("downlinkBytes", 0) + user.get("uplinkBytes", 0)
            gb = total_bytes / (1024 ** 3)
            output_lines.append(f"User: {username}, Total Bytes: {total_bytes} ({gb:.2f} GB)")

        output = "\n".join(output_lines)
        if len(output) > 4000:
            output = output[:4000] + "\n... (truncated)"

        await update.message.reply_text(f"```\n{output}\n```", parse_mode="Markdown")
    except Exception as e:
        await update.message.reply_text(f"[EXCEPTION] {e}")

app = ApplicationBuilder().token(BOT_TOKEN).build()
app.add_handler(CommandHandler("traffic", run_script))
app.run_polling()
