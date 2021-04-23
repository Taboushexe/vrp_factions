
local cfg = module("cfg/factions")
local factions = cfg.factions

factionMembers = {}

MySQL.createCommand("vRP/get_faction_members","SELECT * FROM vrp_users WHERE faction = @faction")
MySQL.createCommand("vRP/get_user_faction","SELECT * FROM vrp_users WHERE id = @user_id")
MySQL.createCommand("vRP/set_user_faction","UPDATE vrp_users SET faction = @group, factionRank = @rank WHERE id = @user_id")
MySQL.createCommand("vRP/set_faction_leader","UPDATE vrp_users SET isFactionLeader = @leader WHERE id = @user_id")
MySQL.createCommand("vRP/set_faction_rank","UPDATE vrp_users SET factionRank = @rank WHERE id = @user_id")

MySQL.createCommand("vRP/get_user","SELECT * FROM vrp_users WHERE id = @user_id")

function getFactionMembers()
	for i, v in pairs(factions) do
		MySQL.query("vRP/get_faction_members", {faction = tostring(i)}, function(rows, affected)
			factionMembers[tostring(i)] = rows
			
		end)
	end
end

AddEventHandler("onResourceStart", function(rs)
	if(rs == "sessionmanager")then
		Citizen.Wait(5000)
		getFactionMembers()
	end
end)

function vRP.getFactions()
	factionsList = {}
	for i, v in pairs(factions) do
		factionsList[i] = v
	end
	return factionsList
end

function vRP.getUserFaction(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		return theFaction
	end
end

function vRP.getFactionRanks(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		return factionRanks
	end
end


function vRP.getFactionCoords(faction)
	local ngroup = factions[faction]
	if ngroup then
		local coords = ngroup.coords
		return coords
	end
end


function vRP.getFactionBlip(faction)
	local ngroup = factions[faction]
	if ngroup then
		local fBlip = ngroup.fBlip
		return fBlip
	end
end


function vRP.getFactionRankSalary(faction, rank)
	local ngroup = factions[faction]
	if ngroup then
		local factionRanks = ngroup.fRanks
		for i, v in pairs(factionRanks) do
			if (v.rank == rank)then
				return v.salary - 1
			end
		end
		return 0
	end
end

function vRP.getFactionSlots(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionSlots = ngroup.fSlots
		return factionSlots
	end
end

function vRP.getFactionType(faction)
	local ngroup = factions[faction]
	if ngroup then
		local factionType = ngroup.fType
		return tostring(factionType)
	end
end

function vRP.hasUserFaction(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		if(theFaction == "user")then
			return false
		else
			return true
		end
	end
end

function vRP.isUserInFaction(user_id,group)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		if(theFaction == group)then
			return true
		else
			return false
		end
	end
end

function vRP.setFactionLeader(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		tmp.fLeader = 1
		MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 1})
	end
end

function vRP.setFactionNonLeader(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		tmp.fLeader = 0
		MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
	end
end

function vRP.isFactionLeader(user_id,group)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theFaction = tmp.fName
		isLeader = tmp.fLeader
		if(theFaction == group) and (isLeader == 1)then
			return true
		else
			return false
		end
	end
end

function vRP.getFactionRank(user_id)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		theRank = tmp.fRank
		return theRank
	end
end

function vRP.factionRankUp(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserDataTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == #ranks)then
				return false
			else
				local theRank = tostring(ranks[i+1].rank)
				tmp.fRank = theRank
				MySQL.execute("vRP/set_faction_rank", {user_id = user_id, rank = theRank})
				return true
			end
		end
	end
end

function vRP.factionRankDown(user_id)
	local theFaction = vRP.getUserFaction(user_id)
	local actualRank = vRP.getFactionRank(user_id)
	local ranks = factions[theFaction].fRanks
	local tmp = vRP.getUserDataTable(user_id)
	local rankName = tmp.fRank
	for i, v in pairs(ranks) do
		rankTitle = v.rank
		if(rankTitle == rankName)then
			if(i == 1)then
				return false
			else
				local theRank = tostring(ranks[i-1].rank)
				tmp.fRank = theRank
				MySQL.execute("vRP/set_faction_rank", {user_id = user_id, rank = tostring(ranks[i-1])})
				return true
			end
		end
	end
end

function vRP.addUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local ngroup = factions[theGroup]
		if ngroup then
			local factionRank = ngroup.fRanks[1].rank
			local tmp = vRP.getUserDataTable(user_id)
			if tmp then
				tmp.fName = theGroup
				tmp.fRank = factionRank
				tmp.fLeader = 0
				MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = theGroup, rank = factionRank})
				MySQL.query("vRP/get_user", {user_id = user_id}, function(rows, affected)
					thePlayer = rows[1]
					table.insert(factionMembers[theGroup], thePlayer) 
				end)
			end
		end
	end
end

function vRP.getUsersByFaction(group)
	return factionMembers[group] or {}
end

function vRP.getOnlineUsersByFaction(group)
	local oUsers = {}

	for k,v in pairs(vRP.rusers) do
		if vRP.isUserInFaction(tonumber(k), group) then table.insert(oUsers, tonumber(k)) end
	end

	return oUsers
end

function vRP.removeUserFaction(user_id,theGroup)
	local player = vRP.getUserSource(user_id)
	if (player) then
		local tmp = vRP.getUserDataTable(user_id)
		if tmp then
			for i, v in pairs(factionMembers[theGroup])do
				if (v.id == user_id) then
					vRP.tryGetInventoryItem(user_id,"fac_doc|"..theGroup,1,false)
					tmp.fName = "user"
					tmp.fRank = 'none'
					tmp.fLeader = 0
					MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = "user", rank = "none"})
					MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
					table.remove(factionMembers[theGroup], i)
				end
			end
		end
	else
		for i, v in pairs(factionMembers[theGroup])do
			if (v.id == user_id) then
				table.remove(factionMembers[theGroup], i)
				MySQL.execute("vRP/set_user_faction", {user_id = user_id, group = "user", rank = "none"})
				MySQL.execute("vRP/set_faction_leader", {user_id = user_id, leader = 0})
			end
		end
	end
end

-- FACTION MENU
local function ch_leaveGroup(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local Rank = vRP.getFactionRank(user_id)
	if user_id ~= nil then
		if(vRP.hasUserFaction(user_id))then
			Wait(100)
			vRPclient.notify(player,{"~w~Ai iesit din ~r~"..theFaction.."!"})
			vRP.removeUserGroup(user_id,theFaction)
			Wait(150)
			vRP.removeUserGroup(user_id,Rank)
			vRP.removeUserFaction(user_id,theFaction)
		end
		vRP.openMainMenu(player)
	end
end

local function ch_inviteFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local members = vRP.getUsersByFaction(theFaction)
	local fSlots = factions[theFaction].fSlots
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(#members) < tonumber(fSlots))then
				local target = vRP.getUserSource(id)
				if(target)then
					local name = GetPlayerName(target)
					if(vRP.hasUserFaction(id))then
						vRPclient.notify(player,{"~r~"..name.." este deja intr-o factiune!"})
						return
					else
						vRPclient.notify(player,{"~w~L-ai adaugat pe ~g~"..name.." ~w~in ~g~"..theFaction.."!"})
						vRPclient.notify(target,{"~w~Ai fost adaugat in ~g~"..theFaction.."!"})
						Citizen.Wait(500)
						vRP.addUserFaction(id,theFaction)
						local Rank = vRP.getFactionRank(id)
						Wait(150)
						vRP.addUserGroup(id,theFaction)
						Wait(150)
						vRP.addUserGroup(id,Rank)
					end
				else
					vRPclient.notify(player,{"~r~Nu sa gasit nici un jucator online cu ID-ul "..id.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Maximul de jucatori in factiune a fost atins! Sloturi: "..fSlots})
			end
		end)
	end
end

local function ch_removeFaction(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id))then
				local target = vRP.getUserSource(id)
				if(target)then
				--	if(vRP.isUserInFaction(id,theFaction))then
						local name = GetPlayerName(target)
						local Rank = vRP.getFactionRank(id)
						vRPclient.notify(player,{"~w~L-ai scos pe ~g~"..name.." ~w~ din ~g~"..theFaction.."!"})
						vRPclient.notify(target,{"~w~Ai fost dat afara ~g~"..theFaction.."!"})
						vRP.removeUserGroup(id,theFaction)
						Wait(150)
						vRP.removeUserGroup(id,Rank)
						vRP.removeUserFaction(id,theFaction)
					--[[else
						vRPclient.notify(player,{"~w~Jucatorul ~g~"..name.." ~w~nu este membru in factiunea ~g~"..theFaction.."!"})
					end]]
				else
					vRPclient.notify(player,{"~w~L-ai scos pe ID ~g~"..id.." ~w~din ~g~"..theFaction.."!"})
					vRP.removeUserFaction(id,theFaction)
				end
			end
		end)
	end
end

local function ch_promoteLeader(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			local target = vRP.getUserSource(id)
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					if(vRP.isFactionLeader(id,theFaction))then
						vRPclient.notify(player,{"~w~L-ai retrogradat pe ~g~"..name.." ~w~la ~g~Membru!"})
						vRPclient.notify(target,{"~w~Ai fost retrogradat la ~g~Membru ~w~in factiunea ~g~"..theFaction.."!"})
						vRP.setFactionNonLeader(id)
					else
						vRPclient.notify(player,{"~w~L-ai promovat pe ~g~"..name.." ~w~la ~g~Lider!"})
						vRPclient.notify(target,{"~w~Ai fost promovat la ~g~Lider ~w~in factiunea ~g~"..theFaction.."!"})
						vRP.setFactionLeader(id)
					end
				else
					vRPclient.notify(player,{"~w~Jucatorul ~g~"..name.." ~w~nu este membru in factiunea ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Nu sa gasit nici un jucator online cu ID-ul "..id.."!"})
			end
		end)
	end
end

local function ch_promoteMember(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local target = vRP.getUserSource(id)
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					local oldRank = vRP.getFactionRank(id)
					if(vRP.factionRankUp(id))then
						SetTimeout(1000, function()
							local newRank = vRP.getFactionRank(id)
							vRPclient.notify(player,{"~w~L-ai promovat pe ~g~"..name.." ~w~de la ~r~"..oldRank.." ~w~la ~g~"..newRank.."!"})
							vRPclient.notify(target,{"~w~Ai fost promovat de la ~r~"..oldRank.." ~w~la~g~ "..newRank.." ~w~in factiunea ~g~"..theFaction.."!"})
							vRP.removeUserGroup(id,oldRank)
							vRP.addUserGroup(id,newRank)
						end)
					else
						vRPclient.notify(player,{"~g~"..name.." ~w~este deja cel mai mare rank!"})
					end
				else
					vRPclient.notify(player,{"~w~Jucator-ul ~g~"..name.." ~w~nu este membru din:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Jucator-ul cu id : "..id.." nu este online!"})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid!"})
			end
		end)
	end
end

local function ch_demoteMember(player,choice)
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	if user_id ~= nil and vRP.isFactionLeader(user_id,theFaction) then
		vRP.prompt(player,"User ID: ","",function(player,id)
			id = parseInt(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local target = vRP.getUserSource(id)
			if(target)then
				local name = GetPlayerName(target)
				if(vRP.isUserInFaction(id,theFaction))then
					local oldRank = vRP.getFactionRank(id)
					if(vRP.factionRankDown(id))then
						SetTimeout(1000, function()
							local newRank = vRP.getFactionRank(id)
							vRPclient.notify(player,{"~w~L-ai retrogradat pe ~g~"..name.." ~w~de la ~r~"..oldRank.." ~w~la ~g~"..newRank.."!"})
							vRPclient.notify(target,{"~w~Ai fost retrogradat de la ~r~"..oldRank.." ~w~la~g~"..newRank.." ~w~in factiunea ~g~"..theFaction.."!"})
							vRP.removeUserGroup(id,oldRank)
							vRP.addUserGroup(id,newRank)
						end)
					else
						vRPclient.notify(player,{"~g~"..name.." ~w~este deja cel mai mic rank!"})
					end
				else
					vRPclient.notify(player,{"~w~Jucator-ul ~g~"..name.." ~w~nu este membru din:  ~g~"..theFaction.."!"})
				end
			else
				vRPclient.notify(player,{"~r~Jucator-ul cu id : "..id.." nu este online!"})
			end
		else
			vRPclient.notify(player,{"~r~ID-ul nu este valid!"})
			end
		end)
	end
end

local function ch_memberList(player,choice)
	return true
end

local function ch_membersList(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Lista Membrii", {player = player}, function(menu2)
			menu2.name = "Lista Membrii"
			menu2.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu2.onclose = function(player) vRP.openMainMenu(player) end
			local user_id = vRP.getUserId(player)
			local theFaction = vRP.getUserFaction(user_id)
			local members = factionMembers[theFaction]
			for i, v in pairs(members) do
				if(v.isFactionLeader == 1)then
					isMLeader = "Lider"
				else
					isMLeader = "Membru"
				end
				local userID = v.id
				local rank = v.factionRank
				menu2[v.username] = {nil, "ID: <font color='yellow'>"..userID.."</font><br/>Rank: <font color='red'>"..rank.."</font><br/>Statut: <font color='green'>"..isMLeader.."</font>"}
			end
			vRP.openMenu(player,menu2)
		end)
	end)
end

local function ch_laveFaction(player,choice)
	vRP.openMainMenu(player)
	player = player
	SetTimeout(400, function()
		vRP.buildMenu("Esti sigur?", {player = player}, function(menu1)
			menu1.name = "Esti sigur?"
			menu1.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu1.onclose = function(player) vRP.openMainMenu(player) end
			menu1["Da"] = {ch_leaveGroup, "Paraseste factiunea"}
			menu1["Nu"] = {function(player) vRP.openMainMenu(player) end}
			vRP.openMenu(player,menu1)
		end)
	end)
end

local function ch_dummySalary(player,choice)
	return false
end

local function ch_ranksAndSalary(player,choice)
	vRP.openMainMenu(player)
	player = player
	local user_id = vRP.getUserId(player)
	local theFaction = vRP.getUserFaction(user_id)
	local ranks = vRP.getFactionRanks(theFaction)
	SetTimeout(400, function()
		vRP.buildMenu("Rankuri & Salarii", {player = player}, function(rsMenu)
			rsMenu.name = "Rankuri & Salarii"
			rsMenu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			rsMenu.onclose = function(player) vRP.openMainMenu(player) end
			for i, v in pairs(ranks) do
				facRank = v.rank
				local salary = vRP.getFactionRankSalary(theFaction, facRank)
				rsMenu["["..i.."] "..facRank] = {ch_dummySalary, "Salariu: <font color='green'>$"..salary.."</font>"}
			end
			vRP.openMenu(player,rsMenu)
		end)
	end)
end

vRP.registerMenuBuilder("main", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		local tmp = vRP.getUserDataTable(user_id)
		if tmp then
			if(vRP.hasUserFaction(user_id))then
				local theFaction = vRP.getUserFaction(user_id)
				local rank = vRP.getFactionRank(user_id)
				local leader = vRP.isFactionLeader(user_id,theFaction)
				local members = vRP.getUsersByFaction(theFaction)
				local fType = vRP.getFactionType(theFaction)
				local fSlots = vRP.getFactionSlots(theFaction)
				local salary = vRP.getFactionRankSalary(theFaction, rank)
				if(leader)then
					isLeader = "Lider"
				else
					isLeader = "Membru"
				end
				if(salary > 0)then
					if(#members == fSlots)then
						infoText = "Nume: <font color='red'>"..theFaction.."</font><br/>Membrii: <font color='red'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/>Tip: <font color='green'>"..fType.."</font><br/>Rank: <font color='green'>"..rank.."</font><br/>Salariu: <font color='yellow'>$"..salary.."</font><br/>Statut: <font color='green'>"..isLeader.."</font>"
					else
						infoText = "Nume: <font color='red'>"..theFaction.."</font><br/>Membrii: <font color='green'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/>Tip: <font color='green'>"..fType.."</font><br/>Rank: <font color='green'>"..rank.."</font><br/>Salariu: <font color='yellow'>$"..salary.."</font><br/>Statut: <font color='green'>"..isLeader.."</font>"
					end
				else
					if(#members == fSlots)then
						infoText = "Nume: <font color='red'>"..theFaction.."</font><br/>Membrii: <font color='red'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/>Tip: <font color='green'>"..fType.."</font><br/>Rank: <font color='green'>"..rank.."</font><br/>Statut: <font color='green'>"..isLeader.."</font>"
					else
						infoText = "Nume: <font color='red'>"..theFaction.."</font><br/>Membrii: <font color='green'>"..#members.."</font>/<font color='red'>"..fSlots.."</font><br/>Tip: <font color='green'>"..fType.."</font><br/>Rank: <font color='green'>"..rank.."</font><br/>Statut: <font color='green'>"..isLeader.."</font>"	
					end
				end
				choices["Meniu Factiune"] = {function(player,choice)
					vRP.buildMenu(theFaction, {player = player}, function(menu)
						menu.name = theFaction
						menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
						menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu
						if(leader)then
							menu["Invita Membru"] = {ch_inviteFaction, "Invita membru in factiune"}
							menu["Exclude Membru"] = {ch_removeFaction, "Exclude membru din factiune"}
							menu["Promoveaza Lider"] = {ch_promoteLeader, "Promoveaza/retrogradat membru la Lider/Membru"}
							menu["Promoveaza Membru"] = {ch_promoteMember, "Promoveaza membru la un rank mai mare"}
							menu["Retrogradeaza Membru"] = {ch_demoteMember, "Retrogradat membru la un rank mai mic"}
						end
						menu["Lista Membrii"] = {ch_membersList, "Lista membrii "..theFaction}
						menu["Rankuri & Salarii"] = {ch_ranksAndSalary, "Rankuri si Salarii"}
						menu["Paraseste Factiunea"] = {ch_laveFaction, "Paraseste factiunea "..theFaction}
						vRP.openMenu(player,menu)
					end)
				end, infoText}
			end
		end
		add(choices)
	end
end)

AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
	local tmp = vRP.getUserDataTable(user_id)
	if tmp then
		MySQL.query("vRP/get_user_faction", {user_id = user_id}, function(rows, affected)
			theFaction = tostring(rows[1].faction)
			isLeader = tonumber(rows[1].isFactionLeader)
			factionRank = tostring(rows[1].factionRank)
			tmp.fName = theFaction
			tmp.fRank = factionRank
			tmp.fLeader = isLeader
		end)
	end
end)

local function ch_addfaction(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			vRP.prompt(player,"Faction: ","",function(player,group)
				group = tostring(group)
				vRP.prompt(player,"Lider (1), Membru(0): ","",function(player,lider)
					lider = parseInt(lider)
					theTarget = vRP.getUserSource(id)
					local name = GetPlayerName(theTarget)
					if(lider == 1) then
						vRP.addUserFaction(id,group)
						local Rank = vRP.getFactionRank(user_id)
						vRP.addUserGroup(id,theFaction)
						Citizen.Wait(500)
						vRP.addUserGroup(id,Rank)
						Citizen.Wait(500)
						vRP.setFactionLeader(id,group)
						vRPclient.notify(player,{"Jucatorul "..name.."  a fost adaugat ca si Leader in factiunea "..group})
						return
					else
						vRP.addUserFaction(id,group)
						Citizen.Wait(500)
						vRP.addUserGroup(id,group)
						local Rank = vRP.getFactionRank(user_id)
						vRP.addUserGroup(id,theFaction)
						Citizen.Wait(500)
						vRP.addUserGroup(id,Rank)
						vRPclient.notify(player,{"Jucatorul "..name.." a fost adaugat in factiunea "..group})
					end
				end)
			end)
		end)
	end
end

local function ch_removefaction(player,choice)
	local user_id = vRP.getUserId(player)
	local Rank = vRP.getFactionRank(user_id)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			theTarget = vRP.getUserSource(id)
			if(tonumber(id)) and (id > 0) and (id ~= "") and (id ~= nil)then
			local name = GetPlayerName(theTarget)
			theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..id.." nu este intr-o factiune"})
			else
				vRP.removeUserGroup(id,theFaction)
				vRP.removeUserGroup(id,Rank)
				vRP.removeUserFaction(id,theFaction)
				vRPclient.notify(player,{theFaction.." removed from user "..id})
			end
		else
			vRPclient.notify(player,{"~r~Seems Valid ID"})
			end
		end)
	end
end

local function ch_factionleader(player,choice)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		vRP.prompt(player,"User id: ","",function(player,id)
			id = parseInt(id)
			theTarget = vRP.getUserSource(id)
			local name = GetPlayerName(theTarget)
			local theFaction = vRP.getUserFaction(id)
			if(theFaction == "user")then
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." nu este in nici o factiune!"})
			else
				vRP.setFactionLeader(id,theFaction)
				vRPclient.notify(player,{"Jucatorul cu ID-ul "..name.." a fost adaugat ca lider in factiunea "..theFaction})
			end
		end)
	end
end

vRP.registerMenuBuilder("admin", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id ~= nil then
		local choices = {}
		if vRP.hasGroup(user_id,"Fondator") then
		-- build admin menu
			choices["Add Faction"] = {ch_addfaction}
			choices["Add Faction Leader"] = {ch_factionleader}
			choices["Remove Faction"] = {ch_removefaction}
		end
		add(choices)
	end
end)

RegisterCommand('f', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if(vRP.hasUserFaction(user_id))then
		local theFaction = vRP.getUserFaction(user_id)
		if(args[1] == nil)then
			TriggerClientEvent('cobrakai', source, "^3SYNTAXA: /"..rawCommand.." [Mesaj]") 
		else
			local fMembers = vRP.getOnlineUsersByFaction(tostring(theFaction))
			for i, v in ipairs(fMembers) do
				local player = vRP.getUserSource(tonumber(v))
				TriggerClientEvent('cobrakai', player, "^5["..theFaction.."] ^7| " .. GetPlayerName(source) .. ": " ..  rawCommand:sub(3))
			end
		end
	end
end)
