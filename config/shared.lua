return {
    serverName = 'Server',
    defaultSpawn = vec4(-540.58, -212.02, 37.65, 208.88),
    notifyPosition = 'top-right', -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
    starterItems = function()
        ---@type { name: string, amount: integer, metadata: fun(source: number): table }[]
        local starterItemTable = { -- Character starting items
            { name = 'phone', amount = 1 },
            { name = 'id_card', amount = 1, metadata = function(source)
                    assert(GetResourceState('qbx_idcard') == 'started', 'qbx_idcard resource not found. Required to give an id_card as a starting item')
                    return exports.qbx_idcard:GetMetaLicense(source, {'id_card'})
                end
            },
            { name = 'driver_license', amount = 1, metadata = function(source)
                    assert(GetResourceState('qbx_idcard') == 'started', 'qbx_idcard resource not found. Required to give an id_card as a starting item')
                    return exports.qbx_idcard:GetMetaLicense(source, {'driver_license'})
                end
            },
        }
        assert(next(starterItemTable), 'starterItems is missing or incorrect in shared/config.lua')
        return starterItemTable
    end
}
