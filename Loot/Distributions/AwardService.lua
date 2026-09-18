local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local AwardService = {}
AwardService.__index = AwardService

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

function AwardService:HasHandler(method)
    return self.handlers[method] ~= nil
end

addon.Loot.Distributions.AwardService =
    AwardService