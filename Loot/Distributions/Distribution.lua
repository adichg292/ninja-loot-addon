local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local DistributionResponse =
    addon.Loot.Distributions.DistributionResponse

local DistributionPhase =
    addon.Loot.Distributions.DistributionPhase

local Distribution = {}
Distribution.__index = Distribution

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

local function containsPlayer(
    participants,
    player
)
    for _, participant in ipairs(participants) do
        if participant == player then
            return true
        end
    end

    return false
end

local function assertParticipant(
    participants,
    player
)
    assertValidPlayer(player)

    assert(
        containsPlayer(
            participants,
            player
        ),
        "Player is not a participant"
    )
end

local function assertValidItem(item)
    assert(
        item ~= nil,
        "Item is required"
    )

    assert(
        getmetatable(item)
        == addon.Loot.Items.Item,
        "Invalid item"
    )
end

local function assertValidBoss(boss)
    assert(
        boss ~= nil,
        "Boss is required"
    )

    assert(
        getmetatable(boss)
        == addon.Loot.Bosses.Boss,
        "Invalid boss"
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
        roll >= 1
        and roll <= 100,
        "Roll must be between 1 and 100"
    )
end

function Distribution.New(
    item,
    boss,
    participants,
    masterLooter
)
    assertValidItem(item)
    assertValidBoss(boss)

    assert(
        participants ~= nil,
        "Participants are required"
    )

    assert(
        masterLooter ~= nil,
        "Master looter is required"
    )

    assert(
        #participants > 0,
        "At least one participant is required"
    )

    local participantSnapshot = {}

    for _, player in ipairs(participants) do
        assertValidPlayer(player)

        table.insert(
            participantSnapshot,
            player
        )
    end

    assertParticipant(
        participantSnapshot,
        masterLooter
    )

    local distribution =
        setmetatable({
            item = item,
            boss = boss,
            masterLooter = masterLooter,

            participants = participantSnapshot,
            rollParticipants = participantSnapshot,

            state = Constants.States.PENDING,

            phaseName = Constants.Phases.ROLLING,

            phase = DistributionPhase.New(
                Constants.Phases.ROLLING
            ),

            responses = {},
            resultResponses = {},

            winner = nil,
            suggestedWinner = nil,

            selectedRoll = nil,
            selectedAt = nil,
            awardedAt = nil,

            resultFinalized = false,
            finalDecision = nil,
            finalDecisionAt = nil,

            rollGraceActive = false,
            rollGraceElapsed = 0,

            pendingRolls = {},

            attempts = {
                {
                    number = 1,
                    responses = {},
                    winner = nil,
                    selectedRoll = nil,
                    rollGraceUsed = false,
                    outcome = nil,
                    eligiblePlayers = {},
                },
            },

            currentAttempt = 1,
            restartCount = 0,
            rerollCount = 0,

            award = nil,
        }, Distribution)

    item:SetDistribution(
        distribution
    )

    return distribution
end

function Distribution:GetItem()
    return self.item
end

function Distribution:GetBoss()
    return self.boss
end

function Distribution:GetMasterLooter()
    return self.masterLooter
end

function Distribution:GetParticipants()
    return self.participants
end

function Distribution:GetParticipantCount()
    return #self.participants
end

function Distribution:GetRollParticipants()
    return self.rollParticipants
end

function Distribution:GetRollParticipantCount()
    return #self.rollParticipants
end

function Distribution:GetState()
    return self.state
end

function Distribution:GetPhase()
    return self.phaseName
end

function Distribution:IsPending()
    return self.state
        == Constants.States.PENDING
end

function Distribution:IsAwarded()
    return self.state
        == Constants.States.AWARDED
end

function Distribution:IsCancelled()
    return self.state
        == Constants.States.CANCELLED
end

function Distribution:IsRolling()
    return self:GetPhase()
        == Constants.Phases.ROLLING
end

function Distribution:IsAwardPending()
    return self:GetPhase()
        == Constants.Phases.AWARD_PENDING
end

function Distribution:IsResult()
    return self:GetPhase()
        == Constants.Phases.RESULT
end

function Distribution:IsFinal()
    return self:GetPhase()
        == Constants.Phases.FINAL
end

function Distribution:IsPhaseExpired()
    if self.phase == nil then
        return false
    end

    return self.phase:IsExpired()
end

function Distribution:GetElapsed()
    if self.phase == nil then
        return 0
    end

    return self.phase:GetElapsed()
end

function Distribution:GetRemaining()
    if self.phase == nil then
        return 0
    end

    return self.phase:GetRemaining()
end

function Distribution:IsRollGraceActive()
    return self.rollGraceActive
end

function Distribution:GetRollGraceElapsed()
    return self.rollGraceElapsed
end

function Distribution:GetCurrentAttempt()
    return self.currentAttempt
end

function Distribution:GetRestartCount()
    return self.restartCount
end

function Distribution:GetRerollCount()
    return self.rerollCount
end

function Distribution:GetAttempts()
    return self.attempts
end

function Distribution:GetAttempt(index)
    return self.attempts[index]
end

function Distribution:GetWinner()
    return self.winner
end

function Distribution:GetSuggestedWinner()
    return self.suggestedWinner
end

function Distribution:GetSelectedRoll()
    return self.selectedRoll
end

function Distribution:GetSelectedAt()
    return self.selectedAt
end

function Distribution:GetAwardedAt()
    return self.awardedAt
end

function Distribution:GetFinalDecision()
    return self.finalDecision
end

function Distribution:GetFinalDecisionAt()
    return self.finalDecisionAt
end

function Distribution:GetAward()
    return self.award
end

function Distribution:GetResponse(player)
    assertParticipant(
        self.participants,
        player
    )

    return DistributionResponse.GetForPlayer(
        self.responses,
        player
    )
end

function Distribution:GetResponses()
    return DistributionResponse.GetAll(
        self.responses
    )
end

function Distribution:GetNeedResponses()
    return DistributionResponse.GetNeedResponses(
        self.responses
    )
end

function Distribution:GetPassResponses()
    return DistributionResponse.GetPassResponses(
        self.responses
    )
end

function Distribution:GetPendingRoll(player)
    assertParticipant(
        self.rollParticipants,
        player
    )

    return self.pendingRolls[
    player:GetName()
    ]
end

function Distribution:HasPendingRoll(player)
    return self:GetPendingRoll(player) ~= nil
end

function Distribution:BeginRoll(player)
    assertParticipant(
        self.rollParticipants,
        player
    )

    assert(
        self:IsPending(),
        "Distribution is not pending"
    )

    assert(
        self:IsRolling(),
        "Distribution is not rolling"
    )

    assert(
        not self.rollGraceActive,
        "Roll grace is active"
    )

    local name = player:GetName()

    assert(
        self.pendingRolls[name] == nil,
        "Player already has a pending roll"
    )

    self.pendingRolls[name] = true

    return self
end

function Distribution:Respond(
    player,
    response
)
    assertParticipant(
        self.rollParticipants,
        player
    )

    assert(
        self:IsPending(),
        "Distribution is not pending"
    )

    assert(
        self:IsRolling(),
        "Distribution is not rolling"
    )

    assert(
        not self.rollGraceActive,
        "Responses are closed during roll grace"
    )

    assert(
        response == Constants.Responses.NEED
        or response == Constants.Responses.PASS,
        "Invalid response"
    )

    local name = player:GetName()
    local existing = self.responses[name]

    if response == Constants.Responses.PASS then
        self.responses[name] =
            DistributionResponse.New(
                player,
                Constants.Responses.PASS
            )

        self.pendingRolls[name] = nil

        self:EvaluateRollingCompletion()

        return self
    end

    if existing ~= nil
        and existing:IsNeed()
    then
        return self
    end

    self:BeginRoll(player)

    RandomRoll(1, 100)

    return self
end

function Distribution:RegisterRoll(
    player,
    roll,
    source
)
    assertParticipant(
        self.rollParticipants,
        player
    )

    assert(
        self:IsPending(),
        "Distribution is not pending"
    )

    assert(
        self:IsRolling(),
        "Distribution is not rolling"
    )

    assertValidRoll(roll)

    assert(
        source ~= nil,
        "Roll source is required"
    )

    local name = player:GetName()
    local existing = self.responses[name]

    if existing ~= nil
        and existing:IsNeed()
    then
        self.pendingRolls[name] = nil

        return false
    end

    self.responses[name] =
        DistributionResponse.New(
            player,
            Constants.Responses.NEED,
            roll,
            source
        )

    self.pendingRolls[name] = nil

    self:EvaluateRollingCompletion()

    return true
end

function Distribution:EvaluateRollingCompletion()
    if not self:IsRolling() then
        return false
    end

    if self.rollGraceActive then
        return false
    end

    if not DistributionResponse.HasEveryParticipantRolled(
            self.responses,
            self.rollParticipants
        ) then
        return false
    end

    if self.phase ~= nil then
        self.phase:Expire()
    end

    self.rollGraceActive = false
    self.rollGraceElapsed = 0

    self:FinishRolling()

    return true
end

function Distribution:FinishRolling()
    assert(
        self:IsRolling(),
        "Distribution is not rolling"
    )

    local highestRoll = nil
    local highestPlayers = {}

    -- Iterate through rollParticipants instead of the
    -- response table so participant ordering remains stable.
    for _, player in ipairs(
        self.rollParticipants
    ) do
        local response =
            self.responses[player:GetName()]

        if response ~= nil
            and response:IsNeed()
        then
            local roll =
                response:GetRoll()

            if highestRoll == nil
                or roll > highestRoll
            then
                highestRoll = roll

                highestPlayers = {
                    player,
                }
            elseif roll == highestRoll then
                table.insert(
                    highestPlayers,
                    player
                )
            end
        end
    end

    if #highestPlayers > 1 then
        self:StartTieReroll(
            highestPlayers
        )

        return self
    end

    self.phaseName =
        Constants.Phases.AWARD_PENDING

    self.phase = nil

    self.pendingRolls = {}

    self:SuggestWinner()

    return self
end

function Distribution:StartTieReroll(
    tiedPlayers
)
    assert(
        self:IsRolling(),
        "Distribution is not rolling"
    )

    assert(
        tiedPlayers ~= nil,
        "Tied players are required"
    )

    assert(
        #tiedPlayers > 1,
        "At least two tied players are required"
    )

    local previousAttempt =
        self.attempts[self.currentAttempt]

    previousAttempt.responses =
        self:GetResponses()

    previousAttempt.winner = nil
    previousAttempt.selectedRoll = nil

    previousAttempt.rollGraceUsed =
        self.rollGraceElapsed > 0

    previousAttempt.outcome =
    "TIE_REROLL"

    previousAttempt.eligiblePlayers = {}

    for _, player in ipairs(tiedPlayers) do
        table.insert(
            previousAttempt.eligiblePlayers,
            player:GetName()
        )
    end

    self.currentAttempt =
        self.currentAttempt + 1

    self.rerollCount =
        self.rerollCount + 1

    self.attempts[self.currentAttempt] = {
        number = self.currentAttempt,
        responses = {},
        winner = nil,
        selectedRoll = nil,
        rollGraceUsed = false,
        outcome = nil,
        eligiblePlayers = {},
    }

    for _, player in ipairs(tiedPlayers) do
        table.insert(
            self.attempts[self.currentAttempt].eligiblePlayers,
            player:GetName()
        )
    end

    self.rollParticipants = {}

    for _, player in ipairs(tiedPlayers) do
        table.insert(
            self.rollParticipants,
            player
        )
    end

    self.responses = {}
    self.resultResponses = {}
    self.pendingRolls = {}

    self.winner = nil
    self.suggestedWinner = nil
    self.selectedRoll = nil
    self.selectedAt = nil
    self.awardedAt = nil

    self.award = nil

    self.state =
        Constants.States.PENDING

    self.phaseName =
        Constants.Phases.ROLLING

    self.phase =
        DistributionPhase.New(
            Constants.Phases.ROLLING
        )

    self.rollGraceActive = false
    self.rollGraceElapsed = 0

    self.resultFinalized = false
    self.finalDecision = nil
    self.finalDecisionAt = nil

    return self
end

function Distribution:SuggestWinner()
    local bestResponse = nil

    for _, response in ipairs(
        self:GetNeedResponses()
    ) do
        if bestResponse == nil
            or response:GetRoll()
            > bestResponse:GetRoll()
        then
            bestResponse = response
        end
    end

    if bestResponse ~= nil then
        self.suggestedWinner =
            bestResponse:GetPlayer()
    else
        self.suggestedWinner =
            self.masterLooter
    end

    return self.suggestedWinner
end

function Distribution:SelectWinner(
    player,
    roll,
    selectedAt
)
    assertParticipant(
        self.participants,
        player
    )

    assert(
        self:IsAwardPending(),
        "Distribution is not waiting for winner selection"
    )

    local response =
        self:GetResponse(player)

    assert(
        player == self.masterLooter
        or (
            response ~= nil
            and response:IsNeed()
        ),
        "Winner must have a NEED response"
    )

    if roll == nil
        and response ~= nil
    then
        roll = response:GetRoll()
    end

    self.winner = player
    self.selectedRoll = roll
    self.selectedAt = selectedAt

    return self
end

function Distribution:StartResult()
    assert(
        self:IsAwarded(),
        "Distribution must be awarded before result"
    )

    self.phaseName =
        Constants.Phases.RESULT

    self.phase =
        DistributionPhase.New(
            Constants.Phases.RESULT
        )

    self.resultResponses = {}

    self.resultFinalized = false
    self.finalDecision = nil
    self.finalDecisionAt = nil

    return self
end

function Distribution:Award(
    player,
    awardedAt
)
    assertParticipant(
        self.participants,
        player
    )

    assert(
        self:IsAwardPending(),
        "Distribution is not waiting for award"
    )

    assert(
        self.winner == player,
        "Player must be the selected winner"
    )

    self.state =
        Constants.States.AWARDED

    self.awardedAt = awardedAt

    self.award = {
        state = Constants.AwardStates.PENDING,
        method = nil,
        recipient = player,
        startedAt = awardedAt,
        completedAt = nil,
        error = nil,
    }

    self:StartResult()

    return self
end

function Distribution:SetAwardPending(
    method,
    startedAt
)
    assert(
        self:IsAwarded(),
        "Distribution must be awarded before setting award state"
    )

    assert(
        self.award ~= nil,
        "Award record does not exist"
    )

    assert(
        method ~= nil,
        "Award method is required"
    )

    self.award.state =
        Constants.AwardStates.PENDING

    self.award.method = method
    self.award.startedAt = startedAt
    self.award.completedAt = nil
    self.award.error = nil

    return self
end

function Distribution:SetAwardSuccess(
    completedAt
)
    assert(
        self:IsAwarded(),
        "Distribution must be awarded before completing award"
    )

    assert(
        self.award ~= nil,
        "Award record does not exist"
    )

    self.award.state =
        Constants.AwardStates.SUCCESS

    self.award.completedAt =
        completedAt

    self.award.error = nil

    return self
end

function Distribution:SetAwardFailed(
    errorMessage,
    completedAt
)
    assert(
        self:IsAwarded(),
        "Distribution must be awarded before failing award"
    )

    assert(
        self.award ~= nil,
        "Award record does not exist"
    )

    assert(
        errorMessage ~= nil,
        "Award failure reason is required"
    )

    self.award.state =
        Constants.AwardStates.FAILED

    self.award.completedAt =
        completedAt

    self.award.error =
        errorMessage

    return self
end

function Distribution:Acknowledge(player)
    assertParticipant(
        self.participants,
        player
    )

    assert(
        self:IsResult(),
        "Distribution is not in result phase"
    )

    assert(
        not self.phase:IsExpired(),
        "Result phase has expired"
    )

    self.resultResponses[player:GetName()] =
        Constants.ResultResponses.ACKNOWLEDGE

    self:EvaluateResultCompletion()

    return self
end

function Distribution:VoteRestart(player)
    assertParticipant(
        self.participants,
        player
    )

    assert(
        self:IsResult(),
        "Distribution is not in result phase"
    )

    assert(
        not self.phase:IsExpired(),
        "Result phase has expired"
    )

    self.resultResponses[player:GetName()] =
        Constants.ResultResponses.VOTE_RESTART

    self:EvaluateResultCompletion()

    return self
end

function Distribution:GetResultResponse(player)
    assertParticipant(
        self.participants,
        player
    )

    return self.resultResponses[
    player:GetName()
    ]
end

function Distribution:GetResultResponses()
    return self.resultResponses
end

function Distribution:GetRestartVoteCount()
    local count = 0

    for _, response in pairs(
        self.resultResponses
    ) do
        if response
            == Constants.ResultResponses.VOTE_RESTART
        then
            count = count + 1
        end
    end

    return count
end

function Distribution:GetRestartThreshold()
    return math.min(
        Constants.RestartVoteThreshold,
        #self.participants
    )
end

function Distribution:HasRestartThreshold()
    return self:GetRestartVoteCount()
        >= self:GetRestartThreshold()
end

function Distribution:HasEveryoneRespondedToResult()
    local count = 0

    for _ in pairs(
        self.resultResponses
    ) do
        count = count + 1
    end

    return count >= #self.participants
end

function Distribution:EvaluateResultCompletion()
    if not self:IsResult() then
        return false
    end

    if not self:HasEveryoneRespondedToResult() then
        return false
    end

    if self:HasRestartThreshold() then
        return false
    end

    self:FinalizeResult(
        Constants.FinalDecisions.ACCEPT
    )

    return true
end

function Distribution:FinalizeResult(
    decision
)
    assert(
        self:IsResult(),
        "Distribution is not in result phase"
    )

    assert(
        decision == nil
        or decision == Constants.FinalDecisions.ACCEPT,
        "Invalid final decision"
    )

    self.phaseName =
        Constants.Phases.FINAL

    self.phase = nil

    self.resultFinalized = true

    if decision ~= nil then
        self.finalDecision = decision
    end

    return self
end

function Distribution:AcceptResult(
    decidedAt
)
    assert(
        self:IsResult(),
        "Distribution is not in result phase"
    )

    self.finalDecision =
        Constants.FinalDecisions.ACCEPT

    self.finalDecisionAt =
        decidedAt

    self:FinalizeResult(
        Constants.FinalDecisions.ACCEPT
    )

    return self
end

function Distribution:Restart(decidedAt)
    assert(
        self:IsResult(),
        "Distribution is not in result phase"
    )

    assert(
        self:HasRestartThreshold(),
        "Restart threshold has not been reached"
    )

    local previousAttempt =
        self.attempts[self.currentAttempt]

    previousAttempt.responses =
        self:GetResponses()

    previousAttempt.winner =
        self.winner

    previousAttempt.selectedRoll =
        self.selectedRoll

    previousAttempt.rollGraceUsed =
        self.rollGraceElapsed > 0

    previousAttempt.outcome =
    "MANUAL_RESTART"

    previousAttempt.completedAt =
        decidedAt

    self.currentAttempt =
        self.currentAttempt + 1

    self.restartCount =
        self.restartCount + 1

    self.attempts[self.currentAttempt] = {
        number = self.currentAttempt,
        responses = {},
        winner = nil,
        selectedRoll = nil,
        rollGraceUsed = false,
        outcome = nil,
        eligiblePlayers = {},
    }

    self.rollParticipants =
        self.participants

    self.responses = {}
    self.resultResponses = {}
    self.pendingRolls = {}

    self.winner = nil
    self.suggestedWinner = nil
    self.selectedRoll = nil
    self.selectedAt = nil
    self.awardedAt = nil

    self.award = nil

    self.state =
        Constants.States.PENDING

    self.phaseName =
        Constants.Phases.ROLLING

    self.phase =
        DistributionPhase.New(
            Constants.Phases.ROLLING
        )

    self.rollGraceActive = false
    self.rollGraceElapsed = 0

    self.resultFinalized = false
    self.finalDecision = nil
    self.finalDecisionAt = nil

    return self
end

function Distribution:Update(elapsed)
    assert(
        elapsed ~= nil,
        "Elapsed time is required"
    )

    assert(
        type(elapsed) == "number",
        "Elapsed time must be a number"
    )

    assert(
        elapsed >= 0,
        "Elapsed time cannot be negative"
    )

    if self:IsRolling() then
        if self.rollGraceActive then
            self.rollGraceElapsed =
                self.rollGraceElapsed + elapsed

            if self.rollGraceElapsed
                >= Constants.RollGraceSeconds
            then
                self.rollGraceElapsed =
                    Constants.RollGraceSeconds

                self.rollGraceActive = false

                self:FinishRolling()
            end

            return self
        end

        local before =
            self.phase:GetElapsed()

        self.phase:Update(elapsed)

        if not self.phase:IsExpired() then
            return self
        end

        local remaining =
            elapsed
            - (
                self.phase:GetDuration()
                - before
            )

        if remaining < 0 then
            remaining = 0
        end

        self.rollGraceActive = true
        self.rollGraceElapsed = 0

        if remaining > 0 then
            self.rollGraceElapsed =
                math.min(
                    remaining,
                    Constants.RollGraceSeconds
                )
        end

        if self.rollGraceElapsed
            >= Constants.RollGraceSeconds
        then
            self.rollGraceActive = false

            self:FinishRolling()
        end

        return self
    end

    if self:IsResult() then
        self.phase:Update(elapsed)

        return self
    end

    return self
end

addon.Loot.Distributions.Distribution =
    Distribution
