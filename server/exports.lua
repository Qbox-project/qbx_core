-- Add or change (a) method(s) in the QBCore.Functions table
---@param methodName string
---@param handler function
---@return boolean success
---@return string message
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    QBCore.Functions[methodName] = handler

    TriggerEvent('QBCore:Server:UpdateObject')

    return true, "success"
end

QBCore.Functions.SetMethod = SetMethod
exports("SetMethod", SetMethod)

-- Add or change (a) field(s) in the QBCore table
---@param fieldName string
---@param data any
---@return boolean success
---@return string message
local function SetField(fieldName, data)
    if type(fieldName) ~= "string" then
        return false, "invalid_field_name"
    end

    QBCore[fieldName] = data

    TriggerEvent('QBCore:Server:UpdateObject')

    return true, "success"
end

QBCore.Functions.SetField = SetField
exports("SetField", SetField)

-- Single add job function which should only be used if you planning on adding a single job
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

QBCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
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

QBCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
---@param jobName string
---@return boolean success
---@return string message
local function RemoveJob(jobName)
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

QBCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
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

QBCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

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

QBCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

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

QBCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

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

QBCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

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

QBCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
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

QBCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
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

QBCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
---@param gangName string
---@return boolean success
---@return string message
local function RemoveGang(gangName)
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

QBCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
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

QBCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

---@param InvokingResource string
---@return string version
local function GetCoreVersion(InvokingResource)
    ---@diagnostic disable-next-line: missing-parameter
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
    if InvokingResource and InvokingResource ~= '' then
        lib.print.debug(("%s called qbcore version check: %s"):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

QBCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

---@param playerId Source server id
---@param origin string reason
local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    CreateThread(function()
        InsertBanEntity({
            name = name,
            license = GetPlayerIdentifierByType(playerId --[[@as string]], 'license2') or GetPlayerIdentifierByType(playerId --[[@as string]], 'license'),
            discordId = GetPlayerIdentifierByType(playerId --[[@as string]], 'discord'),
            ip = GetPlayerIdentifierByType(playerId --[[@as string]], 'ip'),
            reason = origin,
            expiration = 2147483647,
            bannedBy = 'Anti Cheat'
        })
    end)
    DropPlayer(playerId --[[@as string]], Lang:t('info.exploit_banned', {discord = QBCore.Config.Server.Discord}))
    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)
