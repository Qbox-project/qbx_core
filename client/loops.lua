CreateThread(function()
    local timeout = 60000 * Config.StatusInterval
    while true do
        Wait(timeout)

        if QBX.IsLoggedIn then
            if (QBX.PlayerData.metadata.hunger <= 0 or QBX.PlayerData.metadata.thirst <= 0) and not QBX.PlayerData.metadata.isdead then
                local currentHealth = GetEntityHealth(cache.ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(cache.ped, currentHealth - decreaseThreshold)
            end
        end
    end
end)

CreateThread(function()
    local mapText = Config.Server.PauseMapText
    if mapText == '' or type(mapText) ~= 'string' then mapText = 'FiveM' end
    Citizen.InvokeNative(joaat('ADD_TEXT_ENTRY'), 'FE_THDR_GTAO', mapText)
end)