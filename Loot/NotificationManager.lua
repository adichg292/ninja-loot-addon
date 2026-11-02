local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Notifications = addon.Loot.Notifications or {}

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.New(configManager, output)
    assert(configManager ~= nil, "Config manager is required")
    assert(output == nil or type(output) == "function",
        "Notification output must be a function")

    return setmetatable({
        configManager = configManager,
        output = output,
    }, NotificationManager)
end

function NotificationManager:Notify(message, detailedMessage)
    assert(type(message) == "string", "Notification message must be a string")
    if not self.configManager:Get("General.Notifications") then
        return false
    end

    local verbosity = self.configManager:Get("General.NotificationVerbosity")
    if verbosity == "DETAILED" and detailedMessage ~= nil then
        message = detailedMessage
    end

    local text = "|cff33ff99NinjaLoot:|r " .. message
    if self.output ~= nil then
        self.output(text)
    elseif DEFAULT_CHAT_FRAME ~= nil
        and DEFAULT_CHAT_FRAME.AddMessage ~= nil
    then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    elseif print ~= nil then
        print(text)
    end

    return true
end

addon.Loot.Notifications.NotificationManager = NotificationManager
