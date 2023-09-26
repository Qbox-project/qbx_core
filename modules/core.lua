QBX = exports.qbx_core:GetCoreObject()

if not IsDuplicityVersion() then
    QBX.IsLoggedIn = LocalPlayer.state.isLoggedIn
    AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
        QBX.IsLoggedIn = value
    end)
end
