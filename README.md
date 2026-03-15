# NexusUI v2.6 (Roblox Luau UI Library)

NexusUI is a single-file Roblox UI library focused on fast setup, rich widgets, and resilient runtime behavior.

## What's included

- Window API with drag, pin/unpin, resize, and minimize
- Tabs + many built-in controls (toggle, slider, dropdown, multiselect, keybind, color picker, etc.)
- Notification system with animated entry/exit and queue cap
- Theme preset support (`Default`, `Ocean`, `Crimson`, `Forest`, `Midnight`)
- Config save/load helpers (when executor file APIs are available)

## Install

Copy `NexusUI.lua` into your project, or load it remotely.

## LoaderString demo

Use this pattern when your executor supports `loadstring` and `game:HttpGet`:

```lua
local Source = game:HttpGet("https://raw.githubusercontent.com/<your-user>/<your-repo>/<branch>/NexusUI.lua")
local NexusUI = loadstring(Source)()

local Win = NexusUI:CreateWindow({
    Title = "NexusUI Demo",
    Subtitle = "LoaderString",
    Icon = "N",
    Size = UDim2.new(0, 380, 0, 520)
})

local Main = Win:AddTab("Main", "✨")
Main:AddLabel({Text = "Loaded from remote source"})

NexusUI:Notify({
    Title = "NexusUI",
    Desc = "LoaderString demo started",
    Duration = 3,
    Icon = "✓"
})
```

> A complete runnable demo is included in `tests/LoaderStringDemo.lua`.

## Main script template

If you want a clean **main part** for your script, use this structure:

```lua
local Source = game:HttpGet("https://raw.githubusercontent.com/<your-user>/<your-repo>/<branch>/NexusUI.lua")
local NexusUI = loadstring(Source)()

local Win = NexusUI:CreateWindow({
    Title = "My Hub",
    Subtitle = "Main",
    Icon = "N"
})

local Main = Win:AddTab("Main", "🏠")
Main:AddLabel({Text = "Welcome"})
Main:AddToggle({Name = "Feature", Default = false, Callback = function(v)
    print("Feature:", v)
end})
Main:AddButton({Text = "Notify", Callback = function()
    NexusUI:Notify({Title = "Main", Desc = "Button clicked", Icon = "✓"})
end})
```

## Local file loader (alternative)

If your environment does not allow `HttpGet`, you can load from local text:

```lua
local NexusUI = loadstring(readfile("NexusUI.lua"))()
```

## Notes

- In restricted environments, `writefile`/`readfile` may be unavailable.
- If `CoreGui` parenting is blocked, NexusUI falls back to other GUI parenting strategies.
- Keep window titles unique if you rely on config IDs and registry-based save/load.
