local qbCoreCompat = QBCore

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
qbCoreCompat.ServerCallbacks = {}

---@deprecated
qbCoreCompat.Commands = {}

function qbCoreCompat.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    local properties = {
        help = help,
        restricted = permission and permission ~= "user" and 'group.'..permission or false,
        params = {}
    }
    for i = 1, #arguments do
        local argument = arguments[i]
        properties.params[i] = {
            name = argument.name,
            help = argument.help,
            type = argument.type or nil,
            optional = not argsrequired or argument?.optional
        }
    end
    lib.addCommand(name, properties, function(source, args, raw)
        local _args = {}
        for _, v in pairs(args) do
            _args[#_args + 1] = v
        end
        callback(source, _args, raw)
    end)
end

---@deprecated
function qbCoreCompat.Commands.Refresh(_) end

---@deprecated Call lib.print.debug() instead
---@param tbl any
RegisterServerEvent('QBCore:DebugSomething', function(tbl)
    local resource = GetInvokingResource() or "qbx-core"
    lib.print.debug(resource, tbl)
end)

---@deprecated Call lib.print.debug() instead
qbCoreCompat.Debug = DebugPrint

---@deprecated Call lib.print.error() instead
---@param resource string
---@param msg string
function qbCoreCompat.ShowError(resource, msg)
    lib.print.error(resource, msg)
end

---@deprecated Use lib.print.info() instead
---@param resource string
---@param msg string
function qbCoreCompat.ShowSuccess(resource, msg)
    lib.print.info(resource, msg)
end

-- Callback Events --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerClientCallback', function(name, ...)
    if qbCoreCompat.ClientCallbacks[name] then
        qbCoreCompat.ClientCallbacks[name](...)
        qbCoreCompat.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    qbCoreCompat.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

--- @deprecated
RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source --[[@as Source]]
    if not qbCoreCompat.Commands.List[command] then return end
    local Player = qbCoreCompat.Functions.GetPlayer(src)
    if not Player then return end
    if IsPlayerAceAllowed(src, string.format('command.%s', command)) then
        local commandString = command
        for _, value in pairs(args) do
            commandString = string.format('%s %s', commandString, value)
        end
        TriggerClientEvent('QBCore:Command:CallCommand', src, commandString)
    end
end)

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
qbCoreCompat.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
qbCoreCompat.Functions.CreateCallback('QBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)

-- Single add item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function AddItem(itemName, item)
    lib.print.warn(string.format("%s invoked Deprecated function AddItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if qbCoreCompat.Shared.Items[itemName] then
        return false, "item_exists"
    end

    qbCoreCompat.Shared.Items[itemName] = item

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

qbCoreCompat.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function UpdateItem(itemName, item)
    lib.print.warn(string.format("%s invoked deprecated function UpdateItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not qbCoreCompat.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    qbCoreCompat.Shared.Items[itemName] = item
    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

qbCoreCompat.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function AddItems(items)
    lib.print.warn(string.format("%s invoked deprecated function AddItems. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if qbCoreCompat.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        qbCoreCompat.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, message, nil
end

qbCoreCompat.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function RemoveItem(itemName)
    lib.print.warn(string.format("%s invoked deprecated function RemoveItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not qbCoreCompat.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    qbCoreCompat.Shared.Items[itemName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

qbCoreCompat.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

---@deprecated
qbCoreCompat.Functions.GetCoords = GetCoordsFromEntity

---@deprecated use the native GetPlayerIdentifierByType?
qbCoreCompat.Functions.GetIdentifier = GetPlayerIdentifierByType

---@deprecated use the native GetPlayers instead
qbCoreCompat.Functions.GetPlayers = GetPlayers

---@deprecated use SpawnVehicle from imports/utils.lua
function qbCoreCompat.Functions.SpawnVehicle(source, model, coords, warp)
    return SpawnVehicle(source, model, coords, warp)
end

---@deprecated use SpawnVehicle from imports/utils.lua
qbCoreCompat.Functions.CreateVehicle = SpawnVehicle

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
function qbCoreCompat.Functions.TriggerClientCallback(name, source, cb, ...)
    qbCoreCompat.ClientCallbacks[name] = cb
    TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
function qbCoreCompat.Functions.CreateCallback(name, cb)
    qbCoreCompat.ServerCallbacks[name] = cb
end

---@deprecated call a function instead
function qbCoreCompat.Functions.TriggerCallback(name, source, cb, ...)
    if not qbCoreCompat.ServerCallbacks[name] then return end
    qbCoreCompat.ServerCallbacks[name](source, cb, ...)
end

---@deprecated No replacement. See https://overextended.dev/ox_inventory/Functions/Client#useitem
---@param source Source
---@param item string name
function qbCoreCompat.Functions.UseItem(source, item)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:UseItem(source, item)
end

---@deprecated use KickWithReason from imports/utils.lua
qbCoreCompat.Functions.Kick = KickWithReason

---@deprecated use IsLicenseInUse from imports/utils.lua
qbCoreCompat.Functions.IsLicenseInUse = IsLicenseInUse

-- Utility functions

---@deprecated use https://overextended.dev/ox_inventory/Functions/Server#search
qbCoreCompat.Functions.HasItem = HasItem

---@deprecated use GetPlate from imports/utils.lua
qbCoreCompat.Functions.GetPlate = GetPlate

---@deprecated ox_inventory automatically saves
---@param source Source
function qbCoreCompat.Player.SaveInventory(source)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(source, false)
end

---@deprecated ox_inventory automatically saves
---@param playerData PlayerData
function qbCoreCompat.Player.SaveOfflineInventory(playerData)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(playerData, true)
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@return number?
function qbCoreCompat.Player.GetTotalWeight(items)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetTotalWeight(items)
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@param itemName string
---@return integer[]? slots
function qbCoreCompat.Player.GetSlotsByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@param itemName string
---@return integer? slot
function qbCoreCompat.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

---@deprecated import QBCore using module 'qbx-core:core' https://qbox-docs.vercel.app/resources/core/import
AddEventHandler('__cfx_export_qb-core_GetCoreObject', function(setCB)
    setCB(function()
        return qbCoreCompat
    end)
end)