local playersConnected = GlobalState.PlayerCount

AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
     if bagName ~= 'global' or not value then return end
     playersConnected = value
end)

CreateThread(function()
    while true do
        SetDiscordAppId(Config.Discord.AppId)
        SetDiscordRichPresenceAsset(Config.Discord.LargeIcon.icon)
        SetDiscordRichPresenceAssetText(Config.Discord.LargeIcon.text)
        SetDiscordRichPresenceAssetSmall(Config.Discord.SmallIcon.icon)
        SetDiscordRichPresenceAssetSmallText(Config.Discord.SmallIcon.text)
        SetRichPresence(('Players %s/'..Config.MaxPlayers):format(playersConnected))
        SetDiscordRichPresenceAction(0, Config.Discord.FirstButton.text, Config.Discord.FirstButton.link)
        SetDiscordRichPresenceAction(1, Config.Discord.SecondButton.text, Config.Discord.SecondButton.link)
        Wait(60000)
    end
end)