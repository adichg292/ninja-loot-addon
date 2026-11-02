local addon = {}

assert(loadfile("UI/Components/Button.lua"))("NinjaLoot", addon)

local loadLootList = assert(
    loadfile("UI/Loot/LootList.lua")
)

loadLootList(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Loot ~= nil,
    "UI.Loot namespace was not created"
)

assert(
    addon.UI.Loot.LootList ~= nil,
    "LootList was not created"
)

local parent = CreateFrame(
    "Frame",
    "NinjaLootLootListTestParent"
)

local lootList =
    addon.UI.Loot.LootList.New(
        parent
    )

assert(
    lootList ~= nil,
    "Loot list was not created"
)

assert(
    lootList.frame ~= nil,
    "Loot list frame was not created"
)

assert(
    lootList.title ~= nil,
    "Loot list title was not created"
)

assert(
    lootList.text ~= nil,
    "Loot list text was not created"
)

assert(
    lootList.title:GetText()
    == "Loot",
    "Loot list title is incorrect"
)

assert(
    lootList:GetText()
    == "No loot.",
    "Initial loot list text is incorrect"
)

lootList:Update(nil)

assert(
    lootList:GetText()
    == "Loot manager is not available.",
    "Missing loot manager text is incorrect"
)

local emptyManager = {
    GetLootItems = function()
        return {}
    end,
}

lootList:Update(
    emptyManager
)

assert(
    lootList:GetText()
    == "No loot.",
    "Empty loot list text is incorrect"
)

local items = {
    {
        GetName = function()
            return "Test Sword"
        end,

        GetState = function()
            return "AVAILABLE"
        end,
    },

    {
        GetName = function()
            return "Test Helmet"
        end,

        GetState = function()
            return "DISTRIBUTING"
        end,
    },
}

local lootManager = {
    GetLootItems = function()
        return items
    end,
}

lootList:Update(
    lootManager
)

assert(
    lootList:GetText()
    == "Test Sword [AVAILABLE]\n"
        .. "Test Helmet [DISTRIBUTING]",
    "Loot list contents are incorrect"
)

local itemState = "AVAILABLE"
local distributableItem = {
    GetName = function()
        return "Distributable Ring"
    end,

    GetState = function()
        return itemState
    end,
}
local startedItem = nil
lootList:Update({
    GetLootItems = function()
        return { distributableItem }
    end,

    StartDistribution = function(_, item)
        startedItem = item
        itemState = "DISTRIBUTING"
        return "distribution"
    end,
})

assert(
    lootList.rows[1].button:IsShown(),
    "Available loot should have a distribution action"
)

assert(
    lootList.rows[1].button:GetText() == "Distribute",
    "Loot action should be labeled Distribute"
)

lootList.rows[1].button:GetScript("OnClick")()

assert(
    startedItem == distributableItem,
    "Loot action should start a distribution for its item"
)

assert(
    not lootList.rows[1].button:IsShown(),
    "Loot action should hide after distribution starts"
)
