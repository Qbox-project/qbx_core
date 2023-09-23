---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBCore = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared

---@deprecated import QBCore using module 'qbx-core:core'
exports('GetCoreObject', function()
    return QBCore
end)
