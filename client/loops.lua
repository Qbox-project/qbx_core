CreateThread(function()
    local timeout = 60000 * QBCore.Config.StatusInterval
    while true do
        Wait(timeout)

        if IsLoggedIn then
            if (QBCore.PlayerData.metadata.hunger <= 0 or QBCore.PlayerData.metadata.thirst <= 0) and not QBCore.PlayerData.metadata.isdead then
                local currentHealth = GetEntityHealth(cache.ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(cache.ped, currentHealth - decreaseThreshold)
            end
        end
    end
end)
