local addon = {}

assert(
    loadfile("Loot/Items/Item.lua")
)("NinjaLoot", addon)

assert(
    loadfile("Loot/Items/ItemManager.lua")
)("NinjaLoot", addon)

assert(
    loadfile("Loot/Bosses/Boss.lua")
)("NinjaLoot", addon)

assert(
    addon.Loot ~= nil,
    "Loot namespace was not created"
)

assert(
    addon.Loot.Bosses ~= nil,
    "Bosses namespace was not created"
)

assert(
    addon.Loot.Bosses.Boss ~= nil,
    "Boss was not created"
)

local Boss =
    addon.Loot.Bosses.Boss

local Item =
    addon.Loot.Items.Item

local boss =
    Boss.New("Ragnaros")

assert(
    boss ~= nil,
    "Boss was not created"
)

assert(
    boss:GetName() == "Ragnaros",
    "Boss GetName() returned incorrect name"
)

assert(
    not boss:IsKilled(),
    "New boss should not be killed"
)

assert(
    boss:GetKilledAt() == nil,
    "New boss should not have a kill time"
)

assert(
    boss:GetItems() ~= nil,
    "Boss should have an item manager"
)

assert(
    boss:GetItems():Count() == 0,
    "New boss should have zero items"
)

assert(
    getmetatable(boss) == Boss,
    "Boss has incorrect metatable"
)

local item =
    Item.New(
        "Sulfuras",
        19019
    )

assert(
    boss:AddItem(item) == item,
    "Boss AddItem should return the item"
)

assert(
    boss:GetItem(1) == item,
    "Boss should return the added item"
)

assert(
    boss:GetItems():Count() == 1,
    "Boss should contain one item"
)

assert(
    boss:IsKilled() == false,
    "Boss should still be alive before Kill"
)

assert(
    boss:Kill(500) == boss,
    "Kill should return the boss"
)

assert(
    boss:IsKilled(),
    "Boss should be marked killed"
)

assert(
    boss:GetKilledAt() == 500,
    "Boss kill time should be stored"
)

local duplicateKillSuccess =
    pcall(function()
        boss:Kill(600)
    end)

assert(
    not duplicateKillSuccess,
    "Boss should reject being killed twice"
)

local nilSuccess =
    pcall(function()
        Boss.New(nil)
    end)

assert(
    not nilSuccess,
    "Boss.New() should reject nil names"
)

local emptySuccess =
    pcall(function()
        Boss.New("")
    end)

assert(
    not emptySuccess,
    "Boss.New() should reject empty names"
)
