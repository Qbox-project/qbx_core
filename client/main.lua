QBCore = {}
QBCore.PlayerData = {}
QBCore.Config = require 'config'
QBCore.Shared = require 'shared.main'
QBCore.Functions = require 'client.functions'

IsLoggedIn = false

---import QBX using module 'qbx-core:core' https://qbox-project.github.io/resources/core/import
exports('GetCoreObject', function() return QBCore end)
