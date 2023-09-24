QBCore = {}
QBCore.PlayerData = {}
QBCore.Config = require 'config'
QBCore.Shared = require 'shared.main'
QBCore.Functions = require 'client.functions'

IsLoggedIn = false

---@deprecated import QBCore using module 'qbx-core:core' https://qbox-docs.vercel.app/resources/core/import
exports('GetCoreObject', function()
    return QBCore
end)