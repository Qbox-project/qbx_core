if QBCore.Config.UseExternalCharacters then return end

local previewCam = nil
local randomLocation = QBCore.Config.Locations[math.random(1, #QBCore.Config.Locations)]

---@param bool boolean
local function setupPreviewCam(bool)
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(cache.ped, false)
        previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', randomLocation.camCoords.x, randomLocation.camCoords.y, randomLocation.camCoords.z, -6.0, 0.0, randomLocation.camCoords.w, 40.0, false, 0)
        SetCamActive(previewCam, true)
        SetCamUseShallowDofMode(previewCam, true)
        SetCamNearDof(previewCam, 0.4)
        SetCamFarDof(previewCam, 1.8)
        SetCamDofStrength(previewCam, 0.7)
        RenderScriptCams(true, false, 1, true, true)
        CreateThread(function()
            while DoesCamExist(previewCam) do
                SetUseHiDof()
                Wait(0)
            end
        end)
    else
        if not previewCam then return end

        SetTimecycleModifier('default')
        SetCamActive(previewCam, false)
        DestroyCam(previewCam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(cache.ped, false)
    end
end

---@param entity integer
local function randomClothes(entity)
    for i = 0, 11 do
        SetPedComponentVariation(entity, i, 0, 0, 0)
    end
    for i = 0, 7 do
        ClearPedProp(entity, i)
    end
    SetPedHeadBlendData(entity, math.random(0, 45), math.random(0, 45), 0, math.random(0, 15), math.random(0, 15), 0, math.random(0, 100) / 100, math.random(0, 100) / 100, 0, true)
    SetPedComponentVariation(entity, 4, math.random(0, 110), 0, 0)
    SetPedComponentVariation(entity, 2, math.random(0, 45), 0, 0)
    SetPedHairColor(entity, math.random(0, 45), math.random(0, 45))
    SetPedHeadOverlay(entity, 2, math.random(0, 34), 1.0)
    SetPedHeadOverlayColor(entity, 2, 1, math.random(0, 45), 0)
    SetPedComponentVariation(entity, 3, math.random(0, 160), 0, 2)
    SetPedComponentVariation(entity, 8, math.random(0, 160), 0, 2)
    SetPedComponentVariation(entity, 11, math.random(0, 340), 0, 2)
    SetPedComponentVariation(entity, 6, math.random(0, 78), 0, 2)
end

---@param citizenId? string
---@param gender? integer
local function previewPed(citizenId, gender)
    if not citizenId then
        randomClothes(cache.ped)
        return
    end

    local clothing, model = lib.callback.await('qbx-core:server:getPreviewPedData', false, citizenId)

    if model then
        local currentModel = GetEntityModel(cache.ped)
        if (currentModel ~= `mp_m_freemode_01` and gender == 0) or (currentModel ~= `mp_f_freemode_01` and gender == 1) then
            lib.requestModel(model)
            SetPlayerModel(cache.playerId, model)
        end
        SetModelAsNoLongerNeeded(model)
    end

    if clothing then
        pcall(function() exports['illenium-appearance']:setPedAppearance(cache.ped, json.decode(clothing)) end)
        return
    end

    randomClothes(cache.ped)
end

---@class CharacterRegistration
---@field firstname string
---@field lastname string
---@field nationality string
---@field gender number
---@field birthdate string
---@field cid integer

---@param canCancel boolean
---@return any[]?
local function characterDialog(canCancel)
    return lib.inputDialog(Lang:t('info.character_registration_title'), {
        {
            type = 'input', -- First name
            required = true,
            icon = 'user-pen',
            label = Lang:t('info.first_name')
        },
        {
            type = 'input', -- Last name
            required = true,
            icon = 'user-pen',
            label = Lang:t('info.last_name')
        },
        {
            type = 'input', -- Nationality
            required = true,
            icon = 'user-shield',
            label = Lang:t('info.nationality')
        },
        {
            type = 'select', -- Gender
            required = true,
            icon = 'circle-user',
            label = Lang:t('info.gender'),
            options = {
                {
                    value = Lang:t('info.char_male')
                },
                {
                    value = Lang:t('info.char_female')
                }
            }
        },
        {
            type = 'date', -- Birth date
            required = true,
            icon = 'calender-days',
            label = Lang:t('info.birth_date'),
            format = 'YYYY-MM-DD',
            min = '01/01/1900',
            max = '31/12/2006',
            default = '2006-12-31'
        }
    }, {
        allowCancel = canCancel
    })
end

---@param canCancel boolean
---@param cid integer
---@return boolean
local function createCharacter(canCancel, cid)
    previewPed()

    :: noMatch ::

    local dialog = characterDialog(canCancel)

    if not dialog then return false end

    for input = 1, 3 do
        local matched = true
        for i = 5, 1, -1 do
            local str = dialog[input]
            local pattern = ''
            for p = 1, i do
                local isDone = false
                if p == 1 then
                    pattern = '%u%l*%s'
                    isDone = true
                end

                if p == i then
                    pattern = pattern .. '%u%l*'
                    isDone = true
                end

                if p == 1 and p == i then
                    pattern = '%u%l*' -- %u checks for uppercase letter, %l checks for a lowercase letter and * extends it until there is none of them left
                end

                if not isDone then
                    pattern = pattern .. '%u%l*%s' -- %s here checks for a whitespace to allow for whitespaces in between words
                end
            end

            matched = not string.match(str, '^%s') -- Don't match if there is a trailing whitespace at the beginning
            matched = not string.match(str, '%s$') -- Don't match if there is a trailing whitespace at the end
            matched = string.match(str, pattern)
            if matched then
                matched = not QBConfig.ProfanityWords[matched:lower()]
            end
        end

        if not matched then
            QBCore.Functions.Notify(Lang:t('error.no_match_character_registration'), 'error')
            goto noMatch
            break
        end
    end

    DoScreenFadeOut(150)
    TriggerServerEvent('qbx-core:server:createCharacter', {
        firstname = dialog[1],
        lastname = dialog[2],
        nationality = dialog[3],
        gender = dialog[4] == Lang:t('info.char_male') and 0 or 1,
        birthdate = lib.callback.await('qbx-core:server:convertMsToDate', false, dialog[5]),
        cid = cid
    })
    setupPreviewCam(false)
    return true
end

local function chooseCharacter()
    randomLocation = QBCore.Config.Locations[math.random(1, #QBCore.Config.Locations)]

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    FreezeEntityPosition(cache.ped, true)
    Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)
    randomClothes(cache.ped)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    setupPreviewCam(true)

    ---@type PlayerEntity[], integer
    local characters, amount = lib.callback.await('qbx-core:server:getCharacters', false)
    local options = {}
    for i = 1, QBCore.Config.UseMultichar and amount or 1 do
        local character = characters[i]
        local name = character and character.charinfo.firstname .. ' ' .. character.charinfo.lastname
        options[i] = {
            title = character and string.format('%s %s - %s', character.charinfo.firstname, character.charinfo.lastname, character.citizenid) or Lang:t('info.multichar_new_character', { number = i }),
            metadata = character and {
                ['Account Number'] = character.charinfo.account,
                Bank = CommaValue(character.money.bank),
                Birthdate = character.charinfo.birthdate,
                Cash = CommaValue(character.money.cash),
                Gender = character.charinfo.gender == 0 and Lang:t('info.char_male') or Lang:t('info.char_female'),
                Job = character.job.label,
                ['Job Grade'] = character.job.grade.name,
                Name = name,
                Nationality = character.charinfo.nationality,
                ['Phone Number'] = character.charinfo.phone
            } or nil,
            icon = 'user',
            onSelect = function()
                if character then
                    lib.showContext('qbx_core_multichar_character_'..i)
                    previewPed(character.citizenid, character.charinfo.gender)
                    return
                end

                local success = createCharacter(true, i)
                if success then return end

                lib.showContext('qbx_core_multichar_characters')
            end
        }

        if character then
            lib.registerContext({
                id = 'qbx_core_multichar_character_'..i,
                title = string.format('%s %s - %s', character.charinfo.firstname, character.charinfo.lastname, character.citizenid),
                canClose = false,
                menu = 'qbx_core_multichar_characters',
                options = {
                    {
                        title = Lang:t('info.play'),
                        description = Lang:t('info.play_description', { playerName = name }),
                        icon = 'play',
                        onSelect = function()
                            DoScreenFadeOut(10)
                            TriggerServerEvent('qbx-core:server:loadCharacter', character.citizenid)
                            setupPreviewCam(false)
                        end
                    },
                    QBCore.Config.EnableDeleteButton and {
                        title = Lang:t('info.delete_character'),
                        description = Lang:t('info.delete_character_description', { playerName = name }),
                        icon = 'trash',
                        onSelect = function()
                            TriggerServerEvent('qbx-core:server:deleteCharacter', character.citizenid)
                            setupPreviewCam(false)
                            chooseCharacter()
                        end
                    } or nil
                }
            })
        end
    end

    lib.registerContext({
        id = 'qbx_core_multichar_characters',
        title = Lang:t('info.multichar_title'),
        canClose = false,
        options = options
    })

    lib.showContext('qbx_core_multichar_characters')
end

lib.callback.register('qbx-core:client:defaultSpawn', function() -- We use a callback to make the server wait on this to be done
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    setupPreviewCam(false)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    pcall(function() exports.spawnmanager:spawnPlayer() end)

    while not IsScreenFadedIn() do
        Wait(0)
    end

    return true
end)

RegisterNetEvent('qbx-core:client:spawnNoApartments', function() -- This event is only for no starting apartments
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(cache.ped, QBCore.Config.DefaultSpawn.x, QBCore.Config.DefaultSpawn.y, QBCore.Config.DefaultSpawn.z, false, false, false, false)
    SetEntityHeading(cache.ped, QBCore.Config.DefaultSpawn.w)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    setupPreviewCam(false)
    SetEntityVisible(cache.ped, true, false)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qbx-core:client:chooseCharacter', function()
    if GetInvokingResource() then return end -- Make sure this can only be triggered from the server
    chooseCharacter()
end)

CreateThread(function()
	local modelHash = `mp_m_freemode_01`
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            chooseCharacter()
            lib.requestModel(modelHash)
            while GetEntityModel(cache.ped) ~= modelHash do
                SetPlayerModel(cache.playerId, modelHash)
                Wait(100)
            end
            break
        end
	end
end)
