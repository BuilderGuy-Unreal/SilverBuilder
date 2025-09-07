import os
import discord
from discord.ext import commands
from discord import app_commands

TOKEN = os.environ.get("DISCORD_TOKEN")
GUILD_ID = 878909720801443910

intents = discord.Intents.default()
intents.guilds = True
intents.members = True
intents.messages = True
intents.message_content = True

bot = commands.Bot(command_prefix="!", intents=intents)
tree = bot.tree

@bot.event
async def on_ready():
    print(f"✅ Bot online as {bot.user}")
    # Sync slash commands to test server
    guild = discord.Object(id=GUILD_ID)
    await tree.sync(guild=guild)
    print(f"✅ Slash commands synced to guild {GUILD_ID}")

# Auto-load cogs
import os
for filename in os.listdir("./cogs"):
    if filename.endswith(".py"):
        try:
            bot.load_extension(f"cogs.{filename[:-3]}")
            print(f"[+] Loaded cog: {filename}")
        except Exception as e:
            print(f"[!] Failed to load {filename}: {e}")

bot.run(TOKEN)
