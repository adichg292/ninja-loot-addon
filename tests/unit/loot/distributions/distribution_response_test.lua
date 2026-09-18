local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile("Loot/Players/Player.lua")
loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Player =
    addon.Loot.Players.Player

local Constants =
    addon.Loot.Distributions.Constants

local DistributionResponse =
    addon.Loot.Distributions.DistributionResponse

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local needResponse =
    DistributionResponse.New(
        playerOne,
        Constants.Responses.NEED,
        87,
        Constants.RollSources.NINJALOOT
    )

assert(
    needResponse:GetPlayer() == playerOne,
    "Response should store the player"
)

assert(
    needResponse:GetResponse()
    == Constants.Responses.NEED,
    "Response should store NEED"
)

assert(
    needResponse:IsNeed(),
    "Response should identify as NEED"
)

assert(
    not needResponse:IsPass(),
    "NEED response should not identify as PASS"
)

assert(
    needResponse:GetRoll() == 87,
    "Response should store the roll"
)

assert(
    needResponse:GetRollSource()
    == Constants.RollSources.NINJALOOT,
    "Response should store the roll source"
)

local chatResponse =
    DistributionResponse.New(
        playerTwo,
        Constants.Responses.NEED,
        64,
        Constants.RollSources.CHAT
    )

assert(
    chatResponse:GetRoll() == 64,
    "Chat roll should be stored"
)

assert(
    chatResponse:GetRollSource()
    == Constants.RollSources.CHAT,
    "Chat response should use CHAT source"
)

local passResponse =
    DistributionResponse.New(
        playerTwo,
        Constants.Responses.PASS
    )

assert(
    passResponse:IsPass(),
    "PASS response should identify as PASS"
)

assert(
    not passResponse:IsNeed(),
    "PASS response should not identify as NEED"
)

assert(
    passResponse:GetRoll() == nil,
    "PASS response should not have a roll"
)

assert(
    passResponse:GetRollSource() == nil,
    "PASS response should not have a roll source"
)

needResponse:SetPass()

assert(
    needResponse:IsPass(),
    "SetPass should change response to PASS"
)

assert(
    needResponse:GetRoll() == nil,
    "SetPass should clear the roll"
)

assert(
    needResponse:GetRollSource() == nil,
    "SetPass should clear the roll source"
)

needResponse:SetNeed(
    99,
    Constants.RollSources.CHAT
)

assert(
    needResponse:IsNeed(),
    "SetNeed should change response to NEED"
)

assert(
    needResponse:GetRoll() == 99,
    "SetNeed should update the roll"
)

assert(
    needResponse:GetRollSource()
    == Constants.RollSources.CHAT,
    "SetNeed should update the roll source"
)

local responses = {
    [playerOne:GetName()] =
        DistributionResponse.New(
            playerOne,
            Constants.Responses.NEED,
            100,
            Constants.RollSources.NINJALOOT
        ),

    [playerTwo:GetName()] =
        DistributionResponse.New(
            playerTwo,
            Constants.Responses.PASS
        ),
}

assert(
    DistributionResponse.GetForPlayer(
        responses,
        playerOne
    ) ~= nil,
    "GetForPlayer should find an existing response"
)

assert(
    DistributionResponse.GetForPlayer(
        responses,
        playerTwo
    ) ~= nil,
    "GetForPlayer should find PASS response"
)

assert(
    DistributionResponse.GetForPlayer(
        responses,
        Player.New("Missing")
    ) == nil,
    "GetForPlayer should return nil for missing player"
)

local allResponses =
    DistributionResponse.GetAll(
        responses
    )

assert(
    #allResponses == 2,
    "GetAll should return all responses"
)

local needResponses =
    DistributionResponse.GetNeedResponses(
        responses
    )

assert(
    #needResponses == 1,
    "GetNeedResponses should return only NEED responses"
)

assert(
    needResponses[1]:GetPlayer() == playerOne,
    "GetNeedResponses should return the correct player"
)

local passResponses =
    DistributionResponse.GetPassResponses(
        responses
    )

assert(
    #passResponses == 1,
    "GetPassResponses should return only PASS responses"
)

assert(
    passResponses[1]:GetPlayer() == playerTwo,
    "GetPassResponses should return the correct player"
)

assert(
    DistributionResponse.HasCompletedRollResponse(
        responses,
        playerOne
    ),
    "NEED should count as a completed roll"
)

assert(
    not DistributionResponse.HasCompletedRollResponse(
        responses,
        playerTwo
    ),
    "PASS should not count as a completed roll"
)

assert(
    DistributionResponse.HasEveryParticipantRolled(
        responses,
        {
            playerOne,
            playerTwo,
        }
    ) == false,
    "All participants should not count as rolled when one passed"
)

responses[playerTwo:GetName()] =
    DistributionResponse.New(
        playerTwo,
        Constants.Responses.NEED,
        75,
        Constants.RollSources.CHAT
    )

assert(
    DistributionResponse.HasEveryParticipantRolled(
        responses,
        {
            playerOne,
            playerTwo,
        }
    ),
    "All NEED responses should count as completed rolls"
)

local resultResponses = {
    [playerOne:GetName()] =
        Constants.ResultResponses.ACKNOWLEDGE,

    [playerTwo:GetName()] =
        Constants.ResultResponses.VOTE_RESTART,
}

assert(
    DistributionResponse.CountRestartVotes(
        resultResponses
    ) == 1,
    "Restart vote count should be one"
)

assert(
    not DistributionResponse.HasRestartThreshold(
        resultResponses,
        2
    ),
    "One vote should not reach the threshold for two participants"
)

resultResponses[playerOne:GetName()] =
    Constants.ResultResponses.VOTE_RESTART

assert(
    DistributionResponse.HasRestartThreshold(
        resultResponses,
        2
    ),
    "Two votes should reach the threshold for two participants"
)

assert(
    DistributionResponse.HasRestartThreshold(
        resultResponses,
        4
    ) == false,
    "Two votes should not reach the threshold for four participants"
)

assert(
    DistributionResponse.HasRestartThreshold(
        resultResponses,
        1
    ),
    "Threshold should never exceed participant count"
)
