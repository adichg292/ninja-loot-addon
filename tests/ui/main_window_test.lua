local function loadAddonFile(
    path
)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile(
    "Loot/Config/Config.lua"
)

loadAddonFile(
    "UI/Constants.lua"
)

loadAddonFile(
    "UI/Components/Button.lua"
)

loadAddonFile(
    "UI/Components/CloseButton.lua"
)

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "NinjaLoot addon is not initialized"
)

addon.configManager = {
    Get = function(
        self,
        path
    )
        local defaults =
            addon.Loot.Config.Config.GetDefaults()

        local current =
            defaults

        for part in string.gmatch(
            path,
            "[^%.]+"
        ) do
            current = current[part]
        end

        return current
    end,

    Set = function()
    end,
}

addon.historyManager = {
    GetPage = function()
        return {}
    end,

    GetTotalCount = function()
        return 0
    end,
}

loadAddonFile(
    "UI/MainWindow.lua"
)

assert(
    addon.UI ~= nil,
    "addon.UI was not created"
)

assert(
    addon.UI.Constants ~= nil,
    "addon.UI.Constants was not created"
)

assert(
    addon.UI.CreateMainWindow ~= nil,
    "CreateMainWindow was not created"
)

assert(
    addon.UI.Components ~= nil,
    "addon.UI.Components was not created"
)

local constants =
    addon.UI.Constants.MainWindow

local frame =
    addon.UI.CreateMainWindow()

assert(
    frame ~= nil,
    "MainWindow.Create did not return a frame"
)

assert(
    frame == addon.UI.MainWindow,
    "MainWindow was not stored on addon.UI.MainWindow"
)

assert(
    frame:GetWidth()
    == constants.Size.Width,
    "MainWindow width does not match Constants"
)

assert(
    frame:GetHeight()
    == constants.Size.Height,
    "MainWindow height does not match Constants"
)

assert(
    frame.closeButton ~= nil,
    "MainWindow closeButton was not created"
)

assert(
    frame.tabs ~= nil,
    "MainWindow tabs were not created"
)

assert(
    frame.tabs.general ~= nil,
    "General tab was not created"
)

assert(
    frame.tabs.loot ~= nil,
    "Loot tab was not created"
)

assert(
    frame.tabs.history ~= nil,
    "History tab was not created"
)

assert(
    frame.tabs.general:GetText()
    == constants.Tabs.General,
    "General tab text does not match Constants"
)

assert(
    frame.tabs.loot:GetText()
    == constants.Tabs.Loot,
    "Loot tab text does not match Constants"
)

assert(
    frame.tabs.history:GetText()
    == constants.Tabs.History,
    "History tab text does not match Constants"
)

assert(
    frame.generalPanel ~= nil,
    "General panel was not created"
)

assert(
    frame.lootPanel ~= nil,
    "Loot panel was not created"
)

assert(
    frame.historyPanel ~= nil,
    "History panel was not created"
)

assert(
    frame:IsShown() == false,
    "MainWindow should initially be hidden"
)

assert(
    frame.generalPanel:IsShown() == true,
    "General panel should initially be shown"
)

assert(
    frame.lootPanel:IsShown() == false,
    "Loot panel should initially be hidden"
)

assert(
    frame.historyPanel:IsShown() == false,
    "History panel should initially be hidden"
)

frame.tabs.loot:Click()

assert(
    frame.generalPanel:IsShown() == false,
    "General panel should be hidden after selecting Loot"
)

assert(
    frame.lootPanel:IsShown() == true,
    "Loot panel should be shown after selecting Loot"
)

assert(
    frame.historyPanel:IsShown() == false,
    "History panel should remain hidden after selecting Loot"
)

frame.tabs.history:Click()

assert(
    frame.generalPanel:IsShown() == false,
    "General panel should remain hidden after selecting History"
)

assert(
    frame.lootPanel:IsShown() == false,
    "Loot panel should be hidden after selecting History"
)

assert(
    frame.historyPanel:IsShown() == true,
    "History panel should be shown after selecting History"
)

frame.tabs.general:Click()

assert(
    frame.generalPanel:IsShown() == true,
    "General panel should be shown after selecting General"
)

assert(
    frame.lootPanel:IsShown() == false,
    "Loot panel should be hidden after selecting General"
)

assert(
    frame.historyPanel:IsShown() == false,
    "History panel should be hidden after selecting General"
)

local secondFrame =
    addon.UI.CreateMainWindow()

assert(
    secondFrame == frame,
    "CreateMainWindow should return the existing MainWindow"
)
