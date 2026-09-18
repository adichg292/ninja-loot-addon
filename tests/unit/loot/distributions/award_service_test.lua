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
loadAddonFile("Loot/Distributions/AwardService.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

local Player =
    addon.Loot.Players.Player

local Item =
    addon.Loot.Items.Item

local Boss =
    addon.Loot.Bosses.Boss

local Constants =
    addon.Loot.Distributions.Constants

local Distribution =
    addon.Loot.Distributions.Distribution

local AwardService =
    addon.Loot.Distributions.AwardService

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local boss =
    Boss.New("Test Boss")

local item = Item.New("Test Item")

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

distribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerOne,
    80,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

distribution:SelectWinner(
    playerTwo,
    nil,
    100
)

distribution:Award(
    playerTwo,
    101
)

local service =
    AwardService.New()

local handlerCalled = false

service:RegisterHandler(
    Constants.AwardMethods.LOOT,
    function(receivedDistribution)
        handlerCalled = true

        assert(
            receivedDistribution == distribution,
            "Handler should receive the correct distribution"
        )

        return true
    end
)

assert(
    service:HasHandler(
        Constants.AwardMethods.LOOT
    ),
    "Registered handler should be available"
)

local success =
    service:Award(
        distribution,
        Constants.AwardMethods.LOOT,
        102
    )

assert(
    success,
    "Successful handler should return true"
)

assert(
    handlerCalled,
    "Registered handler should be called"
)

assert(
    distribution:GetAward().state
    == Constants.AwardStates.SUCCESS,
    "Successful award should be recorded"
)

assert(
    distribution:GetAward().method
    == Constants.AwardMethods.LOOT,
    "Award method should be recorded"
)

assert(
    distribution:GetAward().completedAt == 102,
    "Award completion time should be recorded"
)

local failedDistribution =
    Distribution.New(
        Item.New("Failed Item"),
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

failedDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

failedDistribution:RegisterRoll(
    playerOne,
    40,
    Constants.RollSources.NINJALOOT
)

failedDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

failedDistribution:RegisterRoll(
    playerTwo,
    50,
    Constants.RollSources.NINJALOOT
)

failedDistribution:SelectWinner(
    playerTwo,
    nil,
    200
)

failedDistribution:Award(
    playerTwo,
    201
)

local failureService =
    AwardService.New()

failureService:RegisterHandler(
    Constants.AwardMethods.TRADE,
    function()
        return false, "Recipient unavailable"
    end
)

local failureResult =
    failureService:Award(
        failedDistribution,
        Constants.AwardMethods.TRADE,
        202
    )

assert(
    not failureResult,
    "Failed handler should return false"
)

assert(
    failedDistribution:GetAward().state
    == Constants.AwardStates.FAILED,
    "Failed award should be recorded"
)

assert(
    failedDistribution:GetAward().error
    == "Recipient unavailable",
    "Award failure reason should be recorded"
)

local missingHandlerService =
    AwardService.New()

local missingHandlerSuccess =
    pcall(function()
        missingHandlerService:Award(
            failedDistribution,
            Constants.AwardMethods.LOOT,
            203
        )
    end)

assert(
    not missingHandlerSuccess,
    "Award without a handler should be rejected"
)
