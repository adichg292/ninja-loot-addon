local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Sessions = addon.Loot.Sessions or {}

local SessionManager = {}
SessionManager.__index = SessionManager

local function assertValidPersistence(
    persistence
)
    assert(
        persistence ~= nil,
        "Persistence is required"
    )

    assert(
        type(persistence.Save) == "function",
        "Invalid persistence"
    )

    assert(
        type(persistence.Load) == "function",
        "Invalid persistence"
    )
end

function SessionManager.New(
    persistence
)
    if persistence ~= nil then
        assertValidPersistence(
            persistence
        )
    end

    return setmetatable({
        activeSessions = {},
        history = {},
        persistence = persistence,
    }, SessionManager)
end

function SessionManager:SetPersistence(
    persistence
)
    assertValidPersistence(
        persistence
    )

    self.persistence = persistence

    return self
end

function SessionManager:Save()
    if self.persistence ~= nil then
        self.persistence:Save(
            self
        )
    end

    return self
end

function SessionManager:Restore()
    assert(
        self.persistence ~= nil,
        "Persistence is required for restore"
    )

    self.persistence:Load(
        self
    )

    return self
end

function SessionManager:Create(
    sessionId,
    lootSystem,
    masterLooter
)
    assert(
        sessionId ~= nil,
        "Session ID is required"
    )

    assert(
        self.activeSessions[sessionId] == nil,
        "Session already exists"
    )

    local session =
        addon.Loot.Sessions.Session.New(
            sessionId,
            lootSystem,
            masterLooter
        )

    self.activeSessions[sessionId] =
        session

    self:Save()

    return session
end

function SessionManager:Start(
    sessionId,
    startedAt
)
    assert(
        sessionId ~= nil,
        "Session ID is required"
    )

    local session =
        self.activeSessions[sessionId]

    assert(
        session ~= nil,
        "Cannot start unknown session"
    )

    session:Start(
        startedAt
    )

    self:Save()

    return session
end

function SessionManager:End(
    sessionId,
    endedAt
)
    assert(
        sessionId ~= nil,
        "Session ID is required"
    )

    local session =
        self.activeSessions[sessionId]

    assert(
        session ~= nil,
        "Cannot end unknown session"
    )

    session:End(
        endedAt
    )

    table.insert(
        self.history,
        session
    )

    self.activeSessions[sessionId] =
        nil

    self:Save()

    return session
end

function SessionManager:GetActive(
    sessionId
)
    if sessionId ~= nil then
        return self.activeSessions[
        sessionId
        ]
    end

    local firstSession = nil

    for _, session in pairs(
        self.activeSessions
    ) do
        if firstSession == nil then
            firstSession = session
        end
    end

    return firstSession
end

function SessionManager:GetActiveSessions()
    return self.activeSessions
end

function SessionManager:GetActiveSessionList()
    local sessions = {}

    for _, session in pairs(
        self.activeSessions
    ) do
        table.insert(
            sessions,
            session
        )
    end

    table.sort(
        sessions,
        function(left, right)
            return left:GetId()
                < right:GetId()
        end
    )

    return sessions
end

function SessionManager:GetActiveCount()
    local count = 0

    for _ in pairs(
        self.activeSessions
    ) do
        count = count + 1
    end

    return count
end

function SessionManager:GetHistory()
    return self.history
end

function SessionManager:GetHistoryEntry(
    index
)
    return self.history[index]
end

function SessionManager:GetHistoryCount()
    return #self.history
end

function SessionManager:GetSession(
    sessionId
)
    local active =
        self.activeSessions[sessionId]

    if active ~= nil then
        return active
    end

    for _, session in ipairs(
        self.history
    ) do
        if session:GetId()
            == sessionId
        then
            return session
        end
    end

    return nil
end

function SessionManager:GetAllSessions()
    local sessions = {}

    for _, session in pairs(
        self.activeSessions
    ) do
        table.insert(
            sessions,
            session
        )
    end

    for _, session in ipairs(
        self.history
    ) do
        table.insert(
            sessions,
            session
        )
    end

    return sessions
end

function SessionManager:ClearHistory()
    self.history = {}

    self:Save()

    return self
end

function SessionManager:ClearActive(
    sessionId
)
    if sessionId ~= nil then
        self.activeSessions[
        sessionId
        ] = nil
    else
        self.activeSessions = {}
    end

    self:Save()

    return self
end

addon.Loot.Sessions.SessionManager =
    SessionManager
