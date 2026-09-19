local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Bosses = addon.UI.Bosses or {}

local BossPanel = {}
BossPanel.__index = BossPanel

function BossPanel.New(parent)
    assert(
        parent ~= nil,
        "Boss panel parent is required"
    )

    local self =
        setmetatable({}, BossPanel)

    local frame = CreateFrame(
        "Frame",
        nil,
        parent
    )

    frame:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        0,
        0
    )

    frame:SetWidth(760)
    frame:SetHeight(120)

    local title =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    title:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText("Boss")

    local text =
        frame:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlight"
        )

    text:SetPoint(
        "TOPLEFT",
        title,
        "BOTTOMLEFT",
        0,
        -8
    )

    text:SetJustifyH("LEFT")

    text:SetText(
        "No current boss."
    )

    self.frame = frame
    self.title = title
    self.text = text

    return self
end

function BossPanel:Update(session)
    if session == nil then
        self.text:SetText(
            "No current boss."
        )

        return self
    end

    local boss =
        session:GetCurrentBoss()

    if boss == nil then
        self.text:SetText(
            "No current boss."
        )

        return self
    end

    local status =
        boss:IsKilled()
            and "Defeated"
            or "Alive"

    local killedAt =
        boss:GetKilledAt()

    local killText =
        killedAt ~= nil
            and tostring(killedAt)
            or "Not killed"

    local lootCount =
        boss:GetItems():Count()

    self.text:SetText(
        "Name: "
            .. boss:GetName()
            .. "\nStatus: "
            .. status
            .. "\nKilled At: "
            .. killText
            .. "\nLoot Count: "
            .. tostring(lootCount)
    )

    return self
end

function BossPanel:GetText()
    return self.text:GetText()
end

function BossPanel:GetFrame()
    return self.frame
end

addon.UI.Bosses.BossPanel =
    BossPanel