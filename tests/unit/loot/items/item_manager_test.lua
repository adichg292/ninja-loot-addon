local addon = {}

assert(
    loadfile("Loot/Items/Item.lua")
)("NinjaLoot", addon)

assert(
    loadfile("Loot/Items/ItemManager.lua")
)("NinjaLoot", addon)

local Item =
    addon.Loot.Items.Item

local ItemManager =
    addon.Loot.Items.ItemManager

local manager =
    ItemManager.New()

assert(
    manager ~= nil,
    "ItemManager was not created"
)

assert(
    manager:Count() == 0,
    "New ItemManager should contain zero items"
)

local invalidNilSuccess =
    pcall(function()
        manager:Add(nil)
    end)

assert(
    not invalidNilSuccess,
    "ItemManager should reject nil items"
)

local invalidTableSuccess =
    pcall(function()
        manager:Add({
            name = "Fake Item",
        })
    end)

assert(
    not invalidTableSuccess,
    "ItemManager should reject non-Item objects"
)

local itemOne =
    Item.New("Item One", 1001)

local itemTwo =
    Item.New("Item Two", 1002)

assert(
    manager:Add(itemOne) == itemOne,
    "Add should return the first item"
)

assert(
    manager:Add(itemTwo) == itemTwo,
    "Add should return the second item"
)

assert(
    manager:Count() == 2,
    "ItemManager should contain two items"
)

assert(
    manager:Get(1) == itemOne,
    "First item should be retrievable"
)

assert(
    manager:Get(2) == itemTwo,
    "Second item should be retrievable"
)

assert(
    manager:GetAll()[1] == itemOne,
    "GetAll should return the first item"
)

assert(
    manager:GetAll()[2] == itemTwo,
    "GetAll should return the second item"
)

assert(
    manager:Remove(1) == itemOne,
    "Remove should return the removed item"
)

assert(
    manager:Count() == 1,
    "ItemManager count should decrease after removal"
)

assert(
    manager:Get(1) == itemTwo,
    "Remaining item should shift into the first position"
)

manager:Clear()

assert(
    manager:Count() == 0,
    "Clear should remove all items"
)
