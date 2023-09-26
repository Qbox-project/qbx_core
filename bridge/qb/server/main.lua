QbCoreCompat = {}

QbCoreCompat.Config = QBX.Config
QbCoreCompat.Shared = require 'bridge.qb.shared.main'
QbCoreCompat.Players = QBX.Players
QbCoreCompat.Player = require 'bridge.qb.server.player'
QbCoreCompat.Player_Buckets = {}
QbCoreCompat.Entity_Buckets = {}
QbCoreCompat.UsableItems = QBX.UsableItems
QbCoreCompat.Functions = require 'bridge.qb.server.functions'
QbCoreCompat.Commands = require 'bridge.qb.server.commands'

---@deprecated Call lib.print.debug() instead
QbCoreCompat.Debug = lib.print.debug

---@deprecated Call lib.print.error() instead
QbCoreCompat.ShowError = lib.print.error

---@deprecated Use lib.print.info() instead
QbCoreCompat.ShowSuccess = lib.print.info

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
QbCoreCompat.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
QbCoreCompat.ServerCallbacks = {}

-- Callback Events --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerClientCallback', function(name, ...)
    if QbCoreCompat.ClientCallbacks[name] then
        QbCoreCompat.ClientCallbacks[name](...)
        QbCoreCompat.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    QbCoreCompat.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

--- @deprecated
RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source --[[@as Source]]
    if not QbCoreCompat.Commands.List[command] then return end
    local player = QBX.Functions.GetPlayer(src)
    if not player then return end
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
function QbCoreCompat.Functions.TriggerClientCallback(name, source, cb, ...)
    QbCoreCompat.ClientCallbacks[name] = cb
    TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
function QbCoreCompat.Functions.CreateCallback(name, cb)
    QbCoreCompat.ServerCallbacks[name] = cb
end

---@deprecated call a function instead
function QbCoreCompat.Functions.TriggerCallback(name, source, cb, ...)
    if not QbCoreCompat.ServerCallbacks[name] then return end
    QbCoreCompat.ServerCallbacks[name](source, cb, ...)
end

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
QbCoreCompat.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
QbCoreCompat.Functions.CreateCallback('QBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)

CreateQbExport('GetCoreObject', function()
    return QbCoreCompat
end)
