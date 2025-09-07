#!/bin/bash
# ----------------------------
# Termux One-Command Bot Launcher
# ----------------------------

# Activate Python environment
source ~/botenv/bin/activate

# Run debug bot first
echo "🛈 Running debug bot..."
python3 ~/MyBot/debug_bot_safe.py
if [ $? -ne 0 ]; then
    echo "[!] Debug failed. Fix issues before starting main bot."
    exit 1
fi

# Run main bot in background
echo "🛈 Starting main bot in background..."
nohup python3 ~/MyBot/bot.py > ~/MyBot/logs/bot.log 2>&1 &
sleep 1
echo "[✅] Main bot started!"
echo "ℹ️ Check logs anytime with: tail -f ~/MyBot/logs/bot.log"
