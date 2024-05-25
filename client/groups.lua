local jobs = require 'shared.jobs'
local gangs = require 'shared.gangs'

---@param name string?
---@return table?
function GetJobs(name)
    if not name then return jobs end

    if type(name) ~= 'string' then return end

    name = name:lower()

    return jobs[name]
end

exports('GetJobs', GetJobs)

---@param name string?
---@return table?
function GetGangs(name)
    if not name then return gangs end

    if type(name) ~= 'string' then return end

    name = name:lower()

    return gangs[name]
end

exports('GetGangs', GetGangs)

---@deprecated use the GetJobs function instead
---@param name string
---@return Job?
function GetJob(name)
    return jobs[name]
end

exports('GetJob', GetJob)

---@deprecated use the GetGangs function instead
---@param name string
---@return Gang?
function GetGang(name)
    return gangs[name]
end

exports('GetGang', GetGang)

RegisterNetEvent('qbx_core:client:onJobUpdate', function(jobName, job)
    jobs[jobName] = job
end)

RegisterNetEvent('qbx_core:client:onGangUpdate', function(gangName, gang)
    gangs[gangName] = gang
end)