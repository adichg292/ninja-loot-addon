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
loadAddonFile("Loot/Sessions/SessionManager.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Player =
    addon.Loot.Players.Player

local Item =
    addon.Loot.Items.Item

local Boss =
    addon.Loot.Bosses.Boss

local SessionManager =
    addon.Loot.Sessions.SessionManager

local Distribution =
    addon.Loot.Distributions.Distribution

local Constants =
    addon.Loot.Distributions.Constants

local playerOne = Player.New(
    "PlayerOne"
)

local playerTwo = Player.New(
    "PlayerTwo"
)

local boss = Boss.New(
    "Test Boss"
)

local sessionManager =
    SessionManager.New()

local session =
    sessionManager:Create(
        "ROLL-EVENT-TEST",
        "ROUND_ROBIN",
        playerOne
    )

local item = Item.New("Test Item")

session:AddPlayer(playerOne)
session:AddPlayer(playerTwo)
session:AddBoss(boss)

local distribution =
    Distribution.New(
        item,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

session:AddDistribution(
    distribution
)

addon.sessionManager =
    sessionManager

loadAddonFile("Core.lua")

assert(
    addon.Events ~= nil,
    "Core event system should be created"
)

assert(
    addon.Events.Frame ~= nil,
    "Core event frame should be created"
)

assert(
    addon.Events.Frame.events.CHAT_MSG_SYSTEM == true,
    "Core should register CHAT_MSG_SYSTEM"
)

TriggerEvent(
    "CHAT_MSG_SYSTEM",
    "PlayerOne rolls 87 (1-100)"
)

local response =
    distribution:GetResponse(playerOne)

assert(
    response ~= nil,
    "Chat roll should create a distribution response"
)

assert(
    response:IsNeed(),
    "Chat roll should create a NEED response"
)

assert(
    response:GetRoll() == 87,
    "Chat roll should store the rolled value"
)

assert(
    response:GetRollSource()
    == Constants.RollSources.CHAT,
    "Chat roll should use CHAT source"
)

TriggerEvent(
    "CHAT_MSG_SYSTEM",
    "PlayerOne rolls 42 (1-100)"
)

assert(
    distribution:GetResponse(playerOne):GetRoll() == 87,
    "A second roll should not replace the first valid roll"
)

TriggerEvent(
    "CHAT_MSG_SYSTEM",
    "PlayerTwo rolls 73 (1-100)"
)

assert(
    distribution:GetResponse(playerTwo) ~= nil,
    "Second participant roll should be registered"
)

assert(
    distribution:GetResponse(playerTwo):GetRoll() == 73,
    "Second participant roll should be stored"
)

assert(
    distribution:IsAwardPending(),
    "All participant rolls should finish rolling"
)

TriggerEvent(
    "CHAT_MSG_SYSTEM",
    "RandomPlayer rolls 99 (1-100)"
)

assert(
    distribution:GetResponse(playerOne):GetRoll() == 87,
    "Unrelated player rolls should not modify the distribution"
)

TriggerEvent(
    "CHAT_MSG_SYSTEM",
    "PlayerOne rolls 100 (1-50)"
)

assert(
    distribution:GetResponse(playerOne):GetRoll() == 87,
    "Non-1-100 rolls should be ignored"
)
