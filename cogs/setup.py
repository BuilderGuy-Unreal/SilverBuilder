import discord
from discord.ext import commands
from discord import app_commands

class Setup(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @app_commands.command(name="setup", description="Safe test server setup")
    async def setup(self, interaction: discord.Interaction):
        await interaction.response.send_message("Creating safe test server structure...")
        await interaction.followup.send("✅ Setup complete!")

async def setup(bot):
    await bot.add_cog(Setup(bot))
