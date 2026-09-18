local addon = {}

assert(
    loadfile("Loot/Items/Item.lua")
)("NinjaLoot", addon)

assert(
    addon.Loot ~= nil,
    "Loot namespace was not created"
)

assert(
    addon.Loot.Items ~= nil,
    "Items namespace was not created"
)

assert(
    addon.Loot.Items.Item ~= nil,
    "Item was not created"
)

local Item =
    addon.Loot.Items.Item

local item =
    Item.New(
        "Test Item",
        12345,
        "|cff0070dd|Hitem:12345|h[Test Item]|h|r"
    )

assert(
    item ~= nil,
    "Item was not created"
)

assert(
    item:GetName() == "Test Item",
    "Item name was not stored correctly"
)

assert(
    item:GetId() == 12345,
    "Item ID was not stored correctly"
)

assert(
    item:GetLink()
    == "|cff0070dd|Hitem:12345|h[Test Item]|h|r",
    "Item link was not stored correctly"
)

assert(
    item:GetDistribution() == nil,
    "New item should not have a distribution"
)

assert(
    getmetatable(item) == Item,
    "Item has incorrect metatable"
)

local nilSuccess =
    pcall(function()
        Item.New(nil)
    end)

assert(
    not nilSuccess,
    "Item.New() should reject nil names"
)

local emptySuccess =
    pcall(function()
        Item.New("")
    end)

assert(
    not emptySuccess,
    "Item.New() should reject empty names"
)
