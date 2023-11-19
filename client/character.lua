local config = require 'config.client'
local defaultSpawn = require 'config.shared'.defaultSpawn

if config.characters.useExternalCharacters then return end

local previewCam = nil
local randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]

local randomPedModels = {
    `a_m_o_soucent_02`,
    `mp_g_m_pros_01`,
    `a_m_m_prolhost_01`,
    `a_f_m_prolhost_01`,
    `a_f_y_smartcaspat_01`,
    `a_f_y_runner_01`,
    `a_f_y_vinewood_04`,
    `a_f_o_soucent_02`,
    `a_m_y_cyclist_01`,
    `a_m_m_hillbilly_02`,
}

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

---@param citizenId? string
local function previewPed(citizenId)
    if not citizenId then
        local model = randomPedModels[math.random(1, #randomPedModels)]
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        return
    end

    local clothing, model = lib.callback.await('qbx_core:server:getPreviewPedData', false, citizenId)
    if model and clothing then
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        pcall(function() exports['illenium-appearance']:setPedAppearance(PlayerPedId(), json.decode(clothing)) end)
    else
        model = randomPedModels[math.random(1, #randomPedModels)]
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
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
    if config.characters.profanityWords[str:lower()] then return false end

    local split = {string.strsplit(' ', str)}
    if #split > 5 then return false end

    for i = 1, #split do
        local word = split[i]
        if config.characters.profanityWords[word:lower()] then return false end
    end

    return true
end

-- @param str string
-- @return string?
local function capString(str)
    return str:gsub("(%w)([%w']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

local function spawnDefault() -- We use a callback to make the server wait on this to be done
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = defaultSpawn.x,
        y = defaultSpawn.y,
        z = defaultSpawn.z,
        heading = defaultSpawn.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end

local function spawnLastLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = QBX.PlayerData.position.x,
        y = QBX.PlayerData.position.y,
        z = QBX.PlayerData.position.z,
        heading = QBX.PlayerData.position.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
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
        firstname = capString(dialog[1]),
        lastname = capString(dialog[2]),
        nationality = capString(dialog[3]),
        gender = dialog[4] == Lang:t('info.char_male') and 0 or 1,
        birthdate = dialog[5],
        cid = cid
    })

    if GetResourceState('qbx_spawn') == 'missing' then
        spawnDefault()
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    else
        if config.characters.startingApartment then
            TriggerEvent('apartments:client:setupSpawnUI', newData)
        else
            TriggerEvent('qbx_core:client:spawnNoApartments')
        end
    end

    destroyPreviewCam()
    return true
end

local function chooseCharacter()
    randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

    FreezeEntityPosition(cache.ped, true)
    Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)
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
                Name = name,
                Gender = character.charinfo.gender == 0 and Lang:t('info.char_male') or Lang:t('info.char_female'),
                Birthdate = character.charinfo.birthdate,
                Nationality = character.charinfo.nationality,
                ['Account Number'] = character.charinfo.account,
                Bank = CommaValue(character.money.bank),
                Cash = CommaValue(character.money.cash),
                Job = character.job.label,
                ['Job Grade'] = character.job.grade.name,
                Gang = character.gang.label,
                ['Gang Grade'] = character.gang.grade.name,
                ['Phone Number'] = character.charinfo.phone
            } or nil,
            icon = 'user',
            onSelect = function()
                if character then
                    lib.showContext('qbx_core_multichar_character_'..i)
                    previewPed(character.citizenid)
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
                            if GetResourceState('qbx_apartments'):find('start') then
                                TriggerEvent('apartments:client:setupSpawnUI', { citizenid = character.citizenid })
                            elseif GetResourceState('qbx_spawn'):find('start') then
                                TriggerEvent('qb-spawn:client:setupSpawns', { citizenid = character.citizenid })
                                TriggerEvent('qb-spawn:client:openUI', true)
                            else
                                spawnLastLocation()
                            end
                            destroyPreviewCam()
                        end
                    },
                    config.characters.enableDeleteButton and {
                        title = Lang:t('info.delete_character'),
                        description = Lang:t('info.delete_character_description', { playerName = name }),
                        icon = 'trash',
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = Lang:t('info.delete_character'),
                                content = Lang:t('info.confirm_delete'),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('qbx_core:server:deleteCharacter', character.citizenid)
                                destroyPreviewCam()
                                chooseCharacter()
                            else
                                lib.showContext('qbx_core_multichar_character_'..i)
                            end
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
    SetEntityCoords(cache.ped, defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, false, false, false, false)
    SetEntityHeading(cache.ped, defaultSpawn.w)
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
    local model = randomPedModels[math.random(1, #randomPedModels)]
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            lib.requestModel(model, config.loadingModelsTimeout)
            SetPlayerModel(cache.playerId, model)
            chooseCharacter()
            break
        end
    end
end)
