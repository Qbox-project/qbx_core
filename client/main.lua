QBX = {}
QBX.PlayerData = {}
QBX.Shared = require 'shared.main'
QBX.IsLoggedIn = false

function GetJobs()
    return QBX.Shared.Jobs
end

exports('GetJobs', GetJobs)

function GetGangs()
    return QBX.Shared.Gangs
end

exports('GetGangs', GetGangs)

function GetVehiclesByName()
    return QBX.Shared.Vehicles
end

exports('GetVehiclesByName', GetVehiclesByName)

function GetVehiclesByHash()
    return QBX.Shared.VehicleHashes
end

exports('GetVehiclesByHash', GetVehiclesByHash)

---@deprecated import QBX using module 'qbx_core:core' https://qbox-project.github.io/resources/core/import
exports('GetCoreObject', function() return QBX end)
