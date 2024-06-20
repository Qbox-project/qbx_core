---------------------------------------------------------------------
-- 			THIS FILE IS NOT USED FOR ITEMS ANY LONGER		       --
---------------------------------------------------------------------

local items = {}

local count = 0

print('[QBCore] Converting Inventory Items')
local file = ('data/items.lua')
local datafile = LoadResourceFile('ox_inventory', file)
local path = ('@@%s/%s'):format('ox_inventory', file)
local func, err = load(datafile, path)

local itemlist = func()

for item, data in pairs(itemlist) do
    count += 1
    items[item] = {
        name = item,
        label = data.label,
        weight = data.weight,
        type = data.type,
        image = data
            .client and (data.client.image and data.client.image) or item .. ".png",
        unique = not stackable,
        useable = false,
        shouldClose =
            data.close,
        combinable = nil,
        description = data.description
    }
end

file = ('data/weapons.lua')
datafile = LoadResourceFile('ox_inventory', file)
path = ('@@%s/%s'):format('ox_inventory', file)
func, err = load(datafile, path)

itemlist = func()

for weapon, data in pairs(itemlist.Weapons) do
    count += 1
    items[weapon:lower()] = {
        name = weapon:lower(),
        label = data.label,
        weight = data.weight,
        type = 'weapon',
        image =
            weapon:lower() .. '.png',
        unique = not weapon.stack,
        useable = false,
        description = ''
    }
end

for attach, data in pairs(itemlist.Components) do
    count += 1
    items[attach] = {
        name = attach,
        label = data.label,
        weight = data.weight,
        type = 'item',
        image = attach ..
            ".png",
        unique = false,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = ''
    }
end

for ammo, data in pairs(itemlist.Ammo) do
    count += 1
    items[ammo] = {
        name = ammo,
        label = data.label,
        weight = data.weight,
        type = 'item',
        image = ammo .. '.png',
        unique = false,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description =
        ''
    }
end

print('[QBCore] Converted ' .. count .. ' items from ox_inventory to QBCore.Shared')

return items
