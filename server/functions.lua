QBCore.Functions = {}
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = QBCore.Functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

---@param entity number
---@return vector4
function QBCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return vec4(coords.x, coords.y, coords.z, heading)
end

---@alias Identifier 'steam'|'license'|'license2'|'xbl'|'ip'|'discord'|'live'

---@param source Source
---@param idtype Identifier
---@return string?
function QBCore.Functions.GetIdentifier(source, idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
end

---@param identifier string
---@return integer source of the player with the matching identifier or 0 if no player found
function QBCore.Functions.GetSource(identifier)
    for src, _ in pairs(QBCore.Players) do
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
        return QBCore.Players[QBCore.Functions.GetSource(source)]
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

---@return Source[] sources
function QBCore.Functions.GetPlayers()
    local sources = {}
    for k in pairs(QBCore.Players) do
        sources[#sources+1] = k
    end
    return sources
end

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

    SetPlayerRoutingBucket(source, bucket)
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
---@return integer[]|boolean
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
    print(string.format("%s invoked deprecated server function QBCore.Functions.SpawnVehicle. Use QBCore.Functions.CreateVehicle instead.", GetInvokingResource()))
    return QBCore.Functions.CreateVehicle(source, model, coords, warp)
end

-- Server side vehicle creation
-- The CreateVehicleServerSetter native uses only the server to create a vehicle instead of using the client as well
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native but use a while loop before that to check if the vehicle exists first like this
--[[
    ```lua
        while not DoesEntityExist(NetToVeh(veh)) do
            Wait(0)
        end
    ```
]]
-- If you don't use the above on the client, it will return 0 as the vehicle from the netid and 0 means no vehicle found because it doesn't exist so fast on the client
-- Deletes vehicle ped is in before spawning a new one.
---@param source number
---@param model string|number
---@param coords? vector4 default to player's position
---@param warp? boolean
---@return number? netId
function QBCore.Functions.CreateVehicle(source, model, coords, warp)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    if not CreateVehicleServerSetter then
        error('^1CreateVehicleServerSetter is not available on your artifact, please use artifact 5904 or above to be able to use this^0')
        return
    end
    local ped = GetPlayerPed(source)
    local currentVeh = GetVehiclePedIsIn(ped, false)
    if currentVeh ~= 0 then DeleteEntity(currentVeh) end

    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do Wait(0) end
    local vehicleType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)
    local veh = CreateVehicleServerSetter(model, vehicleType, coords.x, coords.y, coords.z, coords.w)
    Wait(0)

    if warp then SetPedIntoVehicle(ped, veh, -1) end
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, QBCore.Functions.GetPlate(veh))
    Entity(veh).state:set('initVehicle', true, true)
    return NetworkGetNetworkIdFromEntity(veh)
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

-- Kick Player
---@param source Source
---@param reason string
---@param setKickReason? fun(reason: string)
---@param deferrals? table
function QBCore.Functions.Kick(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. QBCore.Config.Server.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        for _ = 0, 4 do
            while true do
                if source then
                    if GetPlayerPing(source) >= 0 then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end

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
    if not IsPlayerAceAllowed(source, permission) then
        ExecuteCommand(('add_principal player.%s qbox.%s'):format(source, permission))
        QBCore.Commands.Refresh(source)
        TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
        TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
    end
end

---@param source Source
---@param permission string
function QBCore.Functions.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source, permission) then
            ExecuteCommand(('remove_principal player.%s qbox.%s'):format(source, permission))
            QBCore.Commands.Refresh(source)
            TriggerClientEvent('QBCore:Client:OnPermissionUpdate', source)
            TriggerEvent('QBCore:Server:OnPermissionUpdate', source)
        end
    else
        local hasUpdated = false
        for _, v in pairs(QBCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source, v) then
                ExecuteCommand(('remove_principal player.%s qbox.%s'):format(source, v))
                QBCore.Commands.Refresh(source)
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
        if IsPlayerAceAllowed(source, permission) then return true end
    elseif type(permission) == "table" then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source, permLevel) then return true end
        end
    end

    return false
end

---@param source Source
---@return table<string, boolean>
function QBCore.Functions.GetPermission(source)
    local src = source
    local perms = {}
    for _, v in pairs (QBCore.Config.Server.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end

-- Opt in or out of admin reports
---@param source Source
---@return boolean
function QBCore.Functions.IsOptin(source)
    local license = QBCore.Functions.GetIdentifier(source, 'license2') or QBCore.Functions.GetIdentifier(source, 'license')
    if not license or not QBCore.Functions.HasPermission(source, 'admin') then return false end
    local Player = QBCore.Functions.GetPlayer(source)
    return Player.PlayerData.optin
end

function QBCore.Functions.ToggleOptin(source)
    local license = QBCore.Functions.GetIdentifier(source, 'license2') or QBCore.Functions.GetIdentifier(source, 'license')
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
    local plicense = QBCore.Functions.GetIdentifier(source, 'license2') or QBCore.Functions.GetIdentifier(source, 'license')
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

-- Check for duplicate license
---@param license string
---@return boolean
function QBCore.Functions.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license2') or string.find(id, 'license') then
                if id == license then
                    return true
                end
            end
        end
    end
    return false
end

-- Utility functions
---@param source Source
---@param items unknown[]
---@param amount number
---@return boolean
function QBCore.Functions.HasItem(source, items, amount)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:HasItem(source, items, amount)
end

---@see client/functions.lua:QBCore.Functions.NotifyV2
function QBCore.Functions.NotifyV2(source, props)
    TriggerClientEvent('QBCore:NotifyV2', source, props)
end

---@deprecated use QBCore.Functions.NotifyV2 instead.
---@see client/functions.lua:QBCore.Functions.Notify
function QBCore.Functions.Notify(source, text, notifyType, duration)
    TriggerClientEvent('QBCore:Notify', source, text, notifyType, duration)
end

---@param vehicle number
---@return string?
function QBCore.Functions.GetPlate(vehicle)
    if not vehicle or vehicle == 0 then return end
    return QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
end
