---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBCore = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}
QBCore.Functions = require 'functions'

---@deprecated import QBCore using module 'qbx-core:core'
exports('GetCoreObject', function()
    return QBCore
end)
