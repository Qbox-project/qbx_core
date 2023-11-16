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

local gameBuild = GetGameBuildNumber()

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

    if (props.tireBurstCompletely or props.tireBurstState) and not props.tyres then
        props.tyres = {}
        for i = 0, 7 do
            props.tyres[i] = props.tireBurstCompletely and props.tireBurstCompletely[i] and 2 or props.tireBurstState and props.tireBurstState[i] and 1 or nil
        end
    end

    local numWindowsDamaged = 0
    if props.windowStatus and not props.windows then
        props.windows = {}
        for i, isDamaged in pairs(props.windowStatus) do
            if isDamaged then
                numWindowsDamaged += 1
                props.windows[numWindowsDamaged] = i
            end
        end
    end

    local numDoorsDamaged = 0
    if props.doorStatus and not props.doors then
        props.doors = {}
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

   
    --- lib.setVehicleProperties copied and pasted from Overextended below so that we can remove the error so that setting properties is best effort
    if not DoesEntityExist(vehicle) then
        error(("Unable to set vehicle properties for '%s' (entity does not exist)"):
        format(vehicle))
    end

    if NetworkGetEntityIsNetworked(vehicle) and NetworkGetEntityOwner(vehicle) ~= cache.playerId then
        lib.print.warn('setting vehicle properties on non entity owner client. This may cause certain properties to fail to set. entity:', vehicle)
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)
    -- SetVehicleAutoRepairDisabled(vehicle, true)

    if props.extras then
        for id, disable in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(id) --[[@as number]], disable == 1)
        end
    end

    if props.plate then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end

    if props.plateIndex then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end

    if props.bodyHealth then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end

    if props.engineHealth then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end

    if props.tankHealth then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end

    if props.fuelLevel then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end

    if props.oilLevel then
        SetVehicleOilLevel(vehicle, props.oilLevel + 0.0)
    end

    if props.dirtLevel then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end

    if props.color1 then
        if type(props.color1) == 'number' then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 --[[@as number]], colorSecondary --[[@as number]])
        else
            if props.paintType1 then SetVehicleModColor_1(vehicle, props.paintType1, colorPrimary, pearlescentColor) end

            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        end
    end

    if props.color2 then
        if type(props.color2) == 'number' then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 or colorPrimary --[[@as number]], props.color2 --[[@as number]])
        else
            if props.paintType2 then SetVehicleModColor_2(vehicle, props.paintType2, colorSecondary) end

            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        end
    end

    if props.pearlescentColor or props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor or wheelColor)
    end

    if props.interiorColor then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheels then
        SetVehicleWheelType(vehicle, props.wheels)
    end

    if props.wheelSize then
        SetVehicleWheelSize(vehicle, props.wheelSize)
    end

    if props.wheelWidth then
        SetVehicleWheelWidth(vehicle, props.wheelWidth)
    end

    if props.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled then
        for i = 1, #props.neonEnabled do
            SetVehicleNeonLightEnabled(vehicle, i - 1, props.neonEnabled[i])
        end
    end

    if props.windows then
        for i = 1, #props.windows do
            RemoveVehicleWindow(vehicle, props.windows[i])
        end
    end

    if props.doors then
        for i = 1, #props.doors do
            SetVehicleDoorBroken(vehicle, props.doors[i], true)
        end
    end

    if props.tyres then
        for tyre, state in pairs(props.tyres) do
            SetVehicleTyreBurst(vehicle, tonumber(tyre) --[[@as number]], state == 2, 1000.0)
        end
    end

    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
    end

    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    if props.modSpoilers then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end

    if props.modFrontBumper then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end

    if props.modRearBumper then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end

    if props.modSideSkirt then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end

    if props.modExhaust then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end

    if props.modFrame then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end

    if props.modGrille then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end

    if props.modHood then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end

    if props.modFender then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end

    if props.modRightFender then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end

    if props.modRoof then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props.modEngine then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end

    if props.modBrakes then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end

    if props.modTransmission then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end

    if props.modHorns then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end

    if props.modSuspension then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end

    if props.modArmor then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end

    if props.modNitrous then
        SetVehicleMod(vehicle, 17, props.modNitrous, false)
    end

    if props.modTurbo ~= nil then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end

    if props.modSubwoofer ~= nil then
        ToggleVehicleMod(vehicle, 19, props.modSubwoofer)
    end

    if props.modHydraulics ~= nil then
        ToggleVehicleMod(vehicle, 21, props.modHydraulics)
    end

    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end

    if props.xenonColor then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end

    if props.modFrontWheels then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
    end

    if props.modBackWheels then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
    end

    if props.modPlateHolder then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end

    if props.modVanityPlate then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end

    if props.modTrimA then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end

    if props.modOrnaments then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end

    if props.modDashboard then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end

    if props.modDial then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end

    if props.modDoorSpeaker then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end

    if props.modSeats then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end

    if props.modSteeringWheel then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end

    if props.modShifterLeavers then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end

    if props.modAPlate then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end

    if props.modSpeakers then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end

    if props.modTrunk then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end

    if props.modHydrolic then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end

    if props.modEngineBlock then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end

    if props.modAirFilter then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end

    if props.modStruts then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end

    if props.modArchCover then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end

    if props.modAerials then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end

    if props.modTrimB then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end

    if props.modTank then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end

    if props.modWindows then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modDoorR then
        SetVehicleMod(vehicle, 47, props.modDoorR, false)
    end

    if props.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.modRoofLivery then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.modLightbar then
        SetVehicleMod(vehicle, 49, props.modLightbar, false)
    end

    if props.bulletProofTyres ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres)
    end

    if gameBuild >= 2372 and props.driftTyres then
        SetDriftTyresEnabled(vehicle, true)
    end

    return true
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
