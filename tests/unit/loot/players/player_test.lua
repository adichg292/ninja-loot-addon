local addon = {}

local loadPlayer = assert(
    loadfile("Loot/Players/Player.lua")
)

loadPlayer("NinjaLoot", addon)

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

local Player = addon.Loot.Players.Player

local player = Player.New("Pastah")

assert(
    player ~= nil,
    "Player was not created"
)

assert(
    player.name == "Pastah",
    "Player name was not stored correctly"
)

assert(
    player:GetName() == "Pastah",
    "Player GetName() returned incorrect name"
)

assert(
    getmetatable(player) == Player,
    "Player has incorrect metatable"
)

local success = pcall(function()
    Player.New(nil)
end)

assert(
    success == false,
    "Player.New() should reject nil names"
)

success = pcall(function()
    Player.New("")
end)

assert(
    success == false,
    "Player.New() should reject empty names"
)
