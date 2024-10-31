local config = require 'config.client'

-- Trigger Command
--- @deprecated
RegisterNetEvent('QBCore:Command:CallCommand', function(command)
    ExecuteCommand(command)
end)

RegisterNetEvent('QBCore:Client:VehicleInfo', function(info)
    local vehicle = NetworkGetEntityFromNetworkId(info.netId)
    local plate = qbx.getVehiclePlate(vehicle)
    local hasKeys = config.hasKeys(plate, vehicle)

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

AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    TriggerEvent('hud:client:UpdateNeeds', value, LocalPlayer.state.thirst)
end)

AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    TriggerEvent('hud:client:UpdateNeeds', LocalPlayer.state.hunger, value)
end)

AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value)
    TriggerEvent('hud:client:UpdateStress', value)
end)