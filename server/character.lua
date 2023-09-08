local hasDonePreloading = {}

---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return QBCore.Config.Characters.PlayersNumberOfCharacters[license2] or license and QBCore.Config.Characters.PlayersNumberOfCharacters[license] or QBCore.Config.Characters.DefaultNumberOfCharacters
end

---@param source Source
local function giveStarterItems(source)
    local Player = QBCore.Functions.GetPlayer(source)

    for _, v in pairs(QBCore.Shared.StarterItems) do
        if v.item == 'id_card' then
            local metadata = {
                type = string.format('%s %s', Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
                description = string.format('CID: %s  \nBirth date: %s  \nSex: %s  \nNationality: %s',
                Player.PlayerData.citizenid, Player.PlayerData.charinfo.birthdate, Player.PlayerData.charinfo.gender == 0 and Lang:t('info.char_male') or Lang:t('char_female'), Player.PlayerData.charinfo.nationality)
            }
            exports.ox_inventory:AddItem(source, v.item, v.amount, metadata)
        elseif v.item == 'driver_license' then
            local metadata = {
                type = 'Class C Driver License',
                description = string.format('First name: %s  \nLast name: %s  \nBirth date: %s',
                Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.birthdate)
            }
            exports.ox_inventory:AddItem(source, v.item, v.amount, metadata)
        else
            exports.ox_inventory:AddItem(source, v.item, v.amount)
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

lib.callback.register('qbx-core:server:convertMsToDate', function(_, ms)
    return os.date('%Y-%m-%d', math.round(ms / 1000, 0))
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
    print('^2[qbx-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..citizenId..') has succesfully loaded!')
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
            print('^2[qbx-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        else
            print('^2[qbx-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            TriggerClientEvent('qbx-core:client:spawnNoApartments', src)
        end
    else
        SetPlayerRoutingBucket(src, 0)
        lib.callback.await('qbx-core:client:spawnDefault', src)
        TriggerClientEvent('qb-clothes:client:CreateFirstCharacter', src)
        print('^2[qbx-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
    end
end)

RegisterNetEvent('qbx-core:server:deleteCharacter', function(citizenId)
    local src = source
    QBCore.Player.DeleteCharacter(src, citizenId)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.character_deleted'), 'success')
end)
