local qbShared = {}
qbShared.Gangs = require 'shared.gangs'
qbShared.Items = require 'shared.items'
qbShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
qbShared.Jobs = require 'shared.jobs'
qbShared.Locations = require 'shared.locations'
qbShared.Vehicles = require 'shared.vehicles'
qbShared.Weapons = require 'shared.weapons'

---@type table<number, Vehicle>
qbShared.VehicleHashes = {}

for _, v in pairs(qbShared.Vehicles) do
	qbShared.VehicleHashes[v.hash] = v
end

---@deprecated use CommaValue from imports/utils.lua
qbShared.CommaValue = CommaValue

---@deprecated use RandomLetter from imports/utils.lua
qbShared.RandomStr = RandomLetter

---@deprecated use RandomNumber from imports/utils.lua
qbShared.RandomInt = RandomNumber

---@deprecated use string.split from imports/utils.lua
qbShared.SplitStr = string.split

---@deprecated use string.trim from imports/utils.lua
qbShared.Trim = string.trim

---@deprecated use string.firstToUpper from imports/utils.lua
qbShared.FirstToUpper = string.firstToUpper

---@deprecated use math.round from imports/utils.lua
qbShared.Round = math.round

---@deprecated use ChangeVehicleExtra from imports/utils.lua
qbShared.ChangeVehicleExtra = ChangeVehicleExtra

---@deprecated use SetVehicleExtras from imports/utils.lua
qbShared.SetDefaultVehicleExtras = SetVehicleExtras

---@deprecated use MaleNoGloves from imports/utils.lua
qbShared.MaleNoGloves = MaleNoGloves

---@deprecated use FemaleNoGloves from imports/utils.lua
qbShared.FemaleNoGloves = FemaleNoGloves

return qbShared
