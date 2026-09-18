local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Items = addon.Loot.Items or {}

local Item = {}
Item.__index = Item

Item.States = {
    AVAILABLE = "AVAILABLE",
    SELECTED = "SELECTED",
    DISTRIBUTING = "DISTRIBUTING",
    AWARDED = "AWARDED",
    UNAVAILABLE = "UNAVAILABLE",
}

function Item.New(
    name,
    itemId,
    itemLink
)
    assert(
        name ~= nil,
        "Item name is required"
    )

    assert(
        name ~= "",
        "Item name cannot be empty"
    )

    return setmetatable({
        name = name,
        itemId = itemId,
        itemLink = itemLink,

        boss = nil,

        lootSlot = nil,
        lootQuantity = 1,
        lootQuality = nil,
        lootLocked = false,
        questLoot = false,
        questId = nil,
        lootActive = true,

        state = Item.States.AVAILABLE,

        distribution = nil,
    }, Item)
end

function Item:GetName()
    return self.name
end

function Item:GetId()
    return self.itemId
end

function Item:GetLink()
    return self.itemLink
end

function Item:GetBoss()
    return self.boss
end

function Item:SetBoss(boss)
    assert(
        boss ~= nil,
        "Boss is required"
    )

    assert(
        getmetatable(boss)
        == addon.Loot.Bosses.Boss,
        "Invalid boss"
    )

    assert(
        self.boss == nil
        or self.boss == boss,
        "Item already belongs to another boss"
    )

    self.boss = boss

    return self
end

function Item:GetLootSlot()
    return self.lootSlot
end

function Item:SetLootSlot(lootSlot)
    assert(
        lootSlot ~= nil,
        "Loot slot is required"
    )

    assert(
        type(lootSlot) == "number",
        "Loot slot must be a number"
    )

    assert(
        lootSlot % 1 == 0,
        "Loot slot must be an integer"
    )

    assert(
        lootSlot > 0,
        "Loot slot must be greater than zero"
    )

    self.lootSlot = lootSlot

    return self
end

function Item:GetLootQuantity()
    return self.lootQuantity
end

function Item:SetLootQuantity(quantity)
    assert(
        quantity ~= nil,
        "Loot quantity is required"
    )

    assert(
        type(quantity) == "number",
        "Loot quantity must be a number"
    )

    assert(
        quantity > 0,
        "Loot quantity must be greater than zero"
    )

    self.lootQuantity = quantity

    return self
end

function Item:GetLootQuality()
    return self.lootQuality
end

function Item:SetLootQuality(quality)
    self.lootQuality = quality

    return self
end

function Item:IsLootLocked()
    return self.lootLocked
end

function Item:SetLootLocked(locked)
    self.lootLocked = locked == true

    return self
end

function Item:IsQuestLoot()
    return self.questLoot
end

function Item:GetQuestId()
    return self.questId
end

function Item:SetQuestLoot(
    isQuestLoot,
    questId
)
    self.questLoot = isQuestLoot == true
    self.questId = questId

    return self
end

function Item:IsLootActive()
    return self.lootActive
end

function Item:SetLootActive(active)
    self.lootActive = active == true

    return self
end

function Item:GetState()
    return self.state
end

function Item:SetState(state)
    assert(
        state ~= nil,
        "Item state is required"
    )

    assert(
        state == Item.States.AVAILABLE
        or state == Item.States.SELECTED
        or state == Item.States.DISTRIBUTING
        or state == Item.States.AWARDED
        or state == Item.States.UNAVAILABLE,
        "Invalid item state"
    )

    self.state = state

    return self
end

function Item:IsAvailable()
    return self.state
        == Item.States.AVAILABLE
        or self.state
        == Item.States.SELECTED
        or self.state
        == Item.States.DISTRIBUTING
end

function Item:IsSelected()
    return self.state
        == Item.States.SELECTED
end

function Item:IsDistributing()
    return self.state
        == Item.States.DISTRIBUTING
end

function Item:IsAwarded()
    return self.state
        == Item.States.AWARDED
end

function Item:IsUnavailable()
    return self.state
        == Item.States.UNAVAILABLE
end

function Item:MarkSelected()
    self.state =
        Item.States.SELECTED

    return self
end

function Item:MarkDistributing()
    self.state =
        Item.States.DISTRIBUTING

    return self
end

function Item:MarkAwarded()
    self.state =
        Item.States.AWARDED

    return self
end

function Item:MarkUnavailable()
    self.state =
        Item.States.UNAVAILABLE

    return self
end

function Item:GetDistribution()
    return self.distribution
end

function Item:SetDistribution(distribution)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        getmetatable(distribution)
        == addon.Loot.Distributions.Distribution,
        "Invalid distribution"
    )

    assert(
        self.distribution == nil
        or self.distribution == distribution,
        "Item already has a distribution"
    )

    self.distribution = distribution

    return self
end

addon.Loot.Items.Item = Item