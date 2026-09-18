local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Lifecycles = addon.Loot.Lifecycles or {}

local Lifecycle = {}
Lifecycle.__index = Lifecycle

Lifecycle.States = {
    NOT_INITIALIZED = "NOT_INITIALIZED",
    SETUP = "SETUP",
    ACTIVE = "ACTIVE",
    ENDED = "ENDED",
}

function Lifecycle.New()
    return setmetatable({
        state = Lifecycle.States.NOT_INITIALIZED,
        startedAt = nil,
        endedAt = nil,
    }, Lifecycle)
end

function Lifecycle:Setup()
    assert(
        self.state == Lifecycle.States.NOT_INITIALIZED,
        "Only an uninitialized lifecycle can be set up"
    )

    self.state = Lifecycle.States.SETUP
end

function Lifecycle:Start(startedAt)
    assert(
        self.state == Lifecycle.States.SETUP,
        "Only a lifecycle in SETUP state can be started"
    )

    assert(
        startedAt ~= nil,
        "Start time is required"
    )

    self.state = Lifecycle.States.ACTIVE
    self.startedAt = startedAt
end

function Lifecycle:End(endedAt)
    assert(
        self.state == Lifecycle.States.ACTIVE,
        "Only an active lifecycle can be ended"
    )

    assert(
        endedAt ~= nil,
        "End time is required"
    )

    self.state = Lifecycle.States.ENDED
    self.endedAt = endedAt
end

function Lifecycle:IsSetup()
    return self.state == Lifecycle.States.SETUP
end

function Lifecycle:IsActive()
    return self.state == Lifecycle.States.ACTIVE
end

function Lifecycle:IsEnded()
    return self.state == Lifecycle.States.ENDED
end

function Lifecycle:GetState()
    return self.state
end

addon.Loot.Lifecycles.Lifecycle = Lifecycle
