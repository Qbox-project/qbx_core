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

---@param pvp_state boolean
RegisterNetEvent('QBCore:Client:PvpHasToggled', function(pvp_state)
    SetCanAttackFriendly(cache.ped, pvp_state, false)
    NetworkSetFriendlyFireOption(pvp_state)
end)

-- Trigger Command
--- @deprecated
RegisterNetEvent('QBCore:Command:CallCommand', function(command)
    ExecuteCommand(command)
end)

-- Teleport Commands

---@param coords vector3
RegisterNetEvent('QBCore:Command:TeleportToPlayer', function(coords)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

---@param x number
---@param y number
---@param z number
---@param h number
RegisterNetEvent('QBCore:Command:TeleportToCoords', function(x, y, z, h)
    SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    SetEntityHeading(cache.ped, h or GetEntityHeading(cache.ped))
end)

---@return 'marker'? error present if player did not place a blip
RegisterNetEvent('QBCore:Command:GoToMarker', function()
    local blipMarker <const> = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        QBCore.Functions.Notify(Lang:t("error.no_waypoint"), 'error')
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
        QBCore.Functions.Notify(Lang:t("error.tp_error"), 'error')
    end

    -- If Z coord was found, set coords in found coords.
    SetPedCoordsKeepVehicle(ped, x, y, groundZ)
    QBCore.Functions.Notify(Lang:t("success.teleported_waypoint"), 'success')
end)

-- Vehicle Commands

EntityStateHandler('initVehicle', function(entity, _, value)
    if not value then return end

    for i = -1, 0 do
        local ped = GetPedInVehicleSeat(entity, i)

        if ped ~= cache.ped and ped > 0 and NetworkGetEntityOwner(ped) == cache.playerId then
            DeleteEntity(ped)
        end
    end

    if NetworkGetEntityOwner(entity) ~= cache.playerId then return end
    SetVehicleNeedsToBeHotwired(entity, false)
    SetVehRadioStation(entity, 'OFF')
    SetVehicleFuelLevel(entity, 100.0)
    SetVehicleDirtLevel(entity, 0.0)
    Entity(entity).state:set('initVehicle', nil, true)
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

---@param val PlayerData
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    local invokingResource = GetInvokingResource()
    if invokingResource and invokingResource ~= GetCurrentResourceName() then return end
    QBCore.PlayerData = val
end)

---@see client/functions.lua:QBCore.Functions.Notify
RegisterNetEvent('QBCore:Notify', function(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    QBCore.Functions.Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
end)

-- Callback Events --

-- Client Callback
---@deprecated call a function instead
RegisterNetEvent('QBCore:Client:TriggerClientCallback', function(name, ...)
    QBCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('QBCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Server Callback
---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
RegisterNetEvent('QBCore:Client:TriggerCallback', function(name, ...)
    if QBCore.ServerCallbacks[name] then
        QBCore.ServerCallbacks[name](...)
        QBCore.ServerCallbacks[name] = nil
    end
end)

-- Me command

---@param coords vector3
---@param str string
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

---@param bagName string
---@param value string
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
---@param tableName string
---@param key any
---@param value any
RegisterNetEvent('QBCore:Client:OnSharedUpdate', function(tableName, key, value)
    QBCore.Shared[tableName][key] = value
    TriggerEvent('QBCore:Client:UpdateObject')
end)

---@param tableName string
---@param values table<any, any>
RegisterNetEvent('QBCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        QBCore.Shared[tableName][key] = value
    end
    TriggerEvent('QBCore:Client:UpdateObject')
end)
