local config = require 'config.server'

---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return config.characters.playersNumberOfCharacters[license2] or license and config.characters.playersNumberOfCharacters[license] or config.characters.defaultNumberOfCharacters
end

---@param source Source
local function giveStarterItems(source)
    while not exports.ox_inventory:GetInventory(source) do
        Wait(100)
    end

    for i = 1, #config.starterItems do
        local item = config.starterItems[i]
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

lib.callback.register('qbx_core:server:loadCharacter', function(source, citizenId)
    local player = LoginV2(source, citizenId)
    if not player then return end

    SetPlayerRoutingBucket(source, 0)
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Loaded', 'green', '**'.. GetPlayerName(source) .. '** ('..(GetPlayerIdentifierByType(source, 'discord') or 'undefined') ..' |  ||'  ..(GetPlayerIdentifierByType(source, 'ip') or 'undefined') ..  '|| | ' ..(GetPlayerIdentifierByType(source, 'license2') or GetPlayerIdentifierByType(source, 'license') or 'undefined') ..' | ' ..citizenId..' | '..source..') loaded..')
    lib.print.info(GetPlayerName(source)..' (Citizen ID: '..citizenId..') has succesfully loaded!')
end)

---@param data unknown
---@return table? newData
lib.callback.register('qbx_core:server:createCharacter', function(source, data)
    local newData = {}
    newData.charinfo = data

    local player = LoginV2(source, nil, newData)
    if not player then return end

    giveStarterItems(source)
    if GetResourceState('qbx_spawn') == 'missing' then
        SetPlayerRoutingBucket(source, 0)
    end

    lib.print.info(GetPlayerName(source)..' has created a character')
    return newData
end)

RegisterNetEvent('qbx_core:server:deleteCharacter', function(citizenId)
    local src = source
    DeleteCharacter(src, citizenId)
    Notify(src, Lang:t('success.character_deleted'), 'success')
end)
