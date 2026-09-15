local addonName, addon = ...

addon.Loot = addon.Loot or {}

local Session = {}
Session.__index = Session

Session.States = {
    NOT_INITIALIZED = "NOT_INITIALIZED",
    SETUP = "SETUP",
    ACTIVE = "ACTIVE",
    ENDED = "ENDED",
}

function Session.New(sessionId, lootSystem, masterLooter)
    assert(sessionId ~= nil, "Session ID is required")
    assert(lootSystem ~= nil, "Loot system is required")
    assert(masterLooter ~= nil, "Master looter is required")

    local session = setmetatable({
        sessionId = sessionId,
        state = Session.States.SETUP,
        lootSystem = lootSystem,
        masterLooter = masterLooter,
        startedAt = nil,
        endedAt = nil,
        raidInfo = nil,
        players = {},
        bosses = {},
        distributions = {},
    }, Session)

    return session
end

function Session:Start(startedAt)
    assert(
        self.state == Session.States.SETUP,
        "Only a session in SETUP state can be started"
    )

    self.state = Session.States.ACTIVE
    self.startedAt = startedAt
end

function Session:End(endedAt)
    assert(
        self.state == Session.States.ACTIVE,
        "Only an active session can be ended"
    )

    self.state = Session.States.ENDED
    self.endedAt = endedAt
end

addon.Loot.Session = Session
