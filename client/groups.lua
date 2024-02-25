local jobs = require 'shared.jobs'
local gangs = require 'shared.gangs'

---@return table<string, Job>
function GetJobs()
    return jobs
end

exports('GetJobs', GetJobs)

---@return table<string, Gang>
function GetGangs()
    return gangs
end

exports('GetGangs', GetGangs)

RegisterNetEvent('qbx_core:client:onJobUpdate', function(jobName, job)
    jobs[jobName] = job
end)

RegisterNetEvent('qbx_core:client:onGangUpdate', function(gangName, gang)
    gangs[gangName] = gang
end)