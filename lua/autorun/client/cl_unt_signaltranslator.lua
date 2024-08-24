local cv_enabled	= CreateClientConVar("cl_signaltranslator_enabled",		1, true, false, "Enables signal translator.", 0, 1)
local cv_sound		= CreateClientConVar("cl_signaltranslator_sound",		1, true, false, "Enables signal translator's sound.", 0, 1)
local cv_soundVol	= CreateClientConVar("cl_signaltranslator_soundvol",	0.6, true, false, "Signal Translator's sound volume.", 0, 1)
local cv_additive	= CreateClientConVar("cl_signaltranslator_additive",	1, true, false, "Signal Translator's font is additive.", 0, 1)

local queue = {}
local COLOR_TEXT = Color(0, 255, 0, 225)
local COLOR_LINE = Color(0, 255, 0, 20)

local function playSound(soundName)
	if cv_sound:GetBool() then
		LocalPlayer():EmitSound(soundName, 0, 100, cv_soundVol:GetFloat())
	end
end

local function buildFonts()
	local additive = cv_additive:GetBool()

	surface.CreateFont("signalTranslator:title", {
		font = "Edit Undo Line BRK",
		size = ScreenScaleH(25),
		weight = 450,
		additive = additive
	})

	surface.CreateFont("signalTranslator:text", {
		font = "Edit Undo Line BRK",
		size = ScreenScaleH(60),
		weight = 450,
		additive = additive
	})
end

local text_to_draw = ""
local position_x = 0
local co = nil
local lineAnim = 0
local drawAnim = 0
local function PostDrawHUD()
	local w, h = ScrW(), ScrH()

	if drawAnim < 1 then
		surface.SetAlphaMultiplier(drawAnim * math.Rand(0.2, 0.9))
	end

	draw.SimpleText("RECEIVING SIGNAL", "signalTranslator:title", w / 2, h / 3, COLOR_TEXT, 1, 1)

	surface.SetDrawColor(COLOR_LINE)
	local space = (8 + 30) * 5
	local startPos = (h / 2) - (space / 2)

	if lineAnim < 1 then
		lineAnim = math.min(1, lineAnim + FrameTime() / 2)
	end

	for i = 1, 5 do
		surface.DrawRect(0, startPos + (30 * i), w * lineAnim, 8)
	end

	draw.SimpleText(text_to_draw, "signalTranslator:text", w / 2 - (position_x / 2), h / 2, COLOR_TEXT, 0, 1)

	if drawAnim < 1 then
		surface.SetAlphaMultiplier(1)
	end

	if co and coroutine.status(co) ~= "dead" then
		if drawAnim < 1 then
			drawAnim = math.min(1, drawAnim + FrameTime() * 2)
		end

		local ok, err = coroutine.resume(co)

		if not ok then
			ErrorNoHaltWithStack(err)
		end
	else
		if drawAnim > 0 then
			drawAnim = math.max(0, drawAnim - FrameTime() * 2)
		else
			hook.Remove("PostDrawHUD", "unt_signalTranslator")
		end
	end
end

local doFonts = true -- Create only when necessary
local function enable()
	if doFonts then
		doFonts = nil

		buildFonts()
	end

	playSound("unitlabs/lethalcompany/signaltranslator_local.wav")

	co = coroutine.create(function()
		lineAnim = 0
		drawAnim = 0

		while #queue > 0 do
			local text = queue[1]

			text_to_draw = ""
			playSound("unitlabs/lethalcompany/signaltranslator_begin.wav")

			coroutine.wait(1.21)

			surface.SetFont("signalTranslator:text")
			position_x = surface.GetTextSize(text)

			for i = 1, #text do
				local letter = text[i]
				text_to_draw = text_to_draw .. letter

				if not letter:match("%s") then
					playSound("unitlabs/lethalcompany/signaltranslator_type" .. math.random(1, 3) .. ".wav")
				end

				-- float num = Mathf.Min((float)signalMessageRandom.Next(-1, 4) * 0.5f, 0f);
				-- yield return new WaitForSeconds(0.7f + num);

				local num = math.min(0, math.Rand(-1, 4) * 0.5)
				coroutine.wait(0.7 + num)
			end

			playSound("unitlabs/lethalcompany/signaltranslator_finish.wav")

			coroutine.wait(0.5)

			table.remove(queue, 1)

			coroutine.yield()
		end
	end)

	hook.Add("PostDrawHUD", "unt_signalTranslator", PostDrawHUD)
end

net.Receive("unt_signalTranslator", function(len)
	if not cv_enabled:GetBool() then return end

	local str = net.ReadString()
	local owner = net.ReadEntity()

	if hook.Run("PreSignalTranslator", str, owner) == false then return end

	local n = table.insert(queue, str)

	Msg("Received message: ", str, " (enqueued #" .. n .. ") ")

	if owner:IsPlayer() then
		print("from", owner)
	else
		Msg("\n")
	end

	if n == 1 then
		enable()
	end

	hook.Run("OnSignalTranslator", str, owner)
end)

cvars.AddChangeCallback("cl_signaltranslator_additive", buildFonts, "cl_signaltranslator_additive")

-- RunConsoleCommand("transmit", "Hello!")

print("Signal Translator by @Zvbhrf loaded! (https://github.com/UnitLabs/lethal-company-signal-translator)")