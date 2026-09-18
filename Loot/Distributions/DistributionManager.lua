local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local DistributionManager = {}
DistributionManager.__index = DistributionManager

local function assertValidDistribution(distribution)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        getmetatable(distribution)
        == addon.Loot.Distributions.Distribution,
        "Invalid distribution"
    )
end

function DistributionManager.New()
    return setmetatable({
        distributions = {},
    }, DistributionManager)
end

function DistributionManager:Add(distribution)
    assertValidDistribution(distribution)

    table.insert(
        self.distributions,
        distribution
    )

    return distribution
end

function DistributionManager:Get(index)
    return self.distributions[index]
end

function DistributionManager:GetAll()
    return self.distributions
end

function DistributionManager:GetByBoss(boss)
    assert(
        boss ~= nil,
        "Boss is required"
    )

    local distributions = {}

    for _, distribution in ipairs(
        self.distributions
    ) do
        if distribution:GetBoss() == boss then
            table.insert(
                distributions,
                distribution
            )
        end
    end

    return distributions
end

function DistributionManager:GetByPlayer(player)
    assert(
        player ~= nil,
        "Player is required"
    )

    local distributions = {}

    for _, distribution in ipairs(
        self.distributions
    ) do
        if distribution:GetWinner() == player then
            table.insert(
                distributions,
                distribution
            )
        end
    end

    return distributions
end

function DistributionManager:StartDistribution(
    distribution,
    startedAt
)
    assertValidDistribution(distribution)

    assert(
        startedAt ~= nil,
        "Distribution start time is required"
    )

    assert(
        distribution:IsPending(),
        "Only a pending distribution can be started"
    )

    assert(
        distribution:IsRolling(),
        "Distribution must be in rolling phase"
    )

    return distribution
end

function DistributionManager:Update(elapsed)
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

    for _, distribution in ipairs(
        self.distributions
    ) do
        distribution:Update(elapsed)
    end
end

function DistributionManager:GetExpired()
    local distributions = {}

    for _, distribution in ipairs(
        self.distributions
    ) do
        local rollingExpired =
            distribution:IsPending()
            and distribution:IsRolling()
            and distribution:IsPhaseExpired()
            and not distribution:IsRollGraceActive()

        local resultExpired =
            distribution:IsAwarded()
            and distribution:IsResult()
            and distribution:IsPhaseExpired()

        if rollingExpired or resultExpired then
            table.insert(
                distributions,
                distribution
            )
        end
    end

    return distributions
end

function DistributionManager:ProcessExpired()
    local processed = {}

    for _, distribution in ipairs(
        self.distributions
    ) do
        local resultExpired =
            distribution:IsAwarded()
            and distribution:IsResult()
            and distribution:IsPhaseExpired()

        if resultExpired
            and not distribution:HasRestartThreshold()
        then
            distribution:FinalizeResult()

            table.insert(
                processed,
                distribution
            )
        end
    end

    return processed
end

function DistributionManager:SelectWinner(
    distribution,
    player,
    roll,
    selectedAt
)
    assertValidDistribution(distribution)

    distribution:SelectWinner(
        player,
        roll,
        selectedAt
    )

    return distribution
end

function DistributionManager:StartResult(
    distribution,
    startedAt
)
    assertValidDistribution(distribution)

    distribution:StartResult(startedAt)

    return distribution
end

function DistributionManager:FinalizeResult(
    distribution
)
    assertValidDistribution(distribution)

    distribution:FinalizeResult()

    return distribution
end

function DistributionManager:AcceptResult(
    distribution,
    decidedAt
)
    assertValidDistribution(distribution)

    distribution:AcceptResult(decidedAt)

    return distribution
end

function DistributionManager:Restart(
    distribution,
    decidedAt
)
    assertValidDistribution(distribution)

    distribution:Restart(decidedAt)

    return distribution
end

function DistributionManager:Award(
    distribution,
    player,
    awardedAt
)
    assertValidDistribution(distribution)

    distribution:Award(
        player,
        awardedAt
    )

    return distribution
end

function DistributionManager:Count()
    return #self.distributions
end

function DistributionManager:Remove(index)
    table.remove(
        self.distributions,
        index
    )
end

function DistributionManager:Clear()
    self.distributions = {}
end

addon.Loot.Distributions.DistributionManager =
    DistributionManager
