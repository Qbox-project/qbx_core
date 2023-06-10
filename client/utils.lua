-- MIT License

-- Copyright (c) 2022 Overextended

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local utils = {}

---@async
function utils.waitFor(cb, timeout)
    local hasValue = cb()
    local i = 0

    while not hasValue do
        if timeout then
            i += 1

            if i > timeout then return end
        end

        Wait(0)
        hasValue = cb()
    end

    return hasValue
end

---@async
---@param bagName string
---@return integer?, integer
function utils.getEntityAndNetIdFromBagName(bagName)
    local netId = tonumber(bagName:gsub('entity:', ''), 10)

    if not utils.waitFor(function()
        return NetworkDoesEntityExistWithNetworkId(netId)
    end, 10000) then
        return print(('statebag timed out while awaiting entity creation! (%s)'):format(bagName)), 0
    end

    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return print(('statebag received invalid entity! (%s)'):format(bagName)), 0
    end

    return entity, netId
end

---@param keyFilter string
---@param cb fun(entity: number, netId: number, value: any, bagName: string)
---@return number
function utils.entityStateHandler(keyFilter, cb)
    return AddStateBagChangeHandler(keyFilter, '', function(bagName, _, value)
        local entity, netId = utils.getEntityAndNetIdFromBagName(bagName)

        if entity then
            cb(entity, netId, value, bagName)
        end
    end)
end

return utils
