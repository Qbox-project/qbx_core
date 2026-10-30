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
    local serverCallback = qbCoreCompat.ServerCallbacks[name]
    if not serverCallback then return end
    qbCoreCompat.ServerCallbacks[name] = nil

    if serverCallback.promise then
        serverCallback.promise:resolve((...))
    end
    if serverCallback.callback then
        serverCallback.callback(...)
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

---@param value any
---@return boolean
local function isFunction(value)
    return type(value) == 'function' or type(value) == 'table' and type(value.__cfx_functionReference) == 'string'
end

-- Server Callback
---Without a callback as the second argument, waits for the response and returns its first value.
---@deprecated use https://coxdocs.dev/ox_lib/Modules/Callback/Lua/Client instead
---@param name string
---@param cb? function
---@return any
function qbCoreCompat.Functions.TriggerCallback(name, cb, ...)
    if isFunction(cb) then
        qbCoreCompat.ServerCallbacks[name] = { callback = cb }
        TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
        return
    end

    local p = promise.new()
    qbCoreCompat.ServerCallbacks[name] = { promise = p }
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, cb, ...)
    return Citizen.Await(p)
end

---@deprecated Use lib.print.debug()
---@param obj any
function qbCoreCompat.Debug(_, obj)
    lib.print.debug(obj)
end

local createQbExport = require 'bridge.qb.shared.export-function'

---@param filters? string[]
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
    return qbCoreCompat.Shared[namespace]?[item]
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function()
    qbCoreCompat.PlayerData = QBX.PlayerData
end)

---@deprecated qbx_core sends shared data changes through QBCore:Client:OnSharedUpdate
RegisterNetEvent('QBCore:Client:SharedUpdate', function(shared)
    if type(shared) ~= 'table' then return end
    for key, value in pairs(shared) do
        if type(qbCoreCompat.Shared[key]) ~= 'function' then
            qbCoreCompat.Shared[key] = value
        end
    end
end)

local exportedElsewhere = { DrawText = true }
for name, func in pairs(qbCoreCompat.Functions) do
    if type(func) == 'function' and not exportedElsewhere[name] then
        createQbExport(name, func)
    end
end

RegisterNetEvent('qbx_core:client:onJobUpdate', function(jobName, job)
    qbCoreCompat.Shared.Jobs[jobName] = job
end)

RegisterNetEvent('qbx_core:client:onGangUpdate', function(gangName, gang)
    qbCoreCompat.Shared.Gangs[gangName] = gang
end)
