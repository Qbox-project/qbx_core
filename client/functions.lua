QBCore.Functions = {}

-- Player

---get playerData via callback or return
---@param cb? fun(playerData: PlayerData)
---@return PlayerData? playerData
function QBCore.Functions.GetPlayerData(cb)
    if not cb then return QBCore.PlayerData end
    cb(QBCore.PlayerData)
end

---@deprecated use GetCoordsFromEntity from imports/utils.lua
QBCore.Functions.GetCoords = GetCoordsFromEntity

---@deprecated use HasItem from imports/utils.lua
QBCore.Functions.HasItem = HasItem

-- Utility

---@deprecated use DrawText2D from imports/utils.lua
QBCore.Functions.DrawText = DrawText2D

---@deprecated use DrawText3D from imports/utils.lua
QBCore.Functions.DrawText3D = DrawText3D

---@deprecated use lib.requestAnimDict from ox_lib
QBCore.Functions.RequestAnimDict = lib.requestAnimDict

---@deprecated use PlayAnim from imports/utils.lua
QBCore.Functions.PlayAnim = PlayAnim

---@deprecated use lib.requestModel from ox_lib
QBCore.Functions.LoadModel = lib.requestModel

---@deprecated use lib.requestAnimSet from ox_lib
QBCore.Functions.LoadAnimSet = lib.requestAnimSet

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType informs default styling. Defaults to 'inform'
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
---@param subTitle? string extra text under the title
---@param notifyPosition? NotificationPosition
---@param notifyStyle? table Custom styling. Please refer too https://overextended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Custom color for the icon chosen before
function QBCore.Functions.Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    local title, description
    if type(text) == "table" then
        title = text.text or 'Placeholder'
        description = text.caption or nil
    else
        title = text
        description = subTitle
    end
    local position = notifyPosition or QBConfig.NotifyPosition

    lib.notify({
        id = title,
        title = title,
        description = description,
        duration = duration,
        type = notifyType,
        position = position,
        style = notifyStyle,
        icon = notifyIcon,
        iconColor = notifyIconColor
    })
end

---@deprecated use DebugPrint from imports/utils.lua
---prints invoking resource and obj using indent
---@param obj any
---@param indent integer
function QBCore.Debug(_, obj, indent)
    DebugPrint(obj, indent)
end

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QBCore.Functions.CreateClientCallback(name, cb)
    QBCore.ClientCallbacks[name] = cb
end

---@deprecated call a function instead
function QBCore.Functions.TriggerClientCallback(name, cb, ...)
    if not QBCore.ClientCallbacks[name] then return end
    QBCore.ClientCallbacks[name](cb, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function QBCore.Functions.TriggerCallback(name, cb, ...)
    QBCore.ServerCallbacks[name] = cb
    TriggerServerEvent('QBCore:Server:TriggerCallback', name, ...)
end

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

---@deprecated use GetVehicles from imports/utils.lua
QBCore.Functions.GetVehicles = GetVehicles

---@deprecated use GetObjects from imports/utils.lua
QBCore.Functions.GetObjects = GetObjects

---@deprecated use GetPlayersInScope from imports/utils.lua
QBCore.Functions.GetPlayers = GetPlayersInScope

---@deprecated use GetPeds from imports/utils.lua
QBCore.Functions.GetPeds = GetPeds

---@deprecated use GetClosestPed from imports/utils.lua
---Use GetClosestPlayer if wanting to ignore non-player peds
QBCore.Functions.GetClosestPed = GetClosestPed

---@deprecated use IsWearingGloves from imports/utils.lua
QBCore.Functions.IsWearingGloves = IsWearingGloves

---@deprecated use GetClosestPlayer from imports/utils.lua
QBCore.Functions.GetClosestPlayer = GetClosestPlayer

---@deprecated use GetPlayersFromCoords from imports/utils.lua
QBCore.Functions.GetPlayersFromCoords = GetPlayersFromCoords

---@deprecated use GetClosestVehicle from imports/utils.lua
QBCore.Functions.GetClosestVehicle = GetClosestVehicle

---@deprecated use GetClosestObject from imports/utils.lua
QBCore.Functions.GetClosestObject = GetClosestObject

---@deprecated use GetClosestBone from imports/utils.lua
QBCore.Functions.GetClosestBone = GetClosestBone

---@deprecated use GetBoneDistance from imports/utils.lua
QBCore.Functions.GetBoneDistance = GetBoneDistance

---@deprecated use AttachProp from imports/utils.lua
QBCore.Functions.AttachProp = AttachProp

-- Vehicle

---@deprecated call server function CreateVehicle instead from imports/utils.lua.
---@param model string|number
---@param cb? fun(vehicle: number)
---@param coords? vector4 player position if not specified
---@param isnetworked? boolean defaults to true
---@param teleportInto boolean teleport player to driver seat if true
function QBCore.Functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
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
QBCore.Functions.DeleteVehicle = DeleteVehicle

---@deprecated use GetPlate from imports/utils.lua
QBCore.Functions.GetPlate = GetPlate

---@deprecated use GetVehicleDisplayName from imports/utils.lua
QBCore.Functions.GetVehicleLabel = GetVehicleDisplayName

---@deprecated use IsVehicleSpawnClear from imports/utils.lua
QBCore.Functions.SpawnClear = IsVehicleSpawnClear

---@deprecated use lib.getVehicleProperties from ox_lib
QBCore.Functions.GetVehicleProperties = lib.getVehicleProperties

---@deprecated use lib.setVehicleProperties from ox_lib
QBCore.Functions.SetVehicleProperties = lib.setVehicleProperties

---@deprecated use lib.requestNamedPtfxAsset from ox_lib
QBCore.Functions.LoadParticleDictionary = lib.requestNamedPtfxAsset

---@deprecated use StartParticleAtCoord from imports/utils.lua
QBCore.Functions.StartParticleAtCoord = StartParticleAtCoord

---@deprecated use StartParticleOnEntity from imports/utils.lua
QBCore.Functions.StartParticleOnEntity = StartParticleOnEntity

---@deprecated use GetStreetNametAtCoords from imports/utils.lua
QBCore.Functions.GetStreetNametAtCoords = GetStreetNametAtCoords

---@deprecated use GetZoneAtCoords from imports/utils.lua
QBCore.Functions.GetZoneAtCoords = GetZoneAtCoords

---@deprecated use GetCardinalDirection from imports/utils.lua
QBCore.Functions.GetCardinalDirection = GetCardinalDirection

---@deprecated use GetCurrentTime from imports/utils.lua
QBCore.Functions.GetCurrentTime = GetCurrentTime

---@deprecated use GetGroundZCoord from imports/utils.lua
QBCore.Functions.GetGroundZCoord = GetGroundZCoord
