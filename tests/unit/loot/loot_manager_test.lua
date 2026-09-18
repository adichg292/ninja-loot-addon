local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile(
    "Loot/Players/Player.lua"
)

loadAddonFile(
    "Loot/Players/PlayerManager.lua"
)

loadAddonFile(
    "Loot/Items/Item.lua"
)

loadAddonFile(
    "Loot/Items/ItemManager.lua"
)

loadAddonFile(
    "Loot/Bosses/Boss.lua"
)

loadAddonFile(
    "Loot/Bosses/BossManager.lua"
)

loadAddonFile(
    "Loot/Lifecycles/Lifecycle.lua"
)

loadAddonFile(
    "Loot/Distributions/Constants.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionResponse.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionPhase.lua"
)

loadAddonFile(
    "Loot/Distributions/Distribution.lua"
)

loadAddonFile(
    "Loot/Distributions/DistributionManager.lua"
)

loadAddonFile(
    "Loot/Sessions/Session.lua"
)

loadAddonFile(
    "Loot/Sessions/SessionManager.lua"
)

loadAddonFile(
    "Loot/LootManager.lua"
)

local addon =
    _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Player =
    addon.Loot.Players.Player

local Boss =
    addon.Loot.Bosses.Boss

local SessionManager =
    addon.Loot.Sessions.SessionManager

local LootManager =
    addon.Loot.LootManager

local playerOne =
    Player.New(
        "PlayerOne"
    )

local playerTwo =
    Player.New(
        "PlayerTwo"
    )

local boss =
    Boss.New(
        "Test Boss"
    )

local sessionManager =
    SessionManager.New()

local session =
    sessionManager:Create(
        "LOOT-MANAGER-TEST",
        "ROUND_ROBIN",
        playerOne
    )

session:AddPlayer(
    playerOne
)

session:AddPlayer(
    playerTwo
)

session:AddBoss(
    boss
)

session:Start(
    100
)

session:BossKilled(
    200
)

local loot = {
    [1] = {
        name = "Test Sword",
        quantity = 1,
        quality = 4,
        link =
            "|cffa335ee|Hitem:19019|h[Test Sword]|h|r",
        locked = false,
        isQuestItem = false,
        questId = nil,
        isActive = true,
        hasItem = true,
    },

    [2] = {
        name = "Test Shield",
        quantity = 1,
        quality = 3,
        link =
            "|cff0070dd|Hitem:12345|h[Test Shield]|h|r",
        locked = false,
        isQuestItem = false,
        questId = nil,
        isActive = true,
        hasItem = true,
    },

    [3] = {
        name = nil,
        quantity = 50,
        quality = nil,
        link = nil,
        locked = false,
        isQuestItem = false,
        questId = nil,
        isActive = true,
        hasItem = false,
    },
}

_G.GetNumLootItems = function()
    return 2
end

_G.GetLootSlotInfo = function(
    slot
)
    local entry = loot[slot]

    if entry == nil then
        return nil
    end

    return nil,
        entry.name,
        entry.quantity,
        nil,
        entry.quality,
        entry.locked,
        entry.isQuestItem,
        entry.questId,
        entry.isActive
end

_G.GetLootSlotLink = function(
    slot
)
    local entry = loot[slot]

    if entry == nil then
        return nil
    end

    return entry.link
end

_G.LootSlotHasItem = function(
    slot
)
    local entry = loot[slot]

    return entry ~= nil
        and entry.hasItem == true
end

_G.GetServerTime = function()
    return 500
end

local lootManager =
    LootManager.New(
        sessionManager
    )

assert(
    lootManager ~= nil,
    "LootManager should be created"
)

assert(
    not lootManager:IsLootOpen(),
    "Loot should not initially be open"
)

assert(
    lootManager:GetSelectedItem() == nil,
    "No item should initially be selected"
)

local registered =
    lootManager:HandleLootOpened()

assert(
    lootManager:IsLootOpen(),
    "Loot should be marked open"
)

assert(
    #registered == 2,
    "Two loot items should be registered"
)

assert(
    boss:GetItems():Count() == 2,
    "Boss should contain two loot items"
)

local sword =
    boss:GetItem(1)

local shield =
    boss:GetItem(2)

assert(
    sword:GetName() == "Test Sword",
    "First loot item should have correct name"
)

assert(
    sword:GetId() == 19019,
    "First loot item should have correct item ID"
)

assert(
    sword:GetLink()
    == loot[1].link,
    "First loot item should have correct link"
)

assert(
    sword:GetLootSlot() == 1,
    "First loot item should remember its loot slot"
)

assert(
    sword:GetLootQuantity() == 1,
    "First loot item should store quantity"
)

assert(
    sword:GetLootQuality() == 4,
    "First loot item should store quality"
)

assert(
    sword:IsAvailable(),
    "New loot should be available"
)

assert(
    shield:GetLootSlot() == 2,
    "Second loot item should remember its loot slot"
)

local registeredAgain =
    lootManager:HandleLootOpened()

assert(
    #registeredAgain == 2,
    "Opening loot again should still expose two items"
)

assert(
    boss:GetItems():Count() == 2,
    "Opening loot again should not duplicate items"
)

assert(
    #lootManager:GetAvailableLoot() == 2,
    "Two items should be available"
)

assert(
    lootManager:SelectItem(sword)
    == sword,
    "SelectItem should return the selected item"
)

assert(
    sword:IsSelected(),
    "Selected item should be marked selected"
)

assert(
    lootManager:GetSelectedItem()
    == sword,
    "Selected item should be tracked"
)

assert(
    lootManager:SelectItem(shield)
    == shield,
    "Second item should be selectable"
)

assert(
    sword:IsAvailable(),
    "Previously selected item should return to available state"
)

assert(
    shield:IsSelected(),
    "Second item should be selected"
)

local distribution =
    lootManager:StartDistribution(
        shield
    )

assert(
    distribution ~= nil,
    "StartDistribution should create a distribution"
)

assert(
    distribution:GetItem()
    == shield,
    "Distribution should belong to selected item"
)

assert(
    distribution:GetBoss()
    == boss,
    "Distribution should belong to current boss"
)

assert(
    distribution:GetParticipantCount()
    == 2,
    "Distribution should include session players"
)

assert(
    distribution:GetMasterLooter()
    == playerOne,
    "Distribution should use session master looter"
)

assert(
    shield:IsDistributing(),
    "Item should enter distributing state"
)

assert(
    session:GetDistributions():Count()
    == 1,
    "Session should contain the new distribution"
)

local verifySuccess,
    verifyError =
    lootManager:VerifyDistributionItem(
        distribution
    )

assert(
    verifySuccess,
    verifyError
    or "Distribution item should be valid"
)

loot[2].hasItem = false

local unavailable =
    lootManager:IsItemStillAvailable(
        shield
    )

assert(
    not unavailable,
    "Removed loot should no longer be available"
)

assert(
    shield:IsUnavailable(),
    "Removed loot should enter unavailable state"
)

local verifyAfterRemoval,
    removalError =
    lootManager:VerifyDistributionItem(
        distribution
    )

assert(
    not verifyAfterRemoval,
    "Distribution should fail validation after loot disappears"
)

assert(
    removalError
    == "Item is no longer available",
    "Distribution should report unavailable loot"
)

loot[1].hasItem = false

local cleared =
    lootManager:
    HandleLootSlotCleared(
        1
    )

assert(
    cleared == sword,
    "Clearing a loot slot should return its item"
)

assert(
    sword:IsUnavailable(),
    "Cleared loot should be unavailable"
)

lootManager:HandleLootClosed()

assert(
    not lootManager:IsLootOpen(),
    "Loot should be marked closed"
)

local noBossLoot =
    SessionManager.New()

local noBossSession =
    noBossLoot:Create(
        "NO-BOSS-LOOT",
        "ROUND_ROBIN",
        playerOne
    )

noBossSession:AddPlayer(
    playerOne
)

local noBossManager =
    LootManager.New(
        noBossLoot
    )

local emptyLoot =
    noBossManager:HandleLootOpened()

assert(
    #emptyLoot == 0,
    "Loot should be ignored without a current boss"
)