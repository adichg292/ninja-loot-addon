local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local Constants = addon.Loot.Distributions.Constants

local DistributionPhase = {}
DistributionPhase.__index = DistributionPhase

local function getDuration(phase)
    if phase == Constants.Phases.ROLLING then
        return Constants.RollTimerSeconds
    end

    if phase == Constants.Phases.RESULT then
        return Constants.ResultTimerSeconds
    end

    return 0
end

function DistributionPhase.New(phase)
    assert(
        phase ~= nil,
        "Phase is required"
    )

    assert(
        getDuration(phase) > 0,
        "Invalid timed phase"
    )

    return setmetatable({
        phase = phase,
        elapsed = 0,
        expired = false,
    }, DistributionPhase)
end

function DistributionPhase:GetPhase()
    return self.phase
end

function DistributionPhase:GetElapsed()
    return self.elapsed
end

function DistributionPhase:GetDuration()
    return getDuration(self.phase)
end

function DistributionPhase:GetRemaining()
    local remaining =
        self:GetDuration() - self.elapsed

    if remaining < 0 then
        return 0
    end

    return remaining
end

function DistributionPhase:IsExpired()
    return self.expired
end

function DistributionPhase:Update(elapsed)
    assert(
        elapsed ~= nil,
        "Elapsed time is required"
    )

    assert(
        type(elapsed) == "number",
        "Elapsed time must be a number"
    )

    assert(
        elapsed >= 0,
        "Elapsed time cannot be negative"
    )

    if self.expired then
        return self
    end

    self.elapsed =
        self.elapsed + elapsed

    if self.elapsed >= self:GetDuration() then
        self.elapsed = self:GetDuration()
        self.expired = true
    end

    return self
end

function DistributionPhase:Expire()
    self.elapsed = self:GetDuration()
    self.expired = true

    return self
end

function DistributionPhase:IsAtDuration()
    return self.elapsed >= self:GetDuration()
end

function DistributionPhase:Reset(phase)
    assert(
        phase ~= nil,
        "Phase is required"
    )

    assert(
        getDuration(phase) > 0,
        "Invalid timed phase"
    )

    self.phase = phase
    self.elapsed = 0
    self.expired = false

    return self
end

addon.Loot.Distributions.DistributionPhase =
    DistributionPhase
