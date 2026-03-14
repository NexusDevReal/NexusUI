local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusDevReal/NexusUI/refs/heads/main/NexusUI.lua"))()

local Win = NexusUI:CreateWindow({
    Title    = "Wonder Chase",
    Subtitle = "v3.0",
    Icon     = "W",
    Size     = UDim2.new(0, 370, 0, 490),
})

local Main     = Win:AddTab("Main")
local Settings = Win:AddTab("Settings")
local Credits  = Win:AddTab("Credits")

-- MAIN TAB --
Main:AddSection("Automation")
Main:AddToggle({
    Name = "Auto Play", Desc = "Automatically play rounds",
    Default = false, Callback = function(v) print("Auto Play:", v) end,
})
Main:AddSlider({
    Name = "Item Value", Min = 1, Max = 100, Default = 10,
    Callback = function(v) print("Item Value:", v) end,
})
Main:AddSlider({
    Name = "Timer", Min = 10, Max = 300, Default = 120, Suffix = "s",
    Callback = function(v) print("Timer:", v) end,
})
Main:AddButton({
    Name = "Check Leaderboard", Icon = "L",
    Callback = function()
        Win:Notify({
            Title = "Leaderboard", Desc = "Fetching scores...",
            Duration = 3, Icon = "L",
            Color = Color3.fromRGB(250,184,50),
        })
    end,
})

-- SETTINGS TAB --
Settings:AddSection("Interface")
Settings:AddDropdown({
    Name = "Theme Color",
    Items = {"Purple","Blue","Green","Red","Orange"},
    Default = "Purple",
    Callback = function(v) print("Theme:", v) end,
})
Settings:AddTextBox({
    Name = "Player Name", Placeholder = "Enter username...",
    Callback = function(t) print("Name:", t) end,
})
Settings:AddKeybind({
    Name = "Toggle UI", Default = Enum.KeyCode.RightShift,
    Callback = function() print("Toggled!") end,
})
Settings:AddColorPicker({
    Name = "Accent", Default = Color3.fromRGB(130,72,245),
    Callback = function(c) print("Color:", c) end,
})
Settings:AddProgressBar({
    Name = "XP Progress", Value = 65,
    Color = Color3.fromRGB(70,210,128),
})

-- CREDITS TAB --
Credits:AddCredit("Credit By NexusDev")
Credits:AddCredit("Wonder Chase UI", "Version 3.0  |  2026")
Credits:AddCredit("Special Thanks", "The Community")

-- STARTUP NOTIFY --
Win:Notify({
    Title = "NexusUI Loaded", Desc = "Wonder Chase ready!",
    Duration = 5, Icon = "OK",
    Color = Color3.fromRGB(70,210,128),
})

