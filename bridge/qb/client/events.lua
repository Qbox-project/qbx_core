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

---@deprecated use qbx.spawnVehicle from modules/lib.lua on the server
RegisterNetEvent('QBCore:Command:SpawnVehicle', function(vehName)
    local hash = type(vehName) == 'number' and vehName or type(vehName) == 'string' and joaat(vehName)
    if not hash or not IsModelInCdimage(hash) then return end
    lib.requestModel(hash)

    if IsPedInAnyVehicle(cache.ped, false) then
        qbx.deleteVehicle(GetVehiclePedIsUsing(cache.ped))
    end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(cache.ped), true, false)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent('vehiclekeys:client:SetOwner', qbx.getVehiclePlate(vehicle))
end)

---@deprecated use qbx.deleteVehicle from modules/lib.lua
RegisterNetEvent('QBCore:Command:DeleteVehicle', function()
    local vehicle = GetVehiclePedIsUsing(cache.ped)
    if vehicle ~= 0 then
        qbx.deleteVehicle(vehicle)
        return
    end

    local vehicles = lib.getNearbyVehicles(GetEntityCoords(cache.ped), 5.0, true)
    for i = 1, #vehicles do
        qbx.deleteVehicle(vehicles[i].vehicle)
    end
end)

---@deprecated qbx_core applies PvP from GlobalState.PVPEnabled
RegisterNetEvent('QBCore:Client:PvpHasToggled', function(pvpState)
    SetCanAttackFriendly(cache.ped, pvpState, false)
    NetworkSetFriendlyFireOption(pvpState)
end)

---@deprecated qbx_core sends player data updates without a client request
RegisterNetEvent('QBCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('QBCore:UpdatePlayer')
end)

---@deprecated
RegisterNetEvent('QBCore:Client:UseItem', function(item)
    lib.print.warn(('%s triggered QBCore:Client:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check qb-inventory for the right use on this event.'):format(GetInvokingResource(), cache.serverId))
    lib.print.warn(item)
end)

---@deprecated use the 'me' player state bag
RegisterNetEvent('QBCore:Command:ShowMe3D', function(senderId, msg)
    local sender = GetPlayerFromServerId(senderId)
    if sender == -1 or not msg then return end

    CreateThread(function()
        local displayTime = GetGameTimer() + 5000
        while displayTime > GetGameTimer() do
            qbx.drawText3d({ text = tostring(msg), coords = GetEntityCoords(GetPlayerPed(sender)) })
            Wait(0)
        end
    end)
end)