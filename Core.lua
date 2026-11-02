local addonName, addon = ...

addon.name = addonName

addon.Events = addon.Events or {}

local eventFrame = CreateFrame(
    "Frame",
    nil
)

addon.Events.Frame = eventFrame

function addon.DebugLog(message)
    if addon.configManager == nil
        or not addon.configManager:Get("General.DebugLogging")
    then
        return false
    end

    local text = "|cff888888NinjaLoot debug:|r " .. tostring(message)
    if DEFAULT_CHAT_FRAME ~= nil and DEFAULT_CHAT_FRAME.AddMessage ~= nil then
        DEFAULT_CHAT_FRAME:AddMessage(text)
    elseif print ~= nil then
        print(text)
    end
    return true
end

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

local function notifyAwardResult(distribution)
    local award = distribution:GetAward()
    if award == nil then
        return
    end

    local constants = addon.Loot.Distributions.Constants
    local item = distribution:GetItem()
    local itemName = item ~= nil and item:GetName() or "item"
    local recipient = award.recipient
    local recipientName = recipient ~= nil and recipient:GetName()
        or "the selected player"

    if award.state == constants.AwardStates.SUCCESS then
        if addon.notificationManager ~= nil then
            addon.notificationManager:Notify(
                "Award completed.",
                "Awarded " .. tostring(itemName) .. " to "
                    .. tostring(recipientName) .. " via "
                    .. tostring(award.method or "unknown method") .. "."
            )
        end

        if addon.announcementManager ~= nil then
            addon.announcementManager:AnnounceAward(distribution)
        end
    elseif award.state == constants.AwardStates.FAILED then
        if addon.notificationManager ~= nil then
            addon.notificationManager:Notify(
                "Award failed.",
                "Award failed for " .. tostring(itemName) .. ": "
                    .. tostring(award.error or "unknown error")
            )
        end
    end
end

local function initializePersistence()
    if addon.sessionPersistence == nil then
        addon.sessionPersistence =
            addon.Loot.Sessions.SessionPersistence.New()

        addon.sessionPersistence:Initialize()
    end
end

local function initializeConfig()
    if addon.configManager == nil then
        addon.configManager =
            addon.Loot.Config.ConfigManager.New(
                addon.sessionPersistence
            )

        addon.configManager:Initialize()
    end

    if addon.notificationManager == nil
        and addon.Loot.Notifications ~= nil
        and addon.Loot.Notifications.NotificationManager ~= nil
    then
        addon.notificationManager =
            addon.Loot.Notifications.NotificationManager.New(
                addon.configManager
            )
    end

    if addon.announcementManager == nil
        and addon.Loot.AnnouncementManager ~= nil
    then
        addon.announcementManager =
            addon.Loot.AnnouncementManager.New(
                addon.configManager
            )
    end
end

local function initializeSessionManager()
    if addon.sessionManager == nil then
        addon.sessionManager =
            addon.Loot.Sessions.SessionManager.New(
                addon.sessionPersistence
            )
    else
        addon.sessionManager:SetPersistence(
            addon.sessionPersistence
        )
    end

    addon.sessionManager:Restore()
    if addon.configManager ~= nil then
        addon.configManager:ApplyRuntimeSettings()
    end
end

local function initializeSessionSync()
    if addon.sessionSync == nil then
        addon.sessionSync =
            addon.Loot.Sessions.SessionSync.New(
                addon.sessionManager,
                addon.sessionPersistence
            )

        addon.sessionSync:Initialize()
    end

    addon.sessionManager:SetSyncHandler(function()
        addon.sessionSync:Publish()
    end)

    addon.sessionSync:RequestSnapshot()
end

local function initializeHistory()
    addon.historyManager =
        addon.Loot.History.HistoryManager.New(
            addon.sessionManager
        )
end

local function initializeLootManager()
    if addon.lootManager ~= nil then
        return
    end

    addon.lootManager =
        addon.Loot.LootManager.New(
            addon.sessionManager
        )
end

local function initializeUI()
    if addon.uiManager == nil then
        addon.uiManager =
            addon.UI.UIManager.New()
    end

    addon.uiManager:Initialize()

    addon.lootManager:SetDistributionHandler(
        function(distribution)
            addon.uiManager:
                ShowDistribution(
                    distribution
                )

            if addon.sessionManager ~= nil then
                addon.sessionManager:Save()
            end

        end
    )

    addon.uiManager:SetResponseHandler(function(distribution, response)
        for _, session in ipairs(
            addon.sessionManager:GetActiveSessionList()
        ) do
            local distributions = session:GetDistributions():GetAll()
            for index, candidate in ipairs(distributions) do
                if candidate == distribution then
                    return addon.sessionSync:SubmitResponse(
                        session:GetId(),
                        index,
                        response
                    )
                end
            end
        end

        return false
    end)
end

local function initializeAwardService()
    if addon.awardService == nil then
        addon.awardService =
            addon.Loot.Distributions.AwardService.New(
                addon.lootManager
            )

        addon.Loot.Distributions.WoWAwardHandler.Register(
            addon.awardService
        )

        addon.Loot.Distributions.TradeAwardHandler.Register(
            addon.awardService
        )
    end

    local function awardUsingMethod(distribution, method)
        addon.DebugLog(
            "Starting " .. tostring(method) .. " award for "
                .. tostring(distribution:GetItem():GetName())
        )
        local timestamp = getTimestamp()

        local success
        if distribution:IsAwardFailed() then
            success = addon.awardService:RetryAward(
                distribution,
                method,
                timestamp,
                timestamp
            )
        else
            success = addon.awardService:AwardWinner(
                distribution,
                method,
                timestamp,
                timestamp
            )
        end

        if addon.sessionManager ~= nil then
            addon.sessionManager:Save()
        end

        if success ~= nil then
            notifyAwardResult(distribution)
            addon.DebugLog("Award handler completed: " .. tostring(success))
        end

        if addon.uiManager ~= nil then
            addon.uiManager:UpdateDistribution(distribution)
            addon.uiManager:RefreshMainWindow()
        end

        return success
    end

    addon.uiManager:SetAwardHandler(function(distribution)
        return awardUsingMethod(
            distribution,
            addon.Loot.Distributions.Constants.AwardMethods.LOOT
        )
    end)

    addon.uiManager:SetTradeHandler(function(distribution)
        return awardUsingMethod(
            distribution,
            addon.Loot.Distributions.Constants.AwardMethods.TRADE
        )
    end)
end

local function initializeAddon()
    initializePersistence()
    initializeConfig()
    initializeSessionManager()
    initializeSessionSync()
    initializeHistory()
    initializeLootManager()
    initializeUI()
    if addon.configManager ~= nil then
        addon.configManager:ApplyRuntimeSettings()
    end
    initializeAwardService()
end

local function getActiveDistributions()
    local distributions = {}

    if addon.sessionManager == nil then
        return distributions
    end

    for _, session in ipairs(
        addon.sessionManager:GetActiveSessionList()
    ) do
        local manager =
            session:GetDistributions()

        for _, distribution in ipairs(
            manager:GetAll()
        ) do
            table.insert(
                distributions,
                distribution
            )
        end
    end

    return distributions
end

local function findPendingRollParticipant(
    distribution,
    playerName
)
    for _, player in ipairs(
        distribution:GetRollParticipants()
    ) do
        if player:GetName() == playerName
            and distribution:HasPendingRoll(player)
        then
            return player
        end
    end

    return nil
end

local function parseRollMessage(
    message
)
    if type(message) ~= "string" then
        return nil
    end

    local playerName,
        roll,
        minimum,
        maximum =
        message:match(
            "^(.+) rolls (%d+) %((%d+)%-(%d+)%)$"
        )

    if playerName == nil then
        return nil
    end

    return {
        playerName = playerName,
        roll = tonumber(roll),
        minimum = tonumber(minimum),
        maximum = tonumber(maximum),
    }
end

local function handleChatSystem(
    message
)
    local roll =
        parseRollMessage(message)

    if roll == nil then
        return
    end

    if roll.minimum ~= 1
        or roll.maximum ~= 100
    then
        return
    end

    local matches = {}

    for _, distribution in ipairs(
        getActiveDistributions()
    ) do
        if distribution:IsPending()
            and distribution:IsRolling()
        then
            local player =
                findPendingRollParticipant(
                    distribution,
                    roll.playerName
                )

            if player ~= nil then
                table.insert(
                    matches,
                    {
                        distribution = distribution,
                        player = player,
                    }
                )
            end
        end
    end

    if #matches ~= 1 then
        return
    end

    local match =
        matches[1]

    match.distribution:RegisterRoll(
        match.player,
        roll.roll,
        addon.Loot.Distributions.Constants
            .RollSources.CHAT
    )

    if addon.uiManager ~= nil then
        addon.uiManager:
            UpdateDistribution(
                match.distribution
            )
    end

    if addon.sessionManager ~= nil then
        addon.sessionManager:Save()
    end
end

local function handleLootOpened()
    if addon.lootManager == nil then
        return
    end

    local items = addon.lootManager:HandleLootOpened()

    if items ~= nil and #items > 0
        and addon.sessionManager ~= nil
    then
        addon.sessionManager:Save()
    end

    if addon.uiManager ~= nil then
        addon.uiManager:RefreshMainWindow()
    end
end

local function handleLootSlotCleared(
    lootSlot
)
    if addon.lootManager == nil then
        return
    end

    addon.lootManager:
        HandleLootSlotCleared(
            lootSlot
        )

    local distribution =
        addon.Loot.Distributions.WoWAwardHandler.
        ConfirmLootSlotCleared(
            lootSlot
        )

    if distribution == false then
        return
    end

    notifyAwardResult(distribution)

    if addon.sessionManager ~= nil then
        addon.sessionManager:Save()
    end

    if addon.uiManager ~= nil then
        addon.uiManager:UpdateDistribution(distribution)
        addon.uiManager:RefreshMainWindow()
    end
end

local function handleLootSlotChanged(
    lootSlot
)
    if addon.lootManager == nil then
        return
    end

    addon.lootManager:
        HandleLootSlotChanged(
            lootSlot
        )
end

local function handleLootClosed()
    if addon.lootManager == nil then
        return
    end

    local failedAwards = addon.Loot.Distributions.WoWAwardHandler
        .FailPendingAwards(
            "Loot window closed before award confirmation"
        )
    addon.lootManager:
        HandleLootClosed()

    if #failedAwards > 0 then
        for _, distribution in ipairs(failedAwards) do
            notifyAwardResult(distribution)
            if addon.uiManager ~= nil then
                addon.uiManager:UpdateDistribution(distribution)
            end
        end
        if addon.sessionManager ~= nil then
            addon.sessionManager:Save()
        end
        if addon.uiManager ~= nil then
            addon.uiManager:RefreshMainWindow()
        end
    end
end

local function refreshTradeAward(distribution)
    if distribution == false or distribution == nil then
        return
    end

    notifyAwardResult(distribution)

    if addon.sessionManager ~= nil then
        addon.sessionManager:Save()
    end

    if addon.uiManager ~= nil then
        addon.uiManager:UpdateDistribution(distribution)
        addon.uiManager:RefreshMainWindow()
    end
end

local function handleEvent(
    self,
    event,
    ...
)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...

        if loadedAddon == addonName then
            initializeAddon()
        end

        return
    end

    if event == "LOOT_OPENED" then
        handleLootOpened()

        return
    end

    if event == "LOOT_SLOT_CLEARED" then
        handleLootSlotCleared(...)

        return
    end

    if event == "LOOT_SLOT_CHANGED" then
        handleLootSlotChanged(...)

        return
    end

    if event == "LOOT_CLOSED" then
        handleLootClosed()

        return
    end

    if event == "CHAT_MSG_SYSTEM" then
        handleChatSystem(...)
        return
    end

    if event == "CHAT_MSG_ADDON" then
        if addon.sessionSync ~= nil then
            addon.sessionSync:HandleMessage(...)
        end
        return
    end

    if event == "GROUP_ROSTER_UPDATE" then
        if addon.sessionSync ~= nil then
            addon.sessionSync:RequestSnapshot()
        end
    end

    local tradeHandler =
        addon.Loot.Distributions.TradeAwardHandler

    if event == "TRADE_SHOW" then
        tradeHandler.HandleTradeShow()
        return
    end

    if event == "TRADE_PLAYER_ITEM_CHANGED" then
        tradeHandler.HandlePlayerItemChanged()
        return
    end

    if event == "TRADE_ACCEPT_UPDATE" then
        tradeHandler.HandleAcceptUpdate(...)
        return
    end

    if event == "TRADE_CLOSED" then
        refreshTradeAward(
            tradeHandler.HandleTradeClosed()
        )
        return
    end
end

eventFrame:RegisterEvent(
    "ADDON_LOADED"
)

eventFrame:RegisterEvent(
    "CHAT_MSG_SYSTEM"
)

eventFrame:RegisterEvent(
    "CHAT_MSG_ADDON"
)

eventFrame:RegisterEvent(
    "GROUP_ROSTER_UPDATE"
)

eventFrame:RegisterEvent(
    "LOOT_OPENED"
)

eventFrame:RegisterEvent(
    "LOOT_SLOT_CLEARED"
)

eventFrame:RegisterEvent(
    "LOOT_SLOT_CHANGED"
)

eventFrame:RegisterEvent(
    "LOOT_CLOSED"
)

eventFrame:RegisterEvent("TRADE_SHOW")
eventFrame:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED")
eventFrame:RegisterEvent("TRADE_ACCEPT_UPDATE")
eventFrame:RegisterEvent("TRADE_CLOSED")

eventFrame:SetScript(
    "OnEvent",
    handleEvent
)
