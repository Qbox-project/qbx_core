local MaxPlayers = GlobalState.MaxPlayers
local Discord = require 'config.client'.Discord

AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
    if bagName == 'global' and value then
        local players = 'Players %s/' .. MaxPlayers
        SetRichPresence((players):format(value))
    end
end)

SetDiscordAppId(Discord.AppId)
SetDiscordRichPresenceAsset(Discord.LargeIcon.icon)
SetDiscordRichPresenceAssetText(Discord.LargeIcon.text)
SetDiscordRichPresenceAssetSmall(Discord.SmallIcon.icon)
SetDiscordRichPresenceAssetSmallText(Discord.SmallIcon.text)
SetDiscordRichPresenceAction(0, Discord.FirstButton.text, Discord.FirstButton.link)
SetDiscordRichPresenceAction(1, Discord.SecondButton.text, Discord.SecondButton.link)
