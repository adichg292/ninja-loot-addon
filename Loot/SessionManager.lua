local addonName, addon = ...

addon.Loot = addon.Loot or {}

local SessionManager = {}
SessionManager.__index = SessionManager

function SessionManager.New()
    return setmetatable({
        activeSession = nil,
    }, SessionManager)
end

function SessionManager:Create(sessionId, lootSystem, masterLooter)
    assert(
        self.activeSession == nil,
        "Cannot create a session while another session is active"
    )

    local session = addon.Loot.Session.New(
        sessionId,
        lootSystem,
        masterLooter
    )

    self.activeSession = session

    return session
end

function SessionManager:Start(startedAt)
    assert(
        self.activeSession ~= nil,
        "Cannot start a session when no session exists"
    )

    self.activeSession:Start(startedAt)

    return self.activeSession
end

function SessionManager:End(endedAt)
    assert(
        self.activeSession ~= nil,
        "Cannot end a session when no session exists"
    )

    self.activeSession:End(endedAt)

    return self.activeSession
end

function SessionManager:GetActive()
    return self.activeSession
end

addon.Loot.SessionManager = SessionManager.New()
