local config = require 'config.server'
local defaultSpawn = require 'config.shared'.defaultSpawn
local logger = require 'modules.logger'
local storage = require 'server.storage.main'
local maxJobsPerPlayer = GetConvarInt('qbx:max_jobs_per_player', 1)
local maxGangsPerPlayer = GetConvarInt('qbx:max_gangs_per_player', 1)
local setJobReplaces = GetConvar('qbx:setjob_replaces', 'true') == 'true'
local setGangReplaces = GetConvar('qbx:setgang_replaces', 'true') == 'true'

---@class PlayerData : PlayerEntity
---@field jobs table<string, integer>
---@field gangs table<string, integer>
---@field source? Source present if player is online
---@field optin? boolean present if player is online

---@param source Source
---@param citizenid? string
---@param newData? PlayerEntity
---@return boolean success
function Login(source, citizenid, newData)
    if not source or source == '' then
        lib.print.error('No source given at login stage')
        return false
    end

    if citizenid then
        local license, license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license'), GetPlayerIdentifierByType(source --[[@as string]], 'license2')
        local playerData = storage.fetchPlayerEntity(citizenid)
        if playerData and (license2 == playerData.license or license == playerData.license) then
            return not not CheckPlayerData(source, playerData)
        else
            DropPlayer(tostring(source), locale('info.exploit_dropped'))
            logger.log({
                source = 'qbx_core',
                webhook = config.logging.webhook.anticheat,
                event = 'Anti-Cheat',
                color = 'white',
                tags = config.logging.role,
                message = ('%s has been dropped for character joining exploit'):format(GetPlayerName(source))
            })
        end
    else
        local player = CheckPlayerData(source, newData)
        player.Functions.Save()
        return true
    end

    return false
end

exports('Login', Login)

---@param citizenid string
---@return Player? player if found in storage
function GetOfflinePlayer(citizenid)
    if not citizenid then return end
    local playerData = storage.fetchPlayerEntity(citizenid)
    if not playerData then return end
    return CheckPlayerData(nil, playerData)
end

exports('GetOfflinePlayer', GetOfflinePlayer)

---@param jobName string
---@param job Job
---@param grade integer
---@return PlayerJob
local function toPlayerJob(jobName, job, grade)
    return {
        name = jobName,
        label = job.label,
        isboss = job.grades[grade].isboss or false,
        onduty = job.defaultDuty or false,
        payment = job.grades[grade].payment or 0,
        type = job.type,
        grade = {
            name = job.grades[grade].name,
            level = grade
        }
    }
end

---Sets a player's job to be primary only if they already have it.
---@param citizenid string
---@param jobName string
function SetPlayerPrimaryJob(citizenid, jobName)
    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))

    local grade = jobName == 'unemployed' and 0 or player.PlayerData.jobs[jobName]
    assert(grade ~= nil, string.format('player %s does not have job %s', citizenid, jobName))

    local job = GetJob(jobName)
    assert(job ~= nil, 'job not found: ' .. jobName)
    assert(job.grades[grade] ~= nil, string.format('job %s does not have grade %s', jobName, grade))

    player.PlayerData.job = toPlayerJob(jobName, job, grade)
    player.Functions.Save()
    if not player.Offline then
        player.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:OnJobUpdate', player.PlayerData.source, player.PlayerData.job)
        TriggerClientEvent('QBCore:Client:OnJobUpdate', player.PlayerData.source, player.PlayerData.job)
    end
end

exports('SetPlayerPrimaryJob', SetPlayerPrimaryJob)

---Adds a player to the job or overwrites their grade for a job already held
---@param citizenid string
---@param jobName string
---@param grade integer
function AddPlayerToJob(citizenid, jobName, grade)
    -- unemployed job is the default, so players cannot be added to it
    if jobName == 'unemployed' then return end
    local job = GetJob(jobName)
    assert(job ~= nil, 'job not found: ' .. jobName)
    assert(job.grades[grade] ~= nil, string.format('job %s does not have grade %s', jobName, grade))

    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))
    if player.PlayerData.jobs[jobName] == grade then return end
    assert(qbx.table.size(player.PlayerData.jobs) < maxJobsPerPlayer or player.PlayerData.jobs[jobName], 'player already has maximum amount of jobs allowed')

    storage.addPlayerToJob(citizenid, jobName, grade)
    if not player.Offline then
        player.PlayerData.jobs[jobName] = grade
        player.Functions.SetPlayerData('jobs', player.PlayerData.jobs)
        TriggerEvent('qbx_core:server:onGroupUpdate', player.PlayerData.source, jobName, grade)
        TriggerClientEvent('qbx_core:client:onGroupUpdate', player.PlayerData.source, jobName, grade)
    end
    if player.PlayerData.job.name == jobName then
        SetPlayerPrimaryJob(citizenid, jobName)
    end
end

exports('AddPlayerToJob', AddPlayerToJob)

---If the job removed from is primary, sets the primary job to unemployed.
---@param citizenid string
---@param jobName string
function RemovePlayerFromJob(citizenid, jobName)
    -- Unemployed is the default job, so players cannot be removed from it.
    if jobName == 'unemployed' then return end
    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))

    if not player.PlayerData.jobs[jobName] then return end

    storage.removePlayerFromJob(citizenid, jobName)
    player.PlayerData.jobs[jobName] = nil
    if player.PlayerData.job.name == jobName then
        local job = GetJob('unemployed')
        assert(job ~= nil, 'cannot find unemployed job. Does it exist in shared/jobs.lua?')
        player.PlayerData.job = toPlayerJob('unemployed', job, 0)
        player.Functions.Save()
    end

    if not player.Offline then
        player.Functions.SetPlayerData('jobs', player.PlayerData.jobs)
        TriggerEvent('qbx_core:server:onGroupUpdate', player.PlayerData.source, jobName)
        TriggerClientEvent('qbx_core:client:onGroupUpdate', player.PlayerData.source, jobName)
    end
end

exports('RemovePlayerFromJob', RemovePlayerFromJob)

---Sets a player's gang to be primary only if they already have it.
---@param citizenid string
---@param gangName string
local function setPlayerPrimaryGang(citizenid, gangName)
    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))

    local grade = gangName == 'none' and 0 or player.PlayerData.gangs[gangName]
    assert(grade ~= nil, string.format('player %s does not have gang %s', citizenid, gangName))

    local gang = GetGang(gangName)
    assert(gang ~= nil, 'gang not found: ' .. gangName)
    assert(gang.grades[grade] ~= nil, string.format('gang %s does not have grade %s', gangName, grade))

    player.PlayerData.gang = {
        name = gangName,
        label = gang.label,
        isboss = gang.grades[grade].isboss,
        grade = {
            name = gang.grades[grade].name,
            level = grade
        }
    }

    player.Functions.Save()

    if not player.Offline then
        player.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:OnGangUpdate', player.PlayerData.source, player.PlayerData.gang)
        TriggerClientEvent('QBCore:Client:OnGangUpdate', player.PlayerData.source, player.PlayerData.gang)
    end
end

exports('SetPlayerPrimaryGang', setPlayerPrimaryGang)

---Adds a player to the gang or overwrites their grade if already in the gang
---@param citizenid string
---@param gangName string
---@param grade integer
function AddPlayerToGang(citizenid, gangName, grade)
    -- None is the default gang, so players cannot be added to it.
    if gangName == 'none' then return end

    local gang = GetGang(gangName)
    assert(gang ~= nil, 'gang not found: ' .. gangName)
    assert(gang.grades[grade] ~= nil, string.format('gang %s does not have grade %s', gangName, grade))

    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))

    if player.PlayerData.gangs[gangName] == grade then return end

    assert(qbx.table.size(player.PlayerData.gangs) < maxGangsPerPlayer or player.PlayerData.gangs[gangName], 'player already has maximum amount of gangs allowed')

    storage.addPlayerToGang(citizenid, gangName, grade)
    if not player.Offline then
        player.PlayerData.gangs[gangName] = grade
        player.Functions.SetPlayerData('gangs', player.PlayerData.gangs)
        TriggerEvent('qbx_core:server:onGroupUpdate', player.PlayerData.source, gangName, grade)
        TriggerClientEvent('qbx_core:client:onGroupUpdate', player.PlayerData.source, gangName, grade)
    end
    if player.PlayerData.gang.name == gangName then
        setPlayerPrimaryGang(citizenid, gangName)
    end
end

exports('AddPlayerToGang', AddPlayerToGang)

---Remove a player from a gang, setting them to the default no gang.
---@param citizenid string
---@param gangName string
local function removePlayerFromGang(citizenid, gangName)
    -- None is the default gang. So players cannot be removed from it.
    if gangName == 'none' then return end

    local player = GetPlayerByCitizenId(citizenid) or GetOfflinePlayer(citizenid)
    assert(player ~= nil, string.format('player not found with citizenid %s', citizenid))
    if not player.PlayerData.gangs[gangName] then return end

    storage.removePlayerFromGang(citizenid, gangName)
    player.PlayerData.gangs[gangName] = nil
    if player.PlayerData.gang.name == gangName then
        local gang = GetGang('none')
        assert(gang ~= nil, 'cannot find none gang. Does it exist in shared/gangs.lua?')
        player.PlayerData.gang = {
            name = 'none',
            label = gang.label,
            isboss = false,
            grade = {
                name = gang.grades[0].name,
                level = 0
            }
        }
        player.Functions.Save()
    end

    if not player.Offline then
        player.Functions.SetPlayerData('gangs', player.PlayerData.gangs)
        TriggerEvent('qbx_core:server:onGroupUpdate', player.PlayerData.source, gangName)
        TriggerClientEvent('qbx_core:client:onGroupUpdate', player.PlayerData.source, gangName)
    end
end

exports('RemovePlayerFromGang', removePlayerFromGang)

---@param source? integer if player is online
---@param playerData? PlayerEntity|PlayerData
---@return Player player
function CheckPlayerData(source, playerData)
    playerData = playerData or {}
    local playerState = Player(source)?.state
    local Offline = true
    if source then
        playerData.source = source
        playerData.license = playerData.license or GetPlayerIdentifierByType(source --[[@as string]], 'license2') or GetPlayerIdentifierByType(source --[[@as string]], 'license')
        playerData.name = GetPlayerName(source)
        Offline = false
    end

    playerData.citizenid = playerData.citizenid or GenerateUniqueIdentifier('citizenid')
    playerData.cid = playerData.charinfo?.cid or playerData.cid or 1
    playerData.money = playerData.money or {}
    playerData.optin = playerData.optin or true
    for moneytype, startamount in pairs(config.money.moneyTypes) do
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
    playerData.charinfo.phone = playerData.charinfo.phone or GenerateUniqueIdentifier('PhoneNumber')
    playerData.charinfo.account = playerData.charinfo.account or GenerateUniqueIdentifier('AccountNumber')
    playerData.charinfo.cid = playerData.charinfo.cid or playerData.cid
    -- Metadata
    playerData.metadata = playerData.metadata or {}
    playerData.metadata.health = playerData.metadata.health or 200
    playerData.metadata.hunger = playerData.metadata.hunger or 100
    playerData.metadata.thirst = playerData.metadata.thirst or 100
    playerData.metadata.stress = playerData.metadata.stress or 0
    if playerState then
        playerState:set('hunger', playerData.metadata.hunger, true)
        playerState:set('thirst', playerData.metadata.thirst, true)
        playerState:set('stress', playerData.metadata.stress, true)
    end

    playerData.metadata.isdead = playerData.metadata.isdead or false
    playerData.metadata.inlaststand = playerData.metadata.inlaststand or false
    playerData.metadata.armor = playerData.metadata.armor or 0
    playerData.metadata.ishandcuffed = playerData.metadata.ishandcuffed or false
    playerData.metadata.tracker = playerData.metadata.tracker or false
    playerData.metadata.injail = playerData.metadata.injail or 0
    playerData.metadata.jailitems = playerData.metadata.jailitems or {}
    playerData.metadata.status = playerData.metadata.status or {}
    playerData.metadata.phone = playerData.metadata.phone or {}
    playerData.metadata.bloodtype = playerData.metadata.bloodtype or config.player.bloodTypes[math.random(1, #config.player.bloodTypes)]
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
    playerData.metadata.fingerprint = playerData.metadata.fingerprint or GenerateUniqueIdentifier('FingerId')
    playerData.metadata.walletid = playerData.metadata.walletid or GenerateUniqueIdentifier('WalletId')
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
        SerialNumber = GenerateUniqueIdentifier('SerialNumber'),
        InstalledApps = {},
    }
    local jobs, gangs = storage.fetchPlayerGroups(playerData.citizenid)

    local job = GetJob(playerData.job?.name) or GetJob('unemployed')
    assert(job ~= nil, 'Unemployed job not found. Does it exist in shared/jobs.lua?')
    local jobGrade = GetJob(playerData.job?.name) and playerData.job.grade.level or 0

    playerData.job = {
        name = playerData.job?.name or 'unemployed',
        label = job.label,
        payment = job.grades[jobGrade].payment or 0,
        type = job.type,
        onduty = playerData.job?.onduty or false,
        isboss = job.grades[jobGrade].isboss or false,
        grade = {
            name = job.grades[jobGrade].name,
            level = jobGrade,
        }
    }
    if QBX.Shared.ForceJobDefaultDutyAtLogin and (job.defaultDuty ~= nil) then
        playerData.job.onduty = job.defaultDuty
    end

    playerData.jobs = jobs or {}
    local gang = GetGang(playerData.gang?.name) or GetGang('none')
    assert(gang ~= nil, 'none gang not found. Does it exist in shared/gangs.lua?')
    local gangGrade = GetGang(playerData.gang?.name) and playerData.gang.grade.level or 0
    playerData.gang = {
        name = playerData.gang?.name or 'none',
        label = gang.label,
        isboss = gang.grades[gangGrade].isboss or false,
        grade = {
            name = gang.grades[gangGrade].name,
            level = gangGrade
        }
    }
    playerData.gangs = gangs or {}
    playerData.position = playerData.position or defaultSpawn
    playerData.items = GetResourceState('qb-inventory') ~= 'missing' and exports['qb-inventory']:LoadInventory(playerData.source, playerData.citizenid) or {}
    return CreatePlayer(playerData --[[@as PlayerData]], Offline)
end

---On player logout
---@param source Source
function Logout(source)
    local player = GetPlayer(source)
    if not player then return end
    local playerState = Player(source)?.state
    player.PlayerData.metadata.hunger = playerState?.hunger or player.PlayerData.metadata.hunger
    player.PlayerData.metadata.thirst = playerState?.thirst or player.PlayerData.metadata.thirst
    player.PlayerData.metadata.stress = playerState?.stress or player.PlayerData.metadata.stress

    TriggerClientEvent('QBCore:Client:OnPlayerUnload', source)
    TriggerEvent('QBCore:Server:OnPlayerUnload', source)

    player.PlayerData.lastLoggedOut = os.time()
    player.Functions.Save()

    Wait(200)
    QBX.Players[source] = nil
    GlobalState.PlayerCount -= 1
    TriggerClientEvent('qbx_core:client:playerLoggedOut', source)
end

exports('Logout', Logout)

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
---@field Save fun()
---@field Logout fun()

---Create a new character
---Don't touch any of this unless you know what you are doing
---Will cause major issues!
---@param playerData PlayerData
---@param Offline boolean
---@return Player player
function CreatePlayer(playerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = playerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end -- Unsupported for Offline Players
        TriggerEvent('QBCore:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('QBCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    ---Overwrites current primary job with a new job. Removing the player from their current primary job
    ---@param jobName string name
    ---@param grade? integer defaults to 0
    ---@return boolean success if job was set
    function self.Functions.SetJob(jobName, grade)
        jobName = jobName:lower()
        grade = grade or 0
        local job = GetJob(jobName)
        if not job then
            lib.print.error(('cannot set job. Job %s does not exist'):format(jobName))
            return false
        end
        if not job.grades[grade] then
            lib.print.error(('cannot set job. Job %s does not have grade %s'):format(jobName, grade))
            return false
        end
        if setJobReplaces then
            RemovePlayerFromJob(self.PlayerData.citizenid, self.PlayerData.job.name)
        end
        AddPlayerToJob(self.PlayerData.citizenid, jobName, grade)
        SetPlayerPrimaryJob(self.PlayerData.citizenid, jobName)
        return true
    end

    ---Removes the player from their current primary gang and adds the player to the new gang
    ---@param gangName string name
    ---@param grade? integer defaults to 0
    ---@return boolean success if gang was set
    function self.Functions.SetGang(gangName, grade)
        gangName = gangName:lower()
        grade = grade or 0
        local gang = GetGang(gangName)
        if not gang then
            lib.print.error(('cannot set gang. Gang %s does not exist'):format(gangName))
            return false
        end
        if not gang.grades[grade] then
            lib.print.error(('cannot set gang. Gang %s does not have grade %s'):format(gangName, grade))
            return false
        end
        if setGangReplaces then
            removePlayerFromGang(self.PlayerData.citizenid, self.PlayerData.gang.name)
        end
        AddPlayerToGang(self.PlayerData.citizenid, gangName, grade)
        setPlayerPrimaryGang(self.PlayerData.citizenid, gangName)
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
        if (meta == 'hunger' or meta == 'thirst' or meta == 'stress') and self.PlayerData.source then
            val = lib.math.clamp(val, 0, 100)
            Player(self.PlayerData.source).state:set(meta, val, true)
        end

        local oldVal = self.PlayerData.metadata[meta]
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
        if meta == 'inlaststand' or meta == 'isdead' then
            self.Functions.Save()
        end
        TriggerClientEvent('qbx_core:client:onSetMetaData', self.PlayerData.source, meta, oldVal, val)
        TriggerEvent('qbx_core:server:onSetMetaData', meta,  oldVal, val, self.PlayerData.source)
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
        amount = qbx.math.round(tonumber(amount) --[[@as number]])
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            local tags = amount > 100000 and config.logging.role or nil
            logger.log({
                source = 'qbx_core',
                webhook = config.logging.webhook['playermoney'],
                event = 'AddMoney',
                color = 'lightgreen',
                tags = tags,
                message = ('**%s (citizenid: %s | id: %s)** $%s (%s) added, new %s balance: $%s reason: %s'):format(GetPlayerName(self.PlayerData.source), self.PlayerData.citizenid, self.PlayerData.source, amount, moneytype, moneytype, self.PlayerData.money[moneytype], reason),
            })
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was removed
    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = qbx.math.round(tonumber(amount) --[[@as number]])
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(config.money.dontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            local tags = amount > 100000 and config.logging.role or nil
            logger.log({
                source = 'qbx_core',
                webhook = config.logging.webhook['playermoney'],
                event = 'RemoveMoney',
                color = 'red',
                tags = tags,
                message = ('** %s (citizenid: %s | id: %s)** $%s (%s) removed, new %s balance: $%s reason: %s'):format(GetPlayerName(self.PlayerData.source), self.PlayerData.citizenid, self.PlayerData.source, amount, moneytype, moneytype, self.PlayerData.money[moneytype], reason),
            })
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was set
    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = qbx.math.round(tonumber(amount) --[[@as number]])
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            logger.log({
                source = 'qbx_core',
                webhook = config.logging.webhook['playermoney'],
                event = 'SetMoney',
                color = 'green',
                message = ('**%s (citizenid: %s | id: %s)** $%s (%s) set, new %s balance: $%s reason: %s'):format(GetPlayerName(self.PlayerData.source), self.PlayerData.citizenid, self.PlayerData.source, amount, moneytype, moneytype, self.PlayerData.money[moneytype], reason),
            })
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
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

    function self.Functions.Save()
        if self.Offline then
            SaveOffline(self.PlayerData)
        else
            Save(self.PlayerData.source)
        end
    end

    ---@deprecated call exports.qbx_core:Logout(source)
    function self.Functions.Logout()
        if self.Offline then return end -- Unsupported for Offline Players
        Logout(self.PlayerData.source)
    end

    AddEventHandler('qbx_core:server:onJobUpdate', function(jobName, job)
        if self.PlayerData.job.name ~= jobName then return end
        if not job then
            self.Functions.setJob('unemployed', 0)
            return
        end
        self.PlayerData.job.label = job.label
        self.PlayerData.job.type = job.type or 'none'
        local jobGrade = job.grades[self.PlayerData.job.grade.level]
        if jobGrade then
            self.PlayerData.job.grade.name = jobGrade.name
            self.PlayerData.job.payment = jobGrade.payment or 30
            self.PlayerData.job.isboss = jobGrade.isboss or false
        else
            self.PlayerData.job.grade = {
                name = 'No Grades',
                level = 0,
                payment = 30,
                isboss = false,
            }
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('QBCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end
    end)

    AddEventHandler('qbx_core:server:onGangUpdate', function(gangName, gang)
        if self.PlayerData.gang.name ~= gangName then return end
        if not gang then
            self.PlayerData.gang = {
                name = 'none',
                label = 'No Gang Affiliation',
                isboss = false,
                grade = {
                    name = 'none',
                    level = 0
                }
            }
        else
            self.PlayerData.gang.label = gang.label
            local gangGrade = gang.grades[self.PlayerData.gang.grade.level]
            if gangGrade then
                self.PlayerData.gang.isboss = gangGrade.isboss or false
            else
                self.PlayerData.gang.grade = {
                    name = 'No Grades',
                    level = 0,
                }
                self.PlayerData.gang.isboss = false
            end
        end
        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('QBCore:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent('QBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end
    end)

    if not self.Offline then
        QBX.Players[self.PlayerData.source] = self
        local ped = GetPlayerPed(self.PlayerData.source)
        lib.callback.await('qbx_core:client:setHealth', self.PlayerData.source, self.PlayerData.metadata.health)
        SetPedArmour(ped, self.PlayerData.metadata.armor)
        -- At this point we are safe to emit new instance to third party resource for load handling
        GlobalState.PlayerCount += 1
        self.Functions.UpdatePlayerData()
        TriggerEvent('QBCore:Server:PlayerLoaded', self)
    end

    return self
end

exports('CreatePlayer', CreatePlayer)

---Save player info to database (make sure citizenid is the primary key in your database)
---@param source Source
function Save(source)
    local ped = GetPlayerPed(source)
    local playerData = QBX.Players[source].PlayerData
    local playerState = Player(source)?.state
    local pcoords = playerData.position
    if not playerState.inApartment and not playerState.inProperty then
        local coords = GetEntityCoords(ped)
        pcoords = vec4(coords.x, coords.y, coords.z, GetEntityHeading(ped))
    end
    if not playerData then
        lib.print.error('QBX.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
        return
    end

    playerData.metadata.health = GetEntityHealth(ped)
    playerData.metadata.armor = GetPedArmour(ped)

    if playerState.isLoggedIn then
        playerData.metadata.hunger = playerState.hunger or 0
        playerData.metadata.thirst = playerState.thirst or 0
        playerData.metadata.stress = playerState.stress or 0
    end

    CreateThread(function()
        storage.upsertPlayerEntity({
            playerEntity = playerData,
            position = pcoords,
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(source) end
    lib.print.verbose(('%s PLAYER SAVED!'):format(playerData.name))
end

exports('Save', Save)

---@param playerData PlayerEntity
function SaveOffline(playerData)
    if not playerData then
        lib.print.error('SaveOffline - PLAYERDATA IS EMPTY!')
        return
    end

    CreateThread(function()
        storage.upsertPlayerEntity({
            playerEntity = playerData,
            position = playerData.position.xyz
        })
    end)
    if GetResourceState('qb-inventory') ~= 'missing' then exports['qb-inventory']:SaveInventory(playerData, true) end
    lib.print.verbose(('%s OFFLINE PLAYER SAVED!'):format(playerData.name))
end

exports('SaveOffline', SaveOffline)

---@param source Source
---@param citizenid string
function DeleteCharacter(source, citizenid)
    local license, license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license'), GetPlayerIdentifierByType(source --[[@as string]], 'license2')
    local result = storage.fetchPlayerEntity(citizenid).license
    if license == result or license2 == result then
        CreateThread(function()
            local success = storage.deletePlayer(citizenid)
            if success then
                logger.log({
                    source = 'qbx_core',
                    webhook = config.logging.webhook['joinleave'],
                    event = 'Character Deleted',
                    color = 'red',
                    message = ('**%s** deleted **%s**...'):format(GetPlayerName(source), citizenid, source),
                })
            end
        end)
    else
        DropPlayer(tostring(source), locale('info.exploit_dropped'))
        logger.log({
            source = 'qbx_core',
            webhook = config.logging.webhook['anticheat'],
            event = 'Anti-Cheat',
            color = 'white',
            tags = config.logging.role,
            message = ('%s has been dropped for character deleting exploit'):format(GetPlayerName(source)),
        })
    end
end

---@param citizenid string
function ForceDeleteCharacter(citizenid)
    local result = storage.fetchPlayerEntity(citizenid).license
    if result then
        local player = GetPlayerByCitizenId(citizenid)
        if player then
            DropPlayer(player.PlayerData.source --[[@as string]], 'An admin deleted the character which you are currently using')
        end

        CreateThread(function()
            local success = storage.deletePlayer(citizenid)
            if success then
                logger.log({
                    source = 'qbx_core',
                    webhook = config.logging.webhook['joinleave'],
                    event = 'Character Force Deleted',
                    color = 'red',
                    message = ('Character **%s** got deleted'):format(citizenid),
                })
            end
        end)
    end
end

exports('DeleteCharacter', ForceDeleteCharacter)

---Generate unique values for player identifiers
---@param type UniqueIdType The type of unique value to generate
---@return string | number UniqueVal unique value generated
function GenerateUniqueIdentifier(type)
    local isUnique, uniqueId
    local table = config.player.identifierTypes[type]
    repeat
        uniqueId = table.valueFunction()
        isUnique = storage.fetchIsUnique(type, uniqueId)
    until isUnique
    return uniqueId
end

exports('GenerateUniqueIdentifier', GenerateUniqueIdentifier)
