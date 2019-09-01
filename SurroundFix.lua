local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")

    sfixFrame:RegisterEvent("PLAYER_LOGIN")
    sfixFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    sfixFrame:RegisterEvent("ADDON_LOADED")
	sfixFrame:RegisterEvent("PLAYER_ALIVE")
	sfixFrame:RegisterEvent("SPELLS_CHANGED")


    sfixFrame:HookScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" or "ADDON_LOADED" or "PLAYER_ENTERING_WORLD" or "PLAYER_ALIVE" or "SPELLS_CHANGED" then
			UIParent:SetSize(1920, 1080)
            UIParent:ClearAllPoints()
            UIParent:SetPoint("CENTER")
        end

    end)
