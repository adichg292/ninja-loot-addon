local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Components = addon.UI.Components or {}

local UI = addon.UI
local Components = UI.Components

local MainWindow = {}
MainWindow.__index = MainWindow

local function getSessionManager()
    return addon.sessionManager
end

local function getLootManager()
    return addon.lootManager
end

local function getHistoryManager()
    return addon.historyManager
end

local function getConfigManager()
    return addon.configManager
end

function MainWindow:CreateTitle()
    local title =
        self.frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        self.frame,
        "TOPLEFT",
        20,
        -15
    )

    title:SetText(
        UI.Constants.MainWindow.Title
    )

    self.title = title

    return title
end

function MainWindow:CreateCloseButton()
    local button =
        Components.CreateCloseButton(
            self.frame
        )

    button:SetPoint(
        "TOPRIGHT",
        self.frame,
        "TOPRIGHT",
        -15,
        -15
    )

    self.closeButton = button

    return button
end

function MainWindow:CreateTabs()
    self.tabs = {}

    local definitions = {
        {
            key = "Raid",
            text =
                UI.Constants.MainWindow.Tabs.Raid,
        },
        {
            key = "Loot",
            text =
                UI.Constants.MainWindow.Tabs.Loot,
        },
        {
            key = "History",
            text =
                UI.Constants.MainWindow.Tabs.History,
        },
        {
            key = "Settings",
            text =
                UI.Constants.MainWindow.Tabs.Settings,
        },
    }

    local previous = nil

    for _, definition in ipairs(definitions) do
        local button =
            Components.CreateButton(
                self.frame,
                nil,
                UI.Constants.MainWindow.TabSize.Width,
                UI.Constants.MainWindow.TabSize.Height
            )

        if previous == nil then
            button:SetPoint(
                "TOPLEFT",
                self.frame,
                "TOPLEFT",
                20,
                -55
            )
        else
            button:SetPoint(
                "LEFT",
                previous,
                "RIGHT",
                5,
                0
            )
        end

        button:SetText(
            definition.text
        )

        local tabKey =
            definition.key

        button:SetScript(
            "OnClick",
            function()
                self:SelectTab(tabKey)
            end
        )

        self.tabs[tabKey] =
            button

        previous = button
    end

    return self.tabs
end

function MainWindow:CreateContent()
    local content = CreateFrame(
        "Frame",
        nil,
        self.frame
    )

    content:SetPoint(
        "TOPLEFT",
        self.frame,
        "TOPLEFT",
        15,
        -95
    )

    content:SetPoint(
        "BOTTOMRIGHT",
        self.frame,
        "BOTTOMRIGHT",
        -15,
        15
    )

    self.content = content

    return content
end

function MainWindow:CreateTabPanel()
    local panel = CreateFrame(
        "Frame",
        nil,
        self.content
    )

    panel:SetPoint(
        "TOPLEFT",
        self.content,
        "TOPLEFT"
    )

    panel:SetPoint(
        "BOTTOMRIGHT",
        self.content,
        "BOTTOMRIGHT"
    )

    return panel
end

function MainWindow:CreateRaidTab()
    local panel = self:CreateTabPanel()

    self.sessionPanel =
        UI.Sessions.SessionPanel.New(
            panel
        )

    self.bossPanel =
        UI.Bosses.BossPanel.New(
            panel
        )

    self.bossPanel.frame:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        0,
        -220
    )

    self.bossPanel:SetAddBossHandler(function(name)
        return self:AddBoss(name)
    end)
    self.bossPanel:SetBossKilledHandler(function()
        return self:MarkBossDefeated()
    end)

    self.lootList =
        UI.Loot.LootList.New(
            panel
        )

    self.lootList.frame:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        0,
        -370
    )

    self.raidTab = panel

    return panel
end

function MainWindow:AddBoss(name)
    local sessionManager = getSessionManager()
    local session = sessionManager ~= nil
        and sessionManager:GetActive()
        or nil

    if session == nil then
        return false, "Start a session before adding a boss."
    end

    if session:GetBoss(name) ~= nil then
        return false, "A boss with that name already exists in this session."
    end

    local boss = addon.Loot.Bosses.Boss.New(name)
    session:AddBoss(boss)
    session:SetCurrentBoss(boss)

    if sessionManager.Save ~= nil then
        sessionManager:Save()
    end

    self:Refresh()
    return true, boss
end

function MainWindow:MarkBossDefeated()
    local sessionManager = getSessionManager()
    local session = sessionManager ~= nil
        and sessionManager:GetActive()
        or nil

    if session == nil or session:GetCurrentBoss() == nil then
        return false, "Add a boss before marking it defeated."
    end

    if session:IsCurrentBossKilled() then
        return false, "The current boss is already defeated."
    end

    local lootManager = getLootManager()
    if lootManager == nil then
        return false, "Loot manager is not available."
    end

    local timestamp = GetServerTime ~= nil
        and GetServerTime()
        or time()
    lootManager:PostBossLoot(timestamp)

    if sessionManager.Save ~= nil then
        sessionManager:Save()
    end

    self:Refresh()
    return true, session:GetCurrentBoss()
end

function MainWindow:CreateLootTab()
    local panel = self:CreateTabPanel()

    local title =
        panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText(
        "Loot Management"
    )

    self.lootManagementList =
        UI.Loot.LootList.New(panel)

    self.lootManagementList.frame:ClearAllPoints()
    self.lootManagementList.frame:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -12
    )

    self.lootTab = panel

    return panel
end

function MainWindow:CreateHistoryTab()
    local panel = self:CreateTabPanel()

    local title =
        panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText(
        "Distribution History"
    )

    local text =
        panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    text:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -12
    )

    text:SetJustifyH("LEFT")

    text:SetText(
        "No distribution history."
    )

    local loadMoreButton = Components.CreateButton(
        panel,
        nil,
        140,
        28
    )
    loadMoreButton:SetPoint(
        "BOTTOMRIGHT",
        panel,
        "BOTTOMRIGHT",
        -10,
        10
    )
    loadMoreButton:SetText(
        UI.Constants.MainWindow.History.LoadMore
    )
    loadMoreButton:Hide()

    self.historyTab = panel
    self.historyTabText = text
    self.historyLoadMoreButton = loadMoreButton
    self.historyOffset = 0

    loadMoreButton:SetScript("OnClick", function()
        self:LoadMoreHistory()
    end)

    return panel
end

function MainWindow:CreateSettingsTab()
    local panel = self:CreateTabPanel()

    local title =
        panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText(
        "Settings"
    )

    local text =
        panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    text:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -12
    )

    text:SetJustifyH("LEFT")

    self.settingsTab = panel
    self.settingsTabText = text
    self.settingsControls = {}

    local definitions = {
        { "General.MinimapButton", "Minimap Button", "toggle" },
        { "General.UIScale", "UI Scale", "number", 0.1, 0.5, 2.0 },
        { "General.Notifications", "Notifications", "toggle" },
        { "General.NotificationVerbosity", "Notification Verbosity", "choice" },
        { "General.DebugLogging", "Debug Logging", "toggle" },
        { "General.ConfirmDestructiveActions", "Confirm Destructive Actions", "toggle" },
        { "General.ShowDistributionHistory", "Show Distribution History", "toggle" },
        { "General.KeepSessionHistoryDays", "Keep Session History (days)", "number", 1, 1, 3650 },
        { "Loot.RoundRobin.RollPeriodSeconds", "Roll Period (seconds)", "number", 1, 1, 300 },
        { "Loot.RoundRobin.RollGracePeriodSeconds", "Roll Grace (seconds)", "number", 1, 1, 60 },
        { "Loot.RoundRobin.ResultPeriodSeconds", "Result Period (seconds)", "number", 1, 1, 300 },
        { "Loot.RoundRobin.AnnounceMLActions", "Announce Master Looter Actions", "toggle" },
        { "Loot.RoundRobin.AllowRestartVoting", "Allow Restart Voting", "toggle" },
    }

    for index, definition in ipairs(definitions) do
        local path = definition[1]
        local label = definition[2]
        local kind = definition[3]
        local step = definition[4]
        local minimum = definition[5]
        local maximum = definition[6]
        local y = -42 - ((index - 1) * 32)
        local rowLabel = panel:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )
        rowLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, y)
        rowLabel:SetText(label)

        local control = { label = label, kind = kind }
        if kind == "number" then
            local valueText = panel:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontHighlight"
            )
            valueText:SetPoint("TOPLEFT", panel, "TOPLEFT", 410, y)

            local decrease = Components.CreateButton(panel, nil, 28, 24)
            decrease:SetPoint("TOPLEFT", panel, "TOPLEFT", 370, y + 3)
            decrease:SetText("-")

            local increase = Components.CreateButton(panel, nil, 28, 24)
            increase:SetPoint("TOPLEFT", panel, "TOPLEFT", 520, y + 3)
            increase:SetText("+")

            decrease:SetScript("OnClick", function()
                local manager = getConfigManager()
                local value = manager:Get(path) - step
                if step < 1 then
                    value = math.floor(value * 10 + 0.5) / 10
                end
                if value >= minimum then
                    manager:Set(path, value)
                    self:UpdateSettings()
                end
            end)
            increase:SetScript("OnClick", function()
                local manager = getConfigManager()
                local value = manager:Get(path) + step
                if step < 1 then
                    value = math.floor(value * 10 + 0.5) / 10
                end
                if value <= maximum then
                    manager:Set(path, value)
                    self:UpdateSettings()
                end
            end)

            control.valueText = valueText
            control.decreaseButton = decrease
            control.increaseButton = increase
            control.minimum = minimum
            control.maximum = maximum
            control.step = step
        else
            local button = Components.CreateButton(panel, nil, 230, 26)
            button:SetPoint("TOPLEFT", panel, "TOPLEFT", 370, y + 2)
            button:SetScript("OnClick", function()
                local manager = getConfigManager()
                local current = manager:Get(path)
                local value

                if kind == "toggle" then
                    value = not current
                elseif current == "NORMAL" then
                    value = "DETAILED"
                else
                    value = "NORMAL"
                end

                manager:Set(path, value)
                self:UpdateSettings()
            end)

            control.button = button
        end

        control.path = path
        self.settingsControls[path] = control
    end

    local resetButton = Components.CreateButton(panel, nil, 150, 28)
    resetButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 8)
    resetButton:SetText("Reset Defaults")
    resetButton:SetScript("OnClick", function()
        local manager = getConfigManager()
        if manager ~= nil
            and manager:Get("General.ConfirmDestructiveActions")
        then
            self.settingsConfirmDialog = Components.CreateConfirmDialog(
                self.frame,
                "Reset all NinjaLoot settings to defaults?",
                function() self:ResetSettings() end
            )
            return self.settingsConfirmDialog
        end
        return self:ResetSettings()
    end)
    self.resetSettingsButton = resetButton

    return panel
end

function MainWindow:CreateTabsContent()
    self.tabPanels = {}

    self.tabPanels.Raid =
        self:CreateRaidTab()

    self.tabPanels.Loot =
        self:CreateLootTab()

    self.tabPanels.History =
        self:CreateHistoryTab()

    self.tabPanels.Settings =
        self:CreateSettingsTab()

    return self.tabPanels
end

function MainWindow:SelectTab(tabKey)
    assert(
        self.tabPanels[tabKey] ~= nil,
        "Unknown Main Window tab: "
            .. tostring(tabKey)
    )

    local configManager = getConfigManager()
    if tabKey == "History"
        and configManager ~= nil
        and not configManager:Get("General.ShowDistributionHistory")
    then
        tabKey = "Raid"
    end

    for key, panel in pairs(
        self.tabPanels
    ) do
        if key == tabKey then
            panel:Show()
        else
            panel:Hide()
        end
    end

    for key, button in pairs(
        self.tabs
    ) do
        if key == tabKey then
            button:Disable()
        else
            button:Enable()
        end
    end

    self.activeTab = tabKey

    return self
end

function MainWindow:GetActiveTab()
    return self.activeTab
end

function MainWindow:UpdateRaid()
    local sessionManager =
        getSessionManager()

    self.sessionPanel:SetSessionManager(sessionManager)

    local session = nil

    if sessionManager ~= nil then
        session =
            sessionManager:GetActive()
    end

    self.sessionPanel:Update(
        session
    )

    self.bossPanel:Update(
        session
    )

    self.lootList:Update(
        getLootManager()
    )

    return self
end

function MainWindow:UpdateLoot()
    local lootManager =
        getLootManager()

    self.lootManagementList:Update(lootManager)

    return self
end

function MainWindow:UpdateHistory()
    local historyManager =
        getHistoryManager()

    if historyManager == nil then
        self.historyTabText:SetText(
            "History manager is not available."
        )
        self.historyOffset = 0
        self.historyLoadMoreButton:Hide()

        return self
    end

    self.historyOffset = 0
    self.historyTabText:SetText("")
    self:AppendHistoryPage(historyManager)

    return self
end

local function formatHistoryEntry(entry)
    local item = entry.item or entry.itemName or "Unknown Item"
    local winner = entry.recipient
        or entry.winner
        or entry.winnerName
        or "No winner"
    local details = {
        entry.boss or "Unknown Boss",
        entry.sessionId or "Unknown Session",
    }

    if entry.awardedAt ~= nil and date ~= nil then
        table.insert(details, date("%Y-%m-%d %H:%M", entry.awardedAt))
    end

    local distribution = entry.distribution
    if distribution ~= nil then
        local award = distribution:GetAward()
        if award ~= nil and award.method ~= nil then
            table.insert(details, award.method)
        end

        local roll = distribution:GetSelectedRoll()
        if roll ~= nil then
            table.insert(details, "Roll " .. tostring(roll))
        end
    end

    return tostring(item)
        .. " -> "
        .. tostring(winner)
        .. "\n"
        .. table.concat(details, " | ")
end

function MainWindow:AppendHistoryPage(historyManager)
    local pageSize = UI.Constants.MainWindow.History.PageSize
    local page

    if historyManager.GetPage ~= nil then
        page = historyManager:GetPage(self.historyOffset, pageSize)
    else
        local all = historyManager.GetAll ~= nil
            and historyManager:GetAll()
            or historyManager:GetHistory()
        page = {}
        for index = self.historyOffset + 1,
            math.min(self.historyOffset + pageSize, #all)
        do
            table.insert(page, all[index])
        end
    end

    if page == nil or #page == 0 then
        if self.historyOffset == 0 then
            self.historyTabText:SetText(
                UI.Constants.MainWindow.History.Empty
            )
        end
        self.historyLoadMoreButton:Hide()
        return self
    end

    local lines = {}
    for index, entry in ipairs(page) do
        table.insert(
            lines,
            string.format(
                "%d. %s",
                self.historyOffset + index,
                formatHistoryEntry(entry)
            )
        )
    end

    local nextOffset = self.historyOffset + #page
    local existing = self.historyTabText:GetText()
    if existing ~= nil and existing ~= "" then
        table.insert(lines, 1, existing)
    end

    self.historyTabText:SetText(table.concat(lines, "\n\n"))

    local total = historyManager.GetTotalCount ~= nil
        and historyManager:GetTotalCount()
        or (nextOffset + (#page == pageSize and 1 or 0))

    self.historyOffset = nextOffset

    if self.historyOffset < total then
        self.historyLoadMoreButton:Show()
    else
        self.historyLoadMoreButton:Hide()
    end

    return self
end

function MainWindow:LoadMoreHistory()
    local historyManager = getHistoryManager()
    if historyManager ~= nil then
        self:AppendHistoryPage(historyManager)
    end

    return self
end

function MainWindow:UpdateSettings()
    local configManager =
        getConfigManager()

    if configManager == nil then
        self.settingsTabText:SetText(
            "Configuration manager is not available."
        )

        for _, control in pairs(self.settingsControls) do
            if control.button ~= nil then
                control.button:Hide()
            else
                control.valueText:Hide()
                control.decreaseButton:Hide()
                control.increaseButton:Hide()
            end
        end
        self.resetSettingsButton:Hide()

        return self
    end

    self.settingsTabText:SetText("")
    self.resetSettingsButton:Show()

    if self.frame.SetScale ~= nil then
        self.frame:SetScale(
            configManager:Get("General.UIScale")
        )
    end

    local showHistory = configManager:Get("General.ShowDistributionHistory")
    if showHistory then
        self.tabs.History:Show()
    else
        self.tabs.History:Hide()
        self.tabPanels.History:Hide()
        if self.activeTab == "History" then
            self:SelectTab("Raid")
        end
    end

    for _, control in pairs(self.settingsControls) do
        local value = configManager:Get(control.path)

        if control.kind == "number" then
            control.valueText:SetText(tostring(value))
            control.valueText:Show()
            control.decreaseButton:Show()
            control.increaseButton:Show()
        else
            local displayValue = control.kind == "toggle"
                and (value and "On" or "Off")
                or tostring(value)
            control.button:SetText(control.label .. ": " .. displayValue)
            control.button:Show()
        end
    end

    return self
end

function MainWindow:ResetSettings()
    local configManager = getConfigManager()
    if configManager ~= nil then
        configManager:ResetAll()
        self:UpdateSettings()
    end

    return self
end

function MainWindow:Refresh()
    self:UpdateRaid()
    self:UpdateLoot()
    self:UpdateHistory()
    self:UpdateSettings()

    return self
end

function MainWindow:UpdateTimer()
    local sessionManager =
        getSessionManager()

    local session = nil

    if sessionManager ~= nil then
        session =
            sessionManager:GetActive()
    end

    self.sessionPanel.timer:Update(
        session
    )

    return self
end

function MainWindow:Show()
    self.frame:Show()

    return self
end

function MainWindow:Hide()
    self.frame:Hide()

    return self
end

function MainWindow:IsShown()
    return self.frame:IsShown()
end

function MainWindow:GetFrame()
    return self.frame
end

local function CreateMainWindow()
    if UI.mainWindow ~= nil then
        return UI.mainWindow
    end

    local self =
        setmetatable({}, MainWindow)

    local constants =
        UI.Constants.MainWindow

    local frame = CreateFrame(
        "Frame",
        nil,
        UIParent
    )

    frame:SetSize(
        constants.Size.Width,
        constants.Size.Height
    )

    frame:SetPoint(
        "CENTER"
    )

    frame:SetMovable(true)

    self.frame = frame

    self:CreateTitle()
    self:CreateCloseButton()
    self:CreateTabs()
    self:CreateContent()
    self:CreateTabsContent()

    self:SelectTab(
        constants.Tabs.Raid
    )

    self:Refresh()

    frame:Hide()

    UI.mainWindow = self

    return self
end

UI.CreateMainWindow =
    CreateMainWindow

UI.MainWindow =
    MainWindow
