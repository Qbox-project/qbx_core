local qbShared = {}
qbShared.Items = require 'shared.items'
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Locations = require 'shared.locations'
qbShared.Vehicles = require 'shared.vehicles'

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
	qbShared.VehicleHashes[v.hash] = v
end

local weaponConfig = require '@ox_inventory.data.weapons'
qbShared.Weapons = weaponConfig.Weapons
qbShared.AmmoTypes = weaponConfig.Ammo

---@type table<number, Weapon>
qbShared.WeaponHashes = {}

for k, v in pairs(qbShared.Weapons) do
	v.name = k

	qbShared.WeaponHashes[joaat(k)] = v
end

return qbShared
