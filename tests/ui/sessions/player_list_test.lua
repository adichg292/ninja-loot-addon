local addon = {}

local loadPlayerList = assert(
    loadfile("UI/Sessions/PlayerList.lua")
)

loadPlayerList(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Sessions ~= nil,
    "UI.Sessions namespace was not created"
)

assert(
    addon.UI.Sessions.PlayerList ~= nil,
    "PlayerList was not created"
)

local parent = CreateFrame(
    "Frame",
    "NinjaLootPlayerListTestParent"
)

local playerList =
    addon.UI.Sessions.PlayerList.New(
        parent
    )

assert(
    playerList ~= nil,
    "Player list was not created"
)

assert(
    playerList.frame == nil,
    "PlayerList should not require a separate frame"
)

assert(
    playerList.title ~= nil,
    "Player list title was not created"
)

assert(
    playerList.text ~= nil,
    "Player list text was not created"
)

assert(
    playerList.title:GetText()
    == "Players",
    "Player list title is incorrect"
)

assert(
    playerList:GetText()
    == "No players.",
    "Initial player list text is incorrect"
)

local emptySession = {
    GetPlayers = function()
        return {
            GetAll = function()
                return {}
            end,
        }
    end,
}

playerList:Update(
    emptySession
)

assert(
    playerList:GetText()
    == "No players.",
    "Empty player list is incorrect"
)

local players = {
    {
        GetName = function()
            return "Alice"
        end,
    },
    {
        GetName = function()
            return "Bob"
        end,
    },
}

local session = {
    GetPlayers = function()
        return {
            GetAll = function()
                return players
            end,
        }
    end,
}

playerList:Update(session)

assert(
    playerList:GetText()
    == "Alice\nBob",
    "Player list contents are incorrect"
)