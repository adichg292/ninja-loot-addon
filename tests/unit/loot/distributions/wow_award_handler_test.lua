local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/AwardService.lua")
loadAddonFile("Loot/Distributions/WoWAwardHandler.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

local Constants =
    addon.Loot.Distributions.Constants

local AwardService =
    addon.Loot.Distributions.AwardService

local WoWAwardHandler =
    addon.Loot.Distributions.WoWAwardHandler

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
