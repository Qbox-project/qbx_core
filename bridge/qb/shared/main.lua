local qbShared = require 'shared.main'

---Mirrors ox_inventory's own rule for giving an item a use action (modules/items/shared.lua)
---@param data table ox_inventory item definition
---@return boolean
local function isUseable(data)
    local client, server = data.client or {}, data.server or {}
    return data.consume ~= nil or client.status ~= nil or client.usetime ~= nil or client.export ~= nil or server.export ~= nil
end

qbShared.Items = {}
local oxItems = require '@ox_inventory.data.items'
for item, data in pairs(oxItems) do
    qbShared.Items[item] = {
        name = item,
        label = data.label,
        weight = data.weight or 0,
        type = 'item',
        image = data.client?.image or item .. '.png',
        unique = data.stack == false,
        useable = isUseable(data),
        shouldClose = data.close ~= false,
        combinable = nil,
        description = data.description or nil
    }
end
local oxWeapons = require '@ox_inventory.data.weapons'
for name, data in pairs(oxWeapons.Weapons) do
    local weapon = string.lower(name)
    qbShared.Items[weapon] = {
        name = weapon,
        label = data.label,
        weight = data.weight or 0,
        type = 'weapon',
        ammotype = data.ammoname or nil,
        image = data.client?.image or name .. '.png',
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = nil
    }
end
for name, data in pairs(oxWeapons.Components) do
    local component = string.lower(name)
    qbShared.Items[component] = {
        name = component,
        label = data.label,
        weight = data.weight or 0,
        type = 'component',
        image = data.client?.image or name .. '.png',
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = data.description
    }
end
for name, data in pairs(oxWeapons.Ammo) do
    local ammo = string.lower(name)
    qbShared.Items[ammo] = {
        name = ammo,
        label = data.label,
        weight = data.weight or 0,
        type = 'ammo',
        image = data.client?.image or name .. '.png',
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = data.description
    }
end

local starterItems = require 'config.shared'.starterItems
---@deprecated use starterItems in config/shared.lua
qbShared.StarterItems = {}

if type(starterItems) == 'table' then
    for i = 1, #starterItems do
        local item = starterItems[i]

        ---@diagnostic disable-next-line: deprecated
        qbShared.StarterItems[item.name] = {
            amount = item.amount,
            item = item.name,
        }
    end
end

---@deprecated use lib.math.groupdigits from ox_lib
qbShared.CommaValue = lib.math.groupdigits

---@deprecated use lib.string.random from ox_lib
qbShared.RandomStr = function(length)
    if length <= 0 then return '' end
    local pattern = math.random(2) == 1 and 'a' or 'A'

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomStr(length - 1) .. lib.string.random(pattern)
end

---@deprecated use lib.string.random from ox_lib
qbShared.RandomInt = function(length)
    if length <= 0 then return '' end

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomInt(length - 1) .. lib.string.random('1')
end

---@deprecated use string.strsplit with CfxLua 5.4
qbShared.SplitStr = function(str, delimiter)
    local result = table.pack(string.strsplit(delimiter, str))
    result.n = nil
    return result
end

---@deprecated use qbx.string.trim from modules/lib.lua
qbShared.Trim = function(str)
    if not str then return nil end
    return qbx.string.trim(str)
end

---@deprecated use qbx.string.capitalize from modules/lib.lua
qbShared.FirstToUpper = function(str)
    if not str then return nil end
    return qbx.string.capitalize(str)
end

---@deprecated use qbx.math.round from modules/lib.lua
qbShared.Round = qbx.math.round

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.ChangeVehicleExtra = qbx.setVehicleExtras

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.SetDefaultVehicleExtras = qbx.setVehicleExtras

---@deprecated use qbx.armsWithoutGloves.male from modules/lib.lua
qbShared.MaleNoGloves = qbx.armsWithoutGloves.male

---@deprecated use qbx.armsWithoutGloves.female from modules/lib.lua
qbShared.FemaleNoGloves = qbx.armsWithoutGloves.female

---@deprecated check type(value) directly
---@param value any
---@return boolean
qbShared.IsFunction = function(value)
    if type(value) == 'table' then
        return type(rawget(value, '__cfx_functionReference')) == 'string'
    end
    return type(value) == 'function'
end

return qbShared
