local config = require 'config.server'

local function removeHungerAndThirst(src, player)
    local newHunger = player.PlayerData.metadata.hunger - config.player.hungerRate
    local newThirst = player.PlayerData.metadata.thirst - config.player.thirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    player.Functions.SetMetaData('thirst', newThirst)
    player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
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

local function sendPaycheck(player, payment)
    player.Functions.AddMoney('bank', payment)
    Notify(player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
end

local function pay(player)
    local job = player.PlayerData.job
    local payment = QBX.Shared.Jobs[job.name].grades[job.grade.level].payment or job.payment
    if payment <= 0 then return end
    if not QBX.Shared.Jobs[job.name].offDutyPay and not job.onduty then return end
    if not config.money.paycheckSociety then
        sendPaycheck(player, payment)
        return
    end
    local account = config.getSocietyAccount(job.name)
    if not account or account == 0 then -- Checks if player is employed by a society
        sendPaycheck(player, payment)
        return
    end
    if account < payment then -- Checks if company has enough money to pay society
        Notify(player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
        return
    end
    config.removeSocietyMoney(job.name, payment)
    sendPaycheck(player, payment)
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
