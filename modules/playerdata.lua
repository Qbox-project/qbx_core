QBCore = QBCore or exports['qbx-core']:GetCoreObject()
PlayerData = QBCore.Functions.GetPlayerData()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if OnPlayerData then
        OnPlayerData(PlayerData)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    if OnPlayerData then
        OnPlayerData(PlayerData)
    end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(value)
    PlayerData = value
    if OnPlayerData then
        OnPlayerData(PlayerData)
    end
end)
