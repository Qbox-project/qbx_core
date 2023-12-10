---@class QueueType
---@field name string
---@field color string?
---@field predicate (fun(source: Source): boolean)? 

if GetConvar('qbx:enablequeue', 'true') == 'false' then return end

-- Disable hardcap because it kicks the player when the server is full

---@param resource string
AddEventHandler('onResourceStarting', function(resource)
    if resource == 'hardcap' then
        lib.print.info('Preventing hardcap from starting...')
        CancelEvent()
    end
end)

if GetResourceState('hardcap'):find('start') then
    lib.print.info('Stopping hardcap...')
    StopResource('hardcap')
end

-- Queue code

local config = require 'config.server'.queue
local maxPlayers = GlobalState.MaxPlayers

---@class SubQueue
---@field size integer
---@field positions table<string, integer>
---@field enqueue fun(self: SubQueue, license: string)
---@field dequeue fun(self: SubQueue, license: string)

local SubQueue = {}
local prototype = {}
local totalSize = 0

---@return SubQueue
function SubQueue.new()
    local self = setmetatable({}, { __index = prototype })
    self.size = 0
    self.positions = {}
    return self
end

---@param self SubQueue
---@param license string
function prototype.enqueue(self, license)
    self.size += 1
    totalSize += 1
    self.positions[license] = self.size
end

---@param self SubQueue
---@param license string
function prototype.dequeue(self, license)
    local pos = self.positions[license]
    self.positions[license] = nil
    self.size -= 1
    totalSize -= 1
    for k, v in pairs(self.positions) do
        if v > pos then
            self.positions[k] -= 1
        end
    end
end

---@type SubQueue[]
local subQueues = {}

for _ = 1, #config.queueTypes do
    subQueues[#subQueues + 1] = SubQueue.new()
end

---Returns the position of the current player in the entire queue.
---@param license string
---@param queueNum integer  the index of the sub-queue the player is in
local function calculateQueuePos(license, queueNum)
    local pos = 0
    for i = 1, queueNum-1 do
        pos += subQueues[i].size
    end
    return pos + subQueues[queueNum].positions[license]
end

---Set of players that are actively waiting in queue.
---@type table<string, true>
local queuedPlayers = {}

---Data about players that are being timed out from the queue.
---@type table<string, fun(): { queueNum:  integer, waitingTime: integer }>
local timingOut = {}

---Licenses of players that finished waiting in queue but have yet to fire the `playerJoining` event mapped to when they started joining.
---(meaning players that are still installing server data)
---@type table<string, { source: Source, timestamp: integer }>
local joiningPlayers = {}
local joiningPlayersAmount = 0

---@param source Source
---@param license string
local function updatePlayerJoining(source, license)
    if not joiningPlayers[license] then
        joiningPlayersAmount += 1
    end
    joiningPlayers[license] = { source = source, timestamp = os.time() }
end

---Registers that the player with the given license has succesfully joined.
---@param license string
local function registerPlayerJoined(license)
    if joiningPlayers[license] then
        joiningPlayersAmount -= 1
    end
    joiningPlayers[license] = nil
end

---@param license string
---@return boolean
local function wasPlayerJoining(license)
    return joiningPlayers[license] ~= nil
end

---@param source Source
---@param license string
---@param deferrals Deferrals
local function enqueue(source, license, deferrals)
    CreateThread(function()
        if wasPlayerJoining(license) then
            -- the player was in the middle of joining so let them in
            updatePlayerJoining(source, license)
            deferrals.done()
            return
        end

        if queuedPlayers[license] then
            deferrals.done('You are already in the queue.')
            return
        end

        ---@type integer
        local queueNum
        ---@type QueueType
        local queueType
        ---@type SubQueue
        local queue

        local prevData = timingOut[license] and timingOut[license]()
        if prevData then
            -- use older data if it exists
            timingOut[license] = nil
            queueNum = prevData.queueNum
            queueType = config.queueTypes[queueNum]
            queue = subQueues[queueNum]
        else
            -- select an appropriate sub-queue since there is no old data
            for i = 1, #config.queueTypes do
                queueNum = i
                queueType = config.queueTypes[i]
                local predicate = queueType.predicate
                if not predicate or predicate(source) then
                    queue = subQueues[i]
                    break
                end
            end
        end

        if not queue then
            -- player was not let into any sub-queue
            deferrals.done(Lang:t('error.no_queue'))
            return
        end

        local pos = 0
        local clockIndex = 1 -- for the emoji to update
        local waitingTime = prevData and prevData.waitingTime or 0
        if not prevData then queue:enqueue(license) end
        queuedPlayers[license] = true

        -- wait until the player disconnected or until there are available slots and the player is first in the queue
        while DoesPlayerExist(source --[[@as string]]) and ((GetNumPlayerIndices() + joiningPlayersAmount) >= maxPlayers or pos > 1) do
            pos = calculateQueuePos(license, queueNum)
            deferrals.presentCard(config.generateCard(queueType, pos, totalSize, waitingTime, config.clockEmojis[clockIndex]))

            waitingTime += 1
            clockIndex += 1
            if clockIndex > #config.clockEmojis then clockIndex = 1 end

            Wait(1000)
        end

        if not DoesPlayerExist(source --[[@as string]]) then
            -- start timing out if the player disconnected
            local dequeue = true
            timingOut[license] = function()
                dequeue = false
                return { queueNum = queueNum, waitingTime = waitingTime }
            end
            queuedPlayers[license] = nil
            Wait(config.timeoutSeconds * 1000)
            if dequeue then
                timingOut[license] = nil
                queue:dequeue(license)
            end
            return
        end

        updatePlayerJoining(source, license)
        queue:dequeue(license)
        deferrals.done()

        local joiningData
        while true do
            joiningData = joiningPlayers[license]

            -- wait until the player disconnects
            while GetPlayerPing(joiningData.source --[[@as string]]) > -1 do
                Wait(1000)
            end

            -- wait until either the player reconnects or was disconnected for too long
            while joiningPlayers[license] ~= nil and joiningPlayers[license].source == joiningData.source and (os.time() - joiningData.timestamp) < config.joinTimeoutSeconds do
                Wait(1000)
            end

            -- if the player did not reconnect then remove them
            if joiningPlayers[license] ~= nil and joiningPlayers[license].source == joiningData.source then
                registerPlayerJoined(license)
                break
            end
        end
        queuedPlayers[license] = nil
    end)
end

return {
    enqueue = enqueue,
    registerPlayerJoined = registerPlayerJoined,
}
