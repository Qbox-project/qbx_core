QBCore = QBCore or exports['qbx-core']:GetCoreObject()
PlayerData = QBCore.PlayerData

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.PlayerData
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

function SetPlayerData(value)
    PlayerData = value
    QBCore.PlayerData = value
end
