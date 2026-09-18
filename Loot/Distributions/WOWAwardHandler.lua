local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local WoWAwardHandler = {}

local function getRecipientName(distribution)
    local winner =
        distribution:GetWinner()

    if winner == nil then
        return nil
    end

    return winner:GetName()
end

function WoWAwardHandler.AwardLoot(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    local recipientName =
        getRecipientName(distribution)

    if recipientName == nil then
        return false, "No winner selected"
    end

    if type(LootSlot) ~= "function" then
        return false, "WoW loot API is unavailable"
    end

    if type(GetLootSlotType) ~= "function" then
        return false, "WoW loot slot API is unavailable"
    end

    return false,
        "Direct loot assignment requires active WoW loot context"
end

function WoWAwardHandler.Trade(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    local recipientName =
        getRecipientName(distribution)

    if recipientName == nil then
        return false, "No winner selected"
    end

    if type(InitiateTrade) ~= "function" then
        return false, "WoW trade API is unavailable"
    end

    return false,
        "Trade requires an active WoW trade context"
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
