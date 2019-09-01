local AddonName = ...

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if AddonName ~= ... then
            return
        else
            self:UnregisterEvent("ADDON_LOADED")
        end
    end

    local altering
    hooksecurefunc(UIParent, "SetPoint", function(self)
        if InCombatLockdown() then
            return
        end
        if altering then
            return
        end

        altering = true
        self:SetSize(1920, 1080)
        self:ClearAllPoints()
        self:SetPoint("CENTER")
        altering = nil
    end)

    if InCombatLockdown() then
        return
    end

    self:SetSize(1920, 1080)
    self:ClearAllPoints()
    self:SetPoint("CENTER")
end)
