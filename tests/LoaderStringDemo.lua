-- tests/LoaderStringDemo.lua
-- Demo / smoke script for loading NexusUI through LoaderString.
-- Intended to be executed in a Roblox executor environment.

local REPO_RAW_URL = "https://raw.githubusercontent.com/<your-user>/<your-repo>/<branch>/NexusUI.lua"

local function fetchSource(url)
    if type(game) ~= "userdata" and type(game) ~= "table" then
        return nil, "game is unavailable"
    end

    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(result) ~= "string" or result == "" then
        return nil, "failed to download source"
    end

    return result, nil
end

local function loadLibrary(src)
    local chunk, err = loadstring(src)
    if not chunk then
        return nil, "loadstring failed: " .. tostring(err)
    end

    local ok, lib = pcall(chunk)
    if not ok or type(lib) ~= "table" then
        return nil, "library bootstrap failed"
    end

    return lib, nil
end

local function buildMainTab(NexusUI, Win)
    local Main = Win:AddTab("Main", "🏠")

    Main:AddLabel({
        Text = "NexusUI loaded from LoaderString.",
        Desc = "This is the main demo section.",
        Icon = "✓",
    })

    Main:AddToggle({
        Name = "Enable Feature",
        Desc = "Basic toggle example",
        Default = false,
        Callback = function(v)
            NexusUI:Notify({
                Title = "Toggle",
                Desc = "Enable Feature = " .. tostring(v),
                Duration = 2,
                Icon = "⚙",
            })
        end,
    })

    Main:AddButton({
        Text = "Show Notification",
        Desc = "Verifies callback + notification path",
        Callback = function()
            NexusUI:Notify({
                Title = "Smoke Test",
                Desc = "Main tab callback executed",
                Duration = 2,
                Icon = "✓",
            })
        end,
    })

    return Main
end

local function buildConfigTab(Win)
    local Config = Win:AddTab("Config", "💾")

    Config:AddButton({
        Text = "Save Config",
        Desc = "Calls Win:SaveConfig('demo')",
        Callback = function()
            Win:SaveConfig("demo")
        end,
    })

    Config:AddButton({
        Text = "Load Config",
        Desc = "Calls Win:LoadConfig('demo')",
        Callback = function()
            Win:LoadConfig("demo")
        end,
    })

    return Config
end

local function runDemo()
    local src, fetchErr = fetchSource(REPO_RAW_URL)
    if not src then
        warn("[LoaderStringDemo] " .. tostring(fetchErr))
        return false
    end

    local NexusUI, loadErr = loadLibrary(src)
    if not NexusUI then
        warn("[LoaderStringDemo] " .. tostring(loadErr))
        return false
    end

    local Win = NexusUI:CreateWindow({
        Title = "NexusUI Loader Test",
        Subtitle = "Main + Config demo",
        Icon = "🧪",
        Size = UDim2.new(0, 390, 0, 520),
    })

    if not Win then
        warn("[LoaderStringDemo] CreateWindow returned nil")
        return false
    end

    buildMainTab(NexusUI, Win)
    buildConfigTab(Win)

    NexusUI:Notify({
        Title = "Loader Test Ready",
        Desc = "NexusUI loaded via game:HttpGet + loadstring",
        Duration = 3,
        Icon = "🚀",
    })

    return true
end

runDemo()
