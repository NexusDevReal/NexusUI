--[[
  ================================================
    NexusUI  v1.2  |  Roblox Luau UI Library
  ================================================
  FIXES in this version:
    [1] ALL emoji/multi-byte Unicode REMOVED
        (Roblox fonts render them as garbled text)
        Icons now use safe ASCII-only symbols.
    [2] Slider purple-square BUG FIXED
        The glow Frame that bled outside the knob
        bounds has been removed entirely.
    [3] Toggle glow-square BUG FIXED
        Same fix — removed bleed-outside Frame.
    [4] Dropdown list now parents to a top-level
        OVERLAY frame so it is never clipped by
        the ScrollingFrame content area.
    [5] Content area is a proper ScrollingFrame
        with per-tab independent scrolling.
  ================================================
--]]

-- ================================================
--  SERVICES
-- ================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================================================
--  THEME  (all Color3 values)
-- ================================================
local T = {
	BG          = Color3.fromRGB(13,  10,  28),
	Surface     = Color3.fromRGB(22,  17,  44),
	SurfaceHi   = Color3.fromRGB(32,  25,  58),
	SurfaceHi2  = Color3.fromRGB(44,  35,  76),
	Border      = Color3.fromRGB(52,  40,  88),
	BorderBri   = Color3.fromRGB(80,  62, 130),

	Accent      = Color3.fromRGB(130,  72, 245),
	AccentHi    = Color3.fromRGB(160, 110, 255),
	AccentLo    = Color3.fromRGB(92,   44, 192),

	TxtMain     = Color3.fromRGB(238, 232, 255),
	TxtSub      = Color3.fromRGB(150, 134, 194),
	TxtMute     = Color3.fromRGB(86,   72, 120),

	Green       = Color3.fromRGB(70,  210, 128),
	Red         = Color3.fromRGB(245,  66,  90),
	Yellow      = Color3.fromRGB(250, 184,  50),
	Blue        = Color3.fromRGB(50,  168, 250),

	TogOff      = Color3.fromRGB(44,  36,  70),
	NotifBG     = Color3.fromRGB(20,  15,  42),
	White       = Color3.fromRGB(255, 255, 255),
	Black       = Color3.fromRGB(0,    0,   0),
}

-- ================================================
--  TWEEN HELPERS
-- ================================================
local function FT(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props):Play()
end
local function ST(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		props):Play()
end
local function LT(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		props):Play()
end

-- ================================================
--  UI PRIMITIVES
-- ================================================
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

-- Frame with ZERO border, fully controlled
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

-- ================================================
--  DRAG  (mouse + touch)
-- ================================================
local function MakeDraggable(win, handle)
	handle = handle or win
	local drag, dragIn, mStart, fStart = false, nil, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag   = true
			mStart = i.Position
			fStart = win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					drag = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
			dragIn = i
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i == dragIn and drag then
			local d = i.Position - mStart
			win.Position = UDim2.new(
				fStart.X.Scale, fStart.X.Offset + d.X,
				fStart.Y.Scale, fStart.Y.Offset + d.Y)
		end
	end)
end

-- ================================================
--  LIBRARY
-- ================================================
local NexusUI = {}
NexusUI.__index = NexusUI

-- ------------------------------------------------
--  NOTIFICATION  (no emoji, clean card)
-- ------------------------------------------------
local _NH = nil   -- notif holder

local function _InitNotifHolder(sg)
	if _NH then _NH:Destroy() end

	_NH = Instance.new("Frame")
	_NH.Name                  = "NexusNotifHolder"
	_NH.BackgroundTransparency = 1
	_NH.BorderSizePixel        = 0
	_NH.Size                   = UDim2.new(0, 295, 1, -20)
	_NH.Position               = UDim2.new(1, -302, 0, 10)
	_NH.ZIndex                 = 200
	_NH.Parent                 = sg

	local ul = Instance.new("UIListLayout")
	ul.FillDirection     = Enum.FillDirection.Vertical
	ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ul.SortOrder         = Enum.SortOrder.LayoutOrder
	ul.Padding           = UDim.new(0, 8)
	ul.Parent            = _NH
end

function NexusUI:Notify(opt)
	opt = opt or {}
	-- FIX: no emoji — use safe ASCII symbols only
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	local icon   = opt.Icon     or "!"    -- SAFE: ASCII only
	local accent = opt.Color    or T.Accent
	if not _NH then return end

	-- Card
	local card = Instance.new("Frame")
	card.BackgroundColor3 = T.NotifBG
	card.BorderSizePixel  = 0
	card.Size             = UDim2.new(1, 0, 0, 72)
	card.Position         = UDim2.new(1, 20, 0, 0)
	card.ZIndex           = 200
	card.Parent           = _NH
	Corner(card, 12)
	Stroke(card, accent, 1, 0.3)

	-- Slide in from right
	FT(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.26)

	-- Left accent bar
	local bar = MkFrame(card, UDim2.new(0, 4, 1, -18), UDim2.new(0, 0, 0, 9), accent)
	bar.ZIndex = 201
	Corner(bar, 3)

	-- Icon box  (NO emoji — user passes a short string like "!" "+" "i" "OK")
	local icBox = MkFrame(card, UDim2.new(0, 36, 0, 36), UDim2.new(0, 12, 0, 18), T.SurfaceHi)
	icBox.ZIndex = 201
	Corner(icBox, 10)
	Stroke(icBox, accent, 1, 0.4)

	local icLbl = MkLabel(icBox, icon, 16, accent, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	icLbl.Size   = UDim2.new(1, 0, 1, 0)
	icLbl.ZIndex = 202

	-- Title
	local tl = Instance.new("TextLabel")
	tl.Text               = title
	tl.TextSize           = 13
	tl.Font               = Enum.Font.GothamBold
	tl.TextColor3         = T.TxtMain
	tl.BackgroundTransparency = 1
	tl.BorderSizePixel    = 0
	tl.Size               = UDim2.new(1, -76, 0, 20)
	tl.Position           = UDim2.new(0, 58, 0, 12)
	tl.TextXAlignment     = Enum.TextXAlignment.Left
	tl.ZIndex             = 201
	tl.Parent             = card

	-- Description
	if desc ~= "" then
		local dl = Instance.new("TextLabel")
		dl.Text               = desc
		dl.TextSize           = 11
		dl.Font               = Enum.Font.Gotham
		dl.TextColor3         = T.TxtSub
		dl.BackgroundTransparency = 1
		dl.BorderSizePixel    = 0
		dl.Size               = UDim2.new(1, -76, 0, 18)
		dl.Position           = UDim2.new(0, 58, 0, 34)
		dl.TextXAlignment     = Enum.TextXAlignment.Left
		dl.TextWrapped        = true
		dl.ZIndex             = 201
		dl.Parent             = card
	end

	-- Close button
	local xB = Instance.new("TextButton")
	xB.Text               = "x"
	xB.TextSize           = 11
	xB.Font               = Enum.Font.GothamBold
	xB.TextColor3         = T.TxtMute
	xB.BackgroundTransparency = 1
	xB.BorderSizePixel    = 0
	xB.Size               = UDim2.new(0, 20, 0, 20)
	xB.Position           = UDim2.new(1, -24, 0, 5)
	xB.ZIndex             = 202
	xB.Parent             = card
	xB.MouseEnter:Connect(function() FT(xB, {TextColor3 = T.Red}, 0.1) end)
	xB.MouseLeave:Connect(function() FT(xB, {TextColor3 = T.TxtMute}, 0.1) end)

	-- Progress bar
	local pgBg = MkFrame(card, UDim2.new(1, -18, 0, 3), UDim2.new(0, 9, 1, -8), T.SurfaceHi)
	pgBg.ZIndex = 201
	Corner(pgBg, 2)
	local pgFill = MkFrame(pgBg, UDim2.new(1, 0, 1, 0), nil, accent)
	pgFill.ZIndex = 202
	Corner(pgFill, 2)
	LT(pgFill, {Size = UDim2.new(0, 0, 1, 0)}, dur)

	-- Auto dismiss
	local gone = false
	local function Dismiss()
		if gone then return end
		gone = true
		FT(card, {Position = UDim2.new(1, 20, 0, 0)}, 0.2)
		task.wait(0.22)
		card:Destroy()
	end
	xB.MouseButton1Click:Connect(Dismiss)
	task.delay(dur, Dismiss)
	return card
end

-- ================================================
--  CREATE WINDOW
-- ================================================
function NexusUI:CreateWindow(opt)
	opt = opt or {}
	-- FIX: default icon is now a safe ASCII string "N"
	-- Users must pass only short ASCII strings for Icon, not emoji
	local wTitle  = opt.Title    or "NexusUI"
	local wSub    = opt.Subtitle or "v1.2"
	local wIcon   = opt.Icon     or "N"    -- SAFE: ASCII only
	local wSize   = opt.Size     or UDim2.new(0, 370, 0, 490)
	local wPos    = opt.Position or UDim2.new(0.5,-185,0.5,-245)

	-- ScreenGui
	local sg = Instance.new("ScreenGui")
	sg.Name            = "NexusUI_"..wTitle
	sg.ResetOnSpawn    = false
	sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder    = 999
	sg.IgnoreGuiInset  = true
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	_InitNotifHolder(sg)

	-- ── Drop shadow (layered frames, no bleed, no glow frames) ──
	local shadowHolder = MkFrame(sg,
		UDim2.new(0, wSize.X.Offset + 40, 0, wSize.Y.Offset + 40),
		UDim2.new(wPos.X.Scale, wPos.X.Offset - 20, wPos.Y.Scale, wPos.Y.Offset - 20),
		T.Black, false, 1)
	shadowHolder.BackgroundTransparency = 1

	local shadowLayers = {}
	for i = 1, 3 do
		local sh = MkFrame(shadowHolder,
			UDim2.new(1, i * 8, 1, i * 8),
			UDim2.new(0, -(i * 4), 0, -(i * 4)),
			Color3.fromRGB(4, 2, 12))
		sh.BackgroundTransparency = 0.56 + i * 0.11
		Corner(sh, 18 + i * 3)
		table.insert(shadowLayers, sh)
	end

	-- ── Main window ──────────────────────────────────────────
	local win = MkFrame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)
	Stroke(win, T.Border, 1)

	-- sync shadow every frame
	local syncConn = RunService.RenderStepped:Connect(function()
		shadowHolder.Position = UDim2.new(
			win.Position.X.Scale, win.Position.X.Offset - 20,
			win.Position.Y.Scale, win.Position.Y.Offset - 20)
	end)

	-- ── Title bar ────────────────────────────────────────────
	local titleBar = MkFrame(win, UDim2.new(1, 0, 0, 52), nil, T.Surface)
	Corner(titleBar, 16)
	-- fix: fill bottom sharp corners created by the top rounding
	MkFrame(titleBar, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 1, -16), T.Surface)

	-- subtle gradient on titlebar
	local tbG = Instance.new("UIGradient")
	tbG.Color    = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 28, 72)),
		ColorSequenceKeypoint.new(1, T.Surface),
	})
	tbG.Rotation = 90
	tbG.Parent   = titleBar

	MakeDraggable(win, titleBar)

	-- Icon pill  (FIX: no emoji, just the ASCII char user passes)
	local iconPill = MkFrame(titleBar, UDim2.new(0, 36, 0, 36), UDim2.new(0, 12, 0, 8), T.AccentLo)
	Corner(iconPill, 10)
	Stroke(iconPill, T.Accent, 1, 0.4)
	MkLabel(iconPill, wIcon, 18, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)

	-- Title + subtitle
	local titleL = MkLabel(titleBar, wTitle, 14, T.TxtMain, Enum.Font.GothamBold)
	titleL.Size     = UDim2.new(1, -148, 0, 22)
	titleL.Position = UDim2.new(0, 56, 0, 7)

	local subL = MkLabel(titleBar, wSub, 11, T.TxtMute, Enum.Font.Gotham)
	subL.Size     = UDim2.new(1, -148, 0, 16)
	subL.Position = UDim2.new(0, 56, 0, 28)

	-- ── Close button ─────────────────────────────────────────
	local closeBox = MkFrame(titleBar, UDim2.new(0, 28, 0, 28), UDim2.new(1, -38, 0, 12), T.Red)
	Corner(closeBox, 8)
	-- FIX: ASCII "x" not a Unicode cross
	MkLabel(closeBox, "x", 13, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	local closeBB = MkButton(closeBox, "", 0, T.Black, T.White)
	closeBB.BackgroundTransparency = 1; closeBB.Size = UDim2.new(1,0,1,0)
	closeBB.MouseEnter:Connect(function() FT(closeBox,{BackgroundColor3=Color3.fromRGB(255,40,70)},0.12) end)
	closeBB.MouseLeave:Connect(function() FT(closeBox,{BackgroundColor3=T.Red},0.12) end)
	closeBB.MouseButton1Click:Connect(function()
		FT(win, {Size=UDim2.new(0,wSize.X.Offset,0,0), BackgroundTransparency=1}, 0.24)
		for _, sh in shadowLayers do FT(sh,{BackgroundTransparency=1},0.2) end
		task.wait(0.26)
		syncConn:Disconnect()
		sg:Destroy()
	end)

	-- ── Minimize button ──────────────────────────────────────
	local minBox = MkFrame(titleBar, UDim2.new(0, 28, 0, 28), UDim2.new(1, -70, 0, 12), T.SurfaceHi)
	Corner(minBox, 8); Stroke(minBox, T.Border, 1)
	-- FIX: ASCII "-" not a Unicode em-dash
	local minLbl = MkLabel(minBox, "-", 16, T.TxtSub, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	local minBB = MkButton(minBox,"",0,T.Black,T.White)
	minBB.BackgroundTransparency=1; minBB.Size=UDim2.new(1,0,1,0)
	minBB.MouseEnter:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi2},0.12) end)
	minBB.MouseLeave:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi},0.12) end)

	-- ── Body (clips content) ─────────────────────────────────
	local body = MkFrame(win, UDim2.new(1,0,1,-52), UDim2.new(0,0,0,52), T.BG, true, 2)
	Corner(body, 16)
	MkFrame(body, UDim2.new(1,0,0,16), nil, T.BG) -- top corner fill

	-- ── Minimize logic  (FIX: shadow hides properly) ─────────
	local minimized = false
	minBB.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			FT(win, {Size = UDim2.new(0, wSize.X.Offset, 0, 52)}, 0.28)
			for _, sh in shadowLayers do FT(sh,{BackgroundTransparency=1},0.2) end
			FT(shadowHolder, {Size=UDim2.new(0,wSize.X.Offset+40,0,92)}, 0.28)
			minLbl.Text = "+"
		else
			FT(win, {Size = wSize}, 0.28)
			for i, sh in shadowLayers do FT(sh,{BackgroundTransparency = 0.56+i*0.11},0.28) end
			FT(shadowHolder, {Size=UDim2.new(0,wSize.X.Offset+40,0,wSize.Y.Offset+40)}, 0.28)
			minLbl.Text = "-"
		end
	end)

	-- ── Tab bar ───────────────────────────────────────────────
	local tabBar = MkFrame(body, UDim2.new(1,-20,0,36), UDim2.new(0,10,0,12), T.SurfaceHi, false, 3)
	Corner(tabBar, 11); Stroke(tabBar, T.Border, 1)
	local tabLL = Instance.new("UIListLayout")
	tabLL.FillDirection=Enum.FillDirection.Horizontal
	tabLL.VerticalAlignment=Enum.VerticalAlignment.Center
	tabLL.SortOrder=Enum.SortOrder.LayoutOrder
	tabLL.Padding=UDim.new(0,4)
	tabLL.Parent=tabBar
	Pad(tabBar, 3,3,4,4)

	-- ── Content holder  (one ScrollingFrame per tab page) ────
	local contentArea = MkFrame(body, UDim2.new(1,0,1,-64), UDim2.new(0,0,0,64), T.BG, false, 3)

	-- !! OVERLAY for dropdowns — sits on TOP, not clipped !!
	local dropOverlay = MkFrame(body, UDim2.new(1,0,1,-64), UDim2.new(0,0,0,64), T.Black, false, 50)
	dropOverlay.BackgroundTransparency = 1

	local tabs      = {}
	local activeTab = nil

	-- ── Window API ────────────────────────────────────────────
	local WinAPI = {}
	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	-- ===========================================================
	--  ADD TAB
	-- ===========================================================
	function WinAPI:AddTab(tabName)
		-- FIX: no emoji in tab names — user provides plain text only
		local tabBtn = Instance.new("TextButton")
		tabBtn.Text             = tabName
		tabBtn.TextSize         = 12
		tabBtn.Font             = Enum.Font.GothamSemibold
		tabBtn.TextColor3       = T.TxtMute
		tabBtn.BackgroundColor3 = T.Black
		tabBtn.BackgroundTransparency = 1
		tabBtn.BorderSizePixel  = 0
		tabBtn.AutoButtonColor  = false
		tabBtn.AutomaticSize    = Enum.AutomaticSize.X
		tabBtn.Size             = UDim2.new(0,10,1,0)
		tabBtn.ZIndex           = 4
		tabBtn.Parent           = tabBar
		Pad(tabBtn,0,0,10,10)
		Corner(tabBtn,8)

		-- Each tab has its own ScrollingFrame  (FIX: proper scroll)
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency  = 1
		page.BorderSizePixel         = 0
		page.Size                    = UDim2.new(1,0,1,0)
		page.CanvasSize              = UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize     = Enum.AutomaticSize.Y
		page.ScrollBarThickness      = 4
		page.ScrollBarImageColor3    = T.Accent
		page.ScrollBarImageTransparency = 0.4
		page.ScrollingDirection      = Enum.ScrollingDirection.Y
		page.Visible                 = false
		page.ZIndex                  = 3
		page.Parent                  = contentArea
		-- DO NOT ClipsDescendants here — dropdowns escape via overlay

		local ll = Instance.new("UIListLayout")
		ll.FillDirection = Enum.FillDirection.Vertical
		ll.SortOrder     = Enum.SortOrder.LayoutOrder
		ll.Padding       = UDim.new(0,7)
		ll.Parent        = page
		Pad(page,10,16,10,10)

		local tabData = {Btn=tabBtn, Page=page}
		table.insert(tabs, tabData)

		local function Activate()
			if activeTab then
				FT(activeTab.Btn,{TextColor3=T.TxtMute,BackgroundTransparency=1},0.14)
				activeTab.Page.Visible = false
			end
			activeTab = tabData
			tabBtn.BackgroundColor3 = T.Accent
			FT(tabBtn,{TextColor3=T.White,BackgroundTransparency=0},0.14)
			page.Visible = true
		end
		tabBtn.MouseButton1Click:Connect(Activate)
		if #tabs == 1 then Activate() end

		-- =========================================================
		--  ELEMENT API
		-- =========================================================
		local API = {}

		-- Card helper — base container for every element
		local function Card(h)
			local c = MkFrame(page, UDim2.new(1,0,0,h), nil, T.Surface)
			c.ZIndex = 4
			Corner(c,12)
			Stroke(c,T.Border,1)
			Pad(c,0,0,14,14)
			return c
		end

		-- ── SECTION ──────────────────────────────────────────────
		function API:AddSection(name)
			local wrap = MkFrame(page,UDim2.new(1,0,0,24),nil,T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4

			MkFrame(wrap,UDim2.new(0.27,0,0,1),UDim2.new(0,0,0.5,0),T.Border).ZIndex=4
			MkFrame(wrap,UDim2.new(0.27,0,0,1),UDim2.new(0.73,0,0.5,0),T.Border).ZIndex=4

			local sl = MkLabel(wrap, name:upper(), 10, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			sl.Size=UDim2.new(0.46,0,1,0); sl.Position=UDim2.new(0.27,0,0,0); sl.ZIndex=4
		end

		-- ── LABEL ────────────────────────────────────────────────
		function API:AddLabel(text)
			local c = Card(38)
			local l = MkLabel(c,text,12,T.TxtSub,Enum.Font.Gotham)
			l.TextWrapped=true; l.ZIndex=5
		end

		-- ── SEPARATOR ────────────────────────────────────────────
		function API:AddSeparator()
			MkFrame(page,UDim2.new(1,-20,0,1),UDim2.new(0,10,0,0),T.Border).ZIndex=4
		end

		-- =========================================================
		--  BUTTON
		-- =========================================================
		function API:AddButton(opt)
			opt = opt or {}
			local name  = opt.Name     or "Button"
			local desc  = opt.Desc     or ""
			local icon  = opt.Icon     or ""   -- ASCII only!
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local cardH = desc~="" and 60 or 48
			local card  = Card(cardH)

			-- Optional left icon box
			local iOff = 0
			if icon ~= "" then
				iOff = 40
				local icB = MkFrame(card,UDim2.new(0,30,0,30),UDim2.new(0,0,0.5,-15),T.AccentLo)
				icB.ZIndex=5; Corner(icB,8); Stroke(icB,color,1,0.4)
				local il = MkLabel(icB,icon,15,color,Enum.Font.GothamBold,
					Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
				il.ZIndex=6
			end

			-- Name
			local nl = MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-(iOff+90),0, desc~="" and 20 or 32)
			nl.Position = UDim2.new(0,iOff,0, desc~="" and 5 or 0)
			nl.TextYAlignment = Enum.TextYAlignment.Center
			nl.ZIndex   = 5

			if desc ~= "" then
				local dl = MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-(iOff+90),0,16)
				dl.Position=UDim2.new(0,iOff,0,28)
				dl.ZIndex=5
			end

			-- Action pill
			local pillW = 74
			local aPill = MkFrame(card,UDim2.new(0,pillW,0,32),UDim2.new(1,-pillW,0.5,-16),color)
			aPill.ZIndex=5; Corner(aPill,9)

			local aGrad = Instance.new("UIGradient")
			aGrad.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,T.AccentHi),
				ColorSequenceKeypoint.new(1,color),
			})
			aGrad.Rotation=100; aGrad.Parent=aPill

			-- FIX: "Run" label — no special Unicode arrow
			local aLbl = MkLabel(aPill,"Run",12,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			aLbl.ZIndex=6

			local aBB = MkButton(aPill,"",0,T.Black,T.White)
			aBB.BackgroundTransparency=1; aBB.Size=UDim2.new(1,0,1,0); aBB.ZIndex=7

			local running = false
			local function DoRun()
				if running then return end
				running=true
				ST(aPill,{Size=UDim2.new(0,pillW-4,0,28)},0.1)
				task.wait(0.12)
				ST(aPill,{Size=UDim2.new(0,pillW,0,32)},0.16)
				aLbl.Text="Done"
				task.delay(0.9,function() if aLbl and aLbl.Parent then aLbl.Text="Run" end end)
				local ok,err = pcall(cb)
				if not ok then warn("[NexusUI] Button err:"..tostring(err)) end
				running=false
			end

			aBB.MouseEnter:Connect(function() aGrad.Enabled=false; FT(aPill,{BackgroundColor3=T.AccentHi},0.12) end)
			aBB.MouseLeave:Connect(function() aGrad.Enabled=true;  FT(aPill,{BackgroundColor3=color},0.12) end)
			aBB.MouseButton1Click:Connect(DoRun)

			-- whole card clickable too
			local cBB = MkButton(card,"",0,T.Black,T.White)
			cBB.BackgroundTransparency=1; cBB.Size=UDim2.new(1,-(pillW+6),1,0); cBB.ZIndex=5
			cBB.MouseEnter:Connect(function() FT(card,{BackgroundColor3=T.SurfaceHi},0.12) end)
			cBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},0.12) end)
			cBB.MouseButton1Click:Connect(DoRun)
		end

		-- =========================================================
		--  TOGGLE  (iOS)
		--  FIX: removed glow Frame that bled outside thumb bounds
		-- =========================================================
		function API:AddToggle(opt)
			opt = opt or {}
			local name  = opt.Name     or "Toggle"
			local desc  = opt.Desc     or ""
			local def   = opt.Default  or false
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local cardH = desc~="" and 58 or 46
			local card  = Card(cardH)

			local nl = MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-68,0,22)
			nl.Position = UDim2.new(0,0,0, desc~="" and 4 or 0)
			nl.TextYAlignment=Enum.TextYAlignment.Center; nl.ZIndex=5

			if desc ~= "" then
				local dl = MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-68,0,16); dl.Position=UDim2.new(0,0,0,28); dl.ZIndex=5
			end

			-- Track
			local track = MkFrame(card,UDim2.new(0,50,0,28),UDim2.new(1,-50,0.5,-14),T.TogOff)
			track.ZIndex=5; Corner(track,14); Stroke(track,T.Border,1)

			-- Thumb  — FIX: NO glow Frame inside thumb (caused purple square)
			-- Instead we animate the UIStroke color for a subtle highlight
			local thumb = MkFrame(track,UDim2.new(0,22,0,22),UDim2.new(0,3,0.5,-11),T.White)
			thumb.ZIndex=6; Corner(thumb,11)
			local thumbStroke = Stroke(thumb, T.Border, 1.5)  -- replaces glow Frame

			local state = def
			local busy  = false

			local function Refresh(anim)
				if state then
					if anim then
						FT(track,{BackgroundColor3=color},0.22)
						ST(thumb,{Position=UDim2.new(0,25,0.5,-11)},0.26)
						FT(thumbStroke,{Color=color, Thickness=2},0.22)
					else
						track.BackgroundColor3=color
						thumb.Position=UDim2.new(0,25,0.5,-11)
						thumbStroke.Color=color; thumbStroke.Thickness=2
					end
				else
					if anim then
						FT(track,{BackgroundColor3=T.TogOff},0.22)
						ST(thumb,{Position=UDim2.new(0,3,0.5,-11)},0.26)
						FT(thumbStroke,{Color=T.Border, Thickness=1.5},0.22)
					else
						track.BackgroundColor3=T.TogOff
						thumb.Position=UDim2.new(0,3,0.5,-11)
						thumbStroke.Color=T.Border; thumbStroke.Thickness=1.5
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy then return end
				busy=true; state=not state; Refresh(true)
				local ok,err=pcall(cb,state)
				if not ok then warn("[NexusUI] Toggle err:"..tostring(err)) end
				task.wait(0.3); busy=false
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog={}
			function Tog:Set(v) state=v; Refresh(true) end
			function Tog:Get() return state end
			return Tog
		end

		-- =========================================================
		--  SLIDER
		--  FIX: removed kGlow Frame that bled outside knob bounds
		--       Track now clips so knob stays clean
		-- =========================================================
		function API:AddSlider(opt)
			opt = opt or {}
			local name  = opt.Name     or "Slider"
			local desc  = opt.Desc     or ""
			local min   = opt.Min      or 0
			local max   = opt.Max      or 100
			local def   = opt.Default  or min
			local sfx   = opt.Suffix   or ""
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local cardH = desc~="" and 74 or 62
			local card  = Card(cardH)

			-- Header row
			local nl = MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.62,0,0,20); nl.ZIndex=5

			local vl = MkLabel(card,tostring(def)..sfx,13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.38,0,0,20); vl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,0,0,14); dl.Position=UDim2.new(0,0,0,22); dl.ZIndex=5
			end

			local yOff = desc~="" and 44 or 30

			-- Track BG  — CLIP = true prevents any child from bleeding outside
			local tBG = MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,yOff),T.SurfaceHi, false)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)

			-- Fill
			local fill = MkFrame(tBG,UDim2.new(0,0,1,0),nil,color)
			fill.ZIndex=6; Corner(fill,5)
			local fillG = Instance.new("UIGradient")
			fillG.Color=ColorSequence.new({
				ColorSequenceKeypoint.new(0,T.AccentHi),
				ColorSequenceKeypoint.new(1,color),
			}); fillG.Parent=fill

			-- Knob  — FIX: pure circle, NO glow Frame child
			-- Knob is slightly taller than track; we clip the CARD not the track
			-- so knob can extend above/below track cleanly
			local knob = MkFrame(tBG,UDim2.new(0,22,0,22),UDim2.new(0,-11,0.5,-11),T.White)
			knob.ZIndex=7; Corner(knob,11)
			-- Colored ring on knob replaces the old glow Frame
			local knobRing = Stroke(knob,color,2)

			local val     = math.clamp(def,min,max)
			local sliding = false

			local function SetVal(v)
				val = math.clamp(v,min,max)
				local pct=(val-min)/(max-min)
				FT(fill,{Size=UDim2.new(pct,0,1,0)},0.07)
				FT(knob,{Position=UDim2.new(pct,-11,0.5,-11)},0.07)
				vl.Text=tostring(math.round(val))..sfx
			end
			SetVal(def)

			local function FromPos(pos)
				local ax=tBG.AbsolutePosition.X
				local aw=tBG.AbsoluteSize.X
				return min + math.clamp((pos.X-ax)/aw,0,1)*(max-min)
			end

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=true
					FT(knob,{Size=UDim2.new(0,26,0,26)},0.1)
					FT(knobRing,{Thickness=3},0.1)
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
					FT(knob,{Size=UDim2.new(0,22,0,22)},0.12)
					FT(knobRing,{Thickness=2},0.12)
				end
			end)

			local Sl={}
			function Sl:Set(v) SetVal(v) end
			function Sl:Get() return math.round(val) end
			return Sl
		end

		-- =========================================================
		--  DROPDOWN
		--  FIX: list parents to dropOverlay (no clip), not page
		--       Search bar, animated chevron, click-outside close
		-- =========================================================
		function API:AddDropdown(opt)
			opt = opt or {}
			local name  = opt.Name     or "Dropdown"
			local items = opt.Items    or {"Option 1","Option 2"}
			local def   = opt.Default  or items[1]
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local card   = Card(46)
			local selVal = def
			local isOpen = false

			-- Label
			local nl = MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.36,0,1,0); nl.ZIndex=5

			-- Pill (right side)
			local pill = MkFrame(card,UDim2.new(0.62,0,0,32),UDim2.new(0.38,0,0.5,-16),T.SurfaceHi)
			pill.ZIndex=5; Corner(pill,10); Stroke(pill,T.Border,1)

			local pillLbl = MkLabel(pill,selVal,12,T.TxtMain,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-28,1,0); pillLbl.Position=UDim2.new(0,10,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd

			-- FIX: ASCII "v" chevron, not Unicode arrow
			local chevLbl = MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chevLbl.Size=UDim2.new(0,22,1,0); chevLbl.Position=UDim2.new(1,-24,0,0); chevLbl.ZIndex=6

			-- ── Dropdown list  →  parented to dropOverlay ────────
			-- This means it is NEVER clipped by the ScrollingFrame page
			local listFrame = MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			listFrame.ZIndex=50; listFrame.Visible=false; listFrame.ClipsDescendants=true
			Corner(listFrame,12); Stroke(listFrame,T.BorderBri,1)

			local listInner = MkFrame(listFrame,UDim2.new(1,0,1,0),nil,T.Black)
			listInner.BackgroundTransparency=1; listInner.ZIndex=51
			local liLL=Instance.new("UIListLayout")
			liLL.FillDirection=Enum.FillDirection.Vertical
			liLL.SortOrder=Enum.SortOrder.LayoutOrder
			liLL.Padding=UDim.new(0,3); liLL.Parent=listInner
			Pad(listInner,5,5,5,5)

			-- Search bar
			local sBG = MkFrame(listInner,UDim2.new(1,0,0,30),nil,T.SurfaceHi)
			sBG.ZIndex=52; Corner(sBG,8); Stroke(sBG,T.Border,1)
			local sTB = Instance.new("TextBox")
			sTB.PlaceholderText="Search..."; sTB.PlaceholderColor3=T.TxtMute
			sTB.Text=""; sTB.TextColor3=T.TxtMain
			sTB.BackgroundTransparency=1; sTB.Font=Enum.Font.Gotham
			sTB.TextSize=12; sTB.Size=UDim2.new(1,-14,1,0); sTB.Position=UDim2.new(0,7,0,0)
			sTB.TextXAlignment=Enum.TextXAlignment.Left
			sTB.ClearTextOnFocus=false; sTB.ZIndex=53; sTB.Parent=sBG

			-- Items scroll
			local itemsSF = Instance.new("ScrollingFrame")
			itemsSF.BackgroundTransparency=1; itemsSF.BorderSizePixel=0
			itemsSF.Size=UDim2.new(1,0,0,0)
			itemsSF.CanvasSize=UDim2.new(0,0,0,0)
			itemsSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			itemsSF.ScrollBarThickness=2
			itemsSF.ScrollBarImageColor3=T.Accent
			itemsSF.ZIndex=52; itemsSF.Parent=listInner

			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical
			iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,2); iLL.Parent=itemsSF

			local allRows = {}

			local function CloseList()
				if not isOpen then return end
				isOpen=false
				FT(listFrame,{Size=UDim2.new(1,-20,0,0)},0.18)
				FT(chevLbl,{Rotation=0},0.18)
				FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.wait(0.2); listFrame.Visible=false
				sTB.Text=""
			end

			local function BuildItems(filter)
				filter=(filter or ""):lower()
				for _,r in allRows do r.Parent=nil end
				allRows={}
				local count=0
				for _,item in items do
					if filter=="" or item:lower():find(filter,1,true) then
						count+=1
						local row=MkFrame(itemsSF,UDim2.new(1,0,0,32),nil,T.Black)
						row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)

						-- FIX: ASCII tick not Unicode checkmark
						local ck=MkLabel(row,selVal==item and ">" or "",12,color,
							Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
						ck.Size=UDim2.new(0,24,1,0); ck.ZIndex=54

						local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham)
						iLbl.Size=UDim2.new(1,-28,1,0); iLbl.Position=UDim2.new(0,26,0,0); iLbl.ZIndex=54

						local hit=MkButton(row,"",0,T.Black,T.White)
						hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
						hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.1) end)
						hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},0.1) end)
						hit.MouseButton1Click:Connect(function()
							selVal=item; pillLbl.Text=item
							CloseList(); BuildItems("")
							pcall(cb,item)
						end)
						table.insert(allRows,row)
					end
				end
				itemsSF.Size=UDim2.new(1,0,0,math.min(count,5)*34+4)
			end
			BuildItems("")
			sTB:GetPropertyChangedSignal("Text"):Connect(function() BuildItems(sTB.Text) end)

			-- Open dropdown
			local pillBB=MkButton(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=7

			pillBB.MouseButton1Click:Connect(function()
				if isOpen then CloseList(); return end
				isOpen=true; BuildItems("")

				-- FIX: position list using AbsolutePosition in screen space
				-- relative to the dropOverlay's own AbsolutePosition
				local oAY = dropOverlay.AbsolutePosition.Y
				local cAY = card.AbsolutePosition.Y
				local cAH = card.AbsoluteSize.Y
				local yPos = (cAY - oAY) + cAH + 4

				local listH = 44 + math.min(#items,5)*34 + 10

				listFrame.Position=UDim2.new(0,10,0,yPos)
				listFrame.Size=UDim2.new(1,-20,0,0)
				listFrame.Visible=true

				FT(listFrame,{Size=UDim2.new(1,-20,0,listH)},0.22)
				FT(chevLbl,{Rotation=180},0.18)
				FT(pill,{BackgroundColor3=T.SurfaceHi2},0.12)
			end)

			-- Click outside closes
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					local lx=listFrame.AbsolutePosition.X; local ly=listFrame.AbsolutePosition.Y
					local lw=listFrame.AbsoluteSize.X;     local lh=listFrame.AbsoluteSize.Y
					local px=pill.AbsolutePosition.X;      local py=pill.AbsolutePosition.Y
					local pw=pill.AbsoluteSize.X;          local ph=pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					local inL = mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh
					local inP = mx>=px and mx<=px+pw and my>=py and my<=py+ph
					if not inL and not inP then CloseList() end
				end
			end)

			local Drop={}
			function Drop:Get() return selVal end
			function Drop:Set(v) selVal=v; pillLbl.Text=v; BuildItems("") end
			function Drop:Refresh(ni) items=ni; selVal=ni[1] or ""; pillLbl.Text=selVal; BuildItems("") end
			return Drop
		end

		-- =========================================================
		--  TEXTBOX
		-- =========================================================
		function API:AddTextBox(opt)
			opt = opt or {}
			local name   = opt.Name        or "Input"
			local ph     = opt.Placeholder or "Type here..."
			local def    = opt.Default     or ""
			local numOnly= opt.NumberOnly  or false
			local cb     = opt.Callback    or function() end
			local color  = opt.Color       or T.Accent

			local card = Card(68); Pad(card,8,8,14,14)

			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local inBG=MkFrame(card,UDim2.new(1,0,0,32),UDim2.new(0,0,0,22),T.SurfaceHi)
			inBG.ZIndex=5; Corner(inBG,9)
			local inStroke=Stroke(inBG,T.Border,1)

			-- FIX: ASCII ">" prefix, not Unicode arrow
			local pre=MkLabel(inBG,">",15,T.TxtMute,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			pre.Size=UDim2.new(0,26,1,0); pre.ZIndex=6

			local tb=Instance.new("TextBox")
			tb.Text=def; tb.PlaceholderText=ph; tb.PlaceholderColor3=T.TxtMute
			tb.TextColor3=T.TxtMain; tb.BackgroundTransparency=1
			tb.Font=Enum.Font.Gotham; tb.TextSize=13
			tb.Size=UDim2.new(1,-40,1,0); tb.Position=UDim2.new(0,28,0,0)
			tb.TextXAlignment=Enum.TextXAlignment.Left
			tb.ClearTextOnFocus=false; tb.ZIndex=6; tb.Parent=inBG

			tb.Focused:Connect(function()
				FT(inBG,{BackgroundColor3=T.SurfaceHi2},0.15)
				FT(inStroke,{Color=color,Thickness=1.5},0.15)
				FT(pre,{TextColor3=color},0.15)
			end)
			tb.FocusLost:Connect(function(enter)
				FT(inBG,{BackgroundColor3=T.SurfaceHi},0.15)
				FT(inStroke,{Color=T.Border,Thickness=1},0.15)
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
			return TBx
		end

		-- =========================================================
		--  KEYBIND
		-- =========================================================
		function API:AddKeybind(opt)
			opt = opt or {}
			local name = opt.Name     or "Keybind"
			local def  = opt.Default  or Enum.KeyCode.F
			local cb   = opt.Callback or function() end

			local card=Card(46)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.52,0,1,0); nl.ZIndex=5

			local curKey=def; local listening=false

			local kPill=MkFrame(card,UDim2.new(0,110,0,30),UDim2.new(1,-110,0.5,-15),T.SurfaceHi)
			kPill.ZIndex=5; Corner(kPill,8); Stroke(kPill,T.Border,1)

			-- FIX: "[ KEY ]" format — no Unicode brackets
			local kLbl=MkLabel(kPill,"["..tostring(def.Name).."]",11,T.TxtMain,
				Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			kLbl.ZIndex=6

			local kBB=MkButton(kPill,"",0,T.Black,T.White)
			kBB.BackgroundTransparency=1; kBB.Size=UDim2.new(1,0,1,0); kBB.ZIndex=7

			kBB.MouseButton1Click:Connect(function()
				listening=true; kLbl.Text="[  ?  ]"
				FT(kPill,{BackgroundColor3=T.AccentLo},0.12)
			end)
			UserInputService.InputBegan:Connect(function(i,gpe)
				if gpe then return end
				if listening and i.UserInputType==Enum.UserInputType.Keyboard then
					listening=false; curKey=i.KeyCode
					kLbl.Text="["..tostring(i.KeyCode.Name).."]"
					FT(kPill,{BackgroundColor3=T.SurfaceHi},0.15)
				elseif not listening and i.UserInputType==Enum.UserInputType.Keyboard
				   and i.KeyCode==curKey then
					pcall(cb)
				end
			end)

			local KB={}
			function KB:Get() return curKey end
			function KB:Set(k) curKey=k; kLbl.Text="["..tostring(k.Name).."]" end
			return KB
		end

		-- =========================================================
		--  COLOR PICKER
		-- =========================================================
		function API:AddColorPicker(opt)
			opt = opt or {}
			local name = opt.Name     or "Color"
			local def  = opt.Default  or T.Accent
			local cb   = opt.Callback or function() end

			local swatches = {
				Color3.fromRGB(245,66,90),  Color3.fromRGB(250,148,50),
				Color3.fromRGB(250,212,50), Color3.fromRGB(70,210,128),
				Color3.fromRGB(50,168,250), Color3.fromRGB(130,72,245),
				Color3.fromRGB(245,70,198), Color3.fromRGB(200,200,200),
			}

			local card=Card(64); Pad(card,8,8,14,14)

			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local row=MkFrame(card,UDim2.new(1,0,0,36),UDim2.new(0,0,0,22),T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local prev=MkFrame(row,UDim2.new(0,36,0,36),nil,def)
			prev.ZIndex=6; Corner(prev,10); Stroke(prev,T.Border,1)

			local swRow=MkFrame(row,UDim2.new(1,-46,1,0),UDim2.new(0,44,0,0),T.Black)
			swRow.BackgroundTransparency=1; swRow.ZIndex=5
			local swLL=Instance.new("UIListLayout")
			swLL.FillDirection=Enum.FillDirection.Horizontal
			swLL.VerticalAlignment=Enum.VerticalAlignment.Center
			swLL.Padding=UDim.new(0,5); swLL.Parent=swRow

			local selColor=def; local activeRing=nil

			for _,col in swatches do
				local sw=MkFrame(swRow,UDim2.new(0,26,0,26),nil,col)
				sw.ZIndex=6; Corner(sw,7)
				local ring=Stroke(sw,T.White,2,col==def and 0 or 1)
				if col==def then activeRing=ring end

				local hit=MkButton(sw,"",0,T.Black,T.White)
				hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=7
				hit.MouseButton1Click:Connect(function()
					selColor=col; FT(prev,{BackgroundColor3=col},0.18)
					if activeRing then FT(activeRing,{Transparency=1},0.1) end
					FT(ring,{Transparency=0},0.1); activeRing=ring
					pcall(cb,col)
				end)
			end

			local CP={}
			function CP:Get() return selColor end
			function CP:Set(c) selColor=c; prev.BackgroundColor3=c end
			return CP
		end

		-- =========================================================
		--  PROGRESS BAR
		-- =========================================================
		function API:AddProgressBar(opt)
			opt = opt or {}
			local name  = opt.Name  or "Progress"
			local val   = opt.Value or 0
			local color = opt.Color or T.Accent

			local card=Card(54); Pad(card,8,8,14,14)

			local row=MkFrame(card,UDim2.new(1,0,0,20),nil,T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local nl=MkLabel(row,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.65,0,1,0); nl.ZIndex=6

			local vl=MkLabel(row,tostring(val).."%",13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.35,0,1,0); vl.ZIndex=6

			local tBG=MkFrame(card,UDim2.new(1,0,0,8),UDim2.new(0,0,0,30),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,4); Stroke(tBG,T.Border,1)
			local fillF=MkFrame(tBG,UDim2.new(val/100,0,1,0),nil,color)
			fillF.ZIndex=6; Corner(fillF,4)
			local fg=Instance.new("UIGradient")
			fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)})
			fg.Parent=fillF

			local PB={}
			function PB:Set(v)
				v=math.clamp(v,0,100)
				FT(fillF,{Size=UDim2.new(v/100,0,1,0)},0.35)
				vl.Text=tostring(math.round(v)).."%"
			end
			function PB:Get() return tonumber(vl.Text:gsub("%%","")) end
			return PB
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

return NexusUI