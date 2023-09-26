QBX = {}
QBX.PlayerData = {}
QBX.Config = require 'config'
QBX.Shared = require 'shared.main'
QBX.Functions = require 'client.functions'
QBX.IsLoggedIn = LocalPlayer.state.isLoggedIn or false

---@deprecated import QBX using module 'qbx_core:core' https://qbox-project.github.io/resources/core/import
exports('GetCoreObject', function() return QBX end)
