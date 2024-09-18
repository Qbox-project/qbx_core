if GetConvar('qbx:enable_vehicle_persistence', 'true') == 'false' then return end

assert(lib.checkDependency('qbx_vehicles', '1.4.1', true))

---A persisted vehicle will respawn when deleted. Only works for player owned vehicles.
---Vehicles spawned using lib are automatically persisted
---@param vehicle number
local function enablePersistence(vehicle)
    Entity(vehicle).state:set('persisted', true, true)
end

exports('EnablePersistence', enablePersistence)

---A vehicle without persistence will not respawn when deleted.
---@param vehicle number
function DisablePersistence(vehicle)
    Entity(vehicle).state:set('persisted', nil, true)
end

exports('DisablePersistence', DisablePersistence)

local function getVehicleId(vehicle)
    return Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
end

RegisterNetEvent('qbx_core:server:vehiclePropsChanged', function(netId, diff)
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    local vehicleId = getVehicleId(vehicle)
    if not vehicleId then return end

    local props = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)?.props
    if not props then return end

    if diff.bodyHealth then
        props.bodyHealth = GetVehicleBodyHealth(vehicle)
    end

    if diff.engineHealth then
        props.engineHealth = GetVehicleEngineHealth(vehicle)
    end

    if diff.tankHealth then
        props.tankHealth = GetVehiclePetrolTankHealth(vehicle)
    end

    if diff.fuelLevel then
        props.fuelLevel = diff.fuelLevel ~= 'deleted' and diff.fuelLevel or nil
    end

    if diff.oilLevel then
        props.oilLevel = diff.oilLevel ~= 'deleted' and diff.oilLevel or nil
    end

    if diff.dirtLevel then
        props.dirtLevel = GetVehicleDirtLevel(vehicle)
    end

    if diff.windows then
        props.windows = diff.windows ~= 'deleted' and diff.windows or nil
    end

    if diff.doors then
        props.doors = diff.doors ~= 'deleted' and diff.doors or nil
    end

    if diff.tyres then
        local damage = {}
        for i = 0, 7 do
            if IsVehicleTyreBurst(vehicle, i, false) then
                damage[i] = IsVehicleTyreBurst(vehicle, i, true) and 2 or 1
            end
        end

        props.tyres = damage
    end

    exports.qbx_vehicles:SaveVehicle(vehicle, {
        props = props,
    })
end)

AddEventHandler('qbx_core:server:vehicleSpawned', function(entity)
    Entity(entity).state:set('persisted', true, true)
end)

AddEventHandler('entityRemoved', function(entity)
    if not Entity(entity).state.persisted then return end
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local bucket = GetEntityRoutingBucket(entity)

    local vehicleId = getVehicleId(entity)
    if not vehicleId then return end
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)

    if DoesEntityExist(entity) then
        Entity(entity).state:set('persisted', nil, true)
        DeleteVehicle(entity)
    end

    qbx.spawnVehicle({
        model = playerVehicle.props.model,
        spawnSource = vec4(coords.x, coords.y, coords.z, heading),
        bucket = bucket,
        props = playerVehicle.props
    })
end)