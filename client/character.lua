if Config.Characters.UseExternalCharacters then return end

local previewCam = nil
local randomLocation = Config.Characters.Locations[math.random(1, #Config.Characters.Locations)]

local function setupPreviewCam()
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
end

local function destroyPreviewCam()
    if not previewCam then return end

    SetTimecycleModifier('default')
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(cache.ped, false)
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

    local clothing, model = lib.callback.await('qbx_core:server:getPreviewPedData', false, citizenId)

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
    else
        randomClothes(cache.ped)
    end
end

---@class CharacterRegistration
---@field firstname string
---@field lastname string
---@field nationality string
---@field gender number
---@field birthdate string
---@field cid integer

---@return string[]?
local function characterDialog()
    return lib.inputDialog(Lang:t('info.character_registration_title'), {
        {
            type = 'input',
            required = true,
            icon = 'user-pen',
            label = Lang:t('info.first_name'),
            placeholder = 'Hank'
        },
        {
            type = 'input',
            required = true,
            icon = 'user-pen',
            label = Lang:t('info.last_name'),
            placeholder = 'Jordan'
        },
        {
            type = 'input',
            required = true,
            icon = 'user-shield',
            label = Lang:t('info.nationality'),
            placeholder = 'Duck'
        },
        {
            type = 'select',
            required = true,
            icon = 'circle-user',
            label = Lang:t('info.gender'),
            placeholder = Lang:t('info.select_gender'),
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
            type = 'date',
            required = true,
            icon = 'calendar-days',
            label = Lang:t('info.birth_date'),
            format = 'YYYY-MM-DD',
            returnString = true,
            min = '1900-01-01', -- Has to be in the same in the same format as the format argument
            max = '2006-12-31', -- Has to be in the same in the same format as the format argument
            default = '2006-12-31'
        }
    })
end

---@param dialog string[]
---@param input integer
---@return boolean
local function checkStrings(dialog, input)
    local str = dialog[input]
    if Config.Characters.ProfanityWords[str:lower()] then return false end

    local split = {string.strsplit(' ', str)}
    if #split > 5 then return false end

    for i = 1, #split do
        local word = split[i]
        if Config.Characters.ProfanityWords[word:lower()] then return false end
        if not string.match(word, '%u%l*') then return false end -- Pattern checks for an uppercase letter at the first character and lowercase for the rest
    end

    return true
end

local function spawnDefault() -- We use a callback to make the server wait on this to be done
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer() end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end

---@param cid integer
---@return boolean
local function createCharacter(cid)
    previewPed()

    :: noMatch ::

    local dialog = characterDialog()

    if not dialog then return false end

    for input = 1, 3 do -- Run through first 3 inputs, aka first name, last name and nationality
        if not checkStrings(dialog, input) then
            Notify(Lang:t('error.no_match_character_registration'), 'error', 10000)
            goto noMatch
            break
        end
    end

    DoScreenFadeOut(150)
    local newData = lib.callback.await('qbx_core:server:createCharacter', false, {
        firstname = dialog[1],
        lastname = dialog[2],
        nationality = dialog[3],
        gender = dialog[4] == Lang:t('info.char_male') and 0 or 1,
        birthdate = dialog[5],
        cid = cid
    })

    if GetResourceState('qbx-spawn') == 'missing' then
        spawnDefault()
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    else
        if Config.Characters.StartingApartment then
            TriggerEvent('apartments:client:setupSpawnUI', newData)
        else
            TriggerEvent('qbx_core:client:spawnNoApartments')
        end
    end

    destroyPreviewCam()
    return true
end

local function chooseCharacter()
    randomLocation = Config.Characters.Locations[math.random(1, #Config.Characters.Locations)]

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
    setupPreviewCam()

    ---@type PlayerEntity[], integer
    local characters, amount = lib.callback.await('qbx_core:server:getCharacters')
    local options = {}
    for i = 1, amount do
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
                else
                    local success = createCharacter(i)
                    if success then return end

                    lib.showContext('qbx_core_multichar_characters')
                end
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
                            lib.callback.await('qbx_core:server:loadCharacter', false, character.citizenid)
                            if GetResourceState('qbx-apartments'):find('start') then
                                TriggerEvent('apartments:client:setupSpawnUI', { citizenid = character.citizenid })
                            else
                                TriggerEvent('qb-spawn:client:setupSpawns', { citizenid = character.citizenid })
                                TriggerEvent('qb-spawn:client:openUI', true)
                            end
                            destroyPreviewCam()
                        end
                    },
                    Config.Characters.EnableDeleteButton and {
                        title = Lang:t('info.delete_character'),
                        description = Lang:t('info.delete_character_description', { playerName = name }),
                        icon = 'trash',
                        onSelect = function()
                            TriggerServerEvent('qbx_core:server:deleteCharacter', character.citizenid)
                            destroyPreviewCam()
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

    SetTimecycleModifier('default')
    lib.showContext('qbx_core_multichar_characters')
end

RegisterNetEvent('qbx_core:client:spawnNoApartments', function() -- This event is only for no starting apartments
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(cache.ped, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, false, false, false, false)
    SetEntityHeading(cache.ped, Config.DefaultSpawn.w)
    Wait(500)
    destroyPreviewCam()
    SetEntityVisible(cache.ped, true, false)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
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
