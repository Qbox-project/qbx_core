---@alias Source integer

---@type table<Source, Player>
QBCore.Players = {}

---@type Player
QBCore.Player = {}

GlobalState.PlayerCount = 0

---@class PlayerData : PlayerEntity
---@field source? Source present if player is online
---@field optin? boolean present if player is online

---On player login get their data or set defaults
---Don't touch any of this unless you know what you are doing
---Will cause major issues!
---@param source Source
---@param citizenid? string
---@param newData PlayerEntity
---@return boolean sourceExists true if source exists
function QBCore.Player.Login(source, citizenid, newData)
    if not source or source == '' then
        DebugPrint('^1ERROR: QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
    if citizenid then
        local license, license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license'), GetPlayerIdentifierByType(source --[[@as string]], 'license2')
        local PlayerData = FetchPlayerEntity(citizenid)
        if PlayerData and (license2 == PlayerData.license or license == PlayerData.license) then
            QBCore.Player.CheckPlayerData(source, PlayerData)
        else
            DropPlayer(tostring(source), Lang:t("info.exploit_dropped"))
            TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', ('%s Has Been Dropped For Character Joining Exploit'):format(GetPlayerName(source)), false)
        end
    else
        QBCore.Player.CheckPlayerData(source, newData)
    end
    return true
end

---@param citizenid string
---@return Player? player if found in storage
function QBCore.Player.GetOfflinePlayer(citizenid)
    if not citizenid then return end
    local PlayerData = FetchPlayerEntity(citizenid)
    if not PlayerData then return end
    return QBCore.Player.CheckPlayerData(nil, PlayerData)
end

---@param source? integer if player is online
---@param PlayerData PlayerEntity|PlayerData
---@return Player? player if offline
function QBCore.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = true
    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
        PlayerData.name = GetPlayerName(source)
        Offline = false
    end

    PlayerData.citizenid = PlayerData.citizenid or QBCore.Player.GenerateUniqueIdentifier('citizenid')
    PlayerData.cid = PlayerData.charinfo?.cid or 1
    PlayerData.money = PlayerData.money or {}
    PlayerData.optin = PlayerData.optin or true
    for moneytype, startamount in pairs(QBCore.Config.Money.MoneyTypes) do
        PlayerData.money[moneytype] = PlayerData.money[moneytype] or startamount
    end

    -- Charinfo
    PlayerData.charinfo = PlayerData.charinfo or {}
    PlayerData.charinfo.firstname = PlayerData.charinfo.firstname or 'Firstname'
    PlayerData.charinfo.lastname = PlayerData.charinfo.lastname or 'Lastname'
    PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate or '00-00-0000'
    PlayerData.charinfo.gender = PlayerData.charinfo.gender or 0
    PlayerData.charinfo.backstory = PlayerData.charinfo.backstory or 'placeholder backstory'
    PlayerData.charinfo.nationality = PlayerData.charinfo.nationality or 'USA'
    PlayerData.charinfo.phone = PlayerData.charinfo.phone or QBCore.Player.GenerateUniqueIdentifier('PhoneNumber')
    PlayerData.charinfo.account = PlayerData.charinfo.account or QBCore.Player.GenerateUniqueIdentifier('AccountNumber')
    -- Metadata
    PlayerData.metadata = PlayerData.metadata or {}
    PlayerData.metadata.health = PlayerData.metadata.health or 200
    PlayerData.metadata.hunger = PlayerData.metadata.hunger or 100
    PlayerData.metadata.thirst = PlayerData.metadata.thirst or 100
    PlayerData.metadata.stress = PlayerData.metadata.stress or 0
    PlayerData.metadata.isdead = PlayerData.metadata.isdead or false
    PlayerData.metadata.inlaststand = PlayerData.metadata.inlaststand or false
    PlayerData.metadata.armor = PlayerData.metadata.armor or 0
    PlayerData.metadata.ishandcuffed = PlayerData.metadata.ishandcuffed or false
    PlayerData.metadata.tracker = PlayerData.metadata.tracker or false
    PlayerData.metadata.injail = PlayerData.metadata.injail or 0
    PlayerData.metadata.jailitems = PlayerData.metadata.jailitems or {}
    PlayerData.metadata.status = PlayerData.metadata.status or {}
    PlayerData.metadata.phone = PlayerData.metadata.phone or {}
    PlayerData.metadata.fitbit = PlayerData.metadata.fitbit or {}
    PlayerData.metadata.commandbinds = PlayerData.metadata.commandbinds or {}
    PlayerData.metadata.bloodtype = PlayerData.metadata.bloodtype or QBCore.Config.Player.Bloodtypes[math.random(1, #QBCore.Config.Player.Bloodtypes)]
    PlayerData.metadata.dealerrep = PlayerData.metadata.dealerrep or 0
    PlayerData.metadata.craftingrep = PlayerData.metadata.craftingrep or 0
    PlayerData.metadata.attachmentcraftingrep = PlayerData.metadata.attachmentcraftingrep or 0
    PlayerData.metadata.currentapartment = PlayerData.metadata.currentapartment or nil
    PlayerData.metadata.jobrep = PlayerData.metadata.jobrep or {}
    PlayerData.metadata.jobrep.tow = PlayerData.metadata.jobrep.tow or 0
    PlayerData.metadata.jobrep.trucker = PlayerData.metadata.jobrep.trucker or 0
    PlayerData.metadata.jobrep.taxi = PlayerData.metadata.jobrep.taxi or 0
    PlayerData.metadata.jobrep.hotdog = PlayerData.metadata.jobrep.hotdog or 0
    PlayerData.metadata.callsign = PlayerData.metadata.callsign or 'NO CALLSIGN'
    PlayerData.metadata.fingerprint = PlayerData.metadata.fingerprint or QBCore.Player.GenerateUniqueIdentifier('FingerId')
    PlayerData.metadata.walletid = PlayerData.metadata.walletid or QBCore.Player.GenerateUniqueIdentifier('WalletId')
    PlayerData.metadata.criminalrecord = PlayerData.metadata.criminalrecord or {
        hasRecord = false,
        date = nil
    }
    PlayerData.metadata.licences = PlayerData.metadata.licences or {
        driver = true,
        business = false,
        weapon = false
    }
    PlayerData.metadata.inside = PlayerData.metadata.inside or {
        house = nil,
        apartment = {
            apartmentType = nil,
            apartmentId = nil,
        }
    }
    PlayerData.metadata.phonedata = PlayerData.metadata.phonedata or {
        SerialNumber = QBCore.Player.GenerateUniqueIdentifier('SerialNumber'),
        InstalledApps = {},
    }
    -- Job
    if PlayerData.job and PlayerData.job.name and not QBCore.Shared.Jobs[PlayerData.job.name] then PlayerData.job = nil end
    PlayerData.job = PlayerData.job or {}
    PlayerData.job.name = PlayerData.job.name or 'unemployed'
    PlayerData.job.label = PlayerData.job.label or 'Civilian'
    PlayerData.job.payment = PlayerData.job.payment or 10
    PlayerData.job.type = PlayerData.job.type or 'none'
    if QBCore.Shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then
        PlayerData.job.onduty = QBCore.Shared.Jobs[PlayerData.job.name].defaultDuty
    end
    PlayerData.job.isboss = PlayerData.job.isboss or false
    PlayerData.job.grade = PlayerData.job.grade or {}
    PlayerData.job.grade.name = PlayerData.job.grade.name or 'Freelancer'
    PlayerData.job.grade.level = PlayerData.job.grade.level or 0
    -- Gang
    if PlayerData.gang and PlayerData.gang.name and not QBCore.Shared.Gangs[PlayerData.gang.name] then PlayerData.gang = nil end
    PlayerData.gang = PlayerData.gang or {}
    PlayerData.gang.name = PlayerData.gang.name or 'none'
    PlayerData.gang.label = PlayerData.gang.label or 'No Gang Affiliation'
    PlayerData.gang.isboss = PlayerData.gang.isboss or false
    PlayerData.gang.grade = PlayerData.gang.grade or {}
    PlayerData.gang.grade.name = PlayerData.gang.grade.name or 'none'
    PlayerData.gang.grade.level = PlayerData.gang.grade.level or 0
    -- Other
    PlayerData.position = PlayerData.position or QBConfig.DefaultSpawn
    PlayerData.items = GetResourceState('qb-inventory') ~= 'missing' and exports['qb-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid) or {}
    return QBCore.Player.CreatePlayer(PlayerData --[[@as PlayerData]], Offline)
end

---On player logout
---@param source Source
function QBCore.Player.Logout(source)
    TriggerClientEvent('QBCore:Client:OnPlayerUnload', source)
    TriggerEvent('QBCore:Server:OnPlayerUnload', source)

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata.hunger - QBCore.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata.thirst - QBCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', source, newHunger, newThirst)
    Player.Functions.Save()

    Wait(200)
    QBCore.Players[source] = nil
    GlobalState.PlayerCount -= 1
end

---@class Player
---@field Functions PlayerFunctions
---@field PlayerData PlayerData
---@field Offline boolean

---@class PlayerFunctions
---@field UpdatePlayerData fun()
---@field SetJob fun(job: string, grade: integer): boolean
---@field SetGang fun(gang: string, grade: integer): boolean
---@field SetJobDuty fun(onDuty: boolean)
---@field SetPlayerData fun(key: string, val: any)
---@field SetMetaData fun(meta: string, val: any)
---@field GetMetaData fun(meta: string): any
---@field AddJobReputation fun(amount: number)
---@field AddMoney fun(moneytype: MoneyType, amount: number, reason?: string): boolean
---@field RemoveMoney fun(moneytype: MoneyType, amount: number, reason?: string): boolean
---@field SetMoney fun(moneytype: MoneyType, amount: number, reason?: string): boolean
---@field GetMoney fun(moneytype: MoneyType): boolean | number
---@field SetCreditCard fun(cardNumber: number)
---@field GetCardSlot fun(cardNumber: number, cardType: 'visa' | 'mastercard' | string): number?
---@field Save fun()
---@field Logout fun()
---@field AddMethod fun(methodName: string, handler: function)
---@field AddField fun(fieldName: string, data: any)

---Create a new character
---Don't touch any of this unless you know what you are doing
---Will cause major issues!
---@param PlayerData PlayerData
---@param Offline boolean
---@return Player? player if player is offline
function QBCore.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end -- Unsupported for Offline Players
        TriggerEvent('QBCore:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('QBCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    ---@param job string name
    ---@param grade integer
    ---@return boolean success if job was set
    function self.Functions.SetJob(job, grade)
        job = job or ''
        grade = tonumber(grade) or 0
        if not QBCore.Shared.Jobs[job] then return false end
        self.PlayerData.job.name = job
        self.PlayerData.job.label = QBCore.Shared.Jobs[job].label
        self.PlayerData.job.onduty = QBCore.Shared.Jobs[job].defaultDuty
        self.PlayerData.job.type = QBCore.Shared.Jobs[job].type or 'none'
        if QBCore.Shared.Jobs[job].grades[grade] then
            local jobgrade = QBCore.Shared.Jobs[job].grades[grade]
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = jobgrade.name
            self.PlayerData.job.grade.level = grade
            self.PlayerData.job.payment = jobgrade.payment or 30
            self.PlayerData.job.isboss = jobgrade.isboss or false
        else
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = 'No Grades'
            self.PlayerData.job.grade.level = 0
            self.PlayerData.job.payment = 30
            self.PlayerData.job.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('QBCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    ---@param gang string name
    ---@param grade integer
    ---@return boolean success if gang was set
    function self.Functions.SetGang(gang, grade)
        gang = gang or ''
        grade = tonumber(grade) or 0
        if not QBCore.Shared.Gangs[gang] then return false end
        self.PlayerData.gang.name = gang
        self.PlayerData.gang.label = QBCore.Shared.Gangs[gang].label
        if QBCore.Shared.Gangs[gang].grades[grade] then
            local ganggrade = QBCore.Shared.Gangs[gang].grades[grade]
            self.PlayerData.gang.grade = {}
            self.PlayerData.gang.grade.name = ganggrade.name
            self.PlayerData.gang.grade.level = grade
            self.PlayerData.gang.isboss = ganggrade.isboss or false
        else
            self.PlayerData.gang.grade = {}
            self.PlayerData.gang.grade.name = 'No Grades'
            self.PlayerData.gang.grade.level = 0
            self.PlayerData.gang.isboss = false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('QBCore:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent('QBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    ---@param onDuty boolean
    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty -- Make sure the value is a boolean if nil is sent
        self.Functions.UpdatePlayerData()
    end

    ---@param key string
    ---@param val any
    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    ---@param meta string
    ---@param val any
    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    ---@param meta string
    ---@return any
    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    ---@param amount number
    function self.Functions.AddJobReputation(amount)
        if not amount then return end
        amount = tonumber(amount) --[[@as number]]
        self.PlayerData.metadata.jobrep[self.PlayerData.job.name] = self.PlayerData.metadata.jobrep[self.PlayerData.job.name] + amount
        self.Functions.UpdatePlayerData()
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was added
    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "add", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was removed
    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(QBCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "remove", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was set
    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, "set", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@return boolean | number amount or false if moneytype does not exist
    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        return self.PlayerData.money[moneytype]
    end

    ---@param cardNumber number
    function self.Functions.SetCreditCard(cardNumber)
        self.PlayerData.charinfo.card = cardNumber
        self.Functions.UpdatePlayerData()
    end

    ---@param cardNumber number
    ---@param cardType 'visa' | 'mastercard' | string
    ---@return number? slot of the card if found
    function self.Functions.GetCardSlot(cardNumber, cardType)
        local item = tostring(cardType)
        local slots = exports['qb-inventory']:GetSlotsByItem(self.PlayerData.items, item)
        for _, slot in pairs(slots) do
            if slot then
                if self.PlayerData.items[slot].info.cardNumber == cardNumber then
                    return slot
                end
            end
        end
        return nil
    end

    function self.Functions.Save()
        if self.Offline then
            QBCore.Player.SaveOffline(self.PlayerData)
        else
            QBCore.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end -- Unsupported for Offline Players
        QBCore.Player.Logout(self.PlayerData.source)
    end

    ---adds a new player method at runtime
    ---@param methodName string
    ---@param handler function
    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    ---adds a new player field at runtime
    ---note this probably isn't what you want. If data should be persistent, see self.Functions.SetMetaData instead.
    ---@param fieldName string
    ---@param data any
    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        QBCore.Players[self.PlayerData.source] = self
        QBCore.Player.Save(self.PlayerData.source)

        -- At this point we are safe to emit new instance to third party resource for load handling
        GlobalState.PlayerCount += 1
        TriggerEvent('QBCore:Server:PlayerLoaded', self)
        self.Functions.UpdatePlayerData()
    end
end

---Add a new function to the Functions table of the player class
---Use-case:
-- [[
--     AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
--         QBCore.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
--             -- do something here
--         end)
--     end)
-- ]]
---@param ids number|number[] which players to add the method to. -1 for all players
---@param methodName string
---@param handler function
function QBCore.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

---Add a new field table of the player class
---Use-case:
--[[
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        QBCore.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]
---@param ids number|number[] which players to add a new field to. -1 for all players
---@param fieldName string
---@param data any
function QBCore.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBCore.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

---Save player info to database (make sure citizenid is the primary key in your database)
---@param source Source
function QBCore.Player.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = QBCore.Players[source].PlayerData
    if not PlayerData then
        DebugPrint('^1ERROR: QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        return
    end

    CreateThread(function()
        UpsertPlayerEntity({
            playerEntity = PlayerData,
            position = pcoords,
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(source) end
    DebugPrint(('^2%s PLAYER SAVED!'):format(PlayerData.name))
end

---@param PlayerData PlayerEntity
function QBCore.Player.SaveOffline(PlayerData)
    if not PlayerData then
        DebugPrint('^1ERROR: QBCORE.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
        return
    end

    CreateThread(function()
        UpsertPlayerEntity({
            playerEntity = PlayerData,
            position = PlayerData.position.xyz
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(PlayerData, true) end
    DebugPrint(('^2%s OFFLINE PLAYER SAVED!'):format(PlayerData.name))
end

---@param source Source
---@param citizenid string
function QBCore.Player.DeleteCharacter(source, citizenid)
    local license, license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license'), GetPlayerIdentifierByType(source --[[@as string]], 'license2')
    local result = FetchPlayerEntity(citizenid).license
    if license == result or license2 == result then
        CreateThread(function()
            local success = DeletePlayerEntity(citizenid)
            if success then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license2 .. ' deleted **' .. citizenid .. '**..')
            end
        end)
    else
        DropPlayer(tostring(source), Lang:t("info.exploit_dropped"))
        TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

---@param citizenid string
function QBCore.Player.ForceDeleteCharacter(citizenid)
    local result = FetchPlayerEntity(citizenid).license
    if result then
        local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        if Player then
            DropPlayer(Player.PlayerData.source --[[@as string]], "An admin deleted the character which you are currently using")
        end

        CreateThread(function()
            local success = DeletePlayerEntity(citizenid)
            if success then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

--- Inventory Backwards Compatibility

---@param source Source
function QBCore.Player.SaveInventory(source)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(source, false)
end

---@param PlayerData PlayerData
function QBCore.Player.SaveOfflineInventory(PlayerData)
    if GetResourceState('qb-inventory') == 'missing' then return end
    exports['qb-inventory']:SaveInventory(PlayerData, true)
end

---@param items any[]
---@return number?
function QBCore.Player.GetTotalWeight(items)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetTotalWeight(items)
end

---@param items any[]
---@param itemName string
---@return integer[]? slots
function QBCore.Player.GetSlotsByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

---@param items any[]
---@param itemName string
---@return integer? slot
function QBCore.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState('qb-inventory') == 'missing' then return end
    return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

---Generate unique values for player identifiers
---@param type UniqueIdType The type of unique value to generate
---@return string | number UniqueVal unique value generated
function QBCore.Player.GenerateUniqueIdentifier(type)
    local isUnique, uniqueId
    local table = QBConfig.Player.IdentifierTypes[type]
    repeat
        uniqueId = table.valueFunction()
        isUnique = FetchIsUnique(type, uniqueId)
    until isUnique
    return uniqueId
end
