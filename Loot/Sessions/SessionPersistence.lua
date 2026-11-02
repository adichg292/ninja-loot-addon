local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Sessions = addon.Loot.Sessions or {}

local SessionPersistence = {}
SessionPersistence.__index = SessionPersistence

local DATABASE_KEY =
"NinjaLootDatabase"

local CURRENT_SCHEMA_VERSION = 1

SessionPersistence.SchemaVersion = CURRENT_SCHEMA_VERSION

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
        lootQuantity = item:GetLootQuantity(),
        lootQuality = item:GetLootQuality(),
        lootLocked = item:IsLootLocked(),
        questLoot = item:IsQuestLoot(),
        questId = item:GetQuestId(),
        lootActive = item:IsLootActive(),
        state = item:GetState(),
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

    local item = addon.Loot.Items.Item.New(
        data.name,
        data.itemId,
        data.itemLink
    )

    if data.lootQuantity ~= nil then
        item:SetLootQuantity(data.lootQuantity)
    end

    item:SetLootQuality(data.lootQuality)
    item:SetLootLocked(data.lootLocked == true)
    item:SetQuestLoot(data.questLoot == true, data.questId)
    if data.lootActive ~= nil then
        item:SetLootActive(data.lootActive)
    end

    if data.state ~= nil then
        item:SetState(data.state)
    end

    return item
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

        elapsed =
            distribution:GetElapsed(),

        rollParticipants = {},
        pendingRolls = {},

        rollGraceActive =
            distribution:IsRollGraceActive(),

        rollGraceElapsed =
            distribution:GetRollGraceElapsed(),

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

        resultFinalized =
            distribution.resultFinalized,

        finalDecision =
            distribution:GetFinalDecision(),

        finalDecisionAt =
            distribution:GetFinalDecisionAt(),
    }

    for _, player in ipairs(
        distribution:GetParticipants()
    ) do
        table.insert(
            data.participants,
            serializePlayer(player)
        )
    end

    for _, player in ipairs(
        distribution:GetRollParticipants()
    ) do
        table.insert(
            data.rollParticipants,
            serializePlayer(player)
        )

        if distribution:HasPendingRoll(player) then
            table.insert(data.pendingRolls, player:GetName())
        end
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

    if data.award ~= nil then
        data.award = {
            state = data.award.state,
            method = data.award.method,
            recipient = data.award.recipient ~= nil
                and serializePlayer(data.award.recipient)
                or nil,
            startedAt = data.award.startedAt,
            completedAt = data.award.completedAt,
            error = data.award.error,
        }
    end

    data.attempts =
        distribution:GetAttempts()

    return data
end

local function getSessionPlayer(session, playerData)
    local player = session:GetPlayer(playerData.name)

    if player == nil then
        player = deserializePlayer(playerData)
        session:AddPlayer(player)
    end

    return player
end

local function findDistributionItem(session, distributionData)
    local bossData = distributionData.boss or {}
    local boss = session:GetBoss(bossData.name)
    local itemData = distributionData.item

    if boss ~= nil and type(itemData) == "table" then
        for _, item in ipairs(boss:GetItems():GetAll()) do
            if (itemData.itemId ~= nil and item:GetId() == itemData.itemId)
                or (itemData.itemLink ~= nil and item:GetLink() == itemData.itemLink)
                or item:GetName() == itemData.name
            then
                return item, boss
            end
        end
    end

    if boss == nil then
        boss = deserializeBoss(bossData)
        session:AddBoss(boss)
    end

    local item = type(itemData) == "table"
        and deserializeItem(itemData)
        or addon.Loot.Items.Item.New(tostring(itemData), nil, nil)

    boss:AddItem(item)
    return item, boss
end

local function deserializeDistribution(session, data)
    local item, boss = findDistributionItem(session, data)
    local participants = {}

    for _, playerData in ipairs(data.participants or {}) do
        table.insert(participants, getSessionPlayer(session, playerData))
    end

    local masterLooter = getSessionPlayer(session, data.masterLooter)
    local distribution = addon.Loot.Distributions.Distribution.New(
        item, boss, participants, masterLooter
    )
    local playersByName = {}

    for _, player in ipairs(participants) do
        playersByName[player:GetName()] = player
    end

    distribution.state = data.state or distribution.state
    distribution.phaseName = data.phase or distribution.phaseName
    distribution.phase = nil
    if distribution.phaseName == "ROLLING" or distribution.phaseName == "RESULT" then
        distribution.phase = addon.Loot.Distributions.DistributionPhase.New(distribution.phaseName)
        distribution.phase:Update(math.max(0, data.elapsed or 0))
    end

    distribution.responses = {}
    for _, responseData in ipairs(data.responses or {}) do
        local player = playersByName[responseData.player.name]
        if player ~= nil then
            distribution.responses[player:GetName()] = addon.Loot.Distributions.DistributionResponse.New(
                player,
                responseData.response,
                responseData.roll,
                responseData.rollSource
            )
        end
    end

    distribution.resultResponses = data.resultResponses or {}
    distribution.winner = data.winner and playersByName[data.winner.name] or nil
    distribution.suggestedWinner = data.suggestedWinner and playersByName[data.suggestedWinner.name] or nil
    distribution.selectedRoll = data.selectedRoll
    distribution.selectedAt = data.selectedAt
    distribution.awardedAt = data.awardedAt
    distribution.currentAttempt = data.currentAttempt or 1
    distribution.restartCount = data.restartCount or 0
    distribution.rerollCount = data.rerollCount or 0
    distribution.attempts = data.attempts or distribution.attempts
    distribution.rollGraceActive = data.rollGraceActive or false
    distribution.rollGraceElapsed = data.rollGraceElapsed or 0
    distribution.resultFinalized = data.resultFinalized or false
    distribution.finalDecision = data.finalDecision
    distribution.finalDecisionAt = data.finalDecisionAt

    if data.rollParticipants ~= nil then
        distribution.rollParticipants = {}
        for _, playerData in ipairs(data.rollParticipants) do
            local player = playersByName[playerData.name]
            if player ~= nil then
                table.insert(distribution.rollParticipants, player)
            end
        end
    end

    distribution.pendingRolls = {}
    local rollParticipantsByName = {}
    for _, player in ipairs(distribution.rollParticipants) do
        rollParticipantsByName[player:GetName()] = player
    end
    for _, playerName in ipairs(data.pendingRolls or {}) do
        if rollParticipantsByName[playerName] ~= nil then
            distribution.pendingRolls[playerName] = true
        end
    end

    if data.award ~= nil then
        distribution.award = {
            state = data.award.state,
            method = data.award.method,
            recipient = data.award.recipient
                and playersByName[data.award.recipient.name]
                or nil,
            startedAt = data.award.startedAt,
            completedAt = data.award.completedAt,
            error = data.award.error,
        }
    end

    return distribution
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

    local restoredMasterLooter =
        session:GetPlayer(masterLooter:GetName())

    if restoredMasterLooter == nil then
        restoredMasterLooter = masterLooter
        session:AddPlayer(restoredMasterLooter)
    end

    session.masterLooter = restoredMasterLooter

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

    for _, distributionData in ipairs(data.distributions or {}) do
        session:AddDistribution(
            deserializeDistribution(session, distributionData)
        )
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
            schemaVersion = CURRENT_SCHEMA_VERSION,
            config = nil,
            activeSessions = {},
            history = {},
        }
    end

    self.database =
        _G[DATABASE_KEY]

    local schemaVersion = self.database.schemaVersion
    if schemaVersion == nil then
        schemaVersion = 0
    end

    assert(
        type(schemaVersion) == "number"
            and schemaVersion >= 0
            and schemaVersion % 1 == 0,
        "Invalid NinjaLoot database schema version"
    )

    assert(
        schemaVersion <= CURRENT_SCHEMA_VERSION,
        "NinjaLoot database was saved by a newer addon version"
    )

    while schemaVersion < CURRENT_SCHEMA_VERSION do
        if schemaVersion == 0 then
            self.database.history = self.database.history or {}
            self.database.activeSessions =
                self.database.activeSessions or {}

            local oldSession = self.database.activeSession
            if oldSession ~= nil
                and oldSession.sessionId ~= nil
                and self.database.activeSessions[
                    oldSession.sessionId
                ] == nil
            then
                self.database.activeSessions[
                    oldSession.sessionId
                ] = oldSession
            end

            self.database.activeSession = nil
            schemaVersion = 1
            self.database.schemaVersion = schemaVersion
        end
    end

    self.database.history =
        self.database.history
        or {}

    if self.database.activeSessions == nil then
        self.database.activeSessions = {}
    end

    self.database.schemaVersion = CURRENT_SCHEMA_VERSION

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

    self.database.schemaVersion = CURRENT_SCHEMA_VERSION

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
    self.database.schemaVersion = CURRENT_SCHEMA_VERSION

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
    self.database.schemaVersion = CURRENT_SCHEMA_VERSION

    return self
end

addon.Loot.Sessions.SessionPersistence =
    SessionPersistence
