---prints invoking resource, and tbl.
---@deprecated
---@param tbl any
---@param indent integer
RegisterServerEvent('QBCore:DebugSomething', function(tbl, indent)
    local resource = GetInvokingResource() or "qbx-core"
    print(('\x1b[4m\x1b[36m[ %s : DEBUG]\x1b[0m'):format(resource))
    DebugPrint(tbl, indent)
    print('\x1b[4m\x1b[36m[ END DEBUG ]\x1b[0m')
end)

---@deprecated
QBCore.Debug = DebugPrint

---@deprecated
---@param resource string
---@param msg string
function QBCore.ShowError(resource, msg)
    DebugPrint(('\x1b[31m[%s:ERROR]\x1b[0m %s'):format(resource, msg))
end

---@deprecated
---@param resource string
---@param msg string
function QBCore.ShowSuccess(resource, msg)
    DebugPrint(('\x1b[32m[%s:LOG]\x1b[0m %s'):format(resource, msg))
end
