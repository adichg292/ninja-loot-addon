local addon = {}

local loadButton = assert(loadfile("UI/Components/Button.lua"))
loadButton("NinjaLoot", addon)

local loadConfirmDialog = assert(
    loadfile("UI/Components/ConfirmDialog.lua")
)
loadConfirmDialog("NinjaLoot", addon)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Components ~= nil,
    "UI Components namespace was not created"
)

assert(
    addon.UI.Components.CreateConfirmDialog ~= nil,
    "CreateConfirmDialog was not created"
)

local parent = CreateFrame(
    "Frame",
    "TestParent",
    UIParent
)

local confirmed = false
local cancelled = false

local dialog = addon.UI.Components.CreateConfirmDialog(
    parent,
    "Are you sure?",
    function()
        confirmed = true
    end,
    function()
        cancelled = true
    end
)

assert(
    dialog ~= nil,
    "Confirm dialog was not created"
)

assert(
    dialog.parent == parent,
    "Confirm dialog parent is incorrect"
)

assert(
    dialog.message == "Are you sure?",
    "Confirm dialog message is incorrect"
)

assert(
    dialog.confirmButton ~= nil,
    "Confirm button was not created"
)

assert(
    dialog.cancelButton ~= nil,
    "Cancel button was not created"
)

dialog.confirmButton:Click()

assert(
    confirmed == true,
    "Confirm callback was not called"
)

assert(
    cancelled == false,
    "Cancel callback should not have been called"
)

dialog.cancelButton:Click()

assert(
    cancelled == true,
    "Cancel callback was not called"
)
