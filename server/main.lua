lib.versionCheck('Qbox-project/qbx_core')
assert(lib.checkDependency('ox_lib', '3.20.0', true))

---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'inactive')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

QBX = {}
QBX.Shared = require 'shared.main'

---@alias Source integer
---@type table<Source, Player>
QBX.Players = {}
GlobalState.PlayerCount = 0
GlobalState.MaxPlayers = GetConvarInt('sv_maxclients', 48)

QBX.Player_Buckets = {}
QBX.Entity_Buckets = {}
QBX.UsableItems = {}

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
