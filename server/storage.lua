---@class InsertBanRequest
---@field name string
---@field license? string
---@field discordId? string
---@field ip? string
---@field reason string
---@field bannedBy string
---@field expiration integer epoch second that the ban will expire

---@param request InsertBanRequest
function InsertBanEntity(request)
    if not request.discordId and not request.ip and not request.license then
        error("no identifier provided")
    end

    MySQL.insert.await('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        request.name,
        request.license,
        request.discordId,
        request.ip,
        request.reason,
        request.expiration,
        request.bannedBy,
    })
end

---@param request GetBanRequest
---@return string column in storage
---@return string value of the id
local function getBanId(request)
    if request.license then
        return "license", request.license
    elseif request.discordId then
        return "discord", request.discordId
    elseif request.ip then
        return "ip", request.ip
    else
        error("no identifier provided", 2)
    end
end

---@class GetBanRequest
---@field license? string
---@field discordId? string
---@field ip? string

---@class BanEntity
---@field expire integer epoch second that the ban will expire
---@field reason string

---@param request GetBanRequest
---@return BanEntity
function GetBanEntity(request)
    local column, value = getBanId(request)
    local result = MySQL.single.await('SELECT * FROM bans WHERE ' ..column.. ' = ?', { value })
    return {
        expire = result.expire,
        reason = result.reason,
    }
end

---@param request GetBanRequest
function DeleteBanEntity(request)
    local column, value = getBanId(request)
    MySQL.query.await('DELETE FROM bans WHERE ' ..column.. ' = ?', { value })
end

---@class UpsertPlayerRequest
---@field playerData PlayerEntity
---@field position vector3

---@param request UpsertPlayerRequest
function UpsertPlayerEntity(request)
    MySQL.insert.await('INSERT INTO players (citizenid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
        citizenid = request.playerData.citizenid,
        license = request.playerData.license,
        name = request.playerData.name,
        money = json.encode(request.playerData.money),
        charinfo = json.encode(request.playerData.charinfo),
        job = json.encode(request.playerData.job),
        gang = json.encode(request.playerData.gang),
        position = json.encode(request.position),
        metadata = json.encode(request.playerData.metadata)
    })
end

---TODO: define JSON table contracts
---@class PlayerEntity
---@field citizenid string
---@field license string
---@field name string
---@field money number
---@field charinfo table
---@field job table
---@field gang table
---@field position vector4
---@field metadata table

---@param citizenId string
---@return PlayerEntity
function GetPlayerEntity(citizenId)
    local player = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenId })
    return {
        citizenid = player.citizenid,
        license = player.license,
        name = player.name,
        money = json.decode(player.money),
        charinfo = json.decode(player.charinfo),
        job = json.decode(player.job),
        gang = player.gang and json.decode(player.gang) or {},
        position = json.decode(player.position),
        metadata = json.decode(player.metadata)
    }
end

---@param citizenId string
---@return boolean success if operation is successful.
function DeletePlayerEntity(citizenId)
    local playerTables = {
        'players',
        'apartments',
        'bank_accounts',
        'crypto_transactions',
        'phone_invoices',
        'phone_messages',
        'playerskins',
        'player_contacts',
        'player_houses',
        'player_mails',
        'player_outfits',
        'player_vehicles',
    }

    local query = "DELETE FROM %s WHERE citizenid = ?"
    local queries = {}

    for i = 1, #playerTables do
        local table = playerTables[i]
        queries[i] = {
            query = query:format(table),
            values = {
                citizenId,
            }
        }
    end

    local success = MySQL.transaction.await(queries)
    return success and true or false
end

---checks the storage for uniqueness of the given value
---@param type UniqueIdType
---@param value string|number
---@return boolean isUnique if the value does not already exist in storage for the given type
function IsUnique(type, value)
    local typeToColumn = {
        citizenid = "citizenid",
        AccountNumber = "JSON_VALUE(charinfo, '$.account')",
        PhoneNumber = "JSON_VALUE(charinfo, '$.phone')",
        FingerId = "JSON_VALUE(metadata, '$.fingerprint')",
        WalletId = "JSON_VALUE(metadata, '$.walletid')",
        SerialNumber = "JSON_VALUE(metadata, '$.phonedata.SerialNumber')",
    }

    local count = MySQL.prepare.await('SELECT COUNT(*) as count FROM players WHERE ' .. typeToColumn[type] .. ' = ?', { value })
    return count == 0
end