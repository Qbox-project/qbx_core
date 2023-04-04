QBCore.Functions = {}

-- Player

function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

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


---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
---@alias NotificationType 'inform' | 'error' | 'success'
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

function QBCore.Debug(resource, obj, depth)
    TriggerServerEvent('QBCore:DebugSomething', resource, obj, depth)
end

-- Callback Functions --

-- Client Callback
function QBCore.Functions.CreateClientCallback(name, cb)
    QBCore.ClientCallbacks[name] = cb
end

function QBCore.Functions.TriggerClientCallback(name, cb, ...)
    if not QBCore.ClientCallbacks[name] then return end
    QBCore.ClientCallbacks[name](cb, ...)
end

-- Server Callback
function QBCore.Functions.TriggerCallback(name, cb, ...)
    QBCore.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

function QBCore.Functions.Progressbar(_, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
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

function QBCore.Functions.GetVehicles()
    return GetGamePool('CVehicle')
end

function QBCore.Functions.GetObjects()
    return GetGamePool('CObject')
end

function QBCore.Functions.GetPlayers()
    return GetActivePlayers()
end

function QBCore.Functions.GetPeds(ignoreList)
    local pedPool = GetGamePool('CPed')
    local peds = {}
    ignoreList = ignoreList or {}
    for i = 1, #pedPool, 1 do
        local found = false
        for j = 1, #ignoreList, 1 do
            if ignoreList[j] == pedPool[i] then
                found = true
            end
        end
        if not found then
            peds[#peds + 1] = pedPool[i]
        end
    end
    return peds
end

function QBCore.Functions.GetClosestPed(coords, ignoreList)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    ignoreList = ignoreList or {}
    local peds = QBCore.Functions.GetPeds(ignoreList)
    local closestDistance = -1
    local closestPed = -1
    for i = 1, #peds, 1 do
        local pedCoords = GetEntityCoords(peds[i])
        local distance = #(pedCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestPed = peds[i]
            closestDistance = distance
        end
    end
    return closestPed, closestDistance
end

function QBCore.Functions.IsWearingGloves()
    local armIndex = GetPedDrawableVariation(cache.ped, 3)
    local model = GetEntityModel(cache.ped)
    local sharedTable = model == `mp_m_freemode_01` and 'MaleNoGloves' or 'FemaleNoGloves'
    return not QBCore.Shared[sharedTable][armIndex]
end

function QBCore.Functions.GetClosestPlayer(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local playerId, _, playerCoords = lib.getClosestPlayer(coords, 50, false)
    local closestDistance = playerCoords and #(playerCoords - coords) or nil
    return playerId, closestDistance
end

function QBCore.Functions.GetPlayersFromCoords(coords, distance)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local players = lib.getNearbyPlayers(coords, distance or 5, true)

    -- This is for backwards compatability as beforehand it only returned the PlayerId, where Lib returns PlayerPed, PlayerId and PlayerCoords
    for i = 1, #players do
        players[i] = players[i].id
    end

    return players
end

function QBCore.Functions.GetClosestVehicle(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local vehicle, vehicleCoords = lib.getClosestVehicle(coords, 50, true)
    local closestDistance = vehicleCoords and #(vehicleCoords - coords) or nil
    return vehicle, closestDistance
end

function QBCore.Functions.GetClosestObject(coords)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)

    local objects = GetGamePool('CObject')
    local closestDistance = -1
    local closestObject = -1
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end

function QBCore.Functions.GetClosestBone(entity, list)
    ---@type vector3, table?, vector3?, number?
    local playerCoords, bone, coords, distance = GetEntityCoords(cache.ped)
    for _, element in pairs(list) do
        local boneCoords = GetWorldPositionOfEntityBone(entity, element.id or element)
        local boneDistance = #(playerCoords - boneCoords)
        if not coords then
            bone, coords, distance = element, boneCoords, boneDistance
        elseif distance > boneDistance then
            bone, coords, distance = element, boneCoords, boneDistance
        end
    end
    if not bone then
        bone = {id = GetEntityBoneIndexByName(entity, "bodyshell"), type = "remains", name = "bodyshell"}
        coords = GetWorldPositionOfEntityBone(entity, bone.id)
        distance = #(coords - playerCoords)
    end
    return bone, coords, distance
end

function QBCore.Functions.GetBoneDistance(entity, boneType, boneIndex)
    local bone = boneType == 1 and GetPedBoneIndex(entity, boneIndex) or GetEntityBoneIndexByName(entity, boneIndex)
    local boneCoords = GetWorldPositionOfEntityBone(entity, bone)
    local playerCoords = GetEntityCoords(cache.ped)
    return #(boneCoords - playerCoords)
end

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

function QBCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    return DoesEntityExist(vehicle)
end

function QBCore.Functions.GetPlate(vehicle)
    if not vehicle or vehicle == 0 then return end
    return QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
end

function QBCore.Functions.GetVehicleLabel(vehicle)
    if not vehicle or vehicle == 0 then return end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

function QBCore.Functions.SpawnClear(coords, radius)
    coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords or GetEntityCoords(cache.ped)
    local vehicles = GetGamePool('CVehicle')
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
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

function QBCore.Functions.StartParticleOnEntity(dict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration)
    QBCore.Functions.LoadParticleDictionary(dict)
    UseParticleFxAssetNextCall(dict)
    local particleHandle, boneID = nil, bone and (GetEntityType(entity) == 1 and GetPedBoneIndex(entity, bone) or GetEntityBoneIndexByName(entity, bone)) or nil
    if looped then
        if bone then
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
        if bone then
            StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale, false, false, false)
        else
            StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
        end
    end
    return particleHandle
end

function QBCore.Functions.GetStreetNametAtCoords(coords)
    local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return { main = GetStreetNameFromHashKey(street1), cross = GetStreetNameFromHashKey(street2) }
end

function QBCore.Functions.GetZoneAtCoords(coords)
    return GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
end

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

function QBCore.Functions.GetGroundZCoord(coords)
    if not coords then return end

    local retval, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    if retval then
        return vec3(coords.x, coords.y, groundZ)
    end

    print('Couldn\'t find Ground Z Coordinates given 3D Coordinates:', coords)
    return coords
end
