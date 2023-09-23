---@type 'strict'|'relaxed'|'inactive'
local bucketLockDownMode = GetConvar('qbx:bucketlockdownmode', 'relaxed')
SetRoutingBucketEntityLockdownMode(0, bucketLockDownMode)

if not lib.checkDependency('ox_lib', '3.10.0', true) then error() return end

QBCore = {}
QBCore.Config = QBConfig
QBCore.Shared = QBShared

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
QBCore.ClientCallbacks = {}

---@deprecated use https://overextended.github.io/docs/ox_lib/Callback/Lua/Server instead
QBCore.ServerCallbacks = {}

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
