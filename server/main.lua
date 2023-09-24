---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBCore = {}
QBCore.Config = require 'config'
QBCore.Shared = require 'shared.main'

---@alias Source integer
---@type table<Source, Player>
QBCore.Players = {}
GlobalState.PlayerCount = 0

QBCore.Player = require 'server.player'

QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}
QBCore.Functions = require 'server.functions'

---@deprecated import QBCore using module 'qbx-core:core' https://qbox-docs.vercel.app/resources/core/import
exports('GetCoreObject', function()
    return QBCore
end)