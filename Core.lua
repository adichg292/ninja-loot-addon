local addonName, addon = ...

addon.name = addonName

addon.Events = addon.Events or {}

local eventFrame = CreateFrame(
    "Frame",
    "NinjaLootEventFrame"
)

addon.Events.Frame = eventFrame

local function getTimestamp()
    if GetServerTime ~= nil then
        return GetServerTime()
    end

    if time ~= nil then
        return time()
    end

    return 0
end

local function initializePersistence()
    if addon.sessionPersistence == nil then
        addon.sessionPersistence =
            addon.Loot.Sessions.SessionPersistence.New()

        addon.sessionPersistence:Initialize()
    end
end

local function initializeConfig()
    if addon.configManager ~= nil then
        return
    end

    addon.configManager =
        addon.Loot.Config.ConfigManager.New(
            addon.sessionPersistence
        )

    addon.configManager:Initialize()
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
        end
    )
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
    end

    addon.uiManager:SetAwardHandler(
        function(distribution)
            local timestamp =
                getTimestamp()

            local success =
                addon.awardService:
                AwardWinner(
                    distribution,
                    addon.Loot.Distributions.Constants
                        .AwardMethods.LOOT,
                    timestamp,
                    timestamp
                )

            if addon.sessionManager ~= nil then
                addon.sessionManager:Save()
            end

            if addon.uiManager ~= nil then
                addon.uiManager:
                    UpdateDistribution(
                        distribution
                    )

                addon.uiManager:
                    RefreshMainWindow()
            end

            return success
        end
    )
end

local function initializeAddon()
    initializePersistence()
    initializeConfig()
    initializeSessionManager()
    initializeHistory()
    initializeLootManager()
    initializeUI()
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

local function findParticipantByName(
    distribution,
    playerName
)
    for _, player in ipairs(
        distribution:GetParticipants()
    ) do
        if player:GetName() == playerName then
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
                findParticipantByName(
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

    addon.lootManager:
        HandleLootOpened()
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

    addon.lootManager:
        HandleLootClosed()
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
    end
end

eventFrame:RegisterEvent(
    "ADDON_LOADED"
)

eventFrame:RegisterEvent(
    "CHAT_MSG_SYSTEM"
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

eventFrame:SetScript(
    "OnEvent",
    handleEvent
)