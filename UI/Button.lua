local addonName, addon = ...

addon.UI = addon.UI or {}

function addon.UI.CreateButton(parent, name, width, height)
    local button = CreateFrame("Button", name, parent)

    button:SetSize(width, height)

    return button
end
