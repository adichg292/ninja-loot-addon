local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Components = addon.UI.Components or {}

function addon.UI.Components.CreateButton(
    parent,
    name,
    width,
    height
)
    local button = CreateFrame(
        "Button",
        name,
        parent
    )

    button:SetSize(
        width,
        height
    )

    return button
end
