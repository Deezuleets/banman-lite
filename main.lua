-- Change this to 'true' to allow guests
local allowGuests = false

function onInit()
    print("BanManager 1.2.0 Ready")
    MP.RegisterEvent("onPlayerAuth","playerAuthHandler")
	MP.RegisterEvent("onChatMessage", "chatMessageHandler")
end

function playerAuthHandler(name, role, isGuest)

	if isGuest and not allowGuests then
		return "You must be signed in to join this server!"
	end

	local f = assert(io.open("../banlist", "r"))
	local t = f:read ("*all")
	
	print("BanManager: Checking banlist for " .. name)
	
	if string.match(t, name) then
		return "You have been banned from the server."
	else
		print("BanManager: All good, user clear to join.")
	end
	
	f:close()

end

function chatMessageHandler(playerID, senderName, message)

	local f = assert(io.open("../perms", "r"))
	local t = f:read ("*all")

	local permsMatch = string.match(t, senderName)
	local getPlayerList = string.match(message, "/idmatch")
	local msgKick = string.match(message, "/kick")
	local msgNumR = string.match(message, "%d+")
	local msgNum = tonumber(msgNumR)

	if senderName == permsMatch then
		--=================================--
		if message == msgKick then
			return true
		end
		if message == getPlayerList then
			return true
		end
		--=================================--

		if getPlayerList then
			local count = msgNum - 1
			while count >= 0 do
				local playerName = MP.GetPlayerName(count)
				if playerName == nil then
					local missingID = "Did not find player with ID " .. count
					MP.SendChatMessage(playerID, missingID)
				else
					playerName = count .. " - " .. MP.GetPlayerName(count)
					MP.SendChatMessage(playerID, playerName)
				end
				count = count - 1
			end
			return -1
		end

		if msgKick then
			if msgNum == nil then
				return "Invalid argument"
			else
				MP.DropPlayer(msgNum)
				print("Kicked player with ID " .. msgNum)
			end
			return -1
		end
	end

	f:close()
end