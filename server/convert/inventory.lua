-- QBCore conversion ported from ox_inventory: https://github.com/overextended/ox_inventory/blob/972e59f542f8aba5f0a3b9639805bbddaced71cb/setup/convert.lua
-- Copyright (c) 2024 Overextended

local maxStashNameLength = 100
local evidenceSlots = 100
local converting = false

local qbAmmoItems = {
    pistol_ammo = true,
    rifle_ammo = true,
    smg_ammo = true,
    shotgun_ammo = true,
    mg_ammo = true,
    snp_ammo = true,
    emp_ammo = true,
}

local legacyTables = {
    { name = 'stashitems', query = 'SELECT stash AS identifier, items FROM stashitems' },
    { name = 'trunkitems', query = 'SELECT CONCAT(\'trunk-\', plate) AS identifier, items FROM trunkitems' },
    { name = 'gloveboxitems', query = 'SELECT CONCAT(\'glovebox-\', plate) AS identifier, items FROM gloveboxitems' },
}

local itemCache = {}

---@param value any
---@return integer?
local function toInteger(value)
    value = tonumber(value)
    return value and math.tointeger(value)
end

---@param str string
---@return string
local function trim(str)
    return str:match('^%s*(.-)%s*$')
end

---@param plate any
---@return string?
local function normalizePlate(plate)
    return type(plate) == 'string' and trim(plate):upper() or nil
end

---@param name string
---@return string
local function normalizeItemName(name)
    name = name:lower()
    return name:sub(1, 7) == 'weapon_' and name:upper() or name
end

---@param name string
---@return boolean
local function tableExists(name)
    return MySQL.scalar.await('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?', { name }) > 0
end

---@param tableName string
---@param column string
---@return boolean
local function columnExists(tableName, column)
    return MySQL.scalar.await('SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?', { tableName, column }) > 0
end

---@param data any
---@return boolean
local function hasInventoryData(data)
    return type(data) == 'string' and data ~= '' and data ~= '[]' and data ~= '{}' and data ~= 'null'
end

---@param raw any
---@return table? items nil when the JSON is invalid
local function decodeItems(raw)
    if raw == nil or raw == '' then return {} end
    if type(raw) == 'table' then return raw end
    if type(raw) ~= 'string' then return end

    local ok, items = pcall(json.decode, raw)
    if not ok then return end

    if items == nil then
        return raw:match('^%s*null%s*$') and {} or nil
    end

    return type(items) == 'table' and items or {}
end

---@param length integer
---@return string
local function generateText(length)
    local text

    repeat
        local chars = {}
        for i = 1, length do chars[i] = string.char(math.random(65, 90)) end
        text = table.concat(chars)
    until text ~= 'POL' and text ~= 'EMS'

    return text
end

---@return string
local function generateSerial()
    return ('%s%s%s'):format(math.random(100000, 999999), generateText(3), math.random(100000, 999999))
end

---@param name string
---@return table?
local function getOxItem(name)
    local item = itemCache[name]

    if item == nil then
        item = exports.ox_inventory:Items(name) or false
        itemCache[name] = item
    end

    return item or nil
end

---@param metadata table
---@param item? table
---@param stats table
local function convertWeapon(metadata, item, stats)
    stats.weapons += 1

    metadata.durability = tonumber(metadata.quality) or tonumber(metadata.durability) or 100
    metadata.quality = nil

    if item?.ammoname or metadata.ammo ~= nil then
        metadata.ammo = toInteger(metadata.ammo) or 0
    end

    if metadata.serial or metadata.serie or metadata.ammo then
        metadata.serial = metadata.serial or (metadata.serie and tostring(metadata.serie)) or generateSerial()
    end

    metadata.serie = nil

    if type(metadata.attachments) == 'table' and next(metadata.attachments) then
        stats.attachments += 1
    end

    metadata.components = {}
end

---@param data any
---@param stats table
---@return table?
local function convertItem(data, stats)
    if type(data) ~= 'table' then return end

    local count = toInteger(data.amount or data.count)

    if type(data.name) ~= 'string' or data.name == '' or not count or count < 1 then
        stats.invalid += 1
        return
    end

    local item = getOxItem(data.name)
    local name = item and item.name or normalizeItemName(data.name)
    local metadata = type(data.info) == 'table' and data.info or {}

    if not item then
        stats.unknown[name] = (stats.unknown[name] or 0) + count
    end

    if data.type == 'weapon' or item?.weapon or name:sub(1, 7) == 'WEAPON_' then
        convertWeapon(metadata, item, stats)
    end

    stats.stacks += 1

    return { name = name, count = count, metadata = next(metadata) and metadata or nil }
end

---With slotLimit, QB slots up to the limit are kept; other items fill the lowest free slots.
---@param items table
---@param stats table
---@param slotLimit? integer
---@return table[]
local function convertItems(items, stats, slotLimit)
    local converted, pending, taken = {}, {}, {}

    for key, data in pairs(items) do
        local item = convertItem(data, stats)

        if item then
            local slot = toInteger(data.slot) or toInteger(key)

            if slotLimit and slot and slot >= 1 and slot <= slotLimit and not taken[slot] then
                item.slot = slot
                taken[slot] = true
                converted[#converted + 1] = item
            else
                pending[#pending + 1] = { item = item, order = slot or math.huge }
            end
        end
    end

    table.sort(pending, function(a, b) return a.order < b.order end)

    local slot = 0

    for i = 1, #pending do
        repeat slot += 1 until not taken[slot]
        pending[i].item.slot = slot
        converted[#converted + 1] = pending[i].item
    end

    table.sort(converted, function(a, b) return a.slot < b.slot end)

    return converted
end

---@param target table[]
---@param items table[]
local function appendItems(target, items)
    local offset = #target

    for i = 1, #items do
        items[i].slot = offset + i
        target[offset + i] = items[i]
    end
end

---@param items table
---@return boolean
local function needsConversion(items)
    for _, data in pairs(items) do
        if type(data) ~= 'table' or not data.count or not data.slot then return true end
    end

    return false
end

---@param items table[]
---@return string?
local function encodeItems(items)
    local ok, encoded = pcall(json.encode, items)
    return ok and encoded or nil
end

---@param ctx table
local function convertPlayers(ctx)
    if not columnExists('players', 'inventory') then
        ctx.report.players = 'players.inventory column not found, skipped'
        return
    end

    local playerSlots = GetConvarInt('inventory:slots', 50)
    local rows = MySQL.query.await('SELECT citizenid, inventory FROM players')
    local converted, alreadyOx, invalid, overflow = 0, 0, {}, {}

    for i = 1, #rows do
        local row = rows[i]
        local items = decodeItems(row.inventory)

        if not items then
            invalid[#invalid + 1] = row.citizenid
        elseif needsConversion(items) then
            local inventory = convertItems(items, ctx.stats, playerSlots)
            local encoded = encodeItems(inventory)
            local last = inventory[#inventory]

            if not encoded then
                invalid[#invalid + 1] = row.citizenid
            else
                if last and last.slot > playerSlots then
                    overflow[#overflow + 1] = row.citizenid
                end

                converted += 1
                ctx.backups[#ctx.backups + 1] = {
                    query = 'INSERT IGNORE INTO players_qb_inventory_backup (citizenid, inventory) VALUES (?, ?)',
                    values = { row.citizenid, type(row.inventory) == 'table' and json.encode(row.inventory) or row.inventory },
                }
                ctx.queries[#ctx.queries + 1] = {
                    query = 'UPDATE players SET inventory = ? WHERE citizenid = ?',
                    values = { encoded, row.citizenid },
                }
            end
        else
            alreadyOx += 1
        end
    end

    ctx.report.players = ('%d rows: %d to convert, %d empty or already ox format (skipped), %d invalid JSON (skipped)'):format(#rows, converted, alreadyOx, #invalid)
    ctx.report.invalidPlayers = invalid
    ctx.report.overflowPlayers = overflow
    ctx.playerWrites = converted
end

---@param ctx table
---@return table[] storages
local function loadStorages(ctx)
    local storages, seen, sources, duplicates = {}, {}, {}, {}

    local function add(identifier, raw, source)
        if type(identifier) ~= 'string' then return end

        local key = trim(identifier):lower()
        if seen[key] then
            duplicates[#duplicates + 1] = ('%s (kept %s, skipped %s)'):format(identifier, seen[key], source)
            return
        end

        seen[key] = source
        storages[#storages + 1] = { identifier = identifier, raw = raw, source = source }
    end

    if tableExists('inventories') then
        local rows = MySQL.query.await('SELECT identifier, items FROM inventories')
        sources[#sources + 1] = ('inventories (%d rows)'):format(#rows)

        for i = 1, #rows do add(rows[i].identifier, rows[i].items, 'inventories') end
    end

    for i = 1, #legacyTables do
        local legacy = legacyTables[i]

        if tableExists(legacy.name) then
            local rows = MySQL.query.await(legacy.query)
            sources[#sources + 1] = ('%s (%d rows)'):format(legacy.name, #rows)

            for j = 1, #rows do add(rows[j].identifier, rows[j].items, legacy.name) end
        end
    end

    ctx.report.sources = #sources > 0 and table.concat(sources, ', ') or 'none found'
    ctx.report.duplicateStorages = duplicates

    return storages
end

---@return table byPlate, table byFakeplate
local function loadVehicles()
    if not tableExists('player_vehicles') then return {}, {} end

    local rows = MySQL.query.await(('SELECT id, plate, %s AS fakeplate, %s AS trunk, %s AS glovebox FROM player_vehicles ORDER BY id'):format(
        columnExists('player_vehicles', 'fakeplate') and 'fakeplate' or 'NULL',
        columnExists('player_vehicles', 'trunk') and 'trunk' or 'NULL',
        columnExists('player_vehicles', 'glovebox') and 'glovebox' or 'NULL'
    ))
    local byPlate, byFakeplate = {}, {}

    for i = 1, #rows do
        local row = rows[i]
        local plate, fakeplate = normalizePlate(row.plate), normalizePlate(row.fakeplate)

        if plate and plate ~= '' then
            byPlate[plate] = byPlate[plate] or {}
            byPlate[plate][#byPlate[plate] + 1] = row
        end

        if fakeplate and fakeplate ~= '' then
            byFakeplate[fakeplate] = byFakeplate[fakeplate] or {}
            byFakeplate[fakeplate][#byFakeplate[fakeplate] + 1] = row
        end
    end

    return byPlate, byFakeplate
end

---@param ctx table
---@param storages table[]
local function convertVehicles(ctx, storages)
    local byPlate, byFakeplate = loadVehicles()
    local targets, order = {}, {}
    local unmatched, duplicates, existing, invalid = {}, {}, {}, {}
    local duplicateSeen = {}

    for i = 1, #storages do
        local storage = storages[i]
        local kind, rawPlate = 'trunk', storage.identifier:match('^trunk%-(.*)$')

        if not rawPlate then
            kind, rawPlate = 'glovebox', storage.identifier:match('^glovebox%-(.*)$')
        end

        rawPlate = rawPlate and trim(rawPlate)

        if rawPlate then
            storage.vehicle = true
            local plate = normalizePlate(rawPlate)
            local items = decodeItems(storage.raw)

            if not items then
                invalid[#invalid + 1] = storage.identifier
            elseif next(items) then
                local matches = byPlate[plate] or byFakeplate[plate]

                if not matches then
                    unmatched[#unmatched + 1] = ('%s (%s)'):format(rawPlate, kind)
                else
                    local vehicle = matches[1]

                    if #matches > 1 and not duplicateSeen[plate] then
                        local ids = {}
                        for j = 1, #matches do ids[j] = matches[j].id end
                        duplicateSeen[plate] = true
                        duplicates[#duplicates + 1] = ('%s (ids %s, used %d)'):format(plate, table.concat(ids, '/'), vehicle.id)
                    end

                    if hasInventoryData(vehicle[kind]) then
                        existing[#existing + 1] = ('%s (%s)'):format(rawPlate, kind)
                    else
                        local key = ('%s:%d'):format(kind, vehicle.id)
                        local target = targets[key]

                        if not target then
                            target = { kind = kind, id = vehicle.id, items = {} }
                            targets[key] = target
                            order[#order + 1] = key
                        end

                        appendItems(target.items, convertItems(items, ctx.stats))
                    end
                end
            end
        end
    end

    local counts = { trunk = 0, glovebox = 0 }

    for i = 1, #order do
        local target = targets[order[i]]
        local encoded = encodeItems(target.items)

        if encoded then
            counts[target.kind] += 1
            ctx.queries[#ctx.queries + 1] = {
                query = ('UPDATE player_vehicles SET %s = ? WHERE id = ? AND (%s IS NULL OR %s IN (\'\', \'[]\', \'{}\', \'null\'))'):format(target.kind, target.kind, target.kind),
                values = { encoded, target.id },
            }
        else
            invalid[#invalid + 1] = ('vehicle id %d (%s)'):format(target.id, target.kind)
        end
    end

    ctx.report.vehicles = ('%d trunks and %d gloveboxes to write'):format(counts.trunk, counts.glovebox)
    ctx.report.unmatchedPlates = unmatched
    ctx.report.duplicatePlates = duplicates
    ctx.report.existingVehicles = existing
    ctx.report.invalidVehicles = invalid
    ctx.vehicleWrites = counts.trunk + counts.glovebox
end

---@param ctx table
---@param storages table[]
local function convertStashes(ctx, storages)
    local existingNames = {}

    if tableExists('ox_inventory') then
        local rows = MySQL.query.await('SELECT name FROM ox_inventory WHERE owner = \'\'')

        for i = 1, #rows do existingNames[trim(rows[i].name):lower()] = true end
    end

    local targets, order = {}, {}
    local existing, tooLong, invalid, oversized = {}, {}, {}, {}
    local evidenceSources = 0

    for i = 1, #storages do
        local storage = storages[i]

        if not storage.vehicle then
            local drawer = storage.identifier:match('| Drawer%s+(%S+)%s*$')
            local name = drawer and ('evidence-%s'):format(drawer) or storage.identifier
            local key = trim(name):lower()
            local items = decodeItems(storage.raw)

            if not items then
                invalid[#invalid + 1] = storage.identifier
            elseif #name > maxStashNameLength then
                tooLong[#tooLong + 1] = storage.identifier
            elseif existingNames[key] then
                if existingNames[key] ~= 'reported' then
                    existingNames[key] = 'reported'
                    existing[#existing + 1] = name
                end
            elseif next(items) then
                local target = targets[key]

                if not target then
                    target = { name = name, items = {}, evidence = drawer ~= nil }
                    targets[key] = target
                    order[#order + 1] = key
                end

                if drawer then evidenceSources += 1 end

                appendItems(target.items, convertItems(items, ctx.stats))
            end
        end
    end

    local stashes, evidence = 0, 0

    for i = 1, #order do
        local target = targets[order[i]]
        local encoded = encodeItems(target.items)

        if encoded then
            stashes += 1

            if target.evidence then
                evidence += 1
                if #target.items > evidenceSlots then oversized[#oversized + 1] = target.name end
            end

            ctx.queries[#ctx.queries + 1] = {
                query = 'INSERT IGNORE INTO ox_inventory (owner, name, data) VALUES (\'\', ?, ?)',
                values = { target.name, encoded },
            }
        else
            invalid[#invalid + 1] = target.name
        end
    end

    ctx.report.stashes = ('%d stashes to create (%d evidence lockers merged from %d QB drawers)'):format(stashes, evidence, evidenceSources)
    ctx.report.existingStashes = existing
    ctx.report.longStashes = tooLong
    ctx.report.invalidStashes = invalid
    ctx.report.oversizedEvidence = oversized
    ctx.stashWrites = stashes
end

local function ensureSchema(ctx)
    if ctx.playerWrites > 0 then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `players_qb_inventory_backup` (
                `citizenid` varchar(50) NOT NULL,
                `inventory` longtext DEFAULT NULL,
                `backed_up_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`citizenid`)
            )
        ]])
    end

    if ctx.vehicleWrites > 0 then
        if not columnExists('player_vehicles', 'glovebox') then
            MySQL.query.await('ALTER TABLE `player_vehicles` ADD COLUMN `glovebox` LONGTEXT NULL')
        end

        if not columnExists('player_vehicles', 'trunk') then
            MySQL.query.await('ALTER TABLE `player_vehicles` ADD COLUMN `trunk` LONGTEXT NULL')
        end
    end

    if ctx.stashWrites > 0 then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `ox_inventory` (
                `owner` varchar(60) DEFAULT NULL,
                `name` varchar(100) NOT NULL,
                `data` longtext DEFAULT NULL,
                `lastupdated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
                UNIQUE KEY `owner` (`owner`,`name`)
            )
        ]])
    end
end

---@param label string
---@param list string[]
local function printList(label, list)
    if #list == 0 then return end
    lib.print.warn(('%s (%d): %s'):format(label, #list, table.concat(list, ', ')))
end

---@param ctx table
local function printReport(ctx)
    local report, stats = ctx.report, ctx.stats

    lib.print.info(('QB inventory sources: %s'):format(report.sources))
    lib.print.info(('Players: %s'):format(report.players))
    lib.print.info(('Vehicles: %s'):format(report.vehicles))
    lib.print.info(('Stashes: %s'):format(report.stashes))
    lib.print.info(('Items: %d stacks converted, %d weapons, %d invalid entries skipped'):format(stats.stacks, stats.weapons, stats.invalid))

    printList('Players with invalid inventory JSON (left unchanged)', report.invalidPlayers or {})
    printList('Inventories found in more than one QB table (only the first was converted)', report.duplicateStorages or {})
    printList('Players with more items than inventory:slots (extra items placed beyond the last slot)', report.overflowPlayers or {})
    printList('Plates with no owned vehicle (not converted)', report.unmatchedPlates)
    printList('Duplicate plates (written to the lowest vehicle id only)', report.duplicatePlates)
    printList('Vehicle inventories that already contain ox data (skipped)', report.existingVehicles)
    printList('Invalid vehicle inventories (skipped)', report.invalidVehicles)
    printList('Stashes that already exist in ox_inventory (skipped)', report.existingStashes)
    printList(('Stash names longer than %d characters (skipped)'):format(maxStashNameLength), report.longStashes)
    printList('Invalid stash inventories (skipped)', report.invalidStashes)
    printList(('Evidence lockers with more than %d items after merging'):format(evidenceSlots), report.oversizedEvidence)

    if stats.attachments > 0 then
        lib.print.warn(('%d weapons had QB attachments; ox components cannot be derived from them, so they start with none (QB data is kept in metadata.attachments)'):format(stats.attachments))
    end

    local unknown, hasAmmo = {}, false

    for name, count in pairs(stats.unknown) do
        unknown[#unknown + 1] = ('%s x%d'):format(name, count)
        if qbAmmoItems[name] then hasAmmo = true end
    end

    table.sort(unknown)

    if #unknown > 0 then
        printList('Items not defined in ox_inventory (kept as-is)', unknown)
        lib.print.warn('ox_inventory drops undefined items when an inventory is loaded and saved. Define them in ox_inventory/data/items.lua before anyone joins, or they will be lost.')
    end

    if hasAmmo then
        lib.print.warn('QB ammo boxes have no ox_inventory equivalent (ox uses per-round items such as ammo-9 or ammo-rifle) and were kept under their QB names.')
    end

    if ctx.stashWrites > 0 then
        lib.print.info('Stashes are created without an owner (shared). Stashes registered per player (owner = true) will not see them.')
    end
end

---@param dryRun boolean
local function convertInventories(dryRun)
    table.wipe(itemCache)

    local ctx = {
        stats = { stacks = 0, weapons = 0, attachments = 0, invalid = 0, unknown = {} },
        report = {},
        queries = {},
        backups = {},
        playerWrites = 0,
        vehicleWrites = 0,
        stashWrites = 0,
    }

    convertPlayers(ctx)

    local storages = loadStorages(ctx)
    convertVehicles(ctx, storages)
    convertStashes(ctx, storages)

    printReport(ctx)

    if dryRun then
        return lib.print.info(('Dry run complete: %d player, %d vehicle and %d stash writes would be made. Nothing was changed.'):format(ctx.playerWrites, ctx.vehicleWrites, ctx.stashWrites))
    end

    if #ctx.queries == 0 then
        return lib.print.info('Nothing to convert.')
    end

    ensureSchema(ctx)

    local queries = ctx.backups

    for i = 1, #ctx.queries do queries[#queries + 1] = ctx.queries[i] end

    if not MySQL.transaction.await(queries) then
        return lib.print.error('Inventory conversion failed; the transaction was rolled back and nothing was changed.')
    end

    lib.print.info(('Converted %d player, %d vehicle and %d stash inventories. Original player inventories were copied to players_qb_inventory_backup; QB source tables were not modified.'):format(ctx.playerWrites, ctx.vehicleWrites, ctx.stashWrites))
end

RegisterCommand('convertqbinventory', function(source, args)
    if source ~= 0 then return warn('This command can only be executed using the server console.') end
    if converting then return warn('Inventory conversion is already running, please wait.') end

    local mode = args[1] and args[1]:lower()
    local dryRun = mode == 'dryrun'

    if mode and not dryRun then
        return warn('Usage: convertqbinventory [dryrun]')
    end

    if GetResourceState('ox_inventory') ~= 'started' then
        return lib.print.error('ox_inventory must be started to convert QB inventories.')
    end

    local playerCount = GetNumPlayerIndices()

    if playerCount > 0 then
        if not dryRun then
            return lib.print.error(('%d players are online. Inventory conversion must run with no players connected.'):format(playerCount))
        end

        lib.print.warn(('%d players are online; their inventories may change before the real conversion.'):format(playerCount))
    end

    lib.print.warn('Back up your database before converting. QB source tables are never modified.')

    converting = true
    local ok, err = pcall(convertInventories, dryRun)
    converting = false

    if not ok then lib.print.error(err) end
end, true)
