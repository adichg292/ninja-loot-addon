local addon = {}

assert(
    loadfile("Loot/Players/Player.lua")
)("NinjaLoot", addon)

assert(
    loadfile("Loot/Players/PlayerManager.lua")
)("NinjaLoot", addon)

assert(
    addon.Loot ~= nil,
    "Loot namespace was not created"
)

assert(
    addon.Loot.Players ~= nil,
    "Players namespace was not created"
)

assert(
    addon.Loot.Players.Player ~= nil,
    "Player was not created"
)

assert(
    addon.Loot.Players.PlayerManager ~= nil,
    "PlayerManager was not created"
)

local Player = addon.Loot.Players.Player
local PlayerManager = addon.Loot.Players.PlayerManager

local manager = PlayerManager.New()

assert(
    manager ~= nil,
    "PlayerManager was not created"
)

assert(
    manager:Count() == 0,
    "New PlayerManager should contain zero players"
)

local invalidNilSuccess = pcall(function()
    manager:Add(nil)
end)

assert(
    invalidNilSuccess == false,
    "PlayerManager should reject nil players"
)

local invalidTableSuccess = pcall(function()
    manager:Add({
        name = "Fake Player",
    })
end)

assert(
    invalidTableSuccess == false,
    "PlayerManager should reject non-Player objects"
)

assert(
    manager:Count() == 0,
    "Invalid players should not be added"
)

local player1 = Player.New("Player One")
local player2 = Player.New("Player Two")

manager:Add(player1)
manager:Add(player2)

assert(
    manager:Count() == 2,
    "PlayerManager should contain two players"
)

assert(
    manager:Get("Player One") == player1,
    "PlayerManager returned incorrect first player"
)

assert(
    manager:Get("Player Two") == player2,
    "PlayerManager returned incorrect second player"
)

assert(
    manager:Get("Unknown Player") == nil,
    "Unknown player should return nil"
)

manager:Remove("Player One")

assert(
    manager:Count() == 1,
    "PlayerManager count is incorrect after removal"
)

assert(
    manager:Get("Player One") == nil,
    "Removed player should not be returned"
)

assert(
    manager:Get("Player Two") == player2,
    "Remaining player should still be available"
)

manager:Clear()

assert(
    manager:Count() == 0,
    "PlayerManager should be empty after Clear()"
)

assert(
    manager:Get("Player Two") == nil,
    "Player should not exist after Clear()"
)
