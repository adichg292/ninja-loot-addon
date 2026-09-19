local addon = {}

local loadSessionTimer = assert(
    loadfile("UI/Sessions/SessionTimer.lua")
)

loadSessionTimer(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Sessions ~= nil,
    "UI.Sessions namespace was not created"
)

assert(
    addon.UI.Sessions.SessionTimer ~= nil,
    "SessionTimer was not created"
)

local parent = CreateFrame(
    "Frame",
    "NinjaLootSessionTimerTestParent"
)

local timer =
    addon.UI.Sessions.SessionTimer.New(
        parent
    )

assert(
    timer ~= nil,
    "Session timer was not created"
)

assert(
    timer.frame ~= nil,
    "Session timer frame was not created"
)

assert(
    timer.text ~= nil,
    "Session timer text was not created"
)

assert(
    timer.frame.parent == parent,
    "Session timer parent is incorrect"
)

assert(
    timer:GetText()
    == "Session Time: 00:00:00",
    "Initial timer text is incorrect"
)

local session = {
    GetStartedAt = function()
        return 100
    end,

    GetEndedAt = function()
        return nil
    end,
}

local oldTime = time

time = function()
    return 125
end

timer:Update(session)

assert(
    timer:GetText()
    == "Session Time: 00:00:25",
    "Active session duration is incorrect"
)

time = function()
    return 200
end

session.GetEndedAt = function()
    return 150
end

timer:Update(session)

assert(
    timer:GetText()
    == "Session Time: 00:00:50",
    "Ended session duration is incorrect"
)

timer:Update(nil)

assert(
    timer:GetText()
    == "Session Time: 00:00:00",
    "Timer should display zero with no session"
)

time = oldTime
