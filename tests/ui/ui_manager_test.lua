local addon = {}

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

local loadMLLootWindow = assert(
    loadfile(
        "UI/Distribution/MLLootWindow.lua"
    )
)

loadMLLootWindow(
    "NinjaLoot",
    addon
)

assert(loadfile("UI/MinimapButton.lua"))("NinjaLoot", addon)
local previousMinimap = Minimap
Minimap = CreateFrame("Frame", nil, UIParent)

local loadUIManager = assert(
    loadfile("UI/UIManager.lua")
)

local mainWindowShown = false
local createdMainWindow = {
    IsShown = function() return mainWindowShown end,
    Show = function() mainWindowShown = true end,
    Hide = function() mainWindowShown = false end,
}

addon.UI.CreateMainWindow =
    function()
        return createdMainWindow
    end

loadUIManager(
    "NinjaLoot",
    addon
)

assert(
    addon.UI.UIManager ~= nil,
    "UIManager was not created"
)

local manager =
    addon.UI.UIManager.New()

assert(
    manager ~= nil,
    "UIManager instance was not created"
)

manager:Initialize()

assert(manager.minimapButton.frame:IsShown(),
    "Minimap button should initialize visible by default")
manager.minimapButton.frame:GetScript("OnClick")()
assert(mainWindowShown, "Minimap click should open the main window")
manager.minimapButton.frame:GetScript("OnClick")()
assert(not mainWindowShown, "Minimap click should toggle the main window closed")
manager:SetMinimapButtonVisible(false)
assert(not manager.minimapButton.frame:IsShown(),
    "Minimap setting should hide the button")
Minimap = previousMinimap

assert(
    manager:GetMainWindow()
        == createdMainWindow,
    "Main window was not initialized"
)

assert(
    manager:GetMLLootWindow() ~= nil,
    "ML loot window was not initialized"
)

local handlerCalled = false

local awardHandler =
    function(distribution)
        handlerCalled = true

        assert(
            distribution ~= nil,
            "Distribution should be passed to award handler"
        )

        return true
    end

manager:SetAwardHandler(
    awardHandler
)

assert(
    manager:GetAwardHandler()
        == awardHandler,
    "Award handler was not stored"
)

assert(
    manager:GetMLLootWindow():
        GetAwardHandler()
        == awardHandler,
    "Award handler was not passed to ML loot window"
)

local tradeHandler = function() return nil end
manager:SetTradeHandler(tradeHandler)
assert(manager:GetTradeHandler() == tradeHandler,
    "Trade handler should be stored")
assert(manager:GetMLLootWindow():GetTradeHandler() == tradeHandler,
    "Trade handler should be passed to ML loot window")

local distribution = {
    GetItem = function()
        return {
            GetName = function()
                return "Test Item"
            end,
        }
    end,

    GetBoss = function()
        return {
            GetName = function()
                return "Test Boss"
            end,
        }
    end,

    GetPhase = function()
        return "AWARD_PENDING"
    end,

    GetCurrentAttempt = function()
        return 1
    end,

    GetRollParticipants = function()
        return {}
    end,

    IsAwardPending = function()
        return true
    end,
}

manager:ShowDistribution(
    distribution
)

assert(
    manager:GetMLLootWindow():
        GetDistribution()
        == distribution,
    "Distribution was not assigned"
)

assert(
    manager:IsDistributionShown(),
    "Distribution window should be visible"
)

local awardResult =
    manager:GetMLLootWindow():Award()

assert(
    awardResult,
    "Award action should return handler result"
)

assert(
    handlerCalled,
    "Award handler should be invoked"
)

manager:UpdateDistribution(
    distribution
)

assert(
    manager:GetMLLootWindow():
        GetDistribution()
        == distribution,
    "Distribution should remain assigned after update"
)

manager:HideDistribution()

assert(
    not manager:IsDistributionShown(),
    "Distribution window should be hidden"
)
