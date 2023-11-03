Config = {}

Config.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48. Only works for server
Config.DefaultSpawn = vec4(-540.58, -212.02, 37.65, 208.88)
Config.UpdateInterval = 5 -- how often to update player data in minutes
Config.StatusInterval = 5 -- how often to check hunger/thirst status in minutes

Config.Characters = {}
Config.LoadingModelsTimeout = 10000 -- Waiting time for ox_lib to load the models before throws an error, for low specs pc
Config.Characters.UseExternalCharacters = false -- Whether you have an external character management resource. (If true, disables the character management inside the core)
Config.Characters.EnableDeleteButton = true -- Whether players should be able to delete characters themselves.
Config.Characters.StartingApartment = true -- If set to false, skips apartment choice in the beginning (requires qbx_spawn if true)
Config.Characters.DefaultNumberOfCharacters = 3 -- Define maximum amount of default characters (maximum 3 characters defined by default)
Config.Characters.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    ['license2:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 5,
}
Config.Characters.ProfanityWords = {
    ['bad word'] = true
}
Config.Characters.Locations = { -- Spawn locations for multichar, these are chosen randomly
    {
        pedCoords = vec4(969.25, 72.61, 116.18, 276.55),
        camCoords = vec4(972.2, 72.9, 116.68, 97.27),
    },
    {
        pedCoords = vec4(1104.49, 195.9, -49.44, 44.22),
        camCoords = vec4(1102.29, 198.14, -48.86, 225.07),
    },
    {
        pedCoords = vec4(-2163.87, 1134.51, -24.37, 310.05),
        camCoords = vec4(-2161.7, 1136.4, -23.77, 131.52),
    },
    {
        pedCoords = vec4(-996.71, -68.07, -99.0, 57.61),
        camCoords = vec4(-999.90, -66.30, -98.45, 241.68),
    },
    {
        pedCoords = vec4(-1023.45, -418.42, 67.66, 205.69),
        camCoords = vec4(-1021.8, -421.7, 68.14, 27.11),
    },
    {
        pedCoords = vec4(2265.27, 2925.02, -84.8, 267.77),
        camCoords = vec4(2268.24, 2925.02, -84.36, 90.88),
    }
}

Config.Money = {}

---@alias MoneyType 'cash' | 'bank' | 'crypto'
---@alias Money {cash: number, bank: number, crypto: number}
---@type Money
Config.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 } -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!

Config.Money.DontAllowMinus = { 'cash', 'crypto' } -- Money that is not allowed going in minus
Config.Money.PaycheckTimeout = 10 -- The time in minutes that it will give the paycheck
Config.Money.PaycheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management

Config.Player = {}
Config.Player.HungerRate = 4.2 -- Rate at which hunger goes down.
Config.Player.ThirstRate = 3.8 -- Rate at which thirst goes down.

---@enum BloodType
Config.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
}

---@alias UniqueIdType 'citizenid' | 'AccountNumber' | 'PhoneNumber' | 'FingerId' | 'WalletId' | 'SerialNumber'
---@type table<UniqueIdType, {valueFunction: function}>
Config.Player.IdentifierTypes = {
    citizenid = {
        valueFunction = function()
            return tostring(RandomLetter(3) .. RandomNumber(5)):upper()
        end,
    },
    AccountNumber = {
        valueFunction = function()
            return 'US0' .. math.random(1, 9) .. 'QBX' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
        end,
    },
    PhoneNumber = {
        valueFunction = function()
            return math.random(100,999) .. math.random(1000000,9999999)
        end,
    },
    FingerId = {
        valueFunction = function()
            return tostring(RandomLetter(2) .. RandomNumber(3) .. RandomLetter(1) .. RandomNumber(2) .. RandomLetter(3) .. RandomNumber(4))
        end,
    },
    WalletId = {
        valueFunction = function()
            return 'QB-' .. math.random(11111111, 99999999)
        end,
    },
    SerialNumber = {
        valueFunction = function()
            return math.random(11111111, 99999999)
        end,
    },
}

Config.Server = {} -- General server config
Config.Server.Closed = false -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
Config.Server.ClosedReason = "Server Closed" -- Reason message to display when people can't join the server
Config.Server.Uptime = 0 -- Time the server has been up.
Config.Server.Whitelist = false -- Enable or disable whitelist on the server
Config.Server.WhitelistPermission = 'admin' -- Permission that's able to enter the server when the whitelist is on
Config.Server.PVP = true -- Enable or disable pvp on the server (Ability to shoot other players)
Config.Server.Discord = "" -- Discord invite link
Config.Server.CheckDuplicateLicense = true -- Check for duplicate rockstar license on join
Config.Server.Permissions = { 'god', 'admin', 'mod' } -- Add as many groups as you want here after creating them in your server.cfg

Config.NotifyPosition = 'top-right' -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'

---@alias TableName string
---@alias ColumnName string

---@type table<TableName, ColumnName>
Config.CharacterDataTables = {
    players = 'citizenid',
    apartments = 'citizenid',
    bank_accounts_new = 'id',
    crypto_transactions = 'citizenid',
    phone_invoices = 'citizenid',
    phone_messages = 'citizenid',
    playerskins = 'citizenid',
    player_contacts = 'citizenid',
    player_houses = 'citizenid',
    player_mails = 'citizenid',
    player_outfits = 'citizenid',
    player_vehicles = 'citizenid',
} -- Rows to be deleted when the character is deleted

---@type { name: string, amount: integer, metadata: fun(source: number): table }
Config.StarterItems = { -- Character starting items
    { name = 'phone', amount = 1 },
    { name = 'id_card', amount = 1, metadata = function(source)
            if GetResourceState("qbx_idcard") ~= 'started' then
                error("qbx_idcard resource not found. Required to give an id_card as a starting item")
            end
            return exports.qbx_idcard:GetMetaLicense(source, {'id_card'})
        end
    },
    { name = 'driver_license', amount = 1, metadata = function(source)
            if GetResourceState("qbx_idcard") ~= 'started' then
                error("qbx_idcard resource not found. Required to give an id_card as a starting item")
            end
            return exports.qbx_idcard:GetMetaLicense(source, {'driver_license'})
        end
    },
}
