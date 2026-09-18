local addon = {}

assert(
    loadfile("Loot/Lifecycles/Lifecycle.lua")
)("NinjaLoot", addon)

assert(
    addon.Loot ~= nil,
    "Loot namespace was not created"
)

assert(
    addon.Loot.Lifecycles ~= nil,
    "Lifecycles namespace was not created"
)

assert(
    addon.Loot.Lifecycles.Lifecycle ~= nil,
    "Lifecycle was not created"
)

local Lifecycle = addon.Loot.Lifecycles.Lifecycle

assert(
    Lifecycle.States ~= nil,
    "Lifecycle states were not created"
)

assert(
    Lifecycle.States.NOT_INITIALIZED == "NOT_INITIALIZED",
    "NOT_INITIALIZED state is incorrect"
)

assert(
    Lifecycle.States.SETUP == "SETUP",
    "SETUP state is incorrect"
)

assert(
    Lifecycle.States.ACTIVE == "ACTIVE",
    "ACTIVE state is incorrect"
)

assert(
    Lifecycle.States.ENDED == "ENDED",
    "ENDED state is incorrect"
)

local lifecycle = Lifecycle.New()

assert(
    lifecycle ~= nil,
    "Lifecycle was not created"
)

assert(
    lifecycle:GetState() == Lifecycle.States.NOT_INITIALIZED,
    "New lifecycle should be NOT_INITIALIZED"
)

assert(
    lifecycle:IsSetup() == false,
    "New lifecycle should not be setup"
)

assert(
    lifecycle:IsActive() == false,
    "New lifecycle should not be active"
)

assert(
    lifecycle:IsEnded() == false,
    "New lifecycle should not be ended"
)

assert(
    lifecycle.startedAt == nil,
    "New lifecycle should not have a start time"
)

assert(
    lifecycle.endedAt == nil,
    "New lifecycle should not have an end time"
)

lifecycle:Setup()

assert(
    lifecycle:GetState() == Lifecycle.States.SETUP,
    "Lifecycle should be SETUP after Setup()"
)

assert(
    lifecycle:IsSetup() == true,
    "Lifecycle should report setup state"
)

local secondSetupSuccess = pcall(function()
    lifecycle:Setup()
end)

assert(
    secondSetupSuccess == false,
    "Lifecycle should not be set up twice"
)

local nilStartSuccess = pcall(function()
    lifecycle:Start(nil)
end)

assert(
    nilStartSuccess == false,
    "Lifecycle should reject a nil start time"
)

assert(
    lifecycle:GetState() == Lifecycle.States.SETUP,
    "Invalid Start() should not change lifecycle state"
)

assert(
    lifecycle.startedAt == nil,
    "Invalid Start() should not set a start time"
)

lifecycle:Start(100)

assert(
    lifecycle:GetState() == Lifecycle.States.ACTIVE,
    "Lifecycle should be ACTIVE after Start()"
)

assert(
    lifecycle:IsSetup() == false,
    "Active lifecycle should not report setup state"
)

assert(
    lifecycle:IsActive() == true,
    "Active lifecycle should report active state"
)

assert(
    lifecycle:IsEnded() == false,
    "Active lifecycle should not report ended state"
)

assert(
    lifecycle.startedAt == 100,
    "Lifecycle start time is incorrect"
)

local secondStartSuccess = pcall(function()
    lifecycle:Start(150)
end)

assert(
    secondStartSuccess == false,
    "Lifecycle should not be started twice"
)

assert(
    lifecycle.startedAt == 100,
    "Invalid second Start() should not change the start time"
)

local nilEndSuccess = pcall(function()
    lifecycle:End(nil)
end)

assert(
    nilEndSuccess == false,
    "Lifecycle should reject a nil end time"
)

assert(
    lifecycle:GetState() == Lifecycle.States.ACTIVE,
    "Invalid End() should not change lifecycle state"
)

assert(
    lifecycle.endedAt == nil,
    "Invalid End() should not set an end time"
)

lifecycle:End(200)

assert(
    lifecycle:GetState() == Lifecycle.States.ENDED,
    "Lifecycle should be ENDED after End()"
)

assert(
    lifecycle:IsSetup() == false,
    "Ended lifecycle should not report setup state"
)

assert(
    lifecycle:IsActive() == false,
    "Ended lifecycle should not report active state"
)

assert(
    lifecycle:IsEnded() == true,
    "Ended lifecycle should report ended state"
)

assert(
    lifecycle.startedAt == 100,
    "Lifecycle start time should remain unchanged after ending"
)

assert(
    lifecycle.endedAt == 200,
    "Lifecycle end time is incorrect"
)

local secondEndSuccess = pcall(function()
    lifecycle:End(300)
end)

assert(
    secondEndSuccess == false,
    "Lifecycle should not be ended twice"
)

assert(
    lifecycle.endedAt == 200,
    "Invalid second End() should not change the end time"
)
