lib.versionCheck('Qbox-project/qbx_core')
local startupErrors, errorMessage = lib.checkDependency('ox_lib', '3.20.0', true), 'ox_lib version 3.20.0 or higher is required'
startupErrors, errorMessage = not startupErrors and lib.checkDependency('ox_inventory', '2.42.0', true), 'ox_inventory version 2.42.0 or higher is required'
startupErrors, errorMessage = not startupErrors and GetConvar('inventory:framework', '') == 'qbx' and true, 'inventory:framework must be set to "qbx" in order to use qbx_core'
if not startupErrors then
    lib.print.error('Startup errors detected, shutting down server...')
    ExecuteCommand('quit immediately')
    for _ = 1, 100 do
        lib.print.error(errorMessage)
    end
    error(errorMessage)
end

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

---@return table<number, Weapon>
function GetWeapons()
    return QBX.Shared.Weapons
end

exports('GetWeapons', GetWeapons)

---@deprecated
---@return table<string, vector4>
function GetLocations()
    return QBX.Shared.Locations
end

exports('GetLocations', GetLocations)
