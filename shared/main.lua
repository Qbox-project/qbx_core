local qbShared = {}
qbShared.Gangs = require 'gangs'
qbShared.Items = require 'items'
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Jobs = require 'jobs'
qbShared.Locations = require 'locations'
qbShared.Vehicles = require 'vehicles'
qbShared.Weapons = require 'weapons'

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
	qbShared.VehicleHashes[v.hash] = v
end

return qbShared
