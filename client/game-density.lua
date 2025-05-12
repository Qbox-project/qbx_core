-- game-density.lua
-- Controls vehicle and ped density in specific game regions and globally

local areaPopulationControl = {
    -- Davis Quartz/Quarry area
    quarry = {
        coords = vector3(2551.0, 2862.0, 38.0),
        radius = 1200.0,
        vehicleDensity = 0.4,
        pedDensity = 0.6
    },
    -- North Yankton / snow area
    northYankton = {
        coords = vector3(3360.19, -4926.24, 170.07),
        radius = 1600.0,
        vehicleDensity = 0.3,
        pedDensity = 0.5
    },
    -- Add more problem areas as needed
}

-- Default multipliers outside special areas
local defaultSettings = {
    vehicleDensity = 1.0,
    pedDensity = 1.0
}

-- Distance-based density calculation
local function calculateDensityForLocation(playerPos)
    -- Default to normal density
    local currentVehicleDensity = defaultSettings.vehicleDensity
    local currentPedDensity = defaultSettings.pedDensity
    
    -- Check if player is in a controlled area
    for _, area in pairs(areaPopulationControl) do
        local distance = #(playerPos - area.coords)
        if distance < area.radius then
            -- Calculate gradual density change based on distance (more natural transition)
            local distanceFactor = distance / area.radius
            currentVehicleDensity = math.min(
                defaultSettings.vehicleDensity,
                area.vehicleDensity + (defaultSettings.vehicleDensity - area.vehicleDensity) * distanceFactor
            )
            currentPedDensity = math.min(
                defaultSettings.pedDensity,
                area.pedDensity + (defaultSettings.pedDensity - area.pedDensity) * distanceFactor
            )
            break
        end
    end
    
    return currentVehicleDensity, currentPedDensity
end

CreateThread(function()
    -- Wait for player to load in
    while not QBX.IsLoggedIn do
        Wait(1000)
    end
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Calculate appropriate density for current location
        local vehicleDensity, pedDensity = calculateDensityForLocation(playerCoords)
        
        -- Set traffic density multipliers
        SetParkedVehicleDensityMultiplierThisFrame(vehicleDensity)
        SetVehicleDensityMultiplierThisFrame(vehicleDensity)
        SetRandomVehicleDensityMultiplierThisFrame(vehicleDensity)
        
        -- Set pedestrian density multipliers
        SetPedDensityMultiplierThisFrame(pedDensity)
        SetScenarioPedDensityMultiplierThisFrame(pedDensity, pedDensity)
        
        -- Only need to update every half second
        Wait(500)
    end
end)

-- Add debugging command for admins
RegisterCommand('checkdensity', function()
    if QBX.Functions.GetPlayerData().job.name == 'admin' then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicleDensity, pedDensity = calculateDensityForLocation(playerCoords)
        QBX.Functions.Notify('Vehicle Density: ' .. vehicleDensity .. '\nPed Density: ' .. pedDensity, 'primary', 5000)
    end
end)

-- Export for other resources to modify density settings
exports('UpdateDensitySettings', function(areaName, settings)
    if areaPopulationControl[areaName] and type(settings) == 'table' then
        for key, value in pairs(settings) do
            if areaPopulationControl[areaName][key] ~= nil then
                areaPopulationControl[areaName][key] = value
            end
        end
        return true
    end
    return false
end)
