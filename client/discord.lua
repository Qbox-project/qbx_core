local maxPlayers = GlobalState.MaxPlayers or GetConvarInt('sv_maxclients', 64)
local discord = require 'config.client'.discord
if not discord.enabled then return end

SetDiscordAppId(discord.appId)
SetDiscordRichPresenceAsset(discord.largeIcon.icon)
SetDiscordRichPresenceAssetText(discord.largeIcon.text)
SetDiscordRichPresenceAssetSmall(discord.smallIcon.icon)
SetDiscordRichPresenceAssetSmallText(discord.smallIcon.text)
SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)

AddStateBagChangeHandler('PlayerCount', '', function(bagName, _, value)
    if bagName == 'global' and value then
        TriggerEvent('discord:updatePresence', value)
    end
end)

RegisterNetEvent('discord:updatePresence', function(currentCount)
    local playerId = GetPlayerServerId(PlayerId())
    local playerName = "Bilinmiyor"

    local PlayerData = QBX.PlayerData
    if PlayerData and PlayerData.charinfo then
        playerName = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname
    end

    local presenceText = ('[%s] %s | %s/%s'):format(playerId, playerName, currentCount or 0, maxPlayers)
    SetRichPresence(presenceText)
end)

CreateThread(function()
    Wait(5000)
    TriggerEvent('discord:updatePresence', GlobalState.PlayerCount or 0)
end)
