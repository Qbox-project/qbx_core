if IsDuplicityVersion() then return end

QBX = QBX or exports.qbx_core:GetCoreObject() -- luacheck: ignore
QBX.PlayerData = QBX.Functions.GetPlayerData()

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    QBX.PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(value)
    QBX.PlayerData = value
end)
