local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Sessions = addon.Loot.Sessions or {}

local SessionPersistence = {}
SessionPersistence.__index = SessionPersistence

local DATABASE_KEY =
"NinjaLootDatabase"

local function serializePlayer(
    player
)
    return {
        name = player:GetName(),
    }
end

local function serializeItem(
    item
)
    return {
        name = item:GetName(),
        itemId = item:GetId(),
        itemLink = item:GetLink(),
    }
end

local function serializeBoss(
    boss
)
    local data = {
        name = boss:GetName(),
        killedAt = boss:GetKilledAt(),
        items = {},
    }

    for _, item in ipairs(
        boss:GetItems():GetAll()
    ) do
        table.insert(
            data.items,
            serializeItem(item)
        )
    end

    return data
end

local function deserializePlayer(
    data
)
    assert(
        type(data) == "table",
        "Player data is required"
    )

    assert(
        data.name ~= nil,
        "Player name is required"
    )

    return addon.Loot.Players.Player.New(
        data.name
    )
end

local function deserializeItem(
    data
)
    assert(
        type(data) == "table",
        "Item data is required"
    )

    assert(
        data.name ~= nil,
        "Item name is required"
    )

    return addon.Loot.Items.Item.New(
        data.name,
        data.itemId,
        data.itemLink
    )
end

local function deserializeBoss(
    data
)
    assert(
        type(data) == "table",
        "Boss data is required"
    )

    assert(
        data.name ~= nil,
        "Boss name is required"
    )

    local boss =
        addon.Loot.Bosses.Boss.New(
            data.name
        )

    for _, itemData in ipairs(
        data.items or {}
    ) do
        boss:AddItem(
            deserializeItem(
                itemData
            )
        )
    end

    if data.killedAt ~= nil then
        boss:Kill(
            data.killedAt
        )
    end

    return boss
end

local function serializeResponse(
    response
)
    return {
        player =
            serializePlayer(
                response:GetPlayer()
            ),

        response =
            response:GetResponse(),

        roll =
            response:GetRoll(),

        rollSource =
            response:GetRollSource(),
    }
end

local function serializeDistribution(
    distribution
)
    local item =
        distribution:GetItem()

    local serializedItem

    if type(item) == "table"
        and getmetatable(item)
        == addon.Loot.Items.Item
    then
        serializedItem =
            serializeItem(item)
    else
        serializedItem = item
    end

    local data = {
        item = serializedItem,

        boss =
            serializeBoss(
                distribution:GetBoss()
            ),

        masterLooter =
            serializePlayer(
                distribution:GetMasterLooter()
            ),

        participants = {},

        state =
            distribution:GetState(),

        phase =
            distribution:GetPhase(),

        winner = nil,
        suggestedWinner = nil,

        selectedRoll =
            distribution:GetSelectedRoll(),

        selectedAt =
            distribution:GetSelectedAt(),

        awardedAt =
            distribution:GetAwardedAt(),

        currentAttempt =
            distribution:GetCurrentAttempt(),

        restartCount =
            distribution:GetRestartCount(),

        rerollCount =
            distribution:GetRerollCount(),

        award =
            distribution:GetAward(),
    }

    for _, player in ipairs(
        distribution:GetParticipants()
    ) do
        table.insert(
            data.participants,
            serializePlayer(player)
        )
    end

    local winner =
        distribution:GetWinner()

    if winner ~= nil then
        data.winner =
            serializePlayer(
                winner
            )
    end

    local suggestedWinner =
        distribution:GetSuggestedWinner()

    if suggestedWinner ~= nil then
        data.suggestedWinner =
            serializePlayer(
                suggestedWinner
            )
    end

    data.responses = {}

    for _, response in ipairs(
        distribution:GetResponses()
    ) do
        table.insert(
            data.responses,
            serializeResponse(
                response
            )
        )
    end

    data.resultResponses =
        distribution:GetResultResponses()

    data.attempts =
        distribution:GetAttempts()

    return data
end

local function serializeSession(
    session
)
    local data = {
        sessionId =
            session:GetId(),

        lootSystem =
            session:GetLootSystem(),

        masterLooter =
            serializePlayer(
                session:GetMasterLooter()
            ),

        state =
            session:GetLifecycle():GetState(),

        startedAt =
            session:GetStartedAt(),

        endedAt =
            session:GetEndedAt(),

        currentBoss = nil,

        players = {},
        bosses = {},
        distributions = {},
    }

    for _, player in pairs(
        session:GetPlayers().players
    ) do
        table.insert(
            data.players,
            serializePlayer(player)
        )
    end

    for _, boss in pairs(
        session:GetBosses().bosses
    ) do
        table.insert(
            data.bosses,
            serializeBoss(boss)
        )
    end

    local currentBoss =
        session:GetCurrentBoss()

    if currentBoss ~= nil then
        data.currentBoss =
            currentBoss:GetName()
    end

    for index = 1,
    session:GetDistributions():Count()
    do
        local distribution =
            session:GetDistribution(index)

        table.insert(
            data.distributions,
            serializeDistribution(
                distribution
            )
        )
    end

    return data
end

local function createSessionFromData(
    data
)
    assert(
        type(data) == "table",
        "Session data is required"
    )

    local masterLooter =
        deserializePlayer(
            data.masterLooter
        )

    local session =
        addon.Loot.Sessions.Session.New(
            data.sessionId,
            data.lootSystem,
            masterLooter
        )

    for _, playerData in ipairs(
        data.players or {}
    ) do
        session:AddPlayer(
            deserializePlayer(
                playerData
            )
        )
    end

    for _, bossData in ipairs(
        data.bosses or {}
    ) do
        session:AddBoss(
            deserializeBoss(
                bossData
            )
        )
    end

    if data.currentBoss ~= nil then
        local currentBoss =
            session:GetBoss(
                data.currentBoss
            )

        if currentBoss ~= nil then
            session:SetCurrentBoss(
                currentBoss
            )
        end
    end

    if data.state == "ACTIVE" then
        assert(
            data.startedAt ~= nil,
            "Active session is missing start time"
        )

        session:Start(
            data.startedAt
        )
    elseif data.state == "ENDED" then
        assert(
            data.startedAt ~= nil,
            "Ended session is missing start time"
        )

        assert(
            data.endedAt ~= nil,
            "Ended session is missing end time"
        )

        session:Start(
            data.startedAt
        )

        session:End(
            data.endedAt
        )
    end

    return session
end

function SessionPersistence.New()
    return setmetatable({
        database = nil,
    }, SessionPersistence)
end

function SessionPersistence:Initialize()
    if _G[DATABASE_KEY] == nil then
        _G[DATABASE_KEY] = {
            config = nil,
            activeSessions = {},
            history = {},
        }
    end

    self.database =
        _G[DATABASE_KEY]

    self.database.history =
        self.database.history
        or {}

    if self.database.activeSessions == nil then
        self.database.activeSessions = {}
    end

    if self.database.activeSession ~= nil then
        local oldSession =
            self.database.activeSession

        if oldSession.sessionId ~= nil
            and self.database.activeSessions[
            oldSession.sessionId
            ] == nil
        then
            self.database.activeSessions[
            oldSession.sessionId
            ] = oldSession
        end

        self.database.activeSession = nil
    end

    return self
end

function SessionPersistence:GetDatabase()
    assert(
        self.database ~= nil,
        "Persistence has not been initialized"
    )

    return self.database
end

function SessionPersistence:Save(
    sessionManager
)
    assert(
        sessionManager ~= nil,
        "Session manager is required"
    )

    assert(
        self.database ~= nil,
        "Persistence has not been initialized"
    )

    self.database.activeSessions = {}

    for sessionId, session in pairs(
        sessionManager:GetActiveSessions()
    ) do
        self.database.activeSessions[
        sessionId
        ] =
            serializeSession(session)
    end

    self.database.activeSession = nil

    self.database.history = {}

    for _, session in ipairs(
        sessionManager:GetHistory()
    ) do
        table.insert(
            self.database.history,
            serializeSession(session)
        )
    end

    return self
end

function SessionPersistence:SaveConfig(
    config
)
    assert(
        self.database ~= nil,
        "Persistence has not been initialized"
    )

    self.database.config =
        config

    return self
end

function SessionPersistence:Load(
    sessionManager
)
    assert(
        sessionManager ~= nil,
        "Session manager is required"
    )

    assert(
        self.database ~= nil,
        "Persistence has not been initialized"
    )

    sessionManager.activeSessions = {}
    sessionManager.history = {}

    for sessionId, sessionData in pairs(
        self.database.activeSessions
        or {}
    ) do
        local session =
            createSessionFromData(
                sessionData
            )

        sessionManager.activeSessions[
        sessionId
        ] = session
    end

    if self.database.activeSession ~= nil then
        local oldSession =
            createSessionFromData(
                self.database.activeSession
            )

        sessionManager.activeSessions[
        oldSession:GetId()
        ] = oldSession
    end

    for _, sessionData in ipairs(
        self.database.history or {}
    ) do
        table.insert(
            sessionManager.history,
            createSessionFromData(
                sessionData
            )
        )
    end

    return sessionManager
end

function SessionPersistence:SerializeSession(
    session
)
    return serializeSession(
        session
    )
end

function SessionPersistence:DeserializeSession(
    data
)
    return createSessionFromData(
        data
    )
end

function SessionPersistence:Clear()
    assert(
        self.database ~= nil,
        "Persistence has not been initialized"
    )

    self.database.config = nil
    self.database.activeSessions = {}
    self.database.activeSession = nil
    self.database.history = {}

    return self
end

addon.Loot.Sessions.SessionPersistence =
    SessionPersistence
