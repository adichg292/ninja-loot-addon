local addonName, addon = ...

addon.UI = addon.UI or {}

function addon.UI.CreateMainWindow()
    local frame = CreateFrame(
        "Frame",
        "NinjaLootMainFrame",
        UIParent
    )

    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:Hide()

    frame.closeButton = addon.UI.CreateCloseButton(frame)

    return frame
end
