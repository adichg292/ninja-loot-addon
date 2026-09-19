local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Sessions = addon.UI.Sessions or {}

local SessionTimer = {}
SessionTimer.__index = SessionTimer

local function formatDuration(seconds)
    seconds = math.max(
        0,
        math.floor(seconds or 0)
    )

    local hours = math.floor(
        seconds / 3600
    )

    local minutes = math.floor(
        (seconds % 3600) / 60
    )

    local remainingSeconds =
        seconds % 60

    return string.format(
        "%02d:%02d:%02d",
        hours,
        minutes,
        remainingSeconds
    )
end

function SessionTimer.New(parent)
    assert(
        parent ~= nil,
        "Session timer parent is required"
    )

    local self =
        setmetatable({}, SessionTimer)

    local frame = CreateFrame(
        "Frame",
        nil,
        parent
    )

    frame:SetPoint(
        "TOPRIGHT",
        parent,
        "TOPRIGHT",
        -10,
        -10
    )

    frame:SetWidth(220)
    frame:SetHeight(30)

    local text =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    text:SetPoint(
        "TOPRIGHT",
        frame,
        "TOPRIGHT"
    )

    text:SetText(
        "Session Time: 00:00:00"
    )

    self.frame = frame
    self.text = text

    return self
end

function SessionTimer:Update(session)
    if session == nil then
        self.text:SetText(
            "Session Time: 00:00:00"
        )

        return self
    end

    local startedAt =
        session:GetStartedAt()

    local endedAt =
        session:GetEndedAt()

    if startedAt == nil then
        self.text:SetText(
            "Session Time: 00:00:00"
        )

        return self
    end

    local currentTime = time()

    local endTime =
        endedAt or currentTime

    local elapsed =
        math.max(
            0,
            endTime - startedAt
        )

    self.text:SetText(
        "Session Time: "
            .. formatDuration(elapsed)
    )

    return self
end

function SessionTimer:GetText()
    return self.text:GetText()
end

function SessionTimer:GetFrame()
    return self.frame
end

addon.UI.Sessions.SessionTimer =
    SessionTimer