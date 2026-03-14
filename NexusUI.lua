--[[
╔══════════════════════════════════════════════════════════════╗
║   NexusUI  v1.7  —  Roblox Luau UI Library                   ║
║   "Icon + Corner" update                                     ║
╠══════════════════════════════════════════════════════════════╣
║  v1.7 Changes                                                ║
║  • MkIcon() helper — auto-detects icon type:                 ║
║      "N"                  → TextLabel (ASCII, as before)     ║
║      "rbxassetid://123"   → ImageLabel (tinted, ScaleFit)    ║
║      "123456789"          → ImageLabel (raw asset ID)        ║
║    Applied to: window pill, notifications, button icons      ║
║  • ContentFrame (tab scroll area) now has UICorner(12)       ║
║    with a top-fill strip so all 4 edges look correct         ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  THEME  v1.7 — richer, warmer, higher contrast
-- ════════════════════════════════════════════════════════════
local T = {
	-- Window / body
	BG          = Color3.fromRGB(11,   8,  24),   -- deeper background
	Surface     = Color3.fromRGB(20,  15,  40),   -- card base
	SurfaceHi   = Color3.fromRGB(30,  23,  56),   -- elevated (pill, input)
	SurfaceHi2  = Color3.fromRGB(42,  32,  72),   -- hover state
	SurfaceHi3  = Color3.fromRGB(54,  42,  90),   -- pressed / focus
	Border      = Color3.fromRGB(58,  44,  96),   -- card border
	BorderBri   = Color3.fromRGB(90,  68, 148),   -- bright border (dropdown)
	BorderGlow  = Color3.fromRGB(110, 80, 200),   -- glow border (focus)

	-- Accent (more saturated)
	Accent      = Color3.fromRGB(138,  76, 255),
	AccentHi    = Color3.fromRGB(170, 118, 255),
	AccentLo    = Color3.fromRGB(94,   48, 205),
	AccentDeep  = Color3.fromRGB(62,   30, 148),

	-- Text
	TxtMain     = Color3.fromRGB(242, 236, 255),
	TxtSub      = Color3.fromRGB(158, 140, 202),
	TxtMute     = Color3.fromRGB(90,   75, 126),
	TxtOff      = Color3.fromRGB(54,   44,  82),

	-- Status
	Green       = Color3.fromRGB(68,  214, 132),
	Red         = Color3.fromRGB(248,  64,  92),
	Yellow      = Color3.fromRGB(252, 188,  52),
	Blue        = Color3.fromRGB(52,  172, 254),

	-- Misc
	TogOff      = Color3.fromRGB(40,   32,  66),
	NotifBG     = Color3.fromRGB(18,   13,  38),
	CardShine   = Color3.fromRGB(255, 255, 255),  -- glass top-shine
	White       = Color3.fromRGB(255, 255, 255),
	Black       = Color3.fromRGB(0,    0,    0),
}

-- ════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ════════════════════════════════════════════════════════════
local function FT(o, p, t)  -- fast quart-out
	TweenService:Create(o, TweenInfo.new(t or 0.18,
		Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
local function ST(o, p, t)  -- spring (back-out)
	TweenService:Create(o, TweenInfo.new(t or 0.30,
		Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
end
local function LT(o, p, t)  -- linear (progress bars)
	TweenService:Create(o, TweenInfo.new(t or 0.25,
		Enum.EasingStyle.Linear, Enum.EasingDirection.Out), p):Play()
end
local function ET(o, p, t)  -- elastic (bounce micro-interactions)
	TweenService:Create(o, TweenInfo.new(t or 0.36,
		Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), p):Play()
end
local function SIT(o, p, t) -- sine-in-out (smooth reveal)
	TweenService:Create(o, TweenInfo.new(t or 0.22,
		Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), p):Play()
end

-- ════════════════════════════════════════════════════════════
--  UI PRIMITIVES
-- ════════════════════════════════════════════════════════════
local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function Stroke(p, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color           = col   or T.Border
	s.Thickness       = thick or 1
	s.Transparency    = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function Pad(p, top, bot, left, right)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, top   or 8)
	u.PaddingBottom = UDim.new(0, bot   or 8)
	u.PaddingLeft   = UDim.new(0, left  or 10)
	u.PaddingRight  = UDim.new(0, right or 10)
	u.Parent = p
	return u
end

local function MkFrame(parent, size, pos, col, clip, zi)
	local f = Instance.new("Frame")
	f.Size             = size or UDim2.new(1,0,0,40)
	f.Position         = pos  or UDim2.new(0,0,0,0)
	f.BackgroundColor3 = col  or T.Surface
	f.BorderSizePixel  = 0
	f.ClipsDescendants = clip or false
	if zi then f.ZIndex = zi end
	f.Parent = parent
	return f
end

local function MkLabel(parent, text, sz, col, font, xa, ya, wrap)
	local l = Instance.new("TextLabel")
	l.Text             = text or ""
	l.TextSize         = sz   or 13
	l.TextColor3       = col  or T.TxtMain
	l.Font             = font or Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.BorderSizePixel  = 0
	l.Size             = UDim2.new(1,0,1,0)
	l.TextXAlignment   = xa   or Enum.TextXAlignment.Left
	l.TextYAlignment   = ya   or Enum.TextYAlignment.Center
	l.TextWrapped      = wrap or false
	l.RichText         = false
	l.Parent = parent
	return l
end

local function MkButton(parent, text, sz, col, tcol, font)
	local b = Instance.new("TextButton")
	b.Text             = text or ""
	b.TextSize         = sz   or 13
	b.TextColor3       = tcol or T.TxtMain
	b.BackgroundColor3 = col  or T.SurfaceHi
	b.Font             = font or Enum.Font.GothamBold
	b.BorderSizePixel  = 0
	b.AutoButtonColor  = false
	b.Size             = UDim2.new(1,0,1,0)
	b.Parent = parent
	return b
end

-- Glass card shine  — thin top-edge highlight for depth
local function CardShine(card)
	local shine = MkFrame(card, UDim2.new(1,-6,0,1), UDim2.new(0,3,0,1), T.CardShine)
	shine.BackgroundTransparency = 0.88
	shine.ZIndex = card.ZIndex + 1
	Corner(shine, 2)
	-- Gradient: opaque in centre, fade to transparent at edges
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(0.1, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(0.9, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1,   Color3.new(1,1,1)),
	})
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   1),
		NumberSequenceKeypoint.new(0.12, 0.88),
		NumberSequenceKeypoint.new(0.5, 0.82),
		NumberSequenceKeypoint.new(0.88, 0.88),
		NumberSequenceKeypoint.new(1,   1),
	})
	g.Parent = shine
	return shine
end

-- ════════════════════════════════════════════════════════════
--  MkIcon — unified icon renderer
--  Supports:
--    • Plain ASCII text     e.g. "N"  "OK"  "!"
--    • rbxassetid string    e.g. "rbxassetid://12345678"
--    • Raw numeric string   e.g. "12345678"  (treated as asset ID)
--  Returns the created Instance so callers can set ZIndex etc.
-- ════════════════════════════════════════════════════════════
local function MkIcon(parent, icon, textSize, textColor, imgSize, zi)
	textSize  = textSize  or 18
	textColor = textColor or T.White
	imgSize   = imgSize   or UDim2.new(0.72, 0, 0.72, 0)   -- image fills ~72% of parent
	zi        = zi        or 4

	-- Detect whether icon is an asset ID
	local assetId = nil
	if type(icon) == "string" then
		-- "rbxassetid://123456"
		local fromPrefix = icon:match("^rbxassetid://(%d+)$")
		-- plain numeric string "123456"
		local fromNum    = (not fromPrefix) and icon:match("^%d+$") or nil
		assetId = fromPrefix or fromNum
	end

	if assetId then
		-- ── Image icon ────────────────────────────────────────
		local img = Instance.new("ImageLabel")
		img.Image                 = "rbxassetid://" .. assetId
		img.BackgroundTransparency = 1
		img.BorderSizePixel        = 0
		img.Size                   = imgSize
		img.AnchorPoint            = Vector2.new(0.5, 0.5)
		img.Position               = UDim2.new(0.5, 0, 0.5, 0)
		img.ImageColor3            = textColor   -- tintable
		img.ScaleType              = Enum.ScaleType.Fit
		img.ZIndex                 = zi
		img.Parent                 = parent
		return img
	else
		-- ── Text icon ─────────────────────────────────────────
		local lbl = Instance.new("TextLabel")
		lbl.Text                  = icon or ""
		lbl.TextSize              = textSize
		lbl.TextColor3            = textColor
		lbl.Font                  = Enum.Font.GothamBold
		lbl.BackgroundTransparency = 1
		lbl.BorderSizePixel        = 0
		lbl.Size                   = UDim2.new(1, 0, 1, 0)
		lbl.TextXAlignment         = Enum.TextXAlignment.Center
		lbl.TextYAlignment         = Enum.TextYAlignment.Center
		lbl.ZIndex                 = zi
		lbl.Parent                 = parent
		return lbl
	end
end

-- ════════════════════════════════════════════════════════════
--  DRAG  (mouse + touch)
-- ════════════════════════════════════════════════════════════
local function MakeDraggable(win, handle)
	handle = handle or win
	local drag, dragIn, mStart, fStart = false, nil, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag=true; mStart=i.Position; fStart=win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag=false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then dragIn=i end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i==dragIn and drag then
			local d = i.Position - mStart
			win.Position = UDim2.new(fStart.X.Scale, fStart.X.Offset+d.X,
			                         fStart.Y.Scale, fStart.Y.Offset+d.Y)
		end
	end)
end

-- ════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ════════════════════════════════════════════════════════════
local _ConfigReg = {}

local function _RegElement(winName, id, getter, setter, elType)
	if not id or id=="" then return end
	if not _ConfigReg[winName] then _ConfigReg[winName]={} end
	_ConfigReg[winName][id] = {Get=getter, Set=setter, Type=elType}
end
local function _EncodeColor(c)
	return {r=math.round(c.R*255), g=math.round(c.G*255), b=math.round(c.B*255)}
end
local function _DecodeColor(t)
	return Color3.fromRGB(t.r, t.g, t.b)
end

-- ════════════════════════════════════════════════════════════
--  LIBRARY
-- ════════════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI

-- ════════════════════════════════════════════════════════════
--  NOTIFICATION  (v1.7: icon-bubble scale pulse on appear)
-- ════════════════════════════════════════════════════════════
local _NH = nil
local function _InitNotifHolder(sg)
	if _NH then _NH:Destroy() end
	_NH = Instance.new("Frame")
	_NH.Name="NexusNotifHolder"; _NH.BackgroundTransparency=1; _NH.BorderSizePixel=0
	_NH.Size=UDim2.new(0,296,1,-20); _NH.Position=UDim2.new(1,-304,0,10)
	_NH.ZIndex=200; _NH.Parent=sg
	local ul=Instance.new("UIListLayout")
	ul.FillDirection=Enum.FillDirection.Vertical
	ul.VerticalAlignment=Enum.VerticalAlignment.Bottom
	ul.SortOrder=Enum.SortOrder.LayoutOrder
	ul.Padding=UDim.new(0,8); ul.Parent=_NH
end

function NexusUI:Notify(opt)
	opt=opt or {}
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	local icon   = opt.Icon     or "!"
	local accent = opt.Color    or T.Accent
	if not _NH then return end

	-- Card — starts off-screen right
	local card = MkFrame(_NH, UDim2.new(1,0,0,74), UDim2.new(1,20,0,0), T.NotifBG)
	card.ZIndex=200
	Corner(card, 13)
	Stroke(card, accent, 1, 0.25)
	CardShine(card)

	-- Gradient left edge — accent to transparent (top→bottom)
	local edgeGlow = MkFrame(card, UDim2.new(0,3,1,0), nil, accent)
	edgeGlow.ZIndex=201; edgeGlow.BackgroundTransparency=0
	Corner(edgeGlow, 3)
	local edgeG = Instance.new("UIGradient")
	edgeG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accent),
		ColorSequenceKeypoint.new(1, T.AccentDeep),
	})
	edgeG.Rotation=90; edgeG.Parent=edgeGlow

	-- Icon bubble (POLISH: starts small, springs to size)
	local icBox = MkFrame(card, UDim2.new(0,36,0,36), UDim2.new(0,12,0.5,-18), T.SurfaceHi)
	icBox.ZIndex=202; Corner(icBox,11); Stroke(icBox,accent,1,0.35)
	icBox.Size = UDim2.new(0,4,0,4)     -- start tiny for spring animation
	icBox.Position = UDim2.new(0,30,0.5,-2)

	-- MkIcon handles both text ("!") and image ("rbxassetid://123")
	local icWidget = MkIcon(icBox, icon, 15, accent, UDim2.new(0.68,0,0.68,0), 203)

	-- Title
	local tl = Instance.new("TextLabel")
	tl.Text=title; tl.TextSize=13; tl.Font=Enum.Font.GothamBold
	tl.TextColor3=T.TxtMain; tl.BackgroundTransparency=1; tl.BorderSizePixel=0
	tl.Size=UDim2.new(1,-78,0,20); tl.Position=UDim2.new(0,58,0,12)
	tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=201; tl.Parent=card

	-- Description
	if desc~="" then
		local dl=Instance.new("TextLabel")
		dl.Text=desc; dl.TextSize=11; dl.Font=Enum.Font.Gotham
		dl.TextColor3=T.TxtSub; dl.BackgroundTransparency=1; dl.BorderSizePixel=0
		dl.Size=UDim2.new(1,-78,0,18); dl.Position=UDim2.new(0,58,0,34)
		dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true
		dl.ZIndex=201; dl.Parent=card
	end

	-- Close x
	local xB=Instance.new("TextButton")
	xB.Text="x"; xB.TextSize=11; xB.Font=Enum.Font.GothamBold
	xB.TextColor3=T.TxtMute; xB.BackgroundTransparency=1; xB.BorderSizePixel=0
	xB.Size=UDim2.new(0,20,0,20); xB.Position=UDim2.new(1,-24,0,5)
	xB.ZIndex=202; xB.Parent=card
	xB.MouseEnter:Connect(function() FT(xB,{TextColor3=T.Red},0.1) end)
	xB.MouseLeave:Connect(function() FT(xB,{TextColor3=T.TxtMute},0.1) end)

	-- Progress bar
	local pgBg=MkFrame(card,UDim2.new(1,-20,0,3),UDim2.new(0,10,1,-9),T.SurfaceHi)
	pgBg.ZIndex=201; Corner(pgBg,2)
	local pgFill=MkFrame(pgBg,UDim2.new(1,0,1,0),nil,accent)
	pgFill.ZIndex=202; Corner(pgFill,2)
	LT(pgFill,{Size=UDim2.new(0,0,1,0)},dur)

	-- Slide in + icon spring
	FT(card, {Position=UDim2.new(0,0,0,0)}, 0.26)
	task.delay(0.05, function()
		if card and card.Parent then
			ST(icBox, {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,12,0.5,-18)}, 0.32)
		end
	end)

	-- Dismiss
	local gone=false
	local function Dismiss()
		if gone then return end; gone=true
		FT(card,{Position=UDim2.new(1,20,0,0), BackgroundTransparency=1},0.2)
		task.wait(0.22); card:Destroy()
	end
	xB.MouseButton1Click:Connect(Dismiss)
	task.delay(dur,Dismiss)
	return card
end

-- ════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(opt)
	opt=opt or {}
	local wTitle = opt.Title    or "NexusUI"
	local wSub   = opt.Subtitle or "v1.7"
	local wIcon  = opt.Icon     or "N"
	local wSize  = opt.Size     or UDim2.new(0,370,0,500)
	local wPos   = opt.Position or UDim2.new(0.5,-185,0.5,-250)
	local wName  = wTitle

	local sg = Instance.new("ScreenGui")
	sg.Name="NexusUI_"..wTitle; sg.ResetOnSpawn=false
	sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder=999; sg.IgnoreGuiInset=true
	local ok=pcall(function() sg.Parent=game:GetService("CoreGui") end)
	if not ok then sg.Parent=LocalPlayer:WaitForChild("PlayerGui") end
	_InitNotifHolder(sg)

	-- ──────────────────────────────────────────────────────
	--  MAIN WINDOW  (v1.7: spawn animation — scale+fade in)
	-- ──────────────────────────────────────────────────────
	local win = MkFrame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)

	-- UIStroke with animated brightness on open
	local winStroke = Stroke(win, Color3.fromRGB(80, 50, 158), 1.5)

	-- Thin top-edge glow line
	local topGlow = MkFrame(win, UDim2.new(1,-6,0,1), UDim2.new(0,3,0,0),
		Color3.fromRGB(148,96,255))
	topGlow.BackgroundTransparency=0.5; topGlow.ZIndex=10

	-- SPAWN ANIMATION: start transparent + slightly smaller, tween into place
	win.BackgroundTransparency = 1
	win.Size = UDim2.new(0, wSize.X.Offset, 0, wSize.Y.Offset * 0.88)
	win.Position = UDim2.new(wPos.X.Scale, wPos.X.Offset, wPos.Y.Scale, wPos.Y.Offset + 22)
	task.defer(function()
		FT(win, {BackgroundTransparency=0, Size=wSize, Position=wPos}, 0.32)
		-- Stroke brightens as it "arrives"
		FT(winStroke, {Color=Color3.fromRGB(100,62,195)}, 0.4)
	end)

	-- ──────────────────────────────────────────────────────
	--  TITLE BAR  (v1.7: deeper gradient, brighter icon pill)
	-- ──────────────────────────────────────────────────────
	local titleBar = MkFrame(win, UDim2.new(1,0,0,62), nil, T.Surface)
	Corner(titleBar, 16)
	MkFrame(titleBar, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Surface)

	local tbG = Instance.new("UIGradient")
	tbG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(52, 34, 96)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(34, 24, 66)),
		ColorSequenceKeypoint.new(1,   T.Surface),
	})
	tbG.Rotation=90; tbG.Parent=titleBar

	-- Separator with gradient fade
	local tbSep = MkFrame(titleBar, UDim2.new(1,-28,0,1), UDim2.new(0,14,1,-1),
		Color3.fromRGB(80,56,120))
	tbSep.BackgroundTransparency=0.55; tbSep.ZIndex=5
	local sepG = Instance.new("UIGradient")
	sepG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,1),
		NumberSequenceKeypoint.new(0.1,0.55),
		NumberSequenceKeypoint.new(0.9,0.55),
		NumberSequenceKeypoint.new(1,1),
	})
	sepG.Parent = tbSep

	MakeDraggable(win, titleBar)

	-- Icon pill (brighter, inner glow shine)
	local iconPill = MkFrame(titleBar, UDim2.new(0,42,0,42), UDim2.new(0,12,0.5,-21), T.AccentLo)
	Corner(iconPill,13); Stroke(iconPill, T.AccentHi, 1.5, 0.2)
	-- Inner shine
	local pShine = MkFrame(iconPill, UDim2.new(1,-4,0,14), UDim2.new(0,2,0,2), T.White)
	pShine.BackgroundTransparency=0.84; Corner(pShine,8)
	local pShineG = Instance.new("UIGradient")
	pShineG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0.84),
		NumberSequenceKeypoint.new(0.5,0.76),
		NumberSequenceKeypoint.new(1,0.84),
	})
	pShineG.Parent = pShine
	-- Glow behind pill
	local pillGlow = MkFrame(titleBar, UDim2.new(0,52,0,52), UDim2.new(0,7,0.5,-26),
		T.Accent)
	pillGlow.BackgroundTransparency=0.82; Corner(pillGlow,16); pillGlow.ZIndex=2
	-- MkIcon: text "W" or image "rbxassetid://12345678"
	MkIcon(iconPill, wIcon, 20, T.White, UDim2.new(0.72,0,0.72,0), 4)

	-- Title
	local titleL=MkLabel(titleBar, wTitle, 15, T.TxtMain, Enum.Font.GothamBold)
	titleL.Size=UDim2.new(1,-158,0,22); titleL.Position=UDim2.new(0,64,0,10)

	-- Version chip
	local verChip=MkFrame(titleBar, UDim2.new(0,0,0,18), UDim2.new(0,64,0,34), T.AccentDeep)
	verChip.AutomaticSize=Enum.AutomaticSize.X; Corner(verChip,6)
	Stroke(verChip, T.Accent, 1, 0.45)
	local verLbl=MkLabel(verChip, wSub, 10, T.AccentHi, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	verLbl.Size=UDim2.new(1,0,1,0); Pad(verChip,0,0,8,8)

	-- ── Control Buttons ────────────────────────────────────
	local function MkCtrlBtn(xOff, col)
		local box = MkFrame(titleBar, UDim2.new(0,28,0,28), UDim2.new(1,xOff,0.5,-14), col)
		Corner(box,9)
		local bb = MkButton(box,"",0,T.Black,T.White)
		bb.BackgroundTransparency=1; bb.Size=UDim2.new(1,0,1,0)
		return box, bb
	end

	local closeBox, closeBB = MkCtrlBtn(-38, T.Red)
	MkLabel(closeBox,"x",12,T.White,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	closeBB.MouseEnter:Connect(function()
		FT(closeBox,{BackgroundColor3=Color3.fromRGB(255,44,72)},0.12)
		ST(closeBox,{Size=UDim2.new(0,30,0,30)},0.14)
	end)
	closeBB.MouseLeave:Connect(function()
		FT(closeBox,{BackgroundColor3=T.Red},0.12)
		FT(closeBox,{Size=UDim2.new(0,28,0,28)},0.12)
	end)
	closeBB.MouseButton1Click:Connect(function()
		FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,0),BackgroundTransparency=1},0.22)
		task.wait(0.24); sg:Destroy()
	end)

	local minBox, minBB = MkCtrlBtn(-70, T.SurfaceHi)
	Stroke(minBox, T.Border, 1)
	local minLbl=MkLabel(minBox,"-",15,T.TxtSub,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	minBB.MouseEnter:Connect(function()
		FT(minBox,{BackgroundColor3=T.SurfaceHi2},0.12)
		ST(minBox,{Size=UDim2.new(0,30,0,30)},0.14)
	end)
	minBB.MouseLeave:Connect(function()
		FT(minBox,{BackgroundColor3=T.SurfaceHi},0.12)
		FT(minBox,{Size=UDim2.new(0,28,0,28)},0.12)
	end)

	-- ── Body ──────────────────────────────────────────────
	local body = MkFrame(win, UDim2.new(1,0,1,-62), UDim2.new(0,0,0,62), T.BG, true, 2)
	Corner(body,16)
	MkFrame(body, UDim2.new(1,0,0,16), nil, T.BG)

	-- Subtle vignette gradient on the body BG (edges darker)
	local vignette = MkFrame(body, UDim2.new(1,0,1,0), nil, T.Black)
	vignette.BackgroundTransparency=0.92; vignette.ZIndex=1
	local vigG = Instance.new("UIGradient")
	vigG.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0, T.Black),
		ColorSequenceKeypoint.new(0.15, Color3.new(0,0,0)),
		ColorSequenceKeypoint.new(0.85, Color3.new(0,0,0)),
		ColorSequenceKeypoint.new(1, T.Black),
	})
	vigG.Transparency=NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(0.15, 1),
		NumberSequenceKeypoint.new(0.85, 1),
		NumberSequenceKeypoint.new(1, 0.75),
	})
	vigG.Parent=vignette

	-- Bottom accent strip
	local bottomBar = MkFrame(win, UDim2.new(1,-6,0,4), UDim2.new(0,3,1,-4),
		Color3.fromRGB(78,52,142))
	bottomBar.BackgroundTransparency=0.58; bottomBar.ZIndex=3; Corner(bottomBar,4)
	local bbG = Instance.new("UIGradient")
	bbG.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,T.AccentDeep),
		ColorSequenceKeypoint.new(0.5,T.Accent),
		ColorSequenceKeypoint.new(1,T.AccentDeep),
	})
	bbG.Parent=bottomBar

	-- ── Minimize ──────────────────────────────────────────
	local minimized=false
	minBB.MouseButton1Click:Connect(function()
		minimized=not minimized
		if minimized then
			FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,62)},0.28); minLbl.Text="+"
		else
			FT(win,{Size=wSize},0.28); minLbl.Text="-"
		end
	end)

	-- ════════════════════════════════════════════════════════
	--  TAB BAR  (v1.7: sliding underline indicator)
	-- ════════════════════════════════════════════════════════
	local tabBar=MkFrame(body, UDim2.new(1,-20,0,36), UDim2.new(0,10,0,14), T.SurfaceHi, false, 3)
	Corner(tabBar,11); Stroke(tabBar,T.Border,1)

	-- Sliding active indicator pill (sits behind tab buttons)
	local tabIndicator=MkFrame(tabBar, UDim2.new(0,40,0,28), UDim2.new(0,4,0.5,-14), T.Accent)
	tabIndicator.ZIndex=3; Corner(tabIndicator,8)
	local tiG=Instance.new("UIGradient")
	tiG.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0,T.AccentHi),
		ColorSequenceKeypoint.new(1,T.AccentLo),
	})
	tiG.Rotation=90; tiG.Parent=tabIndicator

	local tabLL=Instance.new("UIListLayout")
	tabLL.FillDirection=Enum.FillDirection.Horizontal
	tabLL.VerticalAlignment=Enum.VerticalAlignment.Center
	tabLL.SortOrder=Enum.SortOrder.LayoutOrder
	tabLL.Padding=UDim.new(0,4); tabLL.Parent=tabBar
	Pad(tabBar,3,3,4,4)

	-- ── Content area ─────────────────────────────────────────
	-- UICorner(12): rounds the bottom-left and bottom-right corners so the
	-- content area sits flush inside the window's rounded frame.
	-- A top fill strip squares off the top edge (shared with the tab bar).
	local contentArea=MkFrame(body, UDim2.new(1,-2,1,-70), UDim2.new(0,1,0,68), T.BG, false, 3)
	Corner(contentArea, 12)
	-- Top fill — hides the rounded top corners (tab bar covers this zone)
	local caTopFill = MkFrame(contentArea, UDim2.new(1,0,0,12), nil, T.BG)
	caTopFill.ZIndex = 3

	local dropOverlay=MkFrame(body, UDim2.new(1,0,1,-68), UDim2.new(0,0,0,68), T.Black, false, 50)
	dropOverlay.BackgroundTransparency=1

	local tabs={}; local activeTab=nil

	-- ════════════════════════════════════════════════════════
	--  WINDOW API
	-- ════════════════════════════════════════════════════════
	local WinAPI={}
	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	function WinAPI:SaveConfig(configName)
		configName=configName or "default"
		local reg=_ConfigReg[wName]
		if not reg then warn("[NexusUI] No registered elements."); return end
		local data={}
		for id,entry in reg do
			local v=entry.Get()
			data[id] = entry.Type=="color" and _EncodeColor(v) or v
		end
		local json=HttpService:JSONEncode(data)
		local path="NexusUI_"..wName.."_"..configName..".json"
		local ok2=pcall(function() writefile(path,json) end)
		if ok2 then NexusUI:Notify({Title="Config Saved",Desc=path,Duration=3,Icon="OK",Color=T.Green})
		else print("[NexusUI] Config '"..configName.."':\n"..json)
			NexusUI:Notify({Title="Config (print fallback)",Desc="See output",Duration=3,Icon="!",Color=T.Yellow})
		end
	end

	function WinAPI:LoadConfig(configName)
		configName=configName or "default"
		local reg=_ConfigReg[wName]
		if not reg then warn("[NexusUI] No registered elements."); return end
		local path="NexusUI_"..wName.."_"..configName..".json"
		local ok2,json=pcall(function() return readfile(path) end)
		if not ok2 or not json then
			NexusUI:Notify({Title="Config Not Found",Desc=path,Duration=3,Icon="!",Color=T.Red}); return
		end
		for id,val in HttpService:JSONDecode(json) do
			if reg[id] then
				pcall(function()
					reg[id].Set(reg[id].Type=="color" and _DecodeColor(val) or val)
				end)
			end
		end
		NexusUI:Notify({Title="Config Loaded",Desc=path,Duration=3,Icon="OK",Color=T.Green})
	end

	-- ════════════════════════════════════════════════════════
	--  ADD TAB
	-- ════════════════════════════════════════════════════════
	function WinAPI:AddTab(tabName)
		local tabBtn=Instance.new("TextButton")
		tabBtn.Text=tabName; tabBtn.TextSize=12; tabBtn.Font=Enum.Font.GothamSemibold
		tabBtn.TextColor3=T.TxtMute; tabBtn.BackgroundColor3=T.Black
		tabBtn.BackgroundTransparency=1; tabBtn.BorderSizePixel=0
		tabBtn.AutoButtonColor=false; tabBtn.AutomaticSize=Enum.AutomaticSize.X
		tabBtn.Size=UDim2.new(0,10,1,0); tabBtn.ZIndex=5; tabBtn.Parent=tabBar
		Pad(tabBtn,0,0,10,10); Corner(tabBtn,8)

		local page=Instance.new("ScrollingFrame")
		page.BackgroundTransparency=1; page.BorderSizePixel=0
		page.Size=UDim2.new(1,0,1,0); page.CanvasSize=UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize=Enum.AutomaticSize.Y
		-- POLISH: scrollbar styled, thinner
		page.ScrollBarThickness=3
		page.ScrollBarImageColor3=T.Accent
		page.ScrollBarImageTransparency=0.5
		page.ScrollingDirection=Enum.ScrollingDirection.Y
		page.Visible=false; page.ZIndex=3; page.Parent=contentArea
		local ll=Instance.new("UIListLayout")
		ll.FillDirection=Enum.FillDirection.Vertical; ll.SortOrder=Enum.SortOrder.LayoutOrder
		ll.Padding=UDim.new(0,7); ll.Parent=page
		Pad(page,10,18,10,10)

		local tabData={Btn=tabBtn, Page=page}
		table.insert(tabs,tabData)

		local function Activate()
			if activeTab then
				FT(activeTab.Btn,{TextColor3=T.TxtMute},0.16)
				activeTab.Page.Visible=false
			end
			activeTab=tabData
			FT(tabBtn,{TextColor3=T.White},0.16)
			page.Visible=true

			-- POLISH: slide the indicator to this tab
			task.defer(function()
				if not tabBtn.Parent then return end
				local bAX = tabBtn.AbsolutePosition.X
				local barAX = tabBar.AbsolutePosition.X
				local relX = bAX - barAX - 4  -- subtract tabBar padding
				local bW   = tabBtn.AbsoluteSize.X
				FT(tabIndicator, {
					Size     = UDim2.new(0, bW, 0, 28),
					Position = UDim2.new(0, relX, 0.5, -14),
				}, 0.22)
			end)
		end
		tabBtn.MouseButton1Click:Connect(Activate)
		if #tabs==1 then
			task.defer(Activate)  -- defer so AbsolutePosition is ready
		end

		-- ────────────────────────────────────────────────
		--  ELEMENT API
		-- ────────────────────────────────────────────────
		local API={}

		-- ── Card helper ────────────────────────────────
		-- v3.5: adds glass shine, slightly deeper surface
		local function Card(h, transparentBG)
			local bgCol = transparentBG and T.Surface or T.Surface
			local c=MkFrame(page, UDim2.new(1,0,0,h), nil, bgCol)
			c.ZIndex=4
			if transparentBG then c.BackgroundTransparency=0.28 end
			Corner(c,12); Stroke(c,T.Border,1); Pad(c,0,0,14,14)
			CardShine(c)  -- glass top-shine
			return c
		end

		-- ── SECTION ─────────────────────────────────────────────
		-- v3.5: gradient-fade lines, letter spaced text
		function API:AddSection(name)
			local w=MkFrame(page,UDim2.new(1,0,0,26),nil,T.Black)
			w.BackgroundTransparency=1; w.ZIndex=4

			local function FadeLine(xScale, xOff, wScale)
				local l=MkFrame(w,UDim2.new(wScale,-4,0,1),UDim2.new(xScale,xOff,0.5,0),T.BorderBri)
				l.ZIndex=4
				local g=Instance.new("UIGradient")
				g.Transparency=NumberSequence.new({
					NumberSequenceKeypoint.new(0, xScale==0 and 1 or 0.4),
					NumberSequenceKeypoint.new(0.5, 0.4),
					NumberSequenceKeypoint.new(1, xScale==0 and 0.4 or 1),
				})
				g.Parent=l
			end
			FadeLine(0,0, 0.28)
			FadeLine(0.72,0, 0.28)

			-- Add spaces for letter-spacing effect
			local spaced=""
			for i=1,#name do
				spaced=spaced..name:sub(i,i)
				if i<#name then spaced=spaced.." " end
			end
			local sl=MkLabel(w, spaced:upper(), 9, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			sl.Size=UDim2.new(0.44,0,1,0); sl.Position=UDim2.new(0.28,0,0,0); sl.ZIndex=4
		end

		function API:AddSeparator()
			local s=MkFrame(page,UDim2.new(1,-24,0,1),UDim2.new(0,12,0,0),T.Border)
			s.ZIndex=4
			local sg2=Instance.new("UIGradient")
			sg2.Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,1),
				NumberSequenceKeypoint.new(0.1,0),
				NumberSequenceKeypoint.new(0.9,0),
				NumberSequenceKeypoint.new(1,1),
			})
			sg2.Parent=s
		end

		-- ── LABEL ───────────────────────────────────────────────
		function API:AddLabel(opt)
			opt=type(opt)=="string" and {Text=opt} or (opt or {})
			local text  =opt.Text     or "Label"
			local color =opt.Color    or T.TxtSub
			local align =opt.Align    or "Left"
			local size  =opt.TextSize or 13
			local font  =opt.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
			local xa=align=="Center" and Enum.TextXAlignment.Center
				or align=="Right" and Enum.TextXAlignment.Right
				or Enum.TextXAlignment.Left
			local wrap=MkFrame(page,UDim2.new(1,0,0,26),nil,T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4
			local lbl=MkLabel(wrap,text,size,color,font,xa,Enum.TextYAlignment.Center,true)
			lbl.Size=UDim2.new(1,-20,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.ZIndex=5
			local L={}; function L:SetText(t) lbl.Text=t end; function L:SetColor(c) lbl.TextColor3=c end
			return L
		end

		-- ── PARAGRAPH ───────────────────────────────────────────
		function API:AddParagraph(opt)
			opt=opt or {}
			local title  =opt.Title   or "Paragraph"
			local content=opt.Content or ""
			local color  =opt.Color   or T.TxtSub
			local lineH=18
			local rawLines=math.max(1,math.ceil(#content/40))
			local cardH=math.max(14+22+8+rawLines*lineH+14, 60)

			local card=MkFrame(page,UDim2.new(1,0,0,cardH),nil,T.Surface)
			card.BackgroundTransparency=0.22; card.ZIndex=4
			Corner(card,12); Stroke(card,T.Border,1,0.2); Pad(card,10,10,14,14)
			CardShine(card)

			-- Left accent strip with gradient
			local strip=MkFrame(card,UDim2.new(0,3,1,-20),UDim2.new(0,0,0,10),T.Accent)
			strip.ZIndex=5; Corner(strip,3)
			local stripG=Instance.new("UIGradient")
			stripG.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,T.AccentHi),
				ColorSequenceKeypoint.new(1,T.AccentLo),
			})
			stripG.Rotation=90; stripG.Parent=strip

			local tl=MkLabel(card,title,13,T.TxtMain,Enum.Font.GothamBold)
			tl.Size=UDim2.new(1,-10,0,22); tl.ZIndex=5

			local cl=Instance.new("TextLabel")
			cl.Text=content; cl.TextSize=12; cl.Font=Enum.Font.Gotham
			cl.TextColor3=color; cl.BackgroundTransparency=1; cl.BorderSizePixel=0
			cl.Size=UDim2.new(1,-10,0,cardH-46); cl.Position=UDim2.new(0,0,0,28)
			cl.TextXAlignment=Enum.TextXAlignment.Left; cl.TextYAlignment=Enum.TextYAlignment.Top
			cl.TextWrapped=true; cl.ZIndex=5; cl.Parent=card

			local P={}; function P:SetTitle(t) tl.Text=t end; function P:SetContent(c) cl.Text=c end
			return P
		end

		-- ══════════════════════════════════════════════════
		--  BUTTON
		--  v1.7: white shine overlay on pill, ripple on press
		-- ══════════════════════════════════════════════════
		function API:AddButton(opt)
			opt=opt or {}
			local name=opt.Name or "Button"; local desc=opt.Desc or ""
			local icon=opt.Icon or ""; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent

			local cardH=desc~="" and 60 or 48; local card=Card(cardH)

			local iOff=0
			if icon~="" then
				iOff=40
				local icB=MkFrame(card,UDim2.new(0,30,0,30),UDim2.new(0,0,0.5,-15),T.AccentDeep)
				icB.ZIndex=5; Corner(icB,9); Stroke(icB,color,1,0.3)
				-- MkIcon: "L" text OR "rbxassetid://12345678" image
				MkIcon(icB, icon, 15, color, UDim2.new(0.72,0,0.72,0), 6)
			end

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,-(iOff+92),0,desc~="" and 20 or 32)
			nl.Position=UDim2.new(0,iOff,0,desc~="" and 5 or 0)
			nl.TextYAlignment=Enum.TextYAlignment.Center; nl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-(iOff+92),0,16); dl.Position=UDim2.new(0,iOff,0,28); dl.ZIndex=5
			end

			-- Gradient pill
			local pillW=78
			local aPill=MkFrame(card,UDim2.new(0,pillW,0,32),UDim2.new(1,-pillW,0.5,-16),color)
			aPill.ZIndex=5; Corner(aPill,10)
			local aGrad=Instance.new("UIGradient")
			aGrad.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,T.AccentHi),
				ColorSequenceKeypoint.new(1,color),
			})
			aGrad.Rotation=95; aGrad.Parent=aPill

			-- POLISH: white shine on top of pill
			local pillShine=MkFrame(aPill, UDim2.new(1,-6,0,10), UDim2.new(0,3,0,2), T.White)
			pillShine.BackgroundTransparency=0.82; pillShine.ZIndex=6; Corner(pillShine,4)
			local psG=Instance.new("UIGradient")
			psG.Transparency=NumberSequence.new({
				NumberSequenceKeypoint.new(0,1),
				NumberSequenceKeypoint.new(0.3,0.82),
				NumberSequenceKeypoint.new(0.7,0.82),
				NumberSequenceKeypoint.new(1,1),
			})
			psG.Parent=pillShine

			local aLbl=MkLabel(aPill,"Run",12,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			aLbl.ZIndex=7

			local aBB=MkButton(aPill,"",0,T.Black,T.White)
			aBB.BackgroundTransparency=1; aBB.Size=UDim2.new(1,0,1,0); aBB.ZIndex=8

			local running=false
			local function DoRun()
				if running then return end; running=true
				-- POLISH: press ripple — shrink then spring back
				FT(aPill,{Size=UDim2.new(0,pillW-6,0,26)},0.08)
				task.wait(0.09)
				ST(aPill,{Size=UDim2.new(0,pillW,0,32)},0.2)
				aLbl.Text="Done"
				FT(aLbl,{TextColor3=T.Green},0.1)
				task.delay(0.85,function()
					if aLbl and aLbl.Parent then
						aLbl.Text="Run"; FT(aLbl,{TextColor3=T.White},0.15)
					end
				end)
				pcall(cb); running=false
			end

			aBB.MouseEnter:Connect(function() aGrad.Enabled=false; FT(aPill,{BackgroundColor3=T.AccentHi},0.12) end)
			aBB.MouseLeave:Connect(function() aGrad.Enabled=true;  FT(aPill,{BackgroundColor3=color},0.12) end)
			aBB.MouseButton1Click:Connect(DoRun)

			local cBB=MkButton(card,"",0,T.Black,T.White)
			cBB.BackgroundTransparency=1; cBB.Size=UDim2.new(1,-(pillW+8),1,0); cBB.ZIndex=5
			cBB.MouseEnter:Connect(function() FT(card,{BackgroundColor3=T.SurfaceHi},0.14) end)
			cBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},0.14) end)
			cBB.MouseButton1Click:Connect(DoRun)
		end

		-- ══════════════════════════════════════════════════
		--  TOGGLE
		--  v1.7: thumb size-bounce on toggle
		-- ══════════════════════════════════════════════════
		function API:AddToggle(opt)
			opt=opt or {}
			local name=opt.Name or "Toggle"; local desc=opt.Desc or ""
			local def=opt.Default or false; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent; local id=opt.Id or ""

			local cardH=desc~="" and 58 or 46; local card=Card(cardH)

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,-70,0,22)
			nl.Position=UDim2.new(0,0,0,desc~="" and 4 or 0)
			nl.TextYAlignment=Enum.TextYAlignment.Center; nl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-70,0,16); dl.Position=UDim2.new(0,0,0,28); dl.ZIndex=5
			end

			local track=MkFrame(card,UDim2.new(0,52,0,28),UDim2.new(1,-52,0.5,-14),T.TogOff)
			track.ZIndex=5; Corner(track,14); Stroke(track,T.Border,1)

			-- POLISH: inner track shadow for depth
			local tInner=MkFrame(track,UDim2.new(1,0,0.5,0),UDim2.new(0,0,0.5,0),T.Black)
			tInner.BackgroundTransparency=0.88; tInner.ZIndex=5

			local thumb=MkFrame(track,UDim2.new(0,22,0,22),UDim2.new(0,3,0.5,-11),T.White)
			thumb.ZIndex=6; Corner(thumb,11)
			local tStr=Stroke(thumb,T.Border,1.5)

			-- POLISH: thumb shine
			local tShine=MkFrame(thumb,UDim2.new(1,-4,0,8),UDim2.new(0,2,0,2),T.White)
			tShine.BackgroundTransparency=0.82; tShine.ZIndex=7; Corner(tShine,4)

			local state=def; local busy=false
			local function Refresh(anim)
				if state then
					if anim then
						FT(track,{BackgroundColor3=color},0.2)
						ST(thumb,{Position=UDim2.new(0,27,0.5,-11)},0.24)
						FT(tStr,{Color=color,Thickness=2},0.2)
						-- POLISH: thumb squash on toggle ON
						FT(thumb,{Size=UDim2.new(0,18,0,22)},0.06)
						task.delay(0.07,function()
							if thumb and thumb.Parent then
								ET(thumb,{Size=UDim2.new(0,22,0,22)},0.28)
							end
						end)
					else
						track.BackgroundColor3=color; thumb.Position=UDim2.new(0,27,0.5,-11)
						tStr.Color=color; tStr.Thickness=2
					end
				else
					if anim then
						FT(track,{BackgroundColor3=T.TogOff},0.2)
						ST(thumb,{Position=UDim2.new(0,3,0.5,-11)},0.24)
						FT(tStr,{Color=T.Border,Thickness=1.5},0.2)
						-- POLISH: thumb squash on toggle OFF
						FT(thumb,{Size=UDim2.new(0,18,0,22)},0.06)
						task.delay(0.07,function()
							if thumb and thumb.Parent then
								ET(thumb,{Size=UDim2.new(0,22,0,22)},0.28)
							end
						end)
					else
						track.BackgroundColor3=T.TogOff; thumb.Position=UDim2.new(0,3,0.5,-11)
						tStr.Color=T.Border; tStr.Thickness=1.5
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy then return end; busy=true; state=not state; Refresh(true)
				pcall(cb,state); task.wait(0.32); busy=false
			end
			track.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog={}
			function Tog:Set(v) state=v; Refresh(true) end
			function Tog:Get() return state end
			_RegElement(wName,id,function() return state end,function(v) state=v;Refresh(true) end,"bool")
			return Tog
		end

		-- ══════════════════════════════════════════════════
		--  SLIDER
		--  v1.7: track glows while dragging, knob pulse
		-- ══════════════════════════════════════════════════
		function API:AddSlider(opt)
			opt=opt or {}
			local name=opt.Name or "Slider"; local desc=opt.Desc or ""
			local min=opt.Min or 0; local max=opt.Max or 100
			local def=opt.Default or min; local sfx=opt.Suffix or ""
			local cb=opt.Callback or function() end; local color=opt.Color or T.Accent
			local id=opt.Id or ""

			local cardH=desc~="" and 76 or 64; local card=Card(cardH)

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.62,0,0,20); nl.ZIndex=5
			local vl=MkLabel(card,tostring(def)..sfx,13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.38,0,0,20); vl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,0,0,14); dl.Position=UDim2.new(0,0,0,22); dl.ZIndex=5
			end

			local yOff=desc~="" and 44 or 30

			-- Track with subtle inner gradient
			local tBG=MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,yOff),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)
			local tBGg=Instance.new("UIGradient")
			tBGg.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.SurfaceHi2),
				ColorSequenceKeypoint.new(1, T.SurfaceHi),
			})
			tBGg.Rotation=90; tBGg.Parent=tBG

			-- Fill
			local fill=MkFrame(tBG,UDim2.new(0,0,1,0),nil,color)
			fill.ZIndex=6; Corner(fill,5)
			local fG=Instance.new("UIGradient")
			fG.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,T.AccentHi),
				ColorSequenceKeypoint.new(1,color),
			})
			fG.Parent=fill

			-- Fill top-shine
			local fShine=MkFrame(fill,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White)
			fShine.BackgroundTransparency=0.86; fShine.ZIndex=7; Corner(fShine,4)

			-- Knob
			local knob=MkFrame(tBG,UDim2.new(0,22,0,22),UDim2.new(0,-11,0.5,-11),T.White)
			knob.ZIndex=7; Corner(knob,11); local kR=Stroke(knob,color,2)
			-- Knob shine
			local kSh=MkFrame(knob,UDim2.new(1,-4,0,8),UDim2.new(0,2,0,2),T.White)
			kSh.BackgroundTransparency=0.82; kSh.ZIndex=8; Corner(kSh,4)

			-- POLISH: track glow frame (hidden until drag)
			local trackGlow=Stroke(tBG,T.AccentHi,2,1)

			local val=math.clamp(def,min,max); local sliding=false
			local function SetVal(v)
				val=math.clamp(v,min,max)
				local pct=(val-min)/(max-min)
				FT(fill,{Size=UDim2.new(pct,0,1,0)},0.06)
				FT(knob,{Position=UDim2.new(pct,-11,0.5,-11)},0.06)
				vl.Text=tostring(math.round(val))..sfx
			end
			SetVal(def)

			local function FromPos(p2)
				return min+math.clamp((p2.X-tBG.AbsolutePosition.X)/tBG.AbsoluteSize.X,0,1)*(max-min)
			end

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=true
					-- POLISH: knob expand + track glows
					ST(knob,{Size=UDim2.new(0,26,0,26)},0.12)
					FT(kR,{Thickness=3},0.12)
					FT(trackGlow,{Transparency=0.5},0.2)
					SetVal(FromPos(i.Position)); pcall(cb,math.round(val))
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
				or  i.UserInputType==Enum.UserInputType.Touch) then
					SetVal(FromPos(i.Position)); pcall(cb,math.round(val))
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=false
					FT(knob,{Size=UDim2.new(0,22,0,22)},0.14)
					FT(kR,{Thickness=2},0.14)
					FT(trackGlow,{Transparency=1},0.22)
				end
			end)

			local Sl={}
			function Sl:Set(v) SetVal(v) end
			function Sl:Get() return math.round(val) end
			_RegElement(wName,id,function() return math.round(val) end,
				function(v) SetVal(tonumber(v) or min) end,"number")
			return Sl
		end

		-- ══════════════════════════════════════════════════
		--  DROPDOWN  (single-select)
		-- ══════════════════════════════════════════════════
		function API:AddDropdown(opt)
			opt=opt or {}
			local name=opt.Name or "Dropdown"; local items=opt.Items or {"Option 1","Option 2"}
			local def=opt.Default or items[1]; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent; local id=opt.Id or ""

			local card=Card(46); local selVal=def; local isOpen=false
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.36,0,1,0); nl.ZIndex=5

			local pill=MkFrame(card,UDim2.new(0.62,0,0,32),UDim2.new(0.38,0,0.5,-16),T.SurfaceHi)
			pill.ZIndex=5; Corner(pill,10); Stroke(pill,T.Border,1)
			CardShine(pill)

			local pillLbl=MkLabel(pill,selVal,12,T.TxtMain,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-28,1,0); pillLbl.Position=UDim2.new(0,10,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd
			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chevLbl.Size=UDim2.new(0,22,1,0); chevLbl.Position=UDim2.new(1,-24,0,0); chevLbl.ZIndex=6

			local listFrame=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			listFrame.ZIndex=50; listFrame.Visible=false; listFrame.ClipsDescendants=true
			Corner(listFrame,12); Stroke(listFrame,T.BorderGlow,1,0.3)
			CardShine(listFrame)

			local listInner=MkFrame(listFrame,UDim2.new(1,0,1,0),nil,T.Black)
			listInner.BackgroundTransparency=1; listInner.ZIndex=51
			local liLL=Instance.new("UIListLayout")
			liLL.FillDirection=Enum.FillDirection.Vertical; liLL.SortOrder=Enum.SortOrder.LayoutOrder
			liLL.Padding=UDim.new(0,3); liLL.Parent=listInner; Pad(listInner,5,5,5,5)

			local sBG=MkFrame(listInner,UDim2.new(1,0,0,30),nil,T.SurfaceHi)
			sBG.ZIndex=52; Corner(sBG,8); Stroke(sBG,T.Border,1)
			local sTB=Instance.new("TextBox")
			sTB.PlaceholderText="Search..."; sTB.PlaceholderColor3=T.TxtMute
			sTB.Text=""; sTB.TextColor3=T.TxtMain; sTB.BackgroundTransparency=1
			sTB.Font=Enum.Font.Gotham; sTB.TextSize=12; sTB.Size=UDim2.new(1,-14,1,0)
			sTB.Position=UDim2.new(0,7,0,0); sTB.TextXAlignment=Enum.TextXAlignment.Left
			sTB.ClearTextOnFocus=false; sTB.ZIndex=53; sTB.Parent=sBG

			local itemsSF=Instance.new("ScrollingFrame")
			itemsSF.BackgroundTransparency=1; itemsSF.BorderSizePixel=0
			itemsSF.Size=UDim2.new(1,0,0,0); itemsSF.CanvasSize=UDim2.new(0,0,0,0)
			itemsSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			itemsSF.ScrollBarThickness=2; itemsSF.ScrollBarImageColor3=T.Accent
			itemsSF.ZIndex=52; itemsSF.Parent=listInner
			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical; iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,2); iLL.Parent=itemsSF

			local allRows={}
			local function CloseList()
				if not isOpen then return end; isOpen=false
				FT(listFrame,{Size=UDim2.new(1,-20,0,0)},0.18)
				FT(chevLbl,{Rotation=0},0.18); FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.wait(0.2); listFrame.Visible=false; sTB.Text=""
			end

			local function BuildItems(filter)
				filter=(filter or ""):lower()
				for _,r in allRows do r.Parent=nil end; allRows={}
				local count=0
				for _,item in items do
					if filter=="" or item:lower():find(filter,1,true) then
						count+=1
						local row=MkFrame(itemsSF,UDim2.new(1,0,0,32),nil,T.Black)
						row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)
						local ck=MkLabel(row,selVal==item and ">" or "",12,color,Enum.Font.GothamBold,
							Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
						ck.Size=UDim2.new(0,24,1,0); ck.ZIndex=54
						local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham)
						iLbl.Size=UDim2.new(1,-28,1,0); iLbl.Position=UDim2.new(0,26,0,0); iLbl.ZIndex=54
						local hit=MkButton(row,"",0,T.Black,T.White)
						hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
						hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.1) end)
						hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},0.1) end)
						hit.MouseButton1Click:Connect(function()
							selVal=item; pillLbl.Text=item; CloseList(); BuildItems(""); pcall(cb,item)
						end)
						table.insert(allRows,row)
					end
				end
				itemsSF.Size=UDim2.new(1,0,0,math.min(count,5)*34+4)
			end
			BuildItems("")
			sTB:GetPropertyChangedSignal("Text"):Connect(function() BuildItems(sTB.Text) end)

			local pillBB=MkButton(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=7
			pillBB.MouseButton1Click:Connect(function()
				if isOpen then CloseList(); return end
				isOpen=true; BuildItems("")
				local oAY=dropOverlay.AbsolutePosition.Y
				local yPos=(card.AbsolutePosition.Y-oAY)+card.AbsoluteSize.Y+4
				local listH=44+math.min(#items,5)*34+10
				listFrame.Position=UDim2.new(0,10,0,yPos); listFrame.Size=UDim2.new(1,-20,0,0)
				listFrame.Visible=true
				FT(listFrame,{Size=UDim2.new(1,-20,0,listH)},0.22)
				FT(chevLbl,{Rotation=180},0.18); FT(pill,{BackgroundColor3=T.SurfaceHi2},0.12)
			end)
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					local lx,ly=listFrame.AbsolutePosition.X,listFrame.AbsolutePosition.Y
					local lw,lh=listFrame.AbsoluteSize.X,listFrame.AbsoluteSize.Y
					local px,py=pill.AbsolutePosition.X,pill.AbsolutePosition.Y
					local pw,ph=pill.AbsoluteSize.X,pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not(mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh)
					and not(mx>=px and mx<=px+pw and my>=py and my<=py+ph) then CloseList() end
				end
			end)

			local Drop={}
			function Drop:Get() return selVal end
			function Drop:Set(v) selVal=v; pillLbl.Text=v; BuildItems("") end
			function Drop:Refresh(ni) items=ni; selVal=ni[1] or ""; pillLbl.Text=selVal; BuildItems("") end
			_RegElement(wName,id,function() return selVal end,
				function(v) selVal=tostring(v); pillLbl.Text=selVal; BuildItems("") end,"string")
			return Drop
		end

		-- ══════════════════════════════════════════════════
		--  MULTI DROPDOWN
		-- ══════════════════════════════════════════════════
		function API:AddMultiDropdown(opt)
			opt=opt or {}
			local name=opt.Name or "Multi Select"; local items=opt.Items or {"Item 1","Item 2"}
			local def=opt.Default or {}; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent; local id=opt.Id or ""

			local card=Card(46); local selected={}; local isOpen=false
			for _,v in def do selected[v]=true end

			local function GetSelected()
				local t={}
				for _,item in items do if selected[item] then table.insert(t,item) end end
				return t
			end
			local function PillText()
				local t=GetSelected()
				if #t==0 then return "None"
				elseif #t==1 then return t[1]
				else return t[1].." +"..tostring(#t-1) end
			end

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.36,0,1,0); nl.ZIndex=5

			local pill=MkFrame(card,UDim2.new(0.62,0,0,32),UDim2.new(0.38,0,0.5,-16),T.SurfaceHi)
			pill.ZIndex=5; Corner(pill,10); Stroke(pill,T.Border,1); CardShine(pill)

			local pillLbl=MkLabel(pill,PillText(),12,T.TxtMain,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-46,1,0); pillLbl.Position=UDim2.new(0,10,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd

			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chevLbl.Size=UDim2.new(0,22,1,0); chevLbl.Position=UDim2.new(1,-24,0,0); chevLbl.ZIndex=6

			local badge=MkFrame(pill,UDim2.new(0,18,0,18),UDim2.new(1,-44,0.5,-9),T.Accent)
			badge.ZIndex=7; Corner(badge,9)
			local badgeLbl=MkLabel(badge,"0",10,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			badgeLbl.ZIndex=8
			local function RefBadge()
				local n=#GetSelected()
				badgeLbl.Text=tostring(n); badge.BackgroundTransparency=n==0 and 1 or 0
			end
			RefBadge()

			local listFrame=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			listFrame.ZIndex=50; listFrame.Visible=false; listFrame.ClipsDescendants=true
			Corner(listFrame,12); Stroke(listFrame,T.BorderGlow,1,0.3); CardShine(listFrame)

			local listInner=MkFrame(listFrame,UDim2.new(1,0,1,0),nil,T.Black)
			listInner.BackgroundTransparency=1; listInner.ZIndex=51
			local liLL=Instance.new("UIListLayout")
			liLL.FillDirection=Enum.FillDirection.Vertical; liLL.SortOrder=Enum.SortOrder.LayoutOrder
			liLL.Padding=UDim.new(0,3); liLL.Parent=listInner; Pad(listInner,5,5,5,5)

			local actionRow=MkFrame(listInner,UDim2.new(1,0,0,28),nil,T.SurfaceHi)
			actionRow.ZIndex=52; Corner(actionRow,8)
			local sAB=MkButton(actionRow,"Select All",11,T.AccentLo,T.AccentHi,Enum.Font.GothamBold)
			sAB.BackgroundTransparency=1; sAB.Size=UDim2.new(0.5,0,1,0); sAB.TextXAlignment=Enum.TextXAlignment.Center
			local cAB=MkButton(actionRow,"Clear",11,T.AccentLo,T.TxtMute,Enum.Font.GothamBold)
			cAB.BackgroundTransparency=1; cAB.Size=UDim2.new(0.5,0,1,0)
			cAB.Position=UDim2.new(0.5,0,0,0); cAB.TextXAlignment=Enum.TextXAlignment.Center

			local itemsSF=Instance.new("ScrollingFrame")
			itemsSF.BackgroundTransparency=1; itemsSF.BorderSizePixel=0
			itemsSF.Size=UDim2.new(1,0,0,0); itemsSF.CanvasSize=UDim2.new(0,0,0,0)
			itemsSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			itemsSF.ScrollBarThickness=2; itemsSF.ScrollBarImageColor3=T.Accent
			itemsSF.ZIndex=52; itemsSF.Parent=listInner
			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical; iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,2); iLL.Parent=itemsSF

			local rowRefs={}
			local function BuildMI()
				for _,r in rowRefs do r.rowFrame.Parent=nil end; rowRefs={}
				for _,item in items do
					local row=MkFrame(itemsSF,UDim2.new(1,0,0,34),nil,T.Black)
					row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)
					local cbBox=MkFrame(row,UDim2.new(0,20,0,20),UDim2.new(0,6,0.5,-10),T.SurfaceHi2)
					cbBox.ZIndex=54; Corner(cbBox,5); Stroke(cbBox,T.Border,1)
					local ckM=MkLabel(cbBox,selected[item] and ">" or "",11,color,Enum.Font.GothamBold,
						Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
					ckM.ZIndex=55
					if selected[item] then cbBox.BackgroundColor3=T.AccentDeep end
					local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham)
					iLbl.Size=UDim2.new(1,-36,1,0); iLbl.Position=UDim2.new(0,34,0,0); iLbl.ZIndex=54
					local hit=MkButton(row,"",0,T.Black,T.White)
					hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
					hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.1) end)
					hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},0.1) end)
					hit.MouseButton1Click:Connect(function()
						selected[item]=not selected[item]; ckM.Text=selected[item] and ">" or ""
						FT(cbBox,{BackgroundColor3=selected[item] and T.AccentDeep or T.SurfaceHi2},0.12)
						pillLbl.Text=PillText(); RefBadge(); pcall(cb,GetSelected())
					end)
					table.insert(rowRefs,{item=item,rowFrame=row})
				end
				itemsSF.Size=UDim2.new(1,0,0,math.min(#items,5)*36+4)
			end
			BuildMI()

			sAB.MouseButton1Click:Connect(function()
				for _,i in items do selected[i]=true end
				BuildMI(); pillLbl.Text=PillText(); RefBadge(); pcall(cb,GetSelected())
			end)
			cAB.MouseButton1Click:Connect(function()
				for _,i in items do selected[i]=false end
				BuildMI(); pillLbl.Text=PillText(); RefBadge(); pcall(cb,GetSelected())
			end)

			local function CloseMulti()
				if not isOpen then return end; isOpen=false
				FT(listFrame,{Size=UDim2.new(1,-20,0,0)},0.18)
				FT(chevLbl,{Rotation=0},0.18); FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.wait(0.2); listFrame.Visible=false
			end

			local pBB=MkButton(pill,"",0,T.Black,T.White)
			pBB.BackgroundTransparency=1; pBB.Size=UDim2.new(1,0,1,0); pBB.ZIndex=7
			pBB.MouseButton1Click:Connect(function()
				if isOpen then CloseMulti(); return end
				isOpen=true; BuildMI()
				local oAY=dropOverlay.AbsolutePosition.Y
				local yPos=(card.AbsolutePosition.Y-oAY)+card.AbsoluteSize.Y+4
				local listH=38+math.min(#items,5)*36+12
				listFrame.Position=UDim2.new(0,10,0,yPos); listFrame.Size=UDim2.new(1,-20,0,0)
				listFrame.Visible=true
				FT(listFrame,{Size=UDim2.new(1,-20,0,listH)},0.22)
				FT(chevLbl,{Rotation=180},0.18); FT(pill,{BackgroundColor3=T.SurfaceHi2},0.12)
			end)
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					local lx,ly=listFrame.AbsolutePosition.X,listFrame.AbsolutePosition.Y
					local lw,lh=listFrame.AbsoluteSize.X,listFrame.AbsoluteSize.Y
					local px,py=pill.AbsolutePosition.X,pill.AbsolutePosition.Y
					local pw,ph=pill.AbsoluteSize.X,pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not(mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh)
					and not(mx>=px and mx<=px+pw and my>=py and my<=py+ph) then CloseMulti() end
				end
			end)

			local MD={}
			function MD:Get() return GetSelected() end
			function MD:Set(tbl)
				for _,i in items do selected[i]=false end
				for _,v in tbl do selected[v]=true end
				pillLbl.Text=PillText(); RefBadge(); BuildMI()
			end
			_RegElement(wName,id,function() return GetSelected() end,
				function(v) if type(v)=="table" then
					for _,i in items do selected[i]=false end
					for _,s in v do selected[s]=true end
					pillLbl.Text=PillText(); RefBadge(); BuildMI()
				end end,"multi")
			return MD
		end

		-- ══════════════════════════════════════════════════
		--  TEXTBOX
		-- ══════════════════════════════════════════════════
		function API:AddTextBox(opt)
			opt=opt or {}
			local name=opt.Name or "Input"; local ph=opt.Placeholder or "Type here..."
			local def=opt.Default or ""; local numOnly=opt.NumberOnly or false
			local cb=opt.Callback or function() end; local color=opt.Color or T.Accent
			local id=opt.Id or ""

			local card=Card(70); Pad(card,8,8,14,14)
			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local inBG=MkFrame(card,UDim2.new(1,0,0,32),UDim2.new(0,0,0,24),T.SurfaceHi)
			inBG.ZIndex=5; Corner(inBG,10); local inS=Stroke(inBG,T.Border,1)
			CardShine(inBG)

			local pre=MkLabel(inBG,">",14,T.TxtMute,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			pre.Size=UDim2.new(0,26,1,0); pre.ZIndex=6

			local tb=Instance.new("TextBox")
			tb.Text=def; tb.PlaceholderText=ph; tb.PlaceholderColor3=T.TxtMute
			tb.TextColor3=T.TxtMain; tb.BackgroundTransparency=1; tb.Font=Enum.Font.Gotham
			tb.TextSize=13; tb.Size=UDim2.new(1,-40,1,0); tb.Position=UDim2.new(0,28,0,0)
			tb.TextXAlignment=Enum.TextXAlignment.Left; tb.ClearTextOnFocus=false
			tb.ZIndex=6; tb.Parent=inBG

			tb.Focused:Connect(function()
				FT(inBG,{BackgroundColor3=T.SurfaceHi2},0.15)
				FT(inS,{Color=T.BorderGlow,Thickness=1.5},0.15)
				FT(pre,{TextColor3=color},0.15)
			end)
			tb.FocusLost:Connect(function(enter)
				FT(inBG,{BackgroundColor3=T.SurfaceHi},0.15)
				FT(inS,{Color=T.Border,Thickness=1},0.15)
				FT(pre,{TextColor3=T.TxtMute},0.15)
				if enter then pcall(cb,tb.Text) end
			end)
			if numOnly then
				tb:GetPropertyChangedSignal("Text"):Connect(function()
					local c2=tb.Text:gsub("[^%d%.%-]","")
					if tb.Text~=c2 then tb.Text=c2 end
				end)
			end

			local TBx={}
			function TBx:Get() return tb.Text end
			function TBx:Set(v) tb.Text=tostring(v) end
			_RegElement(wName,id,function() return tb.Text end,function(v) tb.Text=tostring(v) end,"string")
			return TBx
		end

		-- ══════════════════════════════════════════════════
		--  KEYBIND
		-- ══════════════════════════════════════════════════
		function API:AddKeybind(opt)
			opt=opt or {}
			local name=opt.Name or "Keybind"; local def=opt.Default or Enum.KeyCode.F
			local cb=opt.Callback or function() end

			local card=Card(46)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.52,0,1,0); nl.ZIndex=5

			local curKey=def; local listening=false
			local kPill=MkFrame(card,UDim2.new(0,114,0,30),UDim2.new(1,-114,0.5,-15),T.SurfaceHi)
			kPill.ZIndex=5; Corner(kPill,8); Stroke(kPill,T.Border,1); CardShine(kPill)
			local kLbl=MkLabel(kPill,"["..tostring(def.Name).."]",11,T.TxtMain,
				Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			kLbl.ZIndex=6
			local kBB=MkButton(kPill,"",0,T.Black,T.White)
			kBB.BackgroundTransparency=1; kBB.Size=UDim2.new(1,0,1,0); kBB.ZIndex=7
			kBB.MouseButton1Click:Connect(function()
				listening=true; kLbl.Text="[  ?  ]"
				FT(kPill,{BackgroundColor3=T.AccentDeep},0.12)
				Stroke(kPill,T.Accent,1)
			end)
			UserInputService.InputBegan:Connect(function(i,gpe)
				if gpe then return end
				if listening and i.UserInputType==Enum.UserInputType.Keyboard then
					listening=false; curKey=i.KeyCode
					kLbl.Text="["..tostring(i.KeyCode.Name).."]"
					FT(kPill,{BackgroundColor3=T.SurfaceHi},0.15)
				elseif not listening and i.UserInputType==Enum.UserInputType.Keyboard
				   and i.KeyCode==curKey then pcall(cb) end
			end)

			local KB={}
			function KB:Get() return curKey end
			function KB:Set(k) curKey=k; kLbl.Text="["..tostring(k.Name).."]" end
			return KB
		end

		-- ══════════════════════════════════════════════════
		--  COLOR PICKER
		-- ══════════════════════════════════════════════════
		function API:AddColorPicker(opt)
			opt=opt or {}
			local name=opt.Name or "Color"; local def=opt.Default or T.Accent
			local cb=opt.Callback or function() end; local id=opt.Id or ""

			local swatches={
				Color3.fromRGB(248,68,92),  Color3.fromRGB(252,150,52),
				Color3.fromRGB(252,214,52), Color3.fromRGB(68,214,132),
				Color3.fromRGB(52,172,254), Color3.fromRGB(138,76,255),
				Color3.fromRGB(248,72,200), Color3.fromRGB(200,200,210),
			}

			local card=Card(66); Pad(card,8,8,14,14)
			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local row=MkFrame(card,UDim2.new(1,0,0,38),UDim2.new(0,0,0,22),T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local prev=MkFrame(row,UDim2.new(0,38,0,38),nil,def)
			prev.ZIndex=6; Corner(prev,11); Stroke(prev,T.Border,1)
			CardShine(prev)

			local swRow=MkFrame(row,UDim2.new(1,-48,1,0),UDim2.new(0,46,0,0),T.Black)
			swRow.BackgroundTransparency=1; swRow.ZIndex=5
			local swLL=Instance.new("UIListLayout")
			swLL.FillDirection=Enum.FillDirection.Horizontal
			swLL.VerticalAlignment=Enum.VerticalAlignment.Center
			swLL.Padding=UDim.new(0,5); swLL.Parent=swRow

			local selColor=def; local activeRing=nil
			for _,col in swatches do
				local sw=MkFrame(swRow,UDim2.new(0,28,0,28),nil,col)
				sw.ZIndex=6; Corner(sw,8)
				CardShine(sw)
				local ring=Stroke(sw,T.White,2,col==def and 0 or 1)
				if col==def then activeRing=ring end
				local hit=MkButton(sw,"",0,T.Black,T.White)
				hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=7
				hit.MouseEnter:Connect(function() ST(sw,{Size=UDim2.new(0,30,0,30)},0.14) end)
				hit.MouseLeave:Connect(function() FT(sw,{Size=UDim2.new(0,28,0,28)},0.12) end)
				hit.MouseButton1Click:Connect(function()
					selColor=col; FT(prev,{BackgroundColor3=col},0.18)
					if activeRing then FT(activeRing,{Transparency=1},0.1) end
					FT(ring,{Transparency=0},0.1); activeRing=ring; pcall(cb,col)
				end)
			end

			local CP={}
			function CP:Get() return selColor end
			function CP:Set(c) selColor=c; prev.BackgroundColor3=c end
			_RegElement(wName,id,function() return selColor end,
				function(v) selColor=v; prev.BackgroundColor3=v end,"color")
			return CP
		end

		-- ══════════════════════════════════════════════════
		--  PROGRESS BAR
		-- ══════════════════════════════════════════════════
		function API:AddProgressBar(opt)
			opt=opt or {}
			local name=opt.Name or "Progress"; local val=opt.Value or 0
			local color=opt.Color or T.Accent

			local card=Card(54); Pad(card,8,8,14,14)
			local row=MkFrame(card,UDim2.new(1,0,0,20),nil,T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5
			local nl=MkLabel(row,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.65,0,1,0); nl.ZIndex=6
			local vl=MkLabel(row,tostring(val).."%",13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.35,0,1,0); vl.ZIndex=6

			local tBG=MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,30),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)
			local fillF=MkFrame(tBG,UDim2.new(val/100,0,1,0),nil,color)
			fillF.ZIndex=6; Corner(fillF,5)
			local fg=Instance.new("UIGradient")
			fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)})
			fg.Parent=fillF
			-- Fill top shine
			local fSh=MkFrame(fillF,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White)
			fSh.BackgroundTransparency=0.86; fSh.ZIndex=7; Corner(fSh,4)

			local PB={}
			function PB:Set(v)
				v=math.clamp(v,0,100)
				FT(fillF,{Size=UDim2.new(v/100,0,1,0)},0.4)
				vl.Text=tostring(math.round(v)).."%"
			end
			function PB:Get() return tonumber(vl.Text:gsub("%%","")) end
			return PB
		end

		-- ══════════════════════════════════════════════════
		--  CREDIT
		-- ══════════════════════════════════════════════════
		function API:AddCredit(line1, line2)
			line1=line1 or "Credit"; line2=line2 or ""
			local wrap=MkFrame(page,UDim2.new(1,0,0,line2~="" and 72 or 54),nil,T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4

			local function FadeLn(xs,xo,w) -- fading accent line
				local l=MkFrame(wrap,UDim2.new(w,0,0,1),UDim2.new(xs,xo,0,0),T.Accent)
				l.BackgroundTransparency=0.6; l.ZIndex=4
				local g=Instance.new("UIGradient")
				g.Transparency=NumberSequence.new({
					NumberSequenceKeypoint.new(0,xs==0 and 1 or 0.6),
					NumberSequenceKeypoint.new(0.5,0.55),
					NumberSequenceKeypoint.new(1,xs==0 and 0.6 or 1),
				})
				g.Parent=l
			end
			FadeLn(0.05,0,0.3); FadeLn(0.65,0,0.3)

			local l1=Instance.new("TextLabel")
			l1.Text=line1; l1.TextSize=14; l1.Font=Enum.Font.GothamBold
			l1.TextColor3=Color3.fromRGB(200,174,255); l1.BackgroundTransparency=1
			l1.BorderSizePixel=0; l1.Size=UDim2.new(1,0,0,22); l1.Position=UDim2.new(0,0,0,8)
			l1.TextXAlignment=Enum.TextXAlignment.Center; l1.ZIndex=5; l1.Parent=wrap

			if line2~="" then
				local l2=Instance.new("TextLabel")
				l2.Text=line2; l2.TextSize=11; l2.Font=Enum.Font.Gotham
				l2.TextColor3=Color3.fromRGB(114,94,156); l2.BackgroundTransparency=1
				l2.BorderSizePixel=0; l2.Size=UDim2.new(1,0,0,18); l2.Position=UDim2.new(0,0,0,34)
				l2.TextXAlignment=Enum.TextXAlignment.Center; l2.ZIndex=5; l2.Parent=wrap
			end

			FadeLn(0.05,0,0.3); FadeLn(0.65,0,0.3)
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

return NexusUI
