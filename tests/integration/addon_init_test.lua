local function loadAddonFile(
    path
)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile(
    "Core.lua"
)

loadAddonFile(
    "Loot/Players/Player.lua"
)

loadAddonFile(
    "Loot/Players/PlayerManager.lua"
)

loadAddonFile(
    "Loot/Bosses/Boss.lua"
)

loadAddonFile(
    "Loot/Bosses/BossManager.lua"
)

loadAddonFile(
    "Loot/Lifecycles/Lifecycle.lua"
)

loadAddonFile(
    "Loot/Distributions/Constants.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionResponse.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionPhase.lua"
)

loadAddonFile(
    "Loot/Distributions/Distribution.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionManager.lua"
)

loadAddonFile(
    "Loot/Distributions/AwardService.lua"
)

loadAddonFile(
    "Loot/Distributions/WoWAwardHandler.lua"
)

loadAddonFile(
    "Loot/Config/Config.lua"
)

loadAddonFile(
    "Loot/Config/ConfigManager.lua"
)

loadAddonFile(
    "Loot/History/HistoryManager.lua"
)

loadAddonFile(
    "Loot/Sessions/Session.lua"
)

loadAddonFile(
    "Loot/Sessions/SessionManager.lua"
)

loadAddonFile(
    "Loot/Sessions/SessionPersistence.lua"
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

loadAddonFile(
    "UI/Components/ConfirmDialog.lua"
)

loadAddonFile(
    "UI/MainWindow.lua"
)

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table should exist"
)

assert(
    addon.name ~= nil,
    "Addon name should be initialized"
)

assert(
    addon.Loot ~= nil,
    "Loot namespace should exist"
)

assert(
    addon.Loot.Players ~= nil,
    "Players namespace should exist"
)

assert(
    addon.Loot.Bosses ~= nil,
    "Bosses namespace should exist"
)

assert(
    addon.Loot.Lifecycles ~= nil,
    "Lifecycles namespace should exist"
)

assert(
    addon.Loot.Distributions ~= nil,
    "Distributions namespace should exist"
)

assert(
    addon.Loot.Sessions ~= nil,
    "Sessions namespace should exist"
)

assert(
    addon.Loot.Config ~= nil,
    "Config namespace should exist"
)

assert(
    addon.Loot.Config.Config ~= nil,
    "Config should be initialized"
)

assert(
    addon.Loot.Config.ConfigManager ~= nil,
    "ConfigManager should be initialized"
)

assert(
    addon.UI ~= nil,
    "UI namespace should exist"
)

assert(
    addon.UI.Constants ~= nil,
    "UI Constants should exist"
)

assert(
    addon.UI.Components ~= nil,
    "UI Components should exist"
)

assert(
    addon.UI.CreateMainWindow ~= nil,
    "Main window factory should exist"
)

assert(
    addon.Events ~= nil,
    "Event namespace should exist"
)

assert(
    addon.Events.Frame ~= nil,
    "Event frame should exist"
)

assert(
    addon.Events.Frame.events.CHAT_MSG_SYSTEM == true,
    "CHAT_MSG_SYSTEM should be registered"
)

assert(
    addon.Events.Frame.scripts.OnEvent ~= nil,
    "Event frame should have an OnEvent handler"
)
