CreateThread(function()
    local timeout = 60000 * QBCore.Config.StatusInterval
    while true do
        Wait(timeout)

        if IsLoggedIn then
            if (QBCore.PlayerData.metadata.hunger <= 0 or QBCore.PlayerData.metadata.thirst <= 0) and not QBCore.PlayerData.metadata.isdead then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
    end
end)
