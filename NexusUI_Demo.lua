local NexusUI = loadstring(game:HttpGet("YOUR_RAW_LINK"))()

local Win = NexusUI:CreateWindow({
    Title    = "Wonder Chase",
    Subtitle = "v3.0",
    Icon     = "⬡",
    Size     = UDim2.new(0, 360, 0, 500),
})

-- TABS
local Main    = Win:AddTab("Main",    "🏠")
local Settings = Win:AddTab("Settings","⚙")
local Credits  = Win:AddTab("Credits", "💎")

-- MAIN TAB
Main:AddSection("Automation")

Main:AddToggle({
    Name     = "Auto Play",
    Desc     = "Automatically play rounds",
    Default  = false,
    Callback = function(val)
        print("Auto Play:", val)
    end,
})

Main:AddSlider({
    Name     = "Item Value",
    Min      = 1, Max = 100, Default = 10,
    Suffix   = "",
    Callback = function(val)
        print("Item Value:", val)
    end,
})

Main:AddSlider({
    Name     = "Timer",
    Min      = 10, Max = 300, Default = 120,
    Suffix   = "s",
    Callback = function(val)
        print("Timer:", val)
    end,
})

Main:AddButton({
    Name     = "Check Leaderboard",
    Icon     = "🏆",
    Callback = function()
        Win:Notify({
            Title    = "Leaderboard",
            Desc     = "Opening leaderboard...",
            Duration = 3,
            Icon     = "🏆",
        })
    end,
})

-- SETTINGS TAB
Settings:AddSection("Interface")

Settings:AddDropdown({
    Name     = "Theme Color",
    Items    = {"Purple", "Blue", "Green", "Red", "Orange"},
    Default  = "Purple",
    Callback = function(val)
        print("Theme:", val)
    end,
})

Settings:AddTextBox({
    Name        = "Player Name",
    Placeholder = "Enter username...",
    Callback    = function(text)
        print("Name set to:", text)
    end,
})

Settings:AddKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightShift,
    Callback = function()
        print("Toggled UI!")
    end,
})

Settings:AddColorPicker({
    Name     = "Accent Color",
    Default  = Color3.fromRGB(138, 80, 255),
    Callback = function(col)
        print("Color:", col)
    end,
})

Settings:AddProgressBar({
    Name  = "XP Progress",
    Value = 65,
    Color = Color3.fromRGB(80, 220, 140),
})

-- NOTIFICATIONS
Win:Notify({
    Title    = "NexusUI Loaded",
    Desc     = "Welcome to Wonder Chase v3!",
    Duration = 5,
    Icon     = "✅",
    Color    = Color3.fromRGB(80, 220, 140),
})