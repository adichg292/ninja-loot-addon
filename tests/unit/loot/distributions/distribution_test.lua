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
loadAddonFile("Loot/Bosses/BossManager.lua")
loadAddonFile("Loot/Lifecycles/Lifecycle.lua")
loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")
loadAddonFile("Loot/Distributions/Distribution.lua")

local addon =
    _G.NinjaLoot
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

local Distribution =
    addon.Loot.Distributions.Distribution

local Constants =
    addon.Loot.Distributions.Constants

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local playerThree =
    Player.New("PlayerThree")

local playerFour =
    Player.New("PlayerFour")

local boss =
    Boss.New("Test Boss")

local item =
    Item.New(
        "Test Item",
        12345
    )

local distribution =
    Distribution.New(
        item,
        boss,
        {
            playerOne,
            playerTwo,
            playerThree,
            playerFour,
        },
        playerOne
    )

assert(
    distribution:GetItem() == item,
    "Distribution should reference the Item object"
)

assert(
    distribution:GetBoss() == boss,
    "Distribution should reference the Boss"
)

assert(
    item:GetDistribution() == distribution,
    "Item should reference its Distribution"
)

assert(
    distribution:GetParticipantCount() == 4,
    "Distribution should have four participants"
)

assert(
    distribution:GetRollParticipantCount() == 4,
    "Initial roll should include all participants"
)

distribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerOne,
    95,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerTwo,
    95,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerThree,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerThree,
    80,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerFour,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerFour,
    40,
    Constants.RollSources.NINJALOOT
)

assert(
    distribution:IsRolling(),
    "A tied highest roll should automatically start another rolling round"
)

assert(
    distribution:GetCurrentAttempt() == 2,
    "Tie should create the second attempt"
)

assert(
    distribution:GetRerollCount() == 1,
    "Tie should increment automatic reroll count"
)

assert(
    distribution:GetRestartCount() == 0,
    "Automatic tie reroll must not count as manual restart"
)

assert(
    distribution:GetAttempt(1).outcome
    == "TIE_REROLL",
    "First attempt should record tie reroll outcome"
)

assert(
    #distribution:GetAttempt(1).eligiblePlayers == 2,
    "First tied attempt should record two eligible players"
)

assert(
    distribution:GetRollParticipantCount() == 2,
    "Only tied players should be eligible for the next roll"
)

assert(
    distribution:GetRollParticipants()[1] == playerOne,
    "Player one should remain eligible after the tie"
)

assert(
    distribution:GetRollParticipants()[2] == playerTwo,
    "Player two should remain eligible after the tie"
)

assert(
    distribution:GetRollParticipants()[3] == nil,
    "Non-tied players should no longer be eligible after the tie"
)

local nonTiedResponseSuccess =
    pcall(function()
        distribution:Respond(
            playerThree,
            Constants.Responses.NEED
        )
    end)

assert(
    not nonTiedResponseSuccess,
    "Non-tied players must not be allowed to roll after a tie"
)

distribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerOne,
    72,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerTwo,
    91,
    Constants.RollSources.NINJALOOT
)

assert(
    distribution:IsAwardPending(),
    "Unique highest reroll should finish rolling"
)

assert(
    distribution:GetSuggestedWinner() == playerTwo,
    "Player two should be suggested after winning the reroll"
)

assert(
    distribution:GetCurrentAttempt() == 2,
    "Unique reroll should remain on attempt two"
)

assert(
    distribution:GetRerollCount() == 1,
    "Reroll count should remain one after a unique result"
)

distribution:SelectWinner(
    playerTwo,
    nil,
    100
)

assert(
    distribution:GetWinner() == playerTwo,
    "Selected winner should be stored"
)

assert(
    distribution:GetSelectedRoll() == 91,
    "Selected roll should come from the winning response"
)

distribution:Award(
    playerTwo,
    101
)

assert(
    distribution:IsAwarded(),
    "Distribution should become awarded"
)

assert(
    distribution:IsResult(),
    "Award should begin result phase"
)

distribution:Acknowledge(playerOne)
distribution:Acknowledge(playerTwo)
distribution:Acknowledge(playerThree)
distribution:Acknowledge(playerFour)

assert(
    distribution:IsFinal(),
    "All result acknowledgements should finalize the distribution"
)

assert(
    distribution:GetFinalDecision()
    == Constants.FinalDecisions.ACCEPT,
    "Final decision should be acceptance"
)

local secondItem =
    Item.New(
        "Second Item",
        54321
    )

local secondDistribution =
    Distribution.New(
        secondItem,
        boss,
        {
            playerOne,
            playerTwo,
            playerThree,
        },
        playerOne
    )

secondDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerOne,
    100,
    Constants.RollSources.NINJALOOT
)

secondDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerTwo,
    100,
    Constants.RollSources.NINJALOOT
)

secondDistribution:Respond(
    playerThree,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerThree,
    10,
    Constants.RollSources.NINJALOOT
)

assert(
    secondDistribution:GetCurrentAttempt() == 2,
    "Second tie should create a new attempt"
)

assert(
    secondDistribution:GetRerollCount() == 1,
    "Second distribution should have one reroll"
)

assert(
    secondDistribution:GetRollParticipantCount() == 2,
    "Second distribution should narrow the eligible players"
)

secondDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerOne,
    88,
    Constants.RollSources.NINJALOOT
)

secondDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerTwo,
    88,
    Constants.RollSources.NINJALOOT
)

assert(
    secondDistribution:IsRolling(),
    "A second tie should automatically create another roll"
)

assert(
    secondDistribution:GetCurrentAttempt() == 3,
    "Second tie should create the third attempt"
)

assert(
    secondDistribution:GetRerollCount() == 2,
    "Reroll count should increase for every tie"
)

assert(
    secondDistribution:GetRollParticipantCount() == 2,
    "Only the tied players from the second reroll should remain"
)

assert(
    secondDistribution:GetAttempt(2).outcome
    == "TIE_REROLL",
    "Second attempt should record its tie"
)

secondDistribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerOne,
    50,
    Constants.RollSources.NINJALOOT
)

secondDistribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

secondDistribution:RegisterRoll(
    playerTwo,
    75,
    Constants.RollSources.NINJALOOT
)

assert(
    secondDistribution:IsAwardPending(),
    "Third attempt should finish when the tie is broken"
)

assert(
    secondDistribution:GetSuggestedWinner()
    == playerTwo,
    "Final unique highest roll should be suggested"
)

local manualRestartItem =
    Item.New(
        "Manual Restart Item"
    )

local manualRestart =
    Distribution.New(
        manualRestartItem,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

manualRestart:Respond(
    playerOne,
    Constants.Responses.NEED
)

manualRestart:RegisterRoll(
    playerOne,
    90,
    Constants.RollSources.NINJALOOT
)

manualRestart:Respond(
    playerTwo,
    Constants.Responses.NEED
)

manualRestart:RegisterRoll(
    playerTwo,
    50,
    Constants.RollSources.NINJALOOT
)

manualRestart:SelectWinner(
    playerOne,
    nil,
    200
)

manualRestart:Award(
    playerOne,
    201
)

manualRestart:VoteRestart(playerOne)
manualRestart:VoteRestart(playerTwo)

assert(
    manualRestart:HasRestartThreshold(),
    "Manual restart votes should still work"
)

manualRestart:Restart(202)

assert(
    manualRestart:GetCurrentAttempt() == 2,
    "Manual restart should create a new attempt"
)

assert(
    manualRestart:GetRestartCount() == 1,
    "Manual restart should increment restart count"
)

assert(
    manualRestart:GetRerollCount() == 0,
    "Manual restart should not increment automatic reroll count"
)

assert(
    manualRestart:GetAttempt(1).outcome
    == "MANUAL_RESTART",
    "Manual restart should be distinguishable from tie reroll"
)
