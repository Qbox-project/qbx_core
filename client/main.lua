QBX = {}
QBX.PlayerData = {}
QBX.Shared = require 'shared.main'
QBX.IsLoggedIn = false

---@param name string?
---@return table?
function GetVehicles(name)
    if not name then return QBX.Shared.Vehicles end

    if type(name) ~= 'string' then return end

    name = name:lower()

    return QBX.Shared.Vehicles[name]
end

exports('GetVehicles', GetVehicles)

---@deprecated use the GetVehicles function instead
---@return table<string, Vehicle>
function GetVehiclesByName()
    lib.print.verbose('deprecated function GetVehiclesByName invoked. use GetVehicles instead')

    return QBX.Shared.Vehicles
end

exports('GetVehiclesByName', GetVehiclesByName)

---@return table<number, Vehicle>
function GetVehiclesByHash()
    return QBX.Shared.VehicleHashes
end

exports('GetVehiclesByHash', GetVehiclesByHash)

---@return table<string, Vehicle[]>
function GetVehiclesByCategory()
    return qbx.table.mapBySubfield(QBX.Shared.Vehicles, 'category')
end

exports('GetVehiclesByCategory', GetVehiclesByCategory)

---@param name string?
---@return table?
function GetWeapons(name)
    if not name then return QBX.Shared.Weapons end

    if type(name) ~= 'string' then return end

    name = name:lower()

    return QBX.Shared.Weapons[name]
end

exports('GetWeapons', GetWeapons)

---@param name string?
---@return table?
function GetLocations(name)
    if not name then return QBX.Shared.Locations end

    if type(name) ~= 'string' then return end

    name = name:lower()

    return QBX.Shared.Locations[name]
end

exports('GetLocations', GetLocations)

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    QBX.IsLoggedIn = value
end)

lib.callback.register('qbx_core:client:setHealth', function(health)
    SetEntityHealth(cache.ped, health)
end)

local mapText = require 'config.client'.pauseMapText
if mapText == '' or type(mapText) ~= 'string' then mapText = 'FiveM' end
AddTextEntry('FE_THDR_GTAO', mapText)

CreateThread(function()
    for _, v in pairs(GetVehiclesByName()) do
        if v.model and v.name then
            local gameName = GetDisplayNameFromVehicleModel(v.model)
            if gameName and gameName ~= 'CARNOTFOUND' then
                AddTextEntryByHash(joaat(gameName), v.name)
            else
                lib.print.warn('Could not find gameName value in vehicles.meta for vehicle model %s', v.model)
            end
        end
	end
end)
