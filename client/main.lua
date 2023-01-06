QBCore = {}
QBCore.PlayerData = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared
ClientCallbacks = {}
ServerCallbacks = {}
IsLoggedIn = false

exports('GetCoreObject', function()
    return QBCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('__cfx_export_es_extended_getSharedObject', function(setCB)
    setCB(function()
        return QBCore
    end)
end)
