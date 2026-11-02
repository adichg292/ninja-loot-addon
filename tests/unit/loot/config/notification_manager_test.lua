local function loadAddonFile(path)
    assert(loadfile(path), "Failed to load " .. path)()
end

loadAddonFile("Loot/NotificationManager.lua")

local addon = _G.NinjaLoot or _G.NinjaLootAddon
local enabled = true
local verbosity = "NORMAL"
local configManager = {
    Get = function(_, path)
        if path == "General.Notifications" then
            return enabled
        end
        assert(path == "General.NotificationVerbosity")
        return verbosity
    end,
}
local received = {}
local manager = addon.Loot.Notifications.NotificationManager.New(
    configManager,
    function(message)
        table.insert(received, message)
    end
)

assert(manager:Notify("Award completed."),
    "Enabled notifications should be delivered")
assert(#received == 1 and string.find(received[1], "Award completed."),
    "Notification text should reach the output")

verbosity = "DETAILED"
assert(manager:Notify("Award completed.", "Awarded item to player via Trade."))
assert(string.find(received[2], "Awarded item to player via Trade."),
    "Detailed verbosity should show expanded notification text")

enabled = false
assert(not manager:Notify("This should be suppressed."),
    "Disabled notifications should be suppressed")
assert(#received == 2,
    "Suppressed notifications should not reach the output")
