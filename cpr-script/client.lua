AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

AddEventHandler('baseevents:onPlayerDied', function(source, reason)
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local streetName = GetStreetNameAtCoord(x, y, z)
	streetName = GetStreetNameFromHashKey(streetName)
	if streetName == nil or streetName == "" then
		streetName = "Unknown"
	end
    TriggerServerEvent('reviveEMSCall', PlayerPedId(), "^3" .. streetName, x, y)
	TriggerServerEvent('createEMSBlipServer', x, y, z)
	Citizen.Wait(360000) -- 6 Minutes
	if IsPedDeadOrDying(PlayerPedId(), 1) then
	    TriggerEvent('reviveClient')
	    Citizen.Wait(50)
	    TriggerEvent('HOSPITAL:hospitalize', 1, 0)
		TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You have been dead for 6 minutes and therefore put in the hospital.')
	end
end)

AddEventHandler('baseevents:onPlayerKilled', function(source, reason)
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local streetName = GetStreetNameAtCoord(x, y, z)
	streetName = GetStreetNameFromHashKey(streetName)
	if streetName == nil or streetName == "" then
		streetName = "Unknown"
	end
	TriggerServerEvent('reviveEMSCall', PlayerPedId(), "^3" .. streetName, x, y)
	TriggerServerEvent('createEMSBlipServer', x, y, z)
	Citizen.Wait(360000) -- 6 Minutes
	if IsPedDeadOrDying(PlayerPedId(), 1) then
	    TriggerEvent('reviveClient')
	    Citizen.Wait(50)
	    TriggerEvent('HOSPITAL:hospitalize', 1, 0)
		TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You have been dead for 6 minutes and therefore put in the hospital.')
	end
end)


RegisterCommand('reviveself', function()
	if GetNumberOfPlayers() < 2 then
		TriggerEvent('reviveClient')
	else
		TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You must be the only player on the server to revive yourself.')
	end
end)

--
local tries = 0
RegisterCommand('cpr', function()
	closest, distance = GetClosestPlayer()
	if closest ~= nil and DoesEntityExist(GetPlayerPed(closest)) then
		if distance -1 and distance < 3 then
			if IsPedDeadOrDying(GetPlayerPed(closest)) then
				if tries < 10 then 
					local closestID = GetPlayerServerId(closest)
					local chance = math.random(0, 100)
					loadAnimDict("mini@cpr@char_a@cpr_str")
					loadAnimDict("mini@cpr@char_a@cpr_def")

					TaskPlayAnim(PlayerPedId(), "mini@cpr@char_a@cpr_def", "cpr_intro", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
					Citizen.Wait(2000)
					TaskPlayAnim(PlayerPedId(), "mini@cpr@char_a@cpr_str", "cpr_pumpchest", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
					Citizen.Wait(7000)
					TaskPlayAnim(PlayerPedId(), "mini@cpr@char_a@cpr_def", "cpr_success", 8.0, 1.0, -1, 2, 0, 0, 0, 0)

					tries = tries + 1
					if chance <= 25 then
						TriggerServerEvent('reviveServer', closestID)
						TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You successfully revived ^2' .. GetPlayerName(closest) .. '^0 (' .. tries ..'/10 Used)')	
					else
						TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You failed to revived ^3' .. GetPlayerName(closest) .. '^0 try again! (' .. tries ..'/10 Used)')
					end
				else
					TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You are too weak to do anymore CPR. You must wait 2 minutes from running this command.')
					Citizen.Wait(2 * 60000)
					tries = 0
					TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 Your energy has reset. You are now able to do CPR 10 more times.')
				end
			else
				TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 ^3' .. GetPlayerName(closest) .. '^0 doesn\'t need CPR!')
			end
	    else
    		TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 You\'re not near a player!')
		end
	end
end)

-- This is a flaw by design to catch roleplay cheaters. You can patch it if you wish.
RegisterCommand('adminrevive', function()
	TriggerEvent('reviveClient')
	TriggerServerEvent('messageveryonexd')
end)

RegisterCommand('adminreset', function()
	tries = 0
end)

RegisterCommand('revive', function()
	TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 The ^3/revive ^0 command has been removed use ^2/cpr^0 near the downed person')
end)

RegisterNetEvent('reviveClient')
AddEventHandler('reviveClient', function()
	local plyCoords = GetEntityCoords(PlayerPedId(), true)
	ResurrectPed(PlayerPedId())
	SetEntityHealth(PlayerPedId(), 200)
	ClearPedTasksImmediately(PlayerPedId())
	SetEntityCoords(PlayerPedId(), plyCoords.x, plyCoords.y, plyCoords.z + 1.0, 0, 0, 0, 0)
end)

RegisterNetEvent('createEMSBlip')
AddEventHandler('createEMSBlip', function(x, y, z, name)
	local blip = AddBlipForCoord(x, y, z)
	SetBlipSprite(blip, 61)
	SetBlipAsShortRange(blip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("~r~EMS Call: ~s~" .. name)
	EndTextCommandSetBlipName(blip)
	SetBlipColour(blip, 49)
	Citizen.Wait(3 * 60000) -- 3 Minutes
	SetBlipAsMissionCreatorBlip(blip, false)
	RemoveBlip(blip)
	blip = nil
end)

RegisterNetEvent('paramedicEMSPageClient')
AddEventHandler('paramedicEMSPageClient', function(x, y)
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	local vehicleClass = GetVehicleClass(vehicle)
	
	if vehicleClass == 18 then 
		SetNewWaypoint(x, y)
		PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
		Citizen.Wait(250)
		PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
		Citizen.Wait(250)
		PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
		TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 A new EMS call has been issued!')
	end
end)

local respawnToggle = false
RegisterCommand('respawn', function()
    if not respawnToggle then
    	respawnToggle = true
    	TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 Only run the /respawn command if you were RDM\'ed, out of AOP, or you died randomly. Abuse of this command will get you banned.')
    	TriggerEvent('chatMessage', '', {255, 255, 255}, '^8[CADOJRP]^0 Run the ^2/respawn^0 command again to confirm that you want to respawn.')
	else
    	playerDead = false
    	respawnToggle = false
    	TriggerEvent('reviveClient')
	    Citizen.Wait(50)
	    TriggerEvent('HOSPITAL:hospitalize', 1, 0)
    end
end)

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
			table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if target ~= ply then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end