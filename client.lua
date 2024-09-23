lib.locale()

local framework = nil
local ESX, QBCore = nil, nil
local ped = nil

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

function CreatePedEJJLawyer()
    RequestModel(Config.Ped)
    while not HasModelLoaded(Config.Ped) do
        Wait(1)
    end

    ped = CreatePed(4, Config.Ped, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 1, Config.PedHeading, false, true)
    
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end

if Config.UsePed then
    CreatePedEJJLawyer()
end

exports.ox_target:addGlobalPed({
    icon = "fa-solid fa-comment",
    label = locale('police_tag'), 
    canInteract = function(entity, distance, coords, name, boneId)
        return entity == ped
    end,
    onSelect = function()
        local playerId = GetPlayerServerId(PlayerId()) 
        openDialog2(locale('dialogtitle'), {locale('dialoginput1'), locale('dialoginput2'), locale('dialoginput3')}, playerId, function(input)
            updatePlayerInfo(input)
        end)
    end
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

            if playerData and playerData.job and playerData.job.name == Config.Job and not Config.UsePed then
                openDialog(locale('dialogtitle'), {locale('dialoginput1'), locale('dialoginput2'), locale('dialoginput3')}, updatePlayerInfo)
            end
        end
    end
end)

function openDialog(title, inputs, callback)
    local input = lib.inputDialog(title, {
        {type = 'input', label = inputs[1], description = locale('dialogenter') .. inputs[1], required = true},
        {type = 'input', label = inputs[2], description = locale('dialogenter') .. inputs[2], required = true},
        {type = 'input', label = inputs[3], description = locale('dialogenter') .. inputs[3], required = true},
        {type = 'date', label = inputs[4], icon = {'far', 'calendar'}, default = true, format = "DD/MM/YYYY"}
    })

    if input then
        callback(input)
    end
end

function openDialog2(title, inputs, playerId, callback)
    local input = lib.inputDialog(title, {
        {type = 'input', label = inputs[1], description = locale('dialogenter') .. inputs[1], required = true, default = tostring(playerId), disabled = true}, 
        {type = 'input', label = inputs[2], description = locale('dialogenter') .. inputs[2], required = true},
        {type = 'input', label = inputs[3], description = locale('dialogenter') .. inputs[3], required = true},
        {type = 'date', label = inputs[4], icon = {'far', 'calendar'}, default = true, format = "DD/MM/YYYY"}
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
            title = locale('errormsg'),
            type = 'error'
        })
    end
end

local CreateBlips = function()
	for _, blip in pairs(Config.LawyerBlip) do
		local lawyerblip = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
		SetBlipSprite(lawyerblip, blip.sprite)
		SetBlipColour(lawyerblip, blip.color)
		SetBlipScale(lawyerblip, blip.scale)
		SetBlipAsShortRange(lawyerblip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(blip.title)
		EndTextCommandSetBlipName(lawyerblip)
	end
end

if Config.EnableBlip then
    CreateBlips()
end