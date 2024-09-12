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

local advokat_menu_options = {
    {
        title = Config.Strings.titlechangename,
        onSelect = function()
            openDialog(Config.Strings.dialogtitle, {Config.Strings.dialoginput1, Config.Strings.dialoginput2, Config.Strings.dialoginput3}, updatePlayerInfo)
        end
    },
}

lib.registerContext({
    id = 'advokat_context_menu',
    title = Config.Strings.advokatmenu,
    options = advokat_menu_options
})

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        if IsControlJustReleased(0, 167) then 
            local playerData
            if framework == 'esx' then
                playerData = ESX.GetPlayerData()
            elseif framework == 'qbcore' then
                playerData = QBCore.Functions.GetPlayerData()
            end

            if playerData and playerData.job and playerData.job.name == 'advokat' then
                lib.showContext('advokat_context_menu')
            end
        end
    end
end)

function openDialog(title, inputs, callback)
    local input = lib.inputDialog(title, {
        {type = 'input', label = inputs[1], description = Config.Strings.dialogenter .. Config.Strings.dialoginput1, required = true},
        {type = 'input', label = inputs[2], description = Config.Strings.dialogenter .. Config.Strings.dialoginput2, required = true},
        {type = 'input', label = inputs[3], description = Config.Strings.dialogenter .. Config.Strings.dialoginput3, required = true},
        {type = 'date', label = Config.Strings.dialoginput4, icon = {'far', 'calendar'}, default = true, format = "DD/MM/YYYY"}
    })

    if input then
        callback(input)
    end
end

function updatePlayerInfo(input)
    local playerId = tonumber(input[1])
    local firstName = input[2]
    local lastName = input[3]

    if playerId then
        TriggerServerEvent('updatePlayerInfo', playerId, firstName, lastName)
    else
        lib.notify({
            title = Config.Strings.errormsg,
            type = 'error'
        })
    end
end