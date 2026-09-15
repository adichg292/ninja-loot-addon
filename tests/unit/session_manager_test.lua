local addon = {}

local loadSession = assert(loadfile("Loot/Session.lua"))
loadSession("NinjaLoot", addon)

local loadSessionManager = assert(loadfile("Loot/SessionManager.lua"))
loadSessionManager("NinjaLoot", addon)

assert(
    addon.Loot.SessionManager ~= nil,
    "SessionManager was not created"
)

local manager = addon.Loot.SessionManager.New()

assert(
    manager:GetActive() == nil,
    "Manager should not have an active session initially"
)

local session = manager:Create(
    "session-001",
    "ROUND_ROBIN",
    "TestPlayer"
)

assert(
    manager:GetActive() == session,
    "Manager should return the created session"
)

assert(
    session.state == addon.Loot.Session.States.SETUP,
    "Created session should be in SETUP state"
)

manager:Start(100)

assert(
    session.state == addon.Loot.Session.States.ACTIVE,
    "Session should be ACTIVE after manager Start"
)

assert(
    session.startedAt == 100,
    "Session start time is incorrect"
)

manager:End(200)

assert(
    session.state == addon.Loot.Session.States.ENDED,
    "Session should be ENDED after manager End"
)

assert(
    session.endedAt == 200,
    "Session end time is incorrect"
)

assert(
    manager:GetActive() == session,
    "Manager should still reference the ended session"
)

print("Session manager unit tests passed!")
