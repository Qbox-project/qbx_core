local maxPlayers = GlobalState.MaxPlayers
local discord = require 'config.client'.discord

if not discord.enabled then return end

AddStateBagChangeHandler('PlayerCount', '', function(bagName, _, value)
    if bagName == 'global' and value then
        SetRichPresence(('Players %s/%s'):format(value, maxPlayers))
    end
end)

SetDiscordAppId(discord.appId)
SetDiscordRichPresenceAsset(discord.largeIcon.icon)
SetDiscordRichPresenceAssetText(discord.largeIcon.text)
SetDiscordRichPresenceAssetSmall(discord.smallIcon.icon)
SetDiscordRichPresenceAssetSmallText(discord.smallIcon.text)
SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)
