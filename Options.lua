--------------------------------------------
--Variables
--------------------------------------------
local addonName, SurroundFix = ...

local optionsPanel = CreateFrame("Frame", "SurroundFixOptionsPanel") --The main options panel frame
local category, layout = Settings.RegisterVerticalLayoutCategory("SurroundFix")


--------------------------------------------
--Functions
--------------------------------------------  
--Round to decimals - https://warcraft.wiki.gg/wiki/Round
local function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

local function slashHandler(msg, editBox)
    local command, xAspect, yAspect, rest = msg:match("^(%S*)%s*(%d*):?(%d*)(.-)$") --Set command to the first bit of text before whitespace, set xaspect to the first number, set yaspect to the number after a colon, and set remaining to rest

    if command == "aspect" then --If the command is aspect

        if xAspect ~= "" and yAspect ~= "" and rest == "" then --If there's a number in xAspect and yAspect, and there's nothing else

            Settings.GetSetting(addonName.."_aspectMode"):SetValue(5)
            SfixDB.XAspect = tonumber(xAspect) --Set global
            SfixDB.YAspect = tonumber(yAspect) --Set global
            UIParent:SetPoint("TOPLEFT")
            SurroundFix.sfixAnnounce()

        elseif xAspect == "" and yAspect == "" and rest ~= "" then --If the command is /sfix aspect [something]
            --If the command is /sfix aspect [something other than an aspect ratio or auto]
            print("SurroundFix - Usage: \'/sfix aspect [x:y | auto]\' - x:y sets a defined aspect ratio, or auto sets automatic detection")
        end

    elseif command == "refresh" then --If the command is refresh
        UIParent:SetPoint("TOPLEFT")
        SurroundFix.sfixAnnounce()
    elseif command == "" then
        Settings.OpenToCategory(category:GetID())
    else --If the command is /sfix [anything not defined]
        print("SurroundFix - Usage: \'/sfix [aspect | refresh]\' - Use aspect to change how the aspect ratio is calculated, or refresh to force a refresh")
    end

end


--------------------------------------------------------------------------------
--Event Registration
--------------------------------------------------------------------------------
optionsPanel:RegisterEvent("ADDON_LOADED")


--------------------------------------------------------------------------------
--Buttons
--------------------------------------------------------------------------------
local function endstopDropDown(category)

    local variable = "aspectMode"
    local name = "Select Aspect Mode"
    local description = "Select a specific aspect ratio for the UI or enable automatic detection"
    local defaultValue = 0

    local setting = Settings.RegisterAddOnSetting(category, addonName.."_"..variable, variable, SfixDB, type(defaultValue), name, defaultValue)
    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(0, "Auto", "Automatically detect the aspect ratio of the middle display")
        container:Add(1, "16:9", "Constrain the UI to a 16:9 aspect ratio")
        container:Add(2, "16:10", "Constrain the UI to a 16:10 aspect ratio")
        container:Add(3, "21:9", "Constrain the UI to a 21:9 aspect ratio")
        container:Add(4, "4:3", "Constrain the UI to a 4:3 aspect ratio")
        container:Add(5, "Custom", "Use a custom aspect ratio\nCurrently set to '"..SfixDB.XAspect..":"..SfixDB.YAspect.."'\nModify with '/sfix aspect x:y'")
        return container:GetData()
    end
    Settings.CreateDropdown(category, setting, GetOptions, description)

    Settings.GetSetting(addonName.."_"..variable):SetValueChangedCallback(function()
        print(Settings.GetSetting(addonName.."_"..variable):GetValue())
        UIParent:SetPoint("TOPLEFT")
        SurroundFix.sfixAnnounce()
    end)

end


--------------------------------------------------------------------------------
--Event Handler
--------------------------------------------------------------------------------
optionsPanel:SetScript("OnEvent", function(self, event, arg1, arg2)

    if event == "ADDON_LOADED" and arg1 == addonName then

        SfixDB = SfixDB or {}

        if not SfixDB.XAspect then SfixDB.XAspect = 16 end
        if not SfixDB.YAspect then SfixDB.YAspect = 9 end

        --Register the Options Panel in the AddOn Menu
        Settings.RegisterAddOnCategory(category)

        --Add Items
        endstopDropDown(category)

        SLASH_SFIX1, SLASH_SFIX2 = "/sfix", "/surroundfix"; --Setting the slash commands available
        SlashCmdList["SFIX"] = slashHandler;

    end

end)


--------------------------------------------------------------------------------
--Slash Command Handler
--------------------------------------------------------------------------------




