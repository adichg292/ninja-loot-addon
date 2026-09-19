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
    frame:SetHeight(180)

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

    return self
end

function LootList:Update(lootManager)
    if lootManager == nil then
        self.text:SetText(
            "Loot manager is not available."
        )

        return self
    end

    local items =
        lootManager:GetLootItems()

    if items == nil
        or #items == 0
    then
        self.text:SetText(
            "No loot."
        )

        return self
    end

    local lines = {}

    for _, item in ipairs(items) do
        local state = "UNKNOWN"

        if item.GetState ~= nil then
            state =
                item:GetState()
        end

        table.insert(
            lines,
            item:GetName()
                .. " ["
                .. tostring(state)
                .. "]"
        )
    end

    self.text:SetText(
        table.concat(
            lines,
            "\n"
        )
    )

    return self
end

function LootList:GetText()
    return self.text:GetText()
end

function LootList:GetFrame()
    return self.frame
end

addon.UI.Loot.LootList =
    LootList