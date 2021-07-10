local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_holdup:tooFar')
AddEventHandler('esx_holdup:tooFar', function(currentStore)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Stores[currentStore].nameOfStore))
			TriggerClientEvent('esx_holdup:killBlip', xPlayers[i])
		end
	end

	if robbers[_source] then
		TriggerClientEvent('esx_holdup:tooFar', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', Stores[currentStore].nameOfStore))
	end
end)

RegisterServerEvent('esx_holdup:robberyStarted')
AddEventHandler('esx_holdup:robberyStarted', function(currentStore)
	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if Stores[currentStore] then
		local store = Stores[currentStore]

		if (os.time() - store.lastRobbed) < Config.TimerBeforeNewRob and store.lastRobbed ~= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('recently_robbed', Config.TimerBeforeNewRob - (os.time() - store.lastRobbed)))
			return
		end

		local cops = 0
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end

		if not rob then
			if cops >= Config.PoliceNumberRequired then
				rob = true

				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' then
						TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog', store.nameOfStore))
						TriggerClientEvent('esx_holdup:setBlip', xPlayers[i], Stores[currentStore].position)
					end
				end

				TriggerClientEvent('esx:showNotification', _source, _U('started_to_rob', store.nameOfStore))
				TriggerClientEvent('esx:showNotification', _source, _U('alarm_triggered'))
				
				TriggerClientEvent('esx_holdup:currentlyRobbing', _source, currentStore)
				TriggerClientEvent('esx_holdup:startTimer', _source)
				
				Stores[currentStore].lastRobbed = os.time()
				robbers[_source] = currentStore

				SetTimeout(store.secondsRemaining * 1000, function()
					if robbers[_source] then
						rob = false
						if xPlayer then
							TriggerClientEvent('esx_holdup:robberyComplete', _source, store.reward)

							if Config.GiveBlackMoney then
								xPlayer.addAccountMoney('black_money', store.reward)
							else
								xPlayer.addMoney(store.reward)
							end
							
							local xPlayers, xPlayer = ESX.GetPlayers(), nil
							for i=1, #xPlayers, 1 do
								xPlayer = ESX.GetPlayerFromId(xPlayers[i])

								if xPlayer.job.name == 'police' then
									TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', store.nameOfStore))
									TriggerClientEvent('esx_holdup:killBlip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
-----------------------------------------------
--- Overval succes
-----------------------------------------------
RegisterServerEvent('esx_holdup:succes')
AddEventHandler('esx_holdup:succes', function(award, naam)
	local webhook = "YOUR-WEBHOOK"
	local DATE = os.date(" %H:%M %d.%m.%y")
    local discordInfo = {
        ["color"] = "1708645",
        ["type"] = "rich",
        ["author"] = {                    
            name = "Oasis | Roleplay",
            icon_url = "https://media.discordapp.net/attachments/843606318878294056/861297876189446174/OASIS_LOGO.png?width=646&height=646"
        },
        ["title"] = "[Overval gelukt]",
        ["description"] = "**Steam :**  "..naam.." \n **Zwart geld :**  "..award.." \n **Tijd :**  "..DATE..""
    }
    PerformHttpRequest(""..webhook.."", function(err, text, headers) end, 'POST', json.encode({ username = 'Oasis | Logs', embeds = { discordInfo } }), { ['Content-Type'] = 'application/json' })
end)

-----------------------------------------------
--- Overval gestart
-----------------------------------------------
RegisterServerEvent('esx_holdup:gestart')
AddEventHandler('esx_holdup:gestart', function(naam, winkel)
	local webhook = "YOUR-WEBHOOK"
	local DATE = os.date(" %H:%M %d.%m.%y")
    local discordInfo = {
        ["color"] = "1708645",
        ["type"] = "rich",
        ["author"] = {                    
            name = "Oasis | Roleplay",
            icon_url = "https://media.discordapp.net/attachments/843606318878294056/861297876189446174/OASIS_LOGO.png?width=646&height=646"
        },
        ["title"] = "[Overval gestart]",
        ["description"] = "**Steam :**  "..naam.." \n **Locatie :**  "..winkel.." \n **Tijd :**  "..DATE..""
    }
    PerformHttpRequest(""..webhook.."", function(err, text, headers) end, 'POST', json.encode({ username = 'Oasis | Logs', embeds = { discordInfo } }), { ['Content-Type'] = 'application/json' })
end)
