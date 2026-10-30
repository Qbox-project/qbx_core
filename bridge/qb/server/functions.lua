require 'server.functions'
local playerObj = require 'bridge.qb.server.player'
local logger = require 'modules.logger'
local loggingConfig = require 'config.server'.logging
local functions = {}

---@deprecated use the GetEntityCoords and GetEntityHeading natives directly
functions.GetCoords = function(entity)
    local coords = GetEntityCoords(entity)
    return vec4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

---@deprecated use the native GetPlayerIdentifierByType
---@param source Source
---@param idType? string defaults to license
---@return string?
functions.GetIdentifier = function(source, idType)
    return GetPlayerIdentifierByType(source --[[@as string]], idType or 'license')
end

---@return Source[]
function functions.GetPlayers()
    local sources = {}
    local players = exports.qbx_core:GetQBPlayers()
    for k in pairs(players) do
        sources[#sources+1] = k
    end

    return sources
end

---@param source? Source
---@param coords? vector3 | vector4 | { x: number, y: number, z: number }
---@return vector3 origin
---@return integer ped
local function getSearchOrigin(source, coords)
    local ped = source and GetPlayerPed(source --[[@as string]]) or 0
    if coords then return vec3(coords.x, coords.y, coords.z), ped end
    return GetEntityCoords(ped), ped
end

---@param entities integer[]
---@param origin vector3
---@param ignore? integer
---@return integer closestEntity -1 if none found
---@return number closestDistance -1 if none found
local function getClosestEntity(entities, origin, ignore)
    local closestEntity, closestDistance = -1, -1
    for i = 1, #entities do
        local entity = entities[i]
        if entity ~= ignore then
            local distance = #(GetEntityCoords(entity) - origin)
            if closestDistance == -1 or distance < closestDistance then
                closestEntity, closestDistance = entity, distance
            end
        end
    end
    return closestEntity, closestDistance
end

---@deprecated use lib.getClosestPlayer from ox_lib
---@param source? Source excluded from the search; its ped's coords are used when coords is nil
---@param coords? vector3 | vector4 | { x: number, y: number, z: number }
---@return integer closestPlayer -1 if none found
---@return number closestDistance -1 if none found
function functions.GetClosestPlayer(source, coords)
    local origin, ped = getSearchOrigin(source, coords)
    local peds, owners = {}, {}
    for _, playerId in ipairs(GetPlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if playerPed ~= 0 then
            peds[#peds + 1] = playerPed
            owners[playerPed] = tonumber(playerId)
        end
    end
    local closestPed, closestDistance = getClosestEntity(peds, origin, ped)
    return owners[closestPed] or -1, closestDistance
end

---@deprecated use lib.getClosestPed from ox_lib
---@param source? Source
---@param coords? vector3 | vector4 | { x: number, y: number, z: number }
---@return integer closestPed -1 if none found
---@return number closestDistance -1 if none found
function functions.GetClosestPed(source, coords)
    local origin, ped = getSearchOrigin(source, coords)
    return getClosestEntity(GetAllPeds(), origin, ped)
end

---@deprecated use lib.getClosestVehicle from ox_lib
---@param source? Source
---@param coords? vector3 | vector4 | { x: number, y: number, z: number }
---@return integer closestVehicle -1 if none found
---@return number closestDistance -1 if none found
function functions.GetClosestVehicle(source, coords)
    local origin = getSearchOrigin(source, coords)
    return getClosestEntity(GetAllVehicles(), origin)
end

---@deprecated use lib.getClosestObject from ox_lib
---@param source? Source
---@param coords? vector3 | vector4 | { x: number, y: number, z: number }
---@return integer closestObject -1 if none found
---@return number closestDistance -1 if none found
function functions.GetClosestObject(source, coords)
    local origin = getSearchOrigin(source, coords)
    return getClosestEntity(GetAllObjects(), origin)
end

local maxConcurrentSpawns <const> = 20
local spawnTimeoutMs <const> = 10000
---@type table<Source, integer>
local activeSpawns = {}

---@param source Source
local function releaseSpawn(source)
    local count = (activeSpawns[source] or 1) - 1
    activeSpawns[source] = count > 0 and count or nil
end

---@deprecated use qbx.spawnVehicle from modules/lib.lua
---@return number?
function functions.SpawnVehicle(source, model, coords, warp)
    if (activeSpawns[source] or 0) >= maxConcurrentSpawns then return end
    activeSpawns[source] = (activeSpawns[source] or 0) + 1

    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local heading = coords.w and coords.w or 0.0
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)

    local spawnTimeout = GetGameTimer() + spawnTimeoutMs
    while not DoesEntityExist(veh) and GetGameTimer() < spawnTimeout do Wait(0) end
    if not DoesEntityExist(veh) then
        releaseSpawn(source)
        return
    end

    if warp then
        local warpTimeout = GetGameTimer() + spawnTimeoutMs
        while GetVehiclePedIsIn(ped, false) ~= veh and GetGameTimer() < warpTimeout do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end

    local ownerTimeout = GetGameTimer() + spawnTimeoutMs
    while NetworkGetEntityOwner(veh) ~= source and GetGameTimer() < ownerTimeout do Wait(0) end

    releaseSpawn(source)
    return veh
end

---@deprecated use qbx.spawnVehicle from modules/lib.lua
function functions.CreateVehicle(source, model, _, coords, warp)
    model = type(model) == 'string' and joaat(model) or (model --[[@as integer]])
    local ped = GetPlayerPed(source)

    local netId = qbx.spawnVehicle({
        model = model,
        spawnSource = coords or ped,
        warp = warp and ped or nil,
    })

    return NetworkGetEntityFromNetworkId(netId)
end

---@deprecated use qbx.spawnVehicle from modules/lib.lua
---@return integer vehicle
function functions.CreateAutomobile(source, model, coords, warp)
    return functions.CreateVehicle(source, model, nil, coords, warp)
end

---@deprecated No replacement. See https://coxdocs.dev/ox_inventory/Functions/Client#useitem
---@param source Source
---@param item string name
function functions.UseItem(source, item) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

local discordLink = GetConvar('qbx:discordlink', 'discord.gg/qbox')
---@deprecated use setKickReason or deferrals for connecting players, and the DropPlayer native directly otherwise
functions.Kick = function(source, reason, setKickReason, deferrals)
    reason = ('\n %s \n 🔸 Check our Discord for further information: %s'):format(reason, discordLink)
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source --[[@as string]], reason)
        end
    end)
end

---@deprecated check for license usage directly yourself
functions.IsLicenseInUse = function(license)
    local players = GetPlayers()

    for _, player in pairs(players) do
        local plyLicense2 = GetPlayerIdentifierByType(player --[[@as string]], 'license2')
        local plyLicense = GetPlayerIdentifierByType(player --[[@as string]], 'license')
        if plyLicense2 == license or plyLicense == license then
            return true
        end
    end

    return false
end

-- Utility functions

---@deprecated use exports.ox_inventory:GetItemCount or Search
---@param source Source
---@param items string | string[] | table<string, number>
---@param amount? number
---@return boolean
functions.HasItem = function(source, items, amount)
    local player = GetPlayer(source)
    return player and player.Functions.HasItem(items, amount) or false
end

---@deprecated use qbx.getVehiclePlate from modules/lib.lua
functions.GetPlate = qbx.getVehiclePlate

---Items added or changed through the bridge at runtime, resent to players who load in later
---@type table<string, table>
local runtimeItems = {}

---@param itemName string
---@param item table
---@return string
local function toOxItemDefinition(itemName, item)
    return ('[%q] = { label = %q, weight = %s, stack = %s, close = %s, description = %q },'):format(
        itemName,
        tostring(item.label or itemName),
        tonumber(item.weight) or 0,
        tostring(not item.unique),
        tostring(item.shouldClose ~= false),
        tostring(item.description or '')
    )
end

---@param action string
---@param itemName string
---@param item table
local function warnItemNotInInventory(action, itemName, item)
    if exports.ox_inventory:Items(itemName) then return end
    lib.print.warn(("%s used deprecated %s for '%s'. Only QBCore.Shared.Items was changed: ox_inventory cannot register items at runtime, so the item cannot be given or used until it is defined in ox_inventory/data/items.lua, e.g.\n%s"):format(
        GetInvokingResource() or 'unknown resource', action, itemName, toOxItemDefinition(itemName, item)))
end

---@param itemName string
---@param item table
local function setSharedItem(itemName, item)
    item.name = item.name or itemName
    qbCoreCompat.Shared.Items[itemName] = item
    runtimeItems[itemName] = item
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    if not next(runtimeItems) then return end
    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', player.PlayerData.source, 'Items', runtimeItems)
end)

---@deprecated ox_inventory cannot register items at runtime. Define the item in ox_inventory/data/items.lua instead.
---@param itemName string
---@param item table
---@return boolean success
---@return string message
function functions.AddItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if qbCoreCompat.Shared.Items[itemName] then
        return false, 'item_exists'
    end

    if type(item) ~= 'table' then
        return false, 'invalid_item'
    end

    setSharedItem(itemName, item)
    warnItemNotInInventory('AddItem', itemName, item)

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

---@deprecated ox_inventory cannot update items at runtime. Edit the item in ox_inventory/data/items.lua instead.
---@param itemName string
---@param item table
---@return boolean success
---@return string message
function functions.UpdateItem(itemName, item)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if not qbCoreCompat.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end

    if type(item) ~= 'table' then
        return false, 'invalid_item'
    end

    setSharedItem(itemName, item)
    lib.print.warn(("%s used deprecated UpdateItem for '%s'. Only QBCore.Shared.Items was changed; the ox_inventory definition is unchanged."):format(GetInvokingResource() or 'unknown resource', itemName))

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

---@deprecated ox_inventory cannot register items at runtime. Define the items in ox_inventory/data/items.lua instead.
---@param items table<string, table>
---@return boolean success
---@return string message
---@return table? errorItem
function functions.AddItems(items)
    if type(items) ~= 'table' then
        return false, 'invalid_item_name'
    end

    for key, value in pairs(items) do
        if type(key) ~= 'string' then
            return false, 'invalid_item_name', value
        end

        if qbCoreCompat.Shared.Items[key] then
            return false, 'item_exists', value
        end

        if type(value) ~= 'table' then
            return false, 'invalid_item', value
        end
    end

    for key, value in pairs(items) do
        setSharedItem(key, value)
        warnItemNotInInventory('AddItems', key, value)
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

---@deprecated ox_inventory cannot remove items at runtime. Remove the item from ox_inventory/data/items.lua instead.
---@param itemName string
---@return boolean success
---@return string message
function functions.RemoveItem(itemName)
    if type(itemName) ~= 'string' then
        return false, 'invalid_item_name'
    end

    if not qbCoreCompat.Shared.Items[itemName] then
        return false, 'item_not_exists'
    end

    qbCoreCompat.Shared.Items[itemName] = nil
    runtimeItems[itemName] = nil
    if exports.ox_inventory:Items(itemName) then
        lib.print.warn(("%s used deprecated RemoveItem for '%s'. Only QBCore.Shared.Items was changed; ox_inventory still defines the item."):format(GetInvokingResource() or 'unknown resource', itemName))
    end

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, 'success'
end

-- Single add job function which should only be used if you planning on adding a single job
---@deprecated use export CreateJobs
---@param jobName string
---@param job Job
---@return boolean success
---@return string message
local function addJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if GetJob(jobName) then
        return false, 'job_exists'
    end

    local success, message = CreateJobs({[jobName] = job})
    if not success then return false, message end
    return true, 'success'
end

functions.AddJob = addJob

-- Multiple Add Jobs
---@deprecated call export CreateJobs
---@param jobs table<string, Job>
---@return boolean success
---@return string message
---@return Job? errorJob job causing the error message. Only present if success is false.
local function addJobs(jobs)
    for key in pairs(jobs) do
        if type(key) ~= 'string' then
            return false, 'invalid_job_name', jobs[key]
        end

        if GetJob(key) then
            return false, 'job_exists', jobs[key]
        end
    end

    local success, message = CreateJobs(jobs)
    if not success then return false, message end
    return true, 'success'
end

functions.AddJobs = addJobs

-- Single Update Job
---@deprecated call CreateJobs
---@param jobName string
---@param job Job
---@return boolean success
---@return string message
local function updateJob(jobName, job)
    if type(jobName) ~= 'string' then
        return false, 'invalid_job_name'
    end

    if not GetJob(jobName) then
        return false, 'job_not_exists'
    end

    local success, message = CreateJobs({[jobName] = job})
    if not success then return false, message end
    return true, 'success'
end

functions.UpdateJob = updateJob

-- Single Add Gang
---@deprecated call export CreateGangs
---@param gangName string
---@param gang Gang
---@return boolean success
---@return string message
local function addGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if GetGang(gangName) then
        return false, 'gang_exists'
    end

    local success, message = CreateGangs({[gangName] = gang})
    if not success then return false, message end
    return true, 'success'
end

functions.AddGang = addGang

-- Single Update Gang
---@deprecated call export CreateGangs
---@param gangName string
---@param gang Gang
---@return boolean success
---@return string message
local function updateGang(gangName, gang)
    if type(gangName) ~= 'string' then
        return false, 'invalid_gang_name'
    end

    if not GetGang(gangName) then
        return false, 'gang_not_exists'
    end

    local success, message = CreateGangs({[gangName] = gang})
    if not success then return false, message end
    return true, 'success'
end

functions.UpdateGang = updateGang

-- Multiple Add Gangs
---@deprecated call export CreateGangs
---@param gangs table<string, Gang>
---@return boolean success
---@return string message
---@return Gang? errorGang present if success is false. Gang that caused the error message.
local function addGangs(gangs)
    for key in pairs(gangs) do
        if type(key) ~= 'string' then
            return false, 'invalid_gang_name', gangs[key]
        end

        if GetGang(key) then
            return false, 'gang_exists', gangs[key]
        end
    end

    local success, message = CreateGangs(gangs)
    if not success then return false, message end
    return true, 'success'
end

functions.AddGangs = addGangs

---@deprecated use export RemoveJob
---@param jobName string
---@return boolean success
---@return string message
functions.RemoveJob = function(jobName)
    return RemoveJob(jobName)
end

---@deprecated use export RemoveGang
---@param gangName string
---@return boolean success
---@return string message
functions.RemoveGang = function(gangName)
    return RemoveGang(gangName)
end

---Add a new function to the Functions table of the player class
---Use-case:
-- [[
--     AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
--         functions.AddPlayerMethod(Player.PlayerData.source, 'functionName', function(oneArg, orMore)
--             -- do something here
--         end)
--     end)
-- ]]
---@deprecated
---@param ids number|number[] which players to add the method to. -1 for all players
---@param methodName string
---@param handler function
function functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(QBX.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not QBX.Players[ids] then return end
            QBX.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            ---@diagnostic disable-next-line: deprecated
            functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

---Add a new field table of the player class
---Use-case:
--[[
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        functions.AddPlayerField(Player.PlayerData.source, 'fieldName', 'fieldData')
    end)
]]
---@deprecated
---@param ids number|number[] which players to add a new field to. -1 for all players
---@param fieldName string
---@param data any
function functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(QBX.Players) do
                ---@diagnostic disable-next-line: undefined-field
                v.Functions.AddField(fieldName, data)
            end
        else
            if not QBX.Players[ids] then return end

            ---@diagnostic disable-next-line: undefined-field
            QBX.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            ---@diagnostic disable-next-line: deprecated
            functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Add or change (a) method(s) in the Functions table
---@deprecated
---@param methodName string
---@param handler function
---@return boolean success
---@return string message
function functions.SetMethod(methodName, handler)
    if type(methodName) ~= 'string' then
        return false, 'invalid_method_name'
    end

    functions[methodName] = handler

    TriggerEvent('QBCore:Server:UpdateObject')

    return true, 'success'
end

-- Add or change (a) field(s) in the QBCore table
---@deprecated
---@param fieldName string
---@param data any
---@return boolean success
---@return string message
local function SetField(fieldName, data)
    if type(fieldName) ~= 'string' then
        return false, 'invalid_field_name'
    end

    qbCoreCompat[fieldName] = data

    TriggerEvent('QBCore:Server:UpdateObject')

    return true, 'success'
end

functions.SetField = SetField
exports('SetField', SetField)

---@param identifier Identifier
---@return integer source of the player with the matching identifier or 0 if no player found
function functions.GetSource(identifier)
    return exports.qbx_core:GetSource(identifier)
end

---@param source Source|string source or identifier of the player
---@return Player?
function functions.GetPlayer(source)
    return AddDeprecatedFunctions(exports.qbx_core:GetPlayer(source))
end

---@param citizenid string
---@return Player?
function functions.GetPlayerByCitizenId(citizenid)
    return AddDeprecatedFunctions(exports.qbx_core:GetPlayerByCitizenId(citizenid))
end

---@param citizenid string
---@return Player?
function functions.GetOfflinePlayerByCitizenId(citizenid)
    return AddDeprecatedFunctions(exports.qbx_core:GetOfflinePlayer(citizenid))
end

---@param number string
---@return Player?
function functions.GetPlayerByPhone(number)
    return AddDeprecatedFunctions(exports.qbx_core:GetPlayerByPhone(number))
end

---Online player first, otherwise their most recently played character
---@param license string
---@return Player?
function functions.GetPlayerByLicense(license)
    return playerObj.GetPlayerByLicense(license)
end

---@param property string charinfo key
---@param value any
---@return Player?
function functions.GetPlayerByCharInfo(property, value)
    if value == nil then return end
    for _, player in pairs(QBX.Players) do
        if player.PlayerData.charinfo[property] == value then
            return AddDeprecatedFunctions(player)
        end
    end
end

---@param account string
---@return Player?
function functions.GetPlayerByAccount(account)
    return functions.GetPlayerByCharInfo('account', account)
end

---Will return an array of QB Player class instances
---unlike the GetPlayers() wrapper which only returns IDs
---@return table<Source, Player>
function functions.GetQBPlayers()
    local players = exports.qbx_core:GetQBPlayers()
    local deprecatedPlayers = {}
    for k, player in pairs(players) do
        deprecatedPlayers[k] = AddDeprecatedFunctions(player)
    end
    return deprecatedPlayers
end

---@deprecated use exports.qbx_core:GetDutyCountJob or GetDutyCountType
---@param job string job name or job type
---@param checkOnDuty? boolean only include players on duty
---@return Source[]
---@return integer
function functions.GetPlayersByJob(job, checkOnDuty)
    local players = {}
    for source, player in pairs(QBX.Players) do
        local playerJob = player.PlayerData.job
        if (playerJob.name == job or playerJob.type == job) and (not checkOnDuty or playerJob.onduty) then
            players[#players + 1] = source
        end
    end
    return players, #players
end

---Gets a list of all on duty players of a specified job and the number
---@param job string name
---@return integer
---@return Source[]
function functions.GetDutyCount(job)
    return exports.qbx_core:GetDutyCountJob(job)
end

---Gets a list of all on duty players of a specified job and the number
---@param job string name
---@return Source[]
---@return integer
function functions.GetPlayersOnDuty(job)
    local count, sources = exports.qbx_core:GetDutyCountJob(job)
    return sources, count
end

-- Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
---@return table
---@return table
function functions.GetBucketObjects()
    return exports.qbx_core:GetBucketObjects()
end

-- Will set the provided player id / source into the provided bucket id
---@param source Source
---@param bucket integer
---@return boolean
function functions.SetPlayerBucket(source, bucket)
    return exports.qbx_core:SetPlayerBucket(source, bucket)
end

-- Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@param entity integer
---@param bucket integer
---@return boolean
function functions.SetEntityBucket(entity, bucket)
    return exports.qbx_core:SetEntityBucket(entity, bucket)
end

-- Will return an array of all the player ids inside the current bucket
---@param bucket integer
---@return Source[]|boolean
function functions.GetPlayersInBucket(bucket)
    return exports.qbx_core:GetPlayersInBucket(bucket)
end

-- Will return an array of all the entities inside the current bucket (not for player entities, use GetPlayersInBucket for that)
---@param bucket integer
---@return boolean | integer[]
function functions.GetEntitiesInBucket(bucket)
    return exports.qbx_core:GetEntitiesInBucket(bucket)
end

-- Items
---@param item string name
---@param data fun(source: Source, item: unknown)
function functions.CreateUseableItem(item, data)
    exports.qbx_core:CreateUseableItem(item, data)
    local sharedItem = qbCoreCompat.Shared.Items[item]
    if sharedItem then sharedItem.useable = true end
end

---@param item string name
---@return unknown
function functions.CanUseItem(item)
    return exports.qbx_core:CanUseItem(item)
end

-- Check if player is whitelisted, kept like this for backwards compatibility or future plans
---@param source Source
---@return boolean
function functions.IsWhitelisted(source)
    return exports.qbx_core:IsWhitelisted(source)
end

---@param source Source
---@param permission string
function functions.AddPermission(source, permission)
    exports.qbx_core:AddPermission(source, permission)
end

---@param source Source
---@param permission string
function functions.RemovePermission(source, permission)
    exports.qbx_core:RemovePermission(source, permission)
end

-- Checking for Permission Level
---@param source Source
---@param permission string|string[]
---@return boolean
function functions.HasPermission(source, permission)
    return exports.qbx_core:HasPermission(source, permission)
end

---@param source Source
---@return table<string, boolean>
function functions.GetPermission(source)
    return exports.qbx_core:GetPermission(source)
end

-- Opt in or out of admin reports
---@param source Source
---@return boolean
function functions.IsOptin(source)
    return exports.qbx_core:IsOptin(source)
end

---Opt in or out of admin reports
---@param source Source
function functions.ToggleOptin(source)
    exports.qbx_core:ToggleOptin(source)
end

-- Check if player is banned
---@param source Source
---@return boolean
---@return string? playerMessage
function functions.IsPlayerBanned(source)
    return exports.qbx_core:IsPlayerBanned(source)
end

---@see client/functions.lua:functions.Notify
function functions.Notify(source, text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    exports.qbx_core:Notify(source, text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
end

---@param InvokingResource string
---@return string version
function functions.GetCoreVersion(InvokingResource)
    return exports.qbx_core:GetCoreVersion(InvokingResource)
end

---@deprecated use exports.qbx_core:GenerateUniqueIdentifier('AccountNumber')
---@return string
function functions.CreateAccountNumber()
    return GenerateUniqueIdentifier('AccountNumber')
end

---@deprecated use exports.qbx_core:GenerateUniqueIdentifier('PhoneNumber')
---@return string
function functions.CreatePhoneNumber()
    return GenerateUniqueIdentifier('PhoneNumber')
end

---@deprecated use parameterized queries instead
---@param source Source
---@param data any
---@param pattern string
---@return boolean matches whether the whole value matches pattern
function functions.PrepForSQL(source, data, pattern)
    data = tostring(data)
    local result = data:match(pattern)
    if result and #result == #data then return true end

    local player = GetPlayer(source)
    logger.log({
        source = GetInvokingResource() or cache.resource,
        webhook = loggingConfig.webhook['anticheat'],
        event = 'SQL Exploit Attempted',
        color = 'red',
        tags = loggingConfig.role,
        message = ('%s attempted to exploit SQL!'):format(player and player.PlayerData.license or GetPlayerName(source --[[@as string]]) or source),
    })
    return false
end

---@deprecated
---@return { exists: boolean, database: string }
function functions.GetDatabaseInfo()
    local details = { exists = false, database = '' }
    local connectionString = GetConvar('mysql_connection_string', '')

    if connectionString == '' then
        return details
    end

    if connectionString:find('mysql://', 1, true) then
        local hostAndPath = connectionString:match('^mysql://.*@(.*)$') or connectionString:sub(9)
        local database = hostAndPath:match('^[^/]*/([^%?]+)')
        details.database = database or ''
        details.exists = database ~= nil
        return details
    end

    for _, option in ipairs({ string.strsplit(';', connectionString) }) do
        local key, value = option:match('^%s*([^=]+)=(.*)$')
        if key and key:lower() == 'database' then
            details.database = value
            details.exists = true
            return details
        end
    end

    return details
end

return functions
