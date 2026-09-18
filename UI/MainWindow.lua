local addonName, addon = ...

addon.UI = addon.UI or {}

local Config =
    addon.Loot.Config.Config

local Constants =
    addon.UI.Constants.MainWindow

local MainWindow = {}

local function createTab(
    parent,
    name,
    text
)
    local button =
        addon.UI.Components.CreateButton(
            parent,
            name,
            Constants.TabSize.Width,
            Constants.TabSize.Height
        )

    button:SetText(text)

    return button
end

local function createPanel(
    parent
)
    local panel = CreateFrame(
        "Frame",
        nil,
        parent
    )

    panel:SetSize(
        Constants.PanelSize.Width,
        Constants.PanelSize.Height
    )

    panel:SetPoint(
        "TOPLEFT"
    )

    panel:Hide()

    return panel
end

local function createSettingButton(
    parent,
    name,
    text,
    onClick
)
    local button =
        addon.UI.Components.CreateButton(
            parent,
            name,
            Constants.SettingButtonSize.Width,
            Constants.SettingButtonSize.Height
        )

    button:SetText(text)

    button:SetScript(
        "OnClick",
        onClick
    )

    return button
end

local function formatBoolean(
    value
)
    if value then
        return "On"
    end

    return "Off"
end

local function createGeneralPanel(
    parent
)
    local panel =
        createPanel(parent)

    panel.settings = {}

    local config =
        addon.configManager

    local function refresh()
        panel.settings.minimap:SetText(
            Constants.General.MinimapButton
            .. ": "
            .. formatBoolean(
                config:Get(
                    "General.MinimapButton"
                )
            )
        )

        panel.settings.scale:SetText(
            Constants.General.UIScale
            .. ": "
            .. tostring(
                config:Get(
                    "General.UIScale"
                )
            )
        )

        panel.settings.notifications:SetText(
            Constants.General.Notifications
            .. ": "
            .. formatBoolean(
                config:Get(
                    "General.Notifications"
                )
            )
        )

        panel.settings.verbosity:SetText(
            Constants.General.NotificationVerbosity
            .. ": "
            .. config:Get(
                "General.NotificationVerbosity"
            )
        )

        panel.settings.debug:SetText(
            Constants.General.DebugLogging
            .. ": "
            .. formatBoolean(
                config:Get(
                    "General.DebugLogging"
                )
            )
        )

        panel.settings.confirm:SetText(
            Constants.General.ConfirmDestructiveActions
            .. ": "
            .. formatBoolean(
                config:Get(
                    "General.ConfirmDestructiveActions"
                )
            )
        )

        panel.settings.history:SetText(
            Constants.General.ShowDistributionHistory
            .. ": "
            .. formatBoolean(
                config:Get(
                    "General.ShowDistributionHistory"
                )
            )
        )

        panel.settings.keepHistory:SetText(
            Constants.General.KeepSessionHistory
            .. ": "
            .. tostring(
                config:Get(
                    "General.KeepSessionHistoryDays"
                )
            )
            .. " days"
        )
    end

    panel.settings.minimap =
        createSettingButton(
            panel,
            "NinjaLootGeneralMinimap",
            "",
            function()
                config:Set(
                    "General.MinimapButton",
                    not config:Get(
                        "General.MinimapButton"
                    )
                )

                refresh()
            end
        )

    panel.settings.scale =
        createSettingButton(
            panel,
            "NinjaLootGeneralScale",
            "",
            function()
                local current =
                    config:Get(
                        "General.UIScale"
                    )

                local nextValue =
                    current + 0.1

                if nextValue > 2.0 then
                    nextValue = 0.5
                end

                config:Set(
                    "General.UIScale",
                    nextValue
                )

                refresh()
            end
        )

    panel.settings.notifications =
        createSettingButton(
            panel,
            "NinjaLootGeneralNotifications",
            "",
            function()
                config:Set(
                    "General.Notifications",
                    not config:Get(
                        "General.Notifications"
                    )
                )

                refresh()
            end
        )

    panel.settings.verbosity =
        createSettingButton(
            panel,
            "NinjaLootGeneralVerbosity",
            "",
            function()
                local current =
                    config:Get(
                        "General.NotificationVerbosity"
                    )

                local nextValue =
                    Config.NotificationVerbosity.DETAILED

                if current
                    == Config.NotificationVerbosity.DETAILED
                then
                    nextValue =
                        Config.NotificationVerbosity.NORMAL
                end

                config:Set(
                    "General.NotificationVerbosity",
                    nextValue
                )

                refresh()
            end
        )

    panel.settings.debug =
        createSettingButton(
            panel,
            "NinjaLootGeneralDebug",
            "",
            function()
                config:Set(
                    "General.DebugLogging",
                    not config:Get(
                        "General.DebugLogging"
                    )
                )

                refresh()
            end
        )

    panel.settings.confirm =
        createSettingButton(
            panel,
            "NinjaLootGeneralConfirm",
            "",
            function()
                config:Set(
                    "General.ConfirmDestructiveActions",
                    not config:Get(
                        "General.ConfirmDestructiveActions"
                    )
                )

                refresh()
            end
        )

    panel.settings.history =
        createSettingButton(
            panel,
            "NinjaLootGeneralHistory",
            "",
            function()
                config:Set(
                    "General.ShowDistributionHistory",
                    not config:Get(
                        "General.ShowDistributionHistory"
                    )
                )

                refresh()
            end
        )

    panel.settings.keepHistory =
        createSettingButton(
            panel,
            "NinjaLootGeneralKeepHistory",
            "",
            function()
                local current =
                    config:Get(
                        "General.KeepSessionHistoryDays"
                    )

                local nextValue =
                    current + 30

                if nextValue > 3650 then
                    nextValue = 30
                end

                config:Set(
                    "General.KeepSessionHistoryDays",
                    nextValue
                )

                refresh()
            end
        )

    refresh()

    return panel
end

local function createLootPanel(
    parent
)
    local panel =
        createPanel(parent)

    panel.systemPanels = {}
    panel.systemTabs = {}

    local systems = {
        {
            key = Constants.Systems.RoundRobin,
            text = Constants.Loot.Systems.RoundRobin,
        },
        {
            key = Constants.Systems.EPGP,
            text = Constants.Loot.Systems.EPGP,
        },
        {
            key = Constants.Systems.DKP,
            text = Constants.Loot.Systems.DKP,
        },
        {
            key = Constants.Systems.LootCouncil,
            text = Constants.Loot.Systems.LootCouncil,
        },
        {
            key = Constants.Systems.GDKP,
            text = Constants.Loot.Systems.GDKP,
        },
    }

    local function showSystem(
        systemKey
    )
        for key, systemPanel in pairs(
            panel.systemPanels
        ) do
            if key == systemKey then
                systemPanel:Show()
            else
                systemPanel:Hide()
            end
        end
    end

    for _, system in ipairs(
        systems
    ) do
        local button =
            createTab(
                panel,
                "NinjaLootLootTab"
                .. system.key,
                system.text
            )

        button:SetPoint(
            "TOPLEFT"
        )

        panel.systemTabs[
        system.key
        ] = button

        button:SetScript(
            "OnClick",
            function()
                showSystem(
                    system.key
                )
            end
        )
    end

    local roundRobin =
        createPanel(panel)

    roundRobin:SetPoint(
        "TOPLEFT"
    )

    panel.systemPanels[
    Constants.Systems.RoundRobin
    ] = roundRobin

    local config =
        addon.configManager

    local function refresh()
        roundRobin.rollPeriod:SetText(
            Constants.Loot.RoundRobin.RollPeriod
            .. ": "
            .. tostring(
                config:Get(
                    "Loot.RoundRobin.RollPeriodSeconds"
                )
            )
            .. " sec"
        )

        roundRobin.gracePeriod:SetText(
            Constants.Loot.RoundRobin.GracePeriod
            .. ": "
            .. tostring(
                config:Get(
                    "Loot.RoundRobin.RollGracePeriodSeconds"
                )
            )
            .. " sec"
        )

        roundRobin.resultPeriod:SetText(
            Constants.Loot.RoundRobin.ResultPeriod
            .. ": "
            .. tostring(
                config:Get(
                    "Loot.RoundRobin.ResultPeriodSeconds"
                )
            )
            .. " sec"
        )

        roundRobin.announce:SetText(
            Constants.Loot.RoundRobin.Announce
            .. ": "
            .. formatBoolean(
                config:Get(
                    "Loot.RoundRobin.AnnounceMLActions"
                )
            )
        )

        roundRobin.restart:SetText(
            Constants.Loot.RoundRobin.Restart
            .. ": "
            .. formatBoolean(
                config:Get(
                    "Loot.RoundRobin.AllowRestartVoting"
                )
            )
        )
    end

    roundRobin.rollPeriod =
        createSettingButton(
            roundRobin,
            "NinjaLootRRRollPeriod",
            "",
            function()
                local values = {
                    5,
                    10,
                    15,
                    20,
                    25,
                    30,
                    45,
                    60,
                }

                local current =
                    config:Get(
                        "Loot.RoundRobin.RollPeriodSeconds"
                    )

                local nextValue =
                    values[1]

                for index, value in ipairs(
                    values
                ) do
                    if value == current then
                        nextValue =
                            values[
                            index + 1
                            ]
                            or values[1]

                        break
                    end
                end

                config:Set(
                    "Loot.RoundRobin.RollPeriodSeconds",
                    nextValue
                )

                refresh()
            end
        )

    roundRobin.gracePeriod =
        createSettingButton(
            roundRobin,
            "NinjaLootRRGracePeriod",
            "",
            function()
                local current =
                    config:Get(
                        "Loot.RoundRobin.RollGracePeriodSeconds"
                    )

                local nextValue = 1

                if current == 1 then
                    nextValue = 2
                elseif current == 2 then
                    nextValue = 3
                end

                config:Set(
                    "Loot.RoundRobin.RollGracePeriodSeconds",
                    nextValue
                )

                refresh()
            end
        )

    roundRobin.resultPeriod =
        createSettingButton(
            roundRobin,
            "NinjaLootRRResultPeriod",
            "",
            function()
                local current =
                    config:Get(
                        "Loot.RoundRobin.ResultPeriodSeconds"
                    )

                local nextValue = 5

                if current == 5 then
                    nextValue = 10
                elseif current == 10 then
                    nextValue = 15
                elseif current == 15 then
                    nextValue = 20
                end

                config:Set(
                    "Loot.RoundRobin.ResultPeriodSeconds",
                    nextValue
                )

                refresh()
            end
        )

    roundRobin.announce =
        createSettingButton(
            roundRobin,
            "NinjaLootRRAnnounce",
            "",
            function()
                config:Set(
                    "Loot.RoundRobin.AnnounceMLActions",
                    not config:Get(
                        "Loot.RoundRobin.AnnounceMLActions"
                    )
                )

                refresh()
            end
        )

    roundRobin.restart =
        createSettingButton(
            roundRobin,
            "NinjaLootRRRestart",
            "",
            function()
                config:Set(
                    "Loot.RoundRobin.AllowRestartVoting",
                    not config:Get(
                        "Loot.RoundRobin.AllowRestartVoting"
                    )
                )

                refresh()
            end
        )

    refresh()

    local emptyPanels = {
        [
        Constants.Systems.EPGP
        ] = Constants.Loot.Placeholder.EPGP,

        [
        Constants.Systems.DKP
        ] = Constants.Loot.Placeholder.DKP,

        [
        Constants.Systems.LootCouncil
        ] = Constants.Loot.Placeholder.LootCouncil,

        [
        Constants.Systems.GDKP
        ] = Constants.Loot.Placeholder.GDKP,
    }

    for key, text in pairs(
        emptyPanels
    ) do
        local systemPanel =
            createPanel(panel)

        systemPanel.message =
            text

        panel.systemPanels[key] =
            systemPanel
    end

    showSystem(
        Constants.Systems.RoundRobin
    )

    return panel
end

local function createHistoryPanel(
    parent
)
    local panel =
        createPanel(parent)

    panel.offset = 0
    panel.pageSize =
        Constants.History.PageSize

    panel.rows = {}

    local function itemText(
        entry
    )
        local item = entry.item

        if type(item) == "table" then
            if item.link ~= nil then
                return item.link
            end

            if item.name ~= nil then
                return item.name
            end
        end

        return tostring(item)
    end

    local function refresh()
        for _, row in ipairs(
            panel.rows
        ) do
            row:Hide()
        end

        local entries =
            addon.historyManager:GetPage(
                panel.offset,
                panel.pageSize
            )

        for index, entry in ipairs(
            entries
        ) do
            local row =
                panel.rows[index]

            if row == nil then
                row =
                    addon.UI.Components.CreateButton(
                        panel,
                        "NinjaLootHistoryRow"
                        .. tostring(index),
                        Constants.History.RowSize.Width,
                        Constants.History.RowSize.Height
                    )

                panel.rows[index] =
                    row
            end

            row:SetText(
                string.format(
                    Constants.History.RowFormat,
                    itemText(entry),
                    entry.recipient,
                    entry.boss
                )
            )

            row:Show()
        end

        local nextButton =
            panel.nextButton

        if addon.historyManager:GetTotalCount()
            > panel.offset + panel.pageSize
        then
            nextButton:Show()

            nextButton:SetText(
                Constants.History.LoadMore
            )
        else
            nextButton:Hide()
        end
    end

    panel.nextButton =
        addon.UI.Components.CreateButton(
            panel,
            "NinjaLootHistoryLoadMore",
            Constants.HistoryLoadMoreSize.Width,
            Constants.HistoryLoadMoreSize.Height
        )

    panel.nextButton:SetText(
        Constants.History.LoadMore
    )

    panel.nextButton:SetScript(
        "OnClick",
        function()
            panel.offset =
                panel.offset
                + panel.pageSize

            refresh()
        end
    )

    refresh()

    return panel
end

function MainWindow.Create()
    if addon.UI.MainWindow ~= nil then
        return addon.UI.MainWindow
    end

    local frame = CreateFrame(
        "Frame",
        "NinjaLootMainFrame",
        UIParent
    )

    frame:SetSize(
        Constants.Size.Width,
        Constants.Size.Height
    )

    frame:SetPoint(
        "CENTER"
    )

    frame:Hide()

    frame.closeButton =
        addon.UI.Components.CreateCloseButton(
            frame
        )

    frame.tabs = {}

    frame.generalPanel =
        createGeneralPanel(frame)

    frame.lootPanel =
        createLootPanel(frame)

    frame.historyPanel =
        createHistoryPanel(frame)

    frame.tabs.general =
        createTab(
            frame,
            "NinjaLootGeneralTab",
            Constants.Tabs.General
        )

    frame.tabs.loot =
        createTab(
            frame,
            "NinjaLootLootTab",
            Constants.Tabs.Loot
        )

    frame.tabs.history =
        createTab(
            frame,
            "NinjaLootHistoryTab",
            Constants.Tabs.History
        )

    local function showTab(
        tabName
    )
        frame.generalPanel:Hide()
        frame.lootPanel:Hide()
        frame.historyPanel:Hide()

        if tabName == "general" then
            frame.generalPanel:Show()
        elseif tabName == "loot" then
            frame.lootPanel:Show()
        elseif tabName == "history" then
            frame.historyPanel:Show()
        end
    end

    frame.tabs.general:SetScript(
        "OnClick",
        function()
            showTab("general")
        end
    )

    frame.tabs.loot:SetScript(
        "OnClick",
        function()
            showTab("loot")
        end
    )

    frame.tabs.history:SetScript(
        "OnClick",
        function()
            showTab("history")
        end
    )

    showTab("general")

    addon.UI.MainWindow = frame

    return frame
end

addon.UI.CreateMainWindow =
    MainWindow.Create
