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