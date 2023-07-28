-- Event Handler

local usedLicenses = {}

---@param message string
AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerJoining', function()
    if not QBConfig.Server.CheckDuplicateLicense then return end
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    if not license then return end
    if usedLicenses[license] then
        Wait(0) -- mandatory wait for the drop reason to show up
        DropPlayer(src, Lang:t('error.duplicate_license'))
    else
        usedLicenses[license] = true
    end
end)

---@param reason string
AddEventHandler('playerDropped', function(reason)
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    if license then usedLicenses[license] = nil end
    if not QBCore.Players[src] then return end
    GlobalState.PlayerCount -= 1
    local Player = QBCore.Players[src]
    TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' ..'\n **Reason:** ' .. reason)
    Player.Functions.Save()
    QBCore.Player_Buckets[Player.PlayerData.license] = nil
    QBCore.Players[src] = nil
end)

---@class Deferrals https://docs.fivem.net/docs/scripting-reference/events/list/playerConnecting/#deferring-connections
---@field defer fun() initialize deferrals for the current resource. Required to wait at least 1 tick before calling other deferrals methods.
---@field update fun(message: string) sends a progress message to the connecting client
---@field presentCard fun(card: unknown|string, cb?: fun(data: unknown, rawData: string)) send an adaptive card to the client https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/getting-started and capture user input via callback.
---@field done fun(failureReason?: string) finalizes deferrals. If failureReason is present, user will be refused connection and shown reason. Need to wait 1 tick after calling other deferral methods before calling done.

-- Player Connecting
---@param name any
---@param _ any
---@param deferrals Deferrals
local function onPlayerConnecting(name, _, deferrals)
    local src = source --[[@as string]]
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if QBCore.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'qbadmin.join') then
            deferrals.done(QBCore.Config.Server.ClosedReason)
        end
    end

    for _, v in pairs(identifiers) do
        if string.find(v, 'license2') or string.find(v, 'license') then
            license = v
            break
        end
    end

    if not license then
        deferrals.done(Lang:t('error.no_valid_license'))
    elseif QBCore.Config.Server.CheckDuplicateLicense and IsLicenseInUse(license) then
        deferrals.done(Lang:t('error.duplicate_license'))
    end

    local databaseTime = os.clock()
    local databasePromise = promise.new()

    -- conduct database-dependant checks
    CreateThread(function()
        deferrals.update(string.format(Lang:t('info.checking_ban'), name))
        local databaseSuccess, databaseError = pcall(function()
            local isBanned, Reason = QBCore.Functions.IsPlayerBanned(src --[[@as Source]])
            if isBanned then
                deferrals.done(Reason)
            end
        end)

        if QBCore.Config.Server.Whitelist then
            deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))
            databaseSuccess, databaseError = pcall(function()
                if not QBCore.Functions.IsWhitelisted(src --[[@as Source]]) then
                    deferrals.done(Lang:t('error.not_whitelisted'))
                end
            end)
        end

        if not databaseSuccess then
            databasePromise:reject(databaseError)
        end
        databasePromise:resolve()
    end)

    -- wait for database to finish
    databasePromise:next(function()
        deferrals.update(string.format(Lang:t('info.join_server'), name))
        deferrals.done()
    end, function (databaseError)
        deferrals.done(Lang:t('error.connecting_database_error'))
        print('^1' .. databaseError)
    end)

    -- if conducting db checks for too long then raise error
    while databasePromise.state == 0 do
        if os.clock() - databaseTime > 30 then
            deferrals.done(Lang:t('error.connecting_database_timeout'))
            error(Lang:t('error.connecting_database_timeout'))
            break
        end
        Wait(1000)
    end

    -- Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- New method for checking if logged in across all scripts (optional)
-- `if LocalPlayer.state.isLoggedIn then` for the client side
-- `if Player(source).state.isLoggedIn then` for the server side
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    Player(source --[[@as Source]]).state:set('isLoggedIn', true, true)
end)

---@param source Source
AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    Player(source).state:set('isLoggedIn', false, true)
end)

-- Open & Close Server (prevents players from joining)

---@param reason string
RegisterNetEvent('QBCore:Server:CloseServer', function(reason)
    local src = source --[[@as Source]]
    if QBCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        QBCore.Config.Server.Closed = true
        QBCore.Config.Server.ClosedReason = reason
        for k in pairs(QBCore.Players) do
            if not QBCore.Functions.HasPermission(k, QBCore.Config.Server.WhitelistPermission) then
                KickWithReason(k, reason, nil, nil)
            end
        end
    else
        KickWithReason(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

RegisterNetEvent('QBCore:Server:OpenServer', function()
    local src = source --[[@as Source]]
    if QBCore.Functions.HasPermission(src, 'admin') then
        QBCore.Config.Server.Closed = false
    else
        KickWithReason(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerClientCallback', function(name, ...)
    if QBCore.ClientCallbacks[name] then
        QBCore.ClientCallbacks[name](...)
        QBCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
RegisterNetEvent('QBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    QBCore.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('QBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('QBCore:ToggleDuty', function()
    local src = source --[[@as Source]]
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.on_duty'))
    end
    TriggerClientEvent('QBCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

--- @deprecated
RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source --[[@as Source]]
    if not QBCore.Commands.List[command] then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if IsPlayerAceAllowed(src, string.format('command.%s', command)) then
        local commandString = command
        for _, value in pairs(args) do
            commandString = string.format('%s %s', commandString, value)
        end
        TriggerClientEvent('QBCore:Command:CallCommand', src, commandString)
    end
end)

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
QBCore.Functions.CreateCallback('QBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)

---@deprecated call server function SpawnVehicle instead from imports/utils.lua.
QBCore.Functions.CreateCallback('QBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local netId = SpawnVehicle(source, model, coords, warp)
    if netId then cb(netId) end
end)
