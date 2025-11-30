local maxPlayers = GlobalState.MaxPlayers
local discord = require 'config.client'.discord
if not discord.enabled then return end

AddStateBagChangeHandler('PlayerCount', '', function(bagName, _, value)
    if bagName == 'global' and value then
        local steamName = GetPlayerName(PlayerId()) or 'Bilinmeyen Oyuncu'
        SetRichPresence(steamName .. ' | ' .. value .. '/' .. maxPlayers)
    end
end)

SetDiscordAppId(discord.appId)
SetDiscordRichPresenceAsset(discord.largeIcon.icon)
SetDiscordRichPresenceAssetText('Los Angeles - Serious RP')

if discord.smallIcon.icon and discord.smallIcon.icon ~= '' then
    SetDiscordRichPresenceAssetSmall(discord.smallIcon.icon)
    SetDiscordRichPresenceAssetSmallText(discord.smallIcon.text)
end

SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)
