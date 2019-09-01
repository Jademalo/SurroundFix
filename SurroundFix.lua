local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")
sfixFrame:RegisterEvent("ADDON_LOADED")
sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")

sfixFrame:SetScript("OnEvent", function(self, event, ...)
	local fixY = GetScreenHeight() --Get the Vertical resolution of the setup
	local fixYdiv = fixY/9
	local fixX
	local aspect

    if event == "DISPLAY_SIZE_CHANGED" or if event == "ADDON_LOADED" then
       	if GetScreenWidth() <= (fixYdiv*21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), do nothing.
       		print("SurroundFix - Single display detected")
       		return
       	else

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

       		print("SurroundFix - Middle display detected as", aspect,"- Setting UI to", fixX,"x",fixY)

       		local coreSet
       		hooksecurefunc(UIParent, "SetPoint", function(self) --Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
       			if coreSet then --Makes it so that if coreSet is true, it doesn't run the changes.
       				return
       			end

       			coreSet = true --Sets coreSet to true so it doesn't trigger from itsself
       			self:SetSize(fixX, fixY) --self is UIParent since that's what the hook is
       			self:ClearAllPoints()
       			self:SetPoint("CENTER")
       			coreSet = nil
       		end)

    		UIParent:SetPoint("CENTER") --This forces the hook to run at least once to actually set the fix

    	end
    end
end)
