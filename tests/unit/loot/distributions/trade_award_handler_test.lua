local function loadAddonFile(path)
    assert(loadfile(path), "Failed to load " .. path)()
end

loadAddonFile("Loot/Players/Player.lua")
loadAddonFile("Loot/Items/Item.lua")
loadAddonFile("Loot/Items/ItemManager.lua")
loadAddonFile("Loot/Bosses/Boss.lua")
loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionResponse.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")
loadAddonFile("Loot/Distributions/Distribution.lua")
loadAddonFile("Loot/Distributions/AwardService.lua")
loadAddonFile("Loot/Distributions/TradeAwardHandler.lua")

local addon = _G.NinjaLoot or _G.NinjaLootAddon
local Player = addon.Loot.Players.Player
local Item = addon.Loot.Items.Item
local Boss = addon.Loot.Bosses.Boss
local Constants = addon.Loot.Distributions.Constants
local Distribution = addon.Loot.Distributions.Distribution
local AwardService = addon.Loot.Distributions.AwardService
local TradeAwardHandler = addon.Loot.Distributions.TradeAwardHandler

local masterLooter = Player.New("Master")
local winner = Player.New("Winner-Realm")
local item = Item.New("Trade Item", 12345, "|Hitem:12345:0|h[Trade Item]|h")
local distribution = Distribution.New(
    item,
    Boss.New("Test Boss"),
    { masterLooter, winner },
    masterLooter
)

distribution:Respond(masterLooter, Constants.Responses.NEED)
distribution:RegisterRoll(masterLooter, 50, Constants.RollSources.NINJALOOT)
distribution:Respond(winner, Constants.Responses.NEED)
distribution:RegisterRoll(winner, 90, Constants.RollSources.NINJALOOT)
distribution:SelectWinner(winner, nil, 100)
distribution:Award(winner, 100)

local service = AwardService.New()
TradeAwardHandler.Register(service)

local tradeTarget = "Winner-Realm"
local tradedItem = "|Hitem:12345:0|h[Trade Item]|h"
TradeFrameRecipientNameText = {
    GetText = function()
        return tradeTarget
    end,
}
GetTradePlayerItemLink = function(slot)
    return slot == 3 and tradedItem or nil
end

assert(
    service:Award(distribution, Constants.AwardMethods.TRADE, 101) == nil,
    "Trade award should remain pending until the trade is confirmed"
)
assert(TradeAwardHandler.HandleTradeShow(), "Trade with winner should be tracked")
assert(TradeAwardHandler.HandleAcceptUpdate(true, true), "Both accepts should be recorded")
assert(
    TradeAwardHandler.HandleTradeClosed() == distribution,
    "Completed expected-item trade should confirm the award"
)
assert(
    distribution:GetAward().state == Constants.AwardStates.SUCCESS,
    "Confirmed trade should complete the award successfully"
)

local cancelled = Distribution.New(
    Item.New("Cancelled Item", 98765, "|Hitem:98765|h[Cancelled Item]|h"),
    Boss.New("Test Boss"),
    { masterLooter, winner },
    masterLooter
)
cancelled:Respond(masterLooter, Constants.Responses.NEED)
cancelled:RegisterRoll(masterLooter, 50, Constants.RollSources.NINJALOOT)
cancelled:Respond(winner, Constants.Responses.NEED)
cancelled:RegisterRoll(winner, 90, Constants.RollSources.NINJALOOT)
cancelled:SelectWinner(winner, nil, 200)
cancelled:Award(winner, 200)

tradedItem = "|Hitem:98765|h[Cancelled Item]|h"
service:Award(cancelled, Constants.AwardMethods.TRADE, 201)
assert(TradeAwardHandler.HandleTradeShow(), "Second winner trade should be tracked")
assert(
    TradeAwardHandler.HandleTradeClosed() == cancelled,
    "Closing before both accept should finish the attempt"
)
assert(
    cancelled:GetAward().state == Constants.AwardStates.FAILED,
    "Trade closed without both accepts should fail the award"
)

TradeFrameRecipientNameText = nil
GetTradePlayerItemLink = nil
