lib.cron.new(('*/%s * * * *'):format(Config.UpdateInterval), function()
    for src, player in pairs(QBX.Players) do
        if player then
            local newHunger = player.PlayerData.metadata.hunger - Config.Player.HungerRate
            local newThirst = player.PlayerData.metadata.thirst - Config.Player.ThirstRate
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
    end
end)

lib.cron.new(('*/%s * * * *'):format(Config.Money.PaycheckTimeout), function()
    for _, player in pairs(QBX.Players) do
        if player then
            local payment = QBX.Shared.Jobs[player.PlayerData.job.name].grades[player.PlayerData.job.grade.level].payment
            if not payment then payment = player.PlayerData.job.payment end
            if player.PlayerData.job and payment > 0 and (QBX.Shared.Jobs[player.PlayerData.job.name].offDutyPay or player.PlayerData.job.onduty) then
                if Config.Money.PaycheckSociety then
                    local account = exports['qbx-management']:GetAccount(player.PlayerData.job.name)
                    if account ~= 0 then -- Checks if player is employed by a society
                        if account < payment then -- Checks if company has enough money to pay society
                            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                        else
                            player.Functions.AddMoney('bank', payment)
                            exports['qbx-management']:RemoveMoney(player.PlayerData.job.name, payment)
                            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        player.Functions.AddMoney('bank', payment)
                        TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                else
                    player.Functions.AddMoney('bank', payment)
                    TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                end
            end
        end
    end
end)
