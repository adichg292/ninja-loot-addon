local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Sessions = addon.Loot.Sessions or {}

local Session = {}
Session.__index = Session

local function assertValidPlayer(player)
    assert(
        player ~= nil,
        "Player is required"
    )

    assert(
        getmetatable(player)
        == addon.Loot.Players.Player,
        "Invalid player"
    )
end

local function assertValidBoss(boss)
    assert(
        boss ~= nil,
        "Boss is required"
    )

    assert(
        getmetatable(boss)
        == addon.Loot.Bosses.Boss,
        "Invalid boss"
    )
end

local function assertValidItem(item)
    assert(
        item ~= nil,
        "Item is required"
    )

    assert(
        getmetatable(item)
        == addon.Loot.Items.Item,
        "Invalid item"
    )
end

local function assertValidDistribution(distribution)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        getmetatable(distribution)
        == addon.Loot.Distributions.Distribution,
        "Invalid distribution"
    )
end

function Session.New(
    sessionId,
    lootSystem,
    masterLooter
)
    assert(
        sessionId ~= nil,
        "Session ID is required"
    )

    assert(
        sessionId ~= "",
        "Session ID cannot be empty"
    )

    assert(
        lootSystem ~= nil,
        "Loot system is required"
    )

    assert(
        lootSystem ~= "",
        "Loot system cannot be empty"
    )

    assertValidPlayer(masterLooter)

    local lifecycle =
        addon.Loot.Lifecycles.Lifecycle.New()

    lifecycle:Setup()

    return setmetatable({
        sessionId = sessionId,
        lootSystem = lootSystem,
        masterLooter = masterLooter,

        lifecycle = lifecycle,

        players =
            addon.Loot.Players.PlayerManager.New(),

        bosses =
            addon.Loot.Bosses.BossManager.New(),

        distributions =
            addon.Loot.Distributions.DistributionManager.New(),

        currentBoss = nil,
        startedAt = nil,
        endedAt = nil,
    }, Session)
end

function Session:GetId()
    return self.sessionId
end

function Session:GetLootSystem()
    return self.lootSystem
end

function Session:GetMasterLooter()
    return self.masterLooter
end

function Session:GetLifecycle()
    return self.lifecycle
end

function Session:GetPlayers()
    return self.players
end

function Session:GetBosses()
    return self.bosses
end

function Session:GetDistributions()
    return self.distributions
end

function Session:GetCurrentBoss()
    return self.currentBoss
end

function Session:GetStartedAt()
    return self.startedAt
end

function Session:GetEndedAt()
    return self.endedAt
end

function Session:IsSetup()
    return self.lifecycle:IsSetup()
end

function Session:IsActive()
    return self.lifecycle:IsActive()
end

function Session:IsEnded()
    return self.lifecycle:IsEnded()
end

function Session:AddPlayer(player)
    assert(
        not self:IsEnded(),
        "Cannot add a player to an ended session"
    )

    assertValidPlayer(player)

    return self.players:Add(player)
end

function Session:GetPlayer(name)
    return self.players:Get(name)
end

function Session:AddBoss(boss)
    assert(
        not self:IsEnded(),
        "Cannot add a boss to an ended session"
    )

    assertValidBoss(boss)

    local result =
        self.bosses:Add(boss)

    if self.currentBoss == nil then
        self.currentBoss = boss
    end

    return result
end

function Session:GetBoss(name)
    return self.bosses:Get(name)
end

function Session:SetCurrentBoss(boss)
    assert(
        not self:IsEnded(),
        "Cannot change the current boss of an ended session"
    )

    assertValidBoss(boss)

    assert(
        self:GetBoss(boss:GetName()) == boss,
        "Boss must belong to the session"
    )

    self.currentBoss = boss

    return self
end

function Session:BossKilled(killedAt)
    assert(
        not self:IsEnded(),
        "Cannot kill a boss in an ended session"
    )

    assert(
        self.currentBoss ~= nil,
        "Current boss is required"
    )

    self.currentBoss:Kill(killedAt)

    return self.currentBoss
end

function Session:IsCurrentBossKilled()
    return self.currentBoss ~= nil
        and self.currentBoss:IsKilled()
end

function Session:AddItem(item)
    assert(
        not self:IsEnded(),
        "Cannot add an item to an ended session"
    )

    assert(
        self.currentBoss ~= nil,
        "Current boss is required"
    )

    assert(
        self.currentBoss:IsKilled(),
        "Current boss must be killed before adding loot"
    )

    assertValidItem(item)

    return self.currentBoss:AddItem(item)
end

function Session:AddLoot(item)
    return self:AddItem(item)
end

function Session:GetItem(index)
    assert(
        self.currentBoss ~= nil,
        "Current boss is required"
    )

    return self.currentBoss:GetItem(index)
end

function Session:GetItems()
    assert(
        self.currentBoss ~= nil,
        "Current boss is required"
    )

    return self.currentBoss:GetItems()
end

function Session:AddDistribution(distribution)
    assert(
        not self:IsEnded(),
        "Cannot add a distribution to an ended session"
    )

    assertValidDistribution(distribution)

    return self.distributions:Add(distribution)
end

function Session:GetDistribution(index)
    return self.distributions:Get(index)
end

function Session:Start(startedAt)
    assert(
        startedAt ~= nil,
        "Session start time is required"
    )

    self.lifecycle:Start(startedAt)
    self.startedAt = startedAt

    return self
end

function Session:End(endedAt)
    assert(
        endedAt ~= nil,
        "Session end time is required"
    )

    self.lifecycle:End(endedAt)
    self.endedAt = endedAt

    return self
end

addon.Loot.Sessions.Session = Session
