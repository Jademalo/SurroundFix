--------------------------------------------------------------------------------
--Variables
--------------------------------------------------------------------------------
local addonName, SurroundFix = ...
local sfixFrame = CreateFrame("Frame", "SurroundFixFrame")
local clipFrame = CreateFrame("Frame", "SurroundFixClipFrame", UIParent)
local rateLimit = 0.1 --Min time between the script being invoked from an event call
local hookSet
local parentDefault = true


--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
--Get the value of the specific aspect mode
local function aspectMode() 
    return Settings.GetSetting(addonName.."_aspectMode"):GetValue() 
end

--Calculate the required aspect based on the aspect mode
--Returns xAspect yAspect
local function aspectCalc(var)
    var = var or aspectMode()
    if var == 0 then
        local xRes = GetScreenWidth() --Get the Horizontal resolution of the setup
        local yRes = GetScreenHeight() --Get the Vertical resolution of the setup

        if xRes > ((yRes / 9) * 21) then --If it's bigger than a 21:9 monitor (so multiple monitors)
            if xRes >= ((yRes / 9) * 53) then --Figure out if at least one display is Ultrawide
                return 21, 9
            elseif xRes == ((yRes / 9) * 36) then --Figure out if all 3 displays are 4:3
                return 4, 3
            elseif xRes == ((yRes / 10) * 48) then --Figure out if all 3 displays are 16:10
                return 16, 10
            else
                return 16, 9
            end
        else
            return GetPhysicalScreenSize() --Special return if default to send the raw resolution as an aspect ratio
        end
    elseif var == 1 then --Check if it is forcing a specific aspect ratio
        return SfixDB.customXAspect, SfixDB.customYAspect
    elseif var == 2 then
        return 16, 9
    elseif var == 3 then
        return 16, 10
    elseif var == 4 then
        return 21, 9
    elseif var == 5 then
        return 4, 3
    end
end

--Chatspam function
function SurroundFix.sfixAnnounce()
    local xAspect, yAspect = aspectCalc()
    local aspectRatio = xAspect..":"..yAspect

    if aspectMode() == 0 then
        if xAspect < 30 then --If aspectCalc throws back an aspect instead of an actual resolution
            print("SurroundFix - Middle display detected as", aspectRatio)
        end
    else
        print("SurroundFix - UI set to", aspectRatio)
    end
end

local function ClipFrameSetup()
    clipFrame:SetAllPoints()
    clipFrame:SetClipsChildren(true) --Any children of this frame will only be visible within the frame
    CompactRaidFrameManager:SetParent(clipFrame) --Set the Compact Raid Frame Manager to be a child of clipFrame
end

--Restrict screenshots to the size of UIParent
function SurroundFix.restrictScreenshot()
    local xRes, yRes = GetPhysicalScreenSize()
    local xAspect, yAspect = aspectCalc(aspectMode())
    local res

    if Settings.GetSetting(addonName.."_restrictScreenshot"):GetValue() == true then
        res = ((yRes / yAspect) * xAspect).."x"..yRes
    else
        res = "0x0"
    end

    SetCVar("screenshotSizeOverride", res)
end

local function UIParentHook(self) --self is needed so it gets passed in on the hook

    if hookSet or InCombatLockdown() then return end --Makes it so that if hookSet is true or if in combat lockdown, it doesn't run the changes.
    hookSet = true --Sets hookSet to true so it doesn't trigger from itsself

    local xRes = GetScreenWidth()
    local yRes = GetScreenHeight()
    local xAspect, yAspect = aspectCalc() --Get the target aspect ratio
    local xResScaled = ((yRes / yAspect) * xAspect) --Calculate the scaled x axis resolution

    if xAspect > 30 and parentDefault then --If aspectCalc throws back a resolution implying single display and UIParent has not been modified, do nothing until it's been changed.
        hookSet = false
        return
    end

    local leftOffset = (xRes - xResScaled) / 2

    parentDefault = false --Set this to false forever, since there's no longer the default UIParent behaviour
    self:SetPoint("TOPLEFT", leftOffset, 0) --self is UIParent since that's what the hook is
    self:SetPoint("BOTTOMRIGHT", -leftOffset, 0)
    SurroundFix.restrictScreenshot() --Configure the cvar to restrict screenshot size
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
    UIParent:SetPoint(UIParent:GetPoint())
end

if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
    sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED") --Unregister the events so it doesn't spam
    C_Timer.After(rateLimit, function() UIParent:SetPoint(UIParent:GetPoint()) SurroundFix.sfixAnnounce() sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box
end

end)

