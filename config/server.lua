return {
    updateInterval = 5, -- how often to update player data in minutes

    money = {
        ---@alias MoneyType 'cash' | 'bank' | 'crypto'
        ---@alias Money {cash: number, bank: number, crypto: number}
        ---@type Money
        moneyTypes = { cash = 500, bank = 5000, crypto = 0 }, -- type = startamount - Add or remove money types for your server (for ex. blackmoney = 0), remember once added it will not be removed from the database!
        dontAllowMinus = { 'cash', 'crypto' }, -- Money that is not allowed going in minus
        paycheckTimeout = 10, -- The time in minutes that it will give the paycheck
        paycheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires qb-management
    },

    player = {
        hungerRate = 4.2, -- Rate at which hunger goes down.
        thirstRate = 3.8, -- Rate at which thirst goes down.

        ---@enum BloodType
        bloodTypes = {
            "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-",
        },

        ---@alias UniqueIdType 'citizenid' | 'AccountNumber' | 'PhoneNumber' | 'FingerId' | 'WalletId' | 'SerialNumber'
        ---@type table<UniqueIdType, {valueFunction: function}>
        identifierTypes = {
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
    },


    ---@alias TableName string
    ---@alias ColumnName string
    ---@type table<TableName, ColumnName>
    characterDataTables = {
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
    }, -- Rows to be deleted when the character is deleted


    server = {
        pvp = true, -- Enable or disable pvp on the server (Ability to shoot other players)
        closed = false, -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
        closedReason = 'Server Closed', -- Reason message to display when people can't join the server
        whitelist = false, -- Enable or disable whitelist on the server
        whitelistPermission = 'admin', -- Permission that's able to enter the server when the whitelist is on
        discord = '', -- Discord invite link
        checkDuplicateLicense = true, -- Check for duplicate rockstar license on join
        permissions = { 'god', 'admin', 'mod' }, -- Add as many groups as you want here after creating them in your server.cfg
    },

    characters = {
        playersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
            ['license2:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 5,
        },

        defaultNumberOfCharacters = 3, -- Define maximum amount of default characters (maximum 3 characters defined by default)
    },

    ---@type { name: string, amount: integer, metadata: fun(source: number): table }[]
    starterItems = { -- Character starting items
        { name = 'phone', amount = 1 },
        { name = 'id_card', amount = 1, metadata = function(source)
                if GetResourceState('qbx_idcard') ~= 'started' then
                    error('qbx_idcard resource not found. Required to give an id_card as a starting item')
                end
                return exports.qbx_idcard:GetMetaLicense(source, {'id_card'})
            end
        },
        { name = 'driver_license', amount = 1, metadata = function(source)
                if GetResourceState('qbx_idcard') ~= 'started' then
                    error('qbx_idcard resource not found. Required to give an id_card as a starting item')
                end
                return exports.qbx_idcard:GetMetaLicense(source, {'driver_license'})
            end
        },
    },

    -- this configuration is for core events only. putting other webhooks here will have no effect
    logging = {
        webhook = {
            ['default'] = nil, -- default
            ['joinleave'] = nil, -- default
            ['ooc'] = nil, -- default
            ['anticheat'] = nil, -- default
            ['playermoney'] = nil, -- default
        },
        role = {} -- Role to tag for high priority logs. Roles use <@%roleid> and users/channels are <@userid/channelid>
    },

    giveVehicleKeys = function(src, plate)
        return exports.qbx_vehiclekeys:GiveKeys(src, plate)
    end,

    getSocietyAccount = function(accountName)
        return exports.qbx_management:GetAccount(accountName)
    end,
    
    removeSocietyMoney = function(accountName, payment)
        return exports.qbx_management:RemoveMoney(accountName, payment)
    end,

    queue = {
        ---Amount of time to wait for remove a player from the queue after disconnecting while waiting.
        timeoutSeconds = 30,

        ---Amount of time to wait for remove a player from the queue after disconnecting when installing server data.
        joinTimeoutSeconds = 30,

        clockEmojis = {
            '🕛',
            '🕒',
            '🕕',
            '🕘',
        },

        ---Queue types from most prioritized to least prioritized.
        ---The first queue without a predicate function will be used as the default.
        ---If a player doesn't pass any predicates and a queue without a predicate does not exist they will not be let into the server unless player slots are available.
        ---@type QueueType[]
        queueTypes = {
            { name = 'Priority Queue', color = 'good', predicate = function(source) return HasPermission(source, 'admin') end },
            { name = 'Regular Queue' },
        },

        ---Generator function for the queue adaptive card.
        ---@param queueType QueueType  the queue type the player is in
        ---@param currentPos integer  the current position of the player in the queue
        ---@param queueSize integer  the size of the queue
        ---@param waitingTime integer  in seconds
        ---@param clockEmoji string
        ---@return table card  queue adaptive card
        generateCard = function(queueType, currentPos, queueSize, waitingTime, clockEmoji)
            local serverName = GetConvar('sv_projectName', GetConvar('sv_hostname', 'Server'))
            local minutes = math.floor(waitingTime / 60)
            local seconds = waitingTime % 60
            local timeDisplay = ('%02d:%02d'):format(minutes, seconds)

            local progressColumn = {
                type = 'Column',
                width = 'stretch',
                items = {},
            }

            local progressAmount = 7
            local progressColumns = {}

            for i = 1, progressAmount + 2 do
                progressColumns[i] = table.clone(progressColumn)
                progressColumns[i].items = {}
            end

            progressColumns[1].items[1] = {
                type = 'TextBlock',
                text = 'Queue',
                horizontalAlignment = 'center',
                size = 'extralarge',
                weight = 'lighter',
                color = 'good',
            }
            for i = 1, progressAmount do
                progressColumns[i + 1].items[1] = {
                    type = 'TextBlock',
                    text = '•',
                    horizontalAlignment = 'center',
                    size = 'extralarge',
                    weight = 'lighter',
                    color = 'accent',
                }
            end
            progressColumns[progressAmount + 2].items[1] = {
                type = 'TextBlock',
                text = 'Server',
                horizontalAlignment = 'center',
                size = 'extralarge',
                weight = 'lighter',
                color = 'good',
            }

            local playerColumn = currentPos == 1 and progressAmount or (progressAmount - math.ceil(currentPos / (queueSize / progressAmount)) + 1)
            progressColumns[playerColumn + 1].items[1] = {
                type = 'TextBlock',
                text = 'You',
                horizontalAlignment = 'center',
                size = 'extralarge',
                weight = 'lighter',
                color = 'good',
            }

            return {
                type = 'AdaptiveCard',
                version = '1.6',
                body = {
                    {
                        type = 'TextBlock',
                        text = 'In Line',
                        horizontalAlignment = 'center',
                        size = 'large',
                        weight = 'bolder',
                    },
                    {
                        type = 'TextBlock',
                        text = ('Joining %s'):format(serverName),
                        spacing = 'none',
                        horizontalAlignment = 'center',
                        size = 'medium',
                        weight = 'bolder',
                    },
                    {
                        type = 'ColumnSet',
                        spacing = 'large',
                        columns = progressColumns,
                    },
                    {
                        type = 'ColumnSet',
                        spacing = 'large',
                        columns = {
                            {
                                type = 'Column',
                                width = 'stretch',
                                items = {
                                    {
                                        type = 'TextBlock',
                                        text = queueType.name,
                                        color = queueType.color,
                                        size = 'medium',
                                    }
                                },
                            },
                            {
                                type = 'Column',
                                width = 'stretch',
                                items = {
                                    {
                                        type = 'TextBlock',
                                        text = ('%d/%d'):format(currentPos, queueSize),
                                        horizontalAlignment = 'center',
                                        color = 'good',
                                        size = 'medium',
                                    }
                                },
                            },
                            {
                                type = 'Column',
                                width = 'stretch',
                                items = {
                                    {
                                        type = 'TextBlock',
                                        text = ('%s %s'):format(timeDisplay, clockEmoji),
                                        horizontalAlignment = 'right',
                                        size = 'medium',
                                    }
                                },
                            },
                        },
                    },
                },
            }
        end,
    },
}
