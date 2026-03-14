# NexusUI — Roblox Luau UI Library

> **Current Version:** `v1.4`
> A full-featured, production-ready UI Library for Roblox scripts.
> Clean dark purple theme · Smooth animations · Mobile support · Config Save/Load

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusDevReal/NexusUI/refs/heads/main/NexusUI.lua"))()

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v1.0",
    Icon     = "S",          -- Short ASCII only (see Icon Rules)
    Size     = UDim2.new(0, 370, 0, 500),
})

local Main = Win:AddTab("Main")
Main:AddToggle({ Name = "God Mode", Callback = function(v) print(v) end })
```

> **Icon Rules** — Roblox's Gotham font does NOT render emoji or multi-byte Unicode.
> Always use short ASCII strings: `"N"`, `"W"`, `"!"`, `"+"`, `"OK"`, `"i"`.

---

## Version History

### v1.5 — *Current*
- **UICorner** on the main window frame properly rounds all 4 corners
- **`AddMultiDropdown`** — multi-select element with checkboxes, Select All / Clear buttons, and count badge
- **`AddParagraph`** — styled title + body text block with transparent card and accent strip
- **`AddLabel`** — transparent, simple text display (replaces old plain label)
- **Config Save/Load System** — `Win:SaveConfig(name)` and `Win:LoadConfig(name)` via executor `writefile`/`readfile` with JSON serialisation; falls back to `print` if no executor access

### v1.4
- Shadow system fully **removed** — replaced with a clean `UIStroke` accent border
- **TitleBar redesigned** — 60 px tall, richer 3-stop gradient, larger icon pill with inner shine, version badge chip, separator line
- **Body bottom** now has a decorative accent footer bar making the edge look intentional
- **`AddCredit`** — transparent-background credit element with `GothamBold` styled text and decorative divider lines

## V1.3 — Bug Fix Release
- **Emoji/Unicode garble fixed** — All emoji removed; icons are now safe ASCII strings
- **Slider purple square fixed** — Removed glow `Frame` that bled outside knob bounds; replaced with animated `UIStroke` ring
- **Toggle glow square fixed** — Same fix applied to toggle thumb
- **Dropdown clipping fixed** — Dropdown list now parents to a dedicated `dropOverlay` frame above the `ScrollingFrame`, so it is never clipped
- **Proper scroll** — Each tab page is a proper `ScrollingFrame` with auto-canvas

### v1.2
- Drop shadow system (layered frames + `RenderStepped` sync)
- Per-tab `ScrollingFrame` pages
- Overlay system for dropdown positioning
- `AddColorPicker`, `AddProgressBar`, `AddKeybind`
- `NexusUI:Notify()` notification system

### v1.1
- iOS-style `AddToggle` with spring animation
- `AddSlider` with draggable knob
- `AddDropdown` with animated list
- Tab system with animated active indicator
- Mobile touch support (all elements)

### v1.0
- Initial release
- `CreateWindow`, `AddTab`, `AddButton`, `AddToggle` (basic), `AddTextBox`
- Drag support, close & minimize buttons

---

## Window API

### `NexusUI:CreateWindow(options)`

Creates and shows the main window.

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"NexusUI"` | Window title text |
| `Subtitle` | `string` | `"v1.5"` | Version badge text |
| `Icon` | `string` | `"N"` | Short ASCII icon shown in the pill |
| `Size` | `UDim2` | `(0,370,0,500)` | Window size |
| `Position` | `UDim2` | Center screen | Initial position |

**Returns:** `WinAPI` object

```lua
local Win = NexusUI:CreateWindow({
    Title    = "Wonder Chase",
    Subtitle = "v3.0",
    Icon     = "W",
    Size     = UDim2.new(0, 380, 0, 500),
})
```

---

### `Win:AddTab(tabName)`

Adds a tab to the window's tab bar.

| Param | Type | Description |
|---|---|---|
| `tabName` | `string` | Plain text name (no emoji) |

**Returns:** `TabAPI` object

```lua
local Main     = Win:AddTab("Main")
local Settings = Win:AddTab("Settings")
local Credits  = Win:AddTab("Credits")
```

---

### `Win:Notify(options)` / `NexusUI:Notify(options)`

Shows a toast notification in the bottom-right corner.

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Notification"` | Bold header |
| `Desc` | `string` | `""` | Sub-text description |
| `Duration` | `number` | `4` | Seconds before auto-dismiss |
| `Icon` | `string` | `"!"` | ASCII icon shown in the bubble |
| `Color` | `Color3` | Accent purple | Accent color for border + icon |

```lua
Win:Notify({
    Title    = "Success",
    Desc     = "Settings saved!",
    Duration = 3,
    Icon     = "OK",
    Color    = Color3.fromRGB(70, 210, 128),
})
```

---

### `Win:SaveConfig(configName)`

Serialises all registered element values (those with an `Id` field) to JSON and saves to a file named `NexusUI_<Title>_<configName>.json` using the executor's `writefile`.

If `writefile` is unavailable, prints the JSON to the output as a fallback.

```lua
Win:SaveConfig("default")
Win:SaveConfig("speedrun")
```

---

### `Win:LoadConfig(configName)`

Reads and applies a previously saved config file. Each element whose `Id` matches a key in the file will have its value restored.

```lua
Win:LoadConfig("default")
```

**Note:** Elements must have the `Id` field set when they are created to participate in Save/Load.

---

## Tab Elements (TabAPI)

All elements below are called on the object returned by `Win:AddTab(...)`.

---

### `Tab:AddSection(name)`

Decorative text divider with lines on each side.

```lua
Main:AddSection("Automation")
```

---

### `Tab:AddSeparator()`

Thin horizontal rule line.

```lua
Main:AddSeparator()
```

---

### `Tab:AddLabel(options)`

> **NEW in v1.5**

Simple transparent text display — no card background.

| Option | Type | Default | Description |
|---|---|---|---|
| `Text` | `string` | `"Label"` | Text content |
| `Color` | `Color3` | `TxtSub` | Text colour |
| `Align` | `string` | `"Left"` | `"Left"`, `"Center"`, `"Right"` |
| `TextSize` | `number` | `13` | Font size |
| `Bold` | `bool` | `false` | Use GothamBold if true |

**Returns:** `LabelAPI` — `:SetText(t)`, `:SetColor(c)`

```lua
local lbl = Main:AddLabel({
    Text  = "Status: Active",
    Color = Color3.fromRGB(70, 210, 128),
    Align = "Center",
    Bold  = true,
})
lbl:SetText("Status: Idle")
```

---

### `Tab:AddParagraph(options)`

> **NEW in v1.5**

A title + multi-line body text block. Semi-transparent card with a left accent strip.

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Paragraph"` | Bold heading |
| `Content` | `string` | `""` | Body text (auto-wraps) |
| `Color` | `Color3` | `TxtSub` | Body text colour |

**Returns:** `ParaAPI` — `:SetTitle(t)`, `:SetContent(c)`

```lua
Main:AddParagraph({
    Title   = "How to use",
    Content = "Enable Auto Play to automatically start rounds. Adjust the Item Value slider to control the payout multiplier.",
})
```

---

### `Tab:AddButton(options)`

Full-width button card with an optional left icon and a gradient "Run" pill on the right.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Button"` | Button label |
| `Desc` | `string` | `""` | Optional sub-description |
| `Icon` | `string` | `""` | ASCII icon in a circle |
| `Color` | `Color3` | Accent | Run pill colour |
| `Callback` | `function` | — | Called on click |

```lua
Main:AddButton({
    Name     = "Check Leaderboard",
    Icon     = "L",
    Callback = function()
        print("Opened!")
    end,
})
```

---

### `Tab:AddToggle(options)`

iOS-style switch with spring animation and thumb ring.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Toggle"` | Label |
| `Desc` | `string` | `""` | Sub-description |
| `Default` | `bool` | `false` | Initial state |
| `Color` | `Color3` | Accent | Track colour when ON |
| `Id` | `string` | `""` | Config key (for Save/Load) |
| `Callback` | `function(bool)` | — | Fires with new state |

**Returns:** `TogAPI` — `:Set(bool)`, `:Get() → bool`

```lua
local tog = Main:AddToggle({
    Name     = "Auto Play",
    Desc     = "Automatically start rounds",
    Default  = false,
    Id       = "autoPlay",
    Callback = function(v) print("Auto Play:", v) end,
})

tog:Set(true)
print(tog:Get())
```

---

### `Tab:AddSlider(options)`

Draggable slider with gradient fill and animated knob ring.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Slider"` | Label |
| `Desc` | `string` | `""` | Sub-description |
| `Min` | `number` | `0` | Minimum value |
| `Max` | `number` | `100` | Maximum value |
| `Default` | `number` | `Min` | Starting value |
| `Suffix` | `string` | `""` | Appended to value display e.g. `"s"` |
| `Color` | `Color3` | Accent | Fill colour |
| `Id` | `string` | `""` | Config key |
| `Callback` | `function(number)` | — | Fires with rounded value |

**Returns:** `SliderAPI` — `:Set(number)`, `:Get() → number`

```lua
local slider = Main:AddSlider({
    Name     = "Timer",
    Min      = 10, Max = 300, Default = 120,
    Suffix   = "s",
    Id       = "timer",
    Callback = function(v) print("Timer:", v) end,
})
```

---

### `Tab:AddDropdown(options)`

Single-select dropdown with animated chevron, search bar, and checkmark.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Dropdown"` | Label |
| `Items` | `table` | — | List of string options |
| `Default` | `string` | `Items[1]` | Pre-selected value |
| `Color` | `Color3` | Accent | Checkmark colour |
| `Id` | `string` | `""` | Config key |
| `Callback` | `function(string)` | — | Fires with selected item |

**Returns:** `DropAPI` — `:Get() → string`, `:Set(string)`, `:Refresh(table)`

```lua
local drop = Settings:AddDropdown({
    Name     = "Theme Color",
    Items    = {"Purple", "Blue", "Green", "Red"},
    Default  = "Purple",
    Id       = "theme",
    Callback = function(v) print("Theme:", v) end,
})
```

---

### `Tab:AddMultiDropdown(options)`

> **NEW in v1.5**

Multi-select dropdown with checkbox rows, count badge pill, and Select All / Clear actions.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Multi Select"` | Label |
| `Items` | `table` | — | List of string options |
| `Default` | `table` | `{}` | Pre-selected values `{"A","B"}` |
| `Color` | `Color3` | Accent | Checkbox & badge colour |
| `Id` | `string` | `""` | Config key |
| `Callback` | `function(table)` | — | Fires with `{"selected","items"}` |

**Returns:** `MultiDropAPI` — `:Get() → table`, `:Set(table)`

```lua
local multi = Main:AddMultiDropdown({
    Name    = "Active Modes",
    Items   = {"Speed", "Jump", "Fly", "Noclip", "ESP"},
    Default = {"Speed"},
    Id      = "modes",
    Callback = function(selected)
        for _, v in selected do print("Active:", v) end
    end,
})

-- get current selection
local modes = multi:Get()  -- returns e.g. {"Speed", "Fly"}

-- programmatically set
multi:Set({"Fly", "ESP"})
```

---

### `Tab:AddTextBox(options)`

Styled text input with focus glow and optional number-only mode.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Input"` | Label above the box |
| `Placeholder` | `string` | `"Type here..."` | Placeholder text |
| `Default` | `string` | `""` | Pre-filled value |
| `NumberOnly` | `bool` | `false` | Strip non-numeric characters |
| `Color` | `Color3` | Accent | Focus glow colour |
| `Id` | `string` | `""` | Config key |
| `Callback` | `function(string)` | — | Fires on Enter |

**Returns:** `TBxAPI` — `:Get() → string`, `:Set(string)`

```lua
local tb = Settings:AddTextBox({
    Name        = "Player Name",
    Placeholder = "Enter username...",
    Id          = "playerName",
    Callback    = function(t) print("Name:", t) end,
})
```

---

### `Tab:AddKeybind(options)`

Click-to-bind keybind element. Fires callback when the bound key is pressed.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Keybind"` | Label |
| `Default` | `Enum.KeyCode` | `KeyCode.F` | Default key |
| `Callback` | `function` | — | Fires when key is pressed |

**Returns:** `KBApi` — `:Get() → KeyCode`, `:Set(KeyCode)`

```lua
Settings:AddKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightShift,
    Callback = function() print("Toggled!") end,
})
```

---

### `Tab:AddColorPicker(options)`

8-swatch colour picker with active ring indicator and live preview box.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Color"` | Label |
| `Default` | `Color3` | Accent purple | Pre-selected colour |
| `Id` | `string` | `""` | Config key |
| `Callback` | `function(Color3)` | — | Fires on swatch click |

**Returns:** `CPApi` — `:Get() → Color3`, `:Set(Color3)`

```lua
Settings:AddColorPicker({
    Name     = "Accent Color",
    Default  = Color3.fromRGB(130,72,245),
    Id       = "accentColor",
    Callback = function(c) print("Color:", c) end,
})
```

---

### `Tab:AddProgressBar(options)`

Animated gradient fill progress bar.

| Option | Type | Default | Description |
|---|---|---|---|
| `Name` | `string` | `"Progress"` | Label |
| `Value` | `number` | `0` | Initial value `0-100` |
| `Color` | `Color3` | Accent | Fill colour |

**Returns:** `PBApi` — `:Set(number)`, `:Get() → number`

```lua
local pb = Main:AddProgressBar({
    Name  = "XP Progress",
    Value = 65,
    Color = Color3.fromRGB(70, 210, 128),
})
pb:Set(80)
```

---

### `Tab:AddCredit(line1, line2?)`

Transparent credit display with decorative divider lines and styled `GothamBold` text. Designed for Credits tabs.

| Param | Type | Description |
|---|---|---|
| `line1` | `string` | Primary credit line (large, light purple) |
| `line2` | `string?` | Optional sub-line (smaller, muted) |

```lua
Credits:AddCredit("Credit By NexusDev")
Credits:AddCredit("Wonder Chase UI", "Version 3.0  |  2026")
Credits:AddCredit("Special Thanks", "The Community")
```

---

## Config Save / Load — Full Example

```lua
local Win = NexusUI:CreateWindow({ Title = "MyScript", Subtitle = "v1.0", Icon = "M" })
local Main = Win:AddTab("Main")
local Cfg  = Win:AddTab("Config")

-- Elements with Id fields participate in config
local tog = Main:AddToggle({
    Name = "Auto Play", Default = false, Id = "autoPlay",
    Callback = function(v) print(v) end,
})
local sl = Main:AddSlider({
    Name = "Speed", Min = 1, Max = 50, Default = 10, Id = "speed",
    Callback = function(v) print(v) end,
})
local drop = Main:AddDropdown({
    Name = "Mode", Items = {"Easy","Normal","Hard"}, Default = "Normal", Id = "mode",
    Callback = function(v) print(v) end,
})

-- Save / Load buttons
Cfg:AddButton({ Name = "Save Config",  Icon = "S", Callback = function() Win:SaveConfig("default") end })
Cfg:AddButton({ Name = "Load Config",  Icon = "L", Callback = function() Win:LoadConfig("default") end })
```

**Saved file format** (`NexusUI_MyScript_default.json`):
```json
{
  "autoPlay": false,
  "speed": 10,
  "mode": "Normal"
}
```

**Supported types in config:**

| Element | Type saved |
|---|---|
| Toggle | `boolean` |
| Slider | `number` |
| Dropdown | `string` |
| MultiDropdown | `array of strings` |
| TextBox | `string` |
| ColorPicker | `{r, g, b}` object |

---

## Theme Reference

All theme colours are defined in the `T` table. You can fork the library and edit these to match your script's style.

| Key | Hex | Usage |
|---|---|---|
| `BG` | `#0D0A1C` | Window background |
| `Surface` | `#16112C` | Card background |
| `SurfaceHi` | `#20193A` | Elevated card, pill BG |
| `SurfaceHi2` | `#2C2348` | Hover state |
| `Border` | `#342858` | Card stroke |
| `Accent` | `#8248F5` | Primary purple accent |
| `AccentHi` | `#A26EFF` | Lighter accent (gradients) |
| `AccentLo` | `#5A2CC0` | Darker accent (icon pills) |
| `TxtMain` | `#EEE8FF` | Primary text |
| `TxtSub` | `#968842` | Secondary text |
| `TxtMute` | `#564878` | Muted/placeholder text |
| `Green` | `#46D280` | Success, progress |
| `Red` | `#F54258` | Danger, close button |
| `Yellow` | `#FAB832` | Warning |

---

## File Structure

```
NexusUI.lua        — Main library (load with loadstring)
README.md          — This documentation file
NexusUI_<Title>_<configName>.json  — Auto-generated config files
```

---

## Notes

- **Executor required for Config I/O.** `writefile` and `readfile` are executor APIs (Synapse X, KRNL, etc.). The library handles the case where these are unavailable by printing to output.
- **No emoji in any text field.** Roblox's Gotham/GothamBold fonts render multi-byte Unicode as garbled latin characters. Use only short ASCII strings for icons, tab names, and button labels.
- **ZIndex safety.** The dropdown overlay runs at ZIndex 50. Notifications run at ZIndex 200. All regular elements are between 3–10.
- **Mobile support.** Every interactive element (`Toggle`, `Slider`, `Dropdown`, dragging) handles both `MouseButton1` and `Touch` input types.
