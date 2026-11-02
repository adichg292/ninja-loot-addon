local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Sessions = addon.UI.Sessions or {}

local SessionPanel = {}
SessionPanel.__index = SessionPanel
local sessionSequence = 0

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

local function getPlayerNames()
    local names = {}
    local seen = {}

    local function addName(name, realm)
        if type(name) ~= "string" or name == "" then
            return
        end

        if type(realm) == "string" and realm ~= "" then
            name = name .. "-" .. realm
        end

        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end

    if UnitName ~= nil then
        local playerName, playerRealm = UnitName("player")
        addName(playerName, playerRealm)
    end

    if IsInRaid ~= nil and IsInRaid()
        and GetNumGroupMembers ~= nil
    then
        for index = 1, GetNumGroupMembers() do
            local name, realm = nil, nil

            if UnitName ~= nil then
                name, realm = UnitName("raid" .. index)
            elseif GetRaidRosterInfo ~= nil then
                name = GetRaidRosterInfo(index)
            end

            addName(name, realm)
        end
    elseif GetNumGroupMembers ~= nil and UnitName ~= nil then
        local groupCount = GetNumGroupMembers()
        for index = 1, math.min(groupCount, 4) do
            local name, realm = UnitName("party" .. index)
            addName(name, realm)
        end
    end

    if #names == 0 then
        addName("Player")
    end

    return names
end

function SessionPanel.New(parent)
    assert(
        parent ~= nil,
        "Session panel parent is required"
    )

    local self =
        setmetatable({}, SessionPanel)

    local frame = CreateFrame(
        "Frame",
        nil,
        parent
    )

    frame:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        0
    )

    frame:SetWidth(760)
    frame:SetHeight(210)

    local title =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText("Raid")

    local sessionText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    sessionText:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -8
    )

    sessionText:SetJustifyH("LEFT")

    sessionText:SetText(
        "No active session."
    )

    self.frame = frame
    self.title = title
    self.sessionText = sessionText

    self.timer =
        addon.UI.Sessions.SessionTimer.New(
            frame
        )

    self.players =
        addon.UI.Sessions.PlayerList.New(
            frame
        )

    self.players.title:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        10,
        -95
    )

    self.players.text:SetPoint(
        "TOPLEFT",
        self.players.title,
        "BOTTOMLEFT",
        0,
        -8
    )

    local createButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        130,
        28
    )
    createButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    createButton:SetText("Start Session")

    local endButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        110,
        28
    )
    endButton:SetPoint("RIGHT", createButton, "LEFT", -6, 0)
    endButton:SetText("End Session")

    self.createButton = createButton
    self.endButton = endButton
    self.sessionManager = nil

    createButton:SetScript("OnClick", function()
        return self:StartSession()
    end)
    endButton:SetScript("OnClick", function()
        local configManager = addon.configManager
        if configManager ~= nil
            and configManager:Get("General.ConfirmDestructiveActions")
        then
            self.confirmDialog = addon.UI.Components.CreateConfirmDialog(
                self.frame,
                "End the active loot session?",
                function() self:EndSession() end
            )
            return self.confirmDialog
        end
        return self:EndSession()
    end)

    self:UpdateControls(nil)

    return self
end

function SessionPanel:SetSessionManager(sessionManager)
    self.sessionManager = sessionManager
    return self
end

function SessionPanel:UpdateControls(session)
    local hasActiveSession = session ~= nil

    if hasActiveSession then
        self.createButton:Hide()
        self.endButton:Show()
    else
        self.createButton:Show()
        self.endButton:Hide()
    end

    return self
end

function SessionPanel:StartSession()
    assert(self.sessionManager ~= nil, "Session manager is not configured")
    assert(self.sessionManager:GetActive() == nil, "A session is already active")

    local timestamp = getTimestamp()
    sessionSequence = sessionSequence + 1
    local sessionId = "NL-" .. tostring(timestamp) .. "-" .. tostring(sessionSequence)
    local names = getPlayerNames()
    local masterLooter = addon.Loot.Players.Player.New(names[1])
    local session = self.sessionManager:Create(
        sessionId,
        "RoundRobin",
        masterLooter
    )

    for index = 2, #names do
        session:AddPlayer(
            addon.Loot.Players.Player.New(names[index])
        )
    end

    self.sessionManager:Start(sessionId, timestamp)
    self:Update(session)

    return session
end

function SessionPanel:EndSession()
    assert(self.sessionManager ~= nil, "Session manager is not configured")

    local session = self.sessionManager:GetActive()
    assert(session ~= nil, "No active session to end")

    local ended = self.sessionManager:End(
        session:GetId(),
        getTimestamp()
    )

    self:Update(nil)
    return ended
end

function SessionPanel:Update(session)
    self:UpdateControls(session)

    if session == nil then
        self.sessionText:SetText(
            "No active session."
        )

        self.timer:Update(nil)
        self.players:Update(nil)

        return self
    end

    local masterLooter = session:GetMasterLooter()
    if masterLooter ~= nil and masterLooter.GetName ~= nil then
        masterLooter = masterLooter:GetName()
    end

    self.sessionText:SetText(
        "Session: "
            .. tostring(session:GetId())
            .. "\nStatus: "
            .. (session.IsActive ~= nil and session:IsActive()
                and "ACTIVE" or "SETUP")
            .. "\nSystem: "
            .. tostring(
                session:GetLootSystem()
            )
            .. "\nMaster Looter: "
            .. tostring(masterLooter)
    )

    self.timer:Update(session)
    self.players:Update(session)

    return self
end

function SessionPanel:GetFrame()
    return self.frame
end

addon.UI.Sessions.SessionPanel =
    SessionPanel
