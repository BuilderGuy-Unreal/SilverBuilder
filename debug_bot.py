import os
import discord
from discord.ext import commands
import asyncio

print("🛈 Ultimate Discord Bot Debug Script")

# -------------------------
# 1️⃣ Check token
# -------------------------
TOKEN = os.environ.get("DISCORD_TOKEN")
if not TOKEN:
    print("[!] DISCORD_TOKEN not set. Please run:")
    print("    export DISCORD_TOKEN='YOUR_BOT_TOKEN'")
    exit(1)
else:
    print("[+] Token is set.")

# -------------------------
# 2️⃣ Setup intents
# -------------------------
intents = discord.Intents.default()
intents.guilds = True
intents.members = True
intents.messages = True
intents.message_content = True

bot = commands.Bot(command_prefix="!", intents=intents)

# -------------------------
# 3️⃣ Events for debug
# -------------------------
@bot.event
async def on_ready():
    print(f"✅ Bot connected as: {bot.user}")
    
    # Print intents
    print("\n🛈 Enabled Intents:")
    for name, value in intents.__dict__.items():
        if not name.startswith("_"):
            print(f"   {name}: {value}")

    # Print accessible guilds
    if bot.guilds:
        print("\n🛈 Accessible Guilds:")
        for guild in bot.guilds:
            print(f"   - {guild.name} (ID: {guild.id})")
            print(f"     Members: {guild.member_count}")
    else:
        print("\n[!] Bot is not in any guilds. Make sure it is invited with proper permissions.")

    # Print success message
    print("\n[✅] Debug complete. If the bot shows online and guilds, connection is successful.")

    # Close bot after debug
    await bot.close()

# -------------------------
# 4️⃣ Run bot with error handling
# -------------------------
try:
    bot.run(TOKEN)
except discord.LoginFailure:
    print("[!] Login failed. Invalid token or malformed environment variable.")
except discord.Forbidden:
    print("[!] Forbidden: Bot lacks permissions or intents.")
except discord.HTTPException as e:
    print(f"[!] HTTP Exception: {e}")
except Exception as e:
    print(f"[!] Unexpected error: {e}")
