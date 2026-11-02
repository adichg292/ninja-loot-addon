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

assert(loadfile("UI/Components/ConfirmDialog.lua"))(
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

local historyEntries = {}
for index = 1, 12 do
    historyEntries[index] = {
        item = "Item " .. tostring(index),
        recipient = "Winner " .. tostring(index),
        boss = "Boss " .. tostring(index),
        sessionId = "SESSION-" .. tostring(index),
        awardedAt = 1000 + index,
    }
end

addon.historyManager = {
    GetTotalCount = function()
        return #historyEntries
    end,

    GetPage = function(_, offset, limit)
        local page = {}
        for index = offset + 1, math.min(offset + limit, #historyEntries) do
            table.insert(page, historyEntries[index])
        end
        return page
    end,
}

firstWindow:UpdateHistory()
assert(
    string.find(firstWindow.historyTabText:GetText(), "Item 1 -> Winner 1", 1, true) ~= nil,
    "History should display the item recipient"
)
assert(
    string.find(firstWindow.historyTabText:GetText(), "Boss 1 | SESSION-1", 1, true) ~= nil,
    "History should display boss and session details"
)
assert(
    firstWindow.historyLoadMoreButton:IsShown(),
    "History should offer more pages when entries remain"
)

firstWindow.historyLoadMoreButton:GetScript("OnClick")()
assert(
    string.find(firstWindow.historyTabText:GetText(), "Item 12 -> Winner 12", 1, true) ~= nil,
    "Load More should append the next history page"
)
assert(
    not firstWindow.historyLoadMoreButton:IsShown(),
    "Load More should hide after the last history page"
)

firstWindow.tabs.Settings:Click()

assert(
    firstWindow:GetActiveTab()
    == "Settings",
    "Settings tab was not activated"
)

local settingValues = {
    ["General.MinimapButton"] = true,
    ["General.UIScale"] = 1.0,
    ["General.Notifications"] = true,
    ["General.NotificationVerbosity"] = "NORMAL",
    ["General.DebugLogging"] = false,
    ["General.ConfirmDestructiveActions"] = true,
    ["General.ShowDistributionHistory"] = true,
    ["General.KeepSessionHistoryDays"] = 30,
    ["Loot.RoundRobin.RollPeriodSeconds"] = 20,
    ["Loot.RoundRobin.RollGracePeriodSeconds"] = 1,
    ["Loot.RoundRobin.ResultPeriodSeconds"] = 10,
    ["Loot.RoundRobin.AnnounceMLActions"] = true,
    ["Loot.RoundRobin.AllowRestartVoting"] = true,
}

local function copySettingValues()
    local copy = {}
    for path, value in pairs(settingValues) do
        copy[path] = value
    end
    return copy
end
local defaultSettingValues = copySettingValues()

addon.configManager = {
    Get = function(_, path)
        return settingValues[path]
    end,

    Set = function(_, path, value)
        settingValues[path] = value
    end,

    ResetAll = function()
        settingValues = {}
        for path, value in pairs(defaultSettingValues) do
            settingValues[path] = value
        end
    end,
}

firstWindow:UpdateSettings()
settingValues["General.ShowDistributionHistory"] = false
firstWindow:UpdateSettings()
assert(not firstWindow.tabs.History:IsShown(),
    "Disabling distribution history should hide its tab")
firstWindow:SelectTab("History")
assert(firstWindow:GetActiveTab() == "Raid",
    "Hidden distribution history should not be selectable")
settingValues["General.ShowDistributionHistory"] = true
firstWindow:UpdateSettings()
assert(firstWindow.tabs.History:IsShown(),
    "Enabling distribution history should restore its tab")
assert(
    firstWindow.settingsControls["General.Notifications"].button:GetText()
        == "Notifications: On",
    "Boolean settings should show their current value"
)
firstWindow.settingsControls["General.Notifications"].button:GetScript("OnClick")()
assert(
    settingValues["General.Notifications"] == false,
    "Boolean setting control should save the toggled value"
)
assert(
    firstWindow.settingsControls["General.Notifications"].button:GetText()
        == "Notifications: Off",
    "Boolean setting control should refresh after saving"
)

firstWindow.settingsControls["General.UIScale"].increaseButton:GetScript("OnClick")()
assert(
    settingValues["General.UIScale"] == 1.1
        and firstWindow.frame:GetScale() == 1.1,
    "UI scale control should persist and apply its value"
)

settingValues["General.Notifications"] = false
local resetDialog = firstWindow.resetSettingsButton:GetScript("OnClick")()
assert(resetDialog:IsShown(), "Reset Defaults should request confirmation")
resetDialog.confirmButton:Click()
assert(
    settingValues["General.Notifications"] == true,
    "Reset Defaults should restore configuration values"
)

local currentBoss = nil
local bossPlayer = { GetName = function() return "Master" end }
local session = {
    GetBoss = function(_, name)
        if currentBoss ~= nil and currentBoss:GetName() == name then
            return currentBoss
        end
        return nil
    end,
    AddBoss = function(_, boss)
        currentBoss = boss
    end,
    SetCurrentBoss = function(_, boss)
        currentBoss = boss
    end,
    GetCurrentBoss = function()
        return currentBoss
    end,
    IsCurrentBossKilled = function()
        return currentBoss ~= nil and currentBoss.killed == true
    end,
    GetId = function() return "BOSS-SESSION" end,
    GetLootSystem = function() return "RoundRobin" end,
    GetMasterLooter = function() return bossPlayer end,
    IsActive = function() return true end,
    GetStartedAt = function() return 1 end,
    GetEndedAt = function() return nil end,
    GetPlayers = function()
        return { GetAll = function() return { bossPlayer } end }
    end,
}
local savedBossSession = 0
addon.sessionManager = {
    GetActive = function() return session end,
    Save = function() savedBossSession = savedBossSession + 1 end,
}
addon.Loot = {
    Bosses = {
        Boss = {
            New = function(name)
                return {
                    name = name,
                    killed = false,
                    GetName = function(self) return self.name end,
                    IsKilled = function(self) return self.killed end,
                    GetItems = function()
                        return { Count = function() return 0 end }
                    end,
                }
            end,
        },
    },
}
addon.lootManager = {
    GetLootItems = function() return {} end,
    PostBossLoot = function(_, killedAt)
        assert(killedAt ~= nil, "Boss kill should be timestamped")
        currentBoss.killed = true
        return {}
    end,
}

firstWindow.bossPanel.bossNameInput:SetText("Test Encounter")
firstWindow.bossPanel.addBossButton:Click()
assert(
    currentBoss ~= nil
        and currentBoss:GetName() == "Test Encounter",
    "Boss UI should add and select the new encounter"
)
assert(
    firstWindow.bossPanel.bossKilledButton:IsShown(),
    "Newly added boss should be markable as defeated"
)

firstWindow.bossPanel.bossKilledButton:Click()
assert(
    currentBoss.killed
        and not firstWindow.bossPanel.bossKilledButton:IsShown(),
    "Mark Defeated should record the boss kill"
)
assert(
    savedBossSession == 2,
    "Adding and defeating a boss should persist the session"
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
