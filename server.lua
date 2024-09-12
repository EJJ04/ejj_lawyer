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
    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerIdentifier = xPlayer.getIdentifier()

            MySQL.Async.execute('UPDATE users SET firstname = @firstName, lastname = @lastName WHERE identifier = @identifier',
                {
                    ['@firstName'] = firstName,
                    ['@lastName'] = lastName,
                    ['@identifier'] = playerIdentifier
                },
                function(rowsChanged)
                    if rowsChanged > 0 then
                        print('Updated player info successfully!')
                    else
                        print('Failed to update player info.')
                    end
                end
            )
        else
            print('Player not found')
        end

    elseif framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            local playerIdentifier = player.PlayerData.citizenid

            MySQL.Async.execute('UPDATE players SET firstname = @firstName, lastname = @lastName WHERE citizenid = @identifier',
                {
                    ['@firstName'] = firstName,
                    ['@lastName'] = lastName,
                    ['@identifier'] = playerIdentifier
                },
                function(rowsChanged)
                    if rowsChanged > 0 then
                        print('Updated player info successfully!')
                    else
                        print('Failed to update player info.')
                    end
                end
            )
        else
            print('Player not found')
        end
    end
end)