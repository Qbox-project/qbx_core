---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBX = {}
QBX.Config = require 'config'
QBX.Shared = require 'shared.main'

---@alias Source integer
---@type table<Source, Player>
QBX.Players = {}
GlobalState.PlayerCount = 0

QBX.Player = require 'server.player'

QBX.Player_Buckets = {}
QBX.Entity_Buckets = {}
QBX.UsableItems = {}
QBX.Functions = require 'server.functions'

---Adds or overwrites jobs in shared/jobs.lua
---@param jobs table<string, Job>
local function createJobs(jobs)
    for jobName, job in pairs(jobs) do
        QBX.Shared.Jobs[jobName] = job
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('QBCore:Server:UpdateObject')
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

    if not QBX.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    QBX.Shared.Jobs[jobName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

exports('RemoveJob', RemoveJob)

---Adds or overwrites gangs in shared/gangs.lua
---@param gangs table<string, Gang>
local function createGangs(gangs)
    for gangName, gang in pairs(gangs) do
        QBX.Shared.Gangs[gangName] = gang
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('QBCore:Server:UpdateObject')
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

    if not QBX.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    QBX.Shared.Gangs[gangName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

exports('RemoveGang', RemoveGang)

---@deprecated import QBX using module 'qbx_core:core' https://qbox-project.github.io/resources/core/import
exports('GetCoreObject', function() return QBX end)
