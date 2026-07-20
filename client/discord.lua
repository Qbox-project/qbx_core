local discord = require 'config.client'.discord

if not discord.enabled then return end

local template = discord.richPresence
local maxPlayers = GlobalState.MaxPlayers
local updateInterval = math.max(discord.updateInterval or 15000, 5000)

local usesCharName = template:find('{charName}', 1, true) ~= nil
local usesPlayerId = template:find('{id}', 1, true) ~= nil
local usesPlayerName = template:find('{playerName}', 1, true) ~= nil
local usesPlayers = template:find('{currentPlayers}', 1, true) ~= nil
local usesStreet = template:find('{streetName}', 1, true) ~= nil

---@return string
local function getStreetName()
    local coords = GetEntityCoords(cache.ped)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
end

---@return string
local function getCharName()
    local PlayerData = QBX.PlayerData
    if PlayerData and PlayerData.charinfo then
        return PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname
    end
    return 'Unknown'
end

---@return string
local function render()
    return (template:gsub('{(%w+)}', {
        id = usesPlayerId and tostring(GetPlayerServerId(PlayerId())) or nil,
        charName = usesCharName and getCharName() or nil,
        playerName = usesPlayerName and GetPlayerName(PlayerId()) or nil,
        currentPlayers = usesPlayers and (GlobalState.PlayerCount or 0) or nil,
        maxPlayers = maxPlayers,
        streetName = usesStreet and getStreetName() or nil,
    }))
end

SetDiscordAppId(discord.appId)
SetDiscordRichPresenceAsset(discord.largeIcon.icon)
SetDiscordRichPresenceAssetText(discord.largeIcon.text)
SetDiscordRichPresenceAssetSmall(discord.smallIcon.icon)
SetDiscordRichPresenceAssetSmallText(discord.smallIcon.text)
SetDiscordRichPresenceAction(0, discord.firstButton.text, discord.firstButton.link)
SetDiscordRichPresenceAction(1, discord.secondButton.text, discord.secondButton.link)

local last = render()
SetRichPresence(last)

if usesPlayers or usesStreet or usesCharName or usesPlayerId then
    CreateThread(function()
        while true do
            Wait(updateInterval)
            local updated = render()
            if updated ~= last then
                last = updated
                SetRichPresence(updated)
            end
        end
    end)
end
