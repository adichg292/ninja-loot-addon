local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile("Loot/Players/Player.lua")
loadAddonFile("Loot/Items/Item.lua")
loadAddonFile("Loot/Items/ItemManager.lua")
loadAddonFile("Loot/Bosses/Boss.lua")
loadAddonFile("Loot/Lifecycles/Lifecycle.lua")
loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")
loadAddonFile("Loot/Distributions/Distribution.lua")
loadAddonFile("Loot/Distributions/DistributionManager.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Distribution =
    addon.Loot.Distributions.Distribution

local DistributionManager =
    addon.Loot.Distributions.DistributionManager

local Constants =
    addon.Loot.Distributions.Constants

local Player =
    addon.Loot.Players.Player

local Boss =
    addon.Loot.Bosses.Boss

local playerOne = Player.New("PlayerOne")
local playerTwo = Player.New("PlayerTwo")
local playerThree = Player.New("PlayerThree")
local playerFour = Player.New("PlayerFour")

local bossOne = Boss.New("Boss One")
local bossTwo = Boss.New("Boss Two")

local manager = DistributionManager.New()

local distributionOne = Distribution.New(
    addon.Loot.Items.Item.New("Item One"),
    bossOne,
    {
        playerOne,
        playerTwo,
    },
    playerOne
)

local distributionTwo = Distribution.New(
    addon.Loot.Items.Item.New("Item Two"),
    bossOne,
    {
        playerOne,
        playerTwo,
        playerThree,
    },
    playerOne
)

local distributionThree = Distribution.New(
    addon.Loot.Items.Item.New("Item Three"),
    bossTwo,
    {
        playerOne,
        playerTwo,
        playerThree,
        playerFour,
    },
    playerOne
)

manager:Add(distributionOne)
manager:Add(distributionTwo)
manager:Add(distributionThree)

assert(
    manager:Count() == 3,
    "Manager should contain three distributions"
)

assert(
    manager:Get(1) == distributionOne,
    "First distribution should be retrievable"
)

assert(
    manager:Get(2) == distributionTwo,
    "Second distribution should be retrievable"
)

assert(
    manager:Get(3) == distributionThree,
    "Third distribution should be retrievable"
)

local bossOneDistributions =
    manager:GetByBoss(bossOne)

assert(
    #bossOneDistributions == 2,
    "Boss lookup should return two distributions"
)

local bossTwoDistributions =
    manager:GetByBoss(bossTwo)

assert(
    #bossTwoDistributions == 1,
    "Second boss lookup should return one distribution"
)

distributionOne:Respond(
    playerOne,
    Constants.Responses.NEED
)

distributionOne:RegisterRoll(
    playerOne,
    100,
    Constants.RollSources.NINJALOOT
)

distributionOne:Respond(
    playerTwo,
    Constants.Responses.NEED
)

distributionOne:RegisterRoll(
    playerTwo,
    50,
    Constants.RollSources.NINJALOOT
)

assert(
    distributionOne:IsAwardPending(),
    "Distribution should finish rolling after all rolls"
)

distributionOne:SelectWinner(
    playerOne,
    100,
    100
)

distributionOne:Award(
    playerOne,
    110
)

local playerOneDistributions =
    manager:GetByPlayer(playerOne)

assert(
    #playerOneDistributions == 1,
    "Winner lookup should return one awarded distribution"
)

assert(
    playerOneDistributions[1] == distributionOne,
    "Winner lookup should return the correct distribution"
)

manager:Update(
    Constants.RollTimerSeconds
)

assert(
    distributionTwo:IsRollGraceActive(),
    "Distribution two should enter roll grace"
)

assert(
    distributionThree:IsRollGraceActive(),
    "Distribution three should enter roll grace"
)

local expiredDuringGrace =
    manager:GetExpired()

assert(
    #expiredDuringGrace == 1,
    "Only the already-expired result distribution should be reported as expired"
)

assert(
    expiredDuringGrace[1] == distributionOne,
    "Only distribution one should be reported as expired during roll grace"
)

manager:Update(
    Constants.RollGraceSeconds
)

assert(
    distributionTwo:IsAwardPending(),
    "Distribution two should leave rolling after grace"
)

assert(
    distributionThree:IsAwardPending(),
    "Distribution three should leave rolling after grace"
)

local expiredAfterGrace =
    manager:GetExpired()

for _, distribution in ipairs(expiredAfterGrace) do
    assert(
        distribution ~= distributionTwo,
        "Award-pending distribution two should not be expired"
    )

    assert(
        distribution ~= distributionThree,
        "Award-pending distribution three should not be expired"
    )
end

manager:ProcessExpired()

assert(
    distributionOne:IsFinal(),
    "Previously expired result should be finalized"
)

distributionTwo:SelectWinner(
    playerOne,
    0,
    200
)

distributionTwo:Award(
    playerOne,
    210
)

assert(
    distributionTwo:IsResult(),
    "Awarding a distribution should enter the result phase"
)

assert(
    distributionTwo:GetElapsed() == 0,
    "Result phase should start with zero elapsed time"
)

manager:Update(
    Constants.ResultTimerSeconds
)

assert(
    distributionTwo:IsPhaseExpired(),
    "Result phase should expire after ten seconds"
)

local processed =
    manager:ProcessExpired()

assert(
    #processed == 1,
    "One expired result should be processed"
)

assert(
    processed[1] == distributionTwo,
    "Processed distribution should be distribution two"
)

assert(
    distributionTwo:IsFinal(),
    "Processed result should become final"
)

distributionThree:SelectWinner(
    playerOne,
    100,
    300
)

distributionThree:Award(
    playerOne,
    310
)

assert(
    distributionThree:IsResult(),
    "Distribution three should enter the result phase"
)

distributionThree:VoteRestart(playerOne)
distributionThree:VoteRestart(playerTwo)
distributionThree:VoteRestart(playerThree)

assert(
    distributionThree:GetRestartVoteCount() == 3,
    "Three restart votes should be counted"
)

assert(
    not distributionThree:HasRestartThreshold(),
    "Three votes should not reach a four-player threshold"
)

manager:Update(
    Constants.ResultTimerSeconds
)

assert(
    distributionThree:IsPhaseExpired(),
    "Distribution three result phase should expire"
)

local processedWithVotes =
    manager:ProcessExpired()

assert(
    #processedWithVotes == 1,
    "Expired result without restart threshold should be finalized"
)

assert(
    processedWithVotes[1] == distributionThree,
    "Distribution three should be processed"
)

assert(
    distributionThree:IsFinal(),
    "Distribution three should become final when restart threshold is not reached"
)

manager:Clear()

local restartDistribution = Distribution.New(
    addon.Loot.Items.Item.New("Restart Item"),
    bossTwo,
    {
        playerOne,
        playerTwo,
        playerThree,
        playerFour,
    },
    playerOne
)

manager:Add(restartDistribution)

restartDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

restartDistribution:RegisterRoll(
    playerOne,
    100,
    Constants.RollSources.NINJALOOT
)

restartDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

restartDistribution:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

restartDistribution:Respond(
    playerThree,
    Constants.Responses.NEED
)

restartDistribution:RegisterRoll(
    playerThree,
    80,
    Constants.RollSources.NINJALOOT
)

restartDistribution:Respond(
    playerFour,
    Constants.Responses.NEED
)

restartDistribution:RegisterRoll(
    playerFour,
    70,
    Constants.RollSources.NINJALOOT
)

assert(
    restartDistribution:IsAwardPending(),
    "All rolls should move restart distribution to award pending"
)

restartDistribution:SelectWinner(
    playerOne,
    100,
    400
)

restartDistribution:Award(
    playerOne,
    410
)

assert(
    restartDistribution:IsResult(),
    "Awarding restart distribution should enter the result phase"
)

restartDistribution:VoteRestart(playerOne)
restartDistribution:VoteRestart(playerTwo)
restartDistribution:VoteRestart(playerThree)
restartDistribution:VoteRestart(playerFour)

assert(
    restartDistribution:GetRestartVoteCount() == 4,
    "Four restart votes should be counted"
)

assert(
    restartDistribution:HasRestartThreshold(),
    "Four votes should reach the dynamic threshold"
)

manager:Update(
    Constants.ResultTimerSeconds
)

assert(
    restartDistribution:IsResult(),
    "Distribution should remain in result phase when restart threshold is reached"
)

assert(
    restartDistribution:IsPhaseExpired(),
    "Result phase should be expired before restart decision"
)

local processedRestart =
    manager:ProcessExpired()

assert(
    #processedRestart == 0,
    "Expired result with restart threshold should remain unresolved"
)

assert(
    restartDistribution:IsResult(),
    "Distribution should remain in result phase while restart decision is unresolved"
)

restartDistribution:Restart(420)

assert(
    restartDistribution:IsPending(),
    "Restart should return distribution to pending"
)

assert(
    restartDistribution:IsRolling(),
    "Restart should return distribution to rolling"
)

assert(
    restartDistribution:GetCurrentAttempt() == 2,
    "Restart should create a new attempt"
)

assert(
    restartDistribution:GetRestartCount() == 1,
    "Restart count should increment"
)

assert(
    restartDistribution:GetAttempt(1) ~= nil,
    "Previous attempt should remain in history"
)

manager:Remove(1)

assert(
    manager:Count() == 0,
    "Removing the distribution should reduce the count"
)

manager:Clear()

assert(
    manager:Count() == 0,
    "Clear should remove all distributions"
)
