require 'client.functions'
local functions = {}

-- Player

---@deprecated import PlayerData using module 'qbx_core:playerdata' https://qbox-docs.vercel.app/resources/core/import
---@param cb? fun(playerData: PlayerData)
---@return PlayerData? playerData
function functions.GetPlayerData(cb)
    if not cb then return QBX.PlayerData end
    cb(QBX.PlayerData)
end

---@deprecated use GetCoordsFromEntity from imports/utils.lua
functions.GetCoords = GetCoordsFromEntity

---@deprecated use https://overextended.dev/ox_inventory/Functions/Client#search
functions.HasItem = HasItem

-- Utility

---@deprecated use DrawText2D from imports/utils.lua
functions.DrawText = DrawText2D

---@deprecated use DrawText3D from imports/utils.lua
functions.DrawText3D = DrawText3D

---@deprecated use lib.requestAnimDict from ox_lib
functions.RequestAnimDict = lib.requestAnimDict

---@deprecated use PlayAnim from imports/utils.lua
functions.PlayAnim = PlayAnim

---@deprecated use lib.requestModel from ox_lib
functions.LoadModel = lib.requestModel

---@deprecated use lib.requestAnimSet from ox_lib
functions.LoadAnimSet = lib.requestAnimSet

---@deprecated use lib.progressBar from ox_lib
---@param label string
---@param duration integer ms
---@param useWhileDead boolean
---@param canCancel boolean
---@param disableControls? {disableMovement: boolean, disableCarMovement: boolean, disableCombat: boolean, disableMouse: boolean}
---@param animation? {animDict: string, anim: string, flags: unknown}
---@param prop? unknown
---@param onFinish fun()
---@param onCancel fun()
function functions.Progressbar(_, label, duration, useWhileDead, canCancel, disableControls, animation, prop, _, onFinish, onCancel)
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

---@deprecated use GetVehicles from imports/utils.lua
functions.GetVehicles = GetVehicles

---@deprecated use GetObjects from imports/utils.lua
functions.GetObjects = GetObjects

---@deprecated use GetPlayersInScope from imports/utils.lua
functions.GetPlayers = GetPlayersInScope

---@deprecated use GetPeds from imports/utils.lua
functions.GetPeds = GetPeds

---@deprecated use GetClosestPed from imports/utils.lua
---Use GetClosestPlayer if wanting to ignore non-player peds
functions.GetClosestPed = GetClosestPed

---@deprecated use IsWearingGloves from imports/utils.lua
functions.IsWearingGloves = IsWearingGloves

---@deprecated use GetClosestPlayer from imports/utils.lua
functions.GetClosestPlayer = GetClosestPlayer

---@deprecated use GetPlayersFromCoords from imports/utils.lua
functions.GetPlayersFromCoords = GetPlayersFromCoords

---@deprecated use GetClosestVehicle from imports/utils.lua
functions.GetClosestVehicle = GetClosestVehicle

---@deprecated use GetClosestObject from imports/utils.lua
functions.GetClosestObject = GetClosestObject

---@deprecated use GetClosestBone from imports/utils.lua
functions.GetClosestBone = GetClosestBone

---@deprecated use GetBoneDistance from imports/utils.lua
functions.GetBoneDistance = GetBoneDistance

---@deprecated use AttachProp from imports/utils.lua
functions.AttachProp = AttachProp

-- Vehicle

---@deprecated call server function CreateVehicle instead from imports/utils.lua.
---@param model string|number
---@param cb? fun(vehicle: number)
---@param coords? vector4 player position if not specified
---@param isnetworked? boolean defaults to true
---@param teleportInto boolean teleport player to driver seat if true
function functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    coords = type(coords) == 'table' and vec4(coords.x, coords.y, coords.z, coords.w or GetEntityHeading(cache.ped)) or coords or GetCoordsFromEntity(cache.ped)
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(model) then return end

    isnetworked = isnetworked == nil or isnetworked
    lib.requestModel(model)
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

---@deprecated use DeleteVehicle from imports/utils.lua
functions.DeleteVehicle = DeleteVehicle

---@deprecated use GetPlate from imports/utils.lua
functions.GetPlate = GetPlate

---@deprecated use GetVehicleDisplayName from imports/utils.lua
functions.GetVehicleLabel = GetVehicleDisplayName

---@deprecated use IsVehicleSpawnClear from imports/utils.lua
functions.SpawnClear = IsVehicleSpawnClear

---@deprecated use lib.getVehicleProperties from ox_lib
function functions.GetVehicleProperties(vehicle)
    local props = lib.getVehicleProperties(vehicle)
    if not props then return end

    local tireHealth = {}
        for i = 0, 3 do
            tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
        end

    local tireBurstState = {}
    local tireBurstCompletely = {}

    for i = 0, 7 do
        local damage = props.tyres[i]
        tireBurstState[i] = damage == 1 or damage == 2
        tireBurstCompletely[i] = damage == 2
    end

    local windowStatus = {}
    for i = 0, 7 do
        windowStatus[i] = IsVehicleWindowIntact(vehicle, i)
    end

    local doorStatus = {}
    for i = 0, 5 do
        doorStatus[i] = IsVehicleDoorDamaged(vehicle, i) == 1
    end

    -- qb properties not in ox
    props.tireHealth = tireHealth
    props.tireBurstState = tireBurstState
    props.tireBurstCompletely = tireBurstCompletely
    props.windowStatus = windowStatus
    props.doorStatus = doorStatus
    props.headlightColor = GetVehicleHeadlightsColour(vehicle)
    props.modKit17 = props.modNitrous
    props.modKit19 = props.modSubwoofer
    props.modKit21 = props.modHydraulics
    props.modKit47 = props.modDoorR
    props.modKit49 = props.modLightbar
    props.liveryRoof = props.modRoofLivery

    return props
end

---@deprecated use lib.setVehicleProperties from ox_lib
function functions.SetVehicleProperties(vehicle, props)
    if props.tireHealth and not props.tyres then
        for wheelIndex, health in pairs(props.tireHealth) do
            SetVehicleWheelHealth(vehicle, wheelIndex, health)
        end
    end
    if props.headlightColor then
        SetVehicleHeadlightsColour(vehicle, props.headlightColor)
    end

    if not props.tyres then
        for i = 0, 7 do
            props.tyres[i] = props.tireBurstCompletely and props.tireBurstCompletely[i] and 2 or props.tireBurstState and props.tireBurstState[i] and 1 or nil
        end
    end

    local numWindowsDamaged = 0
    if props.windowStatus and not props.windows then
        for i, isDamaged in pairs(props.windowStatus) do
            if isDamaged then
                numWindowsDamaged += 1
                props.windows[numWindowsDamaged] = i
            end
        end
    end

    local numDoorsDamaged = 0
    if props.doorStatus and not props.doors then
        for i, isDamaged in pairs(props.doorStatus) do
            if isDamaged then
                numDoorsDamaged += 1
                props.doors[numDoorsDamaged] = i
            end
        end
    end

    -- qb properties converted to ox
    props.modNitrous = props.modNitrous or props.modKit17
    props.modSubwoofer = props.modSubwoofer or props.modKit17
    props.modHydraulics = props.modHydraulics or props.modKit21
    props.modDoorR = props.modDoorR or props.modKit47
    props.modLightbar = props.modLightbar or props.modKit49
    props.modRoofLivery = props.modRoofLivery or props.liveryRoof

    return lib.setVehicleProperties(vehicle, props)
end

---@deprecated use lib.requestNamedPtfxAsset from ox_lib
functions.LoadParticleDictionary = lib.requestNamedPtfxAsset

---@deprecated use StartParticleAtCoord from imports/utils.lua
functions.StartParticleAtCoord = StartParticleAtCoord

---@deprecated use StartParticleOnEntity from imports/utils.lua
functions.StartParticleOnEntity = StartParticleOnEntity

---@deprecated use GetStreetNameAtCoords from imports/utils.lua
functions.GetStreetNametAtCoords = GetStreetNameAtCoords

---@deprecated use GetZoneAtCoords from imports/utils.lua
functions.GetZoneAtCoords = GetZoneAtCoords

---@deprecated use GetCardinalDirection from imports/utils.lua
functions.GetCardinalDirection = GetCardinalDirection

---@deprecated use GetCurrentTime from imports/utils.lua
functions.GetCurrentTime = GetCurrentTime

---@deprecated use GetGroundZCoord from imports/utils.lua
functions.GetGroundZCoord = GetGroundZCoord

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType informs default styling. Defaults to 'inform'
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
---@param subTitle? string extra text under the title
---@param notifyPosition? NotificationPosition
---@param notifyStyle? table Custom styling. Please refer too https://overextended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Custom color for the icon chosen before
function functions.Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    exports.qbx_core:Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
end

return functions
