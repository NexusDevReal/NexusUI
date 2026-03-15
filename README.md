# NexusUI — Roblox Luau UI Library

> A polished, animated, feature-rich UI framework for Roblox.
> Drop-in, zero-dependency. Supports **PC, Mobile and Tablet**.

---

## Version History

| Version | Highlights |
|---------|-----------|
| **v2.4** | Camera nil-guard, AbsoluteSize defer, idle drag early-exit, triple UI parenting fallback, notification cap (max 5), tween cancellation system |
| **v2.3** | Drag type-mismatch fix, UDim2.fromOffset, full connection cleanup, safer pcall, nil-safety guards |
| **v2.1** | Mobile drag rewrite, brighter UIStrokes, UICorner on content pane, image preload fix |
| **v2.0** | Button spam fix, drag connection leak, Toggle/Dropdown visibility, checkmarks, chevrons, Slider Step, SetTheme, MultiDropdown search |
| **v1.0** | Initial release |

---

## v2.4 — Fix Details

### Fix 1 — CurrentCamera Can Be Nil

When scripts run very early after a player joins, workspace.CurrentCamera may not exist yet.
Indexing .ViewportSize on a nil value throws an error and kills drag permanently.

```lua
-- OLD: crashes on early load
local vp = workspace.CurrentCamera.ViewportSize

-- NEW: guarded
local cam = workspace.CurrentCamera
if not cam then return end
local vp = cam.ViewportSize
```

---

### Fix 2 — AbsoluteSize = 0 at Start

Before the first render frame, AbsoluteSize is Vector2(0,0). The clamp math
collapses the window to a screen corner on the very first drag.

The drag connection setup is now deferred one frame:
```lua
task.spawn(function()
    task.wait()  -- one render frame — layout resolves, sizes are valid
    -- drag connections set up here
end)
```
A secondary guard also skips doMove if size is still 0:
```lua
if winW == 0 or winH == 0 then return end
```

---

### Fix 3 — Global Listener Firing Every Frame While Idle

UIS.InputChanged fires many times per second. Without a check, the full
move body ran on every mouse movement even when nothing was being dragged.

```lua
-- NEW: return immediately when idle — zero cost
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    ...
end)
```

---

### Fix 4 — UI Parenting Can Produce a Nil Parent

Old code: if WaitForChild("PlayerGui", 10) timed out, the ScreenGui parent
was nil and the window was permanently invisible.

New triple-fallback:
```lua
-- 1st: CoreGui
local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not ok then
    -- 2nd: FindFirstChildOfClass (no yield)
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then
        -- 3rd: WaitForChild (5s max) then direct .PlayerGui
        local ok2, res = pcall(function()
            return LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
        pGui = (ok2 and res) or LocalPlayer.PlayerGui
    end
    sg.Parent = pGui
end
```
LocalPlayer.PlayerGui always exists — it is a guaranteed property.

---

### Fix 5 — Notifications Stack Forever

Calling Notify in a loop created hundreds of stacked cards with no cleanup.

Max 5 cap with auto-dismiss of the oldest:
```lua
local NOTIF_MAX = 5
while #NotifList >= NOTIF_MAX do
    local oldest = table.remove(NotifList, 1)
    if oldest and oldest.dismiss then oldest.dismiss() end
end
```

---

### Fix 6 — Overlapping Tweens on Spam Clicks

Creating a new tween on an object without cancelling the previous one caused
flickering, stuck colours and visual fighting.

TweenCache system — cancels before playing:
```lua
local TweenCache = {}

local function tw(o, p, t, style, dir)
    if TweenCache[o] then
        TweenCache[o]:Cancel()
        TweenCache[o] = nil
    end
    local tween = TweenService:Create(o, TweenInfo.new(t, style, dir), p)
    TweenCache[o] = tween
    tween:Play()
    tween.Completed:Connect(function()
        if TweenCache[o] == tween then TweenCache[o] = nil end
    end)
end
```

---

## Quick Start

```lua
local NexusUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Win = NexusUI:CreateWindow({
    Title    = "My Script",
    Subtitle = "v2.4",
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
    Subtitle = "v2.4",
    Icon     = "N",
    Size     = UDim2.new(0, 370, 0, 500),
    Position = UDim2.new(0.5, -185, 0.5, -250),
})
```

| Method | Description |
|--------|-------------|
| Win:AddTab(name) | Create tab, returns Tab API |
| Win:Toggle() | Show or hide the window |
| Win:IsVisible() | Returns true if visible |
| Win:Destroy() | Animate-close and fully destroy |
| Win:SetTitle(t) | Change title text live |
| Win:SetSubtitle(s) | Change version chip text |
| Win:Notify({...}) | Send a notification (max 5 at once) |
| Win:SaveConfig(name) | Save all element values to JSON |
| Win:LoadConfig(name) | Load and apply saved config |
| Win:GetValue(id) | Get value by element ID |
| Win:SetValue(id, val) | Set value by element ID |
| Win:GetElement(id) | Get full element API by ID |
| Win:ListIds() | Returns { [id] = type } table |

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
L:SetText("hi"); L:SetColor(Color3.new(1,1,1)); L:SetSize(16)
```

### Paragraph
```lua
local P = Tab:AddParagraph({ Title="About", Content="Long text." })
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
local Tog = Tab:AddToggle({ Name="Speed", Default=false, Id="speed", Callback=function(v) end })
Tog:Get(); Tog:Set(true); Tog:Fire(); Tog:SetEnabled(false)
```

### Slider
```lua
local S = Tab:AddSlider({ Name="WS", Min=16, Max=200, Default=16, Step=1, Suffix=" WS", Id="ws", Callback=function(v) end })
S:Get(); S:Set(50); S:SetMin(0); S:SetMax(500); S:SetStep(0.5); S:SetSuffix("x")
```

### Dropdown
```lua
local D = Tab:AddDropdown({ Name="Mode", Items={"A","B","C"}, Placeholder="Select...", Id="mode", Callback=function(v) end })
D:Get(); D:Set("B"); D:Clear(); D:IsEmpty(); D:IsSelected("B")
D:AddItem("D"); D:RemoveItem("A"); D:Refresh(list); D:SetPlaceholder("…")
```

### Multi Dropdown
```lua
local MD = Tab:AddMultiDropdown({ Name="FX", Items={"Blur","Bloom"}, Default={"Blur"}, Id="fx", Callback=function(t) end })
MD:Get(); MD:Set({"Blur"}); MD:Clear(); MD:SelectAll()
MD:IsEmpty(); MD:IsSelected("Blur"); MD:AddItem("Vignette"); MD:RemoveItem("Blur")
```

### TextBox
```lua
local TB = Tab:AddTextBox({ Name="Input", Placeholder="Type…", NumberOnly=false, Id="txt", Callback=function(t) end })
TB:Get(); TB:Set("hi"); TB:Clear(); TB:Focus(); TB:SetPlaceholder("…")
```

### Keybind
```lua
local KB = Tab:AddKeybind({ Name="Toggle UI", Default=Enum.KeyCode.RightShift, Callback=function() Win:Toggle() end })
KB:Get(); KB:Set(Enum.KeyCode.F4)
```

### Color Picker
```lua
local CP = Tab:AddColorPicker({ Name="ESP", Default=Color3.fromRGB(135,74,252), Id="esp", Callback=function(c) end })
CP:Get(); CP:Set(Color3.fromRGB(255,0,0))
```

### Progress Bar
```lua
local PB = Tab:AddProgressBar({ Name="Loading", Value=0 })
PB:Get(); PB:Set(75); PB:Animate(100, 2)
```

### Credit Footer
```lua
Tab:AddCredit("Made by YourName", "discord.gg/server")
```

---

## Notifications

```lua
Win:Notify({ Title="Done", Desc="Complete", Duration=4, Icon="rbxassetid://123", Color=Color3.fromRGB(66,212,130) })
NexusUI:Notify({ Title="Hello", Duration=3 })  -- works before any window exists
```

Max 5 notifications visible at once. Oldest is auto-dismissed when cap is hit.

---

## Icons

| Input | Result |
|-------|--------|
| "N" | TextLabel with that character |
| "rbxassetid://123" | ImageLabel, natural colours, preloaded |
| "123456789" | Auto-prefixed to rbxassetid:// |
| "rbxthumb://…" | Thumbnail URL, ImageLabel |
| { Icon="…", NoTint=false, Scale="Crop" } | Full table control |

---

## Theme

```lua
NexusUI:SetTheme({ Accent=Color3.fromRGB(255,80,80), AccentHi=Color3.fromRGB(255,130,130) })
```

---

## Config

```lua
Win:SaveConfig("slot1")   -- NexusUI_<Title>_slot1.json
Win:LoadConfig("slot1")
Win:SaveConfig()           -- default slot name
```

---

## Library Info

```lua
print(NexusUI.Version)   -- "2.4"
```
