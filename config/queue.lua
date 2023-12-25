return {
    ---Amount of seconds to wait before removing a player from the queue after disconnecting while waiting.
    timeoutSeconds = 30,

    ---Amount of seconds to wait before removing a player from the queue after disconnecting while installing server data.
    ---Notice that an additional ~2 minutes will be waited due to limitations with how FiveM handles joining players.
    joiningTimeoutSeconds = 0,

    ---@class SubQueueConfig
    ---@field name string
    ---@field predicate? fun(source: Source): boolean

    ---Sub-queues from most to least prioritized.
    ---The first sub-queue without a predicate function will be considered the default.
    ---If a player doesn't pass any predicate and a sub-queuee with no predicate does not exist they will not be let into the server unless a player slot is available.
    ---@type SubQueueConfig[]
    subQueues = {
        { name = 'Admin Queue', predicate = function(source) return HasPermission(source, 'admin') end },
        { name = 'Regular Queue' },
    },
}
