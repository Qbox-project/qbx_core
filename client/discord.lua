local maxPlayers = GlobalState.MaxPlayers
local discord = require 'config.client'.discord

AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
    if bagName == 'global' and value then
        local players = 'Players %s/' .. maxPlayers
        SetRichPresence((players):format(value))
    end
end)

SetDiscordAppId(discord.appId)
SetDiscordRichPresenceAsset(discord.largeIcon.icon)
SetDiscordRichPresenceAssetText(discord.largeIcon.text)
SetDiscordRichPresenceAssetSmall(discord.smallIcon.icon)
SetDiscordRichPresenceAssetSmallText(discord.smallIcon.text)
SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)
