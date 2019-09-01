SurroundFix = {}

function SurroundFix:runFix()
    UIParent:SetSize(1920, 1080)
	UIParent:ClearAllPoints()
	UIParent:SetPoint("CENTER")
end

SurroundFix:runFix()
