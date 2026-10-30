if GetConvar('qbx:enablebridge', 'true') == 'false' then return end

require 'bridge.qb.server.debug'
require 'bridge.qb.server.events'

local compat = require 'bridge.qb.shared.compat'
compat.convertItems()
RegisterCommand('convertqbitems', function() compat.convertItems(true) end, true)

---@diagnostic disable-next-line: lowercase-global
qbCoreCompat = {}

qbCoreCompat.Config = lib.table.merge(require 'config.server', require 'config.shared')
qbCoreCompat.Shared = require 'bridge.qb.shared.main'

local qbItemsLoaded, qbItems = pcall(compat.getQbItems)
if qbItemsLoaded then
    for name, item in pairs(qbItems) do
        if not qbCoreCompat.Shared.Items[name] then
            item.name = item.name or name
            qbCoreCompat.Shared.Items[name] = item
        end
    end
end

qbCoreCompat.Shared.Jobs = GetJobs()
qbCoreCompat.Shared.Gangs = GetGangs()
qbCoreCompat.Players = QBX.Players
qbCoreCompat.Player = require 'bridge.qb.server.player'
qbCoreCompat.Player_Buckets = QBX.Player_Buckets
qbCoreCompat.Entity_Buckets = QBX.Entity_Buckets
qbCoreCompat.UsableItems = QBX.UsableItems
qbCoreCompat.Functions = require 'bridge.qb.server.functions'
qbCoreCompat.Commands = require 'bridge.qb.server.commands'

---@diagnostic disable: deprecated

---@deprecated Call lib.print.debug() instead
qbCoreCompat.Debug = lib.print.debug

---@deprecated Call lib.print.error() instead
qbCoreCompat.ShowError = lib.print.error

---@deprecated Use lib.print.info() instead
qbCoreCompat.ShowSuccess = lib.print.info

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
qbCoreCompat.ServerCallbacks = {}

-- Callback Events --

-- Client Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerClientCallback', function(name, ...)
    local key = ('%s:%s'):format(source, name)
    local cb = qbCoreCompat.ClientCallbacks[key]
    if cb then
        qbCoreCompat.ClientCallbacks[key] = nil
        cb(...)
    end
end)

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    qbCoreCompat.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

--- @deprecated
RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source --[[@as Source]]
    local player = GetPlayer(src)
    if not player then return end
    if IsPlayerAceAllowed(src --[[@as string]], ('command.%s'):format(command)) then
        local commandString = command
        for _, value in pairs(args) do
            commandString = ('%s %s'):format(commandString, value)
        end
        TriggerClientEvent('QBCore:Command:CallCommand', src, commandString)
    end
end)

-- Callback Functions --

-- Client Callback
---Without a callback after source, waits for the client's response and returns it.
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
---@param name string
---@param source Source
---@param ... any optional callback, then arguments sent to the client
---@return any ...
function qbCoreCompat.Functions.TriggerClientCallback(name, source, ...)
    if not source then return end
    local args = table.pack(...)
    local key = ('%s:%s'):format(source, name)

    if qbCoreCompat.Shared.IsFunction(args[1]) then
        qbCoreCompat.ClientCallbacks[key] = args[1]
        TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, table.unpack(args, 2, args.n))
        return
    end

    local p = promise.new()
    qbCoreCompat.ClientCallbacks[key] = function(...)
        p:resolve(table.pack(...))
    end
    TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, table.unpack(args, 1, args.n))
    local result = Citizen.Await(p)
    return table.unpack(result, 1, result.n)
end

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Server instead
function qbCoreCompat.Functions.CreateCallback(name, cb)
    qbCoreCompat.ServerCallbacks[name] = cb
end

---@deprecated call a function instead
function qbCoreCompat.Functions.TriggerCallback(name, source, cb, ...)
    if not qbCoreCompat.ServerCallbacks[name] then return end
    qbCoreCompat.ServerCallbacks[name](source, cb, ...)
end

---@deprecated call server function qbx.spawnVehicle from modules/lib.lua
qbCoreCompat.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local vehId = qbCoreCompat.Functions.SpawnVehicle(source, model, coords, warp)

    if vehId then cb(NetworkGetNetworkIdFromEntity(vehId)) end
end)

---@deprecated call server function qbx.spawnVehicle from modules/lib.lua
qbCoreCompat.Functions.CreateCallback('QBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local vehId = qbCoreCompat.Functions.CreateVehicle(source, model, nil, coords, warp)

    if vehId then cb(NetworkGetNetworkIdFromEntity(vehId)) end
end)

AddEventHandler('qbx_core:server:onJobUpdate', function(jobName)
    qbCoreCompat.Shared.Jobs[jobName] = GetJob(jobName)
end)

AddEventHandler('qbx_core:server:onGangUpdate', function(gangName)
    qbCoreCompat.Shared.Gangs[gangName] = GetGang(gangName)
end)

local createQbExport = require 'bridge.qb.shared.export-function'

---@param filters? string[] only return these top-level keys
createQbExport('GetCoreObject', function(filters)
    if type(filters) ~= 'table' then return qbCoreCompat end

    local results = {}
    for i = 1, #filters do
        local key = filters[i]
        results[key] = qbCoreCompat[key]
    end
    return results
end)

---@deprecated use exports.ox_inventory:Items() instead
createQbExport('GetSharedItems', function()
    return qbCoreCompat.Shared.Items
end)

---@deprecated use exports.qbx_core:GetVehiclesByName() instead
createQbExport('GetSharedVehicles', function()
    return qbCoreCompat.Shared.Vehicles
end)

---@deprecated use exports.qbx_core:GetWeapons() instead
createQbExport('GetSharedWeapons', function()
    return qbCoreCompat.Shared.Weapons
end)

---@deprecated use exports.qbx_core:GetJobs() instead
createQbExport('GetSharedJobs', function()
    return qbCoreCompat.Shared.Jobs
end)

---@deprecated use exports.qbx_core:GetGangs() instead
createQbExport('GetSharedGangs', function()
    return qbCoreCompat.Shared.Gangs
end)

---@deprecated
---@param namespace string
---@param item any
createQbExport('GetShared', function(namespace, item)
    local shared = qbCoreCompat.Shared[namespace]
    if type(shared) == 'table' then return shared[item] end
end)

---@deprecated use exports.qbx_core:ExploitBan() instead
---@param playerId Source
---@param origin string
createQbExport('ExploitBan', function(playerId, origin)
    exports.qbx_core:ExploitBan(playerId, origin)
end)

for name, fn in pairs(qbCoreCompat.Functions) do
    if type(fn) == 'function' then
        createQbExport(name, fn)
    end
end
