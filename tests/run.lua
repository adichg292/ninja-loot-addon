assert(
    loadfile("tests/wow_mock.lua")
)()

local nativeLoadfile = loadfile

local function createTestEnvironment()
    local addon = {}

    _G.NinjaLoot = addon
    _G.NinjaLootAddon = addon

    local originalLoadfile = loadfile

    _G.loadfile = function(path)
        local chunk, loadError =
            nativeLoadfile(path)

        if chunk == nil then
            return nil, loadError
        end

        return function(...)
            local args = {
                ...
            }

            if #args > 0 then
                return chunk(...)
            end

            return chunk(
                "NinjaLoot",
                addon
            )
        end
    end

    return addon, originalLoadfile
end

local function destroyTestEnvironment(
    originalLoadfile
)
    loadfile = originalLoadfile

    _G.NinjaLoot = nil
    _G.NinjaLootAddon = nil
    _G.NinjaLootDatabase = nil

    if ClearLastRandomRoll then
        ClearLastRandomRoll()
    end
end

local function loadTestFile(path)
    local testChunk, loadError =
        nativeLoadfile(path)

    if testChunk == nil then
        return nil, loadError
    end

    local addon, originalLoadfile =
        createTestEnvironment()

    local success, runtimeError =
        pcall(function()
            testChunk(
                "NinjaLoot",
                addon
            )
        end)

    destroyTestEnvironment(
        originalLoadfile
    )

    if not success then
        return nil, runtimeError
    end

    return true
end

local tests = {
    "tests/unit/loot/config/config_manager_test.lua",
    "tests/unit/loot/config/config_test.lua",

    "tests/unit/loot/history/history_manager_test.lua",

    "tests/unit/loot/sessions/session_test.lua",
    "tests/unit/loot/sessions/session_manager_test.lua",
    "tests/unit/loot/sessions/session_persistence_test.lua",

    "tests/unit/loot/players/player_test.lua",
    "tests/unit/loot/players/player_manager_test.lua",

    "tests/unit/loot/items/item_test.lua",
    "tests/unit/loot/items/item_manager_test.lua",

    "tests/unit/loot/bosses/boss_test.lua",
    "tests/unit/loot/bosses/boss_manager_test.lua",

    "tests/unit/loot/lifecycles/lifecycle_test.lua",

    "tests/unit/loot/distributions/distribution_test.lua",
    "tests/unit/loot/distributions/distribution_manager_test.lua",
    "tests/unit/loot/distributions/distribution_response_test.lua",
    "tests/unit/loot/distributions/distribution_phase_test.lua",
    "tests/unit/loot/distributions/award_service_test.lua",
    "tests/unit/loot/distributions/wow_award_handler_test.lua",

    "tests/unit/loot/loot_manager_test.lua",

    "tests/integration/addon_init_test.lua",
    "tests/integration/roll_event_test.lua",

    "tests/ui/button_test.lua",
    "tests/ui/close_button_test.lua",
    "tests/ui/main_window_test.lua",
    "tests/ui/confirm_dialog_test.lua",
}

local failures = {}
local passed = 0

for _, testPath in ipairs(tests) do
    local success, errorMessage =
        loadTestFile(testPath)

    if success then
        passed = passed + 1
    else
        table.insert(
            failures,
            {
                path = testPath,
                error = errorMessage,
            }
        )
    end
end

print("==============================================================")
print("                       TEST SUMMARY")
print("==============================================================")

if #failures > 0 then
    for _, failure in ipairs(failures) do
        print("")
        print(failure.path)
        print(failure.error)
    end
end

print("")
print(
    passed
    .. " / "
    .. #tests
    .. " suites passed"
)

if #failures == 0 then
    print("ALL TESTS PASSED")
else
    print(
        #failures
        .. " TEST SUITE(S) FAILED"
    )
end

print("==============================================================")

if #failures > 0 then
    os.exit(1)
end
