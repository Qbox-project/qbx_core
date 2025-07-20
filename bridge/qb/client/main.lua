if GetConvar('qbx:enablebridge', 'true') == 'false' then return end

require 'bridge.qb.client.drawtext'
require 'bridge.qb.client.events'

local qbCoreCompat = {}
qbCoreCompat.PlayerData = QBX.PlayerData
qbCoreCompat.Config = lib.table.merge(require 'config.client', require 'config.shared')
qbCoreCompat.Shared = require 'bridge.qb.shared.main'
qbCoreCompat.Shared.Jobs = GetJobs()
qbCoreCompat.Shared.Gangs = GetGangs()
qbCoreCompat.Functions = require 'bridge.qb.client.functions'

---@diagnostic disable: deprecated

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
qbCoreCompat.ServerCallbacks = {}

-- Callback Events --

-- Client Callback
---@deprecated call a function instead
RegisterNetEvent('QBCore:Client:TriggerClientCallback', function(name, ...)
    qbCoreCompat.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
RegisterNetEvent('QBCore:Client:TriggerCallback', function(name, ...)
    if qbCoreCompat.ServerCallbacks[name] then
        qbCoreCompat.ServerCallbacks[name](...)
        qbCoreCompat.ServerCallbacks[name] = nil
    end
end)

-- Callback Functions --

-- Client Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
function qbCoreCompat.Functions.CreateClientCallback(name, cb)
    qbCoreCompat.ClientCallbacks[name] = cb
end

---@deprecated call a function instead
function qbCoreCompat.Functions.TriggerClientCallback(name, cb, ...)
    if not qbCoreCompat.ClientCallbacks[name] then return end
    qbCoreCompat.ClientCallbacks[name](cb, ...)
end

-- Server Callback
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
function qbCoreCompat.Functions.TriggerCallback(name, cb, ...)
    qbCoreCompat.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

---@deprecated Use lib.print.debug()
---@param obj any
function qbCoreCompat.Debug(_, obj)
    lib.print.debug(obj)
end

local createQbExport = require 'bridge.qb.shared.export-function'

createQbExport('GetCoreObject', function()
    return qbCoreCompat
end)

RegisterNetEvent('qbx_core:client:onJobUpdate', function(jobName, job)
    qbCoreCompat.Shared.Jobs[jobName] = job
end)

RegisterNetEvent('qbx_core:client:onGangUpdate', function(gangName, gang)
    qbCoreCompat.Shared.Gangs[gangName] = gang
end)
