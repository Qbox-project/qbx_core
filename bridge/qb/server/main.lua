local qbCoreCompat = {}

qbCoreCompat.Config = QBCore.Config
qbCoreCompat.Shared = require 'bridge.qb.shared.main'
qbCoreCompat.Players = QBCore.Players
qbCoreCompat.Player = require 'bridge.qb.server.player'
qbCoreCompat.Player_Buckets = QBCore.Player_Buckets
qbCoreCompat.Entity_Buckets = QBCore.Entity_Buckets
qbCoreCompat.UsableItems = QBCore.UsableItems
qbCoreCompat.Functions = require 'bridge.qb.server.functions'
qbCoreCompat.Commands = require 'bridge.qb.server.commands'

---@deprecated Call lib.print.debug() instead
qbCoreCompat.Debug = lib.print.debug

---@deprecated Call lib.print.error() instead
qbCoreCompat.ShowError = lib.print.error

---@deprecated Use lib.print.info() instead
qbCoreCompat.ShowSuccess = lib.print.info

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
qbCoreCompat.ServerCallbacks = {}

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
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if IsPlayerAceAllowed(src, string.format('command.%s', command)) then
        local commandString = command
        for _, value in pairs(args) do
            commandString = string.format('%s %s', commandString, value)
        end
        TriggerClientEvent('QBCore:Command:CallCommand', src, commandString)
    end
end)

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

function CreateQbExport(name, cb)
    AddEventHandler(string.format('__cfx_export_qb-core_%s', name), function(setCB)
        setCB(cb)
    end)
end

CreateQbExport('GetCoreObject', function()
    return qbCoreCompat
end)
