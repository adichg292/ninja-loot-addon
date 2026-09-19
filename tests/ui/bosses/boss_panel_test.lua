local addon = {}

local loadBossPanel = assert(
    loadfile("UI/Bosses/BossPanel.lua")
)

loadBossPanel(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Bosses ~= nil,
    "UI.Bosses namespace was not created"
)

assert(
    addon.UI.Bosses.BossPanel ~= nil,
    "BossPanel was not created"
)

local parent = CreateFrame(
    "Frame",
    "NinjaLootBossPanelTestParent"
)

local panel =
    addon.UI.Bosses.BossPanel.New(
        parent
    )

assert(
    panel ~= nil,
    "Boss panel was not created"
)

assert(
    panel.frame ~= nil,
    "Boss panel frame was not created"
)

assert(
    panel.title ~= nil,
    "Boss panel title was not created"
)

assert(
    panel.text ~= nil,
    "Boss panel text was not created"
)

assert(
    panel.title:GetText()
    == "Boss",
    "Boss panel title is incorrect"
)

assert(
    panel:GetText()
    == "No current boss.",
    "Initial boss panel text is incorrect"
)

panel:Update(nil)

assert(
    panel:GetText()
    == "No current boss.",
    "Empty boss panel text is incorrect"
)

local boss = {
    GetName = function()
        return "Test Boss"
    end,

    IsKilled = function()
        return false
    end,

    GetKilledAt = function()
        return nil
    end,

    GetItems = function()
        return {
            Count = function()
                return 3
            end,
        }
    end,
}

local session = {
    GetCurrentBoss = function()
        return boss
    end,
}

panel:Update(session)

assert(
    panel:GetText()
    == "Name: Test Boss\n"
        .. "Status: Alive\n"
        .. "Killed At: Not killed\n"
        .. "Loot Count: 3",
    "Alive boss information is incorrect"
)

boss.IsKilled = function()
    return true
end

boss.GetKilledAt = function()
    return 12345
end

panel:Update(session)

assert(
    panel:GetText()
    == "Name: Test Boss\n"
        .. "Status: Defeated\n"
        .. "Killed At: 12345\n"
        .. "Loot Count: 3",
    "Defeated boss information is incorrect"
)