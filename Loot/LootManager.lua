local addonName, addon = ...

addon.Loot = addon.Loot or {}

local LootManager = {}
LootManager.__index = LootManager

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

local function assertValidDistribution(
    distribution
)
    assert(
        distribution ~= nil,
        "Distribution is required"
    )

    assert(
        getmetatable(distribution)
        == addon.Loot.Distributions.Distribution,
        "Invalid distribution"
    )
end

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

local function getItemId(itemLink)
    if type(itemLink) ~= "string" then
        return nil
    end

    local itemId =
        itemLink:match(
            "item:(%d+)"
        )

    if itemId == nil then
        return nil
    end

    return tonumber(itemId)
end

local function findItemBySlot(
    items,
    lootSlot,
    itemLink
)
    for _, item in ipairs(items) do
        if item:GetLootSlot() == lootSlot
            and (
                itemLink == nil
                or item:GetLink() == itemLink
            )
        then
            return item
        end
    end

    return nil
end

function LootManager.New(
    sessionManager
)
    assert(
        sessionManager ~= nil,
        "Session manager is required"
    )

    return setmetatable({
        sessionManager = sessionManager,

        selectedItem = nil,
        lootOpen = false,

        distributionHandler = nil,
    }, LootManager)
end

function LootManager:GetSessionManager()
    return self.sessionManager
end

function LootManager:SetDistributionHandler(
    handler
)
    assert(
        handler == nil
        or type(handler) == "function",
        "Distribution handler must be a function"
    )

    self.distributionHandler = handler

    return self
end

function LootManager:GetDistributionHandler()
    return self.distributionHandler
end

function LootManager:IsLootOpen()
    return self.lootOpen
end

function LootManager:GetSelectedItem()
    return self.selectedItem
end

function LootManager:GetCurrentSession()
    return self.sessionManager:GetActive()
end

function LootManager:GetCurrentBoss()
    local session =
        self:GetCurrentSession()

    if session == nil then
        return nil
    end

    return session:GetCurrentBoss()
end

function LootManager:GetLootItems()
    local boss =
        self:GetCurrentBoss()

    if boss == nil then
        return {}
    end

    return boss:GetItems():GetAll()
end

function LootManager:GetAvailableLoot()
    local boss =
        self:GetCurrentBoss()

    if boss == nil then
        return {}
    end

    local result = {}

    for _, item in ipairs(
        boss:GetItems():GetAll()
    ) do
        if item:IsAvailable()
            and self:IsItemStillAvailable(item)
        then
            table.insert(
                result,
                item
            )
        end
    end

    return result
end

function LootManager:PostBossLoot(
    killedAt
)
    local session =
        self:GetCurrentSession()

    assert(
        session ~= nil,
        "Active session is required"
    )

    local boss =
        session:GetCurrentBoss()

    assert(
        boss ~= nil,
        "Current boss is required"
    )

    if not boss:IsKilled() then
        boss:Kill(
            killedAt
            or getTimestamp()
        )
    end

    return self:ReadLoot()
end

function LootManager:HandleLootOpened()
    self.lootOpen = true

    local session =
        self:GetCurrentSession()

    if session == nil then
        return {}
    end

    local boss =
        session:GetCurrentBoss()

    if boss == nil
        or not boss:IsKilled()
    then
        return {}
    end

    return self:ReadLoot()
end

function LootManager:ReadLoot()
    local session =
        self:GetCurrentSession()

    assert(
        session ~= nil,
        "Active session is required"
    )

    local boss =
        session:GetCurrentBoss()

    assert(
        boss ~= nil,
        "Current boss is required"
    )

    assert(
        boss:IsKilled(),
        "Current boss must be killed before reading loot"
    )

    assert(
        GetNumLootItems ~= nil,
        "GetNumLootItems is not available"
    )

    assert(
        GetLootSlotInfo ~= nil,
        "GetLootSlotInfo is not available"
    )

    assert(
        GetLootSlotLink ~= nil,
        "GetLootSlotLink is not available"
    )

    local items =
        boss:GetItems():GetAll()

    local registered = {}

    local lootCount =
        GetNumLootItems()

    for lootSlot = 1, lootCount do
        local _,
            lootName,
            lootQuantity,
            _,
            lootQuality,
            locked,
            isQuestItem,
            questId,
            isActive =
            GetLootSlotInfo(
                lootSlot
            )

        local itemLink =
            GetLootSlotLink(
                lootSlot
            )

        if itemLink ~= nil
            and lootName ~= nil
        then
            local item =
                findItemBySlot(
                    items,
                    lootSlot,
                    itemLink
                )

            if item == nil then
                item =
                    addon.Loot.Items.Item.New(
                        lootName,
                        getItemId(itemLink),
                        itemLink
                    )

                item:SetLootSlot(
                    lootSlot
                )

                boss:AddItem(item)
            end

            item:SetLootQuantity(
                lootQuantity or 1
            )

            item:SetLootQuality(
                lootQuality
            )

            item:SetLootLocked(
                locked == true
            )

            item:SetQuestLoot(
                isQuestItem == true,
                questId
            )

            item:SetLootActive(
                isActive ~= false
            )

            if item:IsUnavailable() then
                item:SetState(
                    addon.Loot.Items.Item.States.AVAILABLE
                )
            end

            table.insert(
                registered,
                item
            )
        end
    end

    self.lootOpen = true

    return registered
end

function LootManager:SelectItem(item)
    assertValidItem(item)

    local boss =
        self:GetCurrentBoss()

    assert(
        boss ~= nil,
        "Current boss is required"
    )

    assert(
        item:GetBoss() == boss,
        "Item must belong to the current boss"
    )

    assert(
        item:IsAvailable(),
        "Item is not available"
    )

    assert(
        self:IsItemStillAvailable(item),
        "Item is no longer available"
    )

    if self.selectedItem ~= nil
        and self.selectedItem ~= item
        and self.selectedItem:IsSelected()
    then
        self.selectedItem:SetState(
            addon.Loot.Items.Item.States.AVAILABLE
        )
    end

    item:MarkSelected()

    self.selectedItem = item

    return item
end

function LootManager:StartDistribution(
    item
)
    if item == nil then
        item = self.selectedItem
    end

    assertValidItem(item)

    local session =
        self:GetCurrentSession()

    assert(
        session ~= nil,
        "Active session is required"
    )

    local boss =
        session:GetCurrentBoss()

    assert(
        boss ~= nil,
        "Current boss is required"
    )

    assert(
        item:GetBoss() == boss,
        "Item must belong to the current boss"
    )

    assert(
        item:IsAvailable(),
        "Item is not available for distribution"
    )

    assert(
        self:IsItemStillAvailable(item),
        "Item is no longer available"
    )

    if self.selectedItem ~= item then
        self:SelectItem(item)
    end

    local distribution =
        addon.Loot.Distributions.Distribution.New(
            item,
            boss,
            session:GetPlayers():GetAll(),
            session:GetMasterLooter()
        )

    session:AddDistribution(
        distribution
    )

    item:MarkDistributing()

    if self.distributionHandler ~= nil then
        self.distributionHandler(
            distribution
        )
    end

    return distribution
end

function LootManager:IsItemStillAvailable(
    item
)
    assertValidItem(item)

    local lootSlot =
        item:GetLootSlot()

    if lootSlot == nil then
        return false
    end

    if LootSlotHasItem ~= nil
        and not LootSlotHasItem(
            lootSlot
        )
    then
        item:MarkUnavailable()

        return false
    end

    if GetLootSlotLink == nil then
        return false
    end

    local currentLink =
        GetLootSlotLink(
            lootSlot
        )

    if currentLink == nil then
        item:MarkUnavailable()

        return false
    end

    if item:GetLink() ~= nil
        and currentLink ~= item:GetLink()
    then
        item:MarkUnavailable()

        return false
    end

    return true
end

function LootManager:VerifyDistributionItem(
    distribution
)
    assertValidDistribution(
        distribution
    )

    local item =
        distribution:GetItem()

    assertValidItem(item)

    if item:GetDistribution()
        ~= distribution
    then
        return false,
            "Item does not belong to distribution"
    end

    if item:IsUnavailable()
        or item:IsAwarded()
    then
        return false,
            "Item is no longer available"
    end

    if not self:IsItemStillAvailable(
        item
    )
    then
        return false,
            "Item is no longer available"
    end

    return true
end

function LootManager:MarkItemAwarded(
    item
)
    assertValidItem(item)

    item:MarkAwarded()

    if self.selectedItem == item then
        self.selectedItem = nil
    end

    return item
end

function LootManager:HandleLootSlotCleared(
    lootSlot
)
    if lootSlot == nil then
        return nil
    end

    local boss =
        self:GetCurrentBoss()

    if boss == nil then
        return nil
    end

    for _, item in ipairs(
        boss:GetItems():GetAll()
    ) do
        if item:GetLootSlot()
            == lootSlot
        then
            item:MarkUnavailable()

            if self.selectedItem == item then
                self.selectedItem = nil
            end

            return item
        end
    end

    return nil
end

function LootManager:HandleLootClosed()
    self.lootOpen = false

    return self
end

function LootManager:HandleLootSlotChanged(
    lootSlot
)
    if lootSlot == nil then
        return nil
    end

    return self:ReadLoot()
end

addon.Loot.LootManager =
    LootManager