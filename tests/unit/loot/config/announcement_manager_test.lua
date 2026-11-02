local function loadAddonFile(path)
    assert(loadfile(path), "Failed to load " .. path)()
end

loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Config/Config.lua")
loadAddonFile("Loot/AnnouncementManager.lua")

local addon = _G.NinjaLoot or _G.NinjaLootAddon
local enabled = true
local configManager = {
    Get = function(_, path)
        assert(path == "Loot.RoundRobin.AnnounceMLActions")
        return enabled
    end,
}
local previousRaid, previousGroup, previousSend = IsInRaid, IsInGroup, SendChatMessage
local raid, group = true, true
IsInRaid = function() return raid end
IsInGroup = function() return group end
local sent = {}
local failWarning = false
local manager = addon.Loot.AnnouncementManager.New(configManager,
    function(message, channel)
        if failWarning and channel == "RAID_WARNING" then
            error("warning channel unavailable")
        end
        table.insert(sent, { message = message, channel = channel })
    end)
local distribution = {
    GetAward = function()
        return {
            state = addon.Loot.Distributions.Constants.AwardStates.SUCCESS,
            recipient = { GetName = function() return "Winner" end },
        }
    end,
    GetItem = function()
        return { GetName = function() return "Test Item" end }
    end,
}

assert(manager:AnnounceAward(distribution), "Raid award should be announced")
assert(sent[1].channel == "RAID_WARNING"
    and string.find(sent[1].message, "Test Item")
    and string.find(sent[1].message, "Winner"),
    "Raid announcement should name the item and recipient")

raid = false
assert(manager:AnnounceAward(distribution), "Party award should be announced")
assert(sent[2].channel == "PARTY", "Party announcement should use PARTY")

raid = true
failWarning = true
assert(manager:AnnounceAward(distribution),
    "Raid warning failure should fall back to the raid channel")
assert(sent[3].channel == "RAID",
    "Raid warning fallback should use the ordinary raid channel")

group = false
raid = false
assert(not manager:AnnounceAward(distribution),
    "Solo awards should not send group announcements")
enabled = false
raid = true
assert(not manager:AnnounceAward(distribution),
    "Disabled announcements should be suppressed")

IsInRaid, IsInGroup, SendChatMessage = previousRaid, previousGroup, previousSend
