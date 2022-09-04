--------------------------------------------
--Check for project type
--------------------------------------------
local isVanilla = (LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CLASSIC)
local isTBC = (LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_BURNING_CRUSADE)
local isWrath = (LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_NORTHREND)



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

if not SfixForceAspect then --Initialise manual variables if SfixForceAspect doesn't already exist. This tests for nil, not 0.
    SfixForceAspect = 0
    SfixXAspect = 16
    SfixYAspect = 9
end

SLASH_SFIX1, SLASH_SFIX2 = "/sfix", "/surroundfix"; --Setting the slash commands available



--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
local function uiResolution()
    yRes = GetScreenHeight() --Get the Vertical resolution of the setup
    xRes = GetScreenWidth() --Get the Horizontal resolution of the setup
    yResDiv = yRes / 9

    if SfixForceAspect == 0 then --Check if the aspect mode is set to automatic

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

    elseif SfixForceAspect == 1 then --Check if it is forcing a specific aspect ratio
        xRes = ((yRes / SfixYAspect) * SfixXAspect) --Calculate the Horizontal resolution of the middle display relative to the aspect provided manually
        aspect = SfixXAspect..":"..SfixYAspect
    end


end


local function sfixAnnounce() --Chatspam function
    if isVanilla then
        print("~SurroundFix Classic~")
    elseif isTBC then
        print("~SurroundFix Burning Crusade Classic~")
    elseif isWrath then
        print("~SurroundFix Wrath of the Lich King Classic~")
    else
        print("~SurroundFix~")
    end

    if SfixForceAspect == 0 then
        if GetScreenWidth() <= (yResDiv * 21) then --If it's smaller than or equal to a 21:9 monitor (so single monitor), Print this
            print("Automatic mode - Single display detected")
        else
            print("Automatic mode - Middle display detected as", aspect)
        end
    else
        print("Manual mode - UI set to", aspect)
    end

--[[
    if parentDefault then --If we haven't touched the default UIParent behaviour, use a different message.
        print("Leaving UIParent as default")
    else
        print("Setting UI Resolution to "..floor(xRes + 0.5).."x"..floor(yRes + 0.5))
    end
--]]
end


local function UIParentHook(self) --self is needed so it gets passed in on the hook

    if hookSet or InCombatLockdown() then --Makes it so that if hookSet is true or if in combat lockdown, it doesn't run the changes.
        return
    end

    hookSet = true --Sets hookSet to true so it doesn't trigger from itsself
    uiResolution()

    if GetScreenWidth() <= (yResDiv * 21) and parentDefault and SfixForceAspect == 0 then --If it's smaller than or equal to a 21:9 monitor (so single monitor) and auto mode is selected, do nothing until it's been changed.
        hookSet = false
        return
    end

    parentDefault = false --Set this to false forever, since there's no longer the default UIParent behaviour
    self:SetSize(xRes, yRes) --self is UIParent since that's what the hook is
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    hookSet = false

end


local function slashHandler(msg, editBox)
    local command, xAspect, yAspect, rest = msg:match("^(%S*)%s*(%d*):?(%d*)(.-)$") --Set command to the first bit of text before whitespace, set xaspect to the first number, set yaspect to the number after a colon, and set remaining to rest

    if command == "aspect" then --If the command is aspect

        if xAspect ~= "" and yAspect ~= "" and rest == "" then --If there's a number in xAspect and yAspect, and there's nothing else

            SfixForceAspect = 1
            SfixXAspect = tonumber(xAspect) --Set global
            SfixYAspect = tonumber(yAspect) --Set global
            UIParent:SetPoint("CENTER")
            sfixAnnounce()

        elseif xAspect == "" and yAspect == "" and rest ~= "" then --If the command is /sfix aspect [something]

            if rest == "auto" then --If the command is /sfix aspect [auto]
                SfixForceAspect = 0
                UIParent:SetPoint("CENTER")
                sfixAnnounce()
            else --If the command is /sfix aspect [something else]
                print("SurroundFix - Usage: \'/sfix aspect [x:y | auto]\' - x:y sets a defined aspect ratio, or auto sets automatic detection")
            end

        else --If the command is /sfix aspect [something other than an aspect ratio or auto]
            print("SurroundFix - Usage: \'/sfix aspect [x:y | auto]\' - x:y sets a defined aspect ratio, or auto sets automatic detection")
        end

    elseif command == "refresh" then --If the command is refresh
        UIParent:SetPoint("CENTER")
        sfixAnnounce()
    else --If the command is /sfix [anything not defined]
        print("SurroundFix - Usage: \'/sfix [aspect | refresh]\' - Use aspect to change how the aspect ratio is calculated, or refresh to force a refresh")
    end

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
sfixFrame:SetScript("OnEvent", function(self, event, arg1, arg2) --This is essentially saying "On an event, run this function of everything below"

if event == "ADDON_LOADED" and arg1 == addonName then
    sfixFrame:UnregisterEvent("ADDON_LOADED")
    hooksecurefunc(UIParent, "SetPoint", UIParentHook) --Hooks into UIParent "SetPoint", so if anything tries to change that then it runs
end

if event == "PLAYER_ENTERING_WORLD" and (arg1 or arg2) then --This checks the first two args to see if it's first login or a reload
    sfixAnnounce() --Prints the chatspam when everything has loaded and the player enters the world, here rather than in ADDON_LOADED to prevent an error
    sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") --This is here to prevent this event firing on /reload and doubling messages
end

if event == ("PLAYER_ENTERING_WORLD" or "PLAYER_REGEN_ENABLED") then --This fires on all loading screens to make sure the UI is set, as well as when leaving combat
    UIParent:SetPoint("CENTER")
end

if event == "DISPLAY_SIZE_CHANGED" then --Main part of the code that runs when the events happen
    sfixFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED") --Unregister the events so it doesn't spam
    C_Timer.After(rateLimit, function() UIParent:SetPoint("CENTER") sfixAnnounce() sfixFrame:RegisterEvent("DISPLAY_SIZE_CHANGED") end) --After the rateLimit amount of time, reregister the events, run the main code again, and print to the chat box
end

end)



--------------------------------------------------------------------------------
--Slash Command Handler
--------------------------------------------------------------------------------
SlashCmdList["SFIX"] = slashHandler;
