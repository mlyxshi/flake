import json
import http.client
import subprocess
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes


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
app.add_handler(CommandHandler("all", real_traffic))
app.run_polling()
