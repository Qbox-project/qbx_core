-- Vehicles
RegisterServerEvent('baseevents:enteringVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Entering'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteredVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Entered'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteringAborted', function()
    local src = source
    TriggerClientEvent('QBCore:Client:AbortVehicleEntering', src)
end)

RegisterServerEvent('baseevents:leftVehicle', function(veh, seat, modelName, netId)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        netId = netId,
        event = 'Left'
    }
    TriggerClientEvent('QBCore:Client:VehicleInfo', src, data)
end)

local saveCooldownMs <const> = 10000
---@type table<Source, integer>
local nextSaveAllowed = {}
---@type table<Source, table<string, true>>
local warnedItemEvents = {}

---@deprecated qbx_core saves players and drains hunger/thirst on its own interval
RegisterNetEvent('QBCore:UpdatePlayer', function()
    local src = source --[[@as Source]]
    local player = GetPlayer(src)
    if not player then return end

    local now = GetGameTimer()
    if (nextSaveAllowed[src] or 0) > now then return end
    nextSaveAllowed[src] = now + saveCooldownMs

    local metadata = player.PlayerData.metadata
    TriggerClientEvent('hud:client:UpdateNeeds', src, metadata.hunger, metadata.thirst)
    Save(src)
end)

AddEventHandler('playerDropped', function()
    nextSaveAllowed[source] = nil
    warnedItemEvents[source] = nil
end)

---@param eventName string
---@param src Source
---@param itemName any
---@param amount any
local function warnDeprecatedItemEvent(eventName, src, itemName, amount)
    local warned = warnedItemEvents[src] or {}
    if warned[eventName] then return end
    warned[eventName] = true
    warnedItemEvents[src] = warned

    lib.print.warn(('Player %s triggered deprecated, exploitable net event %s (item: %s, amount: %s). It is ignored: give, remove and use items on the server through ox_inventory.'):format(
        src, eventName, tostring(type(itemName) == 'table' and rawget(itemName, 'name') or itemName):sub(1, 64), tonumber(amount) or 'nil'))
end

---@deprecated exploitable, ignored. Use items through ox_inventory
RegisterNetEvent('QBCore:Server:UseItem', function(item)
    warnDeprecatedItemEvent('QBCore:Server:UseItem', source, item)
end)

---@deprecated exploitable, ignored. Remove items on the server through ox_inventory
RegisterNetEvent('QBCore:Server:RemoveItem', function(itemName, amount)
    warnDeprecatedItemEvent('QBCore:Server:RemoveItem', source, itemName, amount)
end)

---@deprecated exploitable, ignored. Add items on the server through ox_inventory
RegisterNetEvent('QBCore:Server:AddItem', function(itemName, amount)
    warnDeprecatedItemEvent('QBCore:Server:AddItem', source, itemName, amount)
end)