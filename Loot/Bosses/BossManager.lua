local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Bosses = addon.Loot.Bosses or {}

local BossManager = {}
BossManager.__index = BossManager

function BossManager.New()
    return setmetatable({
        bosses = {},
    }, BossManager)
end

function BossManager:Add(boss)
    assert(
        boss ~= nil,
        "Boss is required"
    )

    assert(
        getmetatable(boss) == addon.Loot.Bosses.Boss,
        "Invalid boss"
    )

    self.bosses[boss.name] = boss

    return boss
end

function BossManager:Get(name)
    return self.bosses[name]
end

function BossManager:Remove(name)
    self.bosses[name] = nil
end

function BossManager:Count()
    local count = 0

    for _ in pairs(self.bosses) do
        count = count + 1
    end

    return count
end

function BossManager:Clear()
    self.bosses = {}
end

addon.Loot.Bosses.BossManager = BossManager
