assert(loadfile("tests/wow_mock.lua"))()

local tests = {
    "tests/unit/session_test.lua",
    "tests/unit/session_manager_test.lua",

    "tests/ui/button_test.lua",
    "tests/ui/close_button_test.lua",
    "tests/ui/main_window_test.lua",
}

print("")

for _, testFile in ipairs(tests) do
    print("Running:", testFile)

    local test = assert(loadfile(testFile))
    test()

    print("Passed:", testFile, "\n")
end

print("All NinjaLoot tests passed!")
