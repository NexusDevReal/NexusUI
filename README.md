# NexusUI — Roblox Luau UI Library

> A polished, animated, feature-rich UI framework for Roblox.  
> Drop-in, zero-dependency, supports **PC, Mobile and Tablet**.

---

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.1** | Mobile drag rewrite, brighter UIStrokes, UICorner on content pane, image fix, "x" close button |
| **v2.0** | Button spam fix, drag connection leak fix, Toggle/Dropdown visibility fix, `✓` checkmarks, `▾` chevrons, Slider Step, SetTheme, MultiDropdown search, Escape closes dropdowns, WinAPI helpers |
| **v1.0** | Initial release — Window, Tabs, Toggle, Slider, Dropdown, MultiDropdown, TextBox, Keybind, ColorPicker, ProgressBar, Notifications, Config save/load |

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v2.1",
    Icon     = "rbxassetid://YOUR_ICON_ID",   -- or plain text like "N"
    Size     = UDim2.new(0, 370, 0, 500),
})

local Tab = Win:AddTab("Main")

Tab:AddToggle({
    Name     = "God Mode",
    Default  = false,
    Callback = function(state)
        print("God Mode:", state)
    end,
})
```

---

## Creating a Window

```lua
NexusUI:CreateWindow({
    Title    = "Window Title",   -- also used as the registry key
    Subtitle = "v2.1",           -- shown in the version chip
    Icon     = "N",              -- text OR rbxassetid://... (see Icons)
    Size     = UDim2.new(0, 370, 0, 500),
    Position = UDim2.new(0.5, -185, 0.5, -250),
})
```

### Window Methods

| Method | Description |
|--------|-------------|
| `Win:AddTab(name)` | Creates and returns a Tab API |
| `Win:Toggle()` | Show / hide the window |
| `Win:IsVisible()` | Returns `true` if visible |
| `Win:Destroy()` | Animate-close and destroy |
| `Win:SetTitle(t)` | Change the title text |
| `Win:SetSubtitle(s)` | Change the subtitle chip text |
| `Win:Notify({...})` | Send a notification (see Notifications) |
| `Win:SaveConfig(name)` | Save all registered IDs to JSON |
| `Win:LoadConfig(name)` | Load and apply a saved config |
| `Win:GetValue(id)` | Get current value of element by ID |
| `Win:SetValue(id, val)` | Set value of element by ID |
| `Win:GetElement(id)` | Get the full API object by ID |
| `Win:ListIds()` | Returns `{ [id] = type }` table |

---

## Tabs

```lua
local Tab = Win:AddTab("Combat")
Tab:Select()         -- activate this tab programmatically
Tab:SetVisible(false) -- hide the tab button
```

---

## Elements

### Section Header
```lua
Tab:AddSection("Aimbot Settings")
```

### Separator
```lua
Tab:AddSeparator()
```

### Label
```lua
local L = Tab:AddLabel("Hello World")
-- or with options:
local L = Tab:AddLabel({ Text="Info", Color=Color3.fromRGB(200,200,255), Align="Center", TextSize=14, Bold=true })
L:SetText("Updated!"); L:SetColor(Color3.new(1,1,1)); L:SetSize(16)
```

### Paragraph
```lua
local P = Tab:AddParagraph({ Title="About", Content="Long text here..." })
P:SetTitle("New Title"); P:SetContent("New body"); P:SetColor(Color3.new(1,1,1))
```

### Button
```lua
local B = Tab:AddButton({
    Name     = "Teleport",
    Desc     = "Teleports to spawn",   -- optional subtitle
    Icon     = "rbxassetid://12345",   -- optional icon
    Color    = Color3.fromRGB(135,74,252),
    Callback = function() print("clicked") end,
})
B:SetName("New Name"); B:SetDesc("New desc"); B:SetEnabled(false)
```

### Toggle
```lua
local T = Tab:AddToggle({
    Name     = "Speed Hack",
    Desc     = "Enables extra speed",
    Default  = false,
    Color    = Color3.fromRGB(66,212,130),
    Id       = "speedHack",             -- optional, enables SaveConfig
    Callback = function(state) end,
})
T:Get(); T:Set(true); T:Fire(); T:SetEnabled(false)
```

### Slider
```lua
local S = Tab:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 200,
    Default  = 16,
    Step     = 1,     -- decimal steps e.g. 0.1 for 0–1 range
    Suffix   = " WS",
    Color    = Color3.fromRGB(50,170,252),
    Id       = "walkSpeed",
    Callback = function(val) end,
})
S:Get(); S:Set(50); S:SetMin(0); S:SetMax(500); S:SetStep(5); S:SetSuffix(" ms")
```

### Dropdown
```lua
local D = Tab:AddDropdown({
    Name        = "Game Mode",
    Items       = {"Normal", "Ranked", "Custom"},
    Default     = nil,          -- nil / false / "" = no pre-selection
    Placeholder = "Select...",
    Color       = Color3.fromRGB(135,74,252),
    Id          = "gameMode",
    Callback    = function(val) end,
})
D:Get(); D:Set("Ranked"); D:Clear(); D:IsEmpty(); D:IsSelected("Ranked")
D:AddItem("Turbo"); D:RemoveItem("Custom"); D:Refresh(newItemsTable)
D:SetPlaceholder("Pick one...")
```

### Multi Dropdown
```lua
local MD = Tab:AddMultiDropdown({
    Name        = "Effects",
    Items       = {"Blur", "Bloom", "Depth"},
    Default     = {"Blur"},
    Placeholder = "None selected",
    Id          = "effects",
    Callback    = function(selection) end,  -- selection is a table
})
MD:Get(); MD:Set({"Blur","Bloom"}); MD:Clear(); MD:SelectAll()
MD:IsEmpty(); MD:IsSelected("Blur"); MD:AddItem("Vignette"); MD:RemoveItem("Blur")
```

### TextBox
```lua
local TB = Tab:AddTextBox({
    Name        = "Username",
    Placeholder = "Enter name...",
    Default     = "",
    NumberOnly  = false,   -- true = only numbers/decimals accepted
    Color       = Color3.fromRGB(135,74,252),
    Id          = "username",
    Callback    = function(text) end,  -- fires on Enter
})
TB:Get(); TB:Set("Hello"); TB:Clear(); TB:Focus(); TB:SetPlaceholder("...")
```

### Keybind
```lua
local KB = Tab:AddKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightShift,
    Callback = function() Win:Toggle() end,
})
KB:Get(); KB:Set(Enum.KeyCode.F4)
-- Click the pill to re-bind; press the new key to confirm
-- Does NOT fire while a TextBox is focused
```

### Color Picker
```lua
local CP = Tab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(135,74,252),
    Id       = "espColor",
    Callback = function(color) end,
})
CP:Get(); CP:Set(Color3.fromRGB(255,0,0))
```

### Progress Bar
```lua
local PB = Tab:AddProgressBar({
    Name  = "Loading...",
    Value = 0,
    Color = Color3.fromRGB(135,74,252),
})
PB:Get(); PB:Set(75); PB:Animate(100, 2)  -- Animate(value, duration)
```

### Credit Footer
```lua
Tab:AddCredit("Made by YourName", "discord.gg/yourserver")
-- second line is optional
```

---

## Notifications

```lua
-- Via window:
Win:Notify({
    Title    = "Success",
    Desc     = "Operation complete",
    Duration = 4,
    Icon     = "rbxassetid://12345",   -- or plain text "!"
    Color    = Color3.fromRGB(66,212,130),
})

-- Standalone (works before any window is created):
NexusUI:Notify({ Title="Hello", Desc="World", Duration=3 })
```

---

## Icons (MkIcon)

`Icon` fields across all elements accept:

| Input | Result |
|-------|--------|
| `"N"` | TextLabel with that character |
| `"rbxassetid://123"` | ImageLabel, natural colours |
| `"123456789"` | Same as above (auto-prefixed) |
| `"rbxthumb://..."` | Thumbnail URL → ImageLabel |
| `{ Icon="...", Color=..., NoTint=bool, Scale="Fit" }` | Full control |

> **Note v2.1:** Images now default to `NoTint = true` (natural colours) and are preloaded via `ContentProvider:PreloadAsync` so they actually appear.

---

## Theme Customisation

```lua
-- Override any theme colour at runtime (affects all new elements):
NexusUI:SetTheme({
    Accent    = Color3.fromRGB(255, 80, 80),
    AccentHi  = Color3.fromRGB(255, 130, 130),
    AccentLo  = Color3.fromRGB(200, 40, 40),
})
```

---

## Config Save / Load

Any element with a non-empty `Id` field is registered in the config system.

```lua
Win:SaveConfig("slot1")    -- saves to  NexusUI_<Title>_slot1.json
Win:LoadConfig("slot1")    -- loads and applies all registered values
Win:SaveConfig()           -- default slot name is "default"
```

Supported types: `bool`, `number`, `string`, `multi` (table), `color`.

---

## v2.1 Change Details

### Drag (Mobile Fix)
The old drag tracked movement by matching input objects via `UIS.InputChanged`. On mobile this was unreliable because touch events don't always propagate to the global listener consistently.

**v2.1 approach:**
- Stores the specific `Input` object (`activeInput`) when the drag begins
- Listens on **both** `handle.InputChanged` (inside the handle) and `UIS.InputChanged` (anywhere) and only acts when `input == activeInput`
- Listens on **both** `handle.InputEnded` and `UIS.InputEnded` so the drag always releases even if the finger lifts outside the title bar
- Multi-touch safe — only the first touch that hits the handle starts dragging; other touches are ignored
- Returns `{ Disconnect = fn }` so the global connections are always cleaned up when the window closes

### UIStroke Brightness
All border colours were raised significantly:

| Key | Before | After |
|-----|--------|-------|
| `Border` | `55, 42, 92` | `90, 70, 148` |
| `BorderBri` | `88, 66, 144` | `128, 98, 195` |
| `BorderGlow` | `108, 78, 198` | `160, 118, 242` |

Default `UIStroke` thickness raised from `1` to `1.5`.

### Image Loading Fix
- `NoTint` now defaults `true` for image assets — images show their natural colours instead of being tinted by the accent colour
- `ContentProvider:PreloadAsync` is called in a background `task.spawn` immediately after creating any `ImageLabel`, ensuring the texture actually loads
- Default `imgSize` changed from `UDim2.new(0.72, 0, 0.72, 0)` to `UDim2.new(1, 0, 1, 0)` with `ScaleType.Fit` — fills the container and respects aspect ratio

---

## License

Free to use in your Roblox projects. Credit appreciated but not required.

