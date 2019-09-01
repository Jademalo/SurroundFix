local AddonName = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if AddonName ~= ... then
            return
        else
            local altering
            hooksecurefunc(UIParent, "SetPoint", function(self)
                if altering then
                    return
                end

                altering = true
                self:SetSize(1920, 1080)
                self:ClearAllPoints()
                self:SetPoint("CENTER")
                altering = nil
            end)

            UIParent:SetSize(1920, 1080)
            UIParent:ClearAllPoints()
            UIParent:SetPoint("CENTER")

            self:UnregisterEvent("ADDON_LOADED")
        end
    end
end)
