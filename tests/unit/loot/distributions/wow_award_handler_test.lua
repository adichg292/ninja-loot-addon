local addonName, addon = ...

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
    "WoW TRADE handler should be registered"
)

local givenSlot = nil
local givenPlayer = nil

_G.GiveMasterLoot = function(
    slot,
    playerName
)
    givenSlot = slot
    givenPlayer = playerName
end

local success =
    service:AwardWinner(
        distribution,
        Constants.AwardMethods.LOOT,
        100,
        200
    )

assert(
    success,
    "WoW loot award should succeed"
)

assert(
    givenSlot == 7,
    "Master loot should receive the item loot slot"
)

assert(
    givenPlayer == "PlayerTwo",
    "Master loot should receive the winner name"
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
        == Constants.AwardStates.SUCCESS,
    "Successful WoW award should be recorded"
)

assert(
    distribution:GetAward().method
        == Constants.AwardMethods.LOOT,
    "Award method should be recorded"
)

local invalidLootSuccess =
    pcall(function()
        WoWAwardHandler.AwardLoot(nil)
    end)

assert(
    not invalidLootSuccess,
    "AwardLoot should reject nil distribution"
)

local invalidTradeSuccess =
    pcall(function()
        WoWAwardHandler.Trade(nil)
    end)

assert(
    not invalidTradeSuccess,
    "Trade should reject nil distribution"
)

local tradeSuccess,
    tradeError =
    WoWAwardHandler.Trade(
        distribution
    )

assert(
    not tradeSuccess,
    "Unimplemented trade should fail safely"
)

assert(
    tradeError
        == "Trade award is not implemented",
    "Trade failure reason is incorrect"
)