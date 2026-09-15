-- Minimal fake WoW environment for local testing

UIParent = {}

function CreateFrame(frameType, name, parent)
    local frame = {
        frameType = frameType,
        name = name,
        parent = parent,
        visible = false,
        width = nil,
        height = nil,
        point = nil,
    }

    function frame:SetSize(width, height)
        self.width = width
        self.height = height
    end

    function frame:SetPoint(point)
        self.point = point
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

    function frame:SetScript(scriptType, handler)
        self.scripts = self.scripts or {}
        self.scripts[scriptType] = handler
    end

    function frame:Click()
        if self.scripts and self.scripts.OnClick then
            self.scripts.OnClick(self)
        end
    end

    return frame
end
