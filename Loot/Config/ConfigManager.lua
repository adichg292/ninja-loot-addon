local addonName, addon = ...

addon.Loot = addon.Loot or {}
addon.Loot.Config = addon.Loot.Config or {}

local Config = addon.Loot.Config.Config

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local function copyTable(source)
    local copy = {}

    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = copyTable(value)
        else
            copy[key] = value
        end
    end

    return copy
end

local function assertPath(path)
    assert(
        type(path) == "string",
        "Config path must be a string"
    )

    assert(
        path ~= "",
        "Config path cannot be empty"
    )
end

local function splitPath(path)
    local parts = {}

    for part in string.gmatch(
        path,
        "[^%.]+"
    ) do
        table.insert(
            parts,
            part
        )
    end

    return parts
end

local function getNested(root, path)
    local current = root

    for _, part in ipairs(
        splitPath(path)
    ) do
        if type(current) ~= "table" then
            return nil
        end

        current = current[part]
    end

    return current
end

local function setNested(root, path, value)
    local parts = splitPath(path)

    local current = root

    for index = 1, #parts - 1 do
        local part = parts[index]

        if type(current[part]) ~= "table" then
            current[part] = {}
        end

        current = current[part]
    end

    current[parts[#parts]] = value
end

local function valuesMatchType(
    expected,
    actual
)
    if type(expected) ~= type(actual) then
        return false
    end

    return true
end

local function validateValue(
    path,
    value,
    defaults
)
    local defaultValue =
        getNested(
            defaults,
            path
        )

    assert(
        defaultValue ~= nil,
        "Unknown config path: " .. path
    )

    assert(
        valuesMatchType(
            defaultValue,
            value
        ),
        "Invalid value type for config path: "
        .. path
    )

    if path == "General.UIScale" then
        assert(
            value >= 0.5
            and value <= 2.0,
            "UI scale must be between 0.5 and 2.0"
        )
    end

    if path == "General.KeepSessionHistoryDays" then
        assert(
            value >= 1
            and value <= 3650
            and value % 1 == 0,
            "Session history days must be a positive integer"
        )
    end

    if path == "General.NotificationVerbosity" then
        assert(
            value
            == Config.NotificationVerbosity.NORMAL
            or value
            == Config.NotificationVerbosity.DETAILED,
            "Invalid notification verbosity"
        )
    end

    if path == "Loot.RoundRobin.RollPeriodSeconds"
        or path == "Loot.RoundRobin.RollGracePeriodSeconds"
        or path == "Loot.RoundRobin.ResultPeriodSeconds"
    then
        assert(
            value > 0
            and value % 1 == 0,
            "Round Robin timer must be a positive integer"
        )
    end
end

function ConfigManager.New(
    persistence
)
    return setmetatable({
        persistence = persistence,
        config = nil,
    }, ConfigManager)
end

function ConfigManager:Initialize()
    assert(
        self.persistence ~= nil,
        "Persistence is required"
    )

    local database =
        self.persistence:GetDatabase()

    if database.config == nil then
        database.config =
            Config.GetDefaults()
    end

    local defaults =
        Config.GetDefaults()

    if database.config.General == nil then
        database.config.General =
            copyTable(
                defaults.General
            )
    end

    if database.config.Loot == nil then
        database.config.Loot =
            copyTable(
                defaults.Loot
            )
    end

    for key, value in pairs(
        defaults.General
    ) do
        if database.config.General[key] == nil then
            database.config.General[key] = value
        end
    end

    for systemName, systemDefaults in pairs(
        defaults.Loot
    ) do
        if database.config.Loot[systemName] == nil then
            database.config.Loot[systemName] =
                copyTable(systemDefaults)
        elseif type(systemDefaults) == "table" then
            for key, value in pairs(systemDefaults) do
                if database.config.Loot[systemName][key] == nil then
                    database.config.Loot[systemName][key] = value
                end
            end
        end
    end

    self.config =
        database.config

    self:ApplyRuntimeSettings()

    return self
end

function ConfigManager:Get(path)
    assertPath(path)

    assert(
        self.config ~= nil,
        "Config has not been initialized"
    )

    return getNested(
        self.config,
        path
    )
end

function ConfigManager:Set(
    path,
    value
)
    assertPath(path)

    assert(
        self.config ~= nil,
        "Config has not been initialized"
    )

    local defaults =
        Config.GetDefaults()

    validateValue(
        path,
        value,
        defaults
    )

    setNested(
        self.config,
        path,
        value
    )

    self:ApplyRuntimeSettings()

    if self.persistence ~= nil then
        self.persistence:SaveConfig(
            self.config
        )
    end

    return self
end

function ConfigManager:GetAll()
    assert(
        self.config ~= nil,
        "Config has not been initialized"
    )

    return self.config
end

function ConfigManager:Reset(
    path
)
    assertPath(path)

    assert(
        self.config ~= nil,
        "Config has not been initialized"
    )

    local defaults =
        Config.GetDefaults()

    local defaultValue =
        getNested(
            defaults,
            path
        )

    assert(
        defaultValue ~= nil,
        "Unknown config path: " .. path
    )

    if type(defaultValue) == "table" then
        defaultValue =
            copyTable(
                defaultValue
            )
    end

    setNested(
        self.config,
        path,
        defaultValue
    )

    self:ApplyRuntimeSettings()

    if self.persistence ~= nil then
        self.persistence:SaveConfig(
            self.config
        )
    end

    return self
end

function ConfigManager:ResetAll()
    self.config =
        Config.GetDefaults()

    local database =
        self.persistence:GetDatabase()

    database.config =
        self.config

    self:ApplyRuntimeSettings()

    if self.persistence ~= nil then
        self.persistence:SaveConfig(
            self.config
        )
    end

    return self
end

function ConfigManager:ApplyRuntimeSettings()
    if addon.Loot.Distributions == nil then
        return self
    end

    local Constants =
        addon.Loot.Distributions.Constants

    if Constants == nil
        or self.config == nil
    then
        return self
    end

    local roundRobin =
        self.config.Loot.RoundRobin

    Constants.RollTimerSeconds =
        roundRobin.RollPeriodSeconds

    Constants.RollGraceSeconds =
        roundRobin.RollGracePeriodSeconds

    Constants.ResultTimerSeconds =
        roundRobin.ResultPeriodSeconds

    return self
end

addon.Loot.Config.ConfigManager =
    ConfigManager
