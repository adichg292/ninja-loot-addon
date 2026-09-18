local function loadAddonFile(path)
    assert(
        loadfile(path),
        "Failed to load " .. path
    )()
end

loadAddonFile("Loot/Distributions/Constants.lua")
loadAddonFile("Loot/Distributions/DistributionPhase.lua")

local addon = _G.NinjaLoot
    or _G.NinjaLootAddon

assert(
    addon ~= nil,
    "Addon table was not created"
)

local Constants =
    addon.Loot.Distributions.Constants

local DistributionPhase =
    addon.Loot.Distributions.DistributionPhase

local rolling =
    DistributionPhase.New(
        Constants.Phases.ROLLING
    )

assert(
    rolling:GetPhase()
    == Constants.Phases.ROLLING,
    "Phase should be ROLLING"
)

assert(
    rolling:GetElapsed() == 0,
    "New phase should have zero elapsed time"
)

assert(
    rolling:GetDuration()
    == Constants.RollTimerSeconds,
    "Rolling phase should use roll timer"
)

assert(
    rolling:GetRemaining()
    == Constants.RollTimerSeconds,
    "New rolling phase should have full remaining time"
)

assert(
    not rolling:IsExpired(),
    "New phase should not be expired"
)

rolling:Update(5)

assert(
    rolling:GetElapsed() == 5,
    "Elapsed time should increase"
)

assert(
    rolling:GetRemaining()
    == Constants.RollTimerSeconds - 5,
    "Remaining time should decrease"
)

rolling:Update(
    Constants.RollTimerSeconds - 5
)

assert(
    rolling:GetElapsed()
    == Constants.RollTimerSeconds,
    "Elapsed time should stop at duration"
)

assert(
    rolling:GetRemaining() == 0,
    "Remaining time should be zero at expiration"
)

assert(
    rolling:IsExpired(),
    "Phase should expire at duration"
)

rolling:Update(10)

assert(
    rolling:GetElapsed()
    == Constants.RollTimerSeconds,
    "Expired phase should not continue advancing"
)

rolling:Expire()

assert(
    rolling:IsExpired(),
    "Expire should keep phase expired"
)

rolling:Reset(
    Constants.Phases.RESULT
)

assert(
    rolling:GetPhase()
    == Constants.Phases.RESULT,
    "Reset should change phase"
)

assert(
    rolling:GetElapsed() == 0,
    "Reset should clear elapsed time"
)

assert(
    rolling:GetDuration()
    == Constants.ResultTimerSeconds,
    "Result phase should use result timer"
)

assert(
    rolling:GetRemaining()
    == Constants.ResultTimerSeconds,
    "Reset result phase should have full duration"
)

assert(
    not rolling:IsExpired(),
    "Reset phase should not be expired"
)

rolling:Update(
    Constants.ResultTimerSeconds
)

assert(
    rolling:IsExpired(),
    "Result phase should expire at its duration"
)

local invalidPhaseSuccess = pcall(function()
    DistributionPhase.New(
        Constants.Phases.AWARD_PENDING
    )
end)

assert(
    not invalidPhaseSuccess,
    "Untimed phases should not be created as timed phases"
)

local nilPhaseSuccess = pcall(function()
    DistributionPhase.New(nil)
end)

assert(
    not nilPhaseSuccess,
    "Nil phase should be rejected"
)

local negativeUpdateSuccess = pcall(function()
    local phase =
        DistributionPhase.New(
            Constants.Phases.ROLLING
        )

    phase:Update(-1)
end)

assert(
    not negativeUpdateSuccess,
    "Negative elapsed time should be rejected"
)

local invalidElapsedSuccess = pcall(function()
    local phase =
        DistributionPhase.New(
            Constants.Phases.ROLLING
        )

    phase:Update("5")
end)

assert(
    not invalidElapsedSuccess,
    "Non-numeric elapsed time should be rejected"
)

local overDuration =
    DistributionPhase.New(
        Constants.Phases.ROLLING
    )

overDuration:Update(
    Constants.RollTimerSeconds + 10
)

assert(
    overDuration:GetElapsed()
    == Constants.RollTimerSeconds,
    "Elapsed time should be capped at duration"
)

assert(
    overDuration:GetRemaining() == 0,
    "Remaining time should not become negative"
)

assert(
    overDuration:IsAtDuration(),
    "Phase should report being at duration"
)

overDuration:Reset(
    Constants.Phases.ROLLING
)

assert(
    not overDuration:IsAtDuration(),
    "Reset phase should no longer be at duration"
)
