local addonName, addon = ...

addon.UI = addon.UI or {}

addon.UI.Constants = {
    MainWindow = {
        Title = "NinjaLoot",

        Size = {
            Width = 600,
            Height = 420,
        },

        PanelSize = {
            Width = 560,
            Height = 340,
        },

        TabSize = {
            Width = 110,
            Height = 30,
        },

        SettingButtonSize = {
            Width = 360,
            Height = 30,
        },

        HistoryRowSize = {
            Width = 520,
            Height = 30,
        },

        HistoryLoadMoreSize = {
            Width = 160,
            Height = 30,
        },

        Tabs = {
            General = "General",
            Loot = "Loot",
            History = "History",
        },

        Buttons = {
            Close = "Close",
            StartSession = "Start Session",
            EndSession = "End Session",
            StartDistribution = "Start Distribution",
            Restart = "Restart",
            Accept = "Accept",
            Confirm = "Confirm",
            Cancel = "Cancel",
            LoadMore = "Load More",
        },

        General = {
            Title = "General Settings",

            MinimapButton = "Minimap Button",
            UIScale = "UI Scale",
            Notifications = "Notifications",
            NotificationVerbosity = "Notification Verbosity",
            DebugLogging = "Debug Logging",
            ConfirmDestructiveActions = "Confirm Destructive Actions",
            ShowDistributionHistory = "Show Distribution History",
            KeepSessionHistory = "Keep Session History",
        },

        Loot = {
            Title = "Loot Settings",

            Systems = {
                RoundRobin = "Round Robin",
                EPGP = "EPGP",
                DKP = "DKP",
                LootCouncil = "Loot Council",
                GDKP = "GDKP",
            },

            RoundRobin = {
                Title = "Round Robin Settings",
                RollPeriod = "Roll Period",
                GracePeriod = "Roll Grace Period",
                ResultPeriod = "Result Period",
                Announce = "Announce ML Actions",
                Restart = "Allow Restart Voting",
            },

            Placeholder = {
                EPGP = "EPGP configuration will be added later.",
                DKP = "DKP configuration will be added later.",
                LootCouncil = "Loot Council configuration will be added later.",
                GDKP = "GDKP configuration will be added later.",
            },
        },

        History = {
            Title = "Distribution History",
            Empty = "No distribution history.",
            LoadMore = "Load 10 More",
            Item = "Item",
            Winner = "Winner",
            Date = "Date",

            PageSize = 10,

            RowFormat = "%s  ->  %s  |  %s",
        },

        Systems = {
            RoundRobin = "RoundRobin",
            EPGP = "EPGP",
            DKP = "DKP",
            LootCouncil = "LootCouncil",
            GDKP = "GDKP",
        },
    },
}
