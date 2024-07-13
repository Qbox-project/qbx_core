local serverConfig = require 'config.server'.server
local loggingConfig = require 'config.server'.logging
local serverName = require 'config.shared'.serverName
local logger = require 'modules.logger'
local queue = require 'server.queue'

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
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    if not license then return end
    if queue then
        queue.removePlayerJoining(license)
    end
    if not serverConfig.checkDuplicateLicense then return end
    if usedLicenses[license] then
        Wait(0) -- mandatory wait for the drop reason to show up
        DropPlayer(src, locale('error.duplicate_license'))
    else
        usedLicenses[license] = true
    end
end)

---@param reason string
AddEventHandler('playerDropped', function(reason)
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    if license then usedLicenses[license] = nil end
    if not QBX.Players[src] then return end
    GlobalState.PlayerCount -= 1
    local player = QBX.Players[src]
    player.PlayerData.lastLoggedOut = os.time()
    logger.log({
        source = 'qbx_core',
        webhook = loggingConfig.webhook['joinleave'],
        event = 'Dropped',
        color = 'red',
        message = ('**%s** (%s) left...\n **Reason:** %s'):format(GetPlayerName(src), player.PlayerData.license, reason),
    })
    player.Functions.Save()
    QBX.Player_Buckets[player.PlayerData.license] = nil
    QBX.Players[src] = nil
end)

---@class Deferrals https://docs.fivem.net/docs/scripting-reference/events/list/playerConnecting/#deferring-connections
---@field defer fun() initialize deferrals for the current resource. Required to wait at least 1 tick before calling other deferrals methods.
---@field update fun(message: string) sends a progress message to the connecting client
---@field presentCard fun(card: unknown|string, cb?: fun(data: unknown, rawData: string)) send an adaptive card to the client https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/getting-started and capture user input via callback.
---@field done fun(failureReason?: string) finalizes deferrals. If failureReason is present, user will be refused connection and shown reason. Need to wait 1 tick after calling other deferral methods before calling done.

-- Player Connecting
---@param name string
---@param _ any
---@param deferrals Deferrals
local function onPlayerConnecting(name, _, deferrals)
    local src = source --[[@as string]]
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if serverConfig.closed then
        if not IsPlayerAceAllowed(src, 'qbadmin.join') then
            deferrals.done(serverConfig.closedReason)
        end
    end

    if not license then
        deferrals.done(locale('error.no_valid_license'))
    elseif serverConfig.checkDuplicateLicense and usedLicenses[license] then
        deferrals.done(locale('error.duplicate_license'))
    end

    local databaseTime = os.clock()
    local databasePromise = promise.new()

    -- conduct database-dependant checks
    CreateThread(function()
        deferrals.update(locale('info.checking_ban', name))
        local success, err = pcall(function()
            local isBanned, Reason = IsPlayerBanned(src --[[@as Source]])
            if isBanned then
                Wait(0) -- Mandatory wait
                deferrals.done(Reason)
            end
        end)

        if serverConfig.whitelist and success then
            deferrals.update(locale('info.checking_whitelisted', name))
            success, err = pcall(function()
                if not IsWhitelisted(src --[[@as Source]]) then
                    Wait(0) -- Mandatory wait
                    deferrals.done(locale('error.not_whitelisted'))
                end
            end)
        end

        if not success then
            databasePromise:reject(err)
        end
        databasePromise:resolve()
    end)

    local onError = function(err)
        deferrals.done(locale('error.connecting_error'))
        lib.print.error(err)
    end

    -- wait for database to finish
    databasePromise:next(function()
        deferrals.update(locale('info.join_server', name, serverName))

        -- Mandatory wait
        Wait(0)

        if queue then
            queue.awaitPlayerQueue(src --[[@as Source]], license, deferrals)
        else
            deferrals.done()
        end
    end, onError):next(function() end, onError)

    -- if conducting db checks for too long then raise error
    while databasePromise.state == 0 do
        if os.clock() - databaseTime > 30 then
            deferrals.done(locale('error.connecting_database_timeout'))
            error(locale('error.connecting_database_timeout'))
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
    if IsPlayerAceAllowed(src --[[@as string]], 'admin') then
        reason = reason or 'No reason specified'
        serverConfig.closed = true
        serverConfig.closedReason = reason
        for k in pairs(QBX.Players) do
            if not IsPlayerAceAllowed(k --[[@as string]], serverConfig.whitelistPermission) then
                DropPlayer(k --[[@as string]], reason)
            end
        end
    else
        DropPlayer(src --[[@as string]], locale('error.no_permission'))
    end
end)

RegisterNetEvent('QBCore:Server:OpenServer', function()
    local src = source --[[@as Source]]
    if IsPlayerAceAllowed(src --[[@as string]], 'admin') then
        serverConfig.closed = false
    else
        DropPlayer(src --[[@as string]], locale('error.no_permission'))
    end
end)

-- Player

RegisterNetEvent('QBCore:ToggleDuty', function()
    local src = source --[[@as Source]]
    local player = GetPlayer(src)
    if not player then return end
    if player.PlayerData.job.onduty then
        player.Functions.SetJobDuty(false)
        Notify(src, locale('info.off_duty'))
    else
        player.Functions.SetJobDuty(true)
        Notify(src, locale('info.on_duty'))
    end
end)