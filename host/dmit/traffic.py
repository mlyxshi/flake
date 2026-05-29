import subprocess

from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

TOKEN = open("/secret/bot").read().strip()

def reply_text():
  return subprocess.run(
    ["traffic", "8888"], capture_output=True, text=True, check=True).stdout

async def traffic(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
  await update.message.reply_text(reply_text())

def main():
  app = Application.builder().token(TOKEN).build()
  app.add_handler(CommandHandler("traffic", traffic))
  app.run_polling()

if __name__ == "__main__":
  main()