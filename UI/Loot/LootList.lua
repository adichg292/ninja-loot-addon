local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Loot = addon.UI.Loot or {}

local LootList = {}
LootList.__index = LootList

function LootList.New(parent)
    assert(
        parent ~= nil,
        "Loot list parent is required"
    )

    local self =
        setmetatable({}, LootList)

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
    frame:SetHeight(400)

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

    title:SetText("Loot")

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
        "No loot."
    )

    self.frame = frame
    self.title = title
    self.text = text
    self.rows = {}
    self.displayText = "No loot."

    return self
end

function LootList:Update(lootManager)
    local function showMessage(message)
        for _, row in ipairs(self.rows) do
            row.label:Hide()
            row.button:Hide()
        end

        self.displayText = message
        self.text:SetText(message)
        self.text:Show()
    end

    if lootManager == nil then
        showMessage("Loot manager is not available.")

        return self
    end

    local items =
        lootManager:GetLootItems()

    if items == nil
        or #items == 0
    then
        showMessage("No loot.")

        return self
    end

    local lines = {}

    self.text:Hide()

    for index, item in ipairs(items) do
        local state = "UNKNOWN"

        if item.GetState ~= nil then
            state =
                item:GetState()
        end

        local row = self.rows[index]

        if row == nil then
            local label = self.frame:CreateFontString(
                nil,
                "OVERLAY",
                "GameFontHighlight"
            )
            label:SetJustifyH("LEFT")

            local button = addon.UI.Components.CreateButton(
                self.frame,
                nil,
                130,
                26
            )

            row = {
                label = label,
                button = button,
            }
            self.rows[index] = row
        end

        row.label:ClearAllPoints()
        row.label:SetPoint(
            "TOPLEFT",
            self.frame,
            "TOPLEFT",
            10,
            -42 - ((index - 1) * 34)
        )
        row.label:SetText(
            item:GetName()
                .. " ["
                .. tostring(state)
                .. "]"
        )
        row.label:Show()

        table.insert(lines, item:GetName() .. " [" .. tostring(state) .. "]")

        row.button:ClearAllPoints()
        row.button:SetPoint(
            "TOPRIGHT",
            self.frame,
            "TOPRIGHT",
            -10,
            -36 - ((index - 1) * 34)
        )

        local isDistributable = state == "AVAILABLE"
            or state == "SELECTED"

        if isDistributable
            and lootManager.StartDistribution ~= nil
        then
            row.button:SetText("Distribute")
            row.button:SetScript("OnClick", function()
                local distribution = lootManager:StartDistribution(item)
                self:Update(lootManager)
                return distribution
            end)
            row.button:Show()
        else
            row.button:Hide()
        end
    end

    for index = #items + 1, #self.rows do
        self.rows[index].label:Hide()
        self.rows[index].button:Hide()
    end

    self.displayText = table.concat(lines, "\n")

    return self
end

function LootList:GetText()
    return self.displayText
end

function LootList:GetFrame()
    return self.frame
end

addon.UI.Loot.LootList =
    LootList
