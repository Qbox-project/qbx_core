lib.cron.new(('*/%s * * * *'):format(QBCore.Config.UpdateInterval), function()
    for src, Player in pairs(QBCore.Players) do
        if Player then
            local newHunger = Player.PlayerData.metadata.hunger - QBCore.Config.Player.HungerRate
            local newThirst = Player.PlayerData.metadata.thirst - QBCore.Config.Player.ThirstRate
            if newHunger <= 0 then
                newHunger = 0
            end
            if newThirst <= 0 then
                newThirst = 0
            end
            Player.Functions.SetMetaData('thirst', newThirst)
            Player.Functions.SetMetaData('hunger', newHunger)
            TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
            Player.Functions.Save()
        end
    end
end)

lib.cron.new(('*/%s * * * *'):format(QBCore.Config.Money.PaycheckTimeout), function()
    for _, Player in pairs(QBCore.Players) do
        if Player then
            local payment = QBShared.Jobs[Player.PlayerData.job.name].grades[Player.PlayerData.job.grade.level].payment
            if not payment then payment = Player.PlayerData.job.payment end
            if Player.PlayerData.job and payment > 0 and (QBShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                if QBCore.Config.Money.PaycheckSociety then
                    local account = exports['qbx-management']:GetAccount(Player.PlayerData.job.name)
                    if account ~= 0 then -- Checks if player is employed by a society
                        if account < payment then -- Checks if company has enough money to pay society
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('error.company_too_poor'), 'error')
                        else
                            Player.Functions.AddMoney('bank', payment)
                            exports['qbx-management']:RemoveMoney(Player.PlayerData.job.name, payment)
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                        end
                    else
                        Player.Functions.AddMoney('bank', payment)
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                    end
                else
                    Player.Functions.AddMoney('bank', payment)
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Lang:t('info.received_paycheck', {value = payment}))
                end
            end
        end
    end
end)
