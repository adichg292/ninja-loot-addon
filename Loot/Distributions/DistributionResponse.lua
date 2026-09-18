local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local Constants = addon.Loot.Distributions.Constants

local DistributionResponse = {}
DistributionResponse.__index = DistributionResponse

local function assertValidPlayer(player)
    assert(
        player ~= nil,
        "Player is required"
    )

    assert(
        getmetatable(player)
        == addon.Loot.Players.Player,
        "Invalid player"
    )
end

local function assertValidResponse(response)
    assert(
        response == Constants.Responses.NEED
        or response == Constants.Responses.PASS,
        "Invalid response"
    )
end

local function assertValidRoll(roll)
    assert(
        roll ~= nil,
        "Roll is required"
    )

    assert(
        type(roll) == "number",
        "Roll must be a number"
    )

    assert(
        roll % 1 == 0,
        "Roll must be an integer"
    )

    assert(
        roll >= 1,
        "Roll must be at least 1"
    )
end

function DistributionResponse.New(
    player,
    response,
    roll,
    rollSource
)
    assertValidPlayer(player)
    assertValidResponse(response)

    if response == Constants.Responses.NEED then
        assertValidRoll(roll)

        assert(
            rollSource ~= nil,
            "Roll source is required for NEED"
        )
    end

    return setmetatable({
        player = player,
        response = response,
        roll = roll,
        rollSource = rollSource,
    }, DistributionResponse)
end

function DistributionResponse:GetPlayer()
    return self.player
end

function DistributionResponse:GetResponse()
    return self.response
end

function DistributionResponse:GetRoll()
    return self.roll
end

function DistributionResponse:GetRollSource()
    return self.rollSource
end

function DistributionResponse:IsNeed()
    return self.response == Constants.Responses.NEED
end

function DistributionResponse:IsPass()
    return self.response == Constants.Responses.PASS
end

function DistributionResponse:SetNeed(roll, rollSource)
    assertValidRoll(roll)

    assert(
        rollSource ~= nil,
        "Roll source is required"
    )

    self.response = Constants.Responses.NEED
    self.roll = roll
    self.rollSource = rollSource

    return self
end

function DistributionResponse:SetPass()
    self.response = Constants.Responses.PASS
    self.roll = nil
    self.rollSource = nil

    return self
end

function DistributionResponse.GetForPlayer(
    responses,
    player
)
    assertValidPlayer(player)

    return responses[player:GetName()]
end

function DistributionResponse.GetAll(responses)
    local result = {}

    for _, response in pairs(responses) do
        table.insert(result, response)
    end

    return result
end

function DistributionResponse.GetNeedResponses(responses)
    local result = {}

    for _, response in pairs(responses) do
        if response:IsNeed() then
            table.insert(result, response)
        end
    end

    return result
end

function DistributionResponse.GetPassResponses(responses)
    local result = {}

    for _, response in pairs(responses) do
        if response:IsPass() then
            table.insert(result, response)
        end
    end

    return result
end

function DistributionResponse.HasCompletedRollResponse(
    responses,
    player
)
    local response =
        DistributionResponse.GetForPlayer(
            responses,
            player
        )

    return response ~= nil
        and response:IsNeed()
end

function DistributionResponse.HasEveryParticipantRolled(
    responses,
    participants
)
    for _, player in ipairs(participants) do
        if not DistributionResponse.HasCompletedRollResponse(
                responses,
                player
            ) then
            return false
        end
    end

    return true
end

function DistributionResponse.CountRestartVotes(
    responses
)
    local count = 0

    for _, response in pairs(responses) do
        if response == Constants.ResultResponses.VOTE_RESTART then
            count = count + 1
        end
    end

    return count
end

function DistributionResponse.HasRestartThreshold(
    responses,
    participantCount
)
    local threshold =
        math.min(
            Constants.RestartVoteThreshold,
            participantCount
        )

    return DistributionResponse.CountRestartVotes(
        responses
    ) >= threshold
end

addon.Loot.Distributions.DistributionResponse =
    DistributionResponse
