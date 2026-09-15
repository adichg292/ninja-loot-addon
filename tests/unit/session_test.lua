local addon = {}

local loadSession = assert(loadfile("Loot/Session.lua"))
loadSession("NinjaLoot", addon)

assert(addon.Loot ~= nil, "Loot namespace was not created")
assert(addon.Loot.Session ~= nil, "Session was not created")

local Session = addon.Loot.Session

assert(
    Session.States.SETUP == "SETUP",
    "SETUP state is incorrect"
)

assert(
    Session.States.ACTIVE == "ACTIVE",
    "ACTIVE state is incorrect"
)

assert(
    Session.States.ENDED == "ENDED",
    "ENDED state is incorrect"
)

local session = Session.New(
    "session-001",
    "ROUND_ROBIN",
    "TestPlayer"
)

assert(session.sessionId == "session-001", "Session ID is incorrect")
assert(session.state == Session.States.SETUP, "Initial state is incorrect")
assert(session.lootSystem == "ROUND_ROBIN", "Loot system is incorrect")
assert(
    session.masterLooter == "TestPlayer",
    "Master looter is incorrect"
)

assert(session.startedAt == nil, "Session should not have started yet")
assert(session.endedAt == nil, "Session should not have ended yet")

assert(session.raidInfo == nil, "Raid info should start empty")
assert(#session.players == 0, "Players should start empty")
assert(#session.bosses == 0, "Bosses should start empty")
assert(#session.distributions == 0, "Distributions should start empty")

session:Start(100)

assert(
    session.state == Session.States.ACTIVE,
    "Session should be ACTIVE after Start"
)

assert(
    session.startedAt == 100,
    "Session start time is incorrect"
)

session:End(200)

assert(
    session.state == Session.States.ENDED,
    "Session should be ENDED after End"
)

assert(
    session.endedAt == 200,
    "Session end time is incorrect"
)

print("Session unit tests passed!")
