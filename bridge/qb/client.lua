local qbCoreCompat = QBCore

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
qbCoreCompat.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
qbCoreCompat.ServerCallbacks = {}

---@enum Position
local positions = {
    left = 'left-center',
    right = 'right-center',
    top = 'top-center'
}

---@deprecated use ox_lib showTextUI calls directly
local function hideText()
    lib.hideTextUI()
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function drawText(text, position)
    position = positions[position] or position
    lib.showTextUI(text, {
        position = position
    })
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function changeText(text, position)
    position = positions[position] or position
    lib.hideTextUI()
    lib.showTextUI(text, {
        position = position
    })
end

---@deprecated use ox_lib showTextUI calls directly
local function keyPressed()
    CreateThread(function() -- Not sure if a thread is needed but why not eh?
        Wait(500)
        lib.hideTextUI()
    end)
end

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:HideText', function()
    lib.hideTextUI()
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:KeyPressed', function()
    keyPressed()
end)

-- Trigger Command
--- @deprecated
RegisterNetEvent('qb-core:Command:CallCommand', function(command)
    ExecuteCommand(command)
end)

-- Callback Events --

-- Client Callback
---@deprecated call a function instead
RegisterNetEvent('qb-core:Client:TriggerClientCallback', function(name, ...)
    qbCoreCompat.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('qb-core:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
RegisterNetEvent('qb-core:Client:TriggerCallback', function(name, ...)
    if qbCoreCompat.ServerCallbacks[name] then
        qbCoreCompat.ServerCallbacks[name](...)
        qbCoreCompat.ServerCallbacks[name] = nil
    end
end)

---@deprecated import PlayerData using module 'qbx-core:playerdata' https://qbox-docs.vercel.app/resources/core/import
---@param cb? fun(playerData: PlayerData)
---@return PlayerData? playerData
function qbCoreCompat.Functions.GetPlayerData(cb)
    if not cb then return qbCoreCompat.PlayerData end
    cb(qbCoreCompat.PlayerData)
end

---@deprecated use GetCoordsFromEntity from imports/utils.lua
qbCoreCompat.Functions.GetCoords = GetCoordsFromEntity

---@deprecated use https://overextended.dev/ox_inventory/Functions/Client#search
qbCoreCompat.Functions.HasItem = HasItem

-- Utility

---@deprecated use DrawText2D from imports/utils.lua
qbCoreCompat.Functions.DrawText = DrawText2D

---@deprecated use DrawText3D from imports/utils.lua
qbCoreCompat.Functions.DrawText3D = DrawText3D

---@deprecated use lib.requestAnimDict from ox_lib
qbCoreCompat.Functions.RequestAnimDict = lib.requestAnimDict

---@deprecated use PlayAnim from imports/utils.lua
qbCoreCompat.Functions.PlayAnim = PlayAnim

---@deprecated use lib.requestModel from ox_lib
qbCoreCompat.Functions.LoadModel = lib.requestModel

---@deprecated use lib.requestAnimSet from ox_lib
qbCoreCompat.Functions.LoadAnimSet = lib.requestAnimSet

---@deprecated Use lib.print.debug()
---@param obj any
function qbCoreCompat.Debug(_, obj)
    lib.print.debug(obj)
end

-- Callback Functions --

-- Client Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function qbCoreCompat.Functions.CreateClientCallback(name, cb)
    qbCoreCompat.ClientCallbacks[name] = cb
end

---@deprecated call a function instead
function qbCoreCompat.Functions.TriggerClientCallback(name, cb, ...)
    if not qbCoreCompat.ClientCallbacks[name] then return end
    qbCoreCompat.ClientCallbacks[name](cb, ...)
end

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
function qbCoreCompat.Functions.TriggerCallback(name, cb, ...)
    qbCoreCompat.ServerCallbacks[name] = cb
    TriggerServerEvent('qb-core:Server:TriggerCallback', name, ...)
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
function qbCoreCompat.Functions.Progressbar(_, label, duration, useWhileDead, canCancel, disableControls, animation, prop, _, onFinish, onCancel)
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
qbCoreCompat.Functions.GetVehicles = GetVehicles

---@deprecated use GetObjects from imports/utils.lua
qbCoreCompat.Functions.GetObjects = GetObjects

---@deprecated use GetPlayersInScope from imports/utils.lua
qbCoreCompat.Functions.GetPlayers = GetPlayersInScope

---@deprecated use GetPeds from imports/utils.lua
qbCoreCompat.Functions.GetPeds = GetPeds

---@deprecated use GetClosestPed from imports/utils.lua
---Use GetClosestPlayer if wanting to ignore non-player peds
qbCoreCompat.Functions.GetClosestPed = GetClosestPed

---@deprecated use IsWearingGloves from imports/utils.lua
qbCoreCompat.Functions.IsWearingGloves = IsWearingGloves

---@deprecated use GetClosestPlayer from imports/utils.lua
qbCoreCompat.Functions.GetClosestPlayer = GetClosestPlayer

---@deprecated use GetPlayersFromCoords from imports/utils.lua
qbCoreCompat.Functions.GetPlayersFromCoords = GetPlayersFromCoords

---@deprecated use GetClosestVehicle from imports/utils.lua
qbCoreCompat.Functions.GetClosestVehicle = GetClosestVehicle

---@deprecated use GetClosestObject from imports/utils.lua
qbCoreCompat.Functions.GetClosestObject = GetClosestObject

---@deprecated use GetClosestBone from imports/utils.lua
qbCoreCompat.Functions.GetClosestBone = GetClosestBone

---@deprecated use GetBoneDistance from imports/utils.lua
qbCoreCompat.Functions.GetBoneDistance = GetBoneDistance

---@deprecated use AttachProp from imports/utils.lua
qbCoreCompat.Functions.AttachProp = AttachProp

-- Vehicle

---@deprecated call server function CreateVehicle instead from imports/utils.lua.
---@param model string|number
---@param cb? fun(vehicle: number)
---@param coords? vector4 player position if not specified
---@param isnetworked? boolean defaults to true
---@param teleportInto boolean teleport player to driver seat if true
function qbCoreCompat.Functions.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
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
qbCoreCompat.Functions.DeleteVehicle = DeleteVehicle

---@deprecated use GetPlate from imports/utils.lua
qbCoreCompat.Functions.GetPlate = GetPlate

---@deprecated use GetVehicleDisplayName from imports/utils.lua
qbCoreCompat.Functions.GetVehicleLabel = GetVehicleDisplayName

---@deprecated use IsVehicleSpawnClear from imports/utils.lua
qbCoreCompat.Functions.SpawnClear = IsVehicleSpawnClear

---@deprecated use lib.getVehicleProperties from ox_lib
qbCoreCompat.Functions.GetVehicleProperties = lib.getVehicleProperties

---@deprecated use lib.setVehicleProperties from ox_lib
qbCoreCompat.Functions.SetVehicleProperties = lib.setVehicleProperties

---@deprecated use lib.requestNamedPtfxAsset from ox_lib
qbCoreCompat.Functions.LoadParticleDictionary = lib.requestNamedPtfxAsset

---@deprecated use StartParticleAtCoord from imports/utils.lua
qbCoreCompat.Functions.StartParticleAtCoord = StartParticleAtCoord

---@deprecated use StartParticleOnEntity from imports/utils.lua
qbCoreCompat.Functions.StartParticleOnEntity = StartParticleOnEntity

---@deprecated use GetStreetNameAtCoords from imports/utils.lua
qbCoreCompat.Functions.GetStreetNametAtCoords = GetStreetNameAtCoords

---@deprecated use GetZoneAtCoords from imports/utils.lua
qbCoreCompat.Functions.GetZoneAtCoords = GetZoneAtCoords

---@deprecated use GetCardinalDirection from imports/utils.lua
qbCoreCompat.Functions.GetCardinalDirection = GetCardinalDirection

---@deprecated use GetCurrentTime from imports/utils.lua
qbCoreCompat.Functions.GetCurrentTime = GetCurrentTime

---@deprecated use GetGroundZCoord from imports/utils.lua
qbCoreCompat.Functions.GetGroundZCoord = GetGroundZCoord


local function QbExport(name, cb)
    AddEventHandler(string.format('__cfx_export_qb-core_%s', name), function(setCB)
        setCB(cb)
    end)
end

---@deprecated use ox_lib showTextUI calls directly
QbExport('DrawText', drawText)
---@deprecated use ox_lib showTextUI calls directly
QbExport('ChangeText', changeText)
---@deprecated use ox_lib showTextUI calls directly
QbExport('HideText', hideText)
---@deprecated use ox_lib showTextUI calls directly
QbExport('KeyPressed', keyPressed)

---@deprecated import QBCore using module 'qbx-core:core'
AddEventHandler('__cfx_export_qb-core_GetCoreObject', function(setCB)
    setCB(function()
        return qbCoreCompat
    end)
end)