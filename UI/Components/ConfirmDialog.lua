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
        "NinjaLootConfirmDialog",
        parent
    )

    dialog.message = message
    dialog.onConfirm = onConfirm
    dialog.onCancel = onCancel

    dialog.confirmButton = addon.UI.Components.CreateButton(
        dialog,
        "NinjaLootConfirmButton",
        80,
        30
    )

    dialog.cancelButton = addon.UI.Components.CreateButton(
        dialog,
        "NinjaLootCancelButton",
        80,
        30
    )

    dialog.confirmButton:SetScript("OnClick", function()
        if dialog.onConfirm then
            dialog.onConfirm()
        end
    end)

    dialog.cancelButton:SetScript("OnClick", function()
        if dialog.onCancel then
            dialog.onCancel()
        end
    end)

    return dialog
end
