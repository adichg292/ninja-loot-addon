local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Components = addon.UI.Components or {}

function addon.UI.Components.CreateCloseButton(parent)
    local button = addon.UI.Components.CreateButton(
        parent,
        "NinjaLootCloseButton",
        80,
        30
    )

    button:SetPoint("BOTTOMRIGHT")

    button:SetScript("OnClick", function()
        parent:Hide()
    end)

    return button
end
