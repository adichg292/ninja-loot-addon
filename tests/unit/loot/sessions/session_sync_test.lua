local function loadAddonFile(path)
    assert(loadfile(path), "Failed to load " .. path)()
end

loadAddonFile("Loot/Sessions/SessionSync.lua")

local addon = _G.NinjaLoot or _G.NinjaLootAddon
local SessionSync = addon.Loot.Sessions.SessionSync

local sentMessages = {}
local registeredPrefix = nil

_G.C_ChatInfo = {
    RegisterAddonMessagePrefix = function(prefix)
        registeredPrefix = prefix
        return true
    end,

    SendAddonMessage = function(prefix, message, channel, target)
        table.insert(sentMessages, {
            prefix = prefix,
            message = message,
            channel = channel,
            target = target,
        })
    end,
}

_G.IsInRaid = function()
    return false
end

_G.IsInGroup = function()
    return true
end

local localPlayerName = "Master"

_G.UnitFullName = function(unit)
    assert(unit == "player")
    return localPlayerName, "Realm"
end

local masterLooter = {
    GetName = function()
        return "Master"
    end,
}

local memberPlayer = {
    GetName = function()
        return "Member"
    end,
}

local masterDistribution
masterDistribution = {
    IsPending = function()
        return true
    end,
    IsRolling = function()
        return true
    end,
    IsRollGraceActive = function()
        return false
    end,
    GetRollParticipants = function()
        return { memberPlayer }
    end,
    GetResponse = function()
        return nil
    end,
    HasPendingRoll = function()
        return false
    end,
    BeginRoll = function()
        masterDistribution.pendingRollStarted = true
    end,
}

local playerRoster = {
    GetAll = function()
        return { memberPlayer }
    end,
}

local session = {
    GetId = function()
        return "SYNC-SESSION"
    end,
    GetMasterLooter = function()
        return masterLooter
    end,
    GetPlayers = function()
        return playerRoster
    end,
    GetDistribution = function(_, index)
        if index == 1 then
            return masterDistribution
        end
    end,
}

local masterManagerSaved = false
local masterManager = {
    GetActiveSessionList = function()
        return { session }
    end,

    GetActive = function(_, sessionId)
        if sessionId == "SYNC-SESSION" then
            return session
        end
    end,

    GetHistory = function()
        return {}
    end,

    Save = function()
        masterManagerSaved = true
    end,
}

local sessionData = {
    masterLooter = { name = "Master" },
    history = {},
    largeValue = string.rep("payload", 100),
}

local memberResponse = nil
local memberDistribution = {
    Respond = function(_, player, response)
        assert(player == memberPlayer)
        memberResponse = response
    end,
}

local masterPersistence = {
    SerializeSession = function(_, receivedSession)
        assert(receivedSession == session)
        return sessionData
    end,
}

local masterSync = SessionSync.New(
    masterManager,
    masterPersistence
)

masterSync:Initialize()

assert(
    registeredPrefix == "NINJALOOT",
    "Session sync should register its addon message prefix"
)

assert(
    masterSync:Publish(),
    "Master looter should publish the active session"
)

assert(
    #sentMessages > 1,
    "Large session snapshots should be split into chunks"
)

for _, sent in ipairs(sentMessages) do
    assert(sent.prefix == "NINJALOOT")
    assert(sent.channel == "PARTY")
end

local savedSession = nil
local memberManager = {
    activeSessions = {},
}

local memberPersistence = {
    DeserializeSession = function(_, data)
        assert(data.largeValue == sessionData.largeValue)
        return {
            GetId = function()
                return "SYNC-SESSION"
            end,
            GetPlayers = function()
                return playerRoster
            end,
            GetDistributions = function()
                return {
                    GetAll = function()
                        return { memberDistribution }
                    end,
                }
            end,
            IsEnded = function()
                return false
            end,
        }
    end,

    Save = function(_, manager)
        savedSession = manager.activeSessions["SYNC-SESSION"]
    end,
}

local shownDistribution = nil
addon.uiManager = {
    ShowDistribution = function(_, distribution)
        shownDistribution = distribution
    end,
    RefreshMainWindow = function() end,
}

memberDistribution.IsRolling = function() return true end
memberDistribution.IsRollGraceActive = function() return false end
memberDistribution.GetRollParticipants = function() return { memberPlayer } end
memberDistribution.GetResponse = function() return nil end

local memberSync = SessionSync.New(
    memberManager,
    memberPersistence
)

localPlayerName = "Member"

for index = #sentMessages, 1, -1 do
    local sent = sentMessages[index]
    assert(
        memberSync:HandleMessage(
            sent.prefix,
            sent.message,
            sent.channel,
            "Master-Realm"
        ),
        "Member should accept snapshot chunks from the master looter"
    )
end

assert(
    savedSession ~= nil,
    "Complete session snapshot should be restored and persisted"
)
assert(
    shownDistribution == memberDistribution,
    "A participant should see a pending distribution after receiving the session snapshot"
)
addon.uiManager = nil

savedSession = nil
for index = #sentMessages, 1, -1 do
    local sent = sentMessages[index]
    memberSync:HandleMessage(
        sent.prefix,
        sent.message,
        sent.channel,
        "Other-Realm"
    )
end

assert(
    savedSession == nil,
    "Session snapshots from a non-master sender should be rejected"
)

sentMessages = {}
localPlayerName = "Master"
assert(
    masterSync:HandleMessage(
        "NINJALOOT",
        "H",
        "PARTY",
        "Member-Realm"
    ),
    "Master looter should answer group snapshot requests"
)

assert(
    #sentMessages > 0
        and sentMessages[1].channel == "WHISPER"
        and sentMessages[1].target == "Member-Realm",
    "Snapshot response should be whispered to the requesting member"
)

sentMessages = {}
localPlayerName = "Member"
local memberSessionManager = {
    GetActive = function(_, sessionId)
        if sessionId == "SYNC-SESSION" then
            return {
                GetMasterLooter = function()
                    return masterLooter
                end,
                GetPlayers = function()
                    return playerRoster
                end,
                GetDistribution = function(_, index)
                    if index == 1 then
                        return memberDistribution
                    end
                end,
            }
        end
    end,
    Save = function() end,
}

local memberActionSync = SessionSync.New(
    memberSessionManager,
    memberPersistence
)

assert(
    memberActionSync:SubmitResponse("SYNC-SESSION", 1, "NEED"),
    "Member should submit a response to the master looter"
)

assert(
    memberResponse == "NEED"
        and sentMessages[1].channel == "WHISPER"
        and sentMessages[1].target == "Master",
    "Member response should be applied locally and sent to the master looter"
)

localPlayerName = "Master"
assert(
    masterSync:HandleMessage(
        sentMessages[1].prefix,
        sentMessages[1].message,
        "WHISPER",
        "Member-Realm"
    ),
    "Master looter should accept a response from its participant"
)

assert(
    masterDistribution.pendingRollStarted
        and masterManagerSaved,
    "Master looter should record the pending roll and publish the updated state"
)

sentMessages = {}
localPlayerName = "Member"
assert(memberSync:RequestSnapshot())
assert(
    sentMessages[1].message == "H"
        and sentMessages[1].channel == "PARTY",
    "Group members should request a fresh session snapshot"
)
