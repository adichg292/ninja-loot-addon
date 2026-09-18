local function loadAddonFile(
    path
)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile(
    "Loot/Distributions/Constants.lua"
)

loadAddonFile(
    "Loot/Config/Config.lua"
)

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "NinjaLoot addon is not initialized"
)

assert(
    addon.Loot ~= nil,
    "Loot namespace is not initialized"
)

assert(
    addon.Loot.Config ~= nil,
    "Config namespace is not initialized"
)

local Config =
    addon.Loot.Config.Config

assert(
    Config ~= nil,
    "Config is not initialized"
)

assert(
    Config.General ~= nil,
    "General config defaults are missing"
)

assert(
    Config.Loot ~= nil,
    "Loot config defaults are missing"
)

assert(
    Config.Loot.RoundRobin ~= nil,
    "Round Robin config defaults are missing"
)

assert(
    Config.General.MinimapButton == true,
    "Minimap button default should be enabled"
)

assert(
    Config.General.UIScale == 1.0,
    "UI scale default should be 1.0"
)

assert(
    Config.General.Notifications == true,
    "Notifications default should be enabled"
)

assert(
    Config.General.NotificationVerbosity
    == Config.NotificationVerbosity.NORMAL,
    "Notification verbosity default should be NORMAL"
)

assert(
    Config.General.DebugLogging == false,
    "Debug logging default should be disabled"
)

assert(
    Config.General.ConfirmDestructiveActions == true,
    "Destructive confirmations should default to enabled"
)

assert(
    Config.General.ShowDistributionHistory == true,
    "Distribution history should default to enabled"
)

assert(
    Config.General.KeepSessionHistoryDays == 30,
    "Session history retention should default to 30 days"
)

assert(
    Config.Loot.RoundRobin.RollPeriodSeconds == 20,
    "Round Robin roll period should default to 20 seconds"
)

assert(
    Config.Loot.RoundRobin.RollGracePeriodSeconds == 1,
    "Round Robin grace period should default to 1 second"
)

assert(
    Config.Loot.RoundRobin.ResultPeriodSeconds == 10,
    "Round Robin result period should default to 10 seconds"
)

assert(
    Config.Loot.RoundRobin.AnnounceMLActions == true,
    "Round Robin announcements should default to enabled"
)

assert(
    Config.Loot.RoundRobin.AllowRestartVoting == true,
    "Round Robin restart voting should default to enabled"
)

assert(
    Config.DefaultAnnouncementChannel
    == "RAID_WARNING",
    "Default announcement channel should be RAID_WARNING"
)

assert(
    Config.FixedBehavior.AutoOpenLootUI == true,
    "Auto-open loot UI should be enabled"
)

assert(
    Config.FixedBehavior.RememberSelectedTab == true,
    "Remember selected tab should be enabled"
)

assert(
    Config.FixedBehavior.RestartVoteThreshold == 4,
    "Restart vote threshold should be 4"
)

assert(
    Config.FixedBehavior.AutomaticRestart == false,
    "Automatic restart should be disabled"
)

local defaults =
    Config.GetDefaults()

assert(
    defaults ~= nil,
    "Config.GetDefaults should return defaults"
)

assert(
    defaults.General ~= nil,
    "Config.GetDefaults should contain General"
)

assert(
    defaults.Loot ~= nil,
    "Config.GetDefaults should contain Loot"
)

assert(
    defaults.Loot.RoundRobin ~= nil,
    "Config.GetDefaults should contain Round Robin"
)

assert(
    defaults.General ~= Config.General,
    "Config.GetDefaults should return a copy"
)

assert(
    defaults.Loot ~= Config.Loot,
    "Config.GetDefaults should return copied Loot defaults"
)

assert(
    defaults.Loot.RoundRobin
    ~= Config.Loot.RoundRobin,
    "Config.GetDefaults should deep-copy Round Robin defaults"
)

defaults.General.MinimapButton = false

assert(
    Config.General.MinimapButton == true,
    "Changing defaults should not modify Config.General"
)

defaults.Loot.RoundRobin.RollPeriodSeconds = 99

assert(
    Config.Loot.RoundRobin.RollPeriodSeconds == 20,
    "Changing defaults should not modify Config.Loot.RoundRobin"
)
