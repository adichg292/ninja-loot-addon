local addon = {}

local loadButton = assert(
    loadfile("UI/Components/Button.lua")
)
loadButton("NinjaLoot", addon)

local loadCloseButton = assert(
    loadfile("UI/Components/CloseButton.lua")
)
loadCloseButton("NinjaLoot", addon)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Components ~= nil,
    "UI Components namespace was not created"
)

assert(
    addon.UI.Components.CreateCloseButton ~= nil,
    "CreateCloseButton was not created"
)

local parent = CreateFrame(
    "Frame",
    "TestParent",
    UIParent
)

local closeButton = addon.UI.Components.CreateCloseButton(parent)

assert(
    closeButton ~= nil,
    "Close button was not created"
)

assert(
    closeButton.frameType == "Button",
    "Close button is not a Button"
)

assert(
    closeButton.name == "NinjaLootCloseButton",
    "Close button name is incorrect"
)

assert(
    closeButton.parent == parent,
    "Close button parent is incorrect"
)

assert(
    closeButton.width == 80,
    "Close button width is incorrect"
)

assert(
    closeButton.height == 30,
    "Close button height is incorrect"
)

assert(
    closeButton.point == "BOTTOMRIGHT",
    "Close button position is incorrect"
)

parent:Show()

assert(
    parent:IsShown() == true,
    "Parent should be visible before clicking close"
)

closeButton:Click()

assert(
    parent:IsShown() == false,
    "Parent should be hidden after clicking close"
)
