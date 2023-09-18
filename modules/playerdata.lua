QBCore = QBCore or exports['qbx-core']:GetCoreObject()
PlayerData = QBCore.PlayerData

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.PlayerData
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
