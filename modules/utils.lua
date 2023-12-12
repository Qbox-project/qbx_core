local isServer = IsDuplicityVersion()

---Get the coords including the heading from an entity
---@param entity number
---@return vector4
function GetCoordsFromEntity(entity) -- luacheck: ignore
    local coords = GetEntityCoords(entity)
    return vec4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

---Returns the number plate of the specified vehicle
---@param vehicle integer
---@return string?
function GetPlate(vehicle) -- luacheck: ignore
    if not vehicle or vehicle == 0 then return end
    return GetVehicleNumberPlateText(vehicle):trim()
end

---Converts a number to a string version with commas
---@param num number
---@return string
function CommaValue(num) -- luacheck: ignore
    local formatted = tostring(num)
    local numChanged
    repeat
        formatted, numChanged = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
    until numChanged == 0
    return formatted
end

---Split a string by a character
---@param str string
---@param delimiter string character
---@return string[]
function string.split(str, delimiter) -- luacheck: ignore
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

---Trim unwanted characters off the string
---@param str string
---@return string?
---@return number? count
function string.trim(str) -- luacheck: ignore
    if not str then return end
    return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

---Returns a string with the first character uppercase'd
---@param str string
---@return string?
---@return number? count
function string.firstToUpper(str) -- luacheck: ignore
    if not str or str == '' then return end
    return str:gsub("^%l", string.upper)
end

---Returns a rounded number
---@param value number
---@param numDecimalPlaces integer
---@return integer
function math.round(value, numDecimalPlaces) -- luacheck: ignore
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / power
end

local stringCharset = {}
local numberCharset = {}
local globalCharset = {}

for i = 48, 57 do numberCharset[#numberCharset + 1] = string.char(i) end
for i = 65, 90 do stringCharset[#stringCharset + 1] = string.char(i) end
for i = 97, 122 do stringCharset[#stringCharset + 1] = string.char(i) end

for i = 1, #numberCharset do globalCharset[#globalCharset + 1] = numberCharset[i] end
for i = 1, #stringCharset do globalCharset[#globalCharset + 1] = stringCharset[i] end

---Returns a random letter
---@param length integer
---@return string
function RandomLetter(length) -- luacheck: ignore
    if length <= 0 then return '' end
    return RandomLetter(length - 1) .. stringCharset[math.random(1, #stringCharset)]
end

---Returns a random number
---@param length integer
---@return string
function RandomNumber(length) -- luacheck: ignore
    if length <= 0 then return '' end
    return RandomNumber(length - 1) .. numberCharset[math.random(1, #numberCharset)]
end

---Returns a random number or letter
---@param length integer
---@return string
function RandomNumberOrLetter(length) -- luacheck: ignore
    if length <= 0 then return '' end
    return RandomNumberOrLetter(length - 1) .. globalCharset[math.random(1, #globalCharset)]
end

---Generates a random number plate according to a pattern, [pattern format](https://docs.fivem.net/natives/?_0x79780FD2), [plate generation source](https://github.com/citizenfx/fivem/blob/cb97fbc54050e2309930128d6deed515d004a1bd/code/components/extra-natives-five/src/VehicleNumberPlateNatives.cpp#L25-L112)
---@return string
function GenerateRandomPlate(pattern) -- luacheck: ignore
    local newPattern = ''
    local skipNext = false
    for i = 1, #pattern do
        if not skipNext then
            local last = i == #pattern
            local c = pattern:sub(i, i)
            local nextC = last and '\0' or pattern:sub(i + 1, i + 1)
            local curC

            if c == '1' then
                curC = RandomNumber(1)
            elseif c == 'A' then
                curC = RandomLetter(1)
            elseif c == '.' then
                curC = RandomNumberOrLetter(1)
            elseif c == '^' and (nextC == '1' or nextC == 'A' or nextC == '.') then
                curC = nextC
                skipNext = true
            else
                curC = c
            end

            newPattern = newPattern .. curC
        else
            skipNext = false
        end
    end

    return newPattern:upper()
end

--- maps a table by the given subfield
--- @param subfield string
--- @param table table
--- @return table<any, table[]>
function MapTableBySubfield(subfield, table)
	local mappedTable = {}
	for _, tableData in pairs(table) do
        local tableSubfield = tableData[subfield]
		if not tableSubfield then
			goto continue
		end
		if not mappedTable[tableSubfield] then
			mappedTable[tableSubfield] = {}
		end

		mappedTable[tableSubfield][#mappedTable[tableSubfield]+1] = tableData
		::continue::
	end
	return mappedTable
end

if isServer then
    -- Server side vehicle creation
    -- The CreateVehicleServerSetter native uses only the server to create a vehicle instead of using the client as well
    -- use the netid on the client with the NetworkGetEntityFromNetworkId native
    -- convert it to a vehicle via the NetToVeh native but use a while loop before that to check if the vehicle exists first like this
    --[[
        ```lua
            local timeout = 100
            while not NetworkDoesEntityExistWithNetworkId(netId) and timeout > 0 do
                Wait(10)
                timeout -= 1
            end
        ```
    ]]
    -- If you don't use the above on the client, it will return 0 as the vehicle from the netid and 0 means no vehicle found because it doesn't exist so fast on the client
    -- Deletes vehicle ped is in before spawning a new one.
    ---@param source integer
    ---@param model string | integer
    ---@param coords? vector4 defaults to player's position
    ---@param warp? boolean
    ---@param props? table vehicle properties to set https://github.com/overextended/ox_lib/blob/master/resource/vehicleProperties/client.lua#L3
    ---@return integer? netId
    function SpawnVehicle(source, model, coords, warp, props) -- luacheck: ignore
        model = type(model) == 'string' and joaat(model) or model

        if not CreateVehicleServerSetter then
            error('^1CreateVehicleServerSetter is not available on your artifact, please use artifact 5904 or above to be able to use this^0')
            return
        end

        local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
        while not DoesEntityExist(tempVehicle) do
            Wait(0)
        end
        local vehicleType = GetVehicleType(tempVehicle)
        DeleteEntity(tempVehicle)

        local ped = GetPlayerPed(source)
        if not coords then
            coords = GetCoordsFromEntity(ped)
        end

        local veh = CreateVehicleServerSetter(model, vehicleType, coords.x, coords.y, coords.z, coords.w)

        while not DoesEntityExist(veh) do
            Wait(0)
        end

        while GetVehicleNumberPlateText(veh) == "" do
            Wait(0)
        end

        if warp then SetPedIntoVehicle(ped, veh, -1) end

        local owner = lib.waitFor(function()
            local owner = NetworkGetEntityOwner(veh)
            if owner ~= -1 then return owner end
        end, 5000)

        local netId = NetworkGetNetworkIdFromEntity(veh)
        TriggerClientEvent('qbx_core:client:vehicleSpawned', owner, netId, props)
        return netId
    end


    local discordLink = GetConvar('qbx:discordlink', 'discord.gg/qbox')
    --Kick Player
    ---@param source Source
    ---@param reason string
    ---@param setKickReason? fun(reason: string)
    ---@param deferrals? Deferrals
    function KickWithReason(source, reason, setKickReason, deferrals) -- luacheck: ignore
        reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. discordLink
        if setKickReason then
            setKickReason(reason)
        end
        CreateThread(function()
            if deferrals then
                deferrals.update(reason)
                Wait(2500)
            end
            if source then
                DropPlayer(source --[[@as string]], reason)
            end
            for _ = 0, 4 do
                while true do
                    if source then
                        if GetPlayerPing(source --[[@as string]]) >= 0 then
                            break
                        end
                        Wait(100)
                        CreateThread(function()
                            DropPlayer(source --[[@as string]], reason)
                        end)
                    end
                end
                Wait(5000)
            end
        end)
    end

    ---Check for duplicate license
    ---@param license string
    ---@return boolean
    function IsLicenseInUse(license) -- luacheck: ignore
        local players = GetPlayers()

        for _, player in pairs(players) do
            local plyLicense2 = GetPlayerIdentifierByType(player --[[@as string]], 'license2')
            local plyLicense = GetPlayerIdentifierByType(player --[[@as string]], 'license')
            if plyLicense2 == license or plyLicense == license then
                return true
            end
        end

        return false
    end

    ---@deprecated use https://overextended.dev/ox_inventory/Functions/Server#search
    ---@param source Source
    ---@param items string | string[] The item(s) to check for. Can be a string or a table and is mandatory.
    ---@param amount? integer The desired quantity of each item. Acceptable to pass nil, will default to 1.
    ---@return boolean Returns true if the player has the specified items in the desired quantity, false otherwise
    function HasItem(source, items, amount) -- luacheck: ignore
        amount = amount or 1
        local count = exports.ox_inventory:Search(source, 'count', items)
        if type(items) == 'table' and type(count) == 'table' then
            for _, v in pairs(count) do
                if v < amount then
                    return false
                end
            end
            return true
        end
        return count >= amount
    end
else
    ---Draws Text onto the screen in 2D
    ---@param text string
    ---@param coords vector2
    ---@param width? number
    ---@param height? number
    ---@param scale? number 0.0-10.0
    ---@param font? integer
    ---@param r? integer red 0-255
    ---@param g? integer green 0-255
    ---@param b? integer blue 0-255
    ---@param a? integer alpha 0-255
    function DrawText2D(text, coords, width, height, scale, font, r, g, b, a) -- luacheck: ignore
        r = r or 255
        g = g or 255
        b = b or 255
        a = a or 215
        width = width or 1.0
        height = height or 1.0
        scale = scale or 0.35
        font = font or 4

        SetTextFont(font)
        SetTextScale(scale, scale)
        SetTextColour(r, g, b, a)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(coords.x - width / 2, coords.y - height / 2 + 0.005)
    end

    ---Draws Text onto the screen in 3D
    ---@param coords vector3
    ---@param text string
    ---@param scale? number
    ---@param font? integer
    ---@param r? integer red 0-255
    ---@param g? integer green 0-255
    ---@param b? integer blue 0-255
    ---@param a? integer alpha 0-255
    function DrawText3D(text, coords, scale, font, r, g, b, a) -- luacheck: ignore
        r = r or 255
        g = g or 255
        b = b or 255
        a = a or 215
        scale = scale or 0.35
        font = font or 4

        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextColour(r, g, b, a)
        BeginTextCommandDisplayText('STRING')
        SetTextCentre(true)
        AddTextComponentSubstringPlayerName(text)
        SetDrawOrigin(coords.x, coords.y, coords.z, 0)
        EndTextCommandDisplayText(0.0, 0.0)
        local factor = #text / 370
        DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
        ClearDrawOrigin()
    end

    ---Wrapper for getting an entity handle and network id from a state bag name, [source](https://github.com/overextended/ox_core/blob/main/client/utils.lua)
    ---@async
    ---@param bagName string
    ---@return integer, integer
    function GetEntityAndNetIdFromBagName(bagName) -- luacheck: ignore
        local netId = tonumber(bagName:gsub('entity:', ''), 10)

        local idExist = lib.waitFor(function()
            local netIdExist = NetworkDoesEntityExistWithNetworkId(netId)

            if netIdExist then return netIdExist end
        end, ('statebag timed out while awaiting entity creation! (%s)'):format(bagName), 10000)

        local entity = idExist and NetworkGetEntityFromNetworkId(netId) or 0

        if entity == 0 then
            lib.print.error(('statebag received invalid entity! (%s)'):format(bagName))
            return 0, 0
        end

        return entity, netId
    end

    ---Wrapper for a state bag handler made for entities, [source](https://github.com/overextended/ox_core/blob/main/client/utils.lua)
    ---@param keyFilter string
    ---@param cb fun(entity: number, netId: number, value: any, bagName: string)
    ---@return number
    function EntityStateHandler(keyFilter, cb) -- luacheck: ignore
        return AddStateBagChangeHandler(keyFilter, '', function(bagName, _, value)
            local entity, netId = GetEntityAndNetIdFromBagName(bagName)

            if entity then
                cb(entity, netId, value, bagName)
            end
        end)
    end

    ---@deprecated use https://overextended.dev/ox_inventory/Functions/Client#search
    ---@param items string | string[] The item(s) to check for. Can be a string or a table and is mandatory.
    ---@param amount? integer The desired quantity of each item. Acceptable to pass nil, will default to 1.
    ---@return boolean Returns true if the player has the specified items in the desired quantity, false otherwise
    function HasItem(items, amount) -- luacheck: ignore
        amount = amount or 1
        local count = exports.ox_inventory:Search('count', items)
        if type(items) == 'table' and type(count) == 'table' then
            for _, v in pairs(count) do
                if v < amount then
                    return false
                end
            end
            return true
        end
        return count >= amount
    end

    ---Play an animation
    ---@async
    ---@param animDict string
    ---@param animName string
    ---@param upperbodyOnly boolean
    ---@param duration integer ms
    function PlayAnim(animDict, animName, upperbodyOnly, duration) -- luacheck: ignore
        local flags = upperbodyOnly and 16 or 0
        local runTime = duration or -1
        lib.requestAnimDict(animDict)
        TaskPlayAnim(cache.ped, animDict, animName, 8.0, 3.0, runTime, flags, 0.0, false, false, true)
        RemoveAnimDict(animDict)
    end

    ---Returns the entities from the specified pool in the current scope
    ---@param pool string
    ---@param ignoreList? integer[]
    ---@return integer[]
    function GetEntities(pool, ignoreList) -- luacheck: ignore
        ignoreList = ignoreList or {}
        local ents = GetGamePool(pool)
        local entities = {}
        local ignoreMap = {}
        for i = 1, #ignoreList do
            ignoreMap[ignoreList[i]] = true
        end

        for i = 1, #ents do
            local entity = ents[i]
            if not ignoreMap[entity] then
                entities[#entities + 1] = entity
            end
        end
        return entities
    end

    ---Returns all vehicles in the current scope
    ---@param ignoreList? integer[] ignore specific vehicle handles
    ---@return integer[]
    function GetVehicles(ignoreList) -- luacheck: ignore
        return GetEntities('CVehicle', ignoreList)
    end

    ---Returns all objects in the current scope
    ---@param ignoreList? integer[] ignore specific object handles
    ---@return integer[]
    function GetObjects(ignoreList) -- luacheck: ignore
        return GetEntities('CObject', ignoreList)
    end

    ---Returns all peds in the current scope
    ---@param ignoreList? integer[] ignore specific ped handles
    ---@return integer[]
    function GetPeds(ignoreList) -- luacheck: ignore
        return GetEntities('CPed', ignoreList)
    end

    ---Returns all pickups in the current scope
    ---@param ignoreList? integer[] ignore specific pickup handles
    ---@return integer[]
    function GetPickups(ignoreList) -- luacheck: ignore
        return GetEntities('CPickups', ignoreList)
    end

    ---Returns all players in the current scope
    ---@param ignoreList? integer[] ignore specific player ids
    ---@return integer[]
    function GetPlayersInScope(ignoreList) -- luacheck: ignore
        ignoreList = ignoreList or {}
        local plys = GetActivePlayers()
        local players = {}
        local ignoreMap = {}
        for i = 1, #ignoreList do
            ignoreMap[ignoreList[i]] = true
        end

        for i = 1, #plys do
            local player = plys[i]
            if not ignoreMap[player] then
                players[#players + 1] = player
            end
        end
        return players
    end

    ---Returns the closest entity from the list and the specified coords (if set)
    ---@param entities integer[]
    ---@param coords vector3? if unset uses player coords
    ---@return integer closestObj or -1
    ---@return number closestDistance or -1
    function GetClosestEntity(entities, coords) -- luacheck: ignore
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
        local closestDistance = -1
        local closestEntity = -1
        for i = 1, #entities do
            local entity = entities[i]
            local entityCoords = GetEntityCoords(entity)
            local distance = #(entityCoords - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestEntity = entity
                closestDistance = distance
            end
        end
        return closestEntity, closestDistance
    end

    ---Returns the closest ped
    ---Use QBCore.Functions.GetClosestPlayer if wanting to ignore non-player peds
    ---@param coords? vector3 uses player position if not set
    ---@param ignoreList? integer[]
    ---@return integer closestPed or -1
    ---@return number closestDistance or -1
    function GetClosestPed(coords, ignoreList) -- luacheck: ignore
        return GetClosestEntity(GetPeds(ignoreList), coords)
    end

    ---Returns the closest vehicle
    ---@param coords? vector3 uses player position if not set
    ---@param ignoreList? integer[]
    ---@return integer? vehicle
    ---@return number? closestDistance
    function GetClosestVehicle(coords, ignoreList) -- luacheck: ignore
        return GetClosestEntity(GetVehicles(ignoreList), coords)
    end

    ---Returns the closest object
    ---@return number?
    ---@return integer|nil
    function GetClosestObject(coords, ignoreList) -- luacheck: ignore
        return GetClosestEntity(GetObjects(ignoreList), coords)
    end

    local _deleteVehicle = DeleteVehicle

    ---Deletes the specified vehicle
    ---@param vehicle integer
    ---@return boolean
    function DeleteVehicle(vehicle) -- luacheck: ignore
        SetEntityAsMissionEntity(vehicle, true, true)
        _deleteVehicle(vehicle)
        return DoesEntityExist(vehicle)
    end

    ---Returns the closest player
    ---@param coords? vector3 uses player position if not set
    ---@param maxDistance? number
    ---@return integer? playerId
    ---@return number? closestDistance
    function GetClosestPlayer(coords, maxDistance) -- luacheck: ignore
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
        local playerId, _, playerCoords = lib.getClosestPlayer(coords, maxDistance or 50, false)
        local closestDistance = playerCoords and #(playerCoords - coords) or nil
        return playerId, closestDistance
    end

    ---Returns the players close to the coords
    ---@param coords? vector3 uses player position if not set
    ---@param distance? number
    ---@return number[] playerIds
    function GetPlayersFromCoords(coords, distance) -- luacheck: ignore
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
        local players = lib.getNearbyPlayers(coords, distance or 5, true)

        -- This is for backwards compatability as beforehand it only returned the PlayerId, where Lib returns PlayerPed, PlayerId and PlayerCoords
        for i = 1, #players do
            players[i] = players[i].id
        end

        return players
    end

    ---Returns the closest bone to the local ped of the specified entity
    ---@param entity integer
    ---@param list integer[] | {id: integer}[] bones
    ---@return integer | {id: integer} | {id: integer, type: string, name: string}
    ---@return vector3 boneCoords
    ---@return number boneDistance
    function GetClosestBone(entity, list) -- luacheck: ignore
        local playerCoords = GetEntityCoords(cache.ped)

        ---@type integer | {id: integer} | {id: integer, type: string, name: string}, vector3, number
        local bone, coords, distance
        for _, element in pairs(list) do
            local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
            local boneDistance = #(playerCoords - boneCoords)
            if not coords or distance > boneDistance then
                bone = element
                coords = boneCoords
                distance = boneDistance
            end
        end
        if not bone then
            bone = {id = GetEntityBoneIndexByName(entity, "bodyshell"), type = "remains", name = "bodyshell"}
            coords = GetWorldPositionOfEntityBone(entity, bone.id)
            distance = #(coords - playerCoords)
        end
        return bone, coords, distance
    end

    ---Returns the distance from the player to the bone
    ---@param entity integer
    ---@param boneType integer
    ---@param bone string | integer
    ---@return number distance
    function GetBoneDistance(entity, boneType, bone) -- luacheck: ignore
        local boneIndex = boneType == 1 and GetPedBoneIndex(entity, bone --[[@as integer]]) or GetEntityBoneIndexByName(entity, bone --[[@as string]])
        local boneCoords = GetWorldPositionOfEntityBone(entity, boneIndex)
        local playerCoords = GetEntityCoords(cache.ped)
        return #(playerCoords - boneCoords)
    end

    ---@param ped integer
    ---@param model string | integer
    ---@param boneId integer
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param xR number
    ---@param yR number
    ---@param zR number
    ---@param vertex boolean
    ---@return integer prop
    function AttachProp(ped, model, boneId, x, y, z, xR, yR, zR, vertex) -- luacheck: ignore
        local modelHash = type(model) == 'string' and joaat(model) or model
        local bone = GetPedBoneIndex(ped, boneId)
        lib.requestModel(modelHash)
        local prop = CreateObject(modelHash, 1.0, 1.0, 1.0, true, true, false)
        AttachEntityToEntity(prop, ped, bone, x, y, z, xR, yR, zR, true, true, false, true, not vertex and 2 or 0, true)
        SetModelAsNoLongerNeeded(modelHash)
        return prop
    end

    ---Returns the model name of the vehicle
    ---@param vehicle integer
    ---@return string
    function GetVehicleDisplayName(vehicle) -- luacheck: ignore
        return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    end

    ---Returns the brand name of the vehicle
    ---@param vehicle integer
    ---@return string
    function GetVehicleMakeName(vehicle) -- luacheck: ignore
        return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    end

    ---Check if there is no vehicle obstructing the coords
    ---@param coords vector3? defaults to player position
    ---@param radius? number
    ---@return boolean
    function IsVehicleSpawnClear(coords, radius) -- luacheck: ignore
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
        radius = radius or 5
        local vehicles = GetGamePool('CVehicle')
        local closeVeh = {}
        for i = 1, #vehicles do
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance = #(vehicleCoords - coords)
            if distance <= radius then
                closeVeh[#closeVeh + 1] = vehicles[i]
            end
        end
        return #closeVeh == 0
    end

    ---Spawns a particle at the coords
    ---@param dict string
    ---@param ptName string
    ---@param looped boolean
    ---@param coords? vector3 defaults to player position
    ---@param rot vector3
    ---@param scale? number defaults to 1.0
    ---@param alpha? number defaults to 1.0
    ---@param color? {r: number, g: number, b: number}
    ---@param duration? integer ms
    ---@return integer
    function StartParticleAtCoord(dict, ptName, looped, coords, rot, scale, alpha, color, duration) -- luacheck: ignore
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)

        lib.requestNamedPtfxAsset(dict)
        UseParticleFxAssetNextCall(dict)
        SetPtfxAssetNextCall(dict)
        local particleHandle
        if looped then
            particleHandle = StartParticleFxLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0, false, false, false, false)
            if color then
                SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
            end
            SetParticleFxLoopedAlpha(particleHandle, alpha or 10.0)
            if duration then
                Wait(duration)
                StopParticleFxLooped(particleHandle, false)
            end
        else
            SetParticleFxNonLoopedAlpha(alpha or 1.0)
            if color then
                SetParticleFxNonLoopedColour(color.r, color.g, color.b)
            end
            StartParticleFxNonLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0, false, false, false)
        end
        return particleHandle
    end

    ---Spawns a particle on the specified entity
    ---@param dict string
    ---@param ptName string
    ---@param looped boolean
    ---@param entity integer
    ---@param bone? string | number
    ---@param offset vector3
    ---@param rot vector3
    ---@param scale? number defaults to 1.0
    ---@param alpha? number defaults to 1.0
    ---@param color? {r: number, b: number, g: number}
    ---@param evolution? {name: string, amount: number}
    ---@param duration? integer ms
    ---@return number?
    function StartParticleOnEntity(dict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration) -- luacheck: ignore
        lib.requestNamedPtfxAsset(dict)
        UseParticleFxAssetNextCall(dict)
        local particleHandle = nil
        ---@cast bone number
        local pedBoneIndex = bone and GetPedBoneIndex(entity, bone) or 0
        ---@cast bone string
        local nameBoneIndex = bone and GetEntityBoneIndexByName(entity, bone) or 0
        local entityType = GetEntityType(entity)
        local boneID = entityType == 1 and (pedBoneIndex ~= 0 and pedBoneIndex) or (looped and nameBoneIndex ~= 0 and nameBoneIndex)
        if looped then
            if boneID then
                particleHandle = StartParticleFxLoopedOnEntityBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale or 1.0, false, false, false)
            else
                particleHandle = StartParticleFxLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale or 1.0, false, false, false)
            end
            if evolution then
                SetParticleFxLoopedEvolution(particleHandle, evolution.name, evolution.amount, false)
            end
            if color then
                SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
            end
            SetParticleFxLoopedAlpha(particleHandle, alpha or 1.0)
            if duration then
                Wait(duration)
                StopParticleFxLooped(particleHandle, false)
            end
        else
            SetParticleFxNonLoopedAlpha(alpha or 1.0)
            if color then
                SetParticleFxNonLoopedColour(color.r, color.g, color.b)
            end
            if boneID then
                StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale or 1.0, false, false, false)
            else
                StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale or 1.0, false, false, false)
            end
        end
        return particleHandle
    end

    ---Returns the street name and cross section from the coords
    ---@param coords vector3
    ---@return {main: string, cross: string}
    function GetStreetNameAtCoords(coords) -- luacheck: ignore
        local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        return { main = GetStreetNameFromHashKey(street1), cross = GetStreetNameFromHashKey(street2) }
    end

    ---Returns the name of the zone at the specified coords
    ---@param coords vector3
    ---@return string
    function GetZoneAtCoords(coords) -- luacheck: ignore
        return GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    end

    ---Returns the direction the specified entity or local ped is standing towards
    ---@param entity? number defaults to player ped
    ---@return 'North' | 'South' | 'East' | 'West' | string direction or error message
    function GetCardinalDirection(entity) -- luacheck: ignore
        entity = entity or cache.ped
        if not entity or not DoesEntityExist(entity) then
            return 'Entity does not exist'
        end

        local heading = GetEntityHeading(entity)
        heading = heading > 360 and heading * (360 / heading) --[[ Making sure the heading is within 360 degrees ]] or heading
        if (heading >= 0 and heading < 45) or (heading >= 315 and heading < 360) then
            return 'North'
        elseif heading >= 45 and heading < 135 then
            return 'West'
        elseif heading >= 135 and heading < 225 then
            return 'South'
        elseif heading >= 225 and heading < 315 then
            return 'East'
        end

        return 'Couldn\'t find direction'
    end

    ---@class CurrentTime
    ---@field formattedMin string
    ---@field formattedHour integer
    ---@field ampm 'AM' | 'PM'
    ---@field min number
    ---@field hour number

    ---Returns the current time in-game
    ---@return CurrentTime
    function GetCurrentTime() -- luacheck: ignore
        local obj = {}
        obj.min = GetClockMinutes()
        obj.hour = GetClockHours()

        if obj.hour <= 12 then
            obj.ampm = 'AM'
        elseif obj.hour >= 13 then
            obj.ampm = 'PM'
            obj.formattedHour = obj.hour - 12
        end

        if obj.min <= 9 then
            obj.formattedMin = ('0%s'):format(obj.min)
        end

        return obj
    end

    ---Returns the z coord at the first ground the game can find
    ---@param coords vector3
    ---@return vector3?
    function GetGroundZCoord(coords) -- luacheck: ignore
        if not coords then return end

        local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
        if retval then
            return vec3(coords.x, coords.y, groundZ)
        end

        lib.print.verbose('Couldn\'t find Ground Z Coordinates given 3D Coordinates:', coords)
        return coords
    end

        ---Clear all vehicle extras
    ---@param vehicle integer
    local function ClearAllVehicleExtras(vehicle) -- luacheck: ignore
        for i = 1, 20 do
            if DoesExtraExist(vehicle, i) then
                SetVehicleExtra(vehicle, i, false)
            end
        end
    end

    ---Set the status of an extra on the vehicle
    ---@param vehicle integer
    ---@param extra integer
    ---@param enable boolean
    function ChangeVehicleExtra(vehicle, extra, enable) -- luacheck: ignore
        if not DoesExtraExist(vehicle, extra) then return end
        local isExtraOn = IsVehicleExtraTurnedOn(vehicle, extra)

        if enable ~= isExtraOn then
            SetVehicleExtra(vehicle, extra, not enable)
        end
    end

    ---Set the vehicle extras of a vehicle according to a table
    ---@param vehicle integer
    ---@param extras table<integer, boolean>
    function SetVehicleExtras(vehicle, extras) -- luacheck: ignore
        ClearAllVehicleExtras(vehicle)

        for id, enabled in pairs(extras) do
            ChangeVehicleExtra(vehicle, tonumber(id) --[[@as integer]], enabled)
        end
    end

    MaleNoGloves = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [18] = true,
        [26] = true,
        [52] = true,
        [53] = true,
        [54] = true,
        [55] = true,
        [56] = true,
        [57] = true,
        [58] = true,
        [59] = true,
        [60] = true,
        [61] = true,
        [62] = true,
        [112] = true,
        [113] = true,
        [114] = true,
        [118] = true,
        [125] = true,
        [132] = true
    }

    FemaleNoGloves = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [19] = true,
        [59] = true,
        [60] = true,
        [61] = true,
        [62] = true,
        [63] = true,
        [64] = true,
        [65] = true,
        [66] = true,
        [67] = true,
        [68] = true,
        [69] = true,
        [70] = true,
        [71] = true,
        [129] = true,
        [130] = true,
        [131] = true,
        [135] = true,
        [142] = true,
        [149] = true,
        [153] = true,
        [157] = true,
        [161] = true,
        [165] = true
    }

    ---Returns if the local ped is wearing gloves
    ---@return boolean
    function IsWearingGloves() -- luacheck: ignore
        local armIndex = GetPedDrawableVariation(cache.ped, 3)
        local model = GetEntityModel(cache.ped)
        local tbl = model == `mp_m_freemode_01` and MaleNoGloves or FemaleNoGloves
        return not tbl[armIndex]
    end

    ---Loads an audiobank. Please remember to use ReleaseScriptAudioBank() because you can only load 10 banks max
    ---@param audioBank string
    ---@param timeout number? Number of ticks to wait for the audio bank to load. Defaults to 500.
    ---@return boolean
    function LoadAudioBank(audioBank, timeout) -- luacheck: ignore
        local count = 0
        timeout = timeout or 500
        while not RequestScriptAudioBank(audioBank, false) do count += 1 if count > timeout then return false end Wait(0) end
        return true
    end

    ---Plays a sound with the provided audioName and audioRef
    ---@param audioName string
    ---@param audioRef string
    ---@param returnSoundId boolean? If the soundId should be returned. Please make use of ReleaseSoundId() after you are done with the soundId. Defaults to false
    ---@param entity number? If an entity is provided, will make use of PlaySoundFromEntity
    ---@param coords vector3? If a vec3 is provided, will make use of PlaySoundFromCoord
    ---@param range number? Only used if coords are passed. Defaults to 5.0
    ---@return number? soundId Only returns if returnSoundId is set to true.
    function PlayAudio(audioName, audioRef, returnSoundId, entity, coords, range) -- luacheck: ignore
        local soundId = GetSoundId()
        if coords then
            range = range or 5.0
            PlaySoundFromCoord(soundId, audioName, coords.x, coords.y, coords.z, audioRef, false, range, false)
        elseif entity then
            PlaySoundFromEntity(soundId, audioName, entity, audioRef, false, false)
        else
            PlaySoundFrontend(soundId, audioName, audioRef, true)
        end
        returnSoundId = returnSoundId or false
        if returnSoundId then
            return soundId
        else
            ReleaseSoundId(soundId)
        end
    end
end
