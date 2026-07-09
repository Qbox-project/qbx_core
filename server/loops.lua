local config = require 'config.server'

-- Players handled per frame before yielding. Spreads the per-interval burst (DB
-- saves, paychecks, client metadata syncs) across ticks so a full server doesn't
-- hitch every time an interval fires.
local PLAYERS_PER_BATCH = 20

---Runs handler for every online player, yielding a frame every PLAYERS_PER_BATCH.
---The source list is snapshotted first so a join/drop during a yield can't
---corrupt iteration, and each player is revalidated after the wait.
---@param handler fun(src: Source, player: Player)
local function forEachPlayerStaggered(handler)
    local sources = {}
    for src in pairs(QBX.Players) do
        sources[#sources + 1] = src
    end

    for i = 1, #sources do
        local player = QBX.Players[sources[i]]
        if player then
            handler(sources[i], player)
        end
        if i % PLAYERS_PER_BATCH == 0 then
            Wait(0)
        end
    end
end

local function removeHungerAndThirst(src, player)
    local playerState = Player(src).state
    if not playerState.isLoggedIn then return end
    local newHunger = playerState.hunger - config.player.hungerRate
    local newThirst = playerState.thirst - config.player.thirstRate

    player.Functions.SetMetaData('thirst', newThirst)
    player.Functions.SetMetaData('hunger', newHunger)

    player.Functions.Save()
end

CreateThread(function()
    local interval = 60000 * config.updateInterval
    while true do
        Wait(interval)
        forEachPlayerStaggered(removeHungerAndThirst)
    end
end)

local function pay(player)
    local job = player.PlayerData.job
    local jobData = GetJob(job.name)
    local grade = jobData and jobData.grades[job.grade.level]
    if not grade then
        lib.print.error(('cannot pay %s. job "%s" does not have grade %s'):format(player.PlayerData.citizenid, job.name, job.grade.level))
        return
    end
    local payment = grade.payment or job.payment
    if payment <= 0 then return end
    if not jobData.offDutyPay and not job.onduty then return end
    if not config.money.paycheckSociety then
        config.sendPaycheck(player, payment)
        TriggerEvent('QBCore:Server:PayCheck', player.PlayerData.source, payment)
        return
    end
    local account = config.getSocietyAccount(job.name)
    if not account then -- Checks if player is employed by a society
        config.sendPaycheck(player, payment)
        TriggerEvent('QBCore:Server:PayCheck', player.PlayerData.source, payment)
        return
    end
    if account < payment then -- Checks if company has enough money to pay society
        Notify(player.PlayerData.source, locale('error.company_too_poor'), 'error')
        return
    end
    config.removeSocietyMoney(job.name, payment)
    config.sendPaycheck(player, payment)
    TriggerEvent('QBCore:Server:PayCheck', player.PlayerData.source, payment)
end

CreateThread(function()
    local interval = 60000 * config.money.paycheckTimeout
    while true do
        Wait(interval)
        forEachPlayerStaggered(function(_, player)
            pay(player)
        end)
    end
end)
