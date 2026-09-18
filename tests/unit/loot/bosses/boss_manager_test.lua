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
    loadfile("Loot/Bosses/BossManager.lua")
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

assert(
    addon.Loot.Bosses.BossManager ~= nil,
    "BossManager was not created"
)

local Boss =
    addon.Loot.Bosses.Boss

local BossManager =
    addon.Loot.Bosses.BossManager

local manager =
    BossManager.New()

assert(
    manager ~= nil,
    "BossManager was not created"
)

assert(
    manager:Count() == 0,
    "New BossManager should contain zero bosses"
)

local invalidNilSuccess =
    pcall(function()
        manager:Add(nil)
    end)

assert(
    not invalidNilSuccess,
    "BossManager should reject nil bosses"
)

local invalidTableSuccess =
    pcall(function()
        manager:Add({
            name = "Fake Boss",
        })
    end)

assert(
    not invalidTableSuccess,
    "BossManager should reject non-Boss objects"
)

assert(
    manager:Count() == 0,
    "Invalid bosses should not be added"
)

local boss1 =
    Boss.New("Boss One")

local boss2 =
    Boss.New("Boss Two")

manager:Add(boss1)
manager:Add(boss2)

assert(
    manager:Count() == 2,
    "BossManager should contain two bosses"
)

assert(
    manager:Get("Boss One") == boss1,
    "BossManager returned incorrect first boss"
)

assert(
    manager:Get("Boss Two") == boss2,
    "BossManager returned incorrect second boss"
)

assert(
    manager:Get("Unknown Boss") == nil,
    "Unknown boss should return nil"
)

manager:Remove("Boss One")

assert(
    manager:Count() == 1,
    "BossManager count is incorrect after removal"
)

assert(
    manager:Get("Boss One") == nil,
    "Removed boss should not be returned"
)

assert(
    manager:Get("Boss Two") == boss2,
    "Remaining boss should still be available"
)

manager:Clear()

assert(
    manager:Count() == 0,
    "BossManager should be empty after Clear()"
)

assert(
    manager:Get("Boss Two") == nil,
    "Boss should not exist after Clear()"
)
