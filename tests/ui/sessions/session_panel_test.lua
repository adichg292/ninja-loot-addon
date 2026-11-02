local addon = {}

assert(loadfile("UI/Components/Button.lua"))("NinjaLoot", addon)
assert(loadfile("UI/Components/ConfirmDialog.lua"))("NinjaLoot", addon)
assert(loadfile("Loot/Players/Player.lua"))("NinjaLoot", addon)

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
        return {
            GetName = function()
                return "MasterLooter"
            end,
        }
    end,

    IsActive = function()
        return false
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
        .. "Status: SETUP\n"
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

assert(
    not panel.createButton:IsShown()
        and panel.endButton:IsShown(),
    "An existing session should show End Session"
)

local activeSession = nil
local manager = {
    GetActive = function()
        return activeSession
    end,

    Create = function(_, id, system, masterLooter)
        assert(system == "RoundRobin", "New session should default to Round Robin")
        activeSession = {
            id = id,
            masterLooter = masterLooter,
            players = { masterLooter },
            GetId = function(self) return self.id end,
            GetLootSystem = function() return "RoundRobin" end,
            GetMasterLooter = function(self) return self.masterLooter end,
            IsActive = function() return true end,
            GetPlayers = function(self)
                return { GetAll = function() return self.players end }
            end,
            GetStartedAt = function() return 1 end,
            GetEndedAt = function() return nil end,
        }
        return activeSession
    end,

    Start = function() end,

    End = function(_, id)
        assert(id == activeSession.id, "End should target the active session")
        local ended = activeSession
        activeSession = nil
        return ended
    end,
}

panel:SetSessionManager(manager)
panel.createButton:GetScript("OnClick")()

assert(
    activeSession ~= nil
        and activeSession.masterLooter:GetName() ~= nil,
    "Start Session should create and start a session"
)
assert(
    panel.endButton:IsShown()
        and not panel.createButton:IsShown(),
    "An active session should show End Session"
)

addon.configManager = {
    Get = function(_, path)
        assert(path == "General.ConfirmDestructiveActions")
        return true
    end,
}
local endDialog = panel.endButton:GetScript("OnClick")()
assert(endDialog:IsShown(), "Ending a session should request confirmation")
assert(activeSession ~= nil,
    "Session should remain active until confirmation")
endDialog.confirmButton:Click()
assert(
    activeSession == nil
        and panel.createButton:IsShown()
        and not panel.endButton:IsShown(),
    "End Session should end the active session and restore the start control"
)
