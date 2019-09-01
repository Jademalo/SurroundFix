local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")

    sfixFrame:RegisterEvent("PLAYER_LOGIN")
    sfixFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    sfixFrame:RegisterEvent("ADDON_LOADED")
	sfixFrame:RegisterEvent("PLAYER_ALIVE")
	sfixFrame:RegisterEvent("SPELLS_CHANGED")


    sfixFrame:HookScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" then
			UIParent:SetSize(1920, 1080)
            UIParent:ClearAllPoints()
            UIParent:SetPoint("CENTER")
        end

    end)
