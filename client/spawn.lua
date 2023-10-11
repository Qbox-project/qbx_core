local cam
lib.callback.register('qbx_core:client:getSpawnLocation', function(data)
    SetEntityVisible(cache.ped, false)
    SetCloudHatOpacity(0.0)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z + 1500, -85.00, 0.0, 0.0, 100.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    DoScreenFadeIn(500)

    local promise = promise.new()

    local loadApartments = function()
        if Apartments then return end
        local import = LoadResourceFile('qbx_apartments', 'config.lua')
        local chunk = assert(load(import, '@@qbx_apartments/config.lua'))
        if not chunk then return false end
        chunk()

        local i = 0
        while not Apartments and i < 1000 do
            i += 1
            Wait(10)
        end
        return Apartments
    end

    local locations = {}
    if data.isNew then
        if GetResourceState('qbx_apartments'):find('start') and Config.Characters.StartingApartment then
            if loadApartments() then
                for key, apartmentData in pairs(Apartments.Locations) do
                    locations[#locations+1] = {
                        title = apartmentData.label,
                        icon = 'fa-solid fa-building',
                        metadata = { 'The apartment you will be given' },
                        onSelect = function()
                            TriggerServerEvent('apartments:server:CreateApartment', key, apartmentData.label)
                            promise:resolve({coords = apartmentData.enter, type = 'apartment', apartment = key, isNew = true})
                        end
                    }
                end
            else
                promise:resolve(data)
            end
        else
            promise:resolve(data)
        end
    else
        locations[#locations+1] = {
            title = 'Last Location',
            icon = 'fa-solid fa-magnifying-glass-location',
            onSelect = function()
                promise:resolve(false)
            end
        }
        for i = 1, #Config.Spawn.Locations do
            locations[#locations+1] = {
                title = Config.Spawn.Locations[i].label,
                icon = 'fa-solid fa-location-dot',
                onSelect = function()
                    promise:resolve({coords = Config.Spawn.Locations[i].coords, type = 'defined'})
                end
            }
        end
        if data.houses and #data.houses > 0 then
            for i = 1, #data.houses do
                locations[#locations+1] = {
                    title = data.houses[i].label,
                    icon = 'fa-solid fa-building',
                    metadata = { 'Your house' },
                    onSelect = function()
                        promise:resolve({coords = data.houses[i].coords.enter, type = 'house', house = data.houses[i].name})
                    end
                }
            end
        end
        if data.apartment then
            loadApartments()

            locations[#locations+1] = {
                title = data.apartment.label,
                icon = 'fa-solid fa-building',
                metadata = { 'Your Apartment' },
                onSelect = function()
                    promise:resolve({coords = Apartments?.Locations[data.apartment.type].enter or false, type = 'apartment', apartment = data.apartment.type})
                end
            }
        end
    end

    if #locations > 0 then
        lib.registerContext({
            id = 'qbx_core_spawn_selector',
            title = 'Starting Points',
            canClose = false,
            options = locations
        })
        lib.showContext('qbx_core_spawn_selector')
    else
        promise:resolve(false)
    end

    :: skip ::

    return Citizen.Await(promise)
end)

---@class SpawnData
---@field type? string
---@field isNew? boolean
---@field apartment? string
---@field house? string

---@param data nil | SpawnData
RegisterNetEvent('qbx_core:client:spawn', function(data)
    if IsScreenFadedOut() then DoScreenFadeIn(500) end
    while cache.ped ~= PlayerPedId() do
        Wait(10)
    end

    local coords = data?.coords or QBX.PlayerData.position or Config.DefaultSpawn
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
    SetEntityHeading(cache.ped, coords.w)

    if data?.type == 'apartment' then
        TriggerEvent('apartments:client:EnterApartment', data.apartment)
    elseif data?.type == 'house' then
        TriggerEvent('qb-houses:client:enterOwnedHouse', data.house)
    elseif data?.type == 'defined' then
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    else --default spawn
        local inside = QBX.PlayerData.metadata.inside
        if inside.house then
            TriggerEvent('qb-houses:client:LastLocationHouse', inside.house)
        elseif inside.apartment?.apartmentType and inside.apartment?.apartmentId then
            TriggerEvent('qb-apartments:client:LastLocationHouse', inside.apartment.apartmentType, inside.apartment.apartmentId)
        end
    end

    local cam2 = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', coords.x, coords.y, coords.z + 1500, -85.00, 0.0, 0.0, 100.00, false, 0)
    PointCamAtCoord(cam2, coords.x, coords.y, coords.z + 75)
    SetCamActiveWithInterp(cam2, cam, 500, true, true)

    Wait(500)

    if DoesCamExist(cam) then DestroyCam(cam, true) end
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z + 100, -85.00, 0.0, 0.0, 100.00, false, 0)
    PointCamAtCoord(cam, coords.x, coords.y, coords.z)
    SetCamActiveWithInterp(cam, cam2, 1000, true, true)

    Wait(900)

    RenderScriptCams(false, not (data or (data?.type == 'apartment' or data?.type == 'house')), 500, true, true)
    if DoesCamExist(cam2) then
        SetCamActive(cam2, false)
        DestroyCam(cam2, true)
    end

    if data?.isNew then
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    end

    SetEntityVisible(cache.ped, true)
    FreezeEntityPosition(cache.ped, false)
end)