return {
    updateInterval = 5, -- how often to update player data in minutes

    money = {
        ---@alias MoneyType 'cash' | 'bank' | 'crypto'
        ---@alias Money {cash: number, bank: number, crypto: number}
        ---@type Money
        moneyTypes = { cash = 500, bank = 5000, crypto = 0 }, -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
        dontAllowMinus = { 'cash', 'crypto' },                -- Money that is not allowed going in minus
        paycheckTimeout = 10,                                 -- The time in minutes that it will give the paycheck
        paycheckSociety = false                               -- If true paycheck will come from the society account that the player is employed at
    },

    player = {
        hungerRate = 4.2, -- Rate at which hunger goes down.
        thirstRate = 3.8, -- Rate at which thirst goes down.

        ---@enum BloodType
        bloodTypes = {
            'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
        },

        ---@alias UniqueIdType 'citizenid' | 'AccountNumber' | 'PhoneNumber' | 'FingerId' | 'WalletId' | 'SerialNumber'
        ---@type table<UniqueIdType, {valueFunction: function}>
        identifierTypes = {
            citizenid = {
                valueFunction = function()
                    return lib.string.random('A.......')
                end,
            },
            AccountNumber = {
                valueFunction = function()
                    return 'ORP' ..
                        math.random(1, 9) ..
                        'NP' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
                end,
            },
            PhoneNumber = {
                valueFunction = function()
                    return math.random(97, 98) .. math.random(10000000, 99999999)
                end,
            },
            FingerId = {
                valueFunction = function()
                    return lib.string.random('...............')
                end,
            },
            WalletId = {
                valueFunction = function()
                    return 'ODW-' .. math.random(11111111, 99999999)
                end,
            },
            SerialNumber = {
                valueFunction = function()
                    return math.random(11111111, 99999999)
                end,
            },
        }
    },

    ---@alias TableName string
    ---@alias ColumnName string
    ---@type [TableName, ColumnName][]
    characterDataTables = {
        { 'properties',                    'owner' },
        { 'bank_accounts_new',             'id' },
        { 'playerskins',                   'citizenid' },
        { 'player_mails',                  'citizenid' },
        { 'player_outfits',                'citizenid' },
        { 'player_vehicles',               'citizenid' },
        { 'player_groups',                 'citizenid' },
        { 'players',                       'citizenid' },
        { 'npwd_calls',                    'identifier' },
        { 'npwd_darkchat_channel_members', 'user_identifier' },
        { 'npwd_marketplace_listings',     'identifier' },
        { 'npwd_messages_participants',    'participant' },
        { 'npwd_notes',                    'identifier' },
        { 'npwd_phone_contacts',           'identifier' },
        { 'npwd_phone_gallery',            'identifier' },
        { 'npwd_twitter_tweets',           'identifier' },
        { 'npwd_twitter_profiles',         'identifier' },
        { 'npwd_match_views',              'identifier' },
        { 'npwd_match_profiles',           'identifier' },
    }, -- Rows to be deleted when the character is deleted

    server = {
        pvp = true,                              -- Enable or disable pvp on the server (Ability to shoot other players)
        closed = false,                          -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
        closedReason = 'Server Closed',          -- Reason message to display when people can't join the server
        whitelist = false,                       -- Enable or disable whitelist on the server
        whitelistPermission = 'admin',           -- Permission that's able to enter the server when the whitelist is on
        discord = '',                            -- Discord invite link
        checkDuplicateLicense = true,            -- Check for duplicate rockstar license on join
        ---@deprecated use cfg ACE system instead
        permissions = { 'god', 'admin', 'mod' }, -- Add as many groups as you want here after creating them in your server.cfg
    },

    characters = {
        playersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
            ['license2:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 5,
        },

        defaultNumberOfCharacters = 3, -- Define maximum amount of default characters (maximum 3 characters defined by default)
    },

    -- this configuration is for core events only. putting other webhooks here will have no effect
    logging = {
        webhook = {
            ['default'] =
            'https://discord.com/api/webhooks/1023597828771164280/l4_rkfFVd9kh-TeVGs8rp5CNdEfT8Z6CPKs6rtWbG1v-D40BvyNYIM5G1jiqW1CwN22Q', -- default
            ['joinleave'] =
            'https://discord.com/api/webhooks/1023600532717326336/Q9MA1-r8cpAO3V-65rXCBp-jU9eed6pZ8Yo725X__AYONV-7Y-j5YpAbQ0XIKfoOuZMQ', -- default
            ['ooc'] =
            'https://discord.com/api/webhooks/1023600625084272680/pvkb0JfkhH8n5Bsc6csgHXeQmv4P67WRmr-NFc4HZRE21d1n4_zcKsVg0_i0gM7vo2K_', -- default
            ['anticheat'] =
            'https://discord.com/api/webhooks/1023647807518802110/NYh9DMVOsL10DzDKGBWqB3Tdz3lk942pypGaYctxBlc9AE5rXNwTAmJimbqnFvicDK89', -- default
            ['playermoney'] =
            'https://discord.com/api/webhooks/1023598263502389278/1cAHqHloTvHWCDnT9TmJpKMXKdM39A3yPszWif8g1rJxYfZe-i8lhAMcKRJmYpZBI_7K', -- default
        },
        role = {}                                                                                                                        -- Role to tag for high priority logs. Roles use <@%roleid> and users/channels are <@userid/channelid>
    },

    giveVehicleKeys = function(src, plate, vehicle)
        return exports.qbx_vehiclekeys:GiveKeys(src, vehicle)
    end,

    getSocietyAccount = function(accountName)
        return exports.pefcl:getTotalBankBalanceByIdentifier(0, accountName)
    end,

    removeSocietyMoney = function(accountName, payment)
        return exports.pefcl:removeBankBalanceByIdentifier(0, { identifier = accountName, amount = payment })
    end,

    ---Paycheck function
    ---@param player Player Player object
    ---@param payment number Payment amount
    sendPaycheck = function(player, payment)
        player.Functions.AddMoney('bank', payment)
        Notify(player.PlayerData.source, locale('info.received_paycheck', payment))
    end,
}