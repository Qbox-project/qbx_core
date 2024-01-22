local config = require 'config.client'

-- Trigger Command
--- @deprecated
RegisterNetEvent('QBCore:Command:CallCommand', function(command)
    ExecuteCommand(command)
end)

RegisterNetEvent('QBCore:Client:VehicleInfo', function(info)
    local vehicle = NetworkGetEntityFromNetworkId(info.netId)
    local plate = qbx.getVehiclePlate(vehicle)
    local hasKeys = config.hasKeys()

    local data = {
        vehicle = vehicle,
        seat = info.seat,
        name = info.modelName,
        plate = plate,
        driver = GetPedInVehicleSeat(vehicle, -1),
        inseat = GetPedInVehicleSeat(vehicle, info.seat),
        haskeys = hasKeys
    }

    TriggerEvent('QBCore:Client:'..info.event..'Vehicle', data)
end)