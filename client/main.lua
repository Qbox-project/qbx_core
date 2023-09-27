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

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    QBX.IsLoggedIn = value
end)
