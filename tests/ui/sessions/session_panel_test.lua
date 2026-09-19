local addon = {}

local loadSessionTimer = assert(
    loadfile("UI/Sessions/SessionTimer.lua")
)

loadSessionTimer(
    "NinjaLoot",
    addon
)

local loadPlayerList = assert(
    loadfile("UI/Sessions/PlayerList.lua")
)

loadPlayerList(
    "NinjaLoot",
    addon
)

local loadSessionPanel = assert(
    loadfile("UI/Sessions/SessionPanel.lua")
)

loadSessionPanel(
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
    addon.UI.Sessions.SessionPanel ~= nil,
    "SessionPanel was not created"
)

local parent = CreateFrame(
    "Frame",
    "NinjaLootSessionPanelTestParent"
)

local panel =
    addon.UI.Sessions.SessionPanel.New(
        parent
    )

assert(
    panel ~= nil,
    "Session panel was not created"
)

assert(
    panel.frame ~= nil,
    "Session panel frame was not created"
)

assert(
    panel.title ~= nil,
    "Session panel title was not created"
)

assert(
    panel.sessionText ~= nil,
    "Session panel session text was not created"
)

assert(
    panel.timer ~= nil,
    "Session timer was not created"
)

assert(
    panel.players ~= nil,
    "Player list was not created"
)

assert(
    panel.title:GetText()
    == "Raid",
    "Session panel title is incorrect"
)

assert(
    panel.sessionText:GetText()
    == "No active session.",
    "Initial session panel text is incorrect"
)

panel:Update(nil)

assert(
    panel.sessionText:GetText()
    == "No active session.",
    "Empty session panel text is incorrect"
)

local session = {
    GetId = function()
        return "TEST-SESSION"
    end,

    GetLootSystem = function()
        return "ROUND_ROBIN"
    end,

    GetMasterLooter = function()
        return "MasterLooter"
    end,

    GetPlayers = function()
        return {
            GetAll = function()
                return {}
            end,
        }
    end,

    GetStartedAt = function()
        return 100
    end,

    GetEndedAt = function()
        return 100
    end,
}

panel:Update(session)

assert(
    panel.sessionText:GetText()
    == "Session: TEST-SESSION\n"
        .. "System: ROUND_ROBIN\n"
        .. "Master Looter: MasterLooter",
    "Session panel information is incorrect"
)

assert(
    panel.timer:GetText()
    == "Session Time: 00:00:00",
    "Session timer was not updated"
)

assert(
    panel.players:GetText()
    == "No players.",
    "Player list was not updated"
)