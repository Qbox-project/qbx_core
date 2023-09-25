---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBCore = {}
QBCore.Config = require 'config'
QBCore.Shared = require 'shared.main'

---@alias Source integer
---@type table<Source, Player>
QBCore.Players = {}
GlobalState.PlayerCount = 0

QBCore.Player = require 'server.player'

QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}
QBCore.Functions = require 'server.functions'

---Adds or overwrites jobs in shared/jobs.lua
---@param jobs table<string, Job>
local function createJobs(jobs)
    for jobName, job in pairs(jobs) do
        QBCore.Shared.Jobs[jobName] = job
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

    if not QBCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    QBCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

exports('RemoveJob', RemoveJob)

---Adds or overwrites gangs in shared/gangs.lua
---@param gangs table<string, Gang>
local function createGangs(gangs)
    for gangName, gang in pairs(gangs) do
        QBCore.Shared.Gangs[gangName] = gang
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

    if not QBCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    QBCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

exports('RemoveGang', RemoveGang)

---import QBX using module 'qbx-core:core' https://qbox-project.github.io/resources/core/import
exports('GetCoreObject', function() return QBCore end)
