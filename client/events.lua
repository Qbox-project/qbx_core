-- Player load and unload handling
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    IsLoggedIn = true
    if not QBConfig.Server.PVP then return end
    SetCanAttackFriendly(cache.ped, true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    IsLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:PvpHasToggled', function(pvp_state)
    SetCanAttackFriendly(cache.ped, pvp_state, false)
    NetworkSetFriendlyFireOption(pvp_state)
end)
-- Teleport Commands

RegisterNetEvent('QBCore:Command:TeleportToPlayer', function(coords)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('QBCore:Command:TeleportToCoords', function(x, y, z, h)
    SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    SetEntityHeading(cache.ped, h or GetEntityHeading(cache.ped))
end)

RegisterNetEvent('QBCore:Command:GoToMarker', function()
    local blipMarker <const> = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        QBCore.Functions.Notify(Lang:t("error.no_waypoint"), "error", 5000)
        return 'marker'
    end

    -- Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = cache.ped, GetBlipInfoIdCoord(blipMarker)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords.x, coords.y, 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end

        NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        NewLoadSceneStop()
        SetPedCoordsKeepVehicle(ped, x, y, z)

        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end

        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);
        if found then
            Wait(0)
            SetPedCoordsKeepVehicle(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetPedCoordsKeepVehicle(ped, oldCoords.x, oldCoords.y, oldCoords.z - 1.0)
        QBCore.Functions.Notify(Lang:t("error.tp_error"), "error", 5000)
    end

    -- If Z coord was found, set coords in found coords.
    SetPedCoordsKeepVehicle(ped, x, y, groundZ)
    QBCore.Functions.Notify(Lang:t("success.teleported_waypoint"), "success", 5000)
end)

-- Vehicle Commands

RegisterNetEvent('QBCore:Command:SpawnVehicle', function(vehName)
    local hash = joaat(vehName)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    if cache.vehicle then
        DeleteVehicle(cache.vehicle)
    end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(cache.ped), true, false)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetModelAsNoLongerNeeded(hash)
    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
end)

RegisterNetEvent('QBCore:Command:DeleteVehicle', function()
    if cache.vehicle then
        SetEntityAsMissionEntity(cache.vehicle, true, true)
        DeleteVehicle(cache.vehicle)
    else
        local pcoords = GetEntityCoords(cache.ped)
        local vehicles = GetGamePool('CVehicle')
        for _, v in pairs(vehicles) do
            if #(pcoords - GetEntityCoords(v)) <= 5.0 then
                SetEntityAsMissionEntity(v, true, true)
                DeleteVehicle(v)
            end
        end
    end
end)

-- Other stuff

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    local invokingResource = GetInvokingResource()
    if invokingResource and invokingResource ~= GetCurrentResourceName() then return end
    QBCore.PlayerData = val
end)

---@see client/functions.lua:QBCore.Functions.NotifyV2
RegisterNetEvent('QBCore:NotifyV2', function(props)
    QBCore.Functions.NotifyV2(props)
end)

---@deprecated. Use event 'QBCore:NotifyV2' instead.
---@see client/functions.lua:QBCore.Functions.Notify
RegisterNetEvent('QBCore:Notify', function(text, notifyType, duration)
    QBCore.Functions.Notify(text, notifyType, duration)
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('QBCore:Client:TriggerClientCallback', function(name, ...)
    QBCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
RegisterNetEvent('QBCore:Client:TriggerCallback', function(name, ...)
    if QBCore.ServerCallbacks[name] then
        QBCore.ServerCallbacks[name](...)
        QBCore.ServerCallbacks[name] = nil
    end
end)

-- Me command

local function Draw3DText(coords, str)
    local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoord()
    local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
    if onScreen then
        SetTextScale(1.0, 0.5 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextProportional(true)
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(worldX, worldY)
    end
end

AddStateBagChangeHandler('me', nil, function(bagName, _, value)
    if not value then return end

    local playerId = GetPlayerFromStateBagName(bagName)

    if not playerId or not NetworkIsPlayerActive(playerId) then return end

    local isLocalPlayer = playerId == cache.playerId
    local playerPed = isLocalPlayer and cache.ped or GetPlayerPed(playerId)

    -- Here we do a entity check to see if the player exsist within each clients scope --
    if not DoesEntityExist(playerPed) then return end

    -- Distance check to make sure that players do not see others me from 100s of meters away --
    if not isLocalPlayer and #(GetEntityCoords(playerPed) - GetEntityCoords(cache.ped)) > 25 then return end

    CreateThread(function()
        local displayTime = 5000 + GetGameTimer()
        while displayTime > GetGameTimer() do
            playerPed = isLocalPlayer and cache.ped or GetPlayerPed(playerId)
            Draw3DText(GetEntityCoords(playerPed), value)
            Wait(0)
        end
    end)
end)

-- Listen to Shared being updated
RegisterNetEvent('QBCore:Client:OnSharedUpdate', function(tableName, key, value)
    QBCore.Shared[tableName][key] = value
    TriggerEvent('QBCore:Client:UpdateObject')
end)

RegisterNetEvent('QBCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QBCore.Shared[tableName][key] = value
    end
    TriggerEvent('QBCore:Client:UpdateObject')
end)
