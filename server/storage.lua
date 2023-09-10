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
---@return BanEntity?
function FetchBanEntity(request)
    local column, value = getBanId(request)
    local result = MySQL.single.await('SELECT * FROM bans WHERE ' ..column.. ' = ?', { value })
    return result and {
        expire = result.expire,
        reason = result.reason,
    } or nil
end

---@param request GetBanRequest
function DeleteBanEntity(request)
    local column, value = getBanId(request)
    MySQL.query.await('DELETE FROM bans WHERE ' ..column.. ' = ?', { value })
end

---@class UpsertPlayerRequest
---@field playerEntity PlayerEntity
---@field position vector3

---@param request UpsertPlayerRequest
function UpsertPlayerEntity(request)
    MySQL.insert.await('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
        citizenid = request.playerEntity.citizenid,
        cid = request.playerEntity.charinfo.cid,
        license = request.playerEntity.license,
        name = request.playerEntity.name,
        money = json.encode(request.playerEntity.money),
        charinfo = json.encode(request.playerEntity.charinfo),
        job = json.encode(request.playerEntity.job),
        gang = json.encode(request.playerEntity.gang),
        position = json.encode(request.position),
        metadata = json.encode(request.playerEntity.metadata)
    })
end

---@class PlayerEntity
---@field citizenid string
---@field license string
---@field name string
---@field money Money
---@field charinfo PlayerCharInfo
---@field job? PlayerJob
---@field gang? PlayerGang
---@field position vector4
---@field metadata PlayerMetadata
---@field cid integer
---@field items table deprecated

---@class PlayerEntityDatabase : PlayerEntity
---@field charinfo string
---@field money string
---@field job? string
---@field gang? string
---@field position string
---@field metadata string

---@class PlayerCharInfo
---@field firstname string
---@field lastname string
---@field birthdate string
---@field nationality string
---@field cid integer
---@field gender integer
---@field backstory string
---@field phone string
---@field account string
---@field card number

---@class PlayerMetadata
---@field health number
---@field armor number
---@field hunger number
---@field thirst number
---@field stress number
---@field isdead boolean
---@field inlaststand boolean
---@field ishandcuffed boolean
---@field tracker boolean
---@field injail number time in minutes
---@field jailitems table TODO: expand
---@field status table TODO: expand
---@field phone {background: any, profilepicture: any} TODO: figure out more specific types
---@field fitbit {thirst: number, food: number}
---@field commandbinds table TODO: expand
---@field bloodtype BloodType
---@field dealerrep number
---@field craftingrep number
---@field attachmentcraftingrep number
---@field currentapartment? integer apartmentId
---@field jobrep {tow: number, trucker: number, taxi: number, hotdog: number}
---@field callsign string
---@field fingerprint string
---@field walletid string
---@field criminalrecord {hasRecord: boolean, date?: table} TODO: date is os.date(), create better type than table
---@field licences {id: boolean, driver: boolean, weapon: boolean}
---@field inside {house?: any, apartment: {apartmentType?: any, apartmentId?: integer}} TODO: expand
---@field phonedata {SerialNumber: string, InstalledApps: table} TODO: expand

---@class PlayerJob
---@field name string
---@field label string
---@field payment number
---@field type string
---@field onduty boolean
---@field isboss boolean
---@field grade {name: string, level: number}

---@class PlayerGang
---@field name string
---@field label string
---@field isboss boolean
---@field grade {name: string, level: number}

---@class PlayerSkin
---@field citizenid string
---@field model string
---@field skin string
---@field active integer

---@param citizenId string
---@return PlayerSkin?
function FetchPlayerSkin(citizenId)
    return MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ?', {citizenId})
end

local function convertPosition(position)
    local pos = json.decode(position)
    local actualPos = (not pos.x or not pos.y or not pos.z) and QBCore.Config.DefaultSpawn or pos
    return vec4(actualPos.x, actualPos.y, actualPos.z, actualPos.w or QBCore.Config.DefaultSpawn.w)
end

---@param license2 string
---@param license? string
---@return PlayerEntity[]
function FetchAllPlayerEntities(license2, license)
    ---@type PlayerEntity[]
    local chars = {}
    ---@type PlayerEntityDatabase[]
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ? OR license = ?', {license, license2})
    for i = 1, #result do
        chars[i] = result[i]
        chars[i].charinfo = json.decode(result[i].charinfo)
        chars[i].money = json.decode(result[i].money)
        chars[i].job = result[i].job and json.decode(result[i].job)
        chars[i].gang = result[i].gang and json.decode(result[i].gang)
        chars[i].position = convertPosition(result[i].position)
        chars[i].metadata = json.decode(result[i].metadata)
    end

    return chars
end

---@param citizenId string
---@return PlayerEntity?
function FetchPlayerEntity(citizenId)
    ---@type PlayerEntityDatabase
    local player = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenId })
    local charinfo = json.decode(player.charinfo)
    return player and {
        citizenid = player.citizenid,
        cid = charinfo.cid,
        license = player.license,
        name = player.name,
        money = json.decode(player.money),
        charinfo = charinfo,
        job = player.job and json.decode(player.job),
        gang = player.gang and json.decode(player.gang),
        position = convertPosition(player.position),
        metadata = json.decode(player.metadata)
    } or nil
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
function FetchIsUnique(type, value)
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
