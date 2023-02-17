QBConfig = {}

QBConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
QBConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
QBConfig.UpdateInterval = 5 -- how often to update player data in minutes
QBConfig.StatusInterval = 5 -- how often to check hunger/thirst status in minutes

QBConfig.Money = {}

---@alias Money {cash: number, bank: number, crypto: number}
---@type Money
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!

QBConfig.Money.DontAllowMinus = { 'cash', 'crypto' } -- Money that is not allowed going in minus
QBConfig.Money.PaycheckTimeout = 10 -- The time in minutes that it will give the paycheck
QBConfig.Money.PaycheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management

QBConfig.Player = {}
QBConfig.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
QBConfig.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.

---@enum BloodType
QBConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
}

---@alias UniqueIdType 'citizenid' | 'AccountNumber' | 'PhoneNumber' | 'FingerId' | 'WalletId' | 'SerialNumber'
---@type table<UniqueIdType, {valueFunction: function}>
QBConfig.Player.IdentifierTypes = {
    ['citizenid'] = {
        valueFunction = function()
            return tostring(QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(5)):upper()
        end,
    },
    ['AccountNumber'] = {
        valueFunction = function()
            return 'US0' .. math.random(1, 9) .. 'QBCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
        end,
    },
    ['PhoneNumber'] = {
        valueFunction = function()
            return math.random(100,999) .. math.random(1000000,9999999)
        end,
    },
    ['FingerId'] = {
        valueFunction = function()
            return tostring(QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(4))
        end,
    },
    ['WalletId'] = {
        valueFunction = function()
            return 'QB-' .. math.random(11111111, 99999999)
        end,
    },
    ['SerialNumber'] = {
        valueFunction = function()
            return math.random(11111111, 99999999)
        end,
    },
}

QBConfig.Server = {} -- General server config
QBConfig.Server.Closed = false -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
QBConfig.Server.ClosedReason = "Server Closed" -- Reason message to display when people can't join the server
QBConfig.Server.Uptime = 0 -- Time the server has been up.
QBConfig.Server.Whitelist = false -- Enable or disable whitelist on the server
QBConfig.Server.WhitelistPermission = 'admin' -- Permission that's able to enter the server when the whitelist is on
QBConfig.Server.PVP = true -- Enable or disable pvp on the server (Ability to shoot other players)
QBConfig.Server.Discord = "" -- Discord invite link
QBConfig.Server.CheckDuplicateLicense = true -- Check for duplicate rockstar license on join
QBConfig.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

QBConfig.NotifyPosition = 'top-right' -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'