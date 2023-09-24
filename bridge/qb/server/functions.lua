local functions = require 'server.functions'

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
    CreateQbExport['qb-inventory']:UseItem(source, item)
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

    if QBCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    QBCore.Shared.Items[itemName] = item

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
    if not QBCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    QBCore.Shared.Items[itemName] = item
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

        if QBCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        QBCore.Shared.Items[key] = value
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

    if not QBCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    QBCore.Shared.Items[itemName] = nil

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

    if QBCore.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    QBCore.Shared.Jobs[jobName] = job

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

        if QBCore.Shared.Jobs[key] then
            return false, 'job_exists', jobs[key]
        end

        QBCore.Shared.Jobs[key] = value
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

    if not QBCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    QBCore.Shared.Jobs[jobName] = job

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

    if QBCore.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    QBCore.Shared.Gangs[gangName] = gang

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

    if not QBCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    QBCore.Shared.Gangs[gangName] = gang

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

        if QBCore.Shared.Gangs[key] then
            return false, 'gang_exists', gangs[key]
        end

        QBCore.Shared.Gangs[key] = value
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

return functions