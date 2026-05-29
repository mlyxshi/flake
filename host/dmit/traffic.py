import json, subprocess

from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

TOKEN = open("/secret/bot").read().strip()

def human(n):
    n = float(n)
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if n < 1024 or unit == "TiB":
            return ("%d B" % n) if unit == "B" else ("%.2f %s" % (n, unit))
        n /= 1024

def counters():
    out = subprocess.run(
        ["nft", "-j", "list", "counters", "table", "inet", "TRAFFIC"],
        capture_output=True, text=True, check=True).stdout
    res = {}
    for item in json.loads(out)["nftables"]:
        c = item.get("counter")
        if c and "name" in c:
            res[c["name"]] = c.get("bytes", 0)
    return res

def reply_text():
    c = counters()
    tu = c.get("tcp8888_out", 0); td = c.get("tcp8888_in", 0)
    uu = c.get("udp8888_out", 0); ud = c.get("udp8888_in", 0)
    total = tu + td + uu + ud
    return ("tcp up:   %s\n"
            "tcp down: %s\n"
            "udp up:   %s\n"
            "udp down: %s\n"
            "total:    %s") % (human(tu), human(td), human(uu),
                                human(ud), human(total))

async def traffic(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(reply_text())

def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("traffic", traffic))
    app.run_polling()

if __name__ == "__main__":
    main()