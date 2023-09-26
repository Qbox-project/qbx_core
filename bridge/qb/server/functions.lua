local functions = require 'server.functions'

function CreateQbExport(name, cb)
    AddEventHandler(string.format('__cfx_export_qb-core_%s', name), function(setCB)
        setCB(cb)
    end)
end

---@deprecated
functions.GetCoords = GetCoordsFromEntity

---@deprecated use the native GetPlayerIdentifierByType?
functions.GetIdentifier = GetPlayerIdentifierByType

---@deprecated use the native GetPlayers instead
functions.GetPlayers = GetPlayers

---@deprecated Use functions.CreateVehicle instead.
function functions.SpawnVehicle(source, model, coords, warp)
    return SpawnVehicle(source, model, coords, warp)
end

---@deprecated use SpawnVehicle from imports/utils.lua
functions.CreateVehicle = SpawnVehicle

---@deprecated No replacement. See https://overextended.dev/ox_inventory/Functions/Client#useitem
---@param source Source
---@param item string name
function functions.UseItem(source, item)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:UseItem(source, item)
end

---@deprecated use KickWithReason from imports/utils.lua
functions.Kick = KickWithReason

---@deprecated use IsLicenseInUse from imports/utils.lua
functions.IsLicenseInUse = IsLicenseInUse

-- Utility functions

---@deprecated use https://overextended.dev/ox_inventory/Functions/Server#search
functions.HasItem = HasItem

---@deprecated use GetPlate from imports/utils.lua
functions.GetPlate = GetPlate

-- Single add item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function AddItem(itemName, item)
    lib.print.warn(string.format("%s invoked Deprecated function AddItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if QBX.Shared.Items[itemName] then
        return false, "item_exists"
    end

    QBX.Shared.Items[itemName] = item

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.AddItem = AddItem
CreateQbExport('AddItem', AddItem)

-- Single update item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function UpdateItem(itemName, item)
    lib.print.warn(string.format("%s invoked deprecated function UpdateItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not QBX.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    QBX.Shared.Items[itemName] = item
    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.UpdateItem = UpdateItem
CreateQbExport('UpdateItem', UpdateItem)

-- Multiple Add Items
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function AddItems(items)
    lib.print.warn(string.format("%s invoked deprecated function AddItems. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if QBX.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        QBX.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, message, nil
end

functions.AddItems = AddItems
CreateQbExport('AddItems', AddItems)

-- Single Remove Item
---@deprecated incompatible with ox_inventory. Update ox_inventory item config instead.
local function RemoveItem(itemName)
    lib.print.warn(string.format("%s invoked deprecated function RemoveItem. This is incompatible with ox_inventory", GetInvokingResource() or 'unknown resource'))
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not QBX.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    QBX.Shared.Items[itemName] = nil

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.RemoveItem = RemoveItem
CreateQbExport('RemoveItem', RemoveItem)

-- Single add job function which should only be used if you planning on adding a single job
---@deprecated use export CreateJobs
---@param jobName string
---@param job Job
---@return boolean success
---@return string message
local function AddJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if QBX.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    QBX.Shared.Jobs[jobName] = job

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.AddJob = AddJob
CreateQbExport('AddJob', AddJob)

-- Multiple Add Jobs
---@deprecated call export CreateJobs
---@param jobs table<string, Job>
---@return boolean success
---@return string message
---@return Job? errorJob job causing the error message. Only present if success is false.
local function AddJobs(jobs)

    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            return false, 'invalid_job_name', jobs[key]
        end

        if QBX.Shared.Jobs[key] then
            return false, 'job_exists', jobs[key]
        end

        QBX.Shared.Jobs[key] = value
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

functions.AddJobs = AddJobs
CreateQbExport('AddJobs', AddJobs)

-- Single Update Job
---@deprecated call CreateJobs
---@param jobName string
---@param job Job
---@return boolean success
---@return string message
local function UpdateJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not QBX.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    QBX.Shared.Jobs[jobName] = job

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.UpdateJob = UpdateJob
CreateQbExport('UpdateJob', UpdateJob)

-- Single Add Gang
---@deprecated call export CreateGangs
---@param gangName string
---@param gang Gang
---@return boolean success
---@return string message
local function AddGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if QBX.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    QBX.Shared.Gangs[gangName] = gang

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.AddGang = AddGang
CreateQbExport('AddGang', AddGang)

-- Single Update Gang
---@deprecated call export CreateGangs
---@param gangName string
---@param gang Gang
---@return boolean success
---@return string message
local function UpdateGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not QBX.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    QBX.Shared.Gangs[gangName] = gang

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

functions.UpdateGang = UpdateGang
CreateQbExport('UpdateGang', UpdateGang)

-- Multiple Add Gangs
---@deprecated call export CreateGangs
---@param gangs table<string, Gang>
---@return boolean success
---@return string message
---@return Gang? errorGang present if success is false. Gang that caused the error message.
local function AddGangs(gangs)
    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            return false, 'invalid_gang_name', gangs[key]
        end

        if QBX.Shared.Gangs[key] then
            return false, 'gang_exists', gangs[key]
        end

        QBX.Shared.Gangs[key] = value
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

functions.AddGangs = AddGangs
CreateQbExport('AddGangs', AddGangs)

functions.RemoveJob = RemoveJob
CreateQbExport('RemoveJob', RemoveJob)

functions.RemoveGang = RemoveGang
CreateQbExport('RemoveGang', RemoveGang)

-- Routing buckets (Only touch if you know what you are doing)

-- Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
---@deprecated use natives
---@return table
---@return table
function functions.GetBucketObjects()
    return QbCoreCompat.Player_Buckets, QbCoreCompat.Entity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
---@deprecated use natives
---@param source Source
---@param bucket integer
---@return boolean
function functions.SetPlayerBucket(source, bucket)
    if not (source or bucket) then return false end

    SetPlayerRoutingBucket(source --[[@as string]], bucket)
    QbCoreCompat.Player_Buckets[source] = bucket
    return true
end


-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@deprecated use natives
---@param entity integer
---@param bucket integer
---@return boolean
function functions.SetEntityBucket(entity, bucket)
    if not (entity or bucket) then return false end

    SetEntityRoutingBucket(entity, bucket)
    QbCoreCompat.Entity_Buckets[entity] = bucket
    return true
end

-- Will return an array of all the player ids inside the current bucket
---@deprecated use natives
---@param bucket integer
---@return Source[]|boolean
function functions.GetPlayersInBucket(bucket)
    local curr_bucket_pool = {}
    if not (QbCoreCompat.Player_Buckets or next(QbCoreCompat.Player_Buckets)) then
        return false
    end

    for k, v in pairs(QbCoreCompat.Player_Buckets) do
        if v == bucket then
            curr_bucket_pool[#curr_bucket_pool + 1] = k
        end
    end

    return curr_bucket_pool
end

-- Will return an array of all the entities inside the current bucket (not for player entities, use GetPlayersInBucket for that)
---@deprecated use natives
---@param bucket integer
---@return boolean | integer[]
function functions.GetEntitiesInBucket(bucket)
    local curr_bucket_pool = {}
    if not (QbCoreCompat.Entity_Buckets or next(QbCoreCompat.Entity_Buckets)) then
        return false
    end

    for k, v in pairs(QbCoreCompat.Entity_Buckets) do
        if v == bucket then
            curr_bucket_pool[#curr_bucket_pool + 1] = k
        end
    end

    return curr_bucket_pool
end

return functions