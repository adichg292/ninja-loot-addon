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
                "NinjaLootTab"
                    .. definition.key,
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
        "NinjaLootMainWindowContent",
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

function MainWindow:CreateTabPanel(name)
    local panel = CreateFrame(
        "Frame",
        name,
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
    local panel =
        self:CreateTabPanel(
            "NinjaLootRaidTab"
        )

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

    self.lootList =
        UI.Loot.LootList.New(
            panel
        )

    self.lootList.frame:SetPoint(
        "TOPLEFT",
        panel,
        "TOPLEFT",
        0,
        -350
    )

    self.raidTab = panel

    return panel
end

function MainWindow:CreateLootTab()
    local panel =
        self:CreateTabPanel(
            "NinjaLootLootTab"
        )

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
        "Loot management will appear here.\n\n"
        .. "The temporary Master Looter distribution "
        .. "window will be implemented separately."
    )

    self.lootTab = panel
    self.lootTabText = text

    return panel
end

function MainWindow:CreateHistoryTab()
    local panel =
        self:CreateTabPanel(
            "NinjaLootHistoryTab"
        )

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

    self.historyTab = panel
    self.historyTabText = text

    return panel
end

function MainWindow:CreateSettingsTab()
    local panel =
        self:CreateTabPanel(
            "NinjaLootSettingsTab"
        )

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

    text:SetText(
        "General and loot-system settings."
    )

    self.settingsTab = panel
    self.settingsTabText = text

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

    if lootManager == nil then
        self.lootTabText:SetText(
            "Loot manager is not available."
        )

        return self
    end

    local items =
        lootManager:GetLootItems()

    if items == nil
        or #items == 0
    then
        self.lootTabText:SetText(
            "No loot is currently available."
        )

        return self
    end

    local lines = {
        "Current Loot:",
        "",
    }

    for index, item in ipairs(items) do
        local state = "UNKNOWN"

        if item.GetState ~= nil then
            state =
                item:GetState()
        end

        table.insert(
            lines,
            tostring(index)
                .. ". "
                .. item:GetName()
                .. " ["
                .. tostring(state)
                .. "]"
        )
    end

    self.lootTabText:SetText(
        table.concat(
            lines,
            "\n"
        )
    )

    return self
end

function MainWindow:UpdateHistory()
    local historyManager =
        getHistoryManager()

    if historyManager == nil then
        self.historyTabText:SetText(
            "History manager is not available."
        )

        return self
    end

    local history = nil

    if historyManager.GetAll ~= nil then
        history =
            historyManager:GetAll()
    elseif historyManager.GetHistory ~= nil then
        history =
            historyManager:GetHistory()
    end

    if history == nil
        or #history == 0
    then
        self.historyTabText:SetText(
            "No distribution history."
        )

        return self
    end

    local lines = {}

    for index, entry in ipairs(history) do
        local item =
            entry.item
            or entry.itemName
            or "Unknown Item"

        local winner =
            entry.winner
            or entry.winnerName
            or "No winner"

        table.insert(
            lines,
            tostring(index)
                .. ". "
                .. tostring(item)
                .. " -> "
                .. tostring(winner)
        )
    end

    self.historyTabText:SetText(
        table.concat(
            lines,
            "\n"
        )
    )

    return self
end

function MainWindow:UpdateSettings()
    local configManager =
        getConfigManager()

    if configManager == nil then
        self.settingsTabText:SetText(
            "Configuration manager is not available."
        )

        return self
    end

    self.settingsTabText:SetText(
        "General and loot-system settings.\n\n"
        .. "Configuration is managed by the "
        .. "NinjaLoot configuration system."
    )

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
        "NinjaLootMainWindow",
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