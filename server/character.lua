local config = require 'config.server'
local logger = require 'modules.logger'
local storage = require 'server.storage.main'
local starterItems = require 'config.shared'.starterItems

---Sources with a character load or creation request in progress. These
---callbacks yield on database calls, so a client firing the same request twice
---could otherwise pass the character limit check twice and get starter items twice.
---@type table<Source, true>
local pendingRequests = {}

---Runs `fn` unless the source already has a pending character request.
---@param source Source
---@param fn function
---@return ...
local function withPendingRequest(source, fn, ...)
    if pendingRequests[source] then return end
    pendingRequests[source] = true
    local result = table.pack(pcall(fn, source, ...))
    pendingRequests[source] = nil
    if not result[1] then error(result[2], 0) end
    return table.unpack(result, 2, result.n)
end

---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return config.characters.playersNumberOfCharacters[license2] or license and config.characters.playersNumberOfCharacters[license] or config.characters.defaultNumberOfCharacters
end

---@param source Source
local function giveStarterItems(source)
    if GetResourceState('ox_inventory') == 'missing' then return end
    while not exports.ox_inventory:GetInventory(source) do
        Wait(100)
    end
    for i = 1, #starterItems do
        local item = starterItems[i]
        if item.metadata and type(item.metadata) == 'function' then
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata(source))
        else
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata)
        end
    end
end

lib.callback.register('qbx_core:server:getCharacters', function(source)
    local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
    -- Heal any account left with a broken cid sequence (duplicates from the
    -- pre-fix createCharacter bug, or gaps from deleted characters) before
    -- handing the list to the client, so create-time logic can stay a simple append.
    storage.normalizeCids(license2, license)
    return storage.fetchAllPlayerEntities(license2, license), getAllowedAmountOfCharacters(license2, license)
end)

lib.callback.register('qbx_core:server:getPreviewPedData', function(_, citizenId)
    local ped = storage.fetchPlayerSkin(citizenId)
    if not ped then return end

    return ped.skin, ped.model and joaat(ped.model)
end)

---@param source Source
---@param citizenId string
local function loadCharacter(source, citizenId)
    local success = Login(source, citizenId)
    if not success then return end

    logger.log({
        source = 'qbx_core',
        webhook = config.logging.webhook['joinleave'],
        event = 'Loaded',
        color = 'green',
        message = ('**%s** (%s |  ||%s|| | %s | %s | %s) loaded'):format(GetPlayerName(source), GetPlayerIdentifierByType(source, 'discord') or 'undefined', GetPlayerIdentifierByType(source, 'ip') or 'undefined', GetPlayerIdentifierByType(source, 'license2') or GetPlayerIdentifierByType(source, 'license') or 'undefined', citizenId, source)
    })
    lib.print.info(('%s (Citizen ID: %s ID: %s) has successfully loaded!'):format(GetPlayerName(source), citizenId, source))
end

lib.callback.register('qbx_core:server:loadCharacter', function(source, citizenId)
    return withPendingRequest(source, loadCharacter, citizenId)
end)

--- Validates client-supplied character info. Never trust the values the create
--- screen sends: cap free-text length, enforce types, and reject anything that
--- isn't a usable string so a crafted payload can't bloat the row or smuggle in
--- non-string fields. Returns nil to refuse creation outright.
---@param data table
---@return table? sanitized
local function sanitizeNewCharInfo(data)
    local MAX_TEXT = 50
    local MAX_BACKSTORY = 1000

    local function text(value, maxLength)
        if type(value) ~= 'string' then return nil end
        value = value:gsub('^%s+', ''):gsub('%s+$', '')
        if value == '' or #value > maxLength then return nil end
        return value
    end

    local firstname = text(data.firstname, MAX_TEXT)
    local lastname = text(data.lastname, MAX_TEXT)
    local nationality = text(data.nationality, MAX_TEXT)
    local birthdate = text(data.birthdate, MAX_TEXT)
    local gender = tonumber(data.gender)

    if not firstname or not lastname or not nationality or not birthdate or not gender then
        return nil
    end

    return {
        firstname = firstname,
        lastname = lastname,
        nationality = nationality,
        birthdate = birthdate,
        gender = math.floor(gender),
        backstory = text(data.backstory, MAX_BACKSTORY) or 'placeholder backstory',
    }
end

---@param existingCharacters PlayerEntity[] sorted ascending by cid (storage.fetchAllPlayerEntities orders by cid)
---@return integer
local function getNextCid(existingCharacters)
    local lastCharacter = existingCharacters[#existingCharacters]
    return (lastCharacter and lastCharacter.charinfo.cid or 0) + 1
end

---@param source Source
---@param data unknown
---@return table? newData
local function createCharacter(source, data)
    if type(data) ~= 'table' then return end

    local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
    local existingCharacters = storage.fetchAllPlayerEntities(license2, license)
    if #existingCharacters >= getAllowedAmountOfCharacters(license2, license) then
        return
    end

    local charinfo = sanitizeNewCharInfo(data)
    if not charinfo then return end

    -- The client sends a cid (its local slot index), but that value is never
    -- trustworthy: sanitizeNewCharInfo() intentionally drops it, so it must be
    -- computed server-side from the account's existing characters or every new
    -- character silently falls back to cid 1 (see CheckPlayerData in player.lua).
    charinfo.cid = getNextCid(existingCharacters)

    local newData = {}
    newData.charinfo = charinfo

    local success = Login(source, nil, newData)
    if not success then return end

    giveStarterItems(source)

    lib.print.info(('%s has created a character'):format(GetPlayerName(source)))
    return newData
end

---@param data unknown
---@return table? newData
lib.callback.register('qbx_core:server:createCharacter', function(source, data)
    return withPendingRequest(source, createCharacter, data)
end)

--- Deprecated. This event is kept for backward compatibility only and is no longer used internally.
RegisterNetEvent('qbx_core:server:deleteCharacter', function(citizenId)
    local src = source
    DeleteCharacter(src --[[@as number]], citizenId)
    Notify(src, locale('success.character_deleted'), 'success')
end)