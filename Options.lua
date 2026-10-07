--------------------------------------------
--Variables
--------------------------------------------
local addonName, SurroundFix = ...

local optionsPanel = CreateFrame("Frame", "SurroundFixOptionsPanel") --The main options panel frame
local optionsCategory, layout = Settings.RegisterVerticalLayoutCategory("SurroundFix")


--------------------------------------------
--Functions
--------------------------------------------  
--Round to decimals - https://warcraft.wiki.gg/wiki/Round
local function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

local function slashHandler(msg, editBox)
    local command, xAspect, yAspect, rest = msg:match("^(%S*)%s*(%d*):?(%d*)(.-)$") --Set command to the first bit of text before whitespace, set xaspect to the first number, set yaspect to the number after a colon, and set remaining to rest
    local aspectMode = Settings.GetSetting(addonName.."_aspectMode")

    if command == "aspect" then --If the command is aspect

        if xAspect ~= "" and yAspect ~= "" and rest == "" then --If there's a number in xAspect and yAspect, and there's nothing else

            SfixDB.customXAspect = tonumber(xAspect) --Set global
            SfixDB.customYAspect = tonumber(yAspect) --Set global
            aspectMode:SetValue(1) --Set mode to custom

        elseif xAspect == "" and yAspect == "" and rest ~= "" then --If the command is /sfix aspect [something]
            if rest == "auto" then --If the command is /sfix aspect [auto]
                aspectMode:SetValue(0) --Set mode to auto
                print("SurroundFix - Auto mode enabled")
            else --If the command is /sfix aspect [something other than an aspect ratio or auto]
                print("SurroundFix - Usage: \'/sfix aspect [x:y | auto]\' - x:y sets a defined aspect ratio, or auto sets automatic detection")
            end            
        end

    elseif command == "refresh" then --If the command is refresh
        UIParent:SetPoint(UIParent:GetPoint())
        SurroundFix.sfixAnnounce()
    elseif command == "" then
        Settings.OpenToCategory(optionsCategory:GetID())
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
local function aspectDropDown(category)

    local variable = "aspectMode"
    local name = "Select Aspect Mode"
    local description = "Select a specific aspect ratio for the UI or enable automatic detection"
    local defaultValue = 0

    local setting = Settings.RegisterAddOnSetting(category, addonName.."_"..variable, variable, SfixDB, type(defaultValue), name, defaultValue)
    local function GetOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add(0, "Auto", "Automatically detect the aspect ratio of the middle display")
        container:Add(1, "Custom", "Use a custom aspect ratio\nModify with '/sfix aspect x:y'\nCurrently set to '"..SfixDB.customXAspect..":"..SfixDB.customYAspect.."'")
        container:Add(2, "16:9", "Constrain the UI to a 16:9 aspect ratio")
        container:Add(3, "16:10", "Constrain the UI to a 16:10 aspect ratio")
        container:Add(4, "21:9", "Constrain the UI to a 21:9 aspect ratio")
        container:Add(5, "4:3", "Constrain the UI to a 4:3 aspect ratio")
        return container:GetData()
    end
    Settings.CreateDropdown(category, setting, GetOptions, description)

    Settings.GetSetting(addonName.."_"..variable):SetValueChangedCallback(function()
        UIParent:SetPoint(UIParent:GetPoint())
        SurroundFix.sfixAnnounce()
    end)

end

local function screenshotCheckbox(category)

    local variable = "restrictScreenshot"
    local name = "Restrict Screenshot"
    local description = "Restrict screenshots to the width of the UI instead of the full width"
    local defaultValue = true

    local setting = Settings.RegisterAddOnSetting(category, addonName.."_"..variable, variable, SfixDB, type(defaultValue), name, defaultValue)
    Settings.CreateCheckbox(category, setting, description)

    Settings.GetSetting(addonName.."_"..variable):SetValueChangedCallback(function()
        SurroundFix.restrictScreenshot()
    end)

end


--------------------------------------------------------------------------------
--Event Handler
--------------------------------------------------------------------------------
optionsPanel:SetScript("OnEvent", function(self, event, arg1, arg2)

    if event == "ADDON_LOADED" and arg1 == addonName then

        --Initialise savedVariables
        SfixDB = SfixDB or {}
        if not SfixDB.customXAspect then SfixDB.customXAspect = 16 end
        if not SfixDB.customYAspect then SfixDB.customYAspect = 9 end

        --Register the Options Panel in the AddOn Menu
        Settings.RegisterAddOnCategory(optionsCategory)

        --Add Items
        aspectDropDown(optionsCategory)
        screenshotCheckbox(optionsCategory)

        --Initialise slash commands
        SLASH_SFIX1, SLASH_SFIX2 = "/sfix", "/surroundfix";
        SlashCmdList["SFIX"] = slashHandler;

    end

end)

