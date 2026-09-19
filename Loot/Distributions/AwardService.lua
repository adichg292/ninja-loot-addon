local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local AwardService = {}
AwardService.__index = AwardService

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

function AwardService.New(
    lootManager
)
    return setmetatable({
        handlers = {},
        lootManager = lootManager,
    }, AwardService)
end

function AwardService:SetLootManager(
    lootManager
)
    assert(
        lootManager ~= nil,
        "Loot manager is required"
    )

    self.lootManager =
        lootManager

    return self
end

function AwardService:RegisterHandler(
    method,
    handler
)
    assert(
        method ~= nil,
        "Award method is required"
    )

    assert(
        type(handler) == "function",
        "Award handler must be a function"
    )

    self.handlers[method] =
        handler

    return self
end

function AwardService:Award(
    distribution,
    method,
    startedAt
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        method ~= nil,
        "Award method is required"
    )

    local handler =
        self.handlers[method]

    assert(
        handler ~= nil,
        "No award handler registered"
    )

    if distribution:GetAward() ~= nil
        and distribution:GetAward().state
            == Constants.AwardStates.SUCCESS
    then
        error(
            "Distribution has already been awarded"
        )
    end

    if self.lootManager ~= nil then
        local valid,
            errorMessage =
            self.lootManager:
            VerifyDistributionItem(
                distribution
            )

        assert(
            valid,
            errorMessage
            or "Loot item is no longer available"
        )
    end

    distribution:SetAwardPending(
        method,
        startedAt
    )

    local success,
        errorMessage =
        handler(distribution)

    if success then
        distribution:SetAwardSuccess(
            startedAt
        )

        if self.lootManager ~= nil then
            self.lootManager:
                MarkItemAwarded(
                    distribution:GetItem()
                )
        end
    else
        distribution:SetAwardFailed(
            errorMessage
            or "Award failed",
            startedAt
        )
    end

    return success
end

function AwardService:AwardWinner(
    distribution,
    method,
    selectedAt,
    startedAt
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        method ~= nil,
        "Award method is required"
    )

    assert(
        distribution:IsAwardPending(),
        "Distribution is not waiting for award"
    )

    local winner =
        distribution:GetWinner()

    if winner == nil then
        winner =
            distribution:GetSuggestedWinner()
    end

    assert(
        winner ~= nil,
        "No valid winner is available"
    )

    local selectionTime =
        selectedAt

    if selectionTime == nil then
        selectionTime =
            getTimestamp()
    end

    local awardStartTime =
        startedAt

    if awardStartTime == nil then
        awardStartTime =
            selectionTime
    end

    distribution:SelectWinner(
        winner,
        nil,
        selectionTime
    )

    distribution:Award(
        winner,
        awardStartTime
    )

    return self:Award(
        distribution,
        method,
        awardStartTime
    )
end

function AwardService:HasHandler(method)
    return self.handlers[method] ~= nil
end

addon.Loot.Distributions.AwardService =
    AwardService