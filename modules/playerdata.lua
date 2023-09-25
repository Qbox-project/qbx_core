if IsDuplicityVersion() then return end
QBX = QBCore -- luacheck: ignore
PlayerData = QBCore.PlayerData -- luacheck: ignore

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(value)
    PlayerData = value
    QBCore.PlayerData = value
end)
