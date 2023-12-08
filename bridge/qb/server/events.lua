local config = require 'config.server'
local logger = require 'modules.logger'

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

---Compatability event for logging
---@param name string source of the log. Usually a playerId or name of a script.
---@param title string the action or 'event' being logged. Usually a verb describing what the name is doing. Example: SpawnVehicle
---@param message string the message attached to the log
---@param color? string what color the message should be
---@param tagEveryone? boolean Whether a role tag should be applied to this log. Uses config variable for logging role
---@deprecated use logger module from qbx_core
RegisterNetEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone)
    logger.log({
        source = GetInvokingResource() or "qbx_core",
        webhook = name,
        event = title,
        message = message,
        color = color,
        tags = tagEveryone and config.logging.role or nil
    })
end)