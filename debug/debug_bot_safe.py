import os
import discord
from discord.ext import commands

print("🛈 Ultimate Safe Discord Bot Debug Script")

TOKEN = os.environ.get("DISCORD_TOKEN")
if not TOKEN:
    print("[!] DISCORD_TOKEN not set. Run:")
    print("    export DISCORD_TOKEN='YOUR_BOT_TOKEN'")
    exit(1)
else:
    print("[+] Token detected.")

intents = discord.Intents.default()
intents.guilds = True

PRIVILEGED_INTENTS = {
    "members": True,
    "message_content": True
}

for name, enabled in PRIVILEGED_INTENTS.items():
    if enabled:
        print(f"[!] Warning: {name} intent is privileged. Must be enabled in Developer Portal!")

intents.members = PRIVILEGED_INTENTS["members"]
intents.message_content = PRIVILEGED_INTENTS["message_content"]

bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"\n✅ Bot connected as: {bot.user}\n")
    print("🛈 Enabled Intents:")
    for name in dir(intents):
        if not name.startswith("_"):
            value = getattr(intents, name)
            if isinstance(value, bool):
                print(f"   {name}: {value}")
    if bot.guilds:
        print("\n🛈 Accessible Guilds:")
        for guild in bot.guilds:
            print(f"   - {guild.name} (ID: {guild.id}), Members: {guild.member_count}")
    else:
        print("[!] Bot is not in any guilds. Check invite link and permissions.")
    print("\n[✅] Debug complete. Privileged intents may require portal enablement.")
    await bot.close()

try:
    bot.run(TOKEN)
except discord.LoginFailure:
    print("[!] Login failed. Invalid token.")
except discord.Forbidden:
    print("[!] Forbidden: Bot lacks permissions or intents.")
except Exception as e:
    print(f"[!] Unexpected error: {e}")
