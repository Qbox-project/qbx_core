if IsDuplicityVersion() then return end

QBX = {} -- luacheck: ignore
QBX.PlayerData = exports.qbx_core:GetPlayerData() or {}

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    QBX.PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(value)
    QBX.PlayerData = value
end)
