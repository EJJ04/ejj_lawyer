lib.locale()

local framework = nil
local ESX, QBCore = nil, nil

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if GetResourceState('es_extended') == 'started' then
            ESX = exports["es_extended"]:getSharedObject()
            framework = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            framework = 'qbcore'
        end
    end
end)

RegisterServerEvent('updatePlayerInfo')
AddEventHandler('updatePlayerInfo', function(playerId, firstName, lastName)
    local src = source

    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local PlayerMoney = xPlayer.getMoney()

            if PlayerMoney >= Config.Cost then
                local playerIdentifier = xPlayer.getIdentifier()

                MySQL.Async.execute('UPDATE users SET firstname = @firstName, lastname = @lastName WHERE identifier = @identifier', {
                    ['@firstName'] = firstName,
                    ['@lastName'] = lastName,
                    ['@identifier'] = playerIdentifier
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        xPlayer.removeMoney(Config.Cost)
                        TriggerClientEvent('ox_lib:notify', src, {
                            description = locale('namechangesuccess'),
                            type = 'success'
                        })
                    else
                        TriggerClientEvent('ox_lib:notify', src, {
                            description = locale('namechangefail'),
                            type = 'error'
                        })
                    end
                end)
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    description = locale('notenoughmoney'),
                    type = 'error'
                })
            end
        end

    elseif framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            local PlayerMoney = player.PlayerData.money['cash']

            if PlayerMoney >= Config.Cost then
                local playerIdentifier = player.PlayerData.citizenid

                MySQL.Async.execute('UPDATE players SET firstname = @firstName, lastname = @lastName WHERE citizenid = @identifier', {
                    ['@firstName'] = firstName,
                    ['@lastName'] = lastName,
                    ['@identifier'] = playerIdentifier
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        player.Functions.RemoveMoney('cash', Config.Cost)
                        TriggerClientEvent('ox_lib:notify', src, {
                            description = locale('namechangesuccess'),
                            type = 'success'
                        })
                    else
                        TriggerClientEvent('ox_lib:notify', src, {
                            description = locale('namechangefail'),
                            type = 'error'
                        })
                    end
                end)
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    description = locale('notenoughmoney'),
                    type = 'error'
                })
            end
        end
    end
end)