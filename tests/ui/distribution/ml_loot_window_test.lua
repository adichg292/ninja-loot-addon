local addon = {}

local loadButton = assert(
    loadfile("UI/Components/Button.lua")
)

loadButton(
    "NinjaLoot",
    addon
)

local loadCloseButton = assert(
    loadfile("UI/Components/CloseButton.lua")
)

loadCloseButton(
    "NinjaLoot",
    addon
)

local loadWindow = assert(
    loadfile(
        "UI/Distribution/MLLootWindow.lua"
    )
)

loadWindow(
    "NinjaLoot",
    addon
)

assert(
    addon.UI ~= nil,
    "UI namespace was not created"
)

assert(
    addon.UI.Distribution ~= nil,
    "Distribution namespace was not created"
)

assert(
    addon.UI.Distribution.MLLootWindow
        ~= nil,
    "MLLootWindow was not created"
)

local parent = CreateFrame(
    "Frame",
    nil,
    nil
)

local window =
    addon.UI.Distribution.MLLootWindow.New(
        parent
    )

assert(
    window ~= nil,
    "ML loot window was not created"
)

assert(
    window.frame ~= nil,
    "ML loot window frame was not created"
)

assert(
    window.frame:GetWidth() == 700,
    "ML loot window width is incorrect"
)

assert(
    window.frame:GetHeight() == 500,
    "ML loot window height is incorrect"
)

assert(
    window:IsShown() == false,
    "ML loot window should start hidden"
)

assert(
    window:GetDistribution() == nil,
    "Distribution should initially be nil"
)

assert(
    window:GetAwardHandler() == nil,
    "Award handler should initially be nil"
)

assert(
    window:GetItemText()
        == "Item: None",
    "Initial item text is incorrect"
)

assert(
    window:GetBossText()
        == "Boss: None",
    "Initial boss text is incorrect"
)

assert(
    window:GetStatusText()
        == "Round: 0    Phase: UNKNOWN",
    "Initial status text is incorrect"
)

assert(
    window:GetWinnerText()
        == "Winner: Pending",
    "Initial winner text is incorrect"
)

assert(
    window:GetPlayersText()
        == "No players.",
    "Initial player text is incorrect"
)

assert(
    window.awardButton ~= nil,
    "Award button was not created"
)

assert(
    window.closeButton ~= nil,
    "Close button was not created"
)

assert(
    window.awardButton:IsShown() == false,
    "Award button should start hidden"
)

local alice = {
    GetName = function()
        return "Alice"
    end,
}

local bob = {
    GetName = function()
        return "Bob"
    end,
}

local aliceResponse = {
    GetResponse = function()
        return "NEED"
    end,

    GetRoll = function()
        return 95
    end,
}

local bobResponse = {
    GetResponse = function()
        return "NEED"
    end,

    GetRoll = function()
        return 72
    end,
}

local distribution = {
    GetItem = function()
        return {
            GetName = function()
                return "Test Sword"
            end,
        }
    end,

    GetBoss = function()
        return {
            GetName = function()
                return "Test Boss"
            end,
        }
    end,

    GetPhase = function()
        return "ROLLING"
    end,

    GetCurrentAttempt = function()
        return 1
    end,

    GetRollParticipants = function()
        return {
            alice,
            bob,
        }
    end,

    GetResponse = function(
        self,
        player
    )
        if player == alice then
            return aliceResponse
        end

        if player == bob then
            return bobResponse
        end

        return nil
    end,

    GetWinner = function()
        return nil
    end,

    GetSuggestedWinner = function()
        return bob
    end,

    GetSelectedRoll = function()
        return nil
    end,

    IsAwardPending = function()
        return false
    end,
}

window:SetDistribution(
    distribution
)

assert(
    window:GetDistribution()
        == distribution,
    "Distribution was not assigned"
)

assert(
    window:GetItemText()
        == "Item: Test Sword",
    "Item text is incorrect"
)

assert(
    window:GetBossText()
        == "Boss: Test Boss",
    "Boss text is incorrect"
)

assert(
    window:GetStatusText()
        == "Round: 1    Phase: ROLLING",
    "Rolling status text is incorrect"
)

assert(
    window:GetWinnerText()
        == "Winner: Pending",
    "Winner should remain pending while rolling"
)

local playersText =
    window:GetPlayersText()

assert(
    string.find(
        playersText,
        "Alice"
    ) ~= nil,
    "Alice was not displayed"
)

assert(
    string.find(
        playersText,
        "95"
    ) ~= nil,
    "Alice roll was not displayed"
)

assert(
    string.find(
        playersText,
        "Bob"
    ) ~= nil,
    "Bob was not displayed"
)

assert(
    string.find(
        playersText,
        "72"
    ) ~= nil,
    "Bob roll was not displayed"
)

assert(
    window.awardButton:IsShown()
        == false,
    "Award button should be hidden while rolling"
)

distribution.GetPhase =
    function()
        return "AWARD_PENDING"
    end

distribution.IsAwardPending =
    function()
        return true
    end

window:Update()

assert(
    window:GetStatusText()
        == "Round: 1    Phase: AWARD_PENDING",
    "Award pending status text is incorrect"
)

assert(
    window:GetWinnerText()
        == "Winner: Bob (72)",
    "Suggested winner was not displayed"
)

assert(
    window.awardButton:IsShown()
        == true,
    "Award button should be visible when award is pending"
)

distribution.GetWinner =
    function()
        return bob
    end

distribution.GetSelectedRoll =
    function()
        return 72
    end

window:Update()

assert(
    window:GetWinnerText()
        == "Winner: Bob (72)",
    "Selected winner was not displayed"
)

local awardCalled = false

window:SetAwardHandler(
    function(receivedDistribution)
        awardCalled = true

        assert(
            receivedDistribution
                == distribution,
            "Award handler should receive the active distribution"
        )

        return true
    end
)

assert(
    window:GetAwardHandler() ~= nil,
    "Award handler should be configured"
)

local awardSuccess =
    window:Award()

assert(
    awardSuccess,
    "Window award action should return handler result"
)

assert(
    awardCalled,
    "Window award action should invoke handler"
)

distribution.GetPhase =
    function()
        return "FINAL"
    end

distribution.IsAwardPending =
    function()
        return false
    end

window:Update()

assert(
    window.awardButton:IsShown()
        == false,
    "Award button should hide after award completion"
)

window:Show()

assert(
    window:IsShown() == true,
    "ML loot window should be visible after Show"
)

window:Hide()

assert(
    window:IsShown() == false,
    "ML loot window should be hidden after Hide"
)

window:SetDistribution(nil)

assert(
    window:GetDistribution() == nil,
    "Distribution should be cleared"
)

assert(
    window:GetItemText()
        == "Item: None",
    "Item text should reset"
)

assert(
    window:GetBossText()
        == "Boss: None",
    "Boss text should reset"
)

assert(
    window:GetStatusText()
        == "Round: 0    Phase: UNKNOWN",
    "Status text should reset"
)

assert(
    window:GetWinnerText()
        == "Winner: Pending",
    "Winner text should reset"
)

assert(
    window:GetPlayersText()
        == "No players.",
    "Player text should reset"
)

assert(
    window.awardButton:IsShown()
        == false,
    "Award button should be hidden after clearing distribution"
)