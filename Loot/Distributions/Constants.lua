local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Distributions = addon.Loot.Distributions or {}

local Constants = {}

Constants.States = {
    PENDING = "PENDING",
    AWARDED = "AWARDED",
    CANCELLED = "CANCELLED",
}

Constants.Phases = {
    ROLLING = "ROLLING",
    AWARD_PENDING = "AWARD_PENDING",
    RESULT = "RESULT",
    FINAL = "FINAL",
}

Constants.Responses = {
    NEED = "NEED",
    PASS = "PASS",
}

Constants.ResultResponses = {
    ACKNOWLEDGE = "ACKNOWLEDGE",
    VOTE_RESTART = "VOTE_RESTART",
}

Constants.FinalDecisions = {
    ACCEPT = "ACCEPT",
    RESTART = "RESTART",
}

Constants.RollSources = {
    NINJALOOT = "NINJALOOT",
    CHAT = "CHAT",
}

Constants.AwardStates = {
    PENDING = "PENDING",
    SUCCESS = "SUCCESS",
    FAILED = "FAILED",
}

Constants.AwardMethods = {
    LOOT = "LOOT",
    TRADE = "TRADE",
}

Constants.RollTimerSeconds = 20
Constants.RollGraceSeconds = 1
Constants.ResultTimerSeconds = 10
Constants.RestartVoteThreshold = 4

addon.Loot.Distributions.Constants = Constants
