local addon = {}

local loadConstants = assert(
    loadfile("UI/Constants.lua")
)

loadConstants(
    "NinjaLoot",
    addon
)

local loadButton = assert(
    loadfile("UI/Components/Button.lua")
)

loadButton(
    "NinjaLoot",
    addon
)

local loadCloseButton = assert(
    loadfile("UI/Components/CloseButton.lua")
)

loadCloseButton(
    "NinjaLoot",
    addon
)

local loadSessionTimer = assert(
    loadfile("UI/Sessions/SessionTimer.lua")
)

loadSessionTimer(
    "NinjaLoot",
    addon
)

local loadPlayerList = assert(
    loadfile("UI/Sessions/PlayerList.lua")
)

loadPlayerList(
    "NinjaLoot",
    addon
)

local loadSessionPanel = assert(
    loadfile("UI/Sessions/SessionPanel.lua")
)

loadSessionPanel(
    "NinjaLoot",
    addon
)

local loadBossPanel = assert(
    loadfile("UI/Bosses/BossPanel.lua")
)

loadBossPanel(
    "NinjaLoot",
    addon
)

local loadLootList = assert(
    loadfile("UI/Loot/LootList.lua")
)

loadLootList(
    "NinjaLoot",
    addon
)

local loadMainWindow = assert(
    loadfile("UI/MainWindow.lua")
)

loadMainWindow(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.CreateMainWindow ~= nil,
    "CreateMainWindow was not created"
)

local firstWindow =
    addon.UI.CreateMainWindow()

assert(
    firstWindow ~= nil,
    "Main window was not created"
)

assert(
    firstWindow.frame ~= nil,
    "Main window frame was not created"
)

assert(
    firstWindow.frame:GetWidth() == 800,
    "Main window width is incorrect"
)

assert(
    firstWindow.frame:GetHeight() == 600,
    "Main window height is incorrect"
)

assert(
    firstWindow.title ~= nil,
    "Main window title was not created"
)

assert(
    firstWindow.title:GetText()
    == "NinjaLoot",
    "Main window title is incorrect"
)

assert(
    firstWindow.closeButton ~= nil,
    "Main window close button was not created"
)

assert(
    firstWindow.tabs ~= nil,
    "Main window tabs were not created"
)

assert(
    firstWindow.tabs.Raid ~= nil,
    "Raid tab was not created"
)

assert(
    firstWindow.tabs.Loot ~= nil,
    "Loot tab was not created"
)

assert(
    firstWindow.tabs.History ~= nil,
    "History tab was not created"
)

assert(
    firstWindow.tabs.Settings ~= nil,
    "Settings tab was not created"
)

assert(
    firstWindow.tabPanels ~= nil,
    "Main window tab panels were not created"
)

assert(
    firstWindow.tabPanels.Raid ~= nil,
    "Raid tab panel was not created"
)

assert(
    firstWindow.tabPanels.Loot ~= nil,
    "Loot tab panel was not created"
)

assert(
    firstWindow.tabPanels.History ~= nil,
    "History tab panel was not created"
)

assert(
    firstWindow.tabPanels.Settings ~= nil,
    "Settings tab panel was not created"
)

assert(
    firstWindow:GetActiveTab()
    == "Raid",
    "Raid should be the initial active tab"
)

assert(
    firstWindow:IsShown() == false,
    "Main window should start hidden"
)

local secondWindow =
    addon.UI.CreateMainWindow()

assert(
    secondWindow == firstWindow,
    "CreateMainWindow should return the existing window"
)

firstWindow:Show()

assert(
    firstWindow:IsShown() == true,
    "Main window should be visible after Show"
)

firstWindow.tabs.Loot:Click()

assert(
    firstWindow:GetActiveTab()
    == "Loot",
    "Loot tab was not activated"
)

assert(
    firstWindow.tabPanels.Loot:IsShown()
    == true,
    "Loot panel should be visible"
)

assert(
    firstWindow.tabPanels.Raid:IsShown()
    == false,
    "Raid panel should be hidden"
)

firstWindow.tabs.History:Click()

assert(
    firstWindow:GetActiveTab()
    == "History",
    "History tab was not activated"
)

firstWindow.tabs.Settings:Click()

assert(
    firstWindow:GetActiveTab()
    == "Settings",
    "Settings tab was not activated"
)

firstWindow.tabs.Raid:Click()

assert(
    firstWindow:GetActiveTab()
    == "Raid",
    "Raid tab was not activated"
)

firstWindow:Hide()

assert(
    firstWindow:IsShown() == false,
    "Main window should be hidden after Hide"
)