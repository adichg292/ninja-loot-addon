local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Bosses = addon.Loot.Bosses or {}

local Boss = {}
Boss.__index = Boss

function Boss.New(name)
    assert(
        name ~= nil,
        "Boss name is required"
    )

    assert(
        name ~= "",
        "Boss name cannot be empty"
    )

    return setmetatable({
        name = name,
        killedAt = nil,

        items =
            addon.Loot.Items.ItemManager.New(),
    }, Boss)
end

function Boss:GetName()
    return self.name
end

function Boss:IsKilled()
    return self.killedAt ~= nil
end

function Boss:GetKilledAt()
    return self.killedAt
end

function Boss:Kill(killedAt)
    assert(
        killedAt ~= nil,
        "Boss kill time is required"
    )

    assert(
        not self:IsKilled(),
        "Boss has already been killed"
    )

    self.killedAt = killedAt

    return self
end

function Boss:AddItem(item)
    assert(
        item ~= nil,
        "Item is required"
    )

    assert(
        getmetatable(item)
        == addon.Loot.Items.Item,
        "Invalid item"
    )

    item:SetBoss(self)

    return self.items:Add(item)
end

function Boss:GetItem(index)
    return self.items:Get(index)
end

function Boss:GetItems()
    return self.items
end

addon.Loot.Bosses.Boss = Boss