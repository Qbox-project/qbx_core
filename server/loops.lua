local config = require 'config.server'

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
        for src, player in pairs(QBX.Players) do
            removeHungerAndThirst(src, player)
        end
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
        return
    end
    local account = config.getSocietyAccount(job.name)
    if not account then -- Checks if player is employed by a society
        config.sendPaycheck(player, payment)
        return
    end
    if account < payment then -- Checks if company has enough money to pay society
        Notify(player.PlayerData.source, locale('error.company_too_poor'), 'error')
        return
    end
    config.removeSocietyMoney(job.name, payment)
    config.sendPaycheck(player, payment)
end

CreateThread(function()
    local interval = 60000 * config.money.paycheckTimeout
    while true do
        Wait(interval)
        for _, player in pairs(QBX.Players) do
            pay(player)
        end
    end
end)
