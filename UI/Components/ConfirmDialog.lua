local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Components = addon.UI.Components or {}

function addon.UI.Components.CreateConfirmDialog(
    parent,
    message,
    onConfirm,
    onCancel
)
    local dialog = CreateFrame(
        "Frame",
        nil,
        parent
    )
    dialog:SetSize(320, 120)
    dialog:SetPoint("CENTER", parent, "CENTER")
    dialog:Hide()

    dialog.message = message
    dialog.onConfirm = onConfirm
    dialog.onCancel = onCancel

    dialog.confirmButton = addon.UI.Components.CreateButton(
        dialog,
        nil,
        80,
        30
    )

    dialog.cancelButton = addon.UI.Components.CreateButton(
        dialog,
        nil,
        80,
        30
    )

    dialog.messageText = dialog:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlight"
    )
    dialog.messageText:SetPoint("TOPLEFT", dialog, "TOPLEFT", 12, -12)
    dialog.messageText:SetText(message)
    dialog.confirmButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -4, 10)
    dialog.cancelButton:SetPoint("LEFT", dialog.confirmButton, "RIGHT", 8, 0)
    dialog.confirmButton:SetText("Confirm")
    dialog.cancelButton:SetText("Cancel")

    dialog.confirmButton:SetScript("OnClick", function()
        dialog:Hide()
        if dialog.onConfirm then
            dialog.onConfirm()
        end
    end)

    dialog.cancelButton:SetScript("OnClick", function()
        dialog:Hide()
        if dialog.onCancel then
            dialog.onCancel()
        end
    end)

    dialog:Show()

    return dialog
end
