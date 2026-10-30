function AddDeprecatedFunctions(player)
    if not player then return end

    ---@deprecated call ox_inventory instead
    function player.Functions.GetCardSlot()
        error('player.Functions.GetCardSlot is unsupported. Call ox_inventory directly')
    end

    return player
end

local playerObj = {}

---@deprecated ox_inventory automatically saves
---@param source Source
function playerObj.SaveInventory(source) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

---@deprecated ox_inventory automatically saves
---@param playerData PlayerData
function playerObj.SaveOfflineInventory(playerData) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@return number?
function playerObj.GetTotalWeight(items) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@param itemName string
---@return integer[]? slots
function playerObj.GetSlotsByItem(items, itemName) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

---@deprecated call ox_inventory exports directly
---@param items any[]
---@param itemName string
---@return integer? slot
function playerObj.GetFirstSlotByItem(items, itemName) -- luacheck: ignore
    assert(GetResourceState('qb-inventory') ~= 'started', 'qb-inventory is not compatible with qbx_core. use ox_inventory instead')
end

---@param source Source
---@param citizenid? string
---@param newData? PlayerEntity
---@return boolean success
function playerObj.Login(source, citizenid, newData)
    return exports.qbx_core:Login(source, citizenid, newData)
end

---@param citizenid string
---@return Player? player if found in storage
function playerObj.GetOfflinePlayer(citizenid)
    return AddDeprecatedFunctions(exports.qbx_core:GetOfflinePlayer(citizenid))
end

---Loads the most recently played character of a license. qbx stores license2 when available, so either license form matches.
---@param license string
---@return Player?
function playerObj.GetOfflinePlayerByLicense(license)
    if type(license) ~= 'string' then return end
    local citizenid = MySQL.scalar.await([[
        SELECT p.citizenid FROM players p
        LEFT JOIN users u ON u.userId = p.userId
        WHERE p.license = ? OR u.license = ? OR u.license2 = ?
        ORDER BY p.last_logged_out DESC
        LIMIT 1
    ]], { license, license, license })
    return citizenid and playerObj.GetOfflinePlayer(citizenid)
end

---@param license string
---@return Player?
function playerObj.GetPlayerByLicense(license)
    if type(license) ~= 'string' then return end
    local source = exports.qbx_core:GetSource(license)
    if source > 0 then
        return AddDeprecatedFunctions(exports.qbx_core:GetPlayer(source))
    end
    return playerObj.GetOfflinePlayerByLicense(license)
end

---@deprecated unsupported. Call Login or CreatePlayer
function playerObj.CheckPlayerData()
    error('Unsupported. Call Login or CreatePlayer')
end

---On player logout
---@param source Source
function playerObj.Logout(source)
    exports.qbx_core:Logout(source)
end

---Create a new character
---Don't touch any of this unless you know what you are doing
---Will cause major issues!
---@param playerData PlayerData
---@param Offline boolean
---@return Player?
function playerObj.CreatePlayer(playerData, Offline)
    return AddDeprecatedFunctions(exports.qbx_core:CreatePlayer(playerData, Offline))
end

---Save player info to database (make sure citizenid is the primary key in your database)
---@param source Source
function playerObj.Save(source)
    exports.qbx_core:Save(source)
end

---@param playerData PlayerEntity
function playerObj.SaveOffline(playerData)
    exports.qbx_core:SaveOffline(playerData)
end

playerObj.DeleteCharacter = DeleteCharacter

---@param citizenid string
function playerObj.ForceDeleteCharacter(citizenid)
    exports.qbx_core:DeleteCharacter(citizenid)
end

---Generate unique values for player identifiers
---@param type UniqueIdType The type of unique value to generate
---@return string | number UniqueVal unique value generated
function playerObj.GenerateUniqueIdentifier(type)
    return exports.qbx_core:GenerateUniqueIdentifier(type)
end


---@deprecated player.GenerateUniqueIdentifier('citizenid') instead
---@return string citizenid unique citizenid generated
function playerObj.CreateCitizenId()
    return exports.qbx_core:GenerateUniqueIdentifier('citizenid')
end

---@deprecated player.GenerateUniqueIdentifier('FingerId') instead
---@return string
function playerObj.CreateFingerId()
    return exports.qbx_core:GenerateUniqueIdentifier('FingerId')
end

---@deprecated player.GenerateUniqueIdentifier('WalletId') instead
---@return string
function playerObj.CreateWalletId()
    return exports.qbx_core:GenerateUniqueIdentifier('WalletId')
end

---@deprecated player.GenerateUniqueIdentifier('SerialNumber') instead
---@return integer
function playerObj.CreateSerialNumber()
    return exports.qbx_core:GenerateUniqueIdentifier('SerialNumber')
end

return playerObj