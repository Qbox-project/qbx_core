---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return QBCore.Config.Characters.PlayersNumberOfCharacters[license2] or license and QBCore.Config.Characters.PlayersNumberOfCharacters[license] or QBCore.Config.Characters.DefaultNumberOfCharacters
end

---@param source Source
local function giveStarterItems(source)
    for i = 1, #Config.StarterItems do
        local item = Config.StarterItems[i]
        if item.metadata and type(item.metadata) == 'function' then
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata(source))
        else
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata)
        end
    end
end

lib.callback.register('qbx-core:server:getCharacters', function(source)
    local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
    local chars = FetchAllPlayerEntities(license2, license)
    local allowedAmount = getAllowedAmountOfCharacters(license2, license)
    local sortedChars = {}
    for i = 1, #chars do
        local char = chars[i]
        sortedChars[char.charinfo.cid] = char
    end
    return sortedChars, allowedAmount
end)

lib.callback.register('qbx-core:server:getPreviewPedData', function(_, citizenId)
    local ped = FetchPlayerSkin(citizenId)
    if not ped then return end

    return ped.skin, ped.model and joaat(ped.model)
end)

AddEventHandler('playerJoining', function()
    SetPlayerRoutingBucket(source, source)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Wait(100)
    local players = GetPlayers()
    for i = 1, #players do
        local playerId = players[i]
        local playerIdNum = tonumber(playerId)
        if playerIdNum then
            SetPlayerRoutingBucket(playerId, playerIdNum)
        end
    end
end)

lib.callback.register('qbx-core:server:loadCharacter', function(citizenId)
    local src = source
    local player = QBCore.Player.LoginV2(src, citizenId)
    if not player then return end

    SetPlayerRoutingBucket(src, 0)
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**'.. GetPlayerName(src) .. '** ('..(GetPlayerIdentifierByType(src, 'discord') or 'undefined') ..' |  ||'  ..(GetPlayerIdentifierByType(src, 'ip') or 'undefined') ..  '|| | ' ..(GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license') or 'undefined') ..' | ' ..citizenId..' | '..src..') loaded..')
    lib.print.info(GetPlayerName(src)..' (Citizen ID: '..citizenId..') has succesfully loaded!')
end)

---@param data unknown
---@return table? newData
lib.callback.register('qbx-core:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.charinfo = data

    local player = QBCore.Player.LoginV2(src, nil, newData)
    if not player then return end

    giveStarterItems(src)
    if GetResourceState('qbx-spawn') == 'missing' then
        SetPlayerRoutingBucket(src, 0)
    end

    lib.print.info(GetPlayerName(src)..' has created a character')
    return newData
end)

RegisterNetEvent('qbx-core:server:deleteCharacter', function(citizenId)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenId)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.character_deleted'), 'success')
end)
