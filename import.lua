--[[
    Usage:

    shared_script '@qbx-core/import.lua'

    modules { -- Can be `module 'module_name'` as well
        'module_name', -- This is the name of the file in the modules folder in qbx-core without the .lua
        'client:module_name' -- You can specify the side it should be loaded on like this
    }
]]

local resourceName = 'qbx-core'
local isServer = IsDuplicityVersion()

for i = 0, GetNumResourceMetadata(resourceName, 'module') - 1 do
    local module = GetResourceMetadata(resourceName, 'module', i)
    if module then
        local file = module
        local split = {string.strsplit(':', module)}
        local doLoad = true
        if #split > 1 then
            doLoad = split[1] == 'client' and not isServer or split[1] == 'server' and isServer or split[1] == 'shared'
            file = split[2]
        end

        if doLoad then
            local path = ('modules/%s.lua'):format(file)
            local import = LoadResourceFile(resourceName, path)
            local chunk = assert(load(import, ('@@%s/%s'):format(resourceName, path)))
            if chunk then
                chunk()
            end
        end
    end
end
