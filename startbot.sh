#!/bin/bash
# Activate virtual environment and run main bot
if [ -f ~/botenv/bin/activate ]; then
    source ~/botenv/bin/activate
fi
python bot.py
