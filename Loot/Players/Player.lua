local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Players = addon.Loot.Players or {}

local Player = {}
Player.__index = Player

function Player.New(name)
    assert(name ~= nil, "Player name is required")
    assert(name ~= "", "Player name cannot be empty")

    return setmetatable({
        name = name,
    }, Player)
end

function Player:GetName()
    return self.name
end

addon.Loot.Players.Player = Player
