QBCore = {}
QBCore.PlayerData = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared
QBCore.Functions = {}

IsLoggedIn = false

---@deprecated import QBCore using module 'qbx-core:core'
exports('GetCoreObject', function()
    return QBCore
end)