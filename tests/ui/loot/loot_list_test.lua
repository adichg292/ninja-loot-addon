local addon = {}

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