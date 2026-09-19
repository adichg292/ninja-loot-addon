local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Sessions = addon.UI.Sessions or {}

local SessionPanel = {}
SessionPanel.__index = SessionPanel

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

    return self
end

function SessionPanel:Update(session)
    if session == nil then
        self.sessionText:SetText(
            "No active session."
        )

        self.timer:Update(nil)
        self.players:Update(nil)

        return self
    end

    self.sessionText:SetText(
        "Session: "
            .. tostring(session:GetId())
            .. "\nSystem: "
            .. tostring(
                session:GetLootSystem()
            )
            .. "\nMaster Looter: "
            .. tostring(
                session:GetMasterLooter()
            )
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