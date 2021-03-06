print "|||||||  ⚠ Menu personel pour Five-Dev ⚠   |||||||"
print "|||||||          Crée par Enos              |||||||"
print "|||||||        Rework fait par JoJo         |||||||"

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getMaximumGrade(jobname)
	local result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = @jobname ORDER BY `grade` DESC ;', {
		['@jobname'] = jobname
	})

	if result[1] ~= nil then
		return result[1].grade
	end

	return nil
end

function getAdminCommand(name)
	for i = 1, #Config.Admin, 1 do
		if Config.Admin[i].name == name then
			return i
		end
	end

	return false
end

function isAuthorized(index, group)
	for i = 1, #Config.Admin[index].groups, 1 do
		if Config.Admin[index].groups[i] == group then
			return true
		end
	end

	return false
end

ESX.RegisterServerCallback('KorioZ-PersonalMenu:Bill_getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local bills = {}

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i = 1, #result, 1 do
			table.insert(bills, {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('KorioZ-PersonalMenu:Admin_getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGroup = xPlayer.getGroup()

	if plyGroup ~= nil then 
		cb(plyGroup)
	else
		cb('user')
	end
end)

-- Weapon Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedS')
AddEventHandler('KorioZ-PersonalMenu:Weapon_addAmmoToPedS', function(plyId, value, quantity)
	if #(GetEntityCoords(source, false) - GetEntityCoords(plyId, false)) <= 3.0 then
		TriggerClientEvent('KorioZ-PersonalMenu:Weapon_addAmmoToPedC', plyId, value, quantity)
	end
end)

-- Admin Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Admin_BringS')
AddEventHandler('KorioZ-PersonalMenu:Admin_BringS', function(plyId, targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGroup = xPlayer.getGroup()

	if isAuthorized(getAdminCommand('bring'), plyGroup) or isAuthorized(getAdminCommand('goto'), plyGroup) then
		local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
		TriggerClientEvent('KorioZ-PersonalMenu:Admin_BringC', plyId, targetCoords)
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveCash')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveCash', function(money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGroup = xPlayer.getGroup()

	if isAuthorized(getAdminCommand('givemoney'), plyGroup) then
		xPlayer.addMoney(money)
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveBank')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveBank', function(money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGroup = xPlayer.getGroup()

	if isAuthorized(getAdminCommand('givebank'), plyGroup) then
		xPlayer.addAccountMoney('bank', money)
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$ en banque')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveDirtyMoney', function(money)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plyGroup = xPlayer.getGroup()

	if isAuthorized(getAdminCommand('givedirtymoney'), plyGroup) then
		xPlayer.addAccountMoney('black_money', money)
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'GIVE de ' .. money .. '$ sale')
	end
end)

-- Grade Menu --
RegisterServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_promouvoirplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == tonumber(getMaximumGrade(sourceXPlayer.job.name)) - 1) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation du ~r~Gouvernement~w~.')
	else
		if sourceXPlayer.job.grade_name == 'boss' and sourceXPlayer.job.name == targetXPlayer.job.name then
			targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) + 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~promu ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~promu par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_destituerplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous ne pouvez pas ~r~rétrograder~w~ davantage.')
	else
		if sourceXPlayer.job.grade_name == 'boss' and sourceXPlayer.job.name == targetXPlayer.job.name then
			targetXPlayer.setJob(targetXPlayer.job.name, tonumber(targetXPlayer.job.grade) - 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~rétrogradé ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~r~rétrogradé par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_recruterplayer', function(target, job, grade)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if sourceXPlayer.job.grade_name == 'boss' then
		targetXPlayer.setJob(job, grade)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~recruté ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~embauché par ' .. sourceXPlayer.name .. '~w~.')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_virerplayer')
AddEventHandler('KorioZ-PersonalMenu:Boss_virerplayer', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if sourceXPlayer.job.grade_name == 'boss' and sourceXPlayer.job.name == targetXPlayer.job.name then
		targetXPlayer.setJob('unemployed', 0)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~viré ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~viré par ' .. sourceXPlayer.name .. '~w~.')
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_promouvoirplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_promouvoirplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == tonumber(getMaximumGrade(sourceXPlayer.job2.name)) - 1) then
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation du ~r~Gouvernement~w~.')
	else
		if sourceXPlayer.job2.grade_name == 'boss' and sourceXPlayer.job2.name == targetXPlayer.job2.name then
			targetXPlayer.setJob2(targetXPlayer.job2.name, tonumber(targetXPlayer.job2.grade) + 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~promu ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~promu par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_destituerplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_destituerplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, 'Vous ne pouvez pas ~r~rétrograder~w~ davantage.')
	else
		if sourceXPlayer.job2.grade_name == 'boss' and sourceXPlayer.job2.name == targetXPlayer.job2.name then
			targetXPlayer.setJob2(targetXPlayer.job2.name, tonumber(targetXPlayer.job2.grade) - 1)

			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~rétrogradé ' .. targetXPlayer.name .. '~w~.')
			TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~r~rétrogradé par ' .. sourceXPlayer.name .. '~w~.')
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
		end
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_recruterplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_recruterplayer2', function(target, job2, grade2)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if sourceXPlayer.job2.grade_name == 'boss' then
		targetXPlayer.setJob2(job2, grade2)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~g~recruté ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~embauché par ' .. sourceXPlayer.name .. '~w~.')
	end
end)

RegisterServerEvent('KorioZ-PersonalMenu:Boss_virerplayer2')
AddEventHandler('KorioZ-PersonalMenu:Boss_virerplayer2', function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if sourceXPlayer.job2.grade_name == 'boss' and sourceXPlayer.job2.name == targetXPlayer.job2.name then
		targetXPlayer.setJob2('unemployed2', 0)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous avez ~r~viré ' .. targetXPlayer.name .. '~w~.')
		TriggerClientEvent('esx:showNotification', target, 'Vous avez été ~g~viré par ' .. sourceXPlayer.name .. '~w~.')
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)

function sendToDiscordTicket (name,message,color)
    local DiscordWebHook = "https://discord.com/api/webhooks/782282391519363102/LTJxJaW2ya0fUUHNs8Iipi3y8sCZXnbsAmXmOGc_x3VW_vz6b-nrOvhHcqF6-0eo_DTf"
    local color = 0x8fff8b
    local embeds = {
        {
          ["title"]=message,
          ["type"]="rich",
          ["color"] =color,
          ["footer"]=  {
          ["text"]= "Ticket IG | Society",
        },
      }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
    TriggerClientEvent('esx:showAdvancedNotification', source, 'Staff Society', '~q~Message Automatique', "Merci à vous d'avoir ouvert un ticket ! Vous aurez une réponse d'ici peut.", 'CHAR_ARGENTSALE', 9)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------


function sendToDiscordLogs (name,message,color)
    local DiscordWebHook = "https://discord.com/api/webhooks/782282391519363102/LTJxJaW2ya0fUUHNs8Iipi3y8sCZXnbsAmXmOGc_x3VW_vz6b-nrOvhHcqF6-0eo_DTf"
    local color = 0x8fff8b
    local embeds = {
        {
          ["title"]=message,
          ["type"]="rich",
          ["color"] =color,
          ["footer"]=  {
          ["text"]= "Logs IG | Society",
        },
      }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------


function sendToDiscordAvertissement (name,message,color)
    local DiscordWebHook = "https://discord.com/api/webhooks/782282391519363102/LTJxJaW2ya0fUUHNs8Iipi3y8sCZXnbsAmXmOGc_x3VW_vz6b-nrOvhHcqF6-0eo_DTf"
    local color = 0x8fff8b
    local embeds = {
        {
          ["title"]=message,
          ["type"]="rich",
          ["color"] =color,
          ["footer"]=  {
          ["text"]= "Avertissement IG | Society",
        },
      }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------


function sendToDiscordKickBan (name,message,color)
    local DiscordWebHook = "https://discord.com/api/webhooks/782282391519363102/LTJxJaW2ya0fUUHNs8Iipi3y8sCZXnbsAmXmOGc_x3VW_vz6b-nrOvhHcqF6-0eo_DTf"
    local color = 0x8fff8b
    local embeds = {
        {
          ["title"]=message,
          ["type"]="rich",
          ["color"] =color,
          ["footer"]=  {
          ["text"]= "Kick - Ban IG | Society",
        },
      }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------


function sendToDiscordGive (name,message,color)
    local DiscordWebHook = "https://discord.com/api/webhooks/782282391519363102/LTJxJaW2ya0fUUHNs8Iipi3y8sCZXnbsAmXmOGc_x3VW_vz6b-nrOvhHcqF6-0eo_DTf"
    local color = 0x8fff8b
    local embeds = {
        {
          ["title"]=message,
          ["type"]="rich",
          ["color"] =color,
          ["footer"]=  {
          ["text"]= "𝑀𝑜𝑚𝑜#6666 | SocietyLife",
        },
      }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------


RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveCash')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveCash', function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)   
    local name = GetPlayerName(source)

    sendToDiscordGive(name, "`" ..name.. "` viens de se give `" .. money .. "$` en `cash` !")
end)


---------------------------------------------------------------------------------------------------------------------------------------------------------------


RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveBank')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveBank', function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = GetPlayerName(source)

    sendToDiscordGive(name, "`" ..name.. "` viens de se give `" .. money .. "$` en `banque` !")
end)


---------------------------------------------------------------------------------------------------------------------------------------------------------------


RegisterServerEvent('KorioZ-PersonalMenu:Admin_giveDirtyMoney')
AddEventHandler('KorioZ-PersonalMenu:Admin_giveDirtyMoney', function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = GetPlayerName(source)

    sendToDiscordGive(name, "`" ..name.. "` viens de se give `" .. money .. "$` en `sale` !")

end)
