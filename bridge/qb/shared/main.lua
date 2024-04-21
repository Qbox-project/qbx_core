local qbShared = require 'shared.main'

---@deprecated use lib.math.groupdigits from ox_lib
qbShared.CommaValue = lib.math.groupdigits

---@deprecated use lib.string.random from ox_lib
qbShared.RandomStr = function(length)
    if length <= 0 then return '' end
    local pattern = math.random(2) == 1 and 'a' or 'A'
    return qbShared.RandomStr(length - 1) .. lib.string.random(pattern)
end

---@deprecated use lib.string.random from ox_lib
qbShared.RandomInt = function(length)
    if length <= 0 then return '' end
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

local useOldItems = GetConvar('qbx:useOldItems', 'true') == 'true'

if useOldItems then
    lib.print.warn('You are using the deprecated qb-core items / weapons format!')
    lib.print.warn('If you are the author, please update your resources to use ox_inventory. If you are not, please tell them to update!')

    local damageReasons = require '@qbx_medical.config.damage_reasons'
    local weaponTypes = {
        [2685387236] = {'Melee', nil},
        [416676503] = {'Pistol', 'AMMO_PISTOL'},
        [-1609580060] = {'Pistol', 'AMMO_PISTOL'},
        [690389602] = {'Pistol', 'AMMO_STUNGUN'},
        [-957766203] = {'Submachine Gun', 'AMMO_SMG'},
        [860033945] = {'Shotgun', 'AMMO_SHOTGUN'},
        [970310034] = {'Assault Rifle', 'AMMO_RIFLE'},
        [1159398588] = {'Light Machine Gun', 'AMMO_MG'},
        [3082541095] = {'Sniper Rifle', 'AMMO_SNIPER'},
        [2725924767] = {'Heavy Weapons', nil},
        [1548507267] = {'Throwable', nil},
        [4257178988] = {'Miscellaneous', nil}
    }
    local ammoTypes = {
        [`weapon_flaregun`] = 'AMMO_FLARE',
        [`weapon_machinepistol`] = 'AMMO_PISTOL',
        [`weapon_remotesniper`] = 'AMMO_SNIPER_REMOTE',
        [`weapon_rpg`] = 'AMMO_RPG',
        [`weapon_grenadelauncher`] = 'AMMO_GRENADELAUNCHER',
        [`weapon_minigun`] = 'AMMO_MINIGUN',
        [`weapon_hominglauncher`] = 'AMMO_STINGER',
        [`weapon_rayminigun`] = 'AMMO_MINIGUN',
        [`weapon_emplauncher`] = 'AMMO_EMPLAUNCHER',
        [`weapon_ball`] = 'AMMO_BALL',
        [`weapon_flare`] = 'AMMO_FLARE',
        [`weapon_petrolcan`] = 'AMMO_PETROLCAN',
        [`weapon_hazardcan`] = 'AMMO_PETROLCAN',
        ['weapon_fertilizercan'] = 'AMMO_FERTILIZERCAN'
    }

    for name, data in pairs(qbShared.Items) do
        qbShared.Items[name].name = name
        qbShared.Items[name].type = 'item'
        qbShared.Items[name].image = name .. ".png"
        qbShared.Items[name].unique = not data.stack
        qbShared.Items[name].useable = false
        qbShared.Items[name].shouldClose = data.close

        if not data.description then
            qbShared.Items[name].description = ''
        end
    end

    for hash, data in pairs(qbShared.WeaponHashes) do
        local weaponType = lib.context == 'client' and weaponTypes[GetWeapontypeGroup(hash)]

        data.weapontype = weaponType and weaponType[1] or 'Weapon'
        data.ammotype = ammoTypes[hash] or (weaponType and weaponType[2])
        data.damagereason = damageReasons[hash]

        qbShared.Weapons[hash] = data
        qbShared.Items[data.name:lower()] = { name = data.name:lower(), label = data.label, weight = data.weight, type = 'weapon', image = data.name:lower() .. '.png', unique = not data.stack, useable = false, description = '' }
    end

    for name, data in pairs(qbShared.Components) do
        qbShared.Items[name] = { name = name, label = data.label, weight = data.weight, type = 'item', image = name .. ".png", unique = false, useable = true, shouldClose = true, combinable = nil, description = '' }
    end

    for name, data in pairs(qbShared.AmmoTypes) do
        qbShared.Items[name] = { name = name, label = data.label, weight = data.weight, type = 'item', image = name .. ".png", unique = false, useable = true, shouldClose = true, combinable = nil, description = '' }
    end
end

return qbShared