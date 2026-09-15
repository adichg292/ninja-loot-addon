local addonName, addon = ...

addon.UI = addon.UI or {}

function addon.UI.CreateCloseButton(parent)
    local button = addon.UI.CreateButton(
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
