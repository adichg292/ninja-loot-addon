local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local TradeAwardHandler = {}
local pendingDistribution = nil
local tradeState = nil

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

local function normalizedName(name)
    if type(name) ~= "string" then
        return nil
    end

    return string.lower(
        string.match(name, "^[^-]+") or name
    )
end

local function getTradeTargetName()
    local nameText = TradeFrameRecipientNameText

    if nameText == nil or nameText.GetText == nil then
        return nil
    end

    return nameText:GetText()
end

local function itemIdFromLink(link)
    if type(link) ~= "string" then
        return nil
    end

    local itemId = string.match(link, "item:(%d+)")
    return itemId and tonumber(itemId) or nil
end

local function tradeContainsExpectedItem(distribution)
    if GetTradePlayerItemLink == nil then
        return false
    end

    local item = distribution:GetItem()
    local expectedId = item:GetId()

    if expectedId == nil then
        expectedId = itemIdFromLink(item:GetLink())
    end

    if expectedId == nil then
        return false
    end

    for slot = 1, 6 do
        if itemIdFromLink(GetTradePlayerItemLink(slot))
            == expectedId
        then
            return true
        end
    end

    return false
end

local function matchesWinner(distribution)
    local winner = distribution:GetWinner()

    if winner == nil or winner.GetName == nil then
        return false
    end

    local targetName = getTradeTargetName()

    return normalizedName(targetName) ~= nil
        and normalizedName(targetName)
            == normalizedName(winner:GetName())
end

local function complete(success, errorMessage)
    local distribution = pendingDistribution

    if distribution == nil then
        return false
    end

    pendingDistribution = nil
    tradeState = nil

    TradeAwardHandler.awardService:Confirm(
        distribution,
        success,
        errorMessage,
        getTimestamp()
    )

    return distribution
end

function TradeAwardHandler.Trade(distribution)
    assert(distribution ~= nil, "Distribution is required")
    assert(distribution.GetItem ~= nil, "Distribution item is required")
    assert(distribution.GetWinner ~= nil, "Distribution winner is required")

    if pendingDistribution ~= nil then
        return false, "Another trade award is already pending"
    end

    if distribution:GetWinner() == nil then
        return false, "Trade award requires a selected winner"
    end

    if distribution:GetItem():GetId() == nil
        and itemIdFromLink(distribution:GetItem():GetLink()) == nil
    then
        return false, "Trade award item has no item ID"
    end

    pendingDistribution = distribution
    tradeState = nil

    TradeAwardHandler.HandleTradeShow()

    return nil
end

function TradeAwardHandler.HandleTradeShow()
    if pendingDistribution == nil
        or not matchesWinner(pendingDistribution)
    then
        return false
    end

    tradeState = {
        itemSeen = tradeContainsExpectedItem(pendingDistribution),
        bothAccepted = false,
    }

    return true
end

function TradeAwardHandler.HandlePlayerItemChanged()
    if tradeState == nil or pendingDistribution == nil then
        return false
    end

    tradeState.itemSeen =
        tradeContainsExpectedItem(pendingDistribution)
    tradeState.bothAccepted = false

    return tradeState.itemSeen
end

function TradeAwardHandler.HandleAcceptUpdate(
    playerAccepted,
    targetAccepted
)
    if tradeState == nil then
        return false
    end

    tradeState.bothAccepted =
        playerAccepted == true
        and targetAccepted == true

    return tradeState.bothAccepted
end

function TradeAwardHandler.HandleTradeClosed()
    if pendingDistribution == nil or tradeState == nil then
        return false
    end

    if tradeState.itemSeen and tradeState.bothAccepted then
        return complete(true)
    end

    return complete(
        false,
        "Trade closed before both players accepted the expected item"
    )
end

function TradeAwardHandler.Register(awardService)
    assert(awardService ~= nil, "Award service is required")

    TradeAwardHandler.awardService = awardService
    awardService:RegisterHandler(
        Constants.AwardMethods.TRADE,
        TradeAwardHandler.Trade
    )

    return awardService
end

addon.Loot.Distributions.TradeAwardHandler =
    TradeAwardHandler
