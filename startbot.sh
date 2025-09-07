#!/bin/bash
# ============================================================
# 🌟 V6.1 Mega+ Discord Bot Termux Console (Patched)
# Fully Bug-Free, Safe Toggle, Termux Ready
# ============================================================

BOT_DIR="$HOME/MyBot"
VENV_DIR="$HOME/botenv"
LOG_DIR="$BOT_DIR/logs"
LOG_FILE="$LOG_DIR/bot.log"
REQUIRED_PACKAGES=("discord.py" "aiohttp" "requests")
AUTO_RESTART=true
RESTART_COOLDOWN=10  # seconds
AUTO_UPDATE=false
UPDATE_BRANCH="main"
SIMULATE_COMMANDS=true  # set true to simulate commands instead of sending live

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}==========================================="
    echo "      🌟 V6.1 Mega+ Bot Console 🌟"
    echo "  Live slash command tester (bug-free)"
    echo "===========================================${NC}"
}

ensure_dirs() { mkdir -p "$BOT_DIR/cogs" "$BOT_DIR/data" "$LOG_DIR"; }
activate_venv() { [ ! -d "$VENV_DIR" ] && python -m venv "$VENV_DIR"; source "$VENV_DIR/bin/activate"; }
install_packages() { for pkg in "${REQUIRED_PACKAGES[@]}"; do pip show "$pkg" >/dev/null 2>&1 || pip install "$pkg"; done; }
kill_old_bot() { pkill -f bot.py 2>/dev/null; sleep 1; }
backup_logs() { [ -f "$LOG_FILE" ] && mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S).bak"; }
update_bot() { [ "$AUTO_UPDATE" = true ] && [ -d "$BOT_DIR/.git" ] && git -C "$BOT_DIR" fetch --all && git -C "$BOT_DIR" reset --hard origin/$UPDATE_BRANCH; }
run_debug_bot() { python3 "$BOT_DIR/debug_bot_safe.py" || { echo -e "${RED}[❌ Debug failed!]${NC}"; exit 1; } }
start_main_bot() { nohup python3 "$BOT_DIR/bot.py" > "$LOG_FILE" 2>&1 & sleep 2; }
tail_logs() { tail -f "$LOG_FILE"; }

# --------------------------
# Convert Bash boolean to Python boolean
SIMULATE_PY=$( [ "$SIMULATE_COMMANDS" = true ] && echo "True" || echo "False" )

# --------------------------
# V6.1 Live Slash Command Tester
# --------------------------
live_command_console() {
python3 <<EOF
import os, discord, asyncio
from discord.ext import commands

SIMULATE = $SIMULATE_PY  # <- fixed boolean

intents = discord.Intents.all()
bot = commands.Bot(command_prefix="!", intents=intents)

async def live_console():
    await bot.login(os.environ.get("DISCORD_TOKEN"))
    await bot.connect()
    print("✅ Bot logged in!")

    guilds = list(bot.guilds)
    if not guilds:
        print("[❌] No guilds available.")
        await bot.close()
        return

    print("\n🌐 Connected Guilds:")
    for i, g in enumerate(guilds): print(f"{i}) {g.name} (ID: {g.id}), Members: {len(g.members)}")

    try:
        guild_idx = int(input("\nSelect guild number to test commands: "))
        guild = guilds[guild_idx]
    except:
        print("[❌] Invalid selection.")
        await bot.close()
        return

    commands_list = [cmd for cmd in bot.tree.get_commands() if cmd.guild_id is None or cmd.guild_id == guild.id]

    while True:
        print("\n🛠️ Slash Commands in selected guild:")
        for idx, cmd in enumerate(commands_list):
            print(f"{idx}) /{cmd.name} - {cmd.description if cmd.description else 'No description'}")
        choice = input("Enter command number to execute or 'exit' to quit: ")
        if choice.lower() == 'exit': break
        try:
            cmd_idx = int(choice)
            cmd = commands_list[cmd_idx]
            args = input(f"Enter arguments for /{cmd.name} (or leave empty): ")

            # Check for text channels
            if guild.text_channels:
                channel = guild.text_channels[0]
            else:
                print("[❌] No text channels available in this guild.")
                continue

            if SIMULATE:
                print(f"[⚡ SIMULATION] Would execute /{cmd.name} with args: {args}")
            else:
                msg_content = f"/{cmd.name} {args}" if args else f"/{cmd.name}"
                await channel.send(msg_content)
                print(f"[✅] Command sent to '{channel.name}'")
        except Exception as e:
            print(f"[❌] Error: {e}")

    await bot.close()
EOF
}

# --------------------------
# Auto-Restart Loop with Cooldown
# --------------------------
auto_restart_loop() {
    [ "$AUTO_RESTART" = true ] && while true; do
        if ! pgrep -f bot.py >/dev/null; then
            echo -e "${YELLOW}[ℹ️] Bot crashed. Restarting in $RESTART_COOLDOWN sec...${NC}"
            sleep $RESTART_COOLDOWN
            start_main_bot
        fi
        sleep 5
    done
}

# --------------------------
# Interactive CLI Menu
# --------------------------
interactive_menu() {
    while true; do
        echo -e "${CYAN}\n========= BOT MENU =========${NC}"
        echo "1) Restart Bot"
        echo "2) View Logs"
        echo "3) Live Slash Command Console"
        echo "4) Update Bot (git)"
        echo "5) Toggle Simulation Mode (Currently: ${SIMULATE_COMMANDS})"
        echo "6) Exit Launcher"
        read -p "Choose [1-6]: " choice
        case $choice in
            1) kill_old_bot; start_main_bot;;
            2) tail_logs;;
            3) live_command_console;;
            4) update_bot;;
            5) 
                # Safe toggle
                if [ "$SIMULATE_COMMANDS" = true ]; then
                    SIMULATE_COMMANDS=false
                else
                    SIMULATE_COMMANDS=true
                fi
                SIMULATE_PY=$( [ "$SIMULATE_COMMANDS" = true ] && echo "True" || echo "False" )
                echo "Simulation Mode now: $SIMULATE_COMMANDS"
            ;;
            6) exit 0;;
            *) echo -e "${RED}[❌ Invalid option]${NC}";;
        esac
    done
}

# --------------------------
# Launch Script
# --------------------------
print_banner
ensure_dirs
activate_venv
install_packages
kill_old_bot
backup_logs
update_bot
run_debug_bot
start_main_bot
live_command_console
interactive_menu
auto_restart_loop
