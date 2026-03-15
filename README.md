# NexusUI — Roblox Luau UI Library

> A polished, animated, feature-rich UI framework for Roblox.
> Drop-in, zero-dependency. Supports **PC, Mobile and Tablet**.

---

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.6** | Drag inertia + viewport clamp, Pin button, 3 new elements (InputStepper / ToggleGroup / Badge), 5 new Window API methods, theme presets, 9 bug fixes |
| **v2.5** | Frame zi/clip swap fix (dropdowns visible), TweenCache GC fix, MkIcon NoTint fix, ColorPicker Set() ring, dropdown row signal leak, Keybind save/load, config keycode serialisation, Slider SetEnabled, Section/Separator return API |
| **v2.4** | Camera nil-guard, AbsoluteSize defer, idle drag early-exit, triple UI parenting fallback, notification cap (max 5), tween cancellation system |
| **v2.3** | Drag type-mismatch fix, UDim2.fromOffset, full connection cleanup, safer pcall, nil-safety guards |
| **v2.0** | Button spam fix, drag connection leak, Toggle/Dropdown visibility, checkmarks, chevrons, Slider Step, SetTheme, MultiDropdown search |
| **v1.0** | Initial release |

---

## v2.6 — What's New

### 🆕 New Elements

| Element | Description |
|---------|-------------|
| `AddInputStepper` | Numeric field with −/+ buttons, hold-to-repeat, and a direct-edit TextBox |
| `AddToggleGroup` | Mutually exclusive radio-button row; up to N options in a grid |
| `AddBadge` | Inline animated status pill — updates live with bounce animation |

### 🆕 New Window API Methods

| Method | Description |
|--------|-------------|
| `Win:SetPosition(x, y)` | Move the window programmatically (clamped to viewport) |
| `Win:GetPosition()` | Returns `x, y` pixel position |
| `Win:Resize(UDim2)` | Live-resize the window with animation |
| `Win:Pin()` / `Win:Unpin()` | Lock/unlock dragging via code |
| `Win:IsPinned()` | Returns `true` if drag is locked |

### 🆕 Theme Presets

```lua
NexusUI:ApplyPreset("Ocean")     -- deep blue
NexusUI:ApplyPreset("Crimson")   -- dark red
NexusUI:ApplyPreset("Forest")    -- dark green
NexusUI:ApplyPreset("Midnight")  -- cool grey-purple
NexusUI:ApplyPreset("Default")   -- original purple
```

---

## v2.6 — Bug Fixes

### Fix 1 — Default Subtitle Was "v2.4"
The `Subtitle` default string was never updated from v2.4. Windows created without an explicit subtitle showed the wrong version chip.

### Fix 2 — Minimize + Toggle Conflict
`Toggle()` always restored to `wSize`. Calling `Toggle()` while minimized caused the window to jump to full height instead of staying collapsed.

```lua
-- NEW: restore to the correct size
local restoreSize = minimized and UDim2.new(0, wSize.X.Offset, 0, 58) or wSize
FT(win, {Size=restoreSize, BackgroundTransparency=0}, 0.22)
```

### Fix 3 — Tab Icon Overlap
`AddTab(name, icon)` created a `Label` inside a `TextButton` that still had its own `.Text` property set. Both rendered simultaneously and drew over each other.

```lua
-- OLD: TextButton.Text = tabName + overlapping Label("icon")
-- NEW: compose a single string
local displayName = (tabIcon ~= "") and (tabIcon.." "..tabName) or tabName
btn.Text = displayName
```

### Fix 4 — `tw()` Crash on Nil/Destroyed Objects
The tween helper had no guard against destroyed instances. Any tween fired on a just-destroyed object threw a runtime error that could break the entire calling context.

```lua
-- NEW: pcall wraps TweenService:Create
local ok, tween = pcall(function()
    return TweenService:Create(o, TweenInfo.new(...), p)
end)
if not ok or not tween then return end
```

### Fix 5 — Slider Fired Through Other UI (Missing GPE Check)
`tBG.InputBegan` did not check the `GameProcessedEvent` flag. Clicking buttons in the game world could accidentally start a slider drag.

```lua
tBG.InputBegan:Connect(function(i, gpe)
    if gpe then return end   -- ← was missing
    ...
end)
```

### Fix 6 — Notification Slide-In Did Nothing
`UIListLayout` owns the `Position` property of every child. The `FT(card, {Position=...})` tween was silently overridden every frame. Cards popped in with no animation.

Fixed with a **clip-wrapper** whose height animates from `0 → cardH`:
```lua
local outer = Frame(NH, UDim2.new(1,0,0,0), ...)
outer.ClipsDescendants = true
-- card is full-height inside; wrapper expands to reveal it
FT(outer, {Size=UDim2.new(1,0,0,cardH+4)}, 0.22)
-- dismiss: shrink wrapper back to 0
FT(outer, {Size=UDim2.new(1,0,0,0)}, 0.18)
```

### Fix 7 — `AddCredit` Returned Nothing
Every other element returned a Wrap API. `AddCredit` was the only one that silently returned `nil`, making it impossible to hide or destroy the footer at runtime. Now returns a Wrap with `SetLine1(s)` and `SetLine2(s)`.

### Fix 8 — `AddTextBox` Missing `SetEnabled` + Added `FireOnChange`
`SetEnabled` was missing (Toggle and Slider had it). Added it alongside a new `FireOnChange` option that fires the callback on every keystroke rather than only on Enter.

```lua
Tab:AddTextBox({
    Name         = "Search",
    FireOnChange = true,          -- fires cb as you type
    Callback     = function(t) filterList(t) end,
})
```

### Fix 9 — Registry Window-Name Collision Now Warns
Creating two windows with the same `Title` would silently overwrite each other's element registry, breaking `SaveConfig`/`LoadConfig`. A `warn()` is now printed when this happens.

---

## Drag System — v2.6 Overhaul

### Inertia
Velocity is sampled over the last 6 move events. When the mouse is released the window coasts to a natural stop using a short `FT` tween.

### Viewport Clamp
The drag system now watches `workspace.CurrentCamera.ViewportSize` and the camera object itself. If the screen is resized or the device is rotated, the window snaps back inside bounds automatically with a smooth tween.

### Pin Button
A new **⬡** button appears in the title bar to the left of the minimize button. Click it to lock the window in place; click again to unlock. Pinned state is indicated with accent highlight and **⬟** glyph.

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusDevReal/NexusUI/refs/heads/main/NexusUI.lua"))()

-- Optional: apply a colour theme before creating any windows
NexusUI:ApplyPreset("Ocean")

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v2.6",
    Icon     = "rbxassetid://YOUR_ICON_ID",
    Size     = UDim2.new(0, 370, 0, 500),
})

local Tab = Win:AddTab("Main", "⚙")

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
    Subtitle = "v2.6",
    Icon     = "N",
    Size     = UDim2.new(0, 370, 0, 500),
    Position = UDim2.new(0.5, -185, 0.5, -250),
})
```

| Method | Description |
|--------|-------------|
| `Win:AddTab(name, icon?)` | Create a tab, returns Tab API |
| `Win:Toggle()` | Show or hide (respects minimized state) |
| `Win:IsVisible()` | Returns `true` if visible |
| `Win:Destroy()` | Animate-close and fully destroy |
| `Win:SetTitle(t)` | Change title text live |
| `Win:SetSubtitle(s)` | Change version chip text |
| `Win:Notify({...})` | Send a notification (max 5 at once) |
| `Win:SaveConfig(name?)` | Save all element values to JSON |
| `Win:LoadConfig(name?)` | Load and apply saved config |
| `Win:GetValue(id)` | Get value by element ID |
| `Win:SetValue(id, val)` | Set value by element ID |
| `Win:GetElement(id)` | Get full element API by ID |
| `Win:ListIds()` | Returns `{ [id] = type }` table |
| `Win:SetPosition(x, y)` | Move window (clamped to viewport) *(v2.6)* |
| `Win:GetPosition()` | Returns `x, y` pixel offsets *(v2.6)* |
| `Win:Resize(UDim2)` | Live resize with animation *(v2.6)* |
| `Win:Pin()` | Lock drag *(v2.6)* |
| `Win:Unpin()` | Unlock drag *(v2.6)* |
| `Win:IsPinned()` | Returns pin state *(v2.6)* |

---

## Elements

### Section / Separator
```lua
local Sec = Tab:AddSection("Combat")
local Sep = Tab:AddSeparator()
Sec:SetVisible(false); Sep:Destroy()
```

### Label
```lua
local L = Tab:AddLabel({ Text="Info", Color=Color3.fromRGB(200,200,255), Align="Center", Bold=true })
L:SetText("hi"); L:SetColor(Color3.new(1,1,1)); L:SetSize(16)
```

### Paragraph
```lua
local P = Tab:AddParagraph({ Title="About", Content="Long text here." })
P:SetTitle("T"); P:SetContent("C"); P:SetColor(Color3.new(1,1,1))
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
    Callback=function(v) end,
})
Tog:Get(); Tog:Set(true); Tog:Fire(); Tog:SetEnabled(false)
```

### Slider
```lua
local S = Tab:AddSlider({
    Name="Walk Speed", Min=16, Max=200, Default=16,
    Step=1, Suffix=" WS", Id="ws",
    Callback=function(v) end,
})
S:Get(); S:Set(50); S:SetMin(0); S:SetMax(500)
S:SetStep(0.5); S:SetSuffix("x"); S:SetEnabled(false)
```

### Input Stepper *(v2.6)*
```lua
local IS = Tab:AddInputStepper({
    Name="Jump Power", Min=0, Max=200, Default=50,
    Step=5, Suffix=" JP", Id="jp",
    Callback=function(v) end,
})
IS:Get(); IS:Set(100); IS:SetMin(0); IS:SetMax(500)
IS:SetStep(10); IS:SetSuffix("x"); IS:SetEnabled(false)
-- Hold −/+ for rapid repeat after 450ms
```

### Toggle Group *(v2.6)*
```lua
local TG = Tab:AddToggleGroup({
    Name="Team", Options={"Red","Blue","Green"},
    Default="Red", Id="team",
    Callback=function(v) end,
})
TG:Get(); TG:Set("Blue"); TG:SetEnabled(false)
```

### Badge *(v2.6)*
```lua
local BD = Tab:AddBadge({
    Name="Connection", Status="Online", Color=T.Green,
})
BD:Get()               -- returns current status text
BD:SetStatus("Away")   -- updates text with bounce animation
BD:SetColor(T.Yellow)  -- updates pill colour
BD:Set("Offline", T.Red)  -- update both at once
```

### Dropdown
```lua
local D = Tab:AddDropdown({
    Name="Mode", Items={"A","B","C"},
    Placeholder="Select...", Id="mode",
    Callback=function(v) end,
})
D:Get(); D:Set("B"); D:Clear(); D:IsEmpty(); D:IsSelected("B")
D:AddItem("D"); D:RemoveItem("A"); D:Refresh(list); D:SetPlaceholder("…")
-- Press Escape to close
```

### Multi Dropdown
```lua
local MD = Tab:AddMultiDropdown({
    Name="Effects", Items={"Blur","Bloom","Vignette"},
    Default={"Blur"}, Id="fx",
    Callback=function(t) end,
})
MD:Get(); MD:Set({"Blur","Bloom"}); MD:Clear(); MD:SelectAll()
MD:IsEmpty(); MD:IsSelected("Blur"); MD:AddItem("…"); MD:RemoveItem("…")
-- Press Escape to close
```

### TextBox
```lua
local TB = Tab:AddTextBox({
    Name="Player", Placeholder="Type here…",
    NumberOnly=false,
    FireOnChange=true,   -- v2.6: fires on every keystroke
    Id="txt",
    Callback=function(t) end,
})
TB:Get(); TB:Set("hi"); TB:Clear(); TB:Focus()
TB:SetPlaceholder("…"); TB:SetEnabled(false)   -- v2.6: SetEnabled added
```

### Keybind
```lua
local KB = Tab:AddKeybind({
    Name="Toggle UI", Default=Enum.KeyCode.RightShift,
    Id="toggleKey",
    Callback=function() Win:Toggle() end,
})
KB:Get(); KB:Set(Enum.KeyCode.F4)
```
> Keybind is now saved/loaded via `SaveConfig`/`LoadConfig` using the KeyCode Name string.

### Color Picker
```lua
local CP = Tab:AddColorPicker({
    Name="ESP Color", Default=Color3.fromRGB(135,74,252),
    Id="espColor",
    Callback=function(c) end,
})
CP:Get(); CP:Set(Color3.fromRGB(255,0,0))
```

### Progress Bar
```lua
local PB = Tab:AddProgressBar({ Name="Loading", Value=0 })
PB:Get(); PB:Set(75); PB:Animate(100, 2)
```

### Credit Footer
```lua
local C = Tab:AddCredit("Made by YourName", "discord.gg/server")
C:SetLine1("Updated Name")   -- v2.6: live edit
C:SetLine2("New link")
C:SetVisible(false); C:Destroy()
```

---

## Notifications

```lua
Win:Notify({
    Title="Done", Desc="Action complete",
    Duration=4, Icon="✓",
    Color=Color3.fromRGB(66,212,130),
})
NexusUI:Notify({ Title="Hello", Duration=3 })
```

- Max **5** visible at once; oldest is auto-dismissed at cap.
- v2.6: Slide-in is now a proper clip-wrapper height animation (Position tween fix).

---

## Theme

### Custom colours
```lua
NexusUI:SetTheme({
    Accent   = Color3.fromRGB(255, 80,  80),
    AccentHi = Color3.fromRGB(255, 130, 130),
})
```

### Presets *(v2.6)*
```lua
NexusUI:ApplyPreset("Default")   -- original purple
NexusUI:ApplyPreset("Ocean")     -- deep blue
NexusUI:ApplyPreset("Crimson")   -- dark red
NexusUI:ApplyPreset("Forest")    -- dark green
NexusUI:ApplyPreset("Midnight")  -- cool grey-purple
```
> Call `ApplyPreset` **before** `CreateWindow` to theme all elements.

---

## Config / Persistence

```lua
Win:SaveConfig("slot1")   -- NexusUI_<Title>_slot1.json
Win:LoadConfig("slot1")
Win:SaveConfig()           -- default slot
```

| Type | Stored as |
|------|-----------|
| Toggle | `boolean` |
| Slider | `number` |
| InputStepper | `number` *(v2.6)* |
| TextBox | `string` |
| Dropdown | `string` |
| Multi Dropdown | `string[]` |
| ToggleGroup | `string` *(v2.6)* |
| Color Picker | `{r,g,b}` table |
| Keybind | `string` (KeyCode name) |

---

## Icons

| Input | Result |
|-------|--------|
| `"N"` | Text character |
| `"rbxassetid://123"` | ImageLabel, natural colours, preloaded |
| `"123456789"` | Auto-prefixed to `rbxassetid://` |
| `"rbxthumb://..."` | Thumbnail URL |
| `{ Icon="…", NoTint=false, Scale="Crop" }` | Full table control |

---

## Library Info

```lua
print(NexusUI.Version)   -- "2.6"
```

