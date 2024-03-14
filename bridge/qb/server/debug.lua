---@deprecated Call lib.print.debug() instead
---@param tbl any
RegisterServerEvent('QBCore:DebugSomething', function(tbl)
    local resource = GetInvokingResource() or 'qbx_core'
    lib.print.debug(resource, tbl)
end)
