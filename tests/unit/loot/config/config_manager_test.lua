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
    "Loot/History/HistoryManager.lua"
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

local Distribution =
    addon.Loot.Distributions.Distribution

local Constants =
    addon.Loot.Distributions.Constants

local SessionManager =
    addon.Loot.Sessions.SessionManager

local HistoryManager =
    addon.Loot.History.HistoryManager

local masterLooter =
    Player.New("Master")

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local boss =
    Boss.New("Test Boss")

local sessionManager =
    SessionManager.New()

local session =
    sessionManager:Create(
        "HISTORY-TEST",
        "ROUND_ROBIN",
        masterLooter
    )

local item = Item.New("Sword of Testing")
local itemTwo = Item.New("Shield of Testing")
local itemThree = Item.New("Ring of Testing")

session:AddPlayer(
    masterLooter
)

session:AddPlayer(
    playerOne
)

session:AddPlayer(
    playerTwo
)

session:AddBoss(
    boss
)

session:SetCurrentBoss(
    boss
)

sessionManager:Start(
    "HISTORY-TEST",
    100
)

local distributionOne =
    Distribution.New(
        item,
        boss,
        {
            masterLooter,
            playerOne,
            playerTwo,
        },
        masterLooter
    )

session:AddDistribution(
    distributionOne
)

distributionOne:RegisterRoll(
    masterLooter,
    10,
    Constants.RollSources.NINJALOOT
)

distributionOne:RegisterRoll(
    playerOne,
    95,
    Constants.RollSources.NINJALOOT
)

distributionOne:RegisterRoll(
    playerTwo,
    20,
    Constants.RollSources.NINJALOOT
)

assert(
    distributionOne:IsAwardPending(),
    "Distribution should be waiting for winner selection"
)

distributionOne:SelectWinner(
    playerOne,
    95,
    110
)

distributionOne:Award(
    playerOne,
    120
)

distributionOne:SetAwardSuccess(
    121
)

local distributionTwo =
    Distribution.New(
        itemTwo,
        boss,
        {
            masterLooter,
            playerOne,
            playerTwo,
        },
        masterLooter
    )

session:AddDistribution(
    distributionTwo
)

distributionTwo:RegisterRoll(
    masterLooter,
    10,
    Constants.RollSources.NINJALOOT
)

distributionTwo:RegisterRoll(
    playerOne,
    20,
    Constants.RollSources.NINJALOOT
)

distributionTwo:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

assert(
    distributionTwo:IsAwardPending(),
    "Distribution should be waiting for winner selection"
)

distributionTwo:SelectWinner(
    playerTwo,
    90,
    130
)

distributionTwo:Award(
    playerTwo,
    140
)

distributionTwo:SetAwardSuccess(
    141
)

local distributionThree =
    Distribution.New(
        itemThree,
        boss,
        {
            masterLooter,
            playerOne,
            playerTwo,
        },
        masterLooter
    )

session:AddDistribution(
    distributionThree
)

distributionThree:RegisterRoll(
    masterLooter,
    30,
    Constants.RollSources.NINJALOOT
)

distributionThree:RegisterRoll(
    playerOne,
    20,
    Constants.RollSources.NINJALOOT
)

distributionThree:RegisterRoll(
    playerTwo,
    10,
    Constants.RollSources.NINJALOOT
)

assert(
    distributionThree:IsAwardPending(),
    "Distribution should be waiting for winner selection"
)

distributionThree:SelectWinner(
    masterLooter,
    nil,
    150
)

distributionThree:Award(
    masterLooter,
    160
)

distributionThree:SetAwardFailed(
    "Trade failed",
    161
)

local history =
    HistoryManager.New(
        sessionManager
    )

assert(
    history:GetTotalCount() == 2,
    "Only successfully awarded items should appear in history"
)

local recent =
    history:GetRecent(10)

assert(
    #recent == 2,
    "Recent history should contain two successful awards"
)

assert(
    recent[1].item
    == "Shield of Testing",
    "Most recent distribution should appear first"
)

assert(
    recent[1].recipient
    == "PlayerTwo",
    "History should show the recipient"
)

assert(
    recent[2].item
    == "Sword of Testing",
    "Older distribution should appear second"
)

local page =
    history:GetPage(1, 1)

assert(
    #page == 1,
    "Paged history should return one item"
)

assert(
    page[1].recipient
    == "PlayerOne",
    "Paged history should support offsets"
)
