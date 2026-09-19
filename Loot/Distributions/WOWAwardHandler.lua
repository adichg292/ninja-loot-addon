local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local WoWAwardHandler = {}

local function assertDistribution(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        distribution.GetItem ~= nil,
        "Distribution item is required"
    )

    assert(
        distribution.GetWinner ~= nil,
        "Distribution winner is required"
    )
end

local function getLootSlot(
    distribution
)
    local item =
        distribution:GetItem()

    assert(
        item ~= nil,
        "Distribution item is required"
    )

    assert(
        item.GetLootSlot ~= nil,
        "Item loot slot is required"
    )

    local lootSlot =
        item:GetLootSlot()

    assert(
        lootSlot ~= nil,
        "Item loot slot is required"
    )

    return lootSlot
end

local function getWinnerName(
    distribution
)
    local winner =
        distribution:GetWinner()

    assert(
        winner ~= nil,
        "Distribution winner is required"
    )

    assert(
        winner.GetName ~= nil,
        "Winner name is required"
    )

    local winnerName =
        winner:GetName()

    assert(
        winnerName ~= nil
        and winnerName ~= "",
        "Winner name is required"
    )

    return winnerName
end

function WoWAwardHandler.AwardLoot(
    distribution
)
    assertDistribution(
        distribution
    )

    local lootSlot =
        getLootSlot(
            distribution
        )

    local winnerName =
        getWinnerName(
            distribution
        )

    assert(
        GiveMasterLoot ~= nil,
        "GiveMasterLoot is not available"
    )

    GiveMasterLoot(
        lootSlot,
        winnerName
    )

    return true
end

function WoWAwardHandler.Trade(
    distribution
)
    assertDistribution(
        distribution
    )

    return false,
        "Trade award is not implemented"
end

function WoWAwardHandler.Register(
    awardService
)
    assert(
        awardService ~= nil,
        "Award service is required"
    )

    awardService:RegisterHandler(
        Constants.AwardMethods.LOOT,
        WoWAwardHandler.AwardLoot
    )

    awardService:RegisterHandler(
        Constants.AwardMethods.TRADE,
        WoWAwardHandler.Trade
    )

    return awardService
end

addon.Loot.Distributions.WoWAwardHandler =
    WoWAwardHandler