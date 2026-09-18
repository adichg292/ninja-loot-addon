local frames = {}
local eventFrames = {}

local function createFrameMethods(frame)
    function frame:SetSize(
        width,
        height
    )
        self.width = width
        self.height = height
    end

    function frame:GetWidth()
        return self.width
    end

    function frame:GetHeight()
        return self.height
    end

    function frame:SetWidth(
        width
    )
        self.width = width
    end

    function frame:SetHeight(
        height
    )
        self.height = height
    end

    function frame:SetPoint(
        point,
        relativeTo,
        relativePoint,
        offsetX,
        offsetY
    )
        self.point = point
        self.relativeTo = relativeTo
        self.relativePoint = relativePoint
        self.offsetX = offsetX
        self.offsetY = offsetY
    end

    function frame:GetPoint()
        return self.point
    end

    function frame:SetText(
        text
    )
        self.text = text
    end

    function frame:GetText()
        return self.text
    end

    function frame:Show()
        self.visible = true
    end

    function frame:Hide()
        self.visible = false
    end

    function frame:IsShown()
        return self.visible == true
    end

    function frame:SetScript(
        scriptType,
        handler
    )
        self.scripts[scriptType] = handler
    end

    function frame:GetScript(
        scriptType
    )
        return self.scripts[scriptType]
    end

    function frame:RegisterEvent(
        event
    )
        self.events[event] = true

        eventFrames[event] =
            eventFrames[event]
            or {}

        for _, registeredFrame in ipairs(
            eventFrames[event]
        ) do
            if registeredFrame == self then
                return
            end
        end

        table.insert(
            eventFrames[event],
            self
        )
    end

    function frame:UnregisterEvent(
        event
    )
        self.events[event] = nil

        if eventFrames[event] then
            for index, registeredFrame in ipairs(
                eventFrames[event]
            ) do
                if registeredFrame == self then
                    table.remove(
                        eventFrames[event],
                        index
                    )

                    break
                end
            end
        end
    end

    function frame:Click()
        local handler =
            self.scripts.OnClick

        if handler ~= nil then
            handler(self)
        end
    end

    function frame:SetParent(
        parent
    )
        self.parent = parent
    end

    function frame:GetParent()
        return self.parent
    end

    function frame:SetName(
        name
    )
        self.name = name
    end

    function frame:GetName()
        return self.name
    end

    function frame:Enable()
        self.enabled = true
    end

    function frame:Disable()
        self.enabled = false
    end

    function frame:IsEnabled()
        return self.enabled == true
    end

    function frame:SetEnabled(
        enabled
    )
        self.enabled = enabled == true
    end

    function frame:SetAlpha(
        alpha
    )
        self.alpha = alpha
    end

    function frame:GetAlpha()
        return self.alpha
    end

    function frame:SetFrameStrata(
        strata
    )
        self.frameStrata = strata
    end

    function frame:GetFrameStrata()
        return self.frameStrata
    end

    function frame:SetMovable(
        movable
    )
        self.movable = movable == true
    end

    function frame:IsMovable()
        return self.movable == true
    end

    function frame:StartMoving()
        self.moving = true
    end

    function frame:StopMovingOrSizing()
        self.moving = false
    end
end

function CreateFrame(
    frameType,
    name,
    parent
)
    local frame = {
        frameType = frameType,
        name = name,
        parent = parent,

        visible = false,

        width = 0,
        height = 0,

        point = nil,
        relativeTo = nil,
        relativePoint = nil,
        offsetX = 0,
        offsetY = 0,

        text = nil,

        enabled = true,
        alpha = 1,
        frameStrata = nil,
        movable = false,
        moving = false,

        events = {},
        scripts = {},
    }

    createFrameMethods(frame)

    if name ~= nil then
        frames[name] = frame
    end

    return frame
end

UIParent =
    CreateFrame(
        "Frame",
        "UIParent",
        nil
    )

_G.GetFrameByName = function(
    name
)
    return frames[name]
end

function RandomRoll(
    minimum,
    maximum
)
    assert(
        minimum == 1,
        "RandomRoll minimum must be 1"
    )

    assert(
        maximum == 100,
        "RandomRoll maximum must be 100"
    )

    _G.__lastRandomRoll = {
        minimum = minimum,
        maximum = maximum,
    }
end

_G.GetLastRandomRoll = function()
    return _G.__lastRandomRoll
end

_G.ClearLastRandomRoll = function()
    _G.__lastRandomRoll = nil
end

_G.TriggerEvent = function(
    event,
    ...
)
    local registeredFrames =
        eventFrames[event]

    if registeredFrames == nil then
        return
    end

    for _, frame in ipairs(
        registeredFrames
    ) do
        if frame.scripts
            and frame.scripts.OnEvent
        then
            frame.scripts.OnEvent(
                frame,
                event,
                ...
            )
        end
    end
end
