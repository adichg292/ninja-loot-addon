local addonName, addon = ...

addon.Loot = addon.Loot or {}

local AnnouncementManager = {}
AnnouncementManager.__index = AnnouncementManager

function AnnouncementManager.New(configManager, sender)
    assert(configManager ~= nil, "Config manager is required")
    assert(sender == nil or type(sender) == "function",
        "Announcement sender must be a function")

    return setmetatable({ configManager = configManager, sender = sender },
        AnnouncementManager)
end

function AnnouncementManager:AnnounceAward(distribution)
    assert(distribution ~= nil, "Distribution is required")
    if not self.configManager:Get("Loot.RoundRobin.AnnounceMLActions")
        or (self.sender == nil and SendChatMessage == nil)
    then
        return false
    end

    local channel
    if IsInRaid ~= nil and IsInRaid() then
        channel = addon.Loot.Config.Config.DefaultAnnouncementChannel
    elseif IsInGroup ~= nil and IsInGroup() then
        channel = "PARTY"
    else
        return false
    end

    local award = distribution:GetAward()
    if award == nil
        or award.state ~= addon.Loot.Distributions.Constants.AwardStates.SUCCESS
    then
        return false
    end

    local item = distribution:GetItem()
    local recipient = award.recipient
    local itemName = item ~= nil and item:GetName() or "item"
    local recipientName = recipient ~= nil and recipient:GetName()
        or "the selected player"
    local message = "NinjaLoot: awarded " .. tostring(itemName)
        .. " to " .. tostring(recipientName) .. "."

    local send = self.sender or SendChatMessage
    local sent, sendError = pcall(send, message, channel)
    if not sent and channel == "RAID_WARNING" then
        sent = pcall(send, message, "RAID")
    end
    return sent, sendError
end

addon.Loot.AnnouncementManager = AnnouncementManager
