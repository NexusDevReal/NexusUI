# NexusUI — Roblox Luau UI Library

> A polished, animated, feature-rich UI framework for Roblox.  
> Drop-in, zero-dependency. Supports **PC, Mobile and Tablet**.

---

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.3** | Drag type-mismatch fix, UDim2.fromOffset, full connection cleanup, safer pcall, nil-safety guards |
| **v2.1** | Mobile drag rewrite, brighter UIStrokes, UICorner on content pane, image preload fix, "x" close button |
| **v2.0** | Button spam fix, drag leak fix, Toggle/Dropdown visibility fix, ✓ checkmarks, ▾ chevrons, Slider Step, SetTheme, MultiDropdown search, Escape closes dropdowns |
| **v1.0** | Initial release |

---

## v2.3 — Bug Fix Details

### Fix 1 — Drag Never Moved (type mismatch)

**Root cause:**
The drag movement check compared the stored `activeInput` (a `MouseButton1` object) against the `input` arriving in `InputChanged` (a `MouseMovement` object). These are **always different objects** — so the condition `input == activeInput` was always `false` and the window never moved.

```lua
-- OLD (always false — wrong object compared)
if input == activeInput then doMove(input.Position) end

-- NEW (correct — checks the input type instead)
if input.UserInputType == Enum.UserInputType.MouseMovement or
   input.UserInputType == Enum.UserInputType.Touch then
    doMove(input.Position)
end
```

---

### Fix 2 — Window Jumps on First Drag (mixed Scale + Offset)

**Root cause:**
`startPos` was stored as `win.Position` which contains a Scale component (e.g. `UDim2.new(0.5, -185, 0.5, -250)`). Adding pixel deltas to a mixed Scale/Offset UDim2 causes a visible jump on the first frame.

```lua
-- OLD — Scale values mixed with offset delta = position jump
win.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)

-- NEW — pure pixels only, no Scale interference
win.Position = UDim2.fromOffset(newX, newY)
```

`startPos` is now captured from `win.AbsolutePosition` (pure pixel coordinates).

---

### Fix 3 — Connection Memory Leak

**Root cause:**
Only 2 of 5 drag connections were disconnected on window destroy. The other 3 (`handle.InputBegan`, `handle.InputChanged`, `handle.InputEnded`) were never stored and kept running forever.

**Fix:** All 5 connections (`c1`–`c5`) are now stored and all disconnected when `dragCon:Disconnect()` is called:

```lua
return {
    Disconnect = function()
        c1:Disconnect(); c2:Disconnect(); c3:Disconnect()
        c4:Disconnect(); c5:Disconnect()
    end
}
```

---

### Fix 4 — Unsafe Callback Execution

**Root cause:**
Variadic `...` passed directly to `pcall` can still propagate errors in edge cases involving coroutines or yielding callbacks.

**Fix:** Args captured into a table, unpacked inside the protected call:

```lua
local function Call(fn, ...)
    if type(fn) ~= "function" then return end
    local args = {...}
    local ok, err = pcall(function()
        fn(table.unpack(args))
    end)
    if not ok then
        warn("[NexusUI] Callback error:\n  " .. tostring(err))
    end
end
```

No callback error can ever crash or freeze the UI.

---

### Fix 5 — Nil-Safety Guards

**Root cause:**
Several UI event connections assumed the element was created successfully:

```lua
-- OLD — crashes with "attempt to index nil" if creation failed
btn.MouseButton1Click:Connect(Activate)
track.InputBegan:Connect(...)
kBB.MouseButton1Click:Connect(...)
```

**Fix:** All critical connections are now guarded with existence checks:

```lua
if btn   then btn.MouseButton1Click:Connect(Activate) end
if track then track.InputBegan:Connect(...) end
if kBB   then kBB.MouseButton1Click:Connect(...) end
```

`Card()` is wrapped in `pcall` and `Wrap()` guards both `SetVisible` and `Destroy` against nil containers.

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusDevReal/NexusUI/refs/heads/main/NexusUI.lua"))()

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v2.3",
    Icon     = "rbxassetid://YOUR_ICON_ID",  -- or plain text e.g. "N"
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

## Window API

```lua
NexusUI:CreateWindow({
    Title    = "Window Title",
    Subtitle = "v2.3",
    Icon     = "N",
    Size     = UDim2.new(0, 370, 0, 500),
    Position = UDim2.new(0.5, -185, 0.5, -250),
})
```

| Method | Description |
|--------|-------------|
| `Win:AddTab(name)` | Create a tab, returns Tab API |
| `Win:Toggle()` | Show / hide the window |
| `Win:IsVisible()` | Returns `true` if visible |
| `Win:Destroy()` | Animate-close and destroy |
| `Win:SetTitle(t)` | Change title text live |
| `Win:SetSubtitle(s)` | Change version chip text |
| `Win:Notify({...})` | Send a notification |
| `Win:SaveConfig(name)` | Save all element values to JSON |
| `Win:LoadConfig(name)` | Load and apply saved config |
| `Win:GetValue(id)` | Get current value by element ID |
| `Win:SetValue(id, val)` | Set value by element ID |
| `Win:GetElement(id)` | Get full element API by ID |
| `Win:ListIds()` | Returns `{ [id] = type }` table |

---

## Elements

### Section / Separator
```lua
Tab:AddSection("Combat")
Tab:AddSeparator()
```

### Label
```lua
local L = Tab:AddLabel({ Text="Info", Color=Color3.fromRGB(200,200,255), Align="Center", Bold=true })
L:SetText("…"); L:SetColor(Color3.new(1,1,1)); L:SetSize(16)
```

### Paragraph
```lua
local P = Tab:AddParagraph({ Title="About", Content="Long text here." })
P:SetTitle("…"); P:SetContent("…"); P:SetColor(Color3.new(1,1,1))
```

### Button
```lua
local B = Tab:AddButton({
    Name="Teleport", Desc="Go to spawn",
    Icon="rbxassetid://12345",
    Callback=function() end,
})
B:SetName("…"); B:SetDesc("…"); B:SetEnabled(false)
```

### Toggle
```lua
local Tog = Tab:AddToggle({
    Name="Speed", Default=false, Id="speed",
    Callback=function(state) end,
})
Tog:Get(); Tog:Set(true); Tog:Fire(); Tog:SetEnabled(false)
```

### Slider
```lua
local S = Tab:AddSlider({
    Name="Walk Speed", Min=16, Max=200, Default=16,
    Step=1, Suffix=" WS", Id="ws",
    Callback=function(val) end,
})
S:Get(); S:Set(50); S:SetMin(0); S:SetMax(500); S:SetStep(0.5); S:SetSuffix("x")
```

### Dropdown
```lua
local D = Tab:AddDropdown({
    Name="Mode", Items={"A","B","C"},
    Placeholder="Select...", Id="mode",
    Callback=function(val) end,
})
D:Get(); D:Set("B"); D:Clear(); D:IsEmpty(); D:IsSelected("B")
D:AddItem("D"); D:RemoveItem("A"); D:Refresh(newList); D:SetPlaceholder("…")
```

### Multi Dropdown
```lua
local MD = Tab:AddMultiDropdown({
    Name="Effects", Items={"Blur","Bloom","Depth"},
    Default={"Blur"}, Id="fx",
    Callback=function(tbl) end,
})
MD:Get(); MD:Set({"Blur","Bloom"}); MD:Clear(); MD:SelectAll()
MD:IsEmpty(); MD:IsSelected("Blur"); MD:AddItem("Vignette"); MD:RemoveItem("Blur")
```

### TextBox
```lua
local TB = Tab:AddTextBox({
    Name="Username", Placeholder="Type here...",
    NumberOnly=false, Id="uname",
    Callback=function(text) end,  -- fires on Enter
})
TB:Get(); TB:Set("hi"); TB:Clear(); TB:Focus(); TB:SetPlaceholder("…")
```

### Keybind
```lua
local KB = Tab:AddKeybind({
    Name="Toggle UI", Default=Enum.KeyCode.RightShift,
    Callback=function() Win:Toggle() end,
})
KB:Get(); KB:Set(Enum.KeyCode.F4)
-- Click the pill to remap. Does NOT fire while a TextBox is focused.
```

### Color Picker
```lua
local CP = Tab:AddColorPicker({
    Name="ESP Color", Default=Color3.fromRGB(135,74,252), Id="esp",
    Callback=function(color) end,
})
CP:Get(); CP:Set(Color3.fromRGB(255,0,0))
```

### Progress Bar
```lua
local PB = Tab:AddProgressBar({ Name="Loading", Value=0 })
PB:Get(); PB:Set(75); PB:Animate(100, 2)  -- Animate(target, duration_seconds)
```

### Credit Footer
```lua
Tab:AddCredit("Made by YourName", "discord.gg/server")
```

---

## Notifications

```lua
Win:Notify({
    Title    = "Done",
    Desc     = "Operation complete",
    Duration = 4,
    Icon     = "rbxassetid://12345",  -- or plain text "!"
    Color    = Color3.fromRGB(66, 212, 130),
})

-- Also works before any window is created:
NexusUI:Notify({ Title="Hello", Duration=3 })
```

---

## Icons (MkIcon)

| Input | Result |
|-------|--------|
| `"N"` | TextLabel with that character |
| `"rbxassetid://123"` | ImageLabel — natural colours, preloaded |
| `"123456789"` | Auto-prefixed to `rbxassetid://` |
| `"rbxthumb://…"` | Thumbnail URL → ImageLabel |
| `{ Icon="…", NoTint=false, Scale="Crop" }` | Full table control |

Images default to `NoTint = true` and are preloaded via `ContentProvider:PreloadAsync` in a background thread so they always appear.

---

## Theme Customisation

```lua
NexusUI:SetTheme({
    Accent    = Color3.fromRGB(255, 80, 80),
    AccentHi  = Color3.fromRGB(255, 130, 130),
    AccentLo  = Color3.fromRGB(200, 40, 40),
})
```

---

## Config Save / Load

Any element with a non-empty `Id` participates in config saving.

```lua
Win:SaveConfig("slot1")   -- saves to NexusUI_<Title>_slot1.json
Win:LoadConfig("slot1")   -- loads and applies all saved values
Win:SaveConfig()           -- default slot = "default"
```

Supported types: `bool`, `number`, `string`, `multi` (table), `color`.

---

## Library Info

```lua
print(NexusUI.Version)  -- "2.3"
```
