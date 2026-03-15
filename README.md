# NexusUI — Roblox Luau UI Library

> A polished, animated, feature-rich UI framework for Roblox.
> Drop-in, zero-dependency. Supports **PC, Mobile and Tablet**.

---

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.5** | Frame zi/clip swap fix (dropdowns now visible), TweenCache GC leak fixed, MkIcon NoTint false-trap fixed, ColorPicker Set() ring restored, Dropdown row signal leak fixed, Keybind now saves/loads, SaveConfig keycode serialisation, Slider SetEnabled added, Section/Separator return API |
| **v2.4** | Camera nil-guard, AbsoluteSize defer, idle drag early-exit, triple UI parenting fallback, notification cap (max 5), tween cancellation system |
| **v2.3** | Drag type-mismatch fix, UDim2.fromOffset, full connection cleanup, safer pcall, nil-safety guards |
| **v2.1** | Mobile drag rewrite, brighter UIStrokes, UICorner on content pane, image preload fix |
| **v2.0** | Button spam fix, drag connection leak, Toggle/Dropdown visibility, checkmarks, chevrons, Slider Step, SetTheme, MultiDropdown search |
| **v1.0** | Initial release |

---

## v2.5 — Fix Details

### Fix 1 — Frame ZIndex / ClipsDescendants Arguments Swapped (Critical)

The `Frame()` helper signature is `Frame(parent, size, pos, color, zi, clip)`.
Five call-sites had the last two arguments reversed, causing cascading layout
and rendering failures:

- **`overlay`** was getting `ZIndex = 1` (not 50) — dropdown lists rendered
  behind the content area and were completely invisible.
- **`body`** had `ClipsDescendants = true` — dropdown pop-ups were clipped at
  the content area boundary and cut off.
- **`win`** also clipped, causing the same problem from the outer frame.
- **`body.ZIndex = true`** — assigning a boolean to ZIndex is a type error
  in Luau and produces a runtime exception.
- **`tabBar` / `contentArea`** — similar swaps causing wrong stacking order.

```lua
-- OLD (broken): zi=false → ZIndex not set; clip=2 → ClipsDescendants=true
local win = Frame(sg, wSize, wPos, T.BG, false, 2)

-- NEW (correct): zi=2; clip=false
local win = Frame(sg, wSize, wPos, T.BG, 2, false)
```

---

### Fix 2 — MkIcon `NoTint = false` Silently Became `true`

Classic Lua `and/or` ternary pattern fails when the truthy branch is `false`:

```lua
-- OLD: if o.NoTint == false this evaluates to (false and false) or true → true
noTint = (o.NoTint ~= nil) and o.NoTint or true

-- NEW: safe nil-check that preserves false correctly
noTint = (o.NoTint == nil) and true or o.NoTint
```

Passing `NoTint = false` to an icon now correctly applies the tint colour.

---

### Fix 3 — TweenCache Memory Leak (Weak Keys)

The `TweenCache` table held strong references to GUI objects as keys.
Destroyed instances were never collected by the GC because the table kept
them alive.

```lua
-- OLD: strong keys — destroyed objects linger forever
local TweenCache = {}

-- NEW: weak keys — GC collects entries when the object is destroyed
local TweenCache = setmetatable({}, {__mode = "k"})
```

---

### Fix 4 — ColorPicker `Set()` Lost the Active Ring Indicator

`Set()` cleared the old active ring but never highlighted the swatch that
matched the new colour. After a `Set()` call the picker looked deselected
even if a palette colour was active.

Added a `swatchRings` lookup table (keyed by `Color3`) so `Set()` can
find and restore the matching ring:

```lua
local swatchRings = {}   -- [Color3] = UIStroke ring

-- In the swatch build loop:
swatchRings[col] = ring

-- In Set():
function CP:Set(c)
    selColor = c; prev.BackgroundColor3 = c
    if activeRing then FT(activeRing, {Transparency=1}, 0.1); activeRing=nil end
    local matchRing = swatchRings[c]
    if matchRing then FT(matchRing, {Transparency=0}, 0.1); activeRing=matchRing end
end
```

---

### Fix 5 — Dropdown Row Signal Connection Leak

`BuildRows` was clearing old rows with `r.Parent = nil`. Setting Parent to
nil detaches the Instance from the tree visually but **does not destroy it**.
All `MouseEnter`, `MouseLeave`, and `MouseButton1Click` connections on each
row remained alive and accumulated on every rebuild (every keypress in the
search box).

```lua
-- OLD: orphaned rows with live connections
for _,r in ipairs(rows) do r.Parent = nil end

-- NEW: fully destroys rows and all their descendant connections
for _,r in ipairs(rows) do r:Destroy() end
```

This applies to both `AddDropdown` and `AddMultiDropdown`.

---

### Fix 6 — Keybind Never Called `Reg()` (Cannot Save/Load)

`AddKeybind` was the only element that never called `Reg()`, so keybinds
were silently excluded from `SaveConfig` / `LoadConfig`. Added `Id` option
and registered with the `"keycode"` type:

```lua
-- NEW: keybind registers its key as a Name string (safe for JSON)
Reg(wName, id,
    function() return curKey.Name end,          -- e.g. "RightShift"
    function(v)
        local ok, kc = pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then KB:Set(kc) end
    end,
    "keycode", KB)
```

---

### Fix 7 — `SaveConfig` Crashed on Keybind / EnumItem Values

`HttpService:JSONEncode` cannot serialise Roblox `EnumItem` values and
throws a runtime error. `SaveConfig` now routes each type through its own
encoder:

```lua
if e.Type == "color" then
    data[id] = EncC(v)             -- {r, g, b} table
elseif e.Type == "keycode" then
    data[id] = tostring(v)         -- Name string, e.g. "F4"
else
    data[id] = v                   -- number / string / bool — safe as-is
end
```

`LoadConfig` mirrors this: colour values go through `DecC()`, everything
else (including keycodes) passes directly to the element's setter.

---

### Fix 8 — Slider Missing `SetEnabled()`

`AddToggle` exposed `SetEnabled(v)` but `AddSlider` did not, creating an
inconsistent API surface. Added the method:

```lua
function Sl:SetEnabled(v)
    FT(card, {BackgroundTransparency = v and 0 or 0.45}, 0.18)
    FT(nl,   {TextColor3 = v and T.TxtMain or T.TxtOff},  0.18)
    FT(vl,   {TextColor3 = v and color    or T.TxtOff},   0.18)
end
```

---

### Fix 9 — Slider Connection Cleanup Used `pairs` on Sequential Table

`pairs` on a sequential (array) table is technically incorrect — iteration
order is undefined. Changed to `ipairs`:

```lua
-- OLD
for _,c in pairs(conns) do c:Disconnect() end

-- NEW
for _,c in ipairs(conns) do c:Disconnect() end
```

---

### Fix 10 — `AddSection` / `AddSeparator` Returned Nothing

All other elements return a Wrap API so callers can call `:SetVisible()` or
`:Destroy()`. Section and Separator were the only two that returned `nil`,
making it impossible to hide or remove them at runtime.

Both now return a `Wrap(container)` object.

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusDevReal/NexusUI/refs/heads/main/NexusUI.lua"))()

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v2.5",
    Icon     = "rbxassetid://YOUR_ICON_ID",
    Size     = UDim2.new(0, 370, 0, 500),
})

local Tab = Win:AddTab("Main")

Tab:AddToggle({
    Name     = "God Mode",
    Default  = false,
    Callback = function(state) print("God Mode:", state) end,
})
```

---

## Window API

```lua
NexusUI:CreateWindow({
    Title    = "Window Title",
    Subtitle = "v2.5",
    Icon     = "N",
    Size     = UDim2.new(0, 370, 0, 500),
    Position = UDim2.new(0.5, -185, 0.5, -250),
})
```

| Method | Description |
|--------|-------------|
| `Win:AddTab(name)` | Create a tab, returns Tab API |
| `Win:Toggle()` | Show or hide the window |
| `Win:IsVisible()` | Returns `true` if visible |
| `Win:Destroy()` | Animate-close and fully destroy |
| `Win:SetTitle(t)` | Change title text live |
| `Win:SetSubtitle(s)` | Change version chip text |
| `Win:Notify({...})` | Send a notification (max 5 at once) |
| `Win:SaveConfig(name)` | Save all element values to JSON |
| `Win:LoadConfig(name)` | Load and apply saved config |
| `Win:GetValue(id)` | Get value by element ID |
| `Win:SetValue(id, val)` | Set value by element ID |
| `Win:GetElement(id)` | Get full element API by ID |
| `Win:ListIds()` | Returns `{ [id] = type }` table |

---

## Elements

### Section / Separator
```lua
local Sec = Tab:AddSection("Combat")   -- v2.5: now returns API
local Sep = Tab:AddSeparator()         -- v2.5: now returns API
Sec:SetVisible(false)
Sep:Destroy()
```

### Label
```lua
local L = Tab:AddLabel({ Text="Info", Color=Color3.fromRGB(200,200,255), Align="Center", Bold=true })
L:SetText("hi"); L:SetColor(Color3.new(1,1,1)); L:SetSize(16)
L:SetVisible(false); L:Destroy()
```

### Paragraph
```lua
local P = Tab:AddParagraph({ Title="About", Content="Long text here." })
P:SetTitle("T"); P:SetContent("C"); P:SetColor(Color3.new(1,1,1))
```

### Button
```lua
local B = Tab:AddButton({
    Name     = "Teleport",
    Desc     = "Go to spawn",
    Icon     = "rbxassetid://12345",
    Callback = function() end,
})
B:SetName("…"); B:SetDesc("…"); B:SetEnabled(false)
```

### Toggle
```lua
local Tog = Tab:AddToggle({
    Name     = "Speed",
    Default  = false,
    Id       = "speed",
    Callback = function(v) end,
})
Tog:Get(); Tog:Set(true); Tog:Fire(); Tog:SetEnabled(false)
```

### Slider
```lua
local S = Tab:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 200,
    Default  = 16,
    Step     = 1,       -- decimal steps supported: Step=0.01
    Suffix   = " WS",
    Id       = "ws",
    Callback = function(v) end,
})
S:Get(); S:Set(50); S:SetMin(0); S:SetMax(500)
S:SetStep(0.5); S:SetSuffix("x"); S:SetEnabled(false)   -- v2.5: SetEnabled added
```

### Dropdown
```lua
local D = Tab:AddDropdown({
    Name        = "Mode",
    Items       = {"A","B","C"},
    Placeholder = "Select...",
    Id          = "mode",
    Callback    = function(v) end,
})
D:Get(); D:Set("B"); D:Clear(); D:IsEmpty(); D:IsSelected("B")
D:AddItem("D"); D:RemoveItem("A"); D:Refresh(newList); D:SetPlaceholder("…")
-- Close with Escape key (v2.4+)
```

### Multi Dropdown
```lua
local MD = Tab:AddMultiDropdown({
    Name     = "Effects",
    Items    = {"Blur","Bloom","Vignette"},
    Default  = {"Blur"},
    Id       = "fx",
    Callback = function(selectedTable) end,
})
MD:Get(); MD:Set({"Blur","Bloom"}); MD:Clear(); MD:SelectAll()
MD:IsEmpty(); MD:IsSelected("Blur")
MD:AddItem("Vignette"); MD:RemoveItem("Blur")
MD:SetPlaceholder("None")
-- Close with Escape key (v2.4+)
```

### TextBox
```lua
local TB = Tab:AddTextBox({
    Name        = "Player Name",
    Placeholder = "Type here…",
    NumberOnly  = false,   -- set true for numeric-only input (supports decimals & negatives)
    Id          = "txt",
    Callback    = function(text) end,   -- fires on Enter
})
TB:Get(); TB:Set("hello"); TB:Clear(); TB:Focus(); TB:SetPlaceholder("…")
```

### Keybind
```lua
local KB = Tab:AddKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightShift,
    Id       = "toggleKey",   -- v2.5: Id now works; keybind is saved/loaded
    Callback = function() Win:Toggle() end,
})
KB:Get()                       -- returns current KeyCode enum
KB:Set(Enum.KeyCode.F4)
```

> **Note (v2.5):** Keybinds are now included in `SaveConfig`/`LoadConfig`.
> The key is stored as its Name string (e.g. `"RightShift"`) in JSON.
> Requires `Id` to be set.

### Color Picker
```lua
local CP = Tab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(135, 74, 252),
    Id       = "espColor",
    Callback = function(color) end,
})
CP:Get()
CP:Set(Color3.fromRGB(255, 0, 0))   -- v2.5: ring indicator now correctly restored
```

### Progress Bar
```lua
local PB = Tab:AddProgressBar({ Name="Loading", Value=0 })
PB:Get()           -- returns current numeric value (not parsed from text)
PB:Set(75)
PB:Animate(100, 2) -- animate to 100% over 2 seconds
```

### Credit Footer
```lua
Tab:AddCredit("Made by YourName", "discord.gg/yourserver")
```

---

## Notifications

```lua
Win:Notify({
    Title    = "Done",
    Desc     = "Action complete",
    Duration = 4,
    Icon     = "rbxassetid://123456",
    Color    = Color3.fromRGB(66, 212, 130),
})

-- Works even before any window is created
NexusUI:Notify({ Title="Hello", Duration=3 })
```

Max 5 notifications visible at once. The oldest is auto-dismissed when the
cap is hit.

---

## Icons

| Input | Result |
|-------|--------|
| `"N"` | TextLabel with that character |
| `"rbxassetid://123456"` | ImageLabel, natural colours, preloaded |
| `"123456789"` | Auto-prefixed to `rbxassetid://` |
| `"rbxthumb://..."` | Thumbnail URL, ImageLabel |
| `{ Icon="…", NoTint=false, Scale="Crop" }` | Full table — `NoTint=false` now correctly applies tint (v2.5 fix) |

---

## Theme

Override any colour at runtime — affects all subsequently created elements:

```lua
NexusUI:SetTheme({
    Accent   = Color3.fromRGB(255, 80,  80),
    AccentHi = Color3.fromRGB(255, 130, 130),
})
```

---

## Config / Persistence

```lua
Win:SaveConfig("slot1")   -- writes NexusUI_<Title>_slot1.json
Win:LoadConfig("slot1")   -- reads and applies all saved values

Win:SaveConfig()           -- uses "default" slot name
Win:LoadConfig()
```

Supported element types and their JSON encoding:

| Element type | Stored as |
|---|---|
| Toggle | `boolean` |
| Slider | `number` |
| TextBox | `string` |
| Dropdown | `string` |
| Multi Dropdown | `string[]` array |
| Color Picker | `{r, g, b}` table |
| Keybind *(v2.5)* | `string` (KeyCode Name, e.g. `"RightShift"`) |

---

## Library Info

```lua
print(NexusUI.Version)   -- "2.5"
print(NexusUI.MkIcon)    -- icon helper, callable externally
```

