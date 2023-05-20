QBCore.Functions = {}

-- Player

---get playerData via callback or return
---@param cb? fun(playerData: PlayerData)
---@return PlayerData? playerData
function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

---@param entity number
---@return vector4
function QBCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity)
    return vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
end

--- QBCore.Functions.HasItem checks if a player has the specified `items` in their inventory
--- with the specified `amount`. Returns true if the player has at least the amount specified
--- and not that the player has the exact amount. If the user passes nil for `amount` then we
--- default to 1 - as it's self explainatory within the functions name.
---
--- @param items string|string[]    The item(s) to check for. Can be a string or a table and is mandatory.
--- @param amount? integer          The desired quantity of each item. Acceptable to pass nil, will default to 1.
---
--- @return boolean Returns true if the player has the specified items in the desired quantity,
---                 false otherwise
function QBCore.Functions.HasItem(items, amount)
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

-- Utility

---@param x number
---@param y number
---@param width number
---@param height number
---@param scale number
---@param r number
---@param g number
---@param b number
---@param a number
---@param text string
function QBCore.Functions.DrawText(x, y, width, height, scale, r, g, b, a, text)
    -- Use local function instead
    SetTextFont(4)
    SetTextProportional(false)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow()
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

---@param coords vector3
---@param text string
function QBCore.Functions.DrawText3D(coords, text)
    -- Use local function instead
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

QBCore.Functions.RequestAnimDict = lib.requestAnimDict

---@param animDict string
---@param animName string
---@param upperbodyOnly boolean
---@param duration number ms
function QBCore.Functions.PlayAnim(animDict, animName, upperbodyOnly, duration)
    local flags = upperbodyOnly and 16 or 0
    local runTime = duration or -1
    QBCore.Functions.RequestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animName, 8.0, 1.0, runTime, flags, 0.0, false, false, true)
    RemoveAnimDict(animDict)
end

QBCore.Functions.LoadModel = lib.requestModel

QBCore.Functions.LoadAnimSet = lib.requestAnimSet

RegisterNUICallback('getNotifyConfig', function(_, cb)
    cb(QBCore.Config.Notify)
end)


---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
---@alias NotificationType 'inform' | 'error' | 'success' | 'warning'
---@alias DeprecatedNotificationType 'primary'

---@class NotifyProps
---@field id? string notifications with the same id will not be on the screen at the same time
---@field title? string displayed to the player
---@field description? string displayed to the player
---@field duration? number milliseconds notification is on screen
---@field position? NotificationPosition
---@field type? NotificationType
---@field icon? string https://fontawesome.com icon name
---@field iconColor? string css color value for the icon

---Text box popup for player which dissappears after a set time.
---@param props NotifyProps
function QBCore.Functions.NotifyV2(props)
    props.style = nil
    if not props.position then
        props.position = QBConfig.NotifyPosition
    end
    lib.notify(props)
end

---Text box popup for player which dissappears after a set time.
---@deprecated in favor of QBCore.Functions.NotifyV2()
---@param text table|string text of the notification
---@param notifyType? NotificationType|DeprecatedNotificationType informs default styling. Defaults to 'inform'.
---@param duration? integer milliseconds notification will remain on scren. Defaults to 5000.
function QBCore.Functions.Notify(text, notifyType, duration)
    print(string.format("%s invoked deprecated function Notify. Use NotifyV2 instead.", GetInvokingResource()))
    notifyType = notifyType or 'inform'
    if notifyType == 'primary' then notifyType = 'inform' end
    duration = duration or 5000
    local position = QBConfig.NotifyPosition
    if type(text) == "table" then
        local title = text.text or 'Placeholder'
        local description = text.caption or 'Placeholder'
        lib.notify({ title = title, description = description, duration = duration, type = notifyType, position = position})
    else
        lib.notify({ description = text, duration = duration, type = notifyType, position = position})
    end
end

---prints invoking resource and obj using indent
---@param obj any
---@param indent integer
function QBCore.Debug(_, obj, indent)
    TriggerServerEvent('QBCore:DebugSomething', obj, indent)
end

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QBCore.Functions.CreateClientCallback(name, cb)
    print(string.format("%s invoked deprecated function CreateClientCallback. Use ox_lib callback functions instead.", GetInvokingResource()))
    QBCore.ClientCallbacks[name] = cb
end

---@deprecated call a function instead
function QBCore.Functions.TriggerClientCallback(name, cb, ...)
    print(string.format("%s invoked deprecated function TriggerClientCallback. Use ox_lib callback functions instead.", GetInvokingResource()))
    if not QBCore.ClientCallbacks[name] then return end
    QBCore.ClientCallbacks[name](cb, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QBCore.Functions.TriggerCallback(name, cb, ...)
    print(string.format("%s invoked deprecated function TriggerCallback. Use ox_lib callback functions instead.", GetInvokingResource()))
    QBCore.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

---@param label string
---@param duration integer ms
---@param useWhileDead boolean
---@param canCancel boolean
---@param disableControls? {disableMovement: boolean, disableCarMovement: boolean, disableCombat: boolean, disableMouse: boolean}
---@param animation? {animDict: string, anim: string, flags: unknown}
---@param prop? unknown
---@param onFinish fun()
---@param onCancel fun()
function QBCore.Functions.Progressbar(_, label, duration, useWhileDead, canCancel, disableControls, animation, prop, _, onFinish, onCancel)
    if lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        disable = {
            move = disableControls?.disableMovement,
            car = disableControls?.disableCarMovement,
            combat = disableControls?.disableCombat,
            mouse = disableControls?.disableMouse,
        },
        anim = {
            dict = animation?.animDict,
            clip = animation?.anim,
            flags = animation?.flags
        },
        prop = {
            model = prop?.model,
            pos = prop?.coords,
            rot = prop?.rotation,
        },
    }) then
        if onFinish then
            onFinish()
        end
    else
        if onCancel then
            onCancel()
        end
    end
end

-- Getters

---@return number[]
function QBCore.Functions.GetVehicles()
    return GetGamePool('CVehicle')
end

---@return number[]
function QBCore.Functions.GetObjects()
    return GetGamePool('CObject')
end

---@return number[]
function QBCore.Functions.GetPlayers()
    return GetActivePlayers()
end

---@param ignoreList? number[]
---@return number[]
function QBCore.Functions.GetPeds(ignoreList)
    local pedPool = GetGamePool('CPed')
    local peds = {}
    ignoreList = ignoreList or {}
    local ignoreMap = {}
    for i = 1, #ignoreList do
        ignoreMap[ignoreList[i]] = true
    end

    for i = 1, #pedPool do
        local ped = pedPool[i]
        if not ignoreMap[ped] then
            peds[#peds + 1] = ped
        end
    end
    return peds
end

---@param coords vector3? if unset uses player coords
---@param objs number[]
---@return integer closestObj or -1
---@return number closestDistance or -1
local function getClosest(coords, objs)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local closestDistance = -1
    local closestObj = -1
    for i = 1, #objs do
        local obj = objs[i]
        local objCoords = GetEntityCoords(obj)
        local distance = #(objCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObj = obj
            closestDistance = distance
        end
    end
    return closestObj, closestDistance
end

---Use QBCore.Functions.GetClosestPlayer if wanting to ignore non-player peds
---@param coords? vector3 uses player position if not set
---@param ignoreList number[]
---@return number closestPed
---@return number closestDistance
function QBCore.Functions.GetClosestPed(coords, ignoreList)
    ignoreList = ignoreList or {}
    local peds = QBCore.Functions.GetPeds(ignoreList)
    return getClosest(coords, peds)
end

---@return boolean
function QBCore.Functions.IsWearingGloves()
    local armIndex = GetPedDrawableVariation(cache.ped, 3)
    local model = GetEntityModel(cache.ped)
    local sharedTable = model == `mp_m_freemode_01` and 'MaleNoGloves' or 'FemaleNoGloves'
    return not QBCore.Shared[sharedTable][armIndex]
end

---@param coords? vector3 uses player position if not set
---@return number? playerId
---@return integer? closestDistance
function QBCore.Functions.GetClosestPlayer(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local playerId, _, playerCoords = lib.getClosestPlayer(coords, 50, false)
    local closestDistance = playerCoords and #(playerCoords - coords) or nil
    return playerId, closestDistance
end

---@param coords? vector3 uses player position if not set
---@param distance number
---@return number[] playerIds
function QBCore.Functions.GetPlayersFromCoords(coords, distance)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local players = lib.getNearbyPlayers(coords, distance or 5, true)

    -- This is for backwards compatability as beforehand it only returned the PlayerId, where Lib returns PlayerPed, PlayerId and PlayerCoords
    for i = 1, #players do
        players[i] = players[i].id
    end

    return players
end

---@param coords? vector3 uses player position if not set
---@return number? vehicle
---@return integer? closestDistance
function QBCore.Functions.GetClosestVehicle(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local vehicle, vehicleCoords = lib.getClosestVehicle(coords, 50, true)
    local closestDistance = vehicleCoords and #(vehicleCoords - coords) or nil
    return vehicle, closestDistance
end

---@param coords? vector3 uses player position if not set
---@return integer closestObject
---@return number closestDistance
function QBCore.Functions.GetClosestObject(coords)
    local objects = GetGamePool('CObject')
    return getClosest(coords, objects)
end

---@param entity number
---@param list table|{id: number}[] bones
---@return table|{id: number, type: string, name: string}
---@return vector3 boneCoords
---@return number boneDistance
function QBCore.Functions.GetClosestBone(entity, list)
    local playerCoords = GetEntityCoords(cache.ped)

    ---@type table, vector3, number
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

---@param entity number
---@param boneType integer
---@param boneIndex number
---@return number distance
function QBCore.Functions.GetBoneDistance(entity, boneType, boneIndex)
    local bone = boneType == 1 and GetPedBoneIndex(entity, boneIndex) or GetEntityBoneIndexByName(entity, boneIndex)
    local boneCoords = GetWorldPositionOfEntityBone(entity, bone)
    local playerCoords = GetEntityCoords(cache.ped)
    return #(boneCoords - playerCoords)
end

---@param ped number
---@param model number|string
---@param boneId number
---@param x number
---@param y number
---@param z number
---@param xR number
---@param yR number
---@param zR number
---@param vertex boolean
---@return number prop
function QBCore.Functions.AttachProp(ped, model, boneId, x, y, z, xR, yR, zR, vertex)
    local modelHash = type(model) == 'string' and joaat(model) or model
    local bone = GetPedBoneIndex(ped, boneId)
    QBCore.Functions.LoadModel(modelHash)
    local prop = CreateObject(modelHash, 1.0, 1.0, 1.0, true, true, false)
    AttachEntityToEntity(prop, ped, bone, x, y, z, xR, yR, zR, true, true, false, true, not vertex and 2 or 0, true)
    SetModelAsNoLongerNeeded(modelHash)
    return prop
end

-- Vehicle

---@param model string|number
---@param cb? fun(vehicle: number)
---@param coords? vector3 player position if not specified
---@param isnetworked? boolean defaults to true
---@param teleportInto boolean teleport player to driver seat if true
function QBCore.Functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(model) then return end

    isnetworked = isnetworked == nil or isnetworked
    QBCore.Functions.LoadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then TaskWarpPedIntoVehicle(cache.ped, veh, -1) end
    if cb then cb(veh) end
end

---@param vehicle number
---@return boolean failure if true, vehicle was not deleted
function QBCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    return DoesEntityExist(vehicle)
end

---@param vehicle number
---@return string?
function QBCore.Functions.GetPlate(vehicle)
    if not vehicle or vehicle == 0 then return end
    return QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
end

---@param vehicle number
---@return string?
function QBCore.Functions.GetVehicleLabel(vehicle)
    if not vehicle or vehicle == 0 then return end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

---Find if vehicle exists within radius of coords.
---@param coords vector3? defaults to player position
---@param radius number
---@return boolean isCloseVehicle if there is a vehicle within radius of coords
function QBCore.Functions.SpawnClear(coords, radius)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
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

QBCore.Functions.GetVehicleProperties = lib.getVehicleProperties

QBCore.Functions.SetVehicleProperties = lib.setVehicleProperties

QBCore.Functions.LoadParticleDictionary = lib.requestNamedPtfxAsset

---@param dict string
---@param ptName string
---@param looped boolean
---@param coords? vector3 defaults to player position
---@param rot vector3
---@param scale? number defaults to 1.0
---@param alpha? number defaults to 10.0
---@param color? {r: number, g: number, b: number}
---@param duration? number ms
---@return number
function QBCore.Functions.StartParticleAtCoord(dict, ptName, looped, coords, rot, scale, alpha, color, duration)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)

    QBCore.Functions.LoadParticleDictionary(dict)
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
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        StartParticleFxNonLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0, false, false, false)
    end
    return particleHandle
end

---@param dict string
---@param ptName string
---@param looped boolean
---@param entity number
---@param bone? number|string
---@param offset vector3
---@param rot vector3
---@param scale number
---@param alpha number
---@param color? {r: number, b: number, g: number}
---@param evolution? {name: string, amount: number}
---@param duration? number ms
---@return number
function QBCore.Functions.StartParticleOnEntity(dict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration)
    QBCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    local particleHandle = nil
    local boneID = bone and (GetEntityType(entity) == 1 and GetPedBoneIndex(entity, bone) or GetEntityBoneIndexByName(entity, bone)) or nil
    if looped then
        if boneID then
            particleHandle = StartParticleFxLoopedOnEntityBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale, false, false, false)
        else
            particleHandle = StartParticleFxLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
        end
        if evolution then
            SetParticleFxLoopedEvolution(particleHandle, evolution.name, evolution.amount, false)
        end
        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end
        SetParticleFxLoopedAlpha(particleHandle, alpha)
        if duration then
            Wait(duration)
            StopParticleFxLooped(particleHandle, false)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)
        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end
        if boneID then
            StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale, false, false, false)
        else
            StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
        end
    end
    return particleHandle
end

---@param coords vector3
---@return {main: string, cross: string}
function QBCore.Functions.GetStreetNametAtCoords(coords)
    local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return { main = GetStreetNameFromHashKey(street1), cross = GetStreetNameFromHashKey(street2) }
end

---@param coords vector3
---@return string
function QBCore.Functions.GetZoneAtCoords(coords)
    return GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
end

---@param entity? number defaults to player ped
---@return 'North'|'South'|'East'|'West'|string direction or error message
function QBCore.Functions.GetCardinalDirection(entity)
    entity = entity or cache.ped
    if not DoesEntityExist(entity) then
        return 'Entity does not exist'
    end

    local heading = GetEntityHeading(entity)
    if (heading >= 0 and heading < 45) or (heading >= 315 and heading < 360) then
        return 'North'
    elseif heading >= 45 and heading < 135 then
        return 'West'
    elseif heading >= 135 and heading < 225 then
        return 'South'
    elseif heading >= 225 and heading < 315 then
        return 'East'
    end

    return 'Heading is over 360'
end

---@class CurrentTime
---@field formattedMin string
---@field formattedHour integer
---@field ampm 'AM'|'PM'
---@field min number
---@field hour number

---@return CurrentTime
function QBCore.Functions.GetCurrentTime()
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

---@param coords vector3
---@return vector3?
function QBCore.Functions.GetGroundZCoord(coords)
    if not coords then return end

    local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    if retval then
        return vec3(coords.x, coords.y, groundZ)
    end

    print('Couldn\'t find Ground Z Coordinates given 3D Coordinates:', coords)
    return coords
end
