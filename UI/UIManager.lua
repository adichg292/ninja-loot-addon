local addonName, addon = ...

addon.UI = addon.UI or {}

local UIManager = {}
UIManager.__index = UIManager

function UIManager.New()
    return setmetatable({
        mainWindow = nil,
        mlLootWindow = nil,
        awardHandler = nil,
        tradeHandler = nil,
        responseHandler = nil,
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

    if self.minimapButton == nil and addon.UI.MinimapButton ~= nil
        and Minimap ~= nil
    then
        self.minimapButton = addon.UI.MinimapButton.New(
            Minimap,
            function()
                if self.mainWindow:IsShown() then
                    self.mainWindow:Hide()
                else
                    self.mainWindow:Show()
                end
            end
        )
    end

    self.mlLootWindow:SetAwardHandler(
        self.awardHandler
    )
    self.mlLootWindow:SetTradeHandler(self.tradeHandler)
    self.mlLootWindow:SetResponseHandler(
        self.responseHandler
    )
    if self.minimapButton ~= nil then
        self.minimapButton:SetVisible(
            addon.configManager == nil
                or addon.configManager:Get("General.MinimapButton")
        )
    end

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

function UIManager:SetTradeHandler(handler)
    assert(handler == nil or type(handler) == "function",
        "Trade handler must be a function")
    self.tradeHandler = handler
    if self.mlLootWindow ~= nil then
        self.mlLootWindow:SetTradeHandler(handler)
    end
    return self
end

function UIManager:GetTradeHandler()
    return self.tradeHandler
end

function UIManager:SetResponseHandler(handler)
    assert(
        handler == nil or type(handler) == "function",
        "Response handler must be a function"
    )

    self.responseHandler = handler
    if self.mlLootWindow ~= nil then
        self.mlLootWindow:SetResponseHandler(handler)
    end

    return self
end

function UIManager:GetResponseHandler()
    return self.responseHandler
end

function UIManager:SetMinimapButtonVisible(visible)
    if self.minimapButton ~= nil then
        self.minimapButton:SetVisible(visible)
    end
    return self
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
