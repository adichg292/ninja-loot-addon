local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Items = addon.Loot.Items or {}

local ItemManager = {}
ItemManager.__index = ItemManager

local function assertValidItem(item)
    assert(
        item ~= nil,
        "Item is required"
    )

    assert(
        getmetatable(item)
        == addon.Loot.Items.Item,
        "Invalid item"
    )
end

function ItemManager.New()
    return setmetatable({
        items = {},
    }, ItemManager)
end

function ItemManager:Add(item)
    assertValidItem(item)

    table.insert(
        self.items,
        item
    )

    return item
end

function ItemManager:Get(index)
    return self.items[index]
end

function ItemManager:GetAll()
    return self.items
end

function ItemManager:Count()
    return #self.items
end

function ItemManager:Remove(index)
    return table.remove(
        self.items,
        index
    )
end

function ItemManager:Clear()
    self.items = {}

    return self
end

addon.Loot.Items.ItemManager = ItemManager
