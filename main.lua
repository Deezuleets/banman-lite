-- Configure your settings here --

local allowGuests = false
local carLimit = 2 -- Server car limit
local playerLimit = 10 -- Server player limit
local staffSlot = false

----------------------------------

function onInit()
	print("BanManager 1.4.3 Loaded")
	MP.RegisterEvent("onPlayerAuth","playerAuthHandler")
	MP.RegisterEvent("onChatMessage", "chatMessageHandler")
	MP.RegisterEvent("onVehicleSpawn", "spawnLimitHandler")
end

function playerAuthHandler(name, role, isGuest)

	local playersCurrent = MP.GetPlayerCount()
	local pattern = {"%-"}
    local patternout = {"%%-"}

	local banFile = assert(io.open("../banlist", "r"))
	local banlist = banFile:read ("*all")
	banFile:close()

	local authFile = assert(io.open("../perms", "r"))
	local authlist = authFile:read("*all")
	authFile:close()

	if isGuest and not allowGuests then
		return "You must be signed in to join this server!"
	end

    for i = 1, # pattern do
        name = name:gsub(pattern[i], patternout[i])
    end

	if staffSlot == true then
		if playersCurrent == (playerLimit - 1) and not string.match(authlist, name) then
			return "The server is full. Last slot is reserved for staff."
		end
	end
	
	print("BanManager: Checking banlist for " .. name)
	   
	if string.match(banlist, name) then
		return "You have been banned from the server."
	else
		print("BanManager: All good, user clear to join.")
	end

end

function spawnLimitHandler(playerID)

	local playerVehicles = MP.GetPlayerVehicles(playerID)
	local playerCarCount = 0

	-- Check for nil table and loop through player cars
	if playerVehicles ~= nil then
		for _ in pairs(playerVehicles) do playerCarCount = playerCarCount + 1 end
	end

	carLimit = carLimit + 1

	if (playerCarCount + 1) > carLimit then
		MP.DropPlayer(playerID)
		MP.SendChatMessage(-1, "Player " .. MP.GetPlayerName(playerID) .. " was kicked for spawning more than " .. carLimit .. " cars.")
		print("BanManager: Player " .. MP.GetPlayerName(playerID) .. " was kicked for spawning too many cars.")
	end

end

function chatMessageHandler(playerID, senderName, message)

	-- Initialize files
	local authFile = assert(io.open("../perms", "r"))
	local authlist = authFile:read ("*all")
	local banlist = assert(io.open("../banlist", "a+"))

	local authMatch = string.match(authlist, senderName)
	local msgTxt = string.match(message, "%s(.*)")
	local msgNum = tonumber(string.match(message, "%d+"))

	authFile:close()

	-- Intialize commands
	local getPlayerList = string.match(message, "/idmatch")
	local msgKick = string.match(message, "/kick")
	local msgBan = string.match(message, "/ban")
	local msgKban = string.match(message, "/kban")
	local msgCountdown = string.match(message, "/countdown")

	-- Start parsing commands
	if msgCountdown then
		local i = 3
		while i > 0 do
			MP.SendChatMessage(-1, "Countdown: " .. i)
			i = i - 1
			MP.Sleep(1000)
		end
		MP.SendChatMessage(-1, "Go!")
		return -1
	end

	if senderName == authMatch then
		if getPlayerList then
			local i = playerLimit - 1
			while i >= 0 do
				local playerName = MP.GetPlayerName(i)
				if playerName == nil then
					MP.SendChatMessage(playerID, "Did not find player with ID" .. i)
				else
					playerName = i .. " - " .. MP.GetPlayerName(i)
					MP.SendChatMessage(playerID, playerName)
				end
				i = i - 1
			end
			return -1
		end

		if msgKick then
			if msgNum == nil then
				MP.SendChatMessage(playerID, "No ID given")
			else
				MP.DropPlayer(msgNum)
				MP.SendChatMessage(playerID, "Kicked player " .. MP.GetPlayerName(msgNum))
			end
			return -1
		end

		if msgKban then
			if msgNum == nil then
				MP.SendChatMessage(playerID, "No ID given")
			else
				local KbanUsr = MP.GetPlayerName(msgNum)
				banlist:write("\n" .. KbanUsr)
				banlist:flush()
				banlist:close()
				MP.DropPlayer(msgNum)
				MP.SendChatMessage(playerID, "Banned user " .. KbanUsr)
			end
			return -1
		end

		if msgBan then
			if msgTxt == nil then
				MP.SendChatMessage(playerID, "Invalid username")
			else
				banlist:write("\n" .. msgTxt)
				banlist:flush()
				banlist:close()
				MP.SendChatMessage(playerID, "Banned user " .. msgTxt)
			end
			return -1
		end
	end

end


