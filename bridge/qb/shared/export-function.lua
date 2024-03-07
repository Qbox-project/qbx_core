return function (name, cb)
    AddEventHandler(('__cfx_export_qb-core_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end