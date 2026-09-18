local addon = {}

local loadButton = assert(loadfile("UI/Components/Button.lua"))
loadButton("NinjaLoot", addon)

assert(addon.UI ~= nil, "UI namespace was not created")
assert(
    addon.UI.Components ~= nil,
    "UI Components namespace was not created"
)

assert(
    addon.UI.Components.CreateButton ~= nil,
    "CreateButton was not created"
)

local parent = CreateFrame("Frame", "TestParent", UIParent)

local button = addon.UI.Components.CreateButton(
    parent,
    "TestButton",
    100,
    40
)

assert(button ~= nil, "Button was not created")
assert(button.frameType == "Button", "Created frame is not a Button")
assert(button.name == "TestButton", "Button name is incorrect")
assert(button.parent == parent, "Button parent is incorrect")

assert(button.width == 100, "Button width is incorrect")
assert(button.height == 40, "Button height is incorrect")
