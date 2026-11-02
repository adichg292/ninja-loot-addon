local addon = {}
assert(loadfile("UI/MinimapButton.lua"))("NinjaLoot", addon)

local parent = CreateFrame("Frame", nil, UIParent)
local clicks = 0
local button = addon.UI.MinimapButton.New(parent, function()
    clicks = clicks + 1
end)

assert(button ~= nil and button.frame:IsShown() ~= true,
    "Minimap button should be created without forcing visibility")
button:SetVisible(true)
assert(button.frame:IsShown(), "Visible setting should show the minimap button")
button.frame:GetScript("OnClick")()
assert(clicks == 1, "Minimap click should call its handler")
button:SetVisible(false)
assert(not button.frame:IsShown(), "Hidden setting should hide the minimap button")
