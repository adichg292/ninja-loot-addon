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

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

local Player =
    addon.Loot.Players.Player

local SessionManager =
    addon.Loot.Sessions.SessionManager

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local persistenceSaveCount = 0
local persistenceLoadCount = 0

local persistence = {
    Save = function(
        self,
        manager
    )
        assert(
            manager ~= nil,
            "Persistence should receive session manager"
        )

        persistenceSaveCount =
            persistenceSaveCount + 1
    end,

    Load = function(
        self,
        manager
    )
        assert(
            manager ~= nil,
            "Persistence should receive session manager"
        )

        persistenceLoadCount =
            persistenceLoadCount + 1
    end,
}

local manager =
    SessionManager.New(
        persistence
    )

assert(
    manager:GetActiveCount() == 0,
    "New manager should have no active sessions"
)

assert(
    manager:GetHistoryCount() == 0,
    "New manager should have empty history"
)

local sessionOne =
    manager:Create(
        "SESSION-ONE",
        "ROUND_ROBIN",
        playerOne
    )

local sessionTwo =
    manager:Create(
        "SESSION-TWO",
        "ROUND_ROBIN",
        playerTwo
    )

assert(
    manager:GetActiveCount() == 2,
    "Manager should support multiple active sessions"
)

assert(
    manager:GetActive("SESSION-ONE")
    == sessionOne,
    "First active session should be retrievable"
)

assert(
    manager:GetActive("SESSION-TWO")
    == sessionTwo,
    "Second active session should be retrievable"
)

assert(
    persistenceSaveCount == 2,
    "Creating two sessions should save twice"
)

manager:Start(
    "SESSION-ONE",
    100
)

manager:Start(
    "SESSION-TWO",
    200
)

assert(
    sessionOne:IsActive(),
    "First session should be active"
)

assert(
    sessionTwo:IsActive(),
    "Second session should be active"
)

manager:End(
    "SESSION-ONE",
    300
)

assert(
    manager:GetActiveCount() == 1,
    "Ending one session should leave the other active"
)

assert(
    manager:GetActive("SESSION-ONE")
    == nil,
    "Ended session should no longer be active"
)

assert(
    manager:GetActive("SESSION-TWO")
    == sessionTwo,
    "Other session should remain active"
)

assert(
    manager:GetHistoryCount() == 1,
    "Ended session should enter history"
)

assert(
    manager:GetHistoryEntry(1)
    == sessionOne,
    "History should contain ended session"
)

assert(
    manager:GetSession("SESSION-ONE")
    == sessionOne,
    "GetSession should find historical sessions"
)

assert(
    manager:GetSession("SESSION-TWO")
    == sessionTwo,
    "GetSession should find active sessions"
)

assert(
    persistenceLoadCount == 0,
    "Restore should not happen automatically"
)

manager:Restore()

assert(
    persistenceLoadCount == 1,
    "Restore should call persistence load"
)

manager:ClearActive(
    "SESSION-TWO"
)

assert(
    manager:GetActiveCount() == 0,
    "ClearActive should support a specific session"
)

manager:ClearHistory()

assert(
    manager:GetHistoryCount() == 0,
    "ClearHistory should clear history"
)

local replacementPersistence = {
    Save = function(
        self,
        manager
    )
        assert(
            manager ~= nil,
            "Replacement persistence should receive manager"
        )
    end,

    Load = function(
        self,
        manager
    )
        assert(
            manager ~= nil,
            "Replacement persistence should receive manager"
        )
    end,
}

manager:SetPersistence(
    replacementPersistence
)

assert(
    manager.persistence
    == replacementPersistence,
    "SetPersistence should replace persistence"
)
