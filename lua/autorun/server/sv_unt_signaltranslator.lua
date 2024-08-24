util.AddNetworkString("unt_signalTranslator")

local cv_enabled	= CreateConVar("sv_signaltranslator_enabled",		1, FCVAR_ARCHIVE, "Enables signal translator.", 0, 1)
local cv_maxLength	= CreateConVar("sv_signaltranslator_maxlen",		9, FCVAR_ARCHIVE, "Signal translator max message length.", 1, 24)
local cv_adminOnly	= CreateConVar("sv_signaltranslator_adminonly",		1, FCVAR_ARCHIVE, "Restricts signal translator only for admins.", 0, 1)

-- Actually allow to send messages without limits using Lua.
function SignalTranslator(message, owner)
	assert(isstring(message), "ban argument #1 to 'SignalTranslator' (string expected, got " .. type(message) .. ")")
	assert(owner == nil or (isentity(owner) and owner:IsPlayer()), "ban argument #2 to 'SignalTranslator' (Player expected, got " .. type(owner) .. ")")

	message = message:sub(1, 24)
	message = message:match("[%a%s%w%p]+")

	if not message or #message < 1 then
		return false, "short-or-nonLatin"
	end

	if hook.Run("PreSignalTranslator", message, owner) == false then return false, "blocked" end

	net.Start("unt_signalTranslator")
		net.WriteString(message)
		net.WriteEntity(owner)
	net.Broadcast()

	hook.Run("OnSignalTranslator", message, owner)

	return true
end

local function sendMessage(ply, ...)
	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTCONSOLE, ...)
	else
		print(...)
	end
end

concommand.Add("transmit", function(ply, _, _, str)
	if cv_adminOnly:GetBool() then
		if IsValid(ply) and not ply:IsAdmin() then return end
	end

	if not cv_enabled:GetBool() then
		sendMessage(ply, "Signal Translator's concommand is disabled by the server (unt_signaltranslator_enabled = 0)")

		return
	end

	str = str:sub(1, cv_maxLength:GetInt())
	local ok, err = SignalTranslator(str, ply)

	if ok then
		if IsValid(ply) then
			MsgC(
				color_white, "Player ",
				team.GetColor(ply:Team()), ply:Name(),
				color_white, " used Signal Translator: ", str
			)

			Msg("\n")
		else
			print("Transmitting message: " .. str)
		end
	else
		if err == "short-or-nonLatin" then
			sendMessage(ply, "Message is too short or contains non-Latin letters.")
		elseif err == "blocked" then
			sendMessage(ply, "Blocked by PreSignalTranslator hook. No access?")
		else
			sendMessage(ply, "Failed. This should not happen.")
		end
	end
end)

print("Signal Translator by @Zvbhrf loaded! (https://github.com/UnitLabs/lethal-company-signal-translator)")