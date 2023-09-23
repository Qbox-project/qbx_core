local hasDonePreloading = {}

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

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Wait(1000) -- 1 second should be enough to do the preloading in other resources
    hasDonePreloading[Player.PlayerData.source] = true
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    hasDonePreloading[src] = false
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

RegisterNetEvent('qbx-core:server:loadCharacter', function(citizenId)
    local src = source
    if not QBCore.Player.Login(src, citizenId) then return end

    repeat
        Wait(0)
    until hasDonePreloading[src]

    if GetResourceState('qbx-apartments'):find('start') then
        TriggerClientEvent('apartments:client:setupSpawnUI', src, { citizenid = citizenId })
    else
        TriggerClientEvent('qb-spawn:client:setupSpawns', src, { citizenid = citizenId })
        TriggerClientEvent('qb-spawn:client:openUI', src, true)
    end
    SetPlayerRoutingBucket(src, 0)
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**'.. GetPlayerName(src) .. '** ('..(GetPlayerIdentifierByType(src, 'discord') or 'undefined') ..' |  ||'  ..(GetPlayerIdentifierByType(src, 'ip') or 'undefined') ..  '|| | ' ..(GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license') or 'undefined') ..' | ' ..citizenId..' | '..src..') loaded..')
    lib.print.info(GetPlayerName(src)..' (Citizen ID: '..citizenId..') has succesfully loaded!')
end)

RegisterNetEvent('qbx-core:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.charinfo = data

    if not QBCore.Player.Login(src, nil, newData) then return end

    repeat
        Wait(0)
    until hasDonePreloading[src]

    giveStarterItems(src)
    if GetResourceState('qbx-spawn') ~= 'missing' then
        if QBCore.Config.Characters.StartingApartment then
            lib.print.info(GetPlayerName(src)..' has succesfully loaded!')
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        else
            lib.print.info(GetPlayerName(src)..' has succesfully loaded!')
            TriggerClientEvent('qbx-core:client:spawnNoApartments', src)
        end
    else
        SetPlayerRoutingBucket(src, 0)
        lib.callback.await('qbx-core:client:spawnDefault', src)
        TriggerClientEvent('qb-clothes:client:CreateFirstCharacter', src)
        lib.print.info(GetPlayerName(src)..' has succesfully loaded!')
    end
end)

RegisterNetEvent('qbx-core:server:deleteCharacter', function(citizenId)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenId)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.character_deleted'), 'success')
end)
