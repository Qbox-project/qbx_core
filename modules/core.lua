QBX = exports.qbx_core:GetCoreObject()

if not IsDuplicityVersion() then
    AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
        QBX.IsLoggedIn = value
    end)
end
