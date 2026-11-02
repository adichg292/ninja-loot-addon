local function loadAddonFile(
    path
)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile(
    "Loot/Players/Player.lua"
)

loadAddonFile(
    "Loot/Players/PlayerManager.lua"
)

loadAddonFile(
    "Loot/Items/Item.lua"
)

loadAddonFile(
    "Loot/Items/ItemManager.lua"
)

loadAddonFile(
    "Loot/Bosses/Boss.lua"
)

loadAddonFile(
    "Loot/Bosses/BossManager.lua"
)

loadAddonFile(
    "Loot/Lifecycles/Lifecycle.lua"
)

loadAddonFile(
    "Loot/Distributions/Constants.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionResponse.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionPhase.lua"
)

loadAddonFile(
    "Loot/Distributions/Distribution.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionManager.lua"
)

loadAddonFile(
    "Loot/Sessions/Session.lua"
)

loadAddonFile(
    "Loot/Sessions/SessionManager.lua"
)

loadAddonFile(
    "Loot/Sessions/SessionPersistence.lua"
)

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

local Player =
    addon.Loot.Players.Player

local Item =
    addon.Loot.Items.Item

local Boss =
    addon.Loot.Bosses.Boss

local SessionManager =
    addon.Loot.Sessions.SessionManager

local SessionPersistence =
    addon.Loot.Sessions.SessionPersistence

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

_G.NinjaLootDatabase = nil

local persistence =
    SessionPersistence.New()

persistence:Initialize()

assert(
    persistence:GetDatabase().schemaVersion
        == SessionPersistence.SchemaVersion,
    "New databases should be initialized with the current schema version"
)

local manager =
    SessionManager.New(
        persistence
    )

local sessionOne =
    manager:Create(
        "PERSIST-ONE",
        "ROUND_ROBIN",
        playerOne
    )

local sessionTwo =
    manager:Create(
        "PERSIST-TWO",
        "ROUND_ROBIN",
        playerTwo
    )

local boss =
    Boss.New("Test Boss")

sessionOne:AddBoss(boss)
sessionOne:SetCurrentBoss(boss)
sessionOne:BossKilled(150)

local item =
    Item.New(
        "Test Item",
        12345,
        "|Hitem:12345|h[Test Item]|h"
    )

item:SetLootSlot(4)
item:SetLootQuantity(2)
item:SetLootQuality(4)
item:SetLootLocked(true)
item:SetQuestLoot(true, 37)
item:SetLootActive(false)
item:MarkDistributing()

sessionOne:AddPlayer(playerOne)
sessionOne:AddPlayer(playerTwo)

local distribution =
    addon.Loot.Distributions.Distribution.New(
        item,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

distribution:Respond(
    playerTwo,
    addon.Loot.Distributions.Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerTwo,
    87,
    addon.Loot.Distributions.Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerOne,
    addon.Loot.Distributions.Constants.Responses.NEED
)

sessionOne:AddDistribution(distribution)

manager:SetMasterLooter(
    "PERSIST-ONE",
    playerTwo
)

assert(
    sessionOne:GetMasterLooter() == playerTwo
        and distribution:GetMasterLooter() == playerTwo,
    "Master looter handoff should update the session and pending distribution"
)

sessionOne:AddItem(item)

manager:Start(
    "PERSIST-ONE",
    100
)

manager:Start(
    "PERSIST-TWO",
    200
)

manager:End(
    "PERSIST-ONE",
    300
)

local database =
    persistence:GetDatabase()

assert(
    database.activeSessions[
    "PERSIST-TWO"
    ] ~= nil,
    "Active sessions should be persisted by ID"
)

assert(
    database.activeSessions[
    "PERSIST-ONE"
    ] == nil,
    "Ended session should not remain active"
)

assert(
    #database.history == 1,
    "Ended session should be persisted in history"
)

assert(
    database.schemaVersion == SessionPersistence.SchemaVersion,
    "Saved session data should retain the current schema version"
)

local historyData =
    database.history[1]

assert(
    historyData.currentBoss == "Test Boss",
    "Current boss should be persisted"
)

assert(
    #historyData.bosses == 1,
    "Boss should be persisted"
)

assert(
    historyData.bosses[1].name == "Test Boss",
    "Boss name should be persisted"
)

assert(
    historyData.bosses[1].killedAt == 150,
    "Boss kill time should be persisted"
)

assert(
    #historyData.bosses[1].items == 1,
    "Boss items should be persisted"
)

assert(
    historyData.bosses[1].items[1].name
    == "Test Item",
    "Item name should be persisted"
)

assert(
    historyData.bosses[1].items[1].itemId
    == 12345,
    "Item ID should be persisted"
)

assert(
    historyData.bosses[1].items[1].itemLink
    == "|Hitem:12345|h[Test Item]|h",
    "Item link should be persisted"
)

assert(
    historyData.bosses[1].items[1].lootSlot == nil,
    "Ephemeral loot slot should not be persisted"
)

assert(
    historyData.bosses[1].items[1].lootQuantity == 2,
    "Loot quantity should be persisted"
)

assert(
    historyData.bosses[1].items[1].lootQuality == 4,
    "Loot quality should be persisted"
)

assert(
    historyData.bosses[1].items[1].lootLocked == true,
    "Loot lock status should be persisted"
)

assert(
    historyData.bosses[1].items[1].questLoot == true
        and historyData.bosses[1].items[1].questId == 37,
    "Quest loot metadata should be persisted"
)

assert(
    historyData.bosses[1].items[1].lootActive == false,
    "Loot active status should be persisted"
)

assert(
    historyData.bosses[1].items[1].state == "DISTRIBUTING",
    "Item state should be persisted"
)

assert(
    historyData.distributions[1].pendingRolls[1] == "PlayerOne",
    "Pending roll participant should be persisted"
)

local restoredPersistence =
    SessionPersistence.New()

restoredPersistence:Initialize()

local restoredManager =
    SessionManager.New(
        restoredPersistence
    )

restoredManager:Restore()

assert(
    restoredManager:GetActiveCount() == 1,
    "Restore should restore active sessions"
)

assert(
    restoredManager:GetActive(
        "PERSIST-TWO"
    ) ~= nil,
    "Second session should be restored"
)

assert(
    restoredManager:GetHistoryCount() == 1,
    "Restore should restore session history"
)

local restoredSession =
    restoredManager:GetSession(
        "PERSIST-ONE"
    )

assert(
    restoredSession ~= nil,
    "Historical session should be restored"
)

local restoredBoss =
    restoredSession:GetBoss(
        "Test Boss"
    )

assert(
    restoredBoss ~= nil,
    "Boss should be restored"
)

assert(
    restoredBoss:IsKilled(),
    "Restored boss should remain killed"
)

assert(
    restoredBoss:GetKilledAt() == 150,
    "Restored boss should retain kill time"
)

assert(
    restoredBoss:GetItems():Count() == 1,
    "Restored boss should contain its items"
)

local restoredItem =
    restoredBoss:GetItem(1)

assert(
    restoredItem:GetName()
    == "Test Item",
    "Restored item should retain its name"
)

assert(
    restoredItem:GetId()
    == 12345,
    "Restored item should retain its ID"
)

assert(
    restoredItem:GetLink()
    == "|Hitem:12345|h[Test Item]|h",
    "Restored item should retain its link"
)

assert(
    restoredItem:GetLootSlot() == nil
        and restoredItem:GetLootQuantity() == 2,
    "Restored item should retain quantity without restoring a stale loot slot"
)

assert(
    restoredItem:GetLootQuality() == 4
        and restoredItem:IsLootLocked(),
    "Restored item should retain quality and lock status"
)

assert(
    restoredItem:IsQuestLoot()
        and restoredItem:GetQuestId() == 37,
    "Restored item should retain quest metadata"
)

assert(
    not restoredItem:IsLootActive()
        and restoredItem:IsDistributing(),
    "Restored item should retain active status and distribution state"
)

assert(
    restoredSession:GetCurrentBoss()
    == restoredBoss,
    "Restored session should restore current boss"
)

assert(
    restoredSession:GetMasterLooter()
        == restoredSession:GetPlayer("PlayerTwo"),
    "Restored master looter should share the session player instance"
)

local restoredDistribution =
    restoredSession:GetDistribution(1)

assert(
    restoredDistribution ~= nil,
    "Session distributions should be restored"
)

assert(
    restoredDistribution:GetItem() == restoredItem,
    "Restored distribution should reference the restored boss item"
)

assert(
    restoredDistribution:GetBoss() == restoredBoss,
    "Restored distribution should reference the restored boss"
)

assert(
    restoredDistribution:GetResponse(
        restoredSession:GetPlayer("PlayerTwo")
    ):GetRoll() == 87,
    "Restored distribution should retain participant roll responses"
)

assert(
    restoredDistribution:HasPendingRoll(
        restoredSession:GetPlayer("PlayerOne")
    ),
    "Restored distribution should retain pending roll state"
)

_G.NinjaLootDatabase = {
    config = {
        legacySetting = true,
    },
    activeSession = {
        sessionId = "OLD-SESSION",
        lootSystem = "ROUND_ROBIN",
        masterLooter = {
            name = "LegacyML",
        },
        state = "ACTIVE",
        startedAt = 50,
        players = {},
        bosses = {},
        distributions = {},
    },
    history = {},
}

local migratedPersistence =
    SessionPersistence.New()

migratedPersistence:Initialize()

local migratedDatabase =
    migratedPersistence:GetDatabase()

assert(
    migratedDatabase.activeSessions[
    "OLD-SESSION"
    ] ~= nil,
    "Legacy activeSession should migrate to activeSessions"
)

assert(
    migratedDatabase.activeSession == nil,
    "Legacy activeSession should be cleared after migration"
)

assert(
    migratedDatabase.schemaVersion == SessionPersistence.SchemaVersion,
    "Legacy unversioned databases should be migrated to the current schema version"
)

assert(
    migratedDatabase.config.legacySetting == true,
    "Schema migration should preserve existing configuration data"
)

_G.NinjaLootDatabase = {
    schemaVersion = SessionPersistence.SchemaVersion + 1,
    activeSessions = {},
    history = {},
}

local futurePersistence = SessionPersistence.New()
local futureSchemaLoaded = pcall(function()
    futurePersistence:Initialize()
end)

assert(
    not futureSchemaLoaded,
    "Newer database schemas should be rejected instead of overwritten"
)
