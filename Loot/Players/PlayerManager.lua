local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Players = addon.Loot.Players or {}

local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.New()
    return setmetatable({
        players = {},
    }, PlayerManager)
end

function PlayerManager:Add(player)
    assert(
        player ~= nil,
        "Player is required"
    )

    assert(
        getmetatable(player)
        == addon.Loot.Players.Player,
        "Invalid player"
    )

    self.players[player.name] = player

    return player
end

function PlayerManager:Get(name)
    return self.players[name]
end

function PlayerManager:GetAll()
    local players = {}

    for _, player in pairs(
        self.players
    ) do
        table.insert(
            players,
            player
        )
    end

    table.sort(
        players,
        function(left, right)
            return left:GetName()
                < right:GetName()
        end
    )

    return players
end

function PlayerManager:Remove(name)
    self.players[name] = nil
end

function PlayerManager:Count()
    local count = 0

    for _ in pairs(
        self.players
    ) do
        count = count + 1
    end

    return count
end

function PlayerManager:Clear()
    self.players = {}

    return self
end

addon.Loot.Players.PlayerManager =
    PlayerManager