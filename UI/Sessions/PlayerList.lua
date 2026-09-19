local addonName, addon = ...

addon.UI = addon.UI or {}
addon.UI.Sessions = addon.UI.Sessions or {}

local PlayerList = {}
PlayerList.__index = PlayerList

function PlayerList.New(parent)
    assert(
        parent ~= nil,
        "Player list parent is required"
    )

    local self =
        setmetatable({}, PlayerList)

    local title =
        parent:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontNormal"
        )

    title:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        10,
        -10
    )

    title:SetText("Players")

    local text =
        parent:CreateFontString(
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
        "No players."
    )

    self.title = title
    self.text = text

    return self
end

function PlayerList:Update(session)
    if session == nil then
        self.text:SetText(
            "No players."
        )

        return self
    end

    local players =
        session:GetPlayers():GetAll()

    if #players == 0 then
        self.text:SetText(
            "No players."
        )

        return self
    end

    local names = {}

    for _, player in ipairs(players) do
        table.insert(
            names,
            player:GetName()
        )
    end

    self.text:SetText(
        table.concat(
            names,
            "\n"
        )
    )

    return self
end

function PlayerList:GetText()
    return self.text:GetText()
end

addon.UI.Sessions.PlayerList =
    PlayerList