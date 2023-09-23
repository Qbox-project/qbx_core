local functions = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

---@alias Identifier 'steam'|'license'|'license2'|'xbl'|'ip'|'discord'|'live'

---@param identifier Identifier
---@return integer source of the player with the matching identifier or 0 if no player found
function functions.GetSource(identifier)
    for src in pairs(QBCore.Players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

---@param source Source|string source or identifier of the player
---@return Player
function functions.GetPlayer(source)
    if type(source) == 'number' then
        return QBCore.Players[source]
    else
        return QBCore.Players[functions.GetSource(source --[[@as string]])]
    end
end

---@param citizenid string
---@return Player?
function functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(QBCore.Players) do
        if QBCore.Players[src].PlayerData.citizenid == citizenid then
            return QBCore.Players[src]
        end
    end
end

---@param citizenid string
---@return Player?
function functions.GetOfflinePlayerByCitizenId(citizenid)
    return QBCore.Player.GetOfflinePlayer(citizenid)
end

---@param number string
---@return Player?
function functions.GetPlayerByPhone(number)
    for src in pairs(QBCore.Players) do
        if QBCore.Players[src].PlayerData.charinfo.phone == number then
            return QBCore.Players[src]
        end
    end
end

---Will return an array of QB Player class instances
---unlike the GetPlayers() wrapper which only returns IDs
---@return table<Source, Player>
function functions.GetQBPlayers()
    return QBCore.Players
end

---Gets a list of all on duty players of a specified job and the number
---@param job string name
---@return integer
---@return Source[]
function functions.GetDutyCountJob(job)
    local players = {}
    local count = 0
    for src, Player in pairs(QBCore.Players) do
        if Player.PlayerData.job.name == job then
            if Player.PlayerData.job.onduty then
                players[#players + 1] = src
                count += 1
            end
        end
    end
    return count, players
end

---Gets a list of all on duty players of a specified job type and the number
---@param type string
---@return integer
---@return Source[]
function functions.GetDutyCountType(type)
    local players = {}
    local count = 0
    for src, Player in pairs(QBCore.Players) do
        if Player.PlayerData.job.type == type then
            if Player.PlayerData.job.onduty then
                players[#players + 1] = src
                count += 1
            end
        end
    end
    return count, players
end

-- Routing buckets (Only touch if you know what you are doing)

-- Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
---@return table
---@return table
function functions.GetBucketObjects()
    return QBCore.Player_Buckets, QBCore.Entity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
---@param source Source
---@param bucket integer
---@return boolean
function functions.SetPlayerBucket(source, bucket)
    if not (source or bucket) then return false end

    SetPlayerRoutingBucket(source --[[@as string]], bucket)
    QBCore.Player_Buckets[source] = bucket
    return true
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@param entity integer
---@param bucket integer
---@return boolean
function functions.SetEntityBucket(entity, bucket)
    if not (entity or bucket) then return false end

    SetEntityRoutingBucket(entity, bucket)
    QBCore.Entity_Buckets[entity] = bucket
    return true
end

-- Will return an array of all the player ids inside the current bucket
---@param bucket integer
---@return Source[]|boolean
function functions.GetPlayersInBucket(bucket)
    local curr_bucket_pool = {}
    if not (QBCore.Player_Buckets or next(QBCore.Player_Buckets)) then
        return false
    end

    for k, v in pairs(QBCore.Player_Buckets) do
        if v == bucket then
            curr_bucket_pool[#curr_bucket_pool + 1] = k
        end
    end

    return curr_bucket_pool
end

-- Will return an array of all the entities inside the current bucket (not for player entities, use GetPlayersInBucket for that)
---@param bucket integer
---@return boolean | integer[]
function functions.GetEntitiesInBucket(bucket)
    local curr_bucket_pool = {}
    if not (QBCore.Entity_Buckets or next(QBCore.Entity_Buckets)) then
        return false
    end

    for k, v in pairs(QBCore.Entity_Buckets) do
        if v == bucket then
            curr_bucket_pool[#curr_bucket_pool + 1] = k
        end
    end

    return curr_bucket_pool
end

-- Items
---@param item string name
---@param data fun(source: Source, item: unknown)
function functions.CreateUseableItem(item, data)
    QBCore.UsableItems[item] = data
end

---@param item string name
---@return unknown
function functions.CanUseItem(item)
    return QBCore.UsableItems[item]
end

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans
---@param source Source
---@return boolean
function functions.IsWhitelisted(source)
    if not QBCore.Config.Server.Whitelist then return true end
    if functions.HasPermission(source, QBCore.Config.Server.WhitelistPermission) then return true end
    return false
end

-- Setting & Removing Permissions
-- TODO: Should these be moved to the utility module?

---@param source Source
---@param permission string
function functions.AddPermission(source, permission)
    if not IsPlayerAceAllowed(source --[[@as string]], permission) then
        lib.addPrincipal('player.' .. source, 'group.' .. permission)
        lib.addAce('player.' .. source, 'group.' .. permission)
        TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
        TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
    end
end

---@param source Source
---@param permission string
function functions.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source --[[@as string]], permission) then
            lib.removePrincipal('player.' .. source, 'group.' .. permission)
            lib.removeAce('player.' .. source, 'group.' .. permission)
            TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
            TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
        end
    else
        local hasUpdated = false
        for _, v in pairs(QBCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source --[[@as string]], v) then
                lib.removePrincipal('player.' .. source, 'group.' .. v)
                lib.removeAce('player.' .. source, 'group.' .. v)
                hasUpdated = true
            end
        end
        if hasUpdated then
            TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
            TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
        end
    end
end

-- Checking for Permission Level
---@param source Source
---@param permission string|string[]
---@return boolean
function functions.HasPermission(source, permission)
    if type(permission) == "string" then
        if IsPlayerAceAllowed(source --[[@as string]], permission) then return true end
    elseif type(permission) == "table" then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source --[[@as string]], permLevel) then return true end
        end
    end

    return false
end

---@param source Source
---@return table<string, boolean>
function functions.GetPermission(source)
    local perms = {}
    for _, v in pairs (QBCore.Config.Server.Permissions) do
        if IsPlayerAceAllowed(source --[[@as string]], v) then
            perms[v] = true
        end
    end
    return perms
end

-- Opt in or out of admin reports
---@param source Source
---@return boolean
function functions.IsOptin(source)
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    if not license or not functions.HasPermission(source, 'admin') then return false end
    local Player = functions.GetPlayer(source)
    return Player.PlayerData.optin
end

---Opt in or out of admin reports
---@param source Source
function functions.ToggleOptin(source)
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    if not license or not functions.HasPermission(source, 'admin') then return end
    local Player = functions.GetPlayer(source)
    Player.PlayerData.optin = not Player.PlayerData.optin
    Player.Functions.SetPlayerData('optin', Player.PlayerData.optin)
end

-- Check if player is banned
---@param source Source
---@return boolean
---@return string? playerMessage
function functions.IsPlayerBanned(source)
    local plicense = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    local result = FetchBanEntity({
        license = plicense
    })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true, 'You have been banned from the server:\n' .. result.reason .. '\nYour ban expires ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        CreateThread(function()
            DeleteBanEntity({
                license = plicense
            })
        end)
    end
    return false
end

---@see client/functions.lua:functions.Notify
function functions.Notify(source, text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    local title, description
    if type(text) == "table" then
        title = text.text or 'Placeholder'
        description = text.caption or nil
    elseif subTitle then
        title = text
        description = subTitle
    else
        description = text
    end
    local position = notifyPosition or QBConfig.NotifyPosition

    TriggerClientEvent('ox_lib:notify', source, {
        id = title,
        title = title,
        description = description,
        duration = duration,
        type = notifyType,
        position = position,
        style = notifyStyle,
        icon = notifyIcon,
        iconColor = notifyIconColor
    })
end

---Add a new function to the Functions table of the player class
---Use-case:
-- [[
--     AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
--         functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
--             -- do something here
--         end)
--     end)
-- ]]
---@param ids number|number[] which players to add the method to. -1 for all players
---@param methodName string
---@param handler function
function functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

---Add a new field table of the player class
---Use-case:
--[[
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]
---@param ids number|number[] which players to add a new field to. -1 for all players
---@param fieldName string
---@param data any
function functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

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

functions.SetMethod = SetMethod
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

functions.SetField = SetField
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

functions.AddJob = AddJob
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

functions.AddJobs = AddJobs
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

functions.RemoveJob = RemoveJob
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

functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

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

functions.AddGang = AddGang
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

functions.AddGangs = AddGangs
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

functions.RemoveGang = RemoveGang
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

functions.UpdateGang = UpdateGang
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

functions.GetCoreVersion = GetCoreVersion
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


return functions