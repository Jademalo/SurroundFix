--------------------------------------------------------------------------------
--Variables
--------------------------------------------------------------------------------
local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")
local rateLimit = 0.1 --Min time between the script being invoked from an event call
local fixY = 1 --Get the Vertical resolution of the setup
local fixX = 1 --Get the Horizontal resolution of the setup
local fixYdiv = 1
local aspect = "unknown"
local coreSet
local parentDefault = true



--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
local function uiResolution()
	fixY = GetScreenHeight() --Get the Vertical resolution of the setup
	fixX = GetScreenWidth() --Get the Horizontal resolution of the setup
	fixYdiv = fixY/9

	if fixX > (fixYdiv*21) then --If it's bigger than a 21:9 monitor (so multiple monitors)
		if GetScreenWidth() >= (fixYdiv*53) then --Figure out if at least one display is Ultrawide
			fixX = (fixYdiv*21) --Calculate the Horizontal resolution of the middle display for 21:9 Aspect Ratio
			aspect = "21:9"
		elseif GetScreenWidth() == (fixYdiv*36) then --Figure out if all 3 displays are 4:3
			fixX = (fixYdiv*12) --Calculate the Horizontal resolution of the middle display for 4:3 Aspect Ratio
			aspect = "4:3"
		else
			fixX = (fixYdiv*16) --Calculate the Horizontal resolution of the middle display for 16:9 Aspect Ratio
			aspect = "16:9"
		end
	end
end


local function sfixAnnounce() --Chatspam function
	print("~Surround Fix~")

	if GetScreenWidth() <= (fixYdiv*21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), Print this
		print("Single display detected")
	else
		print("Middle display detected as", aspect)
	end

	if parentDefault then --If he haven't touched the default UIParent behaviour, use a different message.
		print("Leaving UIParent as default")
	else
		print("Setting UI Resolution to", floor(fixX+0.5),"x",floor(fixY+0.5))
	end
end


local function UIParentHook(self) --self is needed so it gets passed in on the hook
	if coreSet then --Makes it so that if coreSet is true, it doesn't run the changes.
		return
	end

	coreSet = true --Sets coreSet to true so it doesn't trigger from itsself
	uiResolution()

	if GetScreenWidth() <= (fixYdiv*21) and parentDefault then --If it's smaller than or equal to a 21:9 monitor (so single monitor), do nothing until it's been changed.
		coreSet = nil
		return
	end

	parentDefault = nil --Set this to nil forever, since there's no longer the default UIParent behaviour
	self:SetSize(fixX, fixY) --self is UIParent since that's what the hook is
	self:ClearAllPoints()
	self:SetPoint("CENTER")
	coreSet = nil

end



--------------------------------------------------------------------------------
--Event Registration
--------------------------------------------------------------------------------
sfixFrame:RegisterEvent("ADDON_LOADED")
sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
sfixFrame:RegisterEvent("PLAYER_REGEN_ENABLED")



--------------------------------------------------------------------------------
--Event Handler
--------------------------------------------------------------------------------
sfixFrame:SetScript("OnEvent", function(self, event, ...) --This is essentially saying "On an event, run this function of everything below"

	if event == "ADDON_LOADED" then
		sfixFrame:UnregisterEvent("ADDON_LOADED")
		hooksecurefunc(UIParent, "SetPoint", UIParentHook)--Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
		hooksecurefunc(UIParent, "SetScale", UIParentHook) --Hooks into UIParent "SetScale", so if anything tries to change that then it runs
		sfixAnnounce()
--		hooksecurefunc(CombatText, "CombatText_UpdateDisplayedMessages", combatTextHook)
	end

	if event == "PLAYER_REGEN_ENABLED" then
		UIParent:SetPoint("CENTER") --Fires the hook after leaving combat, to fix it if it happens during combat
	end

    if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
		sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED") --Unregister the events so it doesn't spam
		C_Timer.After(rateLimit, function() UIParent:SetPoint("CENTER") sfixAnnounce() sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box

    end

end)
