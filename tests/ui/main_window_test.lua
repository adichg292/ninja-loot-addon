local addon = {}

local loadButton = assert(loadfile("UI/Button.lua"))
loadButton("NinjaLoot", addon)

local loadCloseButton = assert(loadfile("UI/CloseButton.lua"))
loadCloseButton("NinjaLoot", addon)

local loadMainWindow = assert(loadfile("UI/MainWindow.lua"))
loadMainWindow("NinjaLoot", addon)

assert(addon.UI ~= nil, "UI namespace was not created")
assert(
    addon.UI.CreateMainWindow ~= nil,
    "CreateMainWindow was not created"
)

local mainFrame = addon.UI.CreateMainWindow()

assert(mainFrame ~= nil, "Main window was not created")
assert(
    mainFrame.frameType == "Frame",
    "Main window is not a Frame"
)

assert(
    mainFrame.name == "NinjaLootMainFrame",
    "Main window name is incorrect"
)

assert(
    mainFrame.parent == UIParent,
    "Main window parent is incorrect"
)

assert(
    mainFrame.width == 400,
    "Main window width is incorrect"
)

assert(
    mainFrame.height == 300,
    "Main window height is incorrect"
)

assert(
    mainFrame.point == "CENTER",
    "Main window position is incorrect"
)

assert(
    mainFrame:IsShown() == false,
    "Main window should start hidden"
)

assert(
    mainFrame.closeButton ~= nil,
    "Main window close button was not created"
)

mainFrame:Show()

assert(
    mainFrame:IsShown() == true,
    "Main window should be visible after Show()"
)

mainFrame.closeButton:Click()

assert(
    mainFrame:IsShown() == false,
    "Main window should be hidden after clicking Close"
)

print("Main window UI tests passed!")
