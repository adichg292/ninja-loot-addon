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

local winnerItem =
    Item.New("Winner Item")

local winnerDistribution =
    Distribution.New(
        winnerItem,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

winnerDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

winnerDistribution:RegisterRoll(
    playerOne,
    40,
    Constants.RollSources.NINJALOOT
)

winnerDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

winnerDistribution:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

assert(
    winnerDistribution:IsAwardPending(),
    "Winner distribution should wait for award"
)

assert(
    winnerDistribution:GetWinner() == nil,
    "Winner should not be selected before AwardWinner"
)

local winnerHandlerCalled = false

local winnerService =
    AwardService.New()

winnerService:RegisterHandler(
    Constants.AwardMethods.LOOT,
    function(receivedDistribution)
        winnerHandlerCalled = true

        assert(
            receivedDistribution
            == winnerDistribution,
            "AwardWinner should pass the correct distribution"
        )

        return true
    end
)

local winnerSuccess =
    winnerService:AwardWinner(
        winnerDistribution,
        Constants.AwardMethods.LOOT,
        300,
        301
    )

assert(
    winnerSuccess,
    "AwardWinner should succeed"
)

assert(
    winnerHandlerCalled,
    "AwardWinner should invoke the registered handler"
)

assert(
    winnerDistribution:GetWinner()
        == playerTwo,
    "AwardWinner should use the suggested winner"
)

assert(
    winnerDistribution:GetSelectedRoll()
        == 90,
    "AwardWinner should preserve the winning roll"
)

assert(
    winnerDistribution:IsAwarded(),
    "AwardWinner should transition distribution to awarded state"
)

assert(
    winnerDistribution:IsResult(),
    "AwardWinner should enter result phase"
)

assert(
    winnerDistribution:GetAward().state
        == Constants.AwardStates.SUCCESS,
    "AwardWinner should record successful award"
)

local duplicateSuccess =
    pcall(function()
        winnerService:Award(
            winnerDistribution,
            Constants.AwardMethods.LOOT,
            302
        )
    end)

assert(
    not duplicateSuccess,
    "Successful distribution must reject a second award"
)

local noWinnerItem =
    Item.New("No Winner Item")

local noWinnerDistribution =
    Distribution.New(
        noWinnerItem,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

local noWinnerService =
    AwardService.New()

noWinnerService:RegisterHandler(
    Constants.AwardMethods.LOOT,
    function()
        return true
    end
)

local noWinnerSuccess =
    pcall(function()
        noWinnerService:AwardWinner(
            noWinnerDistribution,
            Constants.AwardMethods.LOOT,
            400,
            401
        )
    end)

assert(
    not noWinnerSuccess,
    "AwardWinner should reject a distribution that is still rolling"
)

local unavailableItem =
    Item.New("Unavailable Item")

local unavailableDistribution =
    Distribution.New(
        unavailableItem,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

unavailableDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

unavailableDistribution:RegisterRoll(
    playerOne,
    80,
    Constants.RollSources.NINJALOOT
)

unavailableDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

unavailableDistribution:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

unavailableDistribution:SelectWinner(
    playerTwo,
    90,
    500
)

local unavailableLootManager = {
    VerifyDistributionItem = function()
        return false,
            "Item is no longer available"
    end,
}

local unavailableService =
    AwardService.New(
        unavailableLootManager
    )

unavailableService:RegisterHandler(
    Constants.AwardMethods.LOOT,
    function()
        return true
    end
)

local unavailableSuccess =
    pcall(function()
        unavailableService:Award(
            unavailableDistribution,
            Constants.AwardMethods.LOOT,
            501
        )
    end)

assert(
    not unavailableSuccess,
    "Unavailable loot must reject award"
)