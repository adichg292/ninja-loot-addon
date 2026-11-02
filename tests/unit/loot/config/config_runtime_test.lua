local function loadAddonFile(path)
    assert(loadfile(path), "Failed to load " .. path)()
end

loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Config/Config.lua")
loadAddonFile("Loot/Config/ConfigManager.lua")

local addon = _G.NinjaLoot or _G.NinjaLootAddon
local database = {}
local savedConfig = nil
local persistence = {
    GetDatabase = function()
        return database
    end,
    SaveConfig = function(_, config)
        savedConfig = config
    end,
}

local oldGetServerTime = GetServerTime
GetServerTime = function() return 1000000 end
local prunedBefore = nil
local minimapVisible = nil
addon.sessionManager = {
    PruneHistoryBefore = function(_, timestamp)
        prunedBefore = timestamp
    end,
}
addon.uiManager = {
    SetMinimapButtonVisible = function(_, visible)
        minimapVisible = visible
    end,
}

local manager = addon.Loot.Config.ConfigManager.New(persistence)
manager:Initialize()
local constants = addon.Loot.Distributions.Constants

assert(constants.AllowRestartVoting == true,
    "Restart voting should default to enabled")
assert(prunedBefore == 1000000 - 30 * 86400,
    "Session history should be pruned according to its retention setting")
assert(minimapVisible == true,
    "Minimap button should use its configured default")

manager:Set("Loot.RoundRobin.AllowRestartVoting", false)
assert(constants.AllowRestartVoting == false,
    "Disabling restart voting should update runtime behavior")
assert(savedConfig == manager:GetAll(),
    "Runtime setting changes should be persisted")

manager:Set("Loot.RoundRobin.AllowRestartVoting", true)
assert(constants.AllowRestartVoting == true,
    "Enabling restart voting should update runtime behavior")

manager:Set("General.KeepSessionHistoryDays", 10)
assert(prunedBefore == 1000000 - 10 * 86400,
    "Changing retention should update the history cutoff")
manager:Set("General.MinimapButton", false)
assert(minimapVisible == false,
    "Changing minimap setting should update button visibility")

addon.sessionManager = nil
addon.uiManager = nil
GetServerTime = oldGetServerTime
