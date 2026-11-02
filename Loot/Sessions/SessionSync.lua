local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Sessions = addon.Loot.Sessions or {}

local SessionSync = {}
SessionSync.__index = SessionSync

local PREFIX = "NINJALOOT"
local CHUNK_SIZE = 180
local MAX_CHUNKS = 1000
local MAX_PAYLOAD_SIZE = 180000

local function encode(value)
    local valueType = type(value)

    if valueType == "string" then
        return "s" .. #value .. ":" .. value
    end

    if valueType == "number" then
        local text = tostring(value)
        return "n" .. #text .. ":" .. text
    end

    if valueType == "boolean" then
        return value and "b1" or "b0"
    end

    assert(valueType == "table", "Unsupported sync value")

    local result = { "t" }
    for key, entry in pairs(value) do
        result[#result + 1] = encode(key)
        result[#result + 1] = encode(entry)
    end
    result[#result + 1] = "e"

    return table.concat(result)
end

local function decode(text)
    local position = 1

    local function readValue()
        local tag = text:sub(position, position)
        position = position + 1

        if tag == "b" then
            local value = text:sub(position, position)
            position = position + 1
            assert(value == "0" or value == "1", "Invalid boolean")
            return value == "1"
        end

        if tag == "t" then
            local result = {}
            while text:sub(position, position) ~= "e" do
                assert(position <= #text, "Incomplete table")
                local key = readValue()
                result[key] = readValue()
            end
            position = position + 1
            return result
        end

        assert(tag == "s" or tag == "n", "Invalid sync value")
        local separator = text:find(":", position, true)
        assert(separator ~= nil, "Invalid sync length")
        local length = tonumber(text:sub(position, separator - 1))
        assert(length ~= nil and length >= 0, "Invalid sync length")
        position = separator + 1

        local value = text:sub(position, position + length - 1)
        assert(#value == length, "Incomplete sync value")
        position = position + length

        if tag == "n" then
            value = tonumber(value)
            assert(value ~= nil, "Invalid sync number")
        end

        return value
    end

    local result = readValue()
    assert(position == #text + 1, "Trailing sync data")
    return result
end

local function normalizeName(name)
    if type(name) ~= "string" then
        return nil
    end

    return string.lower(string.match(name, "^[^-]+") or name)
end

local function isSamePlayer(left, right)
    return normalizeName(left) ~= nil
        and normalizeName(left) == normalizeName(right)
end

local function getGroupChannel()
    if IsInRaid ~= nil and IsInRaid() then
        return "RAID"
    end

    if IsInGroup ~= nil and IsInGroup() then
        return "PARTY"
    end

    return nil
end

local function getLocalPlayerName()
    if UnitFullName ~= nil then
        local name, realm = UnitFullName("player")
        if name ~= nil and realm ~= nil and realm ~= "" then
            return name .. "-" .. realm
        end
        return name
    end

    if UnitName ~= nil then
        return UnitName("player")
    end

    return nil
end

local function findSessionPlayer(session, name)
    for _, player in ipairs(session:GetPlayers():GetAll()) do
        if isSamePlayer(player:GetName(), name) then
            return player
        end
    end

    return nil
end

local function findResponseDistribution(session, player)
    if session.GetDistributions == nil then
        return nil
    end

    local distributions = session:GetDistributions()
    if distributions == nil or distributions.GetAll == nil then
        return nil
    end

    local all = distributions:GetAll()
    for index = #all, 1, -1 do
        local distribution = all[index]
        if distribution:IsRolling()
            and not distribution:IsRollGraceActive()
            and distribution:GetResponse(player) == nil
        then
            for _, participant in ipairs(distribution:GetRollParticipants()) do
                if participant == player then
                    return distribution
                end
            end
        end
    end

    return nil
end

local function showPendingResponse(session)
    if addon.uiManager == nil then
        return
    end

    local playerName = getLocalPlayerName()
    local player = playerName ~= nil
        and findSessionPlayer(session, playerName)
        or nil
    if player == nil then
        return
    end

    local distribution = findResponseDistribution(session, player)
    if distribution ~= nil then
        addon.uiManager:ShowDistribution(distribution)
    end
end

function SessionSync.New(sessionManager, persistence)
    assert(sessionManager ~= nil, "Session manager is required")
    assert(persistence ~= nil, "Session persistence is required")

    return setmetatable({
        sessionManager = sessionManager,
        persistence = persistence,
        transfers = {},
        nextTransferId = 0,
        publishedEndings = {},
    }, SessionSync)
end

function SessionSync:Initialize()
    assert(
        C_ChatInfo ~= nil
            and type(C_ChatInfo.RegisterAddonMessagePrefix) == "function"
            and type(C_ChatInfo.SendAddonMessage) == "function",
        "WoW Forever addon messaging API is unavailable"
    )

    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

    for _, session in ipairs(self.sessionManager:GetHistory()) do
        self.publishedEndings[session:GetId()] = true
    end

    return self
end

function SessionSync:Send(channel, message, target)
    if C_ChatInfo == nil
        or type(C_ChatInfo.SendAddonMessage) ~= "function"
    then
        return false
    end

    C_ChatInfo.SendAddonMessage(PREFIX, message, channel, target)
    return true
end

function SessionSync:RequestSnapshot()
    local channel = getGroupChannel()
    if channel == nil then
        return false
    end

    return self:Send(channel, "H")
end

function SessionSync:SendSnapshot(session, channel, target)
    local data = self.persistence:SerializeSession(session)
    local payload = encode(data)
    local chunkCount = math.ceil(#payload / CHUNK_SIZE)

    assert(chunkCount > 0 and chunkCount <= MAX_CHUNKS, "Session snapshot is too large")

    self.nextTransferId = self.nextTransferId + 1
    local transferId = tostring(self.nextTransferId)

    for chunkIndex = 1, chunkCount do
        local startIndex = (chunkIndex - 1) * CHUNK_SIZE + 1
        local chunk = payload:sub(startIndex, startIndex + CHUNK_SIZE - 1)
        self:Send(
            channel,
            table.concat({ "D", transferId, chunkIndex, chunkCount, chunk }, "|"),
            target
        )
    end

    return true
end

function SessionSync:Publish()
    local channel = getGroupChannel()
    local localName = getLocalPlayerName()

    if channel == nil or localName == nil then
        return false
    end

    local sent = false
    for _, session in ipairs(self.sessionManager:GetActiveSessionList()) do
        if isSamePlayer(session:GetMasterLooter():GetName(), localName) then
            self:SendSnapshot(session, channel)
            sent = true
        end
    end

    for _, session in ipairs(self.sessionManager:GetHistory()) do
        local sessionId = session:GetId()
        if self.publishedEndings[sessionId] ~= true
            and isSamePlayer(session:GetMasterLooter():GetName(), localName)
        then
            self:Send(
                channel,
                "E|" .. encode({
                    sessionId = sessionId,
                    endedAt = session:GetEndedAt(),
                })
            )
            self.publishedEndings[sessionId] = true
            sent = true
        end
    end

    return sent
end

function SessionSync:SubmitResponse(sessionId, distributionIndex, response)
    local session = self.sessionManager:GetActive(sessionId)
    local playerName = getLocalPlayerName()

    if session == nil or playerName == nil then
        return false
    end

    local player = findSessionPlayer(session, playerName)
    local distribution = session:GetDistribution(distributionIndex)

    if player == nil
        or distribution == nil
        or (response ~= "NEED" and response ~= "PASS")
    then
        return false
    end

    local masterLooter = session:GetMasterLooter()
    if isSamePlayer(masterLooter:GetName(), playerName) then
        distribution:Respond(player, response)
        self.sessionManager:Save()
        return true
    end

    distribution:Respond(player, response)
    self.sessionManager:Save()

    return self:Send(
        "WHISPER",
        "A|" .. encode({
            sessionId = sessionId,
            distributionIndex = distributionIndex,
            playerName = player:GetName(),
            response = response,
        }),
        masterLooter:GetName()
    )
end

function SessionSync:HandleAction(message, sender)
    local ok, action = pcall(decode, message:sub(3))
    if not ok or type(action) ~= "table" then
        return false
    end

    local session = self.sessionManager:GetActive(action.sessionId)
    if session == nil
        or not isSamePlayer(
            session:GetMasterLooter():GetName(),
            getLocalPlayerName()
        )
    then
        return false
    end

    if not isSamePlayer(action.playerName, sender) then
        return false
    end

    local player = findSessionPlayer(session, action.playerName)
    local distribution = session:GetDistribution(action.distributionIndex)
    if player == nil
        or distribution == nil
        or not distribution:IsPending()
        or not distribution:IsRolling()
        or distribution:IsRollGraceActive()
    then
        return false
    end

    local isRollParticipant = false
    for _, participant in ipairs(distribution:GetRollParticipants()) do
        if participant == player then
            isRollParticipant = true
            break
        end
    end

    if not isRollParticipant then
        return false
    end

    if action.response == "NEED" then
        if distribution:GetResponse(player) == nil
            and not distribution:HasPendingRoll(player)
        then
            distribution:BeginRoll(player)
        end
    elseif action.response == "PASS" then
        distribution:Respond(player, "PASS")
    else
        return false
    end

    self.sessionManager:Save()
    return true
end

function SessionSync:HandleMessage(prefix, message, channel, sender)
    if prefix ~= PREFIX
        or type(message) ~= "string"
        or (channel ~= "PARTY" and channel ~= "RAID" and channel ~= "INSTANCE_CHAT" and channel ~= "WHISPER")
        or isSamePlayer(sender, getLocalPlayerName())
    then
        return false
    end

    if message == "H" then
        for _, session in ipairs(self.sessionManager:GetActiveSessionList()) do
            if isSamePlayer(
                session:GetMasterLooter():GetName(),
                getLocalPlayerName()
            ) then
                self:SendSnapshot(session, "WHISPER", sender)
            end
        end
        return true
    end

    if message:sub(1, 2) == "A|" then
        return self:HandleAction(message, sender)
    end

    if message:sub(1, 2) == "E|" then
        local ok, ending = pcall(decode, message:sub(3))
        if not ok or type(ending) ~= "table" then
            return false
        end

        local session = self.sessionManager:GetActive(ending.sessionId)
        if session == nil
            or not isSamePlayer(
                session:GetMasterLooter():GetName(),
                sender
            )
            or ending.endedAt == nil
        then
            return false
        end

        session:End(ending.endedAt)
        self.sessionManager.activeSessions[ending.sessionId] = nil
        table.insert(self.sessionManager.history, session)
        self.persistence:Save(self.sessionManager)

        if addon.uiManager ~= nil then
            addon.uiManager:RefreshMainWindow()
        end

        return true
    end

    local transferId, chunkIndex, chunkCount, chunk = message:match(
        "^D|(%d+)|(%d+)|(%d+)|(.*)$"
    )

    if transferId == nil then
        return false
    end

    chunkIndex = tonumber(chunkIndex)
    chunkCount = tonumber(chunkCount)
    if chunkCount == nil
        or chunkCount < 1
        or chunkCount > MAX_CHUNKS
        or chunkIndex == nil
        or chunkIndex < 1
        or chunkIndex > chunkCount
    then
        return false
    end

    local transferKey = sender .. ":" .. transferId
    local transfer = self.transfers[transferKey]

    if transfer == nil then
        transfer = {
            count = chunkCount,
            chunks = {},
            size = 0,
        }
        self.transfers[transferKey] = transfer
    end

    if transfer.count ~= chunkCount then
        self.transfers[transferKey] = nil
        return false
    end

    if transfer.chunks[chunkIndex] == nil then
        transfer.chunks[chunkIndex] = chunk
        transfer.size = transfer.size + #chunk
    end

    if transfer.size > MAX_PAYLOAD_SIZE then
        self.transfers[transferKey] = nil
        return false
    end

    for index = 1, transfer.count do
        if transfer.chunks[index] == nil then
            return true
        end
    end

    self.transfers[transferKey] = nil
    local decoded, sessionData = pcall(
        decode,
        table.concat(transfer.chunks)
    )

    if not decoded
        or type(sessionData) ~= "table"
        or type(sessionData.masterLooter) ~= "table"
        or not isSamePlayer(sessionData.masterLooter.name, sender)
    then
        return false
    end

    local ok, session = pcall(
        self.persistence.DeserializeSession,
        self.persistence,
        sessionData
    )

    if not ok or session:IsEnded() then
        return false
    end

    self.sessionManager.activeSessions[session:GetId()] = session
    self.persistence:Save(self.sessionManager)

    showPendingResponse(session)

    if addon.uiManager ~= nil then
        addon.uiManager:RefreshMainWindow()
    end

    return true
end

addon.Loot.Sessions.SessionSync = SessionSync
