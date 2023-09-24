QBCore = {}
QBCore.PlayerData = {}
QBCore.Config = require 'config'
QBCore.Shared = require 'shared.main'
QBCore.Functions = require 'client.functions'

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
QBCore.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Client/ instead
QBCore.ServerCallbacks = {}

IsLoggedIn = false

---@deprecated import QBCore using module 'qbx-core:core' https://qbox-docs.vercel.app/resources/core/import
exports('GetCoreObject', function()
    return QBCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local QBCore = exports['qbx-core']:GetCoreObject()

---@deprecated import QBCore using module 'qbx-core:core' https://qbox-docs.vercel.app/resources/core/import
AddEventHandler('__cfx_export_qb-core_GetCoreObject', function(setCB)
    setCB(function()
        return QBCore
    end)
end)
