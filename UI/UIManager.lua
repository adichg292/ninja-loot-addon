local addonName, addon = ...

addon.UI = addon.UI or {}

local UIManager = {}
UIManager.__index = UIManager

function UIManager.New()
    return setmetatable({
        mainWindow = nil,
        mlLootWindow = nil,
        awardHandler = nil,
    }, UIManager)
end

function UIManager:Initialize()
    assert(
        addon.UI.CreateMainWindow ~= nil,
        "Main window factory is required"
    )

    assert(
        addon.UI.Distribution ~= nil,
        "Distribution UI namespace is required"
    )

    assert(
        addon.UI.Distribution.MLLootWindow ~= nil,
        "ML loot window is required"
    )

    if self.mainWindow == nil then
        self.mainWindow =
            addon.UI.CreateMainWindow()
    end

    if self.mlLootWindow == nil then
        self.mlLootWindow =
            addon.UI.Distribution.MLLootWindow.New(
                UIParent
            )
    end

    self.mlLootWindow:SetAwardHandler(
        self.awardHandler
    )

    return self
end

function UIManager:SetAwardHandler(
    handler
)
    assert(
        handler == nil
        or type(handler) == "function",
        "Award handler must be a function"
    )

    self.awardHandler = handler

    if self.mlLootWindow ~= nil then
        self.mlLootWindow:SetAwardHandler(
            handler
        )
    end

    return self
end

function UIManager:GetAwardHandler()
    return self.awardHandler
end

function UIManager:GetMainWindow()
    return self.mainWindow
end

function UIManager:GetMLLootWindow()
    return self.mlLootWindow
end

function UIManager:ShowDistribution(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        self.mlLootWindow ~= nil,
        "ML loot window is not initialized"
    )

    self.mlLootWindow:SetDistribution(
        distribution
    )

    self.mlLootWindow:Show()

    return self
end

function UIManager:UpdateDistribution(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        self.mlLootWindow ~= nil,
        "ML loot window is not initialized"
    )

    self.mlLootWindow:SetDistribution(
        distribution
    )

    return self
end

function UIManager:RefreshMainWindow()
    if self.mainWindow ~= nil then
        self.mainWindow:Refresh()
    end

    return self
end

function UIManager:HideDistribution()
    if self.mlLootWindow ~= nil then
        self.mlLootWindow:Hide()
    end

    return self
end

function UIManager:IsDistributionShown()
    return self.mlLootWindow ~= nil
        and self.mlLootWindow:IsShown()
end

addon.UI.UIManager = UIManager