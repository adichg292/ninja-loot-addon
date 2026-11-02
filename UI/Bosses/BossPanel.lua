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
    frame:SetHeight(140)

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
        -6
    )

    text:SetJustifyH("LEFT")

    text:SetText(
        "No current boss."
    )

    self.frame = frame
    self.title = title
    self.text = text
    self.session = nil
    self.addBossHandler = nil
    self.bossKilledHandler = nil

    local bossNameLabel = frame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontHighlight"
    )
    bossNameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -86)
    bossNameLabel:SetText("New Boss:")

    local bossNameInput = CreateFrame(
        "EditBox",
        nil,
        frame,
        "InputBoxTemplate"
    )
    bossNameInput:SetSize(180, 26)
    bossNameInput:SetPoint("TOPLEFT", frame, "TOPLEFT", 75, -86)
    bossNameInput:SetAutoFocus(false)
    bossNameInput:SetTextInsets(6, 6, 0, 0)
    bossNameInput:SetScript("OnEnterPressed", function(input)
        input:ClearFocus()
        self:AddBoss()
    end)

    local addBossButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        100,
        26
    )
    addBossButton:SetPoint("LEFT", bossNameInput, "RIGHT", 8, 0)
    addBossButton:SetText("Add Boss")
    addBossButton:SetScript("OnClick", function()
        self:AddBoss()
    end)

    local bossKilledButton = addon.UI.Components.CreateButton(
        frame,
        nil,
        140,
        26
    )
    bossKilledButton:SetPoint("LEFT", addBossButton, "RIGHT", 8, 0)
    bossKilledButton:SetText("Mark Defeated")
    bossKilledButton:SetScript("OnClick", function()
        self:MarkBossKilled()
    end)

    self.bossNameInput = bossNameInput
    self.bossNameLabel = bossNameLabel
    self.addBossButton = addBossButton
    self.bossKilledButton = bossKilledButton

    return self
end

function BossPanel:SetAddBossHandler(handler)
    assert(
        handler == nil or type(handler) == "function",
        "Add boss handler must be a function"
    )

    self.addBossHandler = handler
    return self
end

function BossPanel:SetBossKilledHandler(handler)
    assert(
        handler == nil or type(handler) == "function",
        "Boss killed handler must be a function"
    )

    self.bossKilledHandler = handler
    return self
end

function BossPanel:AddBoss()
    local name = self.bossNameInput:GetText()
    name = type(name) == "string" and name:match("^%s*(.-)%s*$") or ""

    if name == "" then
        self.text:SetText("Enter a boss name before adding it.")
        return false
    end

    if self.addBossHandler == nil then
        self.text:SetText("Boss management is not available.")
        return false
    end

    local success, result = self.addBossHandler(name)
    if not success then
        self.text:SetText(result or "Could not add boss.")
        return false
    end

    self.bossNameInput:SetText("")
    self:Update(self.session)
    return result or true
end

function BossPanel:MarkBossKilled()
    if self.bossKilledHandler == nil then
        self.text:SetText("Boss management is not available.")
        return false
    end

    local success, result = self.bossKilledHandler()
    if not success then
        self.text:SetText(result or "Could not mark boss defeated.")
        return false
    end

    self:Update(self.session)
    return result or true
end

function BossPanel:Update(session)
    self.session = session

    if session == nil then
        self.text:SetText(
            "No current boss."
        )
        self.bossNameLabel:Hide()
        self.bossNameInput:Hide()
        self.addBossButton:Hide()
        self.bossKilledButton:Hide()

        return self
    end

    self.bossNameInput:Show()
    self.bossNameLabel:Show()
    self.addBossButton:Show()

    local boss =
        session:GetCurrentBoss()

    if boss == nil then
        self.text:SetText(
            "No current boss."
        )
        self.bossKilledButton:Hide()

        return self
    end

    local status =
        boss:IsKilled()
            and "Defeated"
            or "Alive"

    local lootCount =
        boss:GetItems():Count()

    self.text:SetText(
        "Name: "
            .. boss:GetName()
            .. "\nStatus: "
            .. status
            .. "\nLoot Count: "
            .. tostring(lootCount)
    )

    if boss:IsKilled() then
        self.bossKilledButton:Hide()
    else
        self.bossKilledButton:Show()
    end

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
