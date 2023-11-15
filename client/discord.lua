local maxPlayers = GlobalState.MaxPlayers
local discord = require 'config.client'.Discord

AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
    if bagName == 'global' and value then
        local players = 'Players %s/' .. maxPlayers
        SetRichPresence((players):format(value))
    end
end)

SetDiscordAppId(discord.AppId)
SetDiscordRichPresenceAsset(discord.LargeIcon.icon)
SetDiscordRichPresenceAssetText(discord.LargeIcon.text)
SetDiscordRichPresenceAssetSmall(discord.SmallIcon.icon)
SetDiscordRichPresenceAssetSmallText(discord.SmallIcon.text)
SetDiscordRichPresenceAction(0, discord.FirstButton.text, discord.FirstButton.link)
SetDiscordRichPresenceAction(1, discord.SecondButton.text, discord.SecondButton.link)
