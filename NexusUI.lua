--[[
╔══════════════════════════════════════════════════════════════╗
║  NexusUI  v2.1  —  Roblox Luau UI Library                    ║
╠══════════════════════════════════════════════════════════════╣
║  v2.1 — Polish & mobile update:                             ║
║                                                              ║
║  • Drag completely rewritten — proper touch-ID tracking,    ║
║    InputEnded on both handle AND UIS, multi-touch safe,     ║
║    cleanup returns a :Disconnect()-compatible object        ║
║  • UICorner added to contentArea (rounded content pane)     ║
║  • Close button uses plain "x" (correct legacy style)       ║
║  • UIStroke colours significantly brightened — all borders  ║
║    are now clearly visible at a glance                      ║
║  • Default Stroke thickness raised 1 → 1.5                  ║
║  • rbxassetid / URL images: NoTint defaults TRUE so images  ║
║    always show natural colours; ContentProvider:PreloadAsync ║
║    called in background so assets actually appear           ║
║  • Image default size changed to UDim2(1,0,1,0) — fills    ║
║    parent, ScaleType.Fit keeps aspect ratio                 ║
║  • NexusUI.Version = "2.1"                                   ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ─────────────────────────────────────────────────────────────
--  SERVICES
-- ─────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

-- ─────────────────────────────────────────────────────────────
--  THEME
-- ─────────────────────────────────────────────────────────────
local T = {
	BG         = Color3.fromRGB( 13,  10,  28),
	Surface    = Color3.fromRGB( 22,  17,  44),
	SurfaceHi  = Color3.fromRGB( 32,  25,  58),
	SurfaceHi2 = Color3.fromRGB( 44,  35,  76),
	Border     = Color3.fromRGB( 90,  70, 148),   -- was 55,42,92  — now clearly visible
	BorderBri  = Color3.fromRGB(128,  98, 195),   -- was 88,66,144
	BorderGlow = Color3.fromRGB(160, 118, 242),   -- was 108,78,198

	Accent     = Color3.fromRGB(135,  74, 252),
	AccentHi   = Color3.fromRGB(165, 114, 255),
	AccentLo   = Color3.fromRGB( 92,  46, 202),
	AccentDeep = Color3.fromRGB( 60,  28, 148),

	TxtMain    = Color3.fromRGB(240, 234, 255),
	TxtSub     = Color3.fromRGB(154, 138, 200),
	TxtMute    = Color3.fromRGB( 88,  73, 124),
	TxtOff     = Color3.fromRGB( 52,  42,  80),

	Green      = Color3.fromRGB( 66, 212, 130),
	Red        = Color3.fromRGB(246,  62,  90),
	Yellow     = Color3.fromRGB(250, 186,  50),
	Blue       = Color3.fromRGB( 50, 170, 252),

	TogOff     = Color3.fromRGB( 42,  33,  68),
	NotifBG    = Color3.fromRGB( 18,  13,  38),
	White      = Color3.fromRGB(255, 255, 255),
	Black      = Color3.fromRGB(  0,   0,   0),
}

-- ─────────────────────────────────────────────────────────────
--  TWEEN HELPERS
-- ─────────────────────────────────────────────────────────────
local function tw(o, p, t, style, dir)
	TweenService:Create(o,
		TweenInfo.new(t or 0.18,
			style or Enum.EasingStyle.Quart,
			dir   or Enum.EasingDirection.Out), p):Play()
end
local function FT(o, p, t) tw(o, p, t, Enum.EasingStyle.Quart,   Enum.EasingDirection.Out) end
local function ST(o, p, t) tw(o, p, t, Enum.EasingStyle.Back,    Enum.EasingDirection.Out) end
local function LT(o, p, t) tw(o, p, t, Enum.EasingStyle.Linear,  Enum.EasingDirection.Out) end
local function ET(o, p, t) tw(o, p, t, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out) end

-- ─────────────────────────────────────────────────────────────
--  UI PRIMITIVES
-- ─────────────────────────────────────────────────────────────
local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p; return c
end

local function Stroke(p, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or T.Border; s.Thickness = thick or 1.5   -- raised default 1→1.5
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p; return s
end

local function Pad(p, top, bot, left, right)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, top   or 8)
	u.PaddingBottom = UDim.new(0, bot   or 8)
	u.PaddingLeft   = UDim.new(0, left  or 10)
	u.PaddingRight  = UDim.new(0, right or 10)
	u.Parent = p; return u
end

local function Frame(parent, size, pos, color, zi, clip)
	local f = Instance.new("Frame")
	f.Size             = size  or UDim2.new(1,0,0,40)
	f.Position         = pos   or UDim2.new(0,0,0,0)
	f.BackgroundColor3 = color or T.Surface
	f.BorderSizePixel  = 0
	f.ClipsDescendants = clip or false
	if zi then f.ZIndex = zi end
	f.Parent = parent; return f
end

local function Label(parent, text, sz, col, font, xa, ya, wrap)
	local l = Instance.new("TextLabel")
	l.Text       = text or ""; l.TextSize = sz or 13
	l.TextColor3 = col  or T.TxtMain
	l.Font       = font or Enum.Font.GothamBold
	l.BackgroundTransparency = 1; l.BorderSizePixel = 0
	l.Size = UDim2.new(1,0,1,0)
	l.TextXAlignment = xa or Enum.TextXAlignment.Left
	l.TextYAlignment = ya or Enum.TextYAlignment.Center
	l.TextWrapped = wrap or false; l.RichText = false
	l.Parent = parent; return l
end

local function Button(parent, text, sz, bg, tc, font)
	local b = Instance.new("TextButton")
	b.Text = text or ""; b.TextSize = sz or 13
	b.TextColor3 = tc or T.TxtMain
	b.BackgroundColor3 = bg or T.SurfaceHi
	b.Font = font or Enum.Font.GothamBold
	b.BorderSizePixel = 0; b.AutoButtonColor = false
	b.Size = UDim2.new(1,0,1,0)
	b.Parent = parent; return b
end

-- Glass top-shine (subtle depth line on cards)
local function Shine(card)
	local s = Frame(card, UDim2.new(1,-6,0,1), UDim2.new(0,3,0,1), T.White)
	s.BackgroundTransparency = 0.88
	s.ZIndex = (card.ZIndex or 4) + 1
	Corner(s, 2)
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   1),
		NumberSequenceKeypoint.new(0.1, 0.88),
		NumberSequenceKeypoint.new(0.5, 0.82),
		NumberSequenceKeypoint.new(0.9, 0.88),
		NumberSequenceKeypoint.new(1,   1),
	})
	g.Parent = s; return s
end

-- ─────────────────────────────────────────────────────────────
--  MkIcon  — text OR Roblox image asset, auto-detected
--
--  iconArg can be:
--    "W"                        plain ASCII → TextLabel
--    "rbxassetid://123456789"   full URL    → ImageLabel (shows natural colours)
--    "123456789"                numeric ID  → ImageLabel
--    "rbxthumb://..."           thumb URL   → ImageLabel
--    { Icon=, Color=, Size=,
--      NoTint=bool, Trans=0,
--      Scale="Fit"|"Crop"|"Stretch" }
--
--  IMAGE FIX: NoTint now defaults TRUE for image assets so they
--  always render with their natural colours. ContentProvider
--  is PreloadAsync'd in a background coroutine so the asset
--  actually appears instead of staying blank.
-- ─────────────────────────────────────────────────────────────
local ContentProvider = game:GetService("ContentProvider")
local ScaleMap = {
	Fit     = Enum.ScaleType.Fit,
	Crop    = Enum.ScaleType.Crop,
	Stretch = Enum.ScaleType.Stretch,
}

local function resolveAsset(s)
	if type(s) ~= "string" or s == "" then return false, nil end
	if s:match("^rbxassetid://%d+$") then return true, s end
	if s:match("^rbxthumb://")        then return true, s end
	if s:match("^rbxgameasset://")    then return true, s end
	if s:match("^%d+$")              then return true, "rbxassetid://"..s end
	return false, nil
end

local function MkIcon(parent, iconArg, defSize, defColor, defImgSize, defZi)
	local icon, color, imgSize, noTint, trans, scale, tSize, font, zi
	if type(iconArg) == "table" then
		local o = iconArg
		icon    = tostring(o.Icon or "")
		color   = o.Color    or defColor or T.White
		imgSize = o.Size     or defImgSize or UDim2.new(1,0,1,0)
		noTint  = (o.NoTint ~= nil) and o.NoTint or true  -- default TRUE for images
		trans   = o.Trans    or 0
		scale   = o.Scale    or "Fit"
		tSize   = o.TextSize or defSize or 18
		font    = o.Font     or Enum.Font.GothamBold
		zi      = o.ZIndex   or defZi or 4
	else
		icon    = tostring(iconArg or "")
		color   = defColor  or T.White
		imgSize = defImgSize or UDim2.new(1,0,1,0)  -- fill parent, Fit keeps aspect ratio
		noTint  = true   -- FIX: images show natural colours by default
		trans   = 0; scale = "Fit"
		tSize   = defSize or 18
		font    = Enum.Font.GothamBold
		zi      = defZi or 4
	end

	local isImg, url = resolveAsset(icon)
	if isImg then
		local img = Instance.new("ImageLabel")
		img.Image               = url
		img.BackgroundTransparency = 1; img.BorderSizePixel = 0
		img.Size                = imgSize
		img.AnchorPoint         = Vector2.new(0.5, 0.5)
		img.Position            = UDim2.new(0.5, 0, 0.5, 0)
		img.ImageColor3         = noTint and Color3.fromRGB(255,255,255) or color
		img.ImageTransparency   = trans
		img.ScaleType           = ScaleMap[scale] or Enum.ScaleType.Fit
		img.ZIndex              = zi
		img.Parent              = parent

		-- FIX: preload in background so the texture actually renders
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync({img})
			end)
		end)
		return img
	else
		local lbl = Label(parent, icon, tSize, color, font,
			Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
		lbl.ZIndex = zi; return lbl
	end
end

-- ─────────────────────────────────────────────────────────────
--  DRAG  (mouse + touch) — v2.1 rewrite
--
--  Improvements:
--    • Touch ID tracked explicitly — only the finger that
--      started the drag moves the window (multi-touch safe)
--    • InputEnded listened on BOTH the handle AND UIS so
--      the drag always ends even if the finger lifts outside
--    • handle.InputChanged catches movement while still inside
--      the handle; UIS.InputChanged catches it anywhere else
--    • Returns an object with :Disconnect() so the caller
--      can clean up both global connections on destroy
-- ─────────────────────────────────────────────────────────────
local function MakeDraggable(win, handle)
	handle = handle or win
	local dragging  = false
	local dragStart = nil   -- Vector3: position where drag began
	local startPos  = nil   -- UDim2:   win.Position when drag began
	local activeInput = nil -- the specific Input object being tracked

	local function clampedMove(input)
		if not dragging or not dragStart or not startPos then return end
		local delta = input.Position - dragStart
		local vp    = workspace.CurrentCamera.ViewportSize
		local winW  = win.AbsoluteSize.X
		local winH  = win.AbsoluteSize.Y
		local newX  = math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, vp.X - winW))
		local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, vp.Y - winH))
		win.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
	end

	local function beginDrag(input)
		-- Accept the FIRST mouse or touch that hits the handle
		local t = input.UserInputType
		if dragging then return end
		if t == Enum.UserInputType.MouseButton1
		or t == Enum.UserInputType.Touch then
			dragging    = true
			activeInput = input
			dragStart   = input.Position
			startPos    = win.Position
		end
	end

	local function endDrag(input)
		if input == activeInput then
			dragging    = false
			activeInput = nil
			dragStart   = nil
		end
	end

	-- Begin: touch or mouse down on the handle
	handle.InputBegan:Connect(beginDrag)

	-- Move: handle-local (works while finger/cursor is over handle)
	handle.InputChanged:Connect(function(input)
		if input == activeInput then clampedMove(input) end
	end)

	-- Move: global fallback (finger/cursor moved outside the handle)
	local globalMoveCon = UserInputService.InputChanged:Connect(function(input)
		if input == activeInput then clampedMove(input) end
	end)

	-- End: local (finger lifted inside handle)
	handle.InputEnded:Connect(endDrag)

	-- End: global (finger lifted anywhere — most important for mobile)
	local globalEndCon = UserInputService.InputEnded:Connect(endDrag)

	-- Return a :Disconnect()-compatible object
	return {
		Disconnect = function()
			globalMoveCon:Disconnect()
			globalEndCon:Disconnect()
		end
	}
end

-- ─────────────────────────────────────────────────────────────
--  SAFE CALLBACK
-- ─────────────────────────────────────────────────────────────
local function Call(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[NexusUI] callback error: "..tostring(err)) end
end

-- ─────────────────────────────────────────────────────────────
--  CONFIG REGISTRY  { [winName] = { [id] = {Get,Set,Type,API} } }
-- ─────────────────────────────────────────────────────────────
local Registry = {}

local function Reg(wName, id, getter, setter, elType, api)
	if not id or id == "" then return end
	if not Registry[wName] then Registry[wName] = {} end
	Registry[wName][id] = {Get=getter, Set=setter, Type=elType, API=api}
end

local function EncC(c)
	return {r=math.round(c.R*255), g=math.round(c.G*255), b=math.round(c.B*255)}
end
local function DecC(t) return Color3.fromRGB(t.r, t.g, t.b) end

-- ─────────────────────────────────────────────────────────────
--  LIBRARY TABLE
-- ─────────────────────────────────────────────────────────────
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.MkIcon  = MkIcon
NexusUI.Version = "2.1"

-- IMPROVEMENT: allow callers to patch any theme color at runtime
--   e.g. NexusUI:SetTheme({ Accent = Color3.fromRGB(255,100,100) })
function NexusUI:SetTheme(overrides)
	if type(overrides) ~= "table" then return end
	for k, v in pairs(overrides) do
		if T[k] ~= nil then T[k] = v end
	end
end

-- ─────────────────────────────────────────────────────────────
--  NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────
local NH = nil   -- notification holder, one per session

local function InitNH(sg)
	if NH and NH.Parent == sg then return end
	if NH then NH:Destroy() end
	NH = Instance.new("Frame")
	NH.Name = "NexusNotifs"; NH.BackgroundTransparency = 1
	NH.BorderSizePixel = 0
	NH.Size     = UDim2.new(0, 290, 1, -20)
	NH.Position = UDim2.new(1, -298, 0, 10)
	NH.ZIndex   = 200; NH.Parent = sg
	local ul = Instance.new("UIListLayout")
	ul.FillDirection     = Enum.FillDirection.Vertical
	ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ul.SortOrder         = Enum.SortOrder.LayoutOrder
	ul.Padding           = UDim.new(0, 8)
	ul.Parent            = NH
end

-- FIX: if called before any window is created, auto-init a fallback ScreenGui
local function EnsureNH()
	if NH and NH.Parent then return end
	local sg = Instance.new("ScreenGui")
	sg.Name           = "NexusUI_NotifFallback"
	sg.ResetOnSpawn   = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder   = 999
	sg.IgnoreGuiInset = true
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok then
		sg.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
			or LocalPlayer:WaitForChild("PlayerGui", 10)
	end
	InitNH(sg)
end

function NexusUI:Notify(opt)
	opt = opt or {}
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	local icon   = opt.Icon     or "!"
	local accent = opt.Color    or T.Accent

	-- FIX: auto-create fallback holder instead of silently returning
	EnsureNH()
	if not NH then return end

	-- Card
	local card = Frame(NH, UDim2.new(1,0,0,72), UDim2.new(1,20,0,0), T.NotifBG)
	card.ZIndex = 200
	Corner(card, 12); Stroke(card, accent, 1, 0.3); Shine(card)

	-- Left bar
	local bar = Frame(card, UDim2.new(0,4,1,-16), UDim2.new(0,0,0,8), accent)
	bar.ZIndex = 201; Corner(bar, 3)
	do
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accent),
			ColorSequenceKeypoint.new(1, T.AccentDeep),
		})
		g.Rotation = 90; g.Parent = bar
	end

	-- Icon bubble
	local icBox = Frame(card, UDim2.new(0,36,0,36), UDim2.new(0,12,0.5,-18), T.SurfaceHi)
	icBox.ZIndex = 201; Corner(icBox, 10); Stroke(icBox, accent, 1, 0.4)
	MkIcon(icBox, icon, 15, accent, UDim2.new(0.68,0,0.68,0), 202)

	-- Title
	local tl = Instance.new("TextLabel")
	tl.Text = title; tl.TextSize = 13; tl.Font = Enum.Font.GothamBold
	tl.TextColor3 = T.TxtMain; tl.BackgroundTransparency = 1
	tl.BorderSizePixel = 0
	tl.Size = UDim2.new(1,-74,0,20); tl.Position = UDim2.new(0,56,0,11)
	tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 201; tl.Parent = card

	-- Desc
	if desc ~= "" then
		local dl = Instance.new("TextLabel")
		dl.Text = desc; dl.TextSize = 11; dl.Font = Enum.Font.Gotham
		dl.TextColor3 = T.TxtSub; dl.BackgroundTransparency = 1
		dl.BorderSizePixel = 0
		dl.Size = UDim2.new(1,-74,0,18); dl.Position = UDim2.new(0,56,0,33)
		dl.TextXAlignment = Enum.TextXAlignment.Left
		dl.TextWrapped = true; dl.ZIndex = 201; dl.Parent = card
	end

	-- Close
	local xb = Instance.new("TextButton")
	xb.Text = "x"; xb.TextSize = 12; xb.Font = Enum.Font.GothamBold
	xb.TextColor3 = T.TxtMute; xb.BackgroundTransparency = 1
	xb.BorderSizePixel = 0
	xb.Size = UDim2.new(0,18,0,18); xb.Position = UDim2.new(1,-22,0,5)
	xb.ZIndex = 202; xb.Parent = card
	xb.MouseEnter:Connect(function() FT(xb,{TextColor3=T.Red},0.1) end)
	xb.MouseLeave:Connect(function() FT(xb,{TextColor3=T.TxtMute},0.1) end)

	-- Progress bar
	local pgBg = Frame(card, UDim2.new(1,-18,0,3), UDim2.new(0,9,1,-8), T.SurfaceHi)
	pgBg.ZIndex = 201; Corner(pgBg, 2)
	local pgFill = Frame(pgBg, UDim2.new(1,0,1,0), nil, accent)
	pgFill.ZIndex = 202; Corner(pgFill, 2)
	LT(pgFill, {Size=UDim2.new(0,0,1,0)}, dur)

	-- Slide in
	FT(card, {Position=UDim2.new(0,0,0,0)}, 0.25)

	-- Dismiss
	local gone = false
	local function Dismiss()
		if gone then return end; gone = true
		FT(card, {Position=UDim2.new(1,20,0,0), BackgroundTransparency=1}, 0.20)
		task.delay(0.22, function()
			if card and card.Parent then card:Destroy() end
		end)
	end
	xb.MouseButton1Click:Connect(Dismiss)
	task.delay(dur, Dismiss)
	return card
end

-- ─────────────────────────────────────────────────────────────
--  CREATE WINDOW
-- ─────────────────────────────────────────────────────────────
function NexusUI:CreateWindow(opt)
	opt = opt or {}
	local wTitle  = opt.Title    or "NexusUI"
	local wSub    = opt.Subtitle or "v2.1"
	local wIcon   = opt.Icon     or "N"
	local wSize   = opt.Size     or UDim2.new(0,370,0,500)
	local wPos    = opt.Position or UDim2.new(0.5,-185,0.5,-250)
	local wName   = wTitle

	-- ── ScreenGui ────────────────────────────────────────────
	local sg = Instance.new("ScreenGui")
	sg.Name           = "NexusUI_"..wTitle
	sg.ResetOnSpawn   = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder   = 999
	sg.IgnoreGuiInset = true

	-- Try CoreGui, fall back to PlayerGui
	local parentOk = pcall(function()
		sg.Parent = game:GetService("CoreGui")
	end)
	if not parentOk then
		sg.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
			or LocalPlayer:WaitForChild("PlayerGui", 10)
	end

	-- Notification holder
	InitNH(sg)

	-- ── Main window ──────────────────────────────────────────
	local win = Frame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)
	Stroke(win, Color3.fromRGB(80,50,158), 1.5)

	-- Top glow edge
	local topGlow = Frame(win, UDim2.new(1,-6,0,1), UDim2.new(0,3,0,0),
		Color3.fromRGB(145,94,252))
	topGlow.BackgroundTransparency = 0.55; topGlow.ZIndex = 10

	-- ── Title bar ────────────────────────────────────────────
	local tb = Frame(win, UDim2.new(1,0,0,58), nil, T.Surface)
	Corner(tb, 16)
	Frame(tb, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Surface)

	do
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(50,32,92)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(32,22,62)),
			ColorSequenceKeypoint.new(1,   T.Surface),
		})
		g.Rotation = 90; g.Parent = tb
	end

	-- Separator at base of title bar
	do
		local sep = Frame(tb, UDim2.new(1,-28,0,1), UDim2.new(0,14,1,-1),
			Color3.fromRGB(76,54,116))
		sep.BackgroundTransparency = 0.55; sep.ZIndex = 5
		local g = Instance.new("UIGradient")
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,   1),
			NumberSequenceKeypoint.new(0.1, 0.55),
			NumberSequenceKeypoint.new(0.9, 0.55),
			NumberSequenceKeypoint.new(1,   1),
		})
		g.Parent = sep
	end

	-- FIX: store the drag global connection so we can clean it up on destroy
	local dragCon = MakeDraggable(win, tb)

	-- Icon pill
	local iconPill = Frame(tb, UDim2.new(0,40,0,40), UDim2.new(0,12,0.5,-20), T.AccentLo)
	Corner(iconPill,12); Stroke(iconPill, T.AccentHi, 1.5, 0.22)
	do
		local sh = Frame(iconPill, UDim2.new(1,-4,0,12), UDim2.new(0,2,0,2), T.White)
		sh.BackgroundTransparency = 0.84; Corner(sh,6)
		local g = Instance.new("UIGradient")
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,  0.84),
			NumberSequenceKeypoint.new(0.5,0.78),
			NumberSequenceKeypoint.new(1,  0.84),
		}); g.Parent = sh
	end
	do
		local glow = Frame(tb, UDim2.new(0,50,0,50), UDim2.new(0,7,0.5,-25), T.Accent)
		glow.BackgroundTransparency = 0.82; Corner(glow,15); glow.ZIndex = 2
	end
	MkIcon(iconPill, wIcon, 19, T.White, UDim2.new(0.7,0,0.7,0), 4)

	-- Title + version chip
	local titleLbl = Label(tb, wTitle, 15, T.TxtMain, Enum.Font.GothamBold)
	titleLbl.Size = UDim2.new(1,-158,0,22); titleLbl.Position = UDim2.new(0,62,0,9)

	local vc = Frame(tb, UDim2.new(0,0,0,17), UDim2.new(0,62,0,32), T.AccentDeep)
	vc.AutomaticSize = Enum.AutomaticSize.X; Corner(vc,6); Stroke(vc,T.Accent,1,0.5)
	local subtitleLbl
	do
		subtitleLbl = Label(vc, wSub, 10, T.AccentHi, Enum.Font.GothamBold,
			Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
		subtitleLbl.Size = UDim2.new(1,0,1,0); Pad(vc,0,0,7,7)
	end

	-- Control buttons helper
	local function CtrlBtn(xOff, col)
		local box = Frame(tb, UDim2.new(0,26,0,26), UDim2.new(1,xOff,0.5,-13), col)
		Corner(box, 8)
		local bb = Button(box,"",0,T.Black,T.White)
		bb.BackgroundTransparency = 1; bb.Size = UDim2.new(1,0,1,0)
		bb.MouseEnter:Connect(function() FT(box,{Size=UDim2.new(0,28,0,28)},0.12) end)
		bb.MouseLeave:Connect(function() FT(box,{Size=UDim2.new(0,26,0,26)},0.12) end)
		return box, bb
	end

	-- Close
	local cBox, cBB = CtrlBtn(-36, T.Red)
	Label(cBox,"x",12,T.White,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	cBB.MouseEnter:Connect(function() FT(cBox,{BackgroundColor3=Color3.fromRGB(255,42,70)},0.12) end)
	cBB.MouseLeave:Connect(function() FT(cBox,{BackgroundColor3=T.Red},0.12) end)
	cBB.MouseButton1Click:Connect(function()
		FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,0),BackgroundTransparency=1},0.22)
		task.delay(0.24, function()
			dragCon:Disconnect()  -- FIX: clean up global drag connection
			if Registry[wName] then Registry[wName] = nil end
			if sg and sg.Parent then sg:Destroy() end
		end)
	end)

	-- Minimize
	local mBox, mBB = CtrlBtn(-66, T.SurfaceHi)
	Stroke(mBox, T.Border, 1)
	local mLbl = Label(mBox,"−",14,T.TxtSub,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	mBB.MouseEnter:Connect(function() FT(mBox,{BackgroundColor3=T.SurfaceHi2},0.12) end)
	mBB.MouseLeave:Connect(function() FT(mBox,{BackgroundColor3=T.SurfaceHi},0.12) end)

	-- ── Body ─────────────────────────────────────────────────
	local body = Frame(win, UDim2.new(1,0,1,-58), UDim2.new(0,0,0,58), T.BG, true, 2)
	Corner(body, 16)
	Frame(body, UDim2.new(1,0,0,16), nil, T.BG)

	-- Bottom accent strip
	do
		local bot = Frame(win, UDim2.new(1,-4,0,4), UDim2.new(0,2,1,-4),
			Color3.fromRGB(74,50,138))
		bot.BackgroundTransparency = 0.60; bot.ZIndex = 3; Corner(bot, 4)
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,  T.AccentDeep),
			ColorSequenceKeypoint.new(0.5,T.Accent),
			ColorSequenceKeypoint.new(1,  T.AccentDeep),
		}); g.Parent = bot
	end

	-- ── Minimize logic ───────────────────────────────────────
	local minimized = false
	mBB.MouseButton1Click:Connect(function()
		minimized = not minimized
		FT(win, {Size = minimized and UDim2.new(0,wSize.X.Offset,0,58) or wSize}, 0.26)
		mLbl.Text = minimized and "+" or "−"
	end)

	-- ── Tab bar ──────────────────────────────────────────────
	local tabBar = Frame(body, UDim2.new(1,-20,0,34), UDim2.new(0,10,0,12), T.SurfaceHi, false, 3)
	Corner(tabBar, 10); Stroke(tabBar, T.Border, 1)

	-- Sliding active-tab indicator
	local tabInd = Frame(tabBar, UDim2.new(0,10,0,26), UDim2.new(0,4,0.5,-13), T.Accent)
	tabInd.ZIndex = 3; Corner(tabInd, 8)
	do
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, T.AccentHi),
			ColorSequenceKeypoint.new(1, T.AccentLo),
		}); g.Rotation = 90; g.Parent = tabInd
	end

	local tabLL = Instance.new("UIListLayout")
	tabLL.FillDirection     = Enum.FillDirection.Horizontal
	tabLL.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLL.SortOrder         = Enum.SortOrder.LayoutOrder
	tabLL.Padding           = UDim.new(0,4)
	tabLL.Parent            = tabBar
	Pad(tabBar, 3,3,4,4)

	-- Content area
	local contentArea = Frame(body, UDim2.new(1,0,1,-62), UDim2.new(0,0,0,62), T.BG, false, 3)
	Corner(contentArea, 12)  -- rounded content pane

	-- Dropdown overlay — above content, never clips dropdowns
	local overlay = Frame(body, UDim2.new(1,0,1,-62), UDim2.new(0,0,0,62), T.Black, false, 50)
	overlay.BackgroundTransparency = 1

	local tabs      = {}
	local activeTab = nil

	-- ═══════════════════════════════════════════════════════
	--  WINDOW API
	-- ═══════════════════════════════════════════════════════
	local WinAPI = {}

	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	-- IMPROVEMENT: programmatic title/subtitle setters
	function WinAPI:SetTitle(t)
		titleLbl.Text = tostring(t or "")
	end
	function WinAPI:SetSubtitle(s)
		subtitleLbl.Text = tostring(s or "")
	end

	-- FIX: WinAPI:Destroy now also disconnects the drag connection
	function WinAPI:Destroy()
		FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,0),BackgroundTransparency=1},0.22)
		task.delay(0.25, function()
			dragCon:Disconnect()
			if Registry[wName] then Registry[wName] = nil end
			if sg and sg.Parent then sg:Destroy() end
		end)
	end

	local hidden = false
	-- FIX: properly hide/show — set Visible so the window isn't hit-testable at 0 size
	function WinAPI:Toggle()
		hidden = not hidden
		if hidden then
			FT(win, {Size=UDim2.new(0,wSize.X.Offset,0,0), BackgroundTransparency=1}, 0.22)
			task.delay(0.23, function()
				if win and win.Parent then win.Visible = false end
			end)
		else
			win.Visible = true
			FT(win, {Size=wSize, BackgroundTransparency=0}, 0.22)
		end
	end

	-- IMPROVEMENT: query visibility state
	function WinAPI:IsVisible()
		return not hidden
	end

	function WinAPI:SaveConfig(name)
		name = name or "default"
		local reg = Registry[wName]
		if not reg then
			warn("[NexusUI] No registered IDs for window '"..wName.."'"); return
		end
		local data = {}
		for id, e in pairs(reg) do
			local v = e.Get()
			data[id] = e.Type == "color" and EncC(v) or v
		end
		local json = HttpService:JSONEncode(data)
		local path = "NexusUI_"..wName.."_"..name..".json"
		local ok = pcall(writefile, path, json)
		if ok then
			self:Notify({Title="Config Saved",Desc=path,Duration=3,Icon="✓",Color=T.Green})
		else
			print("[NexusUI] Config:\n"..json)
			self:Notify({Title="Saved (print fallback)",Duration=3,Icon="!",Color=T.Yellow})
		end
	end

	function WinAPI:LoadConfig(name)
		name = name or "default"
		local reg = Registry[wName]
		if not reg then
			warn("[NexusUI] No registered IDs for window '"..wName.."'"); return
		end
		local path = "NexusUI_"..wName.."_"..name..".json"
		local ok, json = pcall(readfile, path)
		if not ok or not json then
			self:Notify({Title="Config Not Found",Desc=path,Duration=3,Icon="!",Color=T.Red})
			return
		end
		local data = HttpService:JSONDecode(json)
		for id, val in pairs(data) do
			local e = reg[id]
			if e then
				pcall(function()
					e.Set(e.Type == "color" and DecC(val) or val)
				end)
			end
		end
		self:Notify({Title="Config Loaded",Desc=path,Duration=3,Icon="✓",Color=T.Green})
	end

	function WinAPI:GetValue(id)
		local reg = Registry[wName]
		if reg and reg[id] then return reg[id].Get() end
		warn("[NexusUI] GetValue: unknown Id '"..tostring(id).."'")
	end

	function WinAPI:SetValue(id, val)
		local reg = Registry[wName]
		if reg and reg[id] then
			local e = reg[id]
			pcall(function()
				e.Set(e.Type=="color" and (type(val)=="table" and DecC(val) or val) or val)
			end)
		else
			warn("[NexusUI] SetValue: unknown Id '"..tostring(id).."'")
		end
	end

	function WinAPI:GetElement(id)
		local reg = Registry[wName]
		if reg and reg[id] then return reg[id].API end
		warn("[NexusUI] GetElement: unknown Id '"..tostring(id).."'")
	end

	function WinAPI:ListIds()
		local reg = Registry[wName] or {}
		local out = {}
		for id, e in pairs(reg) do out[id] = e.Type end
		return out
	end

	-- ═══════════════════════════════════════════════════════
	--  ADD TAB
	-- ═══════════════════════════════════════════════════════
	function WinAPI:AddTab(tabName, tabIcon)
		-- Tab button
		local btn = Instance.new("TextButton")
		btn.Text = tabName; btn.TextSize = 12
		btn.Font = Enum.Font.GothamSemibold
		btn.TextColor3 = T.TxtMute
		btn.BackgroundColor3 = T.Black
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0; btn.AutoButtonColor = false
		btn.AutomaticSize = Enum.AutomaticSize.X
		btn.Size = UDim2.new(0,10,1,0); btn.ZIndex = 5
		btn.Parent = tabBar
		Pad(btn,0,0,10,10); Corner(btn,7)

		-- Optional tab icon
		if tabIcon and tabIcon ~= "" then
			-- Prepend icon character — use RichText approach for simplicity
			-- or create a small icon label inside the button
			local ico = Label(btn, tabIcon, 11, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Left, Enum.TextYAlignment.Center)
			ico.Size = UDim2.new(0,14,1,0)
			ico.ZIndex = 6
		end

		-- Page
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1; page.BorderSizePixel = 0
		page.Size = UDim2.new(1,0,1,0)
		page.CanvasSize = UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 4  -- IMPROVEMENT: 3→4px, easier to grab
		page.ScrollBarImageColor3 = T.Accent
		page.ScrollBarImageTransparency = 0.4
		page.ScrollingDirection = Enum.ScrollingDirection.Y
		page.Visible = false; page.ZIndex = 3
		page.Parent = contentArea

		local ll = Instance.new("UIListLayout")
		ll.FillDirection = Enum.FillDirection.Vertical
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Padding = UDim.new(0,7)
		ll.Parent = page
		Pad(page,10,18,10,10)

		local tabData = {Btn=btn, Page=page}
		table.insert(tabs, tabData)

		-- Activate function
		local function Activate()
			if activeTab then
				FT(activeTab.Btn, {TextColor3=T.TxtMute}, 0.15)
				activeTab.Page.Visible = false
			end
			activeTab = tabData
			FT(btn, {TextColor3=T.White}, 0.15)
			page.Visible = true
			page.CanvasPosition = Vector2.new(0,0)  -- IMPROVEMENT: reset scroll on tab switch

			task.spawn(function()
				task.wait()
				if not btn.Parent then return end
				local barAbs = tabBar.AbsolutePosition.X
				local relX   = btn.AbsolutePosition.X - barAbs - 4
				FT(tabInd, {
					Size     = UDim2.new(0, btn.AbsoluteSize.X, 0, 26),
					Position = UDim2.new(0, relX, 0.5, -13),
				}, 0.20)
			end)
		end

		btn.MouseButton1Click:Connect(Activate)
		if #tabs == 1 then Activate() end

		-- ─────────────────────────────────────────────────
		--  ELEMENT API
		-- ─────────────────────────────────────────────────
		local API = {}

		function API:Select()      Activate() end
		function API:SetVisible(v) btn.Visible = v end

		local function Card(h, alpha)
			local c = Frame(page, UDim2.new(1,0,0,h), nil, T.Surface)
			c.ZIndex = 4
			if alpha then c.BackgroundTransparency = alpha end
			Corner(c,11); Stroke(c,T.Border,1); Pad(c,0,0,14,14); Shine(c)
			return c
		end

		local function Wrap(container, api)
			api = api or {}
			function api:SetVisible(v) container.Visible = v end
			function api:Destroy()     container:Destroy() end
			return api
		end

		-- ─────────────────────────────────────────
		--  SECTION
		-- ─────────────────────────────────────────
		function API:AddSection(name)
			local w = Frame(page, UDim2.new(1,0,0,26), nil, T.Black)
			w.BackgroundTransparency = 1; w.ZIndex = 4

			local function Line(xs, xo, ws)
				local l = Frame(w, UDim2.new(ws,-4,0,1), UDim2.new(xs,xo,0.5,0), T.BorderBri)
				l.ZIndex = 4
				local g = Instance.new("UIGradient")
				g.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0,   xs==0 and 1 or 0.4),
					NumberSequenceKeypoint.new(0.5, 0.4),
					NumberSequenceKeypoint.new(1,   xs==0 and 0.4 or 1),
				}); g.Parent = l
			end
			Line(0,0,0.28); Line(0.72,0,0.28)

			local spaced = ""
			for i = 1, #name do
				spaced = spaced..name:sub(i,i)
				if i < #name then spaced = spaced.." " end
			end
			local sl = Label(w, spaced:upper(), 9, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			sl.Size     = UDim2.new(0.44,0,1,0)
			sl.Position = UDim2.new(0.28,0,0,0); sl.ZIndex = 4
		end

		-- ─────────────────────────────────────────
		--  SEPARATOR
		-- ─────────────────────────────────────────
		function API:AddSeparator()
			local s = Frame(page, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,0), T.Border)
			s.ZIndex = 4
			local g = Instance.new("UIGradient")
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0,  1),
				NumberSequenceKeypoint.new(0.1,0),
				NumberSequenceKeypoint.new(0.9,0),
				NumberSequenceKeypoint.new(1,  1),
			}); g.Parent = s
		end

		-- ─────────────────────────────────────────
		--  LABEL
		-- ─────────────────────────────────────────
		function API:AddLabel(opt)
			opt = type(opt)=="string" and {Text=opt} or (opt or {})
			local text  = opt.Text     or "Label"
			local color = opt.Color    or T.TxtSub
			local align = opt.Align    or "Left"
			local size  = opt.TextSize or 13
			local font  = opt.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
			local xa = align=="Center" and Enum.TextXAlignment.Center
				or   align=="Right"  and Enum.TextXAlignment.Right
				or   Enum.TextXAlignment.Left

			local wrap = Frame(page, UDim2.new(1,0,0,26), nil, T.Black)
			wrap.BackgroundTransparency = 1; wrap.ZIndex = 4

			local lbl = Label(wrap, text, size, color, font, xa,
				Enum.TextYAlignment.Center, true)
			lbl.Size = UDim2.new(1,-20,1,0); lbl.Position = UDim2.new(0,10,0,0)
			lbl.ZIndex = 5

			local L = Wrap(wrap)
			function L:SetText(t)  lbl.Text       = t end
			function L:SetColor(c) lbl.TextColor3 = c end
			function L:SetSize(n)  lbl.TextSize   = n end
			return L
		end

		-- ─────────────────────────────────────────
		--  PARAGRAPH
		-- ─────────────────────────────────────────
		function API:AddParagraph(opt)
			opt = opt or {}
			local title   = opt.Title   or "Info"
			local content = opt.Content or ""
			local color   = opt.Color   or T.TxtSub

			local lines = math.max(1, math.ceil(#content/40))
			local h     = math.max(60, 14 + 22 + 8 + lines*18 + 14)

			local c = Frame(page, UDim2.new(1,0,0,h), nil, T.Surface)
			c.BackgroundTransparency = 0.20; c.ZIndex = 4
			Corner(c,11); Stroke(c,T.Border,1,0.2); Pad(c,10,10,14,14); Shine(c)

			local strip = Frame(c, UDim2.new(0,3,1,-20), UDim2.new(0,0,0,10), T.Accent)
			strip.ZIndex = 5; Corner(strip,3)
			do
				local g = Instance.new("UIGradient")
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,T.AccentHi),
					ColorSequenceKeypoint.new(1,T.AccentLo),
				}); g.Rotation=90; g.Parent=strip
			end

			local tl = Label(c, title, 13, T.TxtMain, Enum.Font.GothamBold)
			tl.Size = UDim2.new(1,-10,0,22); tl.ZIndex = 5

			local cl = Instance.new("TextLabel")
			cl.Text = content; cl.TextSize = 12; cl.Font = Enum.Font.Gotham
			cl.TextColor3 = color; cl.BackgroundTransparency = 1
			cl.BorderSizePixel = 0
			cl.Size = UDim2.new(1,-10,0,h-46); cl.Position = UDim2.new(0,0,0,28)
			cl.TextXAlignment = Enum.TextXAlignment.Left
			cl.TextYAlignment = Enum.TextYAlignment.Top
			cl.TextWrapped = true; cl.ZIndex = 5; cl.Parent = c

			local P = Wrap(c)
			function P:SetTitle(t)   tl.Text       = t end
			function P:SetContent(t) cl.Text       = t end
			function P:SetColor(col) cl.TextColor3 = col end
			return P
		end

		-- ─────────────────────────────────────────
		--  BUTTON
		-- ─────────────────────────────────────────
		function API:AddButton(opt)
			opt = opt or {}
			local name    = opt.Name     or "Button"
			local desc    = opt.Desc     or ""
			local icon    = opt.Icon     or ""
			local cb      = opt.Callback or function() end
			local color   = opt.Color    or T.Accent
			local enabled = true

			local h    = desc ~= "" and 58 or 46
			local card = Card(h)

			local iOff = 0
			if icon ~= "" then
				iOff = 38
				local ib = Frame(card, UDim2.new(0,28,0,28), UDim2.new(0,0,0.5,-14), T.AccentDeep)
				ib.ZIndex = 5; Corner(ib,8); Stroke(ib,color,1,0.35)
				MkIcon(ib, icon, 14, color, UDim2.new(0.68,0,0.68,0), 6)
			end

			local nl = Label(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-(iOff+88),0,desc~="" and 20 or 30)
			nl.Position = UDim2.new(0,iOff,0,desc~="" and 5 or 0)
			nl.TextYAlignment = Enum.TextYAlignment.Center; nl.ZIndex = 5

			local dl
			if desc ~= "" then
				dl = Label(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				dl.Size = UDim2.new(1,-(iOff+88),0,16)
				dl.Position = UDim2.new(0,iOff,0,27); dl.ZIndex = 5
			end

			local pillW = 74
			local pill  = Frame(card, UDim2.new(0,pillW,0,30), UDim2.new(1,-pillW,0.5,-15), color)
			pill.ZIndex = 5; Corner(pill,9)
			do
				local g = Instance.new("UIGradient")
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,T.AccentHi),
					ColorSequenceKeypoint.new(1,color),
				}); g.Rotation=95; g.Parent=pill
				local sh = Frame(pill,UDim2.new(1,-6,0,9),UDim2.new(0,3,0,2),T.White)
				sh.BackgroundTransparency=0.84; sh.ZIndex=6; Corner(sh,4)
			end

			local runLbl = Label(pill,"Run",12,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			runLbl.ZIndex = 7

			local pillBB = Button(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=8

			local running = false
			local function Run()
				if running or not enabled then return end
				running = true
				FT(pill,{Size=UDim2.new(0,pillW-5,0,26)},0.07)
				task.delay(0.08,function()
					if pill and pill.Parent then
						ST(pill,{Size=UDim2.new(0,pillW,0,30)},0.18)
					end
				end)
				runLbl.Text = "✓"; FT(runLbl,{TextColor3=T.Green},0.1)
				Call(cb)
				-- FIX: reset running flag AFTER the animation window, not before
				task.delay(0.90, function()
					running = false
					if runLbl and runLbl.Parent then
						runLbl.Text = "Run"
						FT(runLbl,{TextColor3=T.White},0.15)
					end
				end)
			end

			pillBB.MouseEnter:Connect(function() FT(pill,{BackgroundColor3=T.AccentHi},0.12) end)
			pillBB.MouseLeave:Connect(function() FT(pill,{BackgroundColor3=color},0.12) end)
			pillBB.MouseButton1Click:Connect(Run)

			local cBB = Button(card,"",0,T.Black,T.White)
			cBB.BackgroundTransparency=1; cBB.Size=UDim2.new(1,-(pillW+6),1,0); cBB.ZIndex=5
			cBB.MouseEnter:Connect(function() if enabled then FT(card,{BackgroundColor3=T.SurfaceHi},0.13) end end)
			cBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},0.13) end)
			cBB.MouseButton1Click:Connect(Run)

			local B = Wrap(card)
			function B:SetName(s)    nl.Text = s end
			function B:SetDesc(s)    if dl then dl.Text = s end end
			function B:SetEnabled(v)
				enabled = v
				FT(card, {BackgroundTransparency = v and 0 or 0.45}, 0.18)
				FT(nl,   {TextColor3 = v and T.TxtMain or T.TxtOff}, 0.18)
				FT(pill, {BackgroundTransparency = v and 0 or 0.60}, 0.18)
			end
			return B
		end

		-- ─────────────────────────────────────────
		--  TOGGLE
		-- ─────────────────────────────────────────
		function API:AddToggle(opt)
			opt = opt or {}
			local name    = opt.Name     or "Toggle"
			local desc    = opt.Desc     or ""
			local default = opt.Default  or false
			local cb      = opt.Callback or function() end
			local color   = opt.Color    or T.Accent
			local id      = opt.Id       or ""
			local enabled = true

			local h    = desc ~= "" and 56 or 44
			local card = Card(h)

			local nl = Label(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-68,0,22)
			nl.Position = UDim2.new(0,0,0,desc~="" and 3 or 0)
			nl.TextYAlignment = Enum.TextYAlignment.Center; nl.ZIndex = 5

			if desc ~= "" then
				local dl = Label(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				dl.Size = UDim2.new(1,-68,0,16); dl.Position = UDim2.new(0,0,0,26); dl.ZIndex = 5
			end

			local track = Frame(card, UDim2.new(0,50,0,26), UDim2.new(1,-50,0.5,-13), T.TogOff)
			track.ZIndex = 5; Corner(track,13); Stroke(track,T.Border,1)

			local thumb = Frame(track, UDim2.new(0,20,0,20), UDim2.new(0,3,0.5,-10), T.White)
			thumb.ZIndex = 6; Corner(thumb,10)
			local tStr = Stroke(thumb, T.Border, 1.5)
			do
				local sh = Frame(thumb,UDim2.new(1,-4,0,7),UDim2.new(0,2,0,2),T.White)
				sh.BackgroundTransparency=0.82; sh.ZIndex=7; Corner(sh,4)
			end

			local state = default; local busy = false

			local function Refresh(anim)
				if state then
					if anim then
						FT(track,{BackgroundColor3=color},0.20)
						ST(thumb,{Position=UDim2.new(0,27,0.5,-10)},0.24)
						FT(tStr,{Color=color,Thickness=2},0.20)
						FT(thumb,{Size=UDim2.new(0,16,0,20)},0.06)
						task.delay(0.07,function()
							if thumb and thumb.Parent then
								ET(thumb,{Size=UDim2.new(0,20,0,20)},0.26)
							end
						end)
					else
						track.BackgroundColor3=color
						thumb.Position=UDim2.new(0,27,0.5,-10)
						tStr.Color=color; tStr.Thickness=2
					end
				else
					if anim then
						FT(track,{BackgroundColor3=T.TogOff},0.20)
						ST(thumb,{Position=UDim2.new(0,3,0.5,-10)},0.24)
						FT(tStr,{Color=T.Border,Thickness=1.5},0.20)
						FT(thumb,{Size=UDim2.new(0,16,0,20)},0.06)
						task.delay(0.07,function()
							if thumb and thumb.Parent then
								ET(thumb,{Size=UDim2.new(0,20,0,20)},0.26)
							end
						end)
					else
						track.BackgroundColor3=T.TogOff
						thumb.Position=UDim2.new(0,3,0.5,-10)
						tStr.Color=T.Border; tStr.Thickness=1.5
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy or not enabled then return end
				busy=true; state=not state; Refresh(true)
				Call(cb, state); task.delay(0.30,function() busy=false end)
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog = Wrap(card)
			function Tog:Set(v)        state=v; Refresh(true) end
			function Tog:Get()         return state end
			function Tog:Fire()        Call(cb, state) end
			function Tog:SetEnabled(v)
				enabled=v
				FT(card, {BackgroundTransparency=v and 0 or 0.45},0.18)
				FT(track,{BackgroundTransparency=v and 0 or 0.50},0.18)
			end
			Reg(wName,id, function() return state end,
				function(v) state=v; Refresh(true) end, "bool", Tog)
			return Tog
		end

		-- ─────────────────────────────────────────
		--  SLIDER
		--  IMPROVEMENT: opt.Step for decimal precision
		--    e.g. { Min=0, Max=1, Step=0.01, Default=0.5 }
		-- ─────────────────────────────────────────
		function API:AddSlider(opt)
			opt = opt or {}
			local name   = opt.Name     or "Slider"
			local desc   = opt.Desc     or ""
			local minV   = opt.Min      or 0
			local maxV   = opt.Max      or 100
			local defV   = opt.Default  or minV
			local sfx    = opt.Suffix   or ""
			local step   = opt.Step     or 1   -- IMPROVEMENT: decimal step
			local cb     = opt.Callback or function() end
			local color  = opt.Color    or T.Accent
			local id     = opt.Id       or ""

			-- Snap value to step grid
			local function SnapVal(v)
				v = math.clamp(v, minV, maxV)
				if step > 0 then
					v = math.round((v - minV) / step) * step + minV
				end
				-- Round to avoid floating-point display noise
				local decimals = math.max(0, math.ceil(-math.log10(step + 1e-9)))
				local factor = 10 ^ decimals
				return math.round(v * factor) / factor
			end

			local h    = desc ~= "" and 74 or 62
			local card = Card(h)

			local nl = Label(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.62,0,0,20); nl.ZIndex=5

			local vl = Label(card,tostring(SnapVal(defV))..sfx,13,color,Enum.Font.GothamBold,
				Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.38,0,0,20); vl.ZIndex=5

			if desc ~= "" then
				local dl = Label(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,0,0,14); dl.Position=UDim2.new(0,0,0,22); dl.ZIndex=5
			end

			local yOff = desc ~= "" and 42 or 28

			local tBG = Frame(card, UDim2.new(1,0,0,10), UDim2.new(0,0,0,yOff), T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)
			do
				local g=Instance.new("UIGradient")
				g.Color=ColorSequence.new({
					ColorSequenceKeypoint.new(0,T.SurfaceHi2),
					ColorSequenceKeypoint.new(1,T.SurfaceHi),
				}); g.Rotation=90; g.Parent=tBG
			end

			local fill = Frame(tBG,UDim2.new(0,0,1,0),nil,color)
			fill.ZIndex=6; Corner(fill,5)
			do
				local g=Instance.new("UIGradient")
				g.Color=ColorSequence.new({
					ColorSequenceKeypoint.new(0,T.AccentHi),
					ColorSequenceKeypoint.new(1,color),
				}); g.Parent=fill
				local sh=Frame(fill,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White)
				sh.BackgroundTransparency=0.86; sh.ZIndex=7; Corner(sh,4)
			end

			local knob = Frame(tBG,UDim2.new(0,20,0,20),UDim2.new(0,-10,0.5,-10),T.White)
			knob.ZIndex=7; Corner(knob,10)
			local kRing = Stroke(knob,color,2)
			do
				local sh=Frame(knob,UDim2.new(1,-4,0,7),UDim2.new(0,2,0,2),T.White)
				sh.BackgroundTransparency=0.82; sh.ZIndex=8; Corner(sh,4)
			end
			local tGlow = Stroke(tBG,T.AccentHi,2,1)

			local val     = SnapVal(defV)
			local sliding = false

			local function SetVal(v)
				val = SnapVal(v)
				local pct = (maxV ~= minV) and ((val-minV)/(maxV-minV)) or 0
				FT(fill,{Size=UDim2.new(pct,0,1,0)},0.06)
				FT(knob,{Position=UDim2.new(pct,-10,0.5,-10)},0.06)
				vl.Text = tostring(val)..sfx
			end
			SetVal(defV)

			local function FromPos(pos)
				local ax = tBG.AbsolutePosition.X
				local aw = tBG.AbsoluteSize.X
				if aw == 0 then return minV end
				return minV + math.clamp((pos.X-ax)/aw,0,1)*(maxV-minV)
			end

			local conns = {}

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=true
					ST(knob,{Size=UDim2.new(0,24,0,24)},0.12)
					FT(kRing,{Thickness=3},0.12)
					FT(tGlow,{Transparency=0.5},0.20)
					SetVal(FromPos(i.Position)); Call(cb, val)
				end
			end)

			conns[1] = UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
				or             i.UserInputType==Enum.UserInputType.Touch) then
					SetVal(FromPos(i.Position)); Call(cb, val)
				end
			end)
			conns[2] = UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=false
					FT(knob,{Size=UDim2.new(0,20,0,20)},0.13)
					FT(kRing,{Thickness=2},0.13)
					FT(tGlow,{Transparency=1},0.22)
				end
			end)

			card.AncestryChanged:Connect(function()
				if not card.Parent then
					for _,c in pairs(conns) do c:Disconnect() end
				end
			end)

			local Sl = Wrap(card)
			function Sl:Set(v)       SetVal(v) end
			function Sl:Get()        return val end
			function Sl:SetMin(n)    minV=n; SetVal(val) end
			function Sl:SetMax(n)    maxV=n; SetVal(val) end
			function Sl:SetStep(n)   step=n; SetVal(val) end
			function Sl:SetSuffix(s) sfx=s; vl.Text=tostring(val)..s end
			Reg(wName,id,
				function() return val end,
				function(v) SetVal(tonumber(v) or minV) end,
				"number", Sl)
			return Sl
		end

		-- ─────────────────────────────────────────
		--  DROPDOWN  (nil default supported)
		--  IMPROVEMENT: Escape key closes the list
		-- ─────────────────────────────────────────
		function API:AddDropdown(opt)
			opt = opt or {}
			local name        = opt.Name        or "Dropdown"
			local items       = opt.Items       or {}
			local cb          = opt.Callback    or function() end
			local color       = opt.Color       or T.Accent
			local id          = opt.Id          or ""
			local placeholder = opt.Placeholder or "Select..."
			local hasDefault  = opt.Default ~= nil
				and opt.Default ~= false
				and opt.Default ~= ""
			local selVal      = hasDefault and opt.Default or nil
			local isOpen      = false

			local card = Card(44)

			local nl = Label(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.36,0,1,0); nl.ZIndex=5

			local pill = Frame(card,UDim2.new(0.62,0,0,30),UDim2.new(0.38,0,0.5,-15),T.SurfaceHi)
			pill.ZIndex=5; Corner(pill,9); Stroke(pill,T.Border,1); Shine(pill)

			local pillLbl = Label(pill, selVal or placeholder, 12,
				selVal and T.TxtMain or T.TxtMute, Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-26,1,0); pillLbl.Position=UDim2.new(0,9,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd

			-- IMPROVEMENT: ▾/▲ chevrons look far better than "v"
			local chev = Label(pill,"▾",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chev.Size=UDim2.new(0,20,1,0); chev.Position=UDim2.new(1,-22,0,0); chev.ZIndex=6

			local function RefPill()
				if selVal then
					pillLbl.Text=selVal; FT(pillLbl,{TextColor3=T.TxtMain},0.14)
				else
					pillLbl.Text=placeholder; FT(pillLbl,{TextColor3=T.TxtMute},0.14)
				end
			end

			local lf = Frame(overlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			lf.ZIndex=50; lf.Visible=false; lf.ClipsDescendants=true
			Corner(lf,11); Stroke(lf,T.BorderGlow,1,0.3); Shine(lf)

			local inner = Frame(lf,UDim2.new(1,0,1,0),nil,T.Black)
			inner.BackgroundTransparency=1; inner.ZIndex=51
			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical
			iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,3); iLL.Parent=inner
			Pad(inner,5,5,5,5)

			-- Search
			local sBG=Frame(inner,UDim2.new(1,0,0,28),nil,T.SurfaceHi)
			sBG.ZIndex=52; Corner(sBG,7); Stroke(sBG,T.Border,1)
			local sTB=Instance.new("TextBox")
			sTB.PlaceholderText="Search..."; sTB.PlaceholderColor3=T.TxtMute
			sTB.Text=""; sTB.TextColor3=T.TxtMain; sTB.BackgroundTransparency=1
			sTB.Font=Enum.Font.Gotham; sTB.TextSize=12
			sTB.Size=UDim2.new(1,-12,1,0); sTB.Position=UDim2.new(0,6,0,0)
			sTB.TextXAlignment=Enum.TextXAlignment.Left
			sTB.ClearTextOnFocus=false; sTB.ZIndex=53; sTB.Parent=sBG

			local iSF=Instance.new("ScrollingFrame")
			iSF.BackgroundTransparency=1; iSF.BorderSizePixel=0
			iSF.Size=UDim2.new(1,0,0,0); iSF.CanvasSize=UDim2.new(0,0,0,0)
			iSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			iSF.ScrollBarThickness=2; iSF.ScrollBarImageColor3=T.Accent
			iSF.ZIndex=52; iSF.Parent=inner
			local rLL=Instance.new("UIListLayout")
			rLL.FillDirection=Enum.FillDirection.Vertical
			rLL.SortOrder=Enum.SortOrder.LayoutOrder
			rLL.Padding=UDim.new(0,2); rLL.Parent=iSF

			local rows = {}

			local function Close()
				if not isOpen then return end; isOpen=false
				FT(lf,{Size=UDim2.new(1,-20,0,0)},0.16)
				FT(chev,{Rotation=0},0.16)
				FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.delay(0.18,function() if lf and lf.Parent then lf.Visible=false end end)
				sTB.Text=""
			end

			local function BuildRows(filter)
				filter=(filter or ""):lower()
				for _,r in ipairs(rows) do r.Parent=nil end; rows={}
				local cnt=0
				for _,item in ipairs(items) do
					if filter=="" or item:lower():find(filter,1,true) then
						cnt+=1
						local row=Frame(iSF,UDim2.new(1,0,0,30),nil,T.Black)
						row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)
						-- IMPROVEMENT: ✓ checkmark instead of ">"
						local ck=Label(row,selVal==item and "✓" or "",12,color,
							Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
						ck.Size=UDim2.new(0,22,1,0); ck.ZIndex=54
						local il=Label(row,item,12,T.TxtMain,Enum.Font.Gotham)
						il.Size=UDim2.new(1,-26,1,0); il.Position=UDim2.new(0,24,0,0); il.ZIndex=54
						local hit=Button(row,"",0,T.Black,T.White)
						hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
						hit.MouseEnter:Connect(function()
							FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.10)
						end)
						hit.MouseLeave:Connect(function()
							FT(row,{BackgroundTransparency=1},0.10)
						end)
						hit.MouseButton1Click:Connect(function()
							selVal=item; RefPill(); Close(); BuildRows(""); Call(cb,item)
						end)
						table.insert(rows,row)
					end
				end
				iSF.Size=UDim2.new(1,0,0,math.min(cnt,5)*32+4)
			end
			BuildRows("")
			sTB:GetPropertyChangedSignal("Text"):Connect(function() BuildRows(sTB.Text) end)

			local pillBB=Button(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=7

			pillBB.MouseButton1Click:Connect(function()
				if isOpen then Close(); return end
				isOpen=true; BuildRows("")

				-- FIX: task.wait() ensures AbsolutePosition is resolved before we read it
				task.spawn(function()
					task.wait()
					if not card.Parent then return end
					local oY    = overlay.AbsolutePosition.Y
					local cY    = card.AbsolutePosition.Y
					local cH    = card.AbsoluteSize.Y
					local yOff2 = (cY - oY) + cH + 4
					local listH = 38 + math.min(#items,5)*32 + 10

					lf.Position = UDim2.new(0,10,0,yOff2)
					lf.Size     = UDim2.new(1,-20,0,0)
					lf.Visible  = true
					FT(lf,  {Size=UDim2.new(1,-20,0,listH)},0.20)
					FT(chev,{Rotation=180},0.16)
					FT(pill,{BackgroundColor3=T.SurfaceHi2},0.12)
				end)
			end)

			local closeCon = UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				-- IMPROVEMENT: Escape closes the dropdown
				if i.UserInputType == Enum.UserInputType.Keyboard
				and i.KeyCode == Enum.KeyCode.Escape then
					Close(); return
				end
				if i.UserInputType~=Enum.UserInputType.MouseButton1
				and i.UserInputType~=Enum.UserInputType.Touch then return end
				local mx,my = i.Position.X, i.Position.Y
				local function inBounds(f)
					local ax=f.AbsolutePosition.X; local ay=f.AbsolutePosition.Y
					local aw=f.AbsoluteSize.X;     local ah=f.AbsoluteSize.Y
					return mx>=ax and mx<=ax+aw and my>=ay and my<=ay+ah
				end
				if not inBounds(lf) and not inBounds(pill) then Close() end
			end)
			card.AncestryChanged:Connect(function()
				if not card.Parent then closeCon:Disconnect() end
			end)

			local Drop = Wrap(card)
			function Drop:Get()         return selVal end
			function Drop:IsEmpty()     return selVal==nil end
			function Drop:IsSelected(v) return selVal==v end
			function Drop:Set(v)
				selVal = (v==nil or v==false or v=="") and nil or v
				RefPill(); BuildRows("")
			end
			function Drop:Clear()       selVal=nil; RefPill(); BuildRows("") end
			function Drop:AddItem(s)    table.insert(items,s); BuildRows("") end
			function Drop:RemoveItem(s)
				for i,v in ipairs(items) do
					if v==s then table.remove(items,i); break end
				end
				if selVal==s then selVal=nil; RefPill() end
				BuildRows("")
			end
			function Drop:Refresh(ni)
				items=ni or {}
				local found=false
				for _,v in ipairs(items) do if v==selVal then found=true; break end end
				if not found then selVal=nil end
				RefPill(); BuildRows("")
			end
			function Drop:SetPlaceholder(s)
				placeholder=s; if not selVal then pillLbl.Text=s end
			end
			Reg(wName,id,
				function() return selVal end,
				function(v)
					selVal=(v==nil or v==false or v=="") and nil or tostring(v)
					RefPill(); BuildRows("")
				end,
				"string", Drop)
			return Drop
		end

		-- ─────────────────────────────────────────
		--  MULTI DROPDOWN
		--  IMPROVEMENT: now has search filter + ✓ marks + Escape to close
		-- ─────────────────────────────────────────
		function API:AddMultiDropdown(opt)
			opt = opt or {}
			local name        = opt.Name        or "Multi Select"
			local items       = opt.Items       or {}
			local cb          = opt.Callback    or function() end
			local color       = opt.Color       or T.Accent
			local id          = opt.Id          or ""
			local placeholder = opt.Placeholder or "None selected"

			local card     = Card(44)
			local selected = {}
			local isOpen   = false

			if type(opt.Default)=="table" then
				for _,v in pairs(opt.Default) do selected[v]=true end
			end

			local function GetSel()
				local t={}
				for _,item in ipairs(items) do
					if selected[item] then table.insert(t,item) end
				end
				return t
			end
			local function PillTxt()
				local t=GetSel()
				if #t==0 then return placeholder
				elseif #t==1 then return t[1]
				else return t[1].." +"..tostring(#t-1) end
			end

			local nl=Label(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.36,0,1,0); nl.ZIndex=5

			local pill=Frame(card,UDim2.new(0.62,0,0,30),UDim2.new(0.38,0,0.5,-15),T.SurfaceHi)
			pill.ZIndex=5; Corner(pill,9); Stroke(pill,T.Border,1); Shine(pill)

			local pillLbl=Label(pill,PillTxt(),12,
				#GetSel()>0 and T.TxtMain or T.TxtMute,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-44,1,0); pillLbl.Position=UDim2.new(0,9,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd

			-- IMPROVEMENT: ▾/▲ chevrons
			local chev=Label(pill,"▾",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chev.Size=UDim2.new(0,20,1,0); chev.Position=UDim2.new(1,-22,0,0); chev.ZIndex=6

			local badge=Frame(pill,UDim2.new(0,16,0,16),UDim2.new(1,-42,0.5,-8),T.Accent)
			badge.ZIndex=7; Corner(badge,8)
			local badgeLbl=Label(badge,"0",9,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			badgeLbl.ZIndex=8

			local function RefBadge()
				local n=#GetSel(); badgeLbl.Text=tostring(n)
				badge.BackgroundTransparency=n==0 and 1 or 0
				pillLbl.Text=PillTxt()
				FT(pillLbl,{TextColor3=n>0 and T.TxtMain or T.TxtMute},0.14)
			end
			RefBadge()

			local lf=Frame(overlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			lf.ZIndex=50; lf.Visible=false; lf.ClipsDescendants=true
			Corner(lf,11); Stroke(lf,T.BorderGlow,1,0.3); Shine(lf)

			local inner=Frame(lf,UDim2.new(1,0,1,0),nil,T.Black)
			inner.BackgroundTransparency=1; inner.ZIndex=51
			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical
			iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,3); iLL.Parent=inner
			Pad(inner,5,5,5,5)

			-- IMPROVEMENT: Search box (parity with single dropdown)
			local sBG=Frame(inner,UDim2.new(1,0,0,28),nil,T.SurfaceHi)
			sBG.ZIndex=52; Corner(sBG,7); Stroke(sBG,T.Border,1)
			local sTB=Instance.new("TextBox")
			sTB.PlaceholderText="Search..."; sTB.PlaceholderColor3=T.TxtMute
			sTB.Text=""; sTB.TextColor3=T.TxtMain; sTB.BackgroundTransparency=1
			sTB.Font=Enum.Font.Gotham; sTB.TextSize=12
			sTB.Size=UDim2.new(1,-12,1,0); sTB.Position=UDim2.new(0,6,0,0)
			sTB.TextXAlignment=Enum.TextXAlignment.Left
			sTB.ClearTextOnFocus=false; sTB.ZIndex=53; sTB.Parent=sBG

			-- Action row
			local aRow=Frame(inner,UDim2.new(1,0,0,26),nil,T.SurfaceHi)
			aRow.ZIndex=52; Corner(aRow,7)
			local sAll=Button(aRow,"All",11,T.AccentLo,T.AccentHi,Enum.Font.GothamBold)
			sAll.BackgroundTransparency=1; sAll.Size=UDim2.new(0.5,0,1,0)
			sAll.TextXAlignment=Enum.TextXAlignment.Center
			local clr=Button(aRow,"Clear",11,T.AccentLo,T.TxtMute,Enum.Font.GothamBold)
			clr.BackgroundTransparency=1; clr.Size=UDim2.new(0.5,0,1,0)
			clr.Position=UDim2.new(0.5,0,0,0); clr.TextXAlignment=Enum.TextXAlignment.Center

			local iSF=Instance.new("ScrollingFrame")
			iSF.BackgroundTransparency=1; iSF.BorderSizePixel=0
			iSF.Size=UDim2.new(1,0,0,0); iSF.CanvasSize=UDim2.new(0,0,0,0)
			iSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			iSF.ScrollBarThickness=2; iSF.ScrollBarImageColor3=T.Accent
			iSF.ZIndex=52; iSF.Parent=inner
			local rLL=Instance.new("UIListLayout")
			rLL.FillDirection=Enum.FillDirection.Vertical
			rLL.SortOrder=Enum.SortOrder.LayoutOrder
			rLL.Padding=UDim.new(0,2); rLL.Parent=iSF

			local rows={}
			local function BuildRows(filter)
				filter=(filter or ""):lower()
				for _,r in ipairs(rows) do r.Parent=nil end; rows={}
				local cnt=0
				for _,item in ipairs(items) do
					if filter=="" or item:lower():find(filter,1,true) then
						cnt+=1
						local row=Frame(iSF,UDim2.new(1,0,0,32),nil,T.Black)
						row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)
						local cbBox=Frame(row,UDim2.new(0,18,0,18),UDim2.new(0,5,0.5,-9),T.SurfaceHi2)
						cbBox.ZIndex=54; Corner(cbBox,5); Stroke(cbBox,T.Border,1)
						if selected[item] then cbBox.BackgroundColor3=T.AccentDeep end
						-- IMPROVEMENT: ✓ checkmark
						local ck=Label(cbBox,selected[item] and "✓" or "",10,color,
							Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
						ck.ZIndex=55
						local il=Label(row,item,12,T.TxtMain,Enum.Font.Gotham)
						il.Size=UDim2.new(1,-32,1,0); il.Position=UDim2.new(0,30,0,0); il.ZIndex=54
						local hit=Button(row,"",0,T.Black,T.White)
						hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
						hit.MouseEnter:Connect(function()
							FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.10)
						end)
						hit.MouseLeave:Connect(function()
							FT(row,{BackgroundTransparency=1},0.10)
						end)
						hit.MouseButton1Click:Connect(function()
							selected[item]=not selected[item]
							ck.Text=selected[item] and "✓" or ""
							FT(cbBox,{BackgroundColor3=selected[item] and T.AccentDeep or T.SurfaceHi2},0.12)
							RefBadge(); Call(cb,GetSel())
						end)
						table.insert(rows,row)
					end
				end
				iSF.Size=UDim2.new(1,0,0,math.min(cnt,5)*34+4)
			end
			BuildRows("")
			sTB:GetPropertyChangedSignal("Text"):Connect(function() BuildRows(sTB.Text) end)

			sAll.MouseButton1Click:Connect(function()
				for _,i in ipairs(items) do selected[i]=true end
				BuildRows(sTB.Text); RefBadge(); Call(cb,GetSel())
			end)
			clr.MouseButton1Click:Connect(function()
				for _,i in ipairs(items) do selected[i]=false end
				BuildRows(sTB.Text); RefBadge(); Call(cb,{})
			end)

			local function CloseM()
				if not isOpen then return end; isOpen=false
				FT(lf,{Size=UDim2.new(1,-20,0,0)},0.16)
				FT(chev,{Rotation=0},0.16)
				FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.delay(0.18,function() if lf and lf.Parent then lf.Visible=false end end)
				sTB.Text=""
			end

			local pBB=Button(pill,"",0,T.Black,T.White)
			pBB.BackgroundTransparency=1; pBB.Size=UDim2.new(1,0,1,0); pBB.ZIndex=7
			pBB.MouseButton1Click:Connect(function()
				if isOpen then CloseM(); return end
				isOpen=true; BuildRows("")

				-- FIX: task.wait() for correct AbsolutePosition
				task.spawn(function()
					task.wait()
					if not card.Parent then return end
					local oY  = overlay.AbsolutePosition.Y
					local cY  = card.AbsolutePosition.Y
					local cH  = card.AbsoluteSize.Y
					local yOff = (cY-oY)+cH+4
					local lH   = 62+math.min(#items,5)*34+10  -- +34 for search row
					lf.Position=UDim2.new(0,10,0,yOff)
					lf.Size=UDim2.new(1,-20,0,0); lf.Visible=true
					FT(lf,{Size=UDim2.new(1,-20,0,lH)},0.20)
					FT(chev,{Rotation=180},0.16)
					FT(pill,{BackgroundColor3=T.SurfaceHi2},0.12)
				end)
			end)

			local mCon=UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				-- IMPROVEMENT: Escape closes the multi-dropdown
				if i.UserInputType == Enum.UserInputType.Keyboard
				and i.KeyCode == Enum.KeyCode.Escape then
					CloseM(); return
				end
				if i.UserInputType~=Enum.UserInputType.MouseButton1
				and i.UserInputType~=Enum.UserInputType.Touch then return end
				local mx,my=i.Position.X,i.Position.Y
				local function inB(f)
					return mx>=f.AbsolutePosition.X and mx<=f.AbsolutePosition.X+f.AbsoluteSize.X
					   and my>=f.AbsolutePosition.Y and my<=f.AbsolutePosition.Y+f.AbsoluteSize.Y
				end
				if not inB(lf) and not inB(pill) then CloseM() end
			end)
			card.AncestryChanged:Connect(function()
				if not card.Parent then mCon:Disconnect() end
			end)

			local MD = Wrap(card)
			function MD:Get()          return GetSel() end
			function MD:IsEmpty()      return #GetSel()==0 end
			function MD:IsSelected(v)  return selected[v]==true end
			function MD:SelectAll()
				for _,i in ipairs(items) do selected[i]=true end
				BuildRows(""); RefBadge(); Call(cb,GetSel())
			end
			function MD:Set(tbl)
				for _,i in ipairs(items) do selected[i]=false end
				if type(tbl)=="table" then
					for _,v in pairs(tbl) do selected[v]=true end
				end
				BuildRows(""); RefBadge()
			end
			function MD:Clear()
				for _,i in ipairs(items) do selected[i]=false end
				BuildRows(""); RefBadge(); Call(cb,{})
			end
			function MD:AddItem(s)    table.insert(items,s); BuildRows("") end
			function MD:RemoveItem(s)
				for i,v in ipairs(items) do
					if v==s then table.remove(items,i); break end
				end
				selected[s]=nil; BuildRows(""); RefBadge()
			end
			function MD:SetPlaceholder(s)
				placeholder=s; if #GetSel()==0 then pillLbl.Text=s end
			end
			Reg(wName,id,
				function() return GetSel() end,
				function(v)
					if type(v)=="table" then
						for _,i in ipairs(items) do selected[i]=false end
						for _,s in pairs(v) do selected[s]=true end
						BuildRows(""); RefBadge()
					end
				end,
				"multi", MD)
			return MD
		end

		-- ─────────────────────────────────────────
		--  TEXTBOX
		--  FIX: NumberOnly — minus sign only valid at start of string
		-- ─────────────────────────────────────────
		function API:AddTextBox(opt)
			opt = opt or {}
			local name    = opt.Name        or "Input"
			local ph      = opt.Placeholder or "Type here..."
			local default = opt.Default     or ""
			local numOnly = opt.NumberOnly  or false
			local cb      = opt.Callback    or function() end
			local color   = opt.Color       or T.Accent
			local id      = opt.Id          or ""

			local card=Card(66); Pad(card,8,8,14,14)

			local nl=Label(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local inBG=Frame(card,UDim2.new(1,0,0,30),UDim2.new(0,0,0,22),T.SurfaceHi)
			inBG.ZIndex=5; Corner(inBG,9)
			local inS=Stroke(inBG,T.Border,1); Shine(inBG)

			local pre=Label(inBG,"▸",13,T.TxtMute,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			pre.Size=UDim2.new(0,24,1,0); pre.ZIndex=6

			local tbx=Instance.new("TextBox")
			tbx.Text=default; tbx.PlaceholderText=ph
			tbx.PlaceholderColor3=T.TxtMute; tbx.TextColor3=T.TxtMain
			tbx.BackgroundTransparency=1; tbx.Font=Enum.Font.Gotham; tbx.TextSize=13
			tbx.Size=UDim2.new(1,-36,1,0); tbx.Position=UDim2.new(0,26,0,0)
			tbx.TextXAlignment=Enum.TextXAlignment.Left
			tbx.ClearTextOnFocus=false; tbx.ZIndex=6; tbx.Parent=inBG

			tbx.Focused:Connect(function()
				FT(inBG,{BackgroundColor3=T.SurfaceHi2},0.14)
				FT(inS, {Color=T.BorderGlow,Thickness=1.5},0.14)
				FT(pre, {TextColor3=color},0.14)
			end)
			tbx.FocusLost:Connect(function(enter)
				FT(inBG,{BackgroundColor3=T.SurfaceHi},0.14)
				FT(inS, {Color=T.Border,Thickness=1},0.14)
				FT(pre, {TextColor3=T.TxtMute},0.14)
				if enter then Call(cb,tbx.Text) end
			end)

			-- FIX: improved NumberOnly — allow one leading minus, digits, one decimal point
			if numOnly then
				tbx:GetPropertyChangedSignal("Text"):Connect(function()
					local t = tbx.Text
					-- Allow: optional leading "-", digits, optional "." followed by digits
					local clean = t:match("^%-?%d*%.?%d*") or ""
					if t ~= clean then tbx.Text = clean end
				end)
			end

			local TBx=Wrap(card)
			function TBx:Get()             return tbx.Text end
			function TBx:Set(v)            tbx.Text=tostring(v) end
			function TBx:Clear()           tbx.Text="" end
			function TBx:Focus()           tbx:CaptureFocus() end
			function TBx:SetPlaceholder(s) tbx.PlaceholderText=s end
			Reg(wName,id,
				function() return tbx.Text end,
				function(v) tbx.Text=tostring(v) end,
				"string", TBx)
			return TBx
		end

		-- ─────────────────────────────────────────
		--  KEYBIND
		--  FIX: ignore InputBegan when a TextBox is focused
		-- ─────────────────────────────────────────
		function API:AddKeybind(opt)
			opt = opt or {}
			local name = opt.Name     or "Keybind"
			local def  = opt.Default  or Enum.KeyCode.F
			local cb   = opt.Callback or function() end

			local card=Card(44)
			local nl=Label(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.52,0,1,0); nl.ZIndex=5

			local curKey   = def
			local listening = false

			local kPill=Frame(card,UDim2.new(0,110,0,28),UDim2.new(1,-110,0.5,-14),T.SurfaceHi)
			kPill.ZIndex=5; Corner(kPill,8); Stroke(kPill,T.Border,1); Shine(kPill)
			local kLbl=Label(kPill,"["..tostring(def.Name).."]",11,T.TxtMain,
				Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			kLbl.ZIndex=6
			local kBB=Button(kPill,"",0,T.Black,T.White)
			kBB.BackgroundTransparency=1; kBB.Size=UDim2.new(1,0,1,0); kBB.ZIndex=7

			kBB.MouseButton1Click:Connect(function()
				listening=true; kLbl.Text="[  ?  ]"
				FT(kPill,{BackgroundColor3=T.AccentDeep},0.12)
			end)

			local kCon=UserInputService.InputBegan:Connect(function(i,gpe)
				if gpe then return end
				if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
				-- FIX: don't capture / fire when a TextBox is focused
				if UserInputService:GetFocusedTextBox() then return end

				if listening then
					listening=false; curKey=i.KeyCode
					kLbl.Text="["..tostring(i.KeyCode.Name).."]"
					FT(kPill,{BackgroundColor3=T.SurfaceHi},0.14)
				elseif i.KeyCode==curKey then
					Call(cb)
				end
			end)
			card.AncestryChanged:Connect(function()
				if not card.Parent then kCon:Disconnect() end
			end)

			local KB=Wrap(card)
			function KB:Get()   return curKey end
			function KB:Set(k)  curKey=k; kLbl.Text="["..tostring(k.Name).."]" end
			return KB
		end

		-- ─────────────────────────────────────────
		--  COLOR PICKER
		-- ─────────────────────────────────────────
		function API:AddColorPicker(opt)
			opt = opt or {}
			local name = opt.Name     or "Color"
			local def  = opt.Default  or T.Accent
			local cb   = opt.Callback or function() end
			local id   = opt.Id       or ""

			local swatches={
				Color3.fromRGB(248, 66, 90),  Color3.fromRGB(252,148,50),
				Color3.fromRGB(252,212,50),   Color3.fromRGB(66,212,130),
				Color3.fromRGB(50,170,252),   Color3.fromRGB(135,74,252),
				Color3.fromRGB(246,70,198),   Color3.fromRGB(198,198,208),
			}

			local card=Card(62); Pad(card,8,8,14,14)
			local nl=Label(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local row=Frame(card,UDim2.new(1,0,0,36),UDim2.new(0,0,0,20),T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local prev=Frame(row,UDim2.new(0,36,0,36),nil,def)
			prev.ZIndex=6; Corner(prev,10); Stroke(prev,T.Border,1); Shine(prev)

			local swRow=Frame(row,UDim2.new(1,-46,1,0),UDim2.new(0,44,0,0),T.Black)
			swRow.BackgroundTransparency=1; swRow.ZIndex=5
			local swLL=Instance.new("UIListLayout")
			swLL.FillDirection=Enum.FillDirection.Horizontal
			swLL.VerticalAlignment=Enum.VerticalAlignment.Center
			swLL.Padding=UDim.new(0,5); swLL.Parent=swRow

			local selColor=def; local activeRing=nil
			for _,col in ipairs(swatches) do
				local sw=Frame(swRow,UDim2.new(0,26,0,26),nil,col)
				sw.ZIndex=6; Corner(sw,7); Shine(sw)
				local ring=Stroke(sw,T.White,2,col==def and 0 or 1)
				if col==def then activeRing=ring end
				local hit=Button(sw,"",0,T.Black,T.White)
				hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=7
				hit.MouseEnter:Connect(function() ST(sw,{Size=UDim2.new(0,28,0,28)},0.13) end)
				hit.MouseLeave:Connect(function() FT(sw,{Size=UDim2.new(0,26,0,26)},0.12) end)
				hit.MouseButton1Click:Connect(function()
					selColor=col; FT(prev,{BackgroundColor3=col},0.18)
					if activeRing then FT(activeRing,{Transparency=1},0.1) end
					FT(ring,{Transparency=0},0.1); activeRing=ring; Call(cb,col)
				end)
			end

			local CP=Wrap(card)
			function CP:Get()   return selColor end
			function CP:Set(c)
				selColor=c; prev.BackgroundColor3=c
				if activeRing then activeRing.Transparency=1; activeRing=nil end
			end
			Reg(wName,id,
				function() return selColor end,
				function(v) selColor=v; prev.BackgroundColor3=v end,
				"color", CP)
			return CP
		end

		-- ─────────────────────────────────────────
		--  PROGRESS BAR
		--  FIX: value stored as a variable, not parsed from label text
		-- ─────────────────────────────────────────
		function API:AddProgressBar(opt)
			opt = opt or {}
			local name  = opt.Name  or "Progress"
			local initV = opt.Value or 0
			local color = opt.Color or T.Accent

			local card=Card(52); Pad(card,8,8,14,14)
			local row=Frame(card,UDim2.new(1,0,0,20),nil,T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local nl=Label(row,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.65,0,1,0); nl.ZIndex=6
			local vl=Label(row,tostring(initV).."%",13,color,Enum.Font.GothamBold,
				Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.35,0,1,0); vl.ZIndex=6

			local tBG=Frame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,28),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)

			local fillF=Frame(tBG,UDim2.new(initV/100,0,1,0),nil,color)
			fillF.ZIndex=6; Corner(fillF,5)
			do
				local g=Instance.new("UIGradient")
				g.Color=ColorSequence.new({
					ColorSequenceKeypoint.new(0,T.AccentHi),
					ColorSequenceKeypoint.new(1,color),
				}); g.Parent=fillF
				local sh=Frame(fillF,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White)
				sh.BackgroundTransparency=0.86; sh.ZIndex=7; Corner(sh,4)
			end

			-- FIX: store the current value in a local variable
			local currentVal = math.clamp(initV, 0, 100)

			local PB=Wrap(card)
			function PB:Set(v)
				v=math.clamp(v,0,100)
				currentVal = v
				FT(fillF,{Size=UDim2.new(v/100,0,1,0)},0.38)
				vl.Text=tostring(math.round(v)).."%"
			end
			-- FIX: returns stored value, not parsed text
			function PB:Get()
				return currentVal
			end
			function PB:Animate(v,dur)
				v=math.clamp(v,0,100)
				currentVal = v
				LT(fillF,{Size=UDim2.new(v/100,0,1,0)},dur or 1)
				vl.Text=tostring(math.round(v)).."%"
			end
			return PB
		end

		-- ─────────────────────────────────────────
		--  CREDIT
		--  FIX: removed the duplicate FadeLine calls at the bottom
		-- ─────────────────────────────────────────
		function API:AddCredit(line1, line2)
			line1=line1 or "Credit"; line2=line2 or ""
			local wrap=Frame(page,UDim2.new(1,0,0,line2~="" and 70 or 52),nil,T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4

			local function FadeLine(xs,xo,w)
				local l=Frame(wrap,UDim2.new(w,0,0,1),UDim2.new(xs,xo,0,0),T.Accent)
				l.BackgroundTransparency=0.6; l.ZIndex=4
				local g=Instance.new("UIGradient")
				g.Transparency=NumberSequence.new({
					NumberSequenceKeypoint.new(0,  xs==0 and 1 or 0.6),
					NumberSequenceKeypoint.new(0.5,0.55),
					NumberSequenceKeypoint.new(1,  xs==0 and 0.6 or 1),
				}); g.Parent=l
			end
			-- FIX: only ONE set of fade lines (was called twice — creating duplicates)
			FadeLine(0.05,0,0.3); FadeLine(0.65,0,0.3)

			local l1=Instance.new("TextLabel")
			l1.Text=line1; l1.TextSize=14; l1.Font=Enum.Font.GothamBold
			l1.TextColor3=Color3.fromRGB(198,172,255)
			l1.BackgroundTransparency=1; l1.BorderSizePixel=0
			l1.Size=UDim2.new(1,0,0,22); l1.Position=UDim2.new(0,0,0,7)
			l1.TextXAlignment=Enum.TextXAlignment.Center
			l1.ZIndex=5; l1.Parent=wrap

			if line2~="" then
				local l2=Instance.new("TextLabel")
				l2.Text=line2; l2.TextSize=11; l2.Font=Enum.Font.Gotham
				l2.TextColor3=Color3.fromRGB(112,92,154)
				l2.BackgroundTransparency=1; l2.BorderSizePixel=0
				l2.Size=UDim2.new(1,0,0,18); l2.Position=UDim2.new(0,0,0,32)
				l2.TextXAlignment=Enum.TextXAlignment.Center
				l2.ZIndex=5; l2.Parent=wrap
			end
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

return NexusUI
