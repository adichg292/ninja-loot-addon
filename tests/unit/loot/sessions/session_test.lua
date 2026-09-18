local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile("Loot/Players/Player.lua")
loadAddonFile("Loot/Players/PlayerManager.lua")

loadAddonFile("Loot/Items/Item.lua")
loadAddonFile("Loot/Items/ItemManager.lua")

loadAddonFile("Loot/Bosses/Boss.lua")
loadAddonFile("Loot/Bosses/BossManager.lua")

loadAddonFile("Loot/Lifecycles/Lifecycle.lua")

loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")
loadAddonFile("Loot/Distributions/Distribution.lua")
loadAddonFile("Loot/Distributions/DistributionManager.lua")

loadAddonFile("Loot/Sessions/Session.lua")

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Session =
    addon.Loot.Sessions.Session

local Player =
    addon.Loot.Players.Player

local Boss =
    addon.Loot.Bosses.Boss

local Item =
    addon.Loot.Items.Item

local Distribution =
    addon.Loot.Distributions.Distribution

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local bossOne =
    Boss.New("Boss One")

local bossTwo =
    Boss.New("Boss Two")

local session =
    Session.New(
        "SESSION-TEST",
        "ROUND_ROBIN",
        playerOne
    )

assert(
    session:GetId() == "SESSION-TEST",
    "GetId should return the session ID"
)

assert(
    session:GetLootSystem() == "ROUND_ROBIN",
    "GetLootSystem should return the loot system"
)

assert(
    session:GetMasterLooter() == playerOne,
    "GetMasterLooter should return the master looter"
)

assert(
    session:IsSetup(),
    "New session should be in setup state"
)

assert(
    not session:IsActive(),
    "New session should not be active"
)

assert(
    not session:IsEnded(),
    "New session should not be ended"
)

assert(
    session:GetCurrentBoss() == nil,
    "New session should not have a current boss"
)

assert(
    session:GetPlayers() ~= nil,
    "Session should have a player manager"
)

assert(
    session:GetBosses() ~= nil,
    "Session should have a boss manager"
)

assert(
    session:GetDistributions() ~= nil,
    "Session should have a distribution manager"
)

assert(
    session:AddPlayer(playerOne) == playerOne,
    "AddPlayer should return the added player"
)

assert(
    session:AddPlayer(playerTwo) == playerTwo,
    "AddPlayer should return the second player"
)

assert(
    session:GetPlayer("PlayerOne") == playerOne,
    "GetPlayer should return the first player"
)

assert(
    session:GetPlayer("PlayerTwo") == playerTwo,
    "GetPlayer should return the second player"
)

assert(
    session:AddBoss(bossOne) == bossOne,
    "AddBoss should return the first boss"
)

assert(
    session:GetCurrentBoss() == bossOne,
    "First added boss should become current boss"
)

assert(
    session:AddBoss(bossTwo) == bossTwo,
    "AddBoss should return the second boss"
)

assert(
    session:GetCurrentBoss() == bossOne,
    "Adding another boss should not replace current boss"
)

session:SetCurrentBoss(bossTwo)

assert(
    session:GetCurrentBoss() == bossTwo,
    "SetCurrentBoss should change the current boss"
)

assert(
    not session:IsCurrentBossKilled(),
    "Current boss should not be killed initially"
)

local item =
    Item.New(
        "Test Item",
        12345
    )

local addBeforeKillSuccess =
    pcall(function()
        session:AddItem(item)
    end)

assert(
    not addBeforeKillSuccess,
    "Session should reject loot before the boss is killed"
)

assert(
    session:BossKilled(100) == bossTwo,
    "BossKilled should return the current boss"
)

assert(
    session:IsCurrentBossKilled(),
    "Current boss should be marked killed"
)

assert(
    bossTwo:IsKilled(),
    "Current boss should be killed"
)

assert(
    bossTwo:GetKilledAt() == 100,
    "Boss kill time should be stored"
)

assert(
    session:AddItem(item) == item,
    "AddItem should return the added item"
)

assert(
    session:GetItem(1) == item,
    "GetItem should return the current boss item"
)

assert(
    session:GetItems():Count() == 1,
    "Current boss should contain one item"
)

assert(
    session:AddLoot(
        Item.New(
            "Second Item",
            54321
        )
    ) ~= nil,
    "AddLoot should add another item"
)

assert(
    session:GetItems():Count() == 2,
    "AddLoot should increase the item count"
)

local distribution =
    Distribution.New(
        item,
        bossTwo,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

assert(
    session:AddDistribution(distribution)
    == distribution,
    "AddDistribution should return the distribution"
)

assert(
    session:GetDistribution(1)
    == distribution,
    "GetDistribution should return the distribution"
)

assert(
    item:GetDistribution() == distribution,
    "Item should reference its distribution"
)

session:Start(200)

assert(
    session:IsActive(),
    "Started session should be active"
)

assert(
    session:GetStartedAt() == 200,
    "Session should store start time"
)

assert(
    not session:IsSetup(),
    "Started session should not be setup"
)

assert(
    not session:IsEnded(),
    "Started session should not be ended"
)

session:End(300)

assert(
    session:IsEnded(),
    "Ended session should report as ended"
)

assert(
    session:GetEndedAt() == 300,
    "Session should store end time"
)

local addPlayerAfterEndSuccess =
    pcall(function()
        session:AddPlayer(
            Player.New("Another Player")
        )
    end)

assert(
    not addPlayerAfterEndSuccess,
    "Ended session should reject adding players"
)

local addBossAfterEndSuccess =
    pcall(function()
        session:AddBoss(
            Boss.New("Another Boss")
        )
    end)

assert(
    not addBossAfterEndSuccess,
    "Ended session should reject adding bosses"
)

local addItemAfterEndSuccess =
    pcall(function()
        session:AddItem(
            Item.New("Another Item")
        )
    end)

assert(
    not addItemAfterEndSuccess,
    "Ended session should reject adding items"
)

local addDistributionAfterEndSuccess =
    pcall(function()
        session:AddDistribution(
            Distribution.New(
                Item.New("Another Distribution Item"),
                bossTwo,
                {
                    playerOne,
                    playerTwo,
                },
                playerOne
            )
        )
    end)

assert(
    not addDistributionAfterEndSuccess,
    "Ended session should reject adding distributions"
)
