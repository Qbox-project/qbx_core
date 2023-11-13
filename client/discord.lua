AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
     if bagName ~= 'global' or not value then return end
     local players = 'Players %s/' .. Config.MaxPlayers
     SetRichPresence((players):format(value))
end)

SetDiscordAppId(Config.Discord.AppId)
SetDiscordRichPresenceAsset(Config.Discord.LargeIcon.icon)
SetDiscordRichPresenceAssetText(Config.Discord.LargeIcon.text)
SetDiscordRichPresenceAssetSmall(Config.Discord.SmallIcon.icon)
SetDiscordRichPresenceAssetSmallText(Config.Discord.SmallIcon.text)
SetDiscordRichPresenceAction(0, Config.Discord.FirstButton.text, Config.Discord.FirstButton.link)
SetDiscordRichPresenceAction(1, Config.Discord.SecondButton.text, Config.Discord.SecondButton.link)
