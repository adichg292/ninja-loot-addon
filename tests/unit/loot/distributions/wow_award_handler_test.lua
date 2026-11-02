local addonName, addon = ...
local originalGiveMasterLoot = _G.GiveMasterLoot
local originalGetMasterLootCandidate = _G.GetMasterLootCandidate

addon.Loot = addon.Loot or {}
addon.Loot.Items = addon.Loot.Items or {}
addon.Loot.Players = addon.Loot.Players or {}
addon.Loot.Bosses = addon.Loot.Bosses or {}
addon.Loot.Distributions =
    addon.Loot.Distributions or {}

local function loadAddonFile(path)
    local chunk =
        assert(
            loadfile(path),
            "Failed to load " .. path
        )

    chunk(
        addonName,
        addon
    )
end

loadAddonFile("Loot/Items/Item.lua")
loadAddonFile("Loot/Items/ItemManager.lua")
loadAddonFile("Loot/Players/Player.lua")
loadAddonFile("Loot/Bosses/Boss.lua")
loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")
loadAddonFile("Loot/Distributions/Distribution.lua")
loadAddonFile("Loot/Distributions/AwardService.lua")
loadAddonFile("Loot/Distributions/WoWAwardHandler.lua")
loadAddonFile("Loot/Distributions/TradeAwardHandler.lua")

local Constants =
    addon.Loot.Distributions.Constants

local Player =
    addon.Loot.Players.Player

local Item =
    addon.Loot.Items.Item

local Boss =
    addon.Loot.Bosses.Boss

local Distribution =
    addon.Loot.Distributions.Distribution

local AwardService =
    addon.Loot.Distributions.AwardService

local WoWAwardHandler =
    addon.Loot.Distributions.WoWAwardHandler

local TradeAwardHandler =
    addon.Loot.Distributions.TradeAwardHandler

assert(
    addon.Loot.Items.ItemManager ~= nil,
    "ItemManager was not loaded"
)

local playerOne =
    Player.New("PlayerOne")

local playerTwo =
    Player.New("PlayerTwo")

local boss =
    Boss.New("Test Boss")

local item =
    Item.New(
        "Test Item",
        12345,
        "|Hitem:12345|h[Test Item]|h"
    )

item:SetLootSlot(7)

boss:AddItem(item)

local distribution =
    Distribution.New(
        item,
        boss,
        {
            playerOne,
            playerTwo,
        },
        playerOne
    )

distribution:Respond(
    playerOne,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerOne,
    50,
    Constants.RollSources.NINJALOOT
)

distribution:Respond(
    playerTwo,
    Constants.Responses.NEED
)

distribution:RegisterRoll(
    playerTwo,
    90,
    Constants.RollSources.NINJALOOT
)

assert(
    distribution:IsAwardPending(),
    "Distribution should be waiting for award"
)

assert(
    distribution:GetSuggestedWinner()
        == playerTwo,
    "PlayerTwo should be the suggested winner"
)

local service =
    AwardService.New()

WoWAwardHandler.Register(
    service
)

TradeAwardHandler.Register(service)

assert(
    service:HasHandler(
        Constants.AwardMethods.LOOT
    ),
    "WoW LOOT handler should be registered"
)

assert(
    service:HasHandler(
        Constants.AwardMethods.TRADE
    ),
    "Trade award handler should be registered"
)

local givenSlot = nil
local givenCandidateIndex = nil

_G.GetMasterLootCandidate = function(index)
    local candidates = {
        [1] = "PlayerOne",
        [2] = "PlayerTwo",
    }

    return candidates[index]
end

_G.GiveMasterLoot = function(
    slot,
    candidateIndex
)
    givenSlot = slot
    givenCandidateIndex = candidateIndex
end

local success =
    service:AwardWinner(
        distribution,
        Constants.AwardMethods.LOOT,
        100,
        200
    )

assert(
    success == nil,
    "WoW loot award should remain pending until the slot is cleared"
)

assert(
    givenSlot == 7,
    "Master loot should receive the item loot slot"
)

assert(
    givenCandidateIndex == 2,
    "Master loot should receive the winner candidate index"
)

assert(
    distribution:GetWinner()
        == playerTwo,
    "PlayerTwo should be the selected winner"
)

assert(
    distribution:IsAwarded(),
    "Distribution should be awarded"
)

assert(
    distribution:GetAward().state
        == Constants.AwardStates.PENDING,
    "WoW award should not report success before confirmation"
)

assert(
    distribution:GetAward().method
        == Constants.AwardMethods.LOOT,
    "Award method should be recorded"
)

assert(
    WoWAwardHandler.ConfirmLootSlotCleared(7)
        == distribution,
    "Clearing the matching loot slot should confirm the award"
)

assert(
    distribution:GetAward().state
        == Constants.AwardStates.SUCCESS,
    "Confirmed WoW award should be recorded as successful"
)

local stalledItem = Item.New("Stalled Award Item", 24680,
    "|Hitem:24680|h[Stalled Award Item]|h")
stalledItem:SetLootSlot(8)
boss:AddItem(stalledItem)
local stalledDistribution = Distribution.New(
    stalledItem,
    boss,
    { playerOne, playerTwo },
    playerOne
)
stalledDistribution:Respond(playerOne, Constants.Responses.NEED)
stalledDistribution:RegisterRoll(playerOne, 60, Constants.RollSources.NINJALOOT)
stalledDistribution:Respond(playerTwo, Constants.Responses.NEED)
stalledDistribution:RegisterRoll(playerTwo, 40, Constants.RollSources.NINJALOOT)

assert(service:AwardWinner(stalledDistribution, Constants.AwardMethods.LOOT, 300, 301) == nil,
    "Unconfirmed master loot should remain pending")
local failedAwards = WoWAwardHandler.FailPendingAwards("Loot window closed")
assert(#failedAwards == 1 and failedAwards[1] == stalledDistribution,
    "Closing the loot window should fail outstanding master loot awards")
assert(stalledDistribution:IsAwardFailed(),
    "Unconfirmed master loot should be marked failed")

assert(service:RetryAward(stalledDistribution, Constants.AwardMethods.LOOT, 302, 303) == nil,
    "Failed award should be retryable")
assert(stalledDistribution:GetAward().state == Constants.AwardStates.PENDING,
    "Retry should wait for a new master loot confirmation")
WoWAwardHandler.FailPendingAwards("Test cleanup")

_G.GiveMasterLoot = function()
    error("Master loot API failure")
end
local apiFailure = service:RetryAward(
    stalledDistribution,
    Constants.AwardMethods.LOOT,
    304,
    305
)
assert(apiFailure == false and stalledDistribution:IsAwardFailed(),
    "Synchronous master loot errors should fail cleanly")
assert(#WoWAwardHandler.FailPendingAwards("Unexpected pending award") == 0,
    "Synchronous failure should clear its pending slot")

_G.GetMasterLootCandidate = originalGetMasterLootCandidate
_G.GiveMasterLoot = originalGiveMasterLoot

local missingCandidateSuccess,
    missingCandidateError =
    WoWAwardHandler.AwardLoot(distribution)

assert(
    not missingCandidateSuccess,
    "AwardLoot should fail when the winner is not an eligible candidate"
)

assert(
    missingCandidateError
        == "Winner is not an eligible master loot candidate",
    "Missing candidate should report a clear error"
)

local invalidLootSuccess =
    pcall(function()
        WoWAwardHandler.AwardLoot(nil)
    end)

assert(
    not invalidLootSuccess,
    "AwardLoot should reject nil distribution"
)
