local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Distribution =
    addon.UI.Distribution or {}

local MLLootWindow = {}
MLLootWindow.__index = MLLootWindow

local function getDistributionItem(
    distribution
)
    if distribution == nil then
        return nil
    end

    if distribution.GetItem == nil then
        return nil
    end

    return distribution:GetItem()
end

local function getDistributionBoss(
    distribution
)
    if distribution == nil then
        return nil
    end

    if distribution.GetBoss == nil then
        return nil
    end

    return distribution:GetBoss()
end

local function getPhaseName(
    distribution
)
    if distribution == nil then
        return "UNKNOWN"
    end

    if distribution.GetPhase == nil then
        return "UNKNOWN"
    end

    return distribution:GetPhase()
end

local function getRound(
    distribution
)
    if distribution == nil then
        return 0
    end

    if distribution.GetCurrentAttempt == nil then
        return 0
    end

    return distribution:GetCurrentAttempt()
end

local function getPlayers(
    distribution
)
    if distribution == nil then
        return {}
    end

    if distribution.GetRollParticipants == nil then
        return {}
    end

    return distribution:GetRollParticipants()
end

local function getPlayerName(
    player
)
    if player == nil then
        return "Unknown"
    end

    if player.GetName == nil then
        return "Unknown"
    end

    return player:GetName()
end

local function getPlayerResponse(
    distribution,
    player
)
    if distribution == nil
        or player == nil
    then
        return nil
    end

    if distribution.GetResponse == nil then
        return nil
    end

    return distribution:GetResponse(
        player
    )
end

local function getResponseText(
    response
)
    if response == nil then
        return "WAITING"
    end

    if response.GetResponse ~= nil then
        local responseType =
            response:GetResponse()

        if responseType ~= nil then
            return tostring(responseType)
        end
    end

    if response.GetResponseType ~= nil then
        local responseType =
            response:GetResponseType()

        if responseType ~= nil then
            return tostring(responseType)
        end
    end

    if response.GetType ~= nil then
        local responseType =
            response:GetType()

        if responseType ~= nil then
            return tostring(responseType)
        end
    end

    return "RESPONDED"
end

local function getRollText(
    response
)
    if response == nil then
        return "--"
    end

    if response.GetRoll ~= nil then
        local roll = response:GetRoll()

        if roll ~= nil then
            return tostring(roll)
        end
    end

    return "--"
end

local function getWinner(
    distribution
)
    if distribution == nil then
        return nil
    end

    if distribution.GetWinner ~= nil then
        local winner =
            distribution:GetWinner()

        if winner ~= nil then
            return winner
        end
    end

    if distribution.GetSuggestedWinner ~= nil then
        return distribution:GetSuggestedWinner()
    end

    return nil
end

local function getWinnerRoll(
    distribution,
    winner
)
    if distribution == nil
        or winner == nil
    then
        return nil
    end

    if distribution.GetSelectedRoll ~= nil then
        local selectedRoll =
            distribution:GetSelectedRoll()

        if selectedRoll ~= nil then
            return selectedRoll
        end
    end

    local response =
        getPlayerResponse(
            distribution,
            winner
        )

    if response ~= nil
        and response.GetRoll ~= nil
    then
        return response:GetRoll()
    end

    return nil
end

local function getWinnerText(
    distribution
)
    if distribution == nil then
        return "Winner: Pending"
    end

    local phase =
        getPhaseName(
            distribution
        )

    if phase == "ROLLING" then
        return "Winner: Pending"
    end

    local winner =
        getWinner(
            distribution
        )

    if winner == nil then
        return "Winner: None"
    end

    local winnerName =
        getPlayerName(winner)

    local roll =
        getWinnerRoll(
            distribution,
            winner
        )

    if roll == nil then
        return "Winner: "
            .. winnerName
    end

    return "Winner: "
        .. winnerName
        .. " ("
        .. tostring(roll)
        .. ")"
end

local function isAwardFailed(distribution)
    if distribution == nil or distribution.GetAward == nil then
        return false
    end
    local award = distribution:GetAward()
    return award ~= nil
        and award.state == "FAILED"
end

local function normalizePlayerName(name)
    if type(name) ~= "string" then
        return nil
    end

    return string.lower(string.match(name, "^[^-]+") or name)
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

function MLLootWindow.New(parent)
    assert(
        parent ~= nil,
        "ML loot window parent is required"
    )

    local self =
        setmetatable({}, MLLootWindow)

    local frame = CreateFrame(
        "Frame",
        nil,
        parent
    )

    frame:SetWidth(700)
    frame:SetHeight(500)

    frame:SetPoint(
        "CENTER",
        parent,
        "CENTER"
    )

    local title =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormalLarge"
        )

    title:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        -20
    )

    title:SetText(
        "NinjaLoot - Master Looter"
    )

    local itemText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    itemText:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -15
    )

    itemText:SetText(
        "Item: None"
    )

    local bossText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    bossText:SetPoint(
        "TOPLEFT",
        itemText,
        "BOTTOMLEFT",
        0,
        -8
    )

    bossText:SetText(
        "Boss: None"
    )

    local statusText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    statusText:SetPoint(
        "TOPLEFT",
        bossText,
        "BOTTOMLEFT",
        0,
        -15
    )

    statusText:SetText(
        "Round: 0    Phase: UNKNOWN"
    )

    local winnerText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    winnerText:SetPoint(
        "TOPLEFT",
        statusText,
        "BOTTOMLEFT",
        0,
        -10
    )

    winnerText:SetText(
        "Winner: Pending"
    )

    local playersText =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    playersText:SetPoint(
        "TOPLEFT",
        winnerText,
        "BOTTOMLEFT",
        0,
        -20
    )

    playersText:SetJustifyH("LEFT")

    playersText:SetText(
        "No players."
    )

    local awardButton =
        addon.UI.Components.CreateButton(
            frame,
            nil,
            110,
            30
        )

    local tradeButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        80,
        30
    )
    tradeButton:SetPoint("RIGHT", awardButton, "LEFT", -6, 0)
    tradeButton:SetText("Trade")

    local needButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        80,
        30
    )
    needButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
    needButton:SetText("Need")

    local passButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        80,
        30
    )
    passButton:SetPoint("LEFT", needButton, "RIGHT", 6, 0)
    passButton:SetText("Pass")

    awardButton:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -20,
        20
    )

    awardButton:SetText("Master Loot")

    awardButton:Hide()
    tradeButton:Hide()
    needButton:Hide()
    passButton:Hide()

    local closeButton =
        addon.UI.Components.CreateCloseButton(
            frame
        )

    self.frame = frame
    self.title = title
    self.itemText = itemText
    self.bossText = bossText
    self.statusText = statusText
    self.winnerText = winnerText
    self.playersText = playersText
    self.awardButton = awardButton
    self.tradeButton = tradeButton
    self.needButton = needButton
    self.passButton = passButton
    self.closeButton = closeButton

    self.distribution = nil
    self.awardHandler = nil
    self.tradeHandler = nil
    self.responseHandler = nil

    awardButton:SetScript(
        "OnClick",
        function()
            self:Award()
        end
    )

    tradeButton:SetScript("OnClick", function()
        self:Trade()
    end)

    needButton:SetScript("OnClick", function()
        return self:Respond("NEED")
    end)
    passButton:SetScript("OnClick", function()
        return self:Respond("PASS")
    end)

    frame:Hide()

    return self
end

function MLLootWindow:SetDistribution(
    distribution
)
    self.distribution = distribution

    self:Update()

    return self
end

function MLLootWindow:GetDistribution()
    return self.distribution
end

function MLLootWindow:SetAwardHandler(
    handler
)
    assert(
        handler == nil
        or type(handler) == "function",
        "Award handler must be a function"
    )

    self.awardHandler = handler

    return self
end

function MLLootWindow:GetAwardHandler()
    return self.awardHandler
end

function MLLootWindow:SetTradeHandler(handler)
    assert(handler == nil or type(handler) == "function",
        "Trade handler must be a function")
    self.tradeHandler = handler
    self:Update()
    return self
end

function MLLootWindow:GetTradeHandler()
    return self.tradeHandler
end

function MLLootWindow:Trade()
    assert(self.distribution ~= nil, "Distribution is required")
    assert(self.distribution:IsAwardPending() or isAwardFailed(self.distribution),
        "Distribution is not waiting for award")
    assert(self.tradeHandler ~= nil, "Trade handler is not configured")

    local result = self.tradeHandler(self.distribution)
    self:Update()
    return result
end

function MLLootWindow:SetResponseHandler(handler)
    assert(
        handler == nil or type(handler) == "function",
        "Response handler must be a function"
    )

    self.responseHandler = handler
    return self
end

function MLLootWindow:GetResponseHandler()
    return self.responseHandler
end

function MLLootWindow:Respond(response)
    assert(self.distribution ~= nil, "Distribution is required")
    assert(
        response == "NEED" or response == "PASS",
        "Invalid distribution response"
    )
    assert(self.responseHandler ~= nil, "Response handler is not configured")

    local success = self.responseHandler(self.distribution, response)
    self:Update()
    return success
end

function MLLootWindow:UpdateResponseControls(distribution)
    local localName = getLocalPlayerName()
    local localPlayer = nil

    if distribution ~= nil and localName ~= nil
        and distribution.GetRollParticipants ~= nil
    then
        for _, player in ipairs(distribution:GetRollParticipants()) do
            if normalizePlayerName(player:GetName())
                == normalizePlayerName(localName)
            then
                localPlayer = player
                break
            end
        end
    end

    local shouldShow = localPlayer ~= nil
        and distribution.IsRolling ~= nil
        and distribution:IsRolling()
        and (distribution.IsRollGraceActive == nil
            or not distribution:IsRollGraceActive())
        and distribution:GetResponse(localPlayer) == nil
        and (distribution.HasPendingRoll == nil
            or not distribution:HasPendingRoll(localPlayer))
        and self.responseHandler ~= nil

    if shouldShow then
        self.needButton:Show()
        self.passButton:Show()
    else
        self.needButton:Hide()
        self.passButton:Hide()
    end

    return self
end

function MLLootWindow:Award()
    assert(
        self.distribution ~= nil,
        "Distribution is required"
    )

    assert(self.distribution:IsAwardPending() or isAwardFailed(self.distribution),
        "Distribution is not waiting for award")

    assert(
        self.awardHandler ~= nil,
        "Award handler is not configured"
    )

    local success =
        self.awardHandler(
            self.distribution
        )

    self:Update()

    return success
end

function MLLootWindow:Update()
    local distribution =
        self.distribution

    if distribution == nil then
        self.itemText:SetText(
            "Item: None"
        )

        self.bossText:SetText(
            "Boss: None"
        )

        self.statusText:SetText(
            "Round: 0    Phase: UNKNOWN"
        )

        self.winnerText:SetText(
            "Winner: Pending"
        )

        self.playersText:SetText(
            "No players."
        )

        self.awardButton:Hide()
        self.tradeButton:Hide()
        self:UpdateResponseControls(nil)

        return self
    end

    local item =
        getDistributionItem(
            distribution
        )

    local boss =
        getDistributionBoss(
            distribution
        )

    local itemName =
        item ~= nil
        and item:GetName()
        or "None"

    local bossName =
        boss ~= nil
        and boss:GetName()
        or "None"

    self.itemText:SetText(
        "Item: "
            .. tostring(itemName)
    )

    self.bossText:SetText(
        "Boss: "
            .. tostring(bossName)
    )

    self.statusText:SetText(
        "Round: "
            .. tostring(
                getRound(distribution)
            )
            .. "    Phase: "
            .. tostring(
                getPhaseName(distribution)
            )
    )

    self.winnerText:SetText(
        getWinnerText(
            distribution
        )
    )

    local players =
        getPlayers(distribution)

    if #players == 0 then
        self.playersText:SetText(
            "No players."
        )
    else
        local lines = {
            "Player        Response        Roll",
            "----------------------------------------",
        }

        for _, player in ipairs(players) do
            local response =
                getPlayerResponse(
                    distribution,
                    player
                )

            table.insert(
                lines,
                string.format(
                    "%-14s %-14s %s",
                    getPlayerName(player),
                    getResponseText(response),
                    getRollText(response)
                )
            )
        end

        self.playersText:SetText(
            table.concat(
                lines,
                "\n"
            )
        )
    end

    local canAward = distribution.IsAwardPending ~= nil
        and distribution:IsAwardPending()
    local retryingAward = isAwardFailed(distribution)
    if canAward or retryingAward then
        self.awardButton:SetText(retryingAward and "Retry Loot" or "Master Loot")
        self.awardButton:Show()
        if self.tradeHandler ~= nil then
            self.tradeButton:SetText(retryingAward and "Retry Trade" or "Trade")
            self.tradeButton:Show()
        else
            self.tradeButton:Hide()
        end
    else
        self.awardButton:Hide()
        self.tradeButton:Hide()
    end

    self:UpdateResponseControls(distribution)

    return self
end

function MLLootWindow:Show()
    self.frame:Show()

    return self
end

function MLLootWindow:Hide()
    self.frame:Hide()

    return self
end

function MLLootWindow:IsShown()
    return self.frame:IsShown()
end

function MLLootWindow:GetFrame()
    return self.frame
end

function MLLootWindow:GetItemText()
    return self.itemText:GetText()
end

function MLLootWindow:GetBossText()
    return self.bossText:GetText()
end

function MLLootWindow:GetStatusText()
    return self.statusText:GetText()
end

function MLLootWindow:GetWinnerText()
    return self.winnerText:GetText()
end

function MLLootWindow:GetPlayersText()
    return self.playersText:GetText()
end

addon.UI.Distribution.MLLootWindow =
    MLLootWindow
