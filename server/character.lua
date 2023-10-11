---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return Config.Characters.PlayersNumberOfCharacters[license2] or license and Config.Characters.PlayersNumberOfCharacters[license] or Config.Characters.DefaultNumberOfCharacters
end

---@param source Source
local function giveStarterItems(source)
    local getInv = function(...) return exports.ox_inventory:GetInventory(...) ~= false end
    local i = 0
    local invCreated = getInv(source)
    while not invCreated and i < 100 do
        i += 1
        Wait(100)
        invCreated = getInv(source)
    end

    if not invCreated then return error('starting items could not be given because no inventory could be found') end

    for i = 1, #Config.StarterItems do
        local item = Config.StarterItems[i]
        if item.metadata and type(item.metadata) == 'function' then
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata(source))
        else
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata)
        end
    end
end

lib.callback.register('qbx_core:server:getCharacters', function(source)
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

lib.callback.register('qbx_core:server:getPreviewPedData', function(_, citizenId)
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

---@param citizenId string
RegisterNetEvent('qbx_core:server:loadCharacter', function(citizenId)
    local src = source
    local player = LoginV2(src, citizenId)
    if not player then return end

    TriggerEvent('qbx_core:server:playerLoaded', src)
    TriggerClientEvent('qbx_core:client:playerLoaded', src, player.PlayerData)

    if Config.Spawn.EnableSelector then
        local houses, apartment
        if GetResourceState('qbx_houses'):find('start') and Config.Spawn.AllowSpawningInsideOwnedHouses then
            houses = FetchPlayerHouses(citizenId)
        end
        if GetResourceState('qbx_apartments'):find('start') and Config.Spawn.AllowSpawningInsideOwnedApartment then
            apartment = FetchPlayerApartment(citizenId)
        end
        local spawnData = lib.callback.await('qbx_core:client:getSpawnLocation', src, {isNew = false, houses = houses, apartment = apartment})
        if spawnData?.coords then
            player.Functions.SetCoords(spawnData.coords)
            player.PlayerData.position = spawnData.coords
        end
        TriggerClientEvent('qbx_core:client:spawn', src, spawnData)
    else
        TriggerClientEvent('qbx_core:client:spawn', src)
    end

    SetPlayerRoutingBucket(src, 0)
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**'.. GetPlayerName(src) .. '** ('..(GetPlayerIdentifierByType(src, 'discord') or 'undefined') ..' |  ||'  ..(GetPlayerIdentifierByType(src, 'ip') or 'undefined') ..  '|| | ' ..(GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license') or 'undefined') ..' | ' ..citizenId..' | '..src..') loaded..')
    lib.print.info(GetPlayerName(src)..' (Citizen ID: '..citizenId..') has succesfully loaded!')
end)

---@param data unknown
RegisterNetEvent('qbx_core:server:createCharacter', function(data)
    local src = source
    local player = LoginV2(src, nil, {charinfo = data})
    if not player then return end

    TriggerEvent('qbx_core:server:playerLoaded', src)
    TriggerClientEvent('qbx_core:client:playerLoaded', src, player.PlayerData)

    if Config.Spawn.EnableSelector then
        local spawnData = lib.callback.await('qbx_core:client:getSpawnLocation', src, {isNew = true})
        TriggerClientEvent('qbx_core:client:spawn', src, spawnData)
    else
        TriggerClientEvent('qbx_core:client:spawn', src, {isNew = true})
    end

    giveStarterItems(src)
    SetPlayerRoutingBucket(src, 0)

    lib.print.info(GetPlayerName(src)..' has created a character')
end)

RegisterNetEvent('qbx_core:server:deleteCharacter', function(citizenId)
    local src = source
    DeleteCharacter(src, citizenId)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.character_deleted'), 'success')
end)
