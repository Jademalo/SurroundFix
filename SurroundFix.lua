--------------------------------------------------------------------------------
--Variables
--------------------------------------------------------------------------------
local addonName, SurroundFix = ...
local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")
local clipFrame = CreateFrame("Frame", "SurroundFixClipFrame", UIParent)
local rateLimit = 0.1 --Min time between the script being invoked from an event call
local yRes = 1 --Get the Vertical resolution of the setup
local xRes = 1 --Get the Horizontal resolution of the setup
local yResDiv = 1
local aspect = "unknown"
local hookSet
local parentDefault = true

local function aspectMode() return Settings.GetSetting(addonName.."_aspectMode"):GetValue() end


--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
local function uiResolution()
    yRes = GetScreenHeight() --Get the Vertical resolution of the setup
    xRes = GetScreenWidth() --Get the Horizontal resolution of the setup
    yResDiv = yRes / 9

    if aspectMode() == 0 then --Check if the aspect mode is set to automatic

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
    elseif aspectMode() == 1 then
        xRes = ((yRes / 9) * 16)
        aspect = "16:9"
    elseif aspectMode() == 2 then
        xRes = ((yRes / 10) * 16)
        aspect = "16:10"
    elseif aspectMode() == 3 then
        xRes = ((yRes / 9) * 21)
        aspect = "21:9"
    elseif aspectMode() == 4 then
        xRes = ((yRes / 3) * 4)
        aspect = "4:3"
    elseif aspectMode() == 5 then --Check if it is forcing a specific aspect ratio
        xRes = ((yRes / SfixDB.YAspect) * SfixDB.XAspect) --Calculate the Horizontal resolution of the middle display relative to the aspect provided manually
        aspect = SfixDB.XAspect..":"..SfixDB.YAspect
    end


end


function SurroundFix.sfixAnnounce() --Chatspam function
    print("~SurroundFix~")

    if aspectMode() == 0 then
        if GetScreenWidth() <= (yResDiv * 21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), Print this
            print("Auto - Single display detected")
        else
            print("Auto - Middle display detected as", aspect)
        end
    elseif aspectMode() == 5 then
        print("Custom - UI set to", aspect)
    else
        print("Manual - UI set to", aspect)
    end

end


local function ClipFrameSetup()

    clipFrame:SetAllPoints()
    clipFrame:SetClipsChildren(true) --Any children of this frame will only be visible within the frame
    CompactRaidFrameManager:SetParent(clipFrame) --Set the Compact Raid Frame Manager to be a child of clipFrame

end


local function UIParentHook(self) --self is needed so it gets passed in on the hook

    if hookSet or InCombatLockdown() then --Makes it so that if hookSet is true or if in combat lockdown, it doesn't run the changes.
        return
    end

    hookSet = true --Sets hookSet to true so it doesn't trigger from itsself
    uiResolution()

    local screenWidth = GetScreenWidth()

    if screenWidth <= (yResDiv * 21) and parentDefault and aspectMode() == 0 then --If it's smaller than or equal to a 21:9 monitor (so single monitor) and auto mode is selected, do nothing until it's been changed.
        hookSet = false
        return
    end

    local leftOffset = (screenWidth - xRes) / 2

    parentDefault = false --Set this to false forever, since there's no longer the default UIParent behaviour
    self:SetPoint("TOPLEFT", leftOffset, 0) --self is UIParent since that's what the hook is
    self:SetPoint("BOTTOMRIGHT", -leftOffset, 0)
    hookSet = false

end


--------------------------------------------------------------------------------
--Event Registration
--------------------------------------------------------------------------------
sfixFrame:RegisterEvent("ADDON_LOADED")
sfixFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
sfixFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
sfixFrame:RegisterEvent("UI_SCALE_CHANGED")



--------------------------------------------------------------------------------
--Event Handler
--------------------------------------------------------------------------------
sfixFrame:SetScript("OnEvent", function(self, event, arg1, arg2) --This is essentially saying "On an event, run this function of everything below"

if event == "ADDON_LOADED" and arg1 == addonName then
    sfixFrame:UnregisterEvent("ADDON_LOADED")
    hooksecurefunc(UIParent, "SetPoint", UIParentHook) --Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
    ClipFrameSetup() --Set up the clip frame
end

if event == "PLAYER_ENTERING_WORLD" and (arg1 or arg2) then --This checks the first two args to see if it's first login or a reload
    SurroundFix.sfixAnnounce() --Prints the chatspam when everything has loaded and the player enters the world, here rather than in ADDON_LOADED to prevent an error
    sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") --This is here to prevent this event firing on /reload and doubling messages
end

if event == "PLAYER_ENTERING_WORLD" or "PLAYER_REGEN_ENABLED" or "UI_SCALE_CHANGED" then --This fires on all loading screens to make sure the UI is set, as well as when leaving combat and changing UI Scale
    UIParent:SetPoint("TOPLEFT")
end

if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
    sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED") --Unregister the events so it doesn't spam
    C_Timer.After(rateLimit, function() UIParent:SetPoint("TOPLEFT") SurroundFix.sfixAnnounce() sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box
end

end)

