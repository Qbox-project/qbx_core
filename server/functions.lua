local functions = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

---@alias Identifier 'steam'|'license'|'license2'|'xbl'|'ip'|'discord'|'live'

---@param identifier Identifier
---@return integer source of the player with the matching identifier or 0 if no player found
function functions.GetSource(identifier)
    for src in pairs(QBX.Players) do
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
        return QBX.Players[source]
    else
        return QBX.Players[functions.GetSource(source --[[@as string]])]
    end
end

---@param citizenid string
---@return Player?
function functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(QBX.Players) do
        if QBX.Players[src].PlayerData.citizenid == citizenid then
            return QBX.Players[src]
        end
    end
end

---@param citizenid string
---@return Player?
function functions.GetOfflinePlayerByCitizenId(citizenid)
    return QBX.Player.GetOfflinePlayer(citizenid)
end

---@param number string
---@return Player?
function functions.GetPlayerByPhone(number)
    for src in pairs(QBX.Players) do
        if QBX.Players[src].PlayerData.charinfo.phone == number then
            return QBX.Players[src]
        end
    end
end

---Will return an array of QB Player class instances
---unlike the GetPlayers() wrapper which only returns IDs
---@return table<Source, Player>
function functions.GetQBPlayers()
    return QBX.Players
end

---Gets a list of all on duty players of a specified job and the number
---@param job string name
---@return integer
---@return Source[]
function functions.GetDutyCountJob(job)
    local players = {}
    local count = 0
    for src, player in pairs(QBX.Players) do
        if player.PlayerData.job.name == job then
            if player.PlayerData.job.onduty then
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
    for src, player in pairs(QBX.Players) do
        if player.PlayerData.job.type == type then
            if player.PlayerData.job.onduty then
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
    return QBX.Player_Buckets, QBX.Entity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
---@param source Source
---@param bucket integer
---@return boolean
function functions.SetPlayerBucket(source, bucket)
    if not (source or bucket) then return false end

    SetPlayerRoutingBucket(source --[[@as string]], bucket)
    QBX.Player_Buckets[source] = bucket
    return true
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@param entity integer
---@param bucket integer
---@return boolean
function functions.SetEntityBucket(entity, bucket)
    if not (entity or bucket) then return false end

    SetEntityRoutingBucket(entity, bucket)
    QBX.Entity_Buckets[entity] = bucket
    return true
end

-- Will return an array of all the player ids inside the current bucket
---@param bucket integer
---@return Source[]|boolean
function functions.GetPlayersInBucket(bucket)
    local curr_bucket_pool = {}
    if not (QBX.Player_Buckets or next(QBX.Player_Buckets)) then
        return false
    end

    for k, v in pairs(QBX.Player_Buckets) do
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
    if not (QBX.Entity_Buckets or next(QBX.Entity_Buckets)) then
        return false
    end

    for k, v in pairs(QBX.Entity_Buckets) do
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
    QBX.UsableItems[item] = data
end

---@param item string name
---@return unknown
function functions.CanUseItem(item)
    return QBX.UsableItems[item]
end

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans
---@param source Source
---@return boolean
function functions.IsWhitelisted(source)
    if not QBX.Config.Server.Whitelist then return true end
    if functions.HasPermission(source, QBX.Config.Server.WhitelistPermission) then return true end
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
        for _, v in pairs(QBX.Config.Server.Permissions) do
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
    for _, v in pairs (QBX.Config.Server.Permissions) do
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
    local player = functions.GetPlayer(source)
    return player.PlayerData.optin
end

---Opt in or out of admin reports
---@param source Source
function functions.ToggleOptin(source)
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    if not license or not functions.HasPermission(source, 'admin') then return end
    local player = functions.GetPlayer(source)
    player.PlayerData.optin = not player.PlayerData.optin
    player.Functions.SetPlayerData('optin', player.PlayerData.optin)
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
    local position = notifyPosition or QBX.Config.NotifyPosition

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
--         QBX.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
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
            for _, v in pairs(QBX.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not QBX.Players[ids] then return end

            QBX.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBX.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

---Add a new field table of the player class
---Use-case:
--[[
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        QBX.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]
---@param ids number|number[] which players to add a new field to. -1 for all players
---@param fieldName string
---@param data any
function functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBX.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not QBX.Players[ids] then return end

            QBX.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBX.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Add or change (a) method(s) in the QBX.Functions table
---@param methodName string
---@param handler function
---@return boolean success
---@return string message
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    QBX.Functions[methodName] = handler

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
    DropPlayer(playerId --[[@as string]], Lang:t('info.exploit_banned', {discord = QBX.Config.Server.Discord}))
    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)

return functions
