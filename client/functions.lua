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
QBCore.Functions.GetCoords = GetCoords

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

---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
---@alias NotificationType 'info' | 'warning' | 'success' | 'error'
---@alias DeprecatedNotificationType 'primary'

---@class NotifyProps
---@field id? string notifications with the same id will not be on the screen at the same time
---@field title? string displayed to the player
---@field description? string displayed to the player
---@field duration? number milliseconds notification is on screen
---@field position? NotificationPosition
---@field type? NotificationType
---@field style? { [string]: any }
---@field icon? string https://fontawesome.com icon name
---@field iconColor? string css color value for the icon

---Text box popup for player which dissappears after a set time.
---@param props NotifyProps
function QBCore.Functions.NotifyV2(props)
    if not props.position then
        props.position = QBConfig.NotifyPosition
    end
    lib.notify(props)
end

---Text box popup for player which dissappears after a set time.
---@deprecated use QBCore.Functions.NotifyV2
---@param text table|string text of the notification
---@param notifyType? NotificationType|DeprecatedNotificationType informs default styling. Defaults to 'inform'.
---@param duration? integer milliseconds notification will remain on scren. Defaults to 5000.
function QBCore.Functions.Notify(text, notifyType, duration)
    print(string.format("%s invoked deprecated function Notify. Use NotifyV2 instead.", GetInvokingResource()))
    notifyType = notifyType or 'info'
    if notifyType == 'primary' then notifyType = 'info' end
    duration = duration or 5000
    local position = QBConfig.NotifyPosition
    if type(text) == "table" then
        local title = text.text or 'Placeholder'
        local description = text.caption or 'Placeholder'
        lib.notify({ title = title, description = description, duration = duration, type = notifyType --[[@as NotificationType]], position = position})
    else
        lib.notify({ description = text, duration = duration, type = notifyType --[[@as NotificationType]], position = position})
    end
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
    print(string.format("%s invoked deprecated client function QBCore.Functions.SpawnVehicle. call server function QBCore.Functions.CreateVehicle instead.", GetInvokingResource()))
    coords = type(coords) == 'table' and vec4(coords.x, coords.y, coords.z, coords.w or GetEntityHeading(cache.ped)) or coords or GetCoords(cache.ped)
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
