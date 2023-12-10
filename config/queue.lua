return {
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
}
