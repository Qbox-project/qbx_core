local jobs = require 'shared.jobs'
local gangs = require 'shared.gangs'

---Adds or overwrites jobs in shared/jobs.lua
---@param jobs table<string, Job>
local function createJobs(jobs)
    for jobName, job in pairs(jobs) do
        jobs[jobName] = job
        TriggerEvent('qbx_core:server:onJobUpdate', jobName, job)
        TriggerClientEvent('qbx_core:client:onJobUpdate', -1, jobName, job)
    end
end

exports('CreateJobs', createJobs)

-- Single Remove Job
---@param jobName string
---@return boolean success
---@return string message
function RemoveJob(jobName)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not jobs[jobName] then
        return false, "job_not_exists"
    end

    jobs[jobName] = nil
    TriggerEvent('qbx_core:server:onJobUpdate', jobName, nil)
    TriggerClientEvent('qbx_core:client:onJobUpdate', -1, jobName, nil)
    return true, "success"
end

exports('RemoveJob', RemoveJob)

---Adds or overwrites gangs in shared/gangs.lua
---@param gangs table<string, Gang>
local function createGangs(gangs)
    for gangName, gang in pairs(gangs) do
        gangs[gangName] = gang
        TriggerEvent('qbx_core:server:onGangUpdate', gangName, gang)
        TriggerClientEvent('qbx_core:client:onGangUpdate', -1, gangName, gang)
    end
end

exports('CreateGangs', createGangs)

-- Single Remove Gang
---@param gangName string
---@return boolean success
---@return string message
function RemoveGang(gangName)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not gangs[gangName] then
        return false, "gang_not_exists"
    end

    gangs[gangName] = nil

    TriggerEvent('qbx_core:server:onGangUpdate', gangName, nil)
    TriggerClientEvent('qbx_core:client:onGangUpdate', -1, gangName, nil)
    return true, "success"
end

exports('RemoveGang', RemoveGang)

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

---@param name string
---@return Job?
function GetJob(name)
    return jobs[name]
end

---@param name string
---@return Gang?
function GetGang(name)
    return gangs[name]
end

lib.callback.register('qbx_core:server:getJobs', function()
    return jobs
end)

lib.callback.register('qbx_core:server:getGangs', function()
    return gangs
end)