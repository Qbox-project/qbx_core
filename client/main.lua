QBX = {}
QBX.PlayerData = {}
QBX.Shared = require 'shared.main'
QBX.IsLoggedIn = false

---@return table<string, Job>
function GetJobs()
    return QBX.Shared.Jobs
end

exports('GetJobs', GetJobs)

---@return table<string, Gang>
function GetGangs()
    return QBX.Shared.Gangs
end

exports('GetGangs', GetGangs)

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

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    QBX.IsLoggedIn = value
end)
