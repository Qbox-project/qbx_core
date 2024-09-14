if GetConvar('qbx:enable_vehicle_persistence', 'true') == 'false' then return end

assert(lib.checkDependency('qbx_vehicles', '1.4.1', true))

local function getVehicleId(vehicle)
    return Entity(vehicle).state.vehicleid or exports.qbx_vehicles:GetVehicleByIdPlate(GetVehicleNumberPlateText(vehicle))
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
        local damage = {}
        local numDoors = 0

        for i = 0, 5 do
            if IsVehicleDoorDamaged(vehicle, i) then
                numDoors += 1
                damage[numDoors] = i
            end
        end

        props.doors = damage
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

AddEventHandler('entityRemoved', function(entity)
    if not IsEntityAVehicle(entity) then return end
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    local bucket = GetEntityRoutingBucket(entity)

    local vehicleId = getVehicleId(entity)
    if not vehicleId then return end
    local playerVehicle = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)

    if DoesEntityExist(entity) then
        DeleteVehicle(entity)
    end

    qbx.spawnVehicle({
        model = playerVehicle.props.model,
        spawnSource = vec4(coords.x, coords.y, coords.z, heading),
        bucket = bucket,
        props = playerVehicle.props
    })
end)