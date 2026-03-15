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
        Subtitle = "tests/LoaderStringDemo.lua",
        Icon = "🧪",
        Size = UDim2.new(0, 390, 0, 520),
    })

    if not Win then
        warn("[LoaderStringDemo] CreateWindow returned nil")
        return false
    end

    local Main = Win:AddTab("Smoke", "✅")
    Main:AddLabel({Text = "LoaderString demo window created"})
    Main:AddButton({
        Text = "Notify",
        Desc = "Verifies callback + notification path",
        Callback = function()
            NexusUI:Notify({
                Title = "Smoke Test",
                Desc = "Callback executed",
                Duration = 2,
                Icon = "✓",
            })
        end,
    })

    NexusUI:Notify({
        Title = "Loader Test Ready",
        Desc = "NexusUI loaded via game:HttpGet + loadstring",
        Duration = 3,
        Icon = "🚀",
    })

    return true
end

runDemo()
