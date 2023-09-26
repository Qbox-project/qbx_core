QbCoreCompat = {}
QbCoreCompat.PlayerData = QBX.PlayerData
QbCoreCompat.Config = QBX.Config
QbCoreCompat.Shared = require 'bridge.qb.shared.main'
QbCoreCompat.Functions = require 'bridge.qb.client.functions'

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
QbCoreCompat.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
QbCoreCompat.ServerCallbacks = {}

-- Callback Events --

-- Client Callback
---@deprecated call a function instead
RegisterNetEvent('QBCore:Client:TriggerClientCallback', function(name, ...)
    QbCoreCompat.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
RegisterNetEvent('QBCore:Client:TriggerCallback', function(name, ...)
    if QbCoreCompat.ServerCallbacks[name] then
        QbCoreCompat.ServerCallbacks[name](...)
        QbCoreCompat.ServerCallbacks[name] = nil
    end
end)

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QbCoreCompat.Functions.CreateClientCallback(name, cb)
    QbCoreCompat.ClientCallbacks[name] = cb
end

---@deprecated call a function instead
function QbCoreCompat.Functions.TriggerClientCallback(name, cb, ...)
    if not QbCoreCompat.ClientCallbacks[name] then return end
    QbCoreCompat.ClientCallbacks[name](cb, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QbCoreCompat.Functions.TriggerCallback(name, cb, ...)
    QbCoreCompat.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

---@deprecated Use lib.print.debug()
---@param obj any
function QbCoreCompat.Debug(_, obj)
    lib.print.debug(obj)
end

function CreateQbExport(name, cb)
    AddEventHandler(string.format('__cfx_export_qb-core_%s', name), function(setCB)
        setCB(cb)
    end)
end

CreateQbExport('GetCoreObject', function()
    return QbCoreCompat
end)
