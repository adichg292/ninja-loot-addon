local addonName, addon = ...

addon.UI = addon.UI or {}

local MinimapButton = {}
MinimapButton.__index = MinimapButton

function MinimapButton.New(parent, onClick)
    if parent == nil then
        return nil
    end
    assert(type(onClick) == "function", "Minimap click handler is required")

    local button = CreateFrame("Button", nil, parent)
    button:SetSize(32, 32)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", -8, -8)
    button:SetText("NL")
    button:SetScript("OnClick", onClick)

    return setmetatable({ frame = button }, MinimapButton)
end

function MinimapButton:SetVisible(visible)
    if visible then
        self.frame:Show()
    else
        self.frame:Hide()
    end
    return self
end

addon.UI.MinimapButton = MinimapButton
