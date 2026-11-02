local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local Constants =
    addon.Loot.Distributions.Constants

local WoWAwardHandler = {}
local pendingAwards = {}

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

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

local function getCandidateIndex(winnerName)
    if GetMasterLootCandidate == nil then
        return nil
    end

    local exactMatch = nil
    local normalizedMatch = nil
    local normalizedMatchCount = 0
    local normalizedWinner = string.lower(
        string.match(winnerName, "^[^-]+") or winnerName
    )

    for index = 1, 40 do
        local candidateName = GetMasterLootCandidate(index)

        if candidateName == winnerName then
            exactMatch = index
            break
        end

        if candidateName ~= nil then
            local normalizedCandidate = string.lower(
                string.match(candidateName, "^[^-]+") or candidateName
            )

            if normalizedCandidate == normalizedWinner then
                normalizedMatch = index
                normalizedMatchCount = normalizedMatchCount + 1
            end
        end
    end

    if exactMatch ~= nil then
        return exactMatch
    end

    if normalizedMatchCount == 1 then
        return normalizedMatch
    end

    return nil
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

    local candidateIndex =
        getCandidateIndex(winnerName)

    if candidateIndex == nil then
        return false,
            "Winner is not an eligible master loot candidate"
    end

    if GiveMasterLoot == nil then
        return false, "GiveMasterLoot is not available"
    end

    pendingAwards[lootSlot] = distribution

    local ok, errorMessage = pcall(
        GiveMasterLoot,
        lootSlot,
        candidateIndex
    )
    if not ok then
        pendingAwards[lootSlot] = nil
        return false, tostring(errorMessage)
    end

    return nil
end

function WoWAwardHandler.ConfirmLootSlotCleared(
    lootSlot
)
    local distribution = pendingAwards[lootSlot]

    if distribution == nil then
        return false
    end

    pendingAwards[lootSlot] = nil
    WoWAwardHandler.awardService:Confirm(
        distribution,
        true,
        nil,
        getTimestamp()
    )

    return distribution
end

function WoWAwardHandler.FailPendingAwards(errorMessage)
    local failed = {}
    for lootSlot, distribution in pairs(pendingAwards) do
        pendingAwards[lootSlot] = nil
        WoWAwardHandler.awardService:Confirm(
            distribution,
            false,
            errorMessage or "Loot window closed before award confirmation",
            getTimestamp()
        )
        table.insert(failed, distribution)
    end
    return failed
end

function WoWAwardHandler.Register(
    awardService
)
    assert(
        awardService ~= nil,
        "Award service is required"
    )

    WoWAwardHandler.awardService = awardService

    awardService:RegisterHandler(
        Constants.AwardMethods.LOOT,
        WoWAwardHandler.AwardLoot
    )

    return awardService
end

addon.Loot.Distributions.WoWAwardHandler =
    WoWAwardHandler
