local playerObj = {}

---@class PlayerData : PlayerEntity
---@field source? Source present if player is online
---@field optin? boolean present if player is online

---On player login get their data or set defaults
---Don't touch any of this unless you know what you are doing
---Will cause major issues!
---@param source Source
---@param citizenid? string
---@param newData? PlayerEntity
---@return Player? player if logged in successfully
function playerObj.Login(source, citizenid, newData)
    if not source or source == '' then
        lib.print.error('QBCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return
    end
    if citizenid then
        local license, license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license'), GetPlayerIdentifierByType(source --[[@as string]], 'license2')
        local playerData = FetchPlayerEntity(citizenid)
        if playerData and (license2 == playerData.license or license == playerData.license) then
            return QBCore.Player.CheckPlayerData(source, playerData)
        else
            DropPlayer(tostring(source), Lang:t("info.exploit_dropped"))
            TriggerEvent('qb-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', ('%s Has Been Dropped For Character Joining Exploit'):format(GetPlayerName(source)), false)
        end
    else
        return QBCore.Player.CheckPlayerData(source, newData)
    end
end

---@param citizenid string
---@return Player? player if found in storage
function playerObj.GetOfflinePlayer(citizenid)
    if not citizenid then return end
    local playerData = FetchPlayerEntity(citizenid)
    if not playerData then return end
    return QBCore.Player.CheckPlayerData(nil, playerData)
end

---@param source? integer if player is online
---@param playerData? PlayerEntity|PlayerData
---@return Player player
function playerObj.CheckPlayerData(source, playerData)
    playerData = playerData or {}
    local Offline = true
    if source then
        playerData.source = source
        playerData.license = playerData.license or GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
        playerData.name = GetPlayerName(source)
        Offline = false
    end

    playerData.citizenid = playerData.citizenid or QBCore.Player.GenerateUniqueIdentifier('citizenid')
    playerData.cid = playerData.charinfo?.cid or playerData.cid or 1
    playerData.money = playerData.money or {}
    playerData.optin = playerData.optin or true
    for moneytype, startamount in pairs(QBCore.Config.Money.MoneyTypes) do
        playerData.money[moneytype] = playerData.money[moneytype] or startamount
    end

    -- Charinfo
    playerData.charinfo = playerData.charinfo or {}
    playerData.charinfo.firstname = playerData.charinfo.firstname or 'Firstname'
    playerData.charinfo.lastname = playerData.charinfo.lastname or 'Lastname'
    playerData.charinfo.birthdate = playerData.charinfo.birthdate or '00-00-0000'
    playerData.charinfo.gender = playerData.charinfo.gender or 0
    playerData.charinfo.backstory = playerData.charinfo.backstory or 'placeholder backstory'
    playerData.charinfo.nationality = playerData.charinfo.nationality or 'USA'
    playerData.charinfo.phone = playerData.charinfo.phone or QBCore.Player.GenerateUniqueIdentifier('PhoneNumber')
    playerData.charinfo.account = playerData.charinfo.account or QBCore.Player.GenerateUniqueIdentifier('AccountNumber')
    playerData.charinfo.cid = playerData.charinfo.cid or playerData.cid
    -- Metadata
    playerData.metadata = playerData.metadata or {}
    playerData.metadata.health = playerData.metadata.health or 200
    playerData.metadata.hunger = playerData.metadata.hunger or 100
    playerData.metadata.thirst = playerData.metadata.thirst or 100
    playerData.metadata.stress = playerData.metadata.stress or 0
    playerData.metadata.isdead = playerData.metadata.isdead or false
    playerData.metadata.inlaststand = playerData.metadata.inlaststand or false
    playerData.metadata.armor = playerData.metadata.armor or 0
    playerData.metadata.ishandcuffed = playerData.metadata.ishandcuffed or false
    playerData.metadata.tracker = playerData.metadata.tracker or false
    playerData.metadata.injail = playerData.metadata.injail or 0
    playerData.metadata.jailitems = playerData.metadata.jailitems or {}
    playerData.metadata.status = playerData.metadata.status or {}
    playerData.metadata.phone = playerData.metadata.phone or {}
    playerData.metadata.fitbit = playerData.metadata.fitbit or {}
    playerData.metadata.commandbinds = playerData.metadata.commandbinds or {}
    playerData.metadata.bloodtype = playerData.metadata.bloodtype or QBCore.Config.Player.Bloodtypes[math.random(1, #QBCore.Config.Player.Bloodtypes)]
    playerData.metadata.dealerrep = playerData.metadata.dealerrep or 0
    playerData.metadata.craftingrep = playerData.metadata.craftingrep or 0
    playerData.metadata.attachmentcraftingrep = playerData.metadata.attachmentcraftingrep or 0
    playerData.metadata.currentapartment = playerData.metadata.currentapartment or nil
    playerData.metadata.jobrep = playerData.metadata.jobrep or {}
    playerData.metadata.jobrep.tow = playerData.metadata.jobrep.tow or 0
    playerData.metadata.jobrep.trucker = playerData.metadata.jobrep.trucker or 0
    playerData.metadata.jobrep.taxi = playerData.metadata.jobrep.taxi or 0
    playerData.metadata.jobrep.hotdog = playerData.metadata.jobrep.hotdog or 0
    playerData.metadata.callsign = playerData.metadata.callsign or 'NO CALLSIGN'
    playerData.metadata.fingerprint = playerData.metadata.fingerprint or QBCore.Player.GenerateUniqueIdentifier('FingerId')
    playerData.metadata.walletid = playerData.metadata.walletid or QBCore.Player.GenerateUniqueIdentifier('WalletId')
    playerData.metadata.criminalrecord = playerData.metadata.criminalrecord or {
        hasRecord = false,
        date = nil
    }
    playerData.metadata.licences = playerData.metadata.licences or {
        id = true,
        driver = true,
        weapon = false,
    }
    playerData.metadata.inside = playerData.metadata.inside or {
        house = nil,
        apartment = {
            apartmentType = nil,
            apartmentId = nil,
        }
    }
    playerData.metadata.phonedata = playerData.metadata.phonedata or {
        SerialNumber = QBCore.Player.GenerateUniqueIdentifier('SerialNumber'),
        InstalledApps = {},
    }
    -- Job
    if playerData.job and playerData.job.name and not QBCore.Shared.Jobs[playerData.job.name] then playerData.job = nil end
    playerData.job = playerData.job or {}
    playerData.job.name = playerData.job.name or 'unemployed'
    playerData.job.label = playerData.job.label or 'Civilian'
    playerData.job.payment = playerData.job.payment or 10
    playerData.job.type = playerData.job.type or 'none'
    if QBCore.Shared.ForceJobDefaultDutyAtLogin or playerData.job.onduty == nil then
        playerData.job.onduty = QBCore.Shared.Jobs[playerData.job.name].defaultDuty
    end
    playerData.job.isboss = playerData.job.isboss or false
    playerData.job.grade = playerData.job.grade or {}
    playerData.job.grade.name = playerData.job.grade.name or 'Freelancer'
    playerData.job.grade.level = playerData.job.grade.level or 0
    -- Gang
    if playerData.gang and playerData.gang.name and not QBCore.Shared.Gangs[playerData.gang.name] then playerData.gang = nil end
    playerData.gang = playerData.gang or {}
    playerData.gang.name = playerData.gang.name or 'none'
    playerData.gang.label = playerData.gang.label or 'No Gang Affiliation'
    playerData.gang.isboss = playerData.gang.isboss or false
    playerData.gang.grade = playerData.gang.grade or {}
    playerData.gang.grade.name = playerData.gang.grade.name or 'none'
    playerData.gang.grade.level = playerData.gang.grade.level or 0
    -- Other
    playerData.position = playerData.position or QBConfig.DefaultSpawn
    playerData.items = GetResourceState('qb-inventory') ~= 'missing' and exports['qb-inventory']:LoadInventory(playerData.source, playerData.citizenid) or {}
    return QBCore.Player.CreatePlayer(playerData --[[@as PlayerData]], Offline)
end

---On player logout
---@param source Source
function playerObj.Logout(source)
    TriggerClientEvent('QBCore:Client:OnPlayerUnload', source)
    TriggerEvent('QBCore:Server:OnPlayerUnload', source)

    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local newHunger = player.PlayerData.metadata.hunger - QBCore.Config.Player.HungerRate
    local newThirst = player.PlayerData.metadata.thirst - QBCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    player.Functions.SetMetaData('thirst', newThirst)
    player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', source, newHunger, newThirst)
    player.Functions.Save()

    Wait(200)
    QBCore.Players[source] = nil
    GlobalState.PlayerCount -= 1
    TriggerClientEvent('qbx-core:client:playerLoggedOut', source)
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
---@param playerData PlayerData
---@param Offline boolean
---@return Player player
function playerObj.CreatePlayer(playerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = playerData
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
        TriggerEvent('QBCore:Server:SetDuty', self.PlayerData.source, self.PlayerData.job.onduty)
        TriggerClientEvent('QBCore:Client:SetDuty', self.PlayerData.source, self.PlayerData.job.onduty)
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
        if meta == 'inlaststand' or meta == 'isdead' then
            self.Functions.Save()
        end
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

    if not self.Offline then
        QBCore.Players[self.PlayerData.source] = self
        QBCore.Player.Save(self.PlayerData.source)

        -- At this point we are safe to emit new instance to third party resource for load handling
        GlobalState.PlayerCount += 1
        self.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:PlayerLoaded', self)
    end

    return self
end

---Save player info to database (make sure citizenid is the primary key in your database)
---@param source Source
function playerObj.Save(source)
     local ped = GetPlayerPed(source)
    local playerData = QBCore.Players[source].PlayerData
    local pcoords = playerData.position
    if not Player(source)?.state.inApartment and not Player(source)?.state.inProperty then
        pcoords = vec4(GetEntityCoords(ped), GetEntityHeading(ped))
    end
    if not playerData then
        lib.print.error('QBCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        return
    end

    playerData.metadata.health = GetEntityHealth(ped)
    playerData.metadata.armor = GetPedArmour(ped)

    CreateThread(function()
        UpsertPlayerEntity({
            playerEntity = playerData,
            position = pcoords,
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(source) end
    lib.print.verbose(('%s PLAYER SAVED!'):format(playerData.name))
end

---@param playerData PlayerEntity
function playerObj.SaveOffline(playerData)
    if not playerData then
        lib.print.error('QBCORE.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
        return
    end

    CreateThread(function()
        UpsertPlayerEntity({
            playerEntity = playerData,
            position = playerData.position.xyz
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(playerData, true) end
    lib.print.verbose(('%s OFFLINE PLAYER SAVED!'):format(playerData.name))
end

---@param source Source
---@param citizenid string
function playerObj.DeleteCharacter(source, citizenid)
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
function playerObj.ForceDeleteCharacter(citizenid)
    local result = FetchPlayerEntity(citizenid).license
    if result then
        local player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        if player then
            DropPlayer(player.PlayerData.source --[[@as string]], "An admin deleted the character which you are currently using")
        end

        CreateThread(function()
            local success = DeletePlayerEntity(citizenid)
            if success then
                TriggerEvent('qb-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

---Generate unique values for player identifiers
---@param type UniqueIdType The type of unique value to generate
---@return string | number UniqueVal unique value generated
function playerObj.GenerateUniqueIdentifier(type)
    local isUnique, uniqueId
    local table = QBConfig.Player.IdentifierTypes[type]
    repeat
        uniqueId = table.valueFunction()
        isUnique = FetchIsUnique(type, uniqueId)
    until isUnique
    return uniqueId
end

return playerObj