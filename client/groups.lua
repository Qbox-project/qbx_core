local jobs, gangs

local function refreshCache()
    local groups = lib.callback.await('qbx_core:server:getGroups')
    jobs = groups.jobs
    gangs = groups.gangs
end

---@return table<string, Job>
function GetJobs()
    if not jobs then refreshCache() end
    return jobs
end

exports('GetJobs', GetJobs)

---@return table<string, Gang>
function GetGangs()
    if not gangs then refreshCache() end
    return gangs
end

exports('GetGangs', GetGangs)

---@param name string
---@return Job?
function GetJob(name)
    if not jobs then refreshCache() end
    return jobs[name]
end

exports('GetJob', GetJob)

---@param name string
---@return Gang?
function GetGang(name)
    if not gangs then refreshCache() end
    return gangs[name]
end

exports('GetGang', GetGang)

RegisterNetEvent('qbx_core:client:onJobUpdate', function(jobName, job)
    jobs[jobName] = job
end)

RegisterNetEvent('qbx_core:client:onGangUpdate', function(gangName, gang)
    gangs[gangName] = gang
end)
