--------------------------------------------------------------------------------
--Variables
--------------------------------------------------------------------------------
local addonName = ...
local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")
local rateLimit = 0.1 --Min time between the script being invoked from an event call
local yRes = 1 --Get the Vertical resolution of the setup
local xRes = 1 --Get the Horizontal resolution of the setup
local yResDiv = 1
local aspect = "unknown"
local hookSet
local parentDefault = true



--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
local function uiResolution()
    yRes = GetScreenHeight() --Get the Vertical resolution of the setup
    xRes = GetScreenWidth() --Get the Horizontal resolution of the setup
    yResDiv = yRes / 9

    if xRes > (yResDiv * 21) then --If it's bigger than a 21:9 monitor (so multiple monitors)
        if xRes >= (yResDiv * 53) then --Figure out if at least one display is Ultrawide
            xRes = (yResDiv * 21) --Calculate the Horizontal resolution of the middle display for 21:9 Aspect Ratio
            aspect = "21:9"
        elseif xRes == (yResDiv * 36) then --Figure out if all 3 displays are 4:3
            xRes = (yResDiv * 12) --Calculate the Horizontal resolution of the middle display for 4:3 Aspect Ratio
            aspect = "4:3"
        elseif xRes == ((yRes / 10) * 48) then --Figure out if all 3 displays are 16:10
            xRes = ((yRes / 10) * 16) --Calculate the Horizontal resolution of the middle display for 16:10 Aspect Ratio
            aspect = "16:10"
        else
            xRes = (yResDiv * 16) --Calculate the Horizontal resolution of the middle display for 16:9 Aspect Ratio
            aspect = "16:9"
        end
    end
end


local function sfixAnnounce() --Chatspam function
    print("~Surround Fix~")

    if GetScreenWidth() <= (yResDiv * 21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), Print this
        print("Single display detected")
    else
        print("Middle display detected as", aspect)
    end

    if parentDefault then --If he haven't touched the default UIParent behaviour, use a different message.
        print("Leaving UIParent as default")
    else
        print("Setting UI Resolution to", floor(xRes + 0.5), "x", floor(yRes + 0.5))
    end
end


local function UIParentHook(self) --self is needed so it gets passed in on the hook

    if hookSet or InCombatLockdown() then --Makes it so that if hookSet is true or if in combat lockdown, it doesn't run the changes.
        return
    end

    hookSet = true --Sets hookSet to true so it doesn't trigger from itsself
    uiResolution()

    if GetScreenWidth() <= (yResDiv * 21) and parentDefault then --If it's smaller than or equal to a 21:9 monitor (so single monitor), do nothing until it's been changed.
        hookSet = nil
        return
    end

    parentDefault = nil --Set this to nil forever, since there's no longer the default UIParent behaviour
    self:SetSize(xRes, yRes) --self is UIParent since that's what the hook is
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    hookSet = nil

end



--------------------------------------------------------------------------------
--Event Registration
--------------------------------------------------------------------------------
sfixFrame:RegisterEvent("ADDON_LOADED")
sfixFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
sfixFrame:RegisterEvent("PLAYER_REGEN_ENABLED")



--------------------------------------------------------------------------------
--Event Handler
--------------------------------------------------------------------------------
sfixFrame:SetScript("OnEvent", function(self, event, ...) --This is essentially saying "On an event, run this function of everything below"

    if event == "ADDON_LOADED" and addonName == ... then
    sfixFrame:UnregisterEvent("ADDON_LOADED")
    hooksecurefunc(UIParent, "SetPoint", UIParentHook)--Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
end

if event == "PLAYER_ENTERING_WORLD" then
    sfixFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    sfixAnnounce() --Prints the chatspam when everything has loaded and the player enters the world, here rather than in ADDON_LOADED to prevent an error
    sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") --This is here to prevent this event firing on /reload and doubling messages
end

if event == "PLAYER_REGEN_ENABLED" then
    UIParent:SetPoint("CENTER") --Fires the hook after leaving combat, to fix it if it happens during combat
end

if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
    sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED") --Unregister the events so it doesn't spam
    C_Timer.After(rateLimit, function() UIParent:SetPoint("CENTER") sfixAnnounce() sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box
end

end)
