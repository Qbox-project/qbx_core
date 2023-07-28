QBCore.Functions = {}
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = QBCore.Functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

---@deprecated
QBCore.Functions.GetCoords = GetCoordsFromEntity

---@alias Identifier 'steam'|'license'|'license2'|'xbl'|'ip'|'discord'|'live'

---@deprecated use the native GetPlayerIdentifierByType?
QBCore.Functions.GetIdentifier = GetPlayerIdentifierByType

---@param identifier string
---@return integer source of the player with the matching identifier or 0 if no player found
function QBCore.Functions.GetSource(identifier)
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
function QBCore.Functions.GetPlayer(source)
    if type(source) == 'number' then
        return QBCore.Players[source]
    else
        return QBCore.Players[QBCore.Functions.GetSource(source --[[@as string]])]
    end
end

---@param citizenid string
---@return Player?
function QBCore.Functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(QBCore.Players) do
        if QBCore.Players[src].PlayerData.citizenid == citizenid then
            return QBCore.Players[src]
        end
    end
end

---@param citizenid string
---@return Player?
function QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    return QBCore.Player.GetOfflinePlayer(citizenid)
end

---@param number string
---@return Player?
function QBCore.Functions.GetPlayerByPhone(number)
    for src in pairs(QBCore.Players) do
        if QBCore.Players[src].PlayerData.charinfo.phone == number then
            return QBCore.Players[src]
        end
    end
end

---@deprecated use the native GetPlayers instead
QBCore.Functions.GetPlayers = GetPlayers

---Will return an array of QB Player class instances
---unlike the GetPlayers() wrapper which only returns IDs
---@return table<Source, Player>
function QBCore.Functions.GetQBPlayers()
    return QBCore.Players
end

---Gets a list of all on duty players of a specified job and the number
---@param job string name
---@return integer
---@return Source[]
function QBCore.Functions.GetDutyCountJob(job)
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
function QBCore.Functions.GetDutyCountType(type)
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
function QBCore.Functions.GetBucketObjects()
    return QBCore.Player_Buckets, QBCore.Entity_Buckets
end

-- Will set the provided player id / source into the provided bucket id
---@param source Source
---@param bucket integer
---@return boolean
function QBCore.Functions.SetPlayerBucket(source, bucket)
    if not (source or bucket) then return false end

    SetPlayerRoutingBucket(source --[[@as string]], bucket)
    QBCore.Player_Buckets[source] = bucket
    return true
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@param entity integer
---@param bucket integer
---@return boolean
function QBCore.Functions.SetEntityBucket(entity, bucket)
    if not (entity or bucket) then return false end

    SetEntityRoutingBucket(entity, bucket)
    QBCore.Entity_Buckets[entity] = bucket
    return true
end

-- Will return an array of all the player ids inside the current bucket
---@param bucket integer
---@return Source[]|boolean
function QBCore.Functions.GetPlayersInBucket(bucket)
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
function QBCore.Functions.GetEntitiesInBucket(bucket)
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

---@deprecated Use QBCore.Functions.CreateVehicle instead.
function QBCore.Functions.SpawnVehicle(source, model, coords, warp)
    return SpawnVehicle(source, model, coords, warp)
end

---@deprecated use SpawnVehicle from imports/utils.lua
QBCore.Functions.CreateVehicle = SpawnVehicle

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
function QBCore.Functions.TriggerClientCallback(name, source, cb, ...)
    QBCore.ClientCallbacks[name] = cb
    TriggerClientEvent('QBCore:Client:TriggerClientCallback', source, name, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
function QBCore.Functions.CreateCallback(name, cb)
    QBCore.ServerCallbacks[name] = cb
end

---@deprecated call a function instead
function QBCore.Functions.TriggerCallback(name, source, cb, ...)
    if not QBCore.ServerCallbacks[name] then return end
    QBCore.ServerCallbacks[name](source, cb, ...)
end

-- Items
---@param item string name
---@param data fun(source: Source, item: unknown)
function QBCore.Functions.CreateUseableItem(item, data)
    QBCore.UsableItems[item] = data
end

---@param item string name
---@return unknown
function QBCore.Functions.CanUseItem(item)
    return QBCore.UsableItems[item]
end

---@param source Source
---@param item string name
function QBCore.Functions.UseItem(source, item)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:UseItem(source, item)
end

---@deprecated use KickWithReason from imports/utils.lua
QBCore.Functions.Kick = KickWithReason

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans
---@param source Source
---@return boolean
function QBCore.Functions.IsWhitelisted(source)
    if not QBCore.Config.Server.Whitelist then return true end
    if QBCore.Functions.HasPermission(source, QBCore.Config.Server.WhitelistPermission) then return true end
    return false
end

-- Setting & Removing Permissions

---@param source Source
---@param permission string
function QBCore.Functions.AddPermission(source, permission)
    if not IsPlayerAceAllowed(source --[[@as string]], permission) then
        ExecuteCommand(('add_principal player.%s group.%s'):format(source, permission))
        ExecuteCommand(('add_ace player.%s group.%s allow'):format(source, permission))
        TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
        TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
    end
end

---@param source Source
---@param permission string
function QBCore.Functions.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source --[[@as string]], permission) then
            ExecuteCommand(('remove_principal player.%s group.%s'):format(source, permission))
            ExecuteCommand(('remove_ace player.%s group.%s allow'):format(source, permission))
            TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
            TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
        end
    else
        local hasUpdated = false
        for _, v in pairs(QBCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source --[[@as string]], v) then
                ExecuteCommand(('remove_principal player.%s group.%s'):format(source, v))
                ExecuteCommand(('remove_ace player.%s group.%s allow'):format(source, v))
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
---@param permission string
---@return boolean
function QBCore.Functions.HasPermission(source, permission)
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
function QBCore.Functions.GetPermission(source)
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
function QBCore.Functions.IsOptin(source)
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    if not license or not QBCore.Functions.HasPermission(source, 'admin') then return false end
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.optin
end

---Opt in or out of admin reports
---@param source Source
function QBCore.Functions.ToggleOptin(source)
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
    if not license or not QBCore.Functions.HasPermission(source, 'admin') then return end
    local Player = QBCore.Functions.GetPlayer(source)
    Player.PlayerData.optin = not Player.PlayerData.optin
    Player.Functions.SetPlayerData('optin', Player.PlayerData.optin)
end

-- Check if player is banned
---@param source Source
---@return boolean
---@return string? playerMessage
function QBCore.Functions.IsPlayerBanned(source)
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

---@deprecated use IsLicenseInUse from imports/utils.lua
QBCore.Functions.IsLicenseInUse = IsLicenseInUse

-- Utility functions

---@deprecated use HasItem from imports/utils.lua
---@param source Source
---@param items unknown[]
---@param amount number
---@return boolean
function QBCore.Functions.HasItem(source, items, amount)
    if GetResourceState('qb-inventory') == 'missing' then return false end
    return exports['qb-inventory']:HasItem(source, items, amount)
end

---@see client/functions.lua:QBCore.Functions.Notify
function QBCore.Functions.Notify(source, text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    local title, description
    if type(text) == "table" then
        title = text.text or 'Placeholder'
        description = text.caption or nil
    else
        title = text
        description = subTitle
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

---@deprecated use GetPlate from imports/utils.lua
QBCore.Functions.GetPlate = GetPlate
