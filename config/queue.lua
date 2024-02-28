local serverName = require 'config.shared'.serverName

return {
    ---Amount of seconds to wait before removing a player from the queue after disconnecting while waiting.
    timeoutSeconds = 30,

    ---Amount of seconds to wait before removing a player from the queue after disconnecting while installing server data.
    ---Notice that an additional ~2 minutes will be waited due to limitations with how FiveM handles joining players.
    joiningTimeoutSeconds = 0,

    ---@class AdaptiveCardTextOptions
    ---@field style? 'default' | 'heading' | 'columnHeader'
    ---@field fontType? 'default' | 'monospace'
    ---@field size? 'small' | 'default' | 'medium' | 'large' | 'extralarge'
    ---@field weight? 'lighter' | 'default' | 'bolder'
    ---@field color? 'default' | 'dark' | 'light' | 'accent' | 'good' | 'warning' | 'attention'
    ---@field isSubtle? boolean

    ---@class SubQueueConfig
    ---@field name string
    ---@field predicate? fun(source: Source): boolean
    ---@field cardOptions? AdaptiveCardTextOptions  Text options used in the adaptive card

    ---Sub-queues from most to least prioritized.
    ---The first sub-queue without a predicate function will be considered the default.
    ---If a player doesn't pass any predicate and a sub-queue with no predicate does not exist they will not be let into the server unless a player slot is available.
    ---@type SubQueueConfig[]
    subQueues = {
        { name = 'Admin Queue', predicate = function(source) return IsPlayerAceAllowed(source --[[@as string]], 'admin') end, cardOptions = { color = 'good' } },
        { name = 'Regular Queue' },
    },

    ---Cosmetic emojis shown along with the elapsed queue time.
    waitingEmojis = {
        '🕛',
        '🕒',
        '🕕',
        '🕘',
    },

    ---Use the adaptive card generator that is defined below.
    useAdaptiveCard = true,

    ---@class GenerateCardParams
    ---@field subQueue SubQueue
    ---@field globalPos integer
    ---@field totalQueueSize integer
    ---@field displayTime string

    ---Generator function for the adaptive card.
    ---@param params GenerateCardParams
    ---@return table
    generateCard = function(params)
        local subQueue = params.subQueue
        local pos = params.globalPos
        local size = params.totalQueueSize
        local displayTime = params.displayTime

        local cardOptions = subQueue.cardOptions or {}

        local progressAmount = 7 -- amount of progress shown between the queue & server
        local playerColumn = pos == 1 and progressAmount or (progressAmount - math.ceil(pos / (size / progressAmount)) + 1)

        local progressTextReplacements = {
            [1] = {
                text = 'Queue',
                color = 'good',
            },
            [playerColumn + 1] = {
                text = 'You',
                color = 'good',
            },
            [progressAmount + 2] = {
                text = 'Server',
                color = 'good',
            },
        }

        local progressColumns = {}
        for i = 1, progressAmount + 2 do
            local textBlock = {
                type = 'TextBlock',
                text = '•',
                horizontalAlignment = 'center',
                size = 'extralarge',
                weight = 'lighter',
                color = 'accent',
            }

            local replacements = progressTextReplacements[i]
            if replacements then
                for k, v in pairs(replacements) do
                    textBlock[k] = v
                end
            end

            local column = {
                type = 'Column',
                width = 'stretch',
                verticalContentAlignment = 'center',
                items = {
                    textBlock,
                }
            }

            progressColumns[i] = column
        end

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
                                    text = subQueue.name,
                                    style = cardOptions.style,
                                    fontType = cardOptions.fontType,
                                    size = cardOptions.size or 'medium',
                                    color = cardOptions.color,
                                    isSubtle = cardOptions.isSubtle,
                                }
                            },
                        },
                        {
                            type = 'Column',
                            width = 'stretch',
                            items = {
                                {
                                    type = 'TextBlock',
                                    text = ('%d/%d'):format(pos, size),
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
                                    text = displayTime,
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
}
