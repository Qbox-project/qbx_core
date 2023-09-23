---@deprecated Call lib.print.debug() instead
---@param tbl any
---@param indent integer
RegisterServerEvent('QBCore:DebugSomething', function(tbl, indent)
    local resource = GetInvokingResource() or "qbx-core"
    lib.print.debug(resource, tbl)
end)

---@deprecated Call lib.print.debug() instead
QBCore.Debug = DebugPrint

---@deprecated Call lib.print.error() instead
---@param resource string
---@param msg string
function QBCore.ShowError(resource, msg)
    lib.print.error(resource, msg)
end

---@deprecated Use lib.print.info() instead
---@param resource string
---@param msg string
function QBCore.ShowSuccess(resource, msg)
    lib.print.info(resource, msg)
end
