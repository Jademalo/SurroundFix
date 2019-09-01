local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")

function eventRegister() --Function to register events
	sfixFrame:RegisterEvent("ADDON_LOADED")
	sfixFrame:RegisterEvent("PLAYER_LOGIN")
	sfixFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
end

function eventUnregister() --Function to Unreguster those same events
	sfixFrame:UnregisterEvent("ADDON_LOADED")
	sfixFrame:UnregisterEvent("PLAYER_LOGIN")
	sfixFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
end



function uiResolution()
	fixY = GetScreenHeight() --Get the Vertical resolution of the setup
	fixX = GetScreenWidth() --Get the Horizontal resolution of the setup
	fixYdiv = fixY/9
	aspect = "unknown"

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

function uiParentHook()
	if coreSet then --Makes it so that if coreSet is true, it doesn't run the changes.
		return
	end

	uiResolution() --Runs the main code that works out the neccesary resolution of the UI

	coreSet = true --Sets coreSet to true so it doesn't trigger from itsself
	self:SetSize(fixX,fixY) --self is UIParent since that's what the hook is
	self:ClearAllPoints()
	self:SetPoint("CENTER")
	coreSet = nil

	sfixAnnounce()
end



function sfixAnnounce() --Chatspam function
		print("~Surround Fix~")

	if GetScreenWidth() <= (fixYdiv*21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), Print this
		print("Single display detected")
	else
		print("Middle display detected as", aspect)
	end

		print("Setting UI Resolution to", floor(fixX+0.5),"x",floor(fixY+0.5))

end

function diagAnnounce()
	print("UIParent Effective Scale -",UIParent:GetEffectiveScale())
	print("Base -",GetScreenWidth(),"x",GetScreenHeight())
	print("Floor Base -",floor(GetScreenWidth()+0.5),"x",floor(GetScreenHeight()+0.5))
	print("Base Effective Res -",floor((GetScreenWidth()* UIParent:GetEffectiveScale())+0.5),"x",floor((GetScreenHeight()* UIParent:GetEffectiveScale())+0.5))
end

eventRegister() --Runs this to register once




sfixFrame:SetScript("OnEvent", function(self, event, ...) --This is essentially saying "On an event, run this function of everything below"

	local rateLimit = 0.5 --Min time between the script being invoked from an event call

	function sfixMain() --Main function

		uiResolution() --Runs this once to generate the values
     	hooksecurefunc(UIParent, "SetPoint", function() uiParentHook() end) --Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
--		hooksecurefunc(UIParent, "SetScale", function(self) uiParentHook() end) --Hooks into UIParent "SetScale", so if anything tries to change that then it runs

    	UIParent:SetPoint("CENTER") --This forces the hook to run at least once to actually set the fix

	end



	if event == "PLAYER_LOGIN" then
		sfixMain()
	end

    if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
		eventUnregister() --Unregister the events so it doesn't spam
		C_Timer.After(0.1, function() UIParent:SetPoint("CENTER") end) --Run the main code after 0.1 seconds to prevent issues

		C_Timer.After(rateLimit, function() eventRegister() sfixMain() end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box
    end


end)


--		C_Timer.After(2, function() eventRegister() print("timer1") end) - This style of having a function and then two things with an end at the end lets you invoke multiple functions since you're making a mini function in there
--floor(x+0.5) rounds a number normally.
