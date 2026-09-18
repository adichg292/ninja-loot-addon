local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Config = addon.Loot.Config or {}

local Config = {}

Config.General = {
    MinimapButton = true,
    UIScale = 1.0,
    Notifications = true,
    NotificationVerbosity = "NORMAL",
    DebugLogging = false,
    ConfirmDestructiveActions = true,
    ShowDistributionHistory = true,
    KeepSessionHistoryDays = 30,
}

Config.Loot = {
    RoundRobin = {
        RollPeriodSeconds = 20,
        RollGracePeriodSeconds = 1,
        ResultPeriodSeconds = 10,
        AnnounceMLActions = true,
        AllowRestartVoting = true,
    },

    EPGP = {},
    DKP = {},
    LootCouncil = {},
    GDKP = {},
}

Config.NotificationVerbosity = {
    NORMAL = "NORMAL",
    DETAILED = "DETAILED",
}

Config.DefaultAnnouncementChannel = "RAID_WARNING"

Config.FixedBehavior = {
    AutoOpenLootUI = true,
    RememberSelectedTab = true,
    RestartVoteThreshold = 4,
    AutomaticRestart = false,
}

local function copyTable(source)
    local copy = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = copyTable(value)
        else
            copy[key] = value
        end
    end

    return copy
end

function Config.GetDefaults()
    return {
        General = copyTable(Config.General),
        Loot = copyTable(Config.Loot),
    }
end

addon.Loot.Config.Config = Config
