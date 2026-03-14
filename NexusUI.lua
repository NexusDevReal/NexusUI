--[[
╔═══════════════════════════════════════════════════════════╗
║  ███╗  ██╗███████╗██╗  ██╗██╗   ██╗███████╗  ██╗   ██╗  ║
║  ████╗ ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝  ██║   ██║  ║
║  ██╔██╗██║█████╗   ╚███╔╝ ██║   ██║███████╗  ██║   ██║  ║
║  ██║╚████║██╔══╝   ██╔██╗ ██║   ██║╚════██║  ██║   ██║  ║
║  ██║ ╚███║███████╗██╔╝██╗ ╚██████╔╝███████║  ╚██████╔╝  ║
║  ╚═╝  ╚══╝╚══════╝╚═╝ ╚═╝  ╚═════╝ ╚══════╝   ╚═════╝   ║
║                                                           ║
║  NexusUI  v1.1  —  Roblox Luau UI Library                ║
║  Fixes: Shadow/Minimize · Dropdown · Buttons · Notifs    ║
╚═══════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════════════════════════
local T = {
	BG          = Color3.fromRGB(13,  10,  28 ),
	Surface     = Color3.fromRGB(22,  17,  44 ),
	SurfaceHi   = Color3.fromRGB(32,  25,  58 ),
	SurfaceHi2  = Color3.fromRGB(42,  33,  72 ),
	Border      = Color3.fromRGB(52,  40,  88 ),
	BorderBright= Color3.fromRGB(72,  56, 118 ),

	Accent      = Color3.fromRGB(132,  74, 248),
	AccentHi    = Color3.fromRGB(158, 108, 255),
	AccentLo    = Color3.fromRGB(96,   46, 196),

	TxtMain     = Color3.fromRGB(238, 232, 255),
	TxtSub      = Color3.fromRGB(152, 136, 196),
	TxtMute     = Color3.fromRGB(88,   74, 122),

	Green       = Color3.fromRGB(72,  214, 130),
	Red         = Color3.fromRGB(248,  68,  92),
	Yellow      = Color3.fromRGB(252, 186,  52),
	Blue        = Color3.fromRGB(52,  172, 252),

	TogOff      = Color3.fromRGB(46,   38,  72),
	NotifBG     = Color3.fromRGB(24,   18,  48),
	White       = Color3.fromRGB(255, 255, 255),
	Black       = Color3.fromRGB(0,     0,   0),
}

-- ═══════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ═══════════════════════════════════════════════════════════
local function FT(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props):Play()
end
local function ST(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		props):Play()
end
local function LT(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		props):Play()
end

-- ═══════════════════════════════════════════════════════════
--  UI PRIMITIVES
-- ═══════════════════════════════════════════════════════════
local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = p
	return c
end

local function Stroke(p, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color         = col or T.Border
	s.Thickness     = thick or 1
	s.Transparency  = trans or 0
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

local function Frame(parent, size, pos, col, clip, zi)
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

local function Lbl(parent, text, sz, col, font, xa, ya, wrap)
	local l = Instance.new("TextLabel")
	l.Text           = text or ""
	l.TextSize       = sz   or 13
	l.TextColor3     = col  or T.TxtMain
	l.Font           = font or Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.Size           = UDim2.new(1,0,1,0)
	l.TextXAlignment = xa   or Enum.TextXAlignment.Left
	l.TextYAlignment = ya   or Enum.TextYAlignment.Center
	l.TextWrapped    = wrap or false
	l.RichText       = false
	l.Parent = parent
	return l
end

local function Btn(parent, text, sz, col, tcol, font)
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

-- ═══════════════════════════════════════════════════════════
--  DRAG (mouse + touch)
-- ═══════════════════════════════════════════════════════════
local function MakeDraggable(win, handle)
	handle = handle or win
	local drag, dragInput, mStart, fStart = false, nil, nil, nil

	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			drag   = true
			mStart = i.Position
			fStart = win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then drag = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch then
			dragInput = i
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if i == dragInput and drag then
			local d = i.Position - mStart
			win.Position = UDim2.new(
				fStart.X.Scale, fStart.X.Offset + d.X,
				fStart.Y.Scale, fStart.Y.Offset + d.Y)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI

-- ─────────────────────────────────────────────────────────
--  NOTIFICATION  (fully redesigned – clean card, no frame bugs)
-- ─────────────────────────────────────────────────────────
local _notifHolder = nil

local function _initNotifs(sg)
	if _notifHolder then _notifHolder:Destroy() end

	_notifHolder = Instance.new("Frame")
	_notifHolder.Name                = "NexusNotifs"
	_notifHolder.BackgroundTransparency = 1
	_notifHolder.BorderSizePixel     = 0
	_notifHolder.Size                = UDim2.new(0, 300, 1, -20)
	_notifHolder.Position            = UDim2.new(1, -308, 0, 10)
	_notifHolder.ZIndex              = 200
	_notifHolder.Parent              = sg

	local ul = Instance.new("UIListLayout")
	ul.FillDirection     = Enum.FillDirection.Vertical
	ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ul.SortOrder         = Enum.SortOrder.LayoutOrder
	ul.Padding           = UDim.new(0, 8)
	ul.Parent            = _notifHolder
end

function NexusUI:Notify(opt)
	opt = opt or {}
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	local icon   = opt.Icon     or "ℹ️"
	local accent = opt.Color    or T.Accent
	if not _notifHolder then return end

	-- Card
	local card = Instance.new("Frame")
	card.Name              = "NexusNotif"
	card.BackgroundColor3  = T.NotifBG
	card.BorderSizePixel   = 0
	card.Size              = UDim2.new(1, 0, 0, 78)
	card.Position          = UDim2.new(1, 20, 0, 0)
	card.ZIndex            = 200
	card.ClipsDescendants  = false
	card.Parent            = _notifHolder
	Corner(card, 14)
	Stroke(card, accent, 1, 0.2)

	-- Slide in
	FT(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.28)

	-- Left accent stripe
	local stripe = Frame(card, UDim2.new(0, 4, 1, -20), UDim2.new(0, 0, 0, 10), accent)
	stripe.ZIndex = 201
	Corner(stripe, 3)

	-- Icon circle
	local icBox = Frame(card, UDim2.new(0, 40, 0, 40), UDim2.new(0, 14, 0, 19), T.SurfaceHi)
	icBox.ZIndex = 201
	Corner(icBox, 12)
	Stroke(icBox, accent, 1, 0.35)

	local icLbl = Lbl(icBox, icon, 20, accent, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	icLbl.Size   = UDim2.new(1, 0, 1, 0)
	icLbl.ZIndex = 202

	-- Title
	local tLbl = Instance.new("TextLabel")
	tLbl.Text              = title
	tLbl.TextSize          = 13
	tLbl.Font              = Enum.Font.GothamBold
	tLbl.TextColor3        = T.TxtMain
	tLbl.BackgroundTransparency = 1
	tLbl.BorderSizePixel   = 0
	tLbl.Size              = UDim2.new(1, -82, 0, 20)
	tLbl.Position          = UDim2.new(0, 64, 0, 14)
	tLbl.TextXAlignment    = Enum.TextXAlignment.Left
	tLbl.ZIndex            = 201
	tLbl.Parent            = card

	-- Desc
	if desc ~= "" then
		local dLbl = Instance.new("TextLabel")
		dLbl.Text              = desc
		dLbl.TextSize          = 11
		dLbl.Font              = Enum.Font.Gotham
		dLbl.TextColor3        = T.TxtSub
		dLbl.BackgroundTransparency = 1
		dLbl.BorderSizePixel   = 0
		dLbl.Size              = UDim2.new(1, -82, 0, 18)
		dLbl.Position          = UDim2.new(0, 64, 0, 36)
		dLbl.TextXAlignment    = Enum.TextXAlignment.Left
		dLbl.TextWrapped       = true
		dLbl.ZIndex            = 201
		dLbl.Parent            = card
	end

	-- Close button
	local xBtn = Instance.new("TextButton")
	xBtn.Text              = "✕"
	xBtn.TextSize          = 11
	xBtn.Font              = Enum.Font.GothamBold
	xBtn.TextColor3        = T.TxtMute
	xBtn.BackgroundTransparency = 1
	xBtn.BorderSizePixel   = 0
	xBtn.Size              = UDim2.new(0, 20, 0, 20)
	xBtn.Position          = UDim2.new(1, -24, 0, 6)
	xBtn.ZIndex            = 202
	xBtn.Parent            = card
	xBtn.MouseEnter:Connect(function() FT(xBtn, {TextColor3 = T.Red}, 0.1) end)
	xBtn.MouseLeave:Connect(function() FT(xBtn, {TextColor3 = T.TxtMute}, 0.1) end)

	-- Progress bar bg
	local pgBg = Frame(card, UDim2.new(1, -20, 0, 3), UDim2.new(0, 10, 1, -9), T.SurfaceHi)
	pgBg.ZIndex = 201
	Corner(pgBg, 2)

	local pgFill = Frame(pgBg, UDim2.new(1, 0, 1, 0), nil, accent)
	pgFill.ZIndex = 202
	Corner(pgFill, 2)
	LT(pgFill, {Size = UDim2.new(0, 0, 1, 0)}, dur)

	-- Dismiss logic
	local gone = false
	local function Dismiss()
		if gone then return end
		gone = true
		FT(card, {Position = UDim2.new(1, 20, 0, 0)}, 0.22)
		task.wait(0.25)
		card:Destroy()
	end
	xBtn.MouseButton1Click:Connect(Dismiss)
	task.delay(dur, Dismiss)

	return card
end

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════
function NexusUI:CreateWindow(opt)
	opt = opt or {}
	local wTitle  = opt.Title    or "NexusUI"
	local wSub    = opt.Subtitle or "1.1"
	local wIcon   = opt.Icon     or "⬡"
	local wSize   = opt.Size     or UDim2.new(0, 370, 0, 490)
	local wPos    = opt.Position or UDim2.new(0.5,-185,0.5,-245)

	-- ── ScreenGui ─────────────────────────────────────────
	local sg = Instance.new("ScreenGui")
	sg.Name           = "NexusUI_"..wTitle
	sg.ResetOnSpawn   = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder   = 999
	sg.IgnoreGuiInset = true
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	_initNotifs(sg)

	-- ── Shadow layers (FIX: controlled separately from window) ─
	local shadowHolder = Frame(sg,
		UDim2.new(0, wSize.X.Offset+40, 0, wSize.Y.Offset+40),
		UDim2.new(wPos.X.Scale, wPos.X.Offset-20, wPos.Y.Scale, wPos.Y.Offset-20),
		T.Black, false, 1)
	shadowHolder.BackgroundTransparency = 1

	local shadowLayers = {}
	for i = 1, 3 do
		local sh = Frame(shadowHolder,
			UDim2.new(1, i*8, 1, i*8),
			UDim2.new(0, -(i*4), 0, -(i*4)),
			Color3.fromRGB(4, 2, 14))
		sh.BackgroundTransparency = 0.55 + (i * 0.12)
		Corner(sh, 18 + i*3)
		table.insert(shadowLayers, sh)
	end

	-- ── Main window frame ──────────────────────────────────
	local win = Frame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)
	Stroke(win, T.Border, 1)

	-- Keep shadow synced to window position every frame
	local syncConn = RunService.RenderStepped:Connect(function()
		shadowHolder.Position = UDim2.new(
			win.Position.X.Scale, win.Position.X.Offset - 20,
			win.Position.Y.Scale, win.Position.Y.Offset - 20)
	end)

	-- ── Title Bar ─────────────────────────────────────────
	local titleBar = Frame(win, UDim2.new(1,0,0,52), nil, T.Surface)
	Corner(titleBar, 16)
	-- fix sharp bottom corners on titlebar
	Frame(titleBar, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Surface)

	-- titlebar gradient
	local tbGrad = Instance.new("UIGradient")
	tbGrad.Color    = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(36,26,68)),
		ColorSequenceKeypoint.new(1, T.Surface),
	})
	tbGrad.Rotation = 90
	tbGrad.Parent   = titleBar

	MakeDraggable(win, titleBar)

	-- Icon pill
	local iconPill = Frame(titleBar, UDim2.new(0,36,0,36), UDim2.new(0,12,0,8), T.AccentLo)
	Corner(iconPill, 10)
	Stroke(iconPill, T.Accent, 1, 0.4)
	local iconL = Lbl(iconPill, wIcon, 18, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)

	-- Title
	local titleL = Lbl(titleBar, wTitle, 14, T.TxtMain, Enum.Font.GothamBold)
	titleL.Size     = UDim2.new(1,-145,0,22)
	titleL.Position = UDim2.new(0,56,0,7)

	local subL = Lbl(titleBar, wSub, 11, T.TxtMute, Enum.Font.Gotham)
	subL.Size     = UDim2.new(1,-145,0,16)
	subL.Position = UDim2.new(0,56,0,28)

	-- ── CLOSE BUTTON ──────────────────────────────────────
	local closeBox = Frame(titleBar, UDim2.new(0,28,0,28), UDim2.new(1,-38,0,12), T.Red)
	Corner(closeBox, 8)
	Lbl(closeBox, "✕", 12, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	local closeBB = Btn(closeBox,"",0,T.Black,T.White,Enum.Font.GothamBold)
	closeBB.BackgroundTransparency = 1
	closeBB.Size = UDim2.new(1,0,1,0)
	closeBB.MouseEnter:Connect(function() FT(closeBox,{BackgroundColor3=Color3.fromRGB(255,40,70)},0.12) end)
	closeBB.MouseLeave:Connect(function() FT(closeBox,{BackgroundColor3=T.Red},0.12) end)
	closeBB.MouseButton1Click:Connect(function()
		FT(win, {Size=UDim2.new(0,wSize.X.Offset,0,0), BackgroundTransparency=1}, 0.25)
		FT(shadowHolder, {BackgroundTransparency=1}, 0.2)
		for _, sh in shadowLayers do FT(sh, {BackgroundTransparency=1}, 0.2) end
		task.wait(0.28)
		syncConn:Disconnect()
		sg:Destroy()
	end)

	-- ── MINIMIZE BUTTON ───────────────────────────────────
	local minBox = Frame(titleBar, UDim2.new(0,28,0,28), UDim2.new(1,-70,0,12), T.SurfaceHi)
	Corner(minBox, 8)
	Stroke(minBox, T.Border, 1)
	local minLbl = Lbl(minBox, "—", 14, T.TxtSub, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	local minBB = Btn(minBox,"",0,T.Black,T.White,Enum.Font.GothamBold)
	minBB.BackgroundTransparency = 1
	minBB.Size = UDim2.new(1,0,1,0)
	minBB.MouseEnter:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi2},0.12) end)
	minBB.MouseLeave:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi},0.12) end)

	-- ── BODY ──────────────────────────────────────────────
	local body = Frame(win, UDim2.new(1,0,1,-52), UDim2.new(0,0,0,52), T.BG, true, 2)
	Corner(body, 16)
	Frame(body, UDim2.new(1,0,0,16), nil, T.BG) -- corner fix top

	-- ── MINIMIZE LOGIC  ← FIX: shadow hides properly ──────
	local minimized = false
	minBB.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			-- Shrink window to just titlebar height
			FT(win, {Size = UDim2.new(0, wSize.X.Offset, 0, 52)}, 0.3)
			-- FIX: hide all shadow layers + resize holder
			for _, sh in shadowLayers do
				FT(sh, {BackgroundTransparency = 1}, 0.2)
			end
			FT(shadowHolder, {
				Size = UDim2.new(0, wSize.X.Offset+40, 0, 92),
			}, 0.3)
			minLbl.Text = "▲"
		else
			FT(win, {Size = wSize}, 0.3)
			-- FIX: restore shadow
			for i, sh in shadowLayers do
				FT(sh, {BackgroundTransparency = 0.55 + (i * 0.12)}, 0.28)
			end
			FT(shadowHolder, {
				Size = UDim2.new(0, wSize.X.Offset+40, 0, wSize.Y.Offset+40),
			}, 0.3)
			minLbl.Text = "—"
		end
	end)

	-- ── TAB BAR ───────────────────────────────────────────
	local tabBar = Frame(body, UDim2.new(1,-20,0,38), UDim2.new(0,10,0,12), T.SurfaceHi, false, 3)
	Corner(tabBar, 12)
	Stroke(tabBar, T.Border, 1)

	local tabLL = Instance.new("UIListLayout")
	tabLL.FillDirection     = Enum.FillDirection.Horizontal
	tabLL.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLL.SortOrder         = Enum.SortOrder.LayoutOrder
	tabLL.Padding           = UDim.new(0,4)
	tabLL.Parent            = tabBar
	Pad(tabBar,4,4,4,4)

	-- Content holder
	local contentArea = Instance.new("ScrollingFrame")
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel        = 0
	contentArea.Size                   = UDim2.new(1,0,1,-70)
	contentArea.Position               = UDim2.new(0,0,0,66)
	contentArea.ScrollBarThickness     = 3
	contentArea.ScrollBarImageColor3   = T.Accent
	contentArea.ScrollBarImageTransparency = 0.5
	contentArea.CanvasSize             = UDim2.new(0,0,0,0)
	contentArea.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	contentArea.ZIndex                 = 3
	contentArea.Parent                 = body

	local tabs      = {}
	local activeTab = nil

	-- ── WINDOW API ────────────────────────────────────────
	local WinAPI = {}
	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	-- ────────────────────────────────────────────────────
	--  ADD TAB
	-- ────────────────────────────────────────────────────
	function WinAPI:AddTab(tabName, tabIcon)
		tabIcon = tabIcon or ""
		local txt = (tabIcon~="" and tabIcon.."  " or "")..tabName

		-- Tab button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Text             = txt
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
		Corner(tabBtn, 8)

		-- Page
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel        = 0
		page.Size                   = UDim2.new(1,0,1,0)
		page.ScrollBarThickness     = 3
		page.ScrollBarImageColor3   = T.Accent
		page.ScrollBarImageTransparency = 0.5
		page.CanvasSize             = UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		page.Visible                = false
		page.ZIndex                 = 3
		page.Parent                 = contentArea

		local ll = Instance.new("UIListLayout")
		ll.FillDirection = Enum.FillDirection.Vertical
		ll.SortOrder     = Enum.SortOrder.LayoutOrder
		ll.Padding       = UDim.new(0,7)
		ll.Parent        = page
		Pad(page, 10, 14, 10, 10)

		local tabData = {Btn=tabBtn, Page=page}
		table.insert(tabs, tabData)

		local function Activate()
			if activeTab then
				FT(activeTab.Btn, {TextColor3=T.TxtMute, BackgroundTransparency=1}, 0.15)
				activeTab.Page.Visible = false
			end
			activeTab = tabData
			tabBtn.BackgroundColor3 = T.Accent
			FT(tabBtn, {TextColor3=T.White, BackgroundTransparency=0}, 0.15)
			page.Visible = true
		end
		tabBtn.MouseButton1Click:Connect(Activate)
		if #tabs == 1 then Activate() end

		-- ── ELEMENT API ──────────────────────────────────
		local API = {}

		-- Card helper
		local function Card(h)
			local c = Frame(page, UDim2.new(1,0,0,h), nil, T.Surface)
			c.ZIndex = 4
			Corner(c, 12)
			Stroke(c, T.Border, 1)
			Pad(c, 0, 0, 14, 14)
			return c
		end

		-- ─────────────────────────────────────────────────
		--  SECTION
		-- ─────────────────────────────────────────────────
		function API:AddSection(name)
			local wrap = Frame(page, UDim2.new(1,0,0,26), nil, T.Black)
			wrap.BackgroundTransparency = 1
			wrap.ZIndex = 4

			-- lines
			local lL = Frame(wrap, UDim2.new(0.27,0,0,1), UDim2.new(0,0,0.5,0), T.Border)
			lL.ZIndex = 4
			local lR = Frame(wrap, UDim2.new(0.27,0,0,1), UDim2.new(0.73,0,0.5,0), T.Border)
			lR.ZIndex = 4

			local sl = Lbl(wrap, name:upper(), 10, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			sl.Size     = UDim2.new(0.46,0,1,0)
			sl.Position = UDim2.new(0.27,0,0,0)
			sl.ZIndex   = 4
		end

		-- ─────────────────────────────────────────────────
		--  LABEL
		-- ─────────────────────────────────────────────────
		function API:AddLabel(text)
			local c = Card(38)
			local l = Lbl(c, text, 12, T.TxtSub, Enum.Font.Gotham)
			l.TextWrapped = true
			l.ZIndex = 5
		end

		-- ─────────────────────────────────────────────────
		--  SEPARATOR
		-- ─────────────────────────────────────────────────
		function API:AddSeparator()
			local s = Frame(page, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,0), T.Border)
			s.ZIndex = 4
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  BUTTON  — redesigned full-width           ║
		-- ╚════════════════════════════════════════════╝
		function API:AddButton(opt)
			opt = opt or {}
			local name  = opt.Name     or "Button"
			local desc  = opt.Desc     or ""
			local icon  = opt.Icon     or ""
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local cardH = (desc ~= "") and 60 or 48
			local card  = Card(cardH)

			-- Left icon circle
			local iconOff = 0
			if icon ~= "" then
				iconOff = 40
				local icCircle = Frame(card, UDim2.new(0,32,0,32), UDim2.new(0,0,0.5,-16), T.AccentLo)
				icCircle.ZIndex = 5
				Corner(icCircle, 9)
				Stroke(icCircle, color, 1, 0.4)
				local iL = Lbl(icCircle, icon, 16, color, Enum.Font.GothamBold,
					Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
				iL.ZIndex = 6
			end

			-- Name label
			local nl = Lbl(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-(iconOff+88),0, desc~="" and 20 or 32)
			nl.Position = UDim2.new(0,iconOff,0, desc~="" and 5 or 0)
			nl.TextYAlignment = desc~="" and Enum.TextYAlignment.Center or Enum.TextYAlignment.Center
			nl.ZIndex   = 5

			if desc ~= "" then
				local dl = Lbl(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				dl.Size     = UDim2.new(1,-(iconOff+88),0,16)
				dl.Position = UDim2.new(0,iconOff,0,28)
				dl.ZIndex   = 5
			end

			-- ── Action pill (right, gradient) ─────────────
			local pillW  = 76
			local actPill = Frame(card, UDim2.new(0,pillW,0,34), UDim2.new(1,-pillW,0.5,-17), color)
			actPill.ZIndex = 5
			Corner(actPill, 10)

			local grad = Instance.new("UIGradient")
			grad.Color    = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, color),
			})
			grad.Rotation = 100
			grad.Parent   = actPill

			local actLbl = Lbl(actPill, "▶  Run", 11, T.White, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			actLbl.ZIndex = 6

			local actBB = Btn(actPill,"",0,T.Black,T.White)
			actBB.BackgroundTransparency = 1
			actBB.Size   = UDim2.new(1,0,1,0)
			actBB.ZIndex = 7

			local function RunCallback()
				ST(actPill, {Size=UDim2.new(0,pillW-4,0,30)}, 0.1)
				task.wait(0.12)
				ST(actPill, {Size=UDim2.new(0,pillW,0,34)}, 0.18)
				actLbl.Text = "✓  Done"
				task.delay(0.8, function() actLbl.Text = "▶  Run" end)
				local ok, err = pcall(cb)
				if not ok then warn("[NexusUI] Button: "..tostring(err)) end
			end

			actBB.MouseEnter:Connect(function()
				grad.Enabled = false
				FT(actPill, {BackgroundColor3=T.AccentHi}, 0.12)
			end)
			actBB.MouseLeave:Connect(function()
				grad.Enabled = true
				FT(actPill, {BackgroundColor3=color}, 0.12)
			end)
			actBB.MouseButton1Click:Connect(RunCallback)

			-- card hover
			local cardBB = Btn(card,"",0,T.Black,T.White)
			cardBB.BackgroundTransparency = 1
			cardBB.Size   = UDim2.new(1,-(pillW+6),1,0)
			cardBB.ZIndex = 5
			cardBB.MouseEnter:Connect(function() FT(card,{BackgroundColor3=T.SurfaceHi},0.12) end)
			cardBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},0.12) end)
			cardBB.MouseButton1Click:Connect(RunCallback)
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  TOGGLE  (iOS style)                       ║
		-- ╚════════════════════════════════════════════╝
		function API:AddToggle(opt)
			opt = opt or {}
			local name  = opt.Name     or "Toggle"
			local desc  = opt.Desc     or ""
			local def   = opt.Default  or false
			local cb    = opt.Callback or function() end
			local color = opt.Color    or T.Accent

			local cardH = desc~="" and 58 or 46
			local card  = Card(cardH)

			local nl = Lbl(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size     = UDim2.new(1,-68,0,22)
			nl.Position = UDim2.new(0,0,0, desc~="" and 4 or 0)
			nl.TextYAlignment = Enum.TextYAlignment.Center
			nl.ZIndex   = 5

			if desc ~= "" then
				local dl = Lbl(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				dl.Size     = UDim2.new(1,-68,0,16)
				dl.Position = UDim2.new(0,0,0,28)
				dl.ZIndex   = 5
			end

			-- Track
			local track = Frame(card, UDim2.new(0,50,0,28), UDim2.new(1,-50,0.5,-14), T.TogOff)
			track.ZIndex = 5
			Corner(track, 14)
			Stroke(track, T.Border, 1)

			-- Thumb
			local thumb = Frame(track, UDim2.new(0,22,0,22), UDim2.new(0,3,0.5,-11), T.White)
			thumb.ZIndex = 6
			Corner(thumb, 11)

			-- thumb glow
			local glow = Frame(thumb, UDim2.new(1,10,1,10), UDim2.new(0.5,-5,0.5,-5), color)
			glow.BackgroundTransparency = 1
			glow.ZIndex = 5
			Corner(glow, 15)

			local state = def
			local busy  = false

			local function Refresh(anim)
				if state then
					if anim then
						FT(track, {BackgroundColor3=color}, 0.22)
						ST(thumb, {Position=UDim2.new(0,25,0.5,-11)}, 0.28)
						FT(glow,  {BackgroundTransparency=0.55}, 0.22)
					else
						track.BackgroundColor3 = color
						thumb.Position = UDim2.new(0,25,0.5,-11)
						glow.BackgroundTransparency = 0.55
					end
				else
					if anim then
						FT(track, {BackgroundColor3=T.TogOff}, 0.22)
						ST(thumb, {Position=UDim2.new(0,3,0.5,-11)}, 0.28)
						FT(glow,  {BackgroundTransparency=1}, 0.22)
					else
						track.BackgroundColor3 = T.TogOff
						thumb.Position = UDim2.new(0,3,0.5,-11)
						glow.BackgroundTransparency = 1
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy then return end
				busy  = true
				state = not state
				Refresh(true)
				local ok, err = pcall(cb, state)
				if not ok then warn("[NexusUI] Toggle: "..tostring(err)) end
				task.wait(0.32)
				busy = false
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog = {}
			function Tog:Set(v) state=v; Refresh(true) end
			function Tog:Get() return state end
			return Tog
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  SLIDER                                    ║
		-- ╚════════════════════════════════════════════╝
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

			local cardH = desc~="" and 72 or 60
			local card  = Card(cardH)

			-- Header
			local nl = Lbl(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size     = UDim2.new(0.62,0,0,20)
			nl.ZIndex   = 5

			local vl = Lbl(card, tostring(def)..sfx, 13, color, Enum.Font.GothamBold,
				Enum.TextXAlignment.Right)
			vl.Size     = UDim2.new(0.38,0,0,20)
			vl.ZIndex   = 5

			if desc ~= "" then
				local dl = Lbl(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				dl.Size     = UDim2.new(1,0,0,14)
				dl.Position = UDim2.new(0,0,0,22)
				dl.ZIndex   = 5
			end

			local yOff = desc~="" and 42 or 28

			-- Track BG
			local tBG = Frame(card, UDim2.new(1,0,0,8), UDim2.new(0,0,0,yOff), T.SurfaceHi)
			tBG.ZIndex = 5
			Corner(tBG, 4)
			Stroke(tBG, T.Border, 1)

			-- Fill
			local fill = Frame(tBG, UDim2.new(0,0,1,0), nil, color)
			fill.ZIndex = 6
			Corner(fill, 4)

			-- fill gradient
			local fg = Instance.new("UIGradient")
			fg.Color    = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, color),
			})
			fg.Parent = fill

			-- Knob
			local knob = Frame(tBG, UDim2.new(0,20,0,20), UDim2.new(0,-10,0.5,-10), T.White)
			knob.ZIndex = 7
			Corner(knob, 10)
			Stroke(knob, color, 2)

			-- knob glow
			local kGlow = Frame(knob, UDim2.new(1,12,1,12), UDim2.new(0.5,-6,0.5,-6), color)
			kGlow.BackgroundTransparency = 0.65
			kGlow.ZIndex = 6
			Corner(kGlow, 16)

			local val     = math.clamp(def, min, max)
			local sliding = false

			local function SetVal(v)
				val = math.clamp(v, min, max)
				local pct = (val-min)/(max-min)
				FT(fill, {Size=UDim2.new(pct,0,1,0)}, 0.06)
				FT(knob, {Position=UDim2.new(pct,-10,0.5,-10)}, 0.06)
				vl.Text = tostring(math.round(val))..sfx
			end
			SetVal(def)

			local function FromPos(pos)
				local ax = tBG.AbsolutePosition.X
				local aw = tBG.AbsoluteSize.X
				return min + math.clamp((pos.X-ax)/aw, 0, 1)*(max-min)
			end

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding = true
					FT(knob, {Size=UDim2.new(0,24,0,24)}, 0.1)
					SetVal(FromPos(i.Position))
					pcall(cb, math.round(val))
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
				or  i.UserInputType==Enum.UserInputType.Touch) then
					SetVal(FromPos(i.Position))
					pcall(cb, math.round(val))
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding = false
					FT(knob, {Size=UDim2.new(0,20,0,20)}, 0.12)
				end
			end)

			local Sl = {}
			function Sl:Set(v) SetVal(v) end
			function Sl:Get() return math.round(val) end
			return Sl
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  DROPDOWN  — redesigned (animated open,    ║
		-- ║  search bar, checkmarks, clean look)       ║
		-- ╚════════════════════════════════════════════╝
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

			-- Label (left)
			local nl = Lbl(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size   = UDim2.new(0.36,0,1,0)
			nl.ZIndex = 5

			-- ── Selection pill (right 62%) ─────────────────
			local pill = Frame(card, UDim2.new(0.62,0,0,32), UDim2.new(0.38,0,0.5,-16), T.SurfaceHi)
			pill.ZIndex = 5
			Corner(pill, 10)
			Stroke(pill, T.Border, 1)

			local pillLbl = Lbl(pill, selVal, 12, T.TxtMain, Enum.Font.GothamSemibold)
			pillLbl.Size         = UDim2.new(1,-30,1,0)
			pillLbl.Position     = UDim2.new(0,10,0,0)
			pillLbl.ZIndex       = 6
			pillLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local chevLbl = Lbl(pill, "⌄", 16, T.TxtSub, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			chevLbl.Size     = UDim2.new(0,24,1,0)
			chevLbl.Position = UDim2.new(1,-26,0,0)
			chevLbl.ZIndex   = 6

			-- ── Floating list ──────────────────────────────
			-- It parents to `page` so it floats above other cards
			local listFrame = Frame(page, UDim2.new(1,-20,0,0), UDim2.new(0,10,0,0), T.Surface)
			listFrame.ZIndex           = 20
			listFrame.Visible          = false
			listFrame.ClipsDescendants = true
			Corner(listFrame, 12)
			Stroke(listFrame, T.BorderBright, 1)

			-- List inner
			local listInner = Frame(listFrame, UDim2.new(1,0,1,0), nil, T.Black)
			listInner.BackgroundTransparency = 1
			listInner.ZIndex = 21
			local liLL = Instance.new("UIListLayout")
			liLL.FillDirection = Enum.FillDirection.Vertical
			liLL.SortOrder     = Enum.SortOrder.LayoutOrder
			liLL.Padding       = UDim.new(0,3)
			liLL.Parent        = listInner
			Pad(listInner,5,5,5,5)

			-- Search
			local searchBG = Frame(listInner, UDim2.new(1,0,0,32), nil, T.SurfaceHi)
			searchBG.ZIndex = 22
			Corner(searchBG, 8)
			Stroke(searchBG, T.Border, 1)

			local searchIcon = Lbl(searchBG, "⌕", 15, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			searchIcon.Size   = UDim2.new(0,28,1,0)
			searchIcon.ZIndex = 23

			local searchTB = Instance.new("TextBox")
			searchTB.PlaceholderText  = "Search..."
			searchTB.PlaceholderColor3 = T.TxtMute
			searchTB.Text             = ""
			searchTB.TextColor3       = T.TxtMain
			searchTB.BackgroundTransparency = 1
			searchTB.Font             = Enum.Font.Gotham
			searchTB.TextSize         = 12
			searchTB.Size             = UDim2.new(1,-30,1,0)
			searchTB.Position         = UDim2.new(0,26,0,0)
			searchTB.TextXAlignment   = Enum.TextXAlignment.Left
			searchTB.ClearTextOnFocus = false
			searchTB.ZIndex           = 23
			searchTB.Parent           = searchBG

			-- Items scroll
			local itemsScroll = Instance.new("ScrollingFrame")
			itemsScroll.BackgroundTransparency = 1
			itemsScroll.BorderSizePixel        = 0
			itemsScroll.Size                   = UDim2.new(1,0,0,0) -- set dynamically
			itemsScroll.CanvasSize             = UDim2.new(0,0,0,0)
			itemsScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
			itemsScroll.ScrollBarThickness     = 2
			itemsScroll.ScrollBarImageColor3   = T.Accent
			itemsScroll.ZIndex                 = 22
			itemsScroll.Parent                 = listInner

			local itemsLL = Instance.new("UIListLayout")
			itemsLL.FillDirection = Enum.FillDirection.Vertical
			itemsLL.SortOrder     = Enum.SortOrder.LayoutOrder
			itemsLL.Padding       = UDim.new(0,2)
			itemsLL.Parent        = itemsScroll

			local allItemBtns = {}

			local function CloseList()
				if not isOpen then return end
				isOpen = false
				FT(listFrame, {Size=UDim2.new(1,-20,0,0)}, 0.18)
				FT(chevLbl, {Rotation=0}, 0.18)
				FT(pill, {BackgroundColor3=T.SurfaceHi}, 0.12)
				task.wait(0.2)
				listFrame.Visible = false
				searchTB.Text = ""
			end

			local function BuildItems(filter)
				filter = (filter or ""):lower()
				for _, b in allItemBtns do b.Parent = nil end
				allItemBtns = {}
				local count  = 0
				for _, item in items do
					if filter=="" or item:lower():find(filter,1,true) then
						count += 1
						local row = Frame(itemsScroll, UDim2.new(1,0,0,34), nil, T.Black)
						row.BackgroundTransparency = 1
						row.ZIndex = 23
						Corner(row, 8)

						-- checkmark
						local ck = Lbl(row, selVal==item and "✓" or "", 12, color,
							Enum.Font.GothamBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
						ck.Size   = UDim2.new(0,26,1,0)
						ck.ZIndex = 24

						local iLbl = Lbl(row, item, 12, T.TxtMain, Enum.Font.Gotham)
						iLbl.Size     = UDim2.new(1,-30,1,0)
						iLbl.Position = UDim2.new(0,28,0,0)
						iLbl.ZIndex   = 24

						local hit = Btn(row,"",0,T.Black,T.White)
						hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=25

						hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.1) end)
						hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},0.1) end)
						hit.MouseButton1Click:Connect(function()
							selVal = item
							pillLbl.Text = item
							CloseList()
							BuildItems("")
							pcall(cb, item)
						end)
						table.insert(allItemBtns, row)
					end
				end
				-- Resize itemsScroll height (max 5 visible)
				local visible = math.min(count, 5)
				itemsScroll.Size = UDim2.new(1,0,0, visible * 36 + 4)
			end
			BuildItems("")

			searchTB:GetPropertyChangedSignal("Text"):Connect(function()
				BuildItems(searchTB.Text)
			end)

			-- ── Open ──────────────────────────────────────
			local pillBB = Btn(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=7

			pillBB.MouseButton1Click:Connect(function()
				if isOpen then CloseList(); return end
				isOpen = true
				BuildItems("")

				-- Calculate Y position below card
				local cardAY = card.AbsolutePosition.Y
				local pageAY = page.AbsolutePosition.Y
				local yBelow = (cardAY - pageAY) + card.AbsoluteSize.Y + 4 + page.CanvasPosition.Y

				local itemCount = math.min(#items, 5)
				local listH     = 46 + itemCount * 36 + 10

				listFrame.Position = UDim2.new(0,10,0,yBelow)
				listFrame.Size     = UDim2.new(1,-20,0,0)
				listFrame.Visible  = true

				FT(listFrame, {Size=UDim2.new(1,-20,0,listH)}, 0.22)
				FT(chevLbl,   {Rotation=180}, 0.18)
				FT(pill, {BackgroundColor3=T.SurfaceHi2}, 0.12)
			end)

			-- Close when clicking outside
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					local lx = listFrame.AbsolutePosition.X
					local ly = listFrame.AbsolutePosition.Y
					local lw = listFrame.AbsoluteSize.X
					local lh = listFrame.AbsoluteSize.Y
					local px = pill.AbsolutePosition.X
					local py = pill.AbsolutePosition.Y
					local pw = pill.AbsoluteSize.X
					local ph = pill.AbsoluteSize.Y
					local mx,my = i.Position.X, i.Position.Y
					local inList = mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh
					local inPill = mx>=px and mx<=px+pw and my>=py and my<=py+ph
					if not inList and not inPill then CloseList() end
				end
			end)

			local Drop = {}
			function Drop:Get() return selVal end
			function Drop:Set(v) selVal=v; pillLbl.Text=v; BuildItems("") end
			function Drop:Refresh(newItems) items=newItems; selVal=newItems[1] or ""; pillLbl.Text=selVal; BuildItems("") end
			return Drop
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  TEXTBOX                                   ║
		-- ╚════════════════════════════════════════════╝
		function API:AddTextBox(opt)
			opt = opt or {}
			local name   = opt.Name        or "Input"
			local ph     = opt.Placeholder or "Type here..."
			local def    = opt.Default     or ""
			local numOnly= opt.NumberOnly  or false
			local cb     = opt.Callback    or function() end
			local color  = opt.Color       or T.Accent

			local card = Card(68)
			Pad(card, 8, 8, 14, 14)

			local nl = Lbl(card, name, 12, T.TxtSub, Enum.Font.GothamBold)
			nl.Size   = UDim2.new(1,0,0,18)
			nl.ZIndex = 5

			local inBG = Frame(card, UDim2.new(1,0,0,34), UDim2.new(0,0,0,22), T.SurfaceHi)
			inBG.ZIndex = 5
			Corner(inBG, 10)
			local inStroke = Stroke(inBG, T.Border, 1)

			-- prefix
			local prefix = Lbl(inBG, "›", 18, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			prefix.Size   = UDim2.new(0,28,1,0)
			prefix.ZIndex = 6

			local tb = Instance.new("TextBox")
			tb.Text             = def
			tb.PlaceholderText  = ph
			tb.PlaceholderColor3 = T.TxtMute
			tb.TextColor3       = T.TxtMain
			tb.BackgroundTransparency = 1
			tb.Font             = Enum.Font.Gotham
			tb.TextSize         = 13
			tb.Size             = UDim2.new(1,-44,1,0)
			tb.Position         = UDim2.new(0,30,0,0)
			tb.TextXAlignment   = Enum.TextXAlignment.Left
			tb.ClearTextOnFocus = false
			tb.ZIndex           = 6
			tb.Parent           = inBG

			tb.Focused:Connect(function()
				FT(inBG,     {BackgroundColor3=T.SurfaceHi2}, 0.15)
				FT(inStroke, {Color=color, Thickness=1.5}, 0.15)
				FT(prefix,   {TextColor3=color}, 0.15)
			end)
			tb.FocusLost:Connect(function(enter)
				FT(inBG,     {BackgroundColor3=T.SurfaceHi}, 0.15)
				FT(inStroke, {Color=T.Border, Thickness=1}, 0.15)
				FT(prefix,   {TextColor3=T.TxtMute}, 0.15)
				if enter then pcall(cb, tb.Text) end
			end)
			if numOnly then
				tb:GetPropertyChangedSignal("Text"):Connect(function()
					local c2 = tb.Text:gsub("[^%d%.%-]","")
					if tb.Text~=c2 then tb.Text=c2 end
				end)
			end

			local TBx = {}
			function TBx:Get() return tb.Text end
			function TBx:Set(v) tb.Text=tostring(v) end
			return TBx
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  KEYBIND                                   ║
		-- ╚════════════════════════════════════════════╝
		function API:AddKeybind(opt)
			opt = opt or {}
			local name = opt.Name     or "Keybind"
			local def  = opt.Default  or Enum.KeyCode.F
			local cb   = opt.Callback or function() end

			local card = Card(46)
			local nl   = Lbl(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nl.Size = UDim2.new(0.52,0,1,0); nl.ZIndex = 5

			local curKey   = def
			local listening = false

			local kPill = Frame(card, UDim2.new(0,106,0,32), UDim2.new(1,-106,0.5,-16), T.SurfaceHi)
			kPill.ZIndex = 5; Corner(kPill, 9); Stroke(kPill, T.Border, 1)

			local kLbl = Lbl(kPill, "[ "..tostring(def.Name).." ]", 11, T.TxtMain,
				Enum.Font.GothamBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			kLbl.ZIndex = 6

			local kBB = Btn(kPill,"",0,T.Black,T.White)
			kBB.BackgroundTransparency=1; kBB.Size=UDim2.new(1,0,1,0); kBB.ZIndex=7

			kBB.MouseButton1Click:Connect(function()
				listening = true
				kLbl.Text = "[ ... ]"
				FT(kPill, {BackgroundColor3=T.AccentLo}, 0.12)
				Stroke(kPill, T.Accent, 1)
			end)
			UserInputService.InputBegan:Connect(function(i, gpe)
				if gpe then return end
				if listening and i.UserInputType==Enum.UserInputType.Keyboard then
					listening = false
					curKey    = i.KeyCode
					kLbl.Text = "[ "..tostring(i.KeyCode.Name).." ]"
					FT(kPill, {BackgroundColor3=T.SurfaceHi}, 0.15)
				elseif not listening and i.UserInputType==Enum.UserInputType.Keyboard
				   and i.KeyCode==curKey then
					pcall(cb)
				end
			end)

			local KB = {}
			function KB:Get() return curKey end
			function KB:Set(k) curKey=k; kLbl.Text="[ "..tostring(k.Name).." ]" end
			return KB
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  COLOR PICKER                              ║
		-- ╚════════════════════════════════════════════╝
		function API:AddColorPicker(opt)
			opt = opt or {}
			local name = opt.Name     or "Color"
			local def  = opt.Default  or T.Accent
			local cb   = opt.Callback or function() end

			local swatches = {
				Color3.fromRGB(248,68,92),   Color3.fromRGB(252,148,52),
				Color3.fromRGB(252,214,52),  Color3.fromRGB(72,214,130),
				Color3.fromRGB(52,172,252),  Color3.fromRGB(132,74,248),
				Color3.fromRGB(248,72,200),  Color3.fromRGB(200,200,200),
			}

			local card = Card(64)
			Pad(card,8,8,14,14)

			local nl = Lbl(card, name, 12, T.TxtSub, Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local row = Frame(card, UDim2.new(1,0,0,36), UDim2.new(0,0,0,22), T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			-- preview box
			local prev = Frame(row, UDim2.new(0,36,0,36), nil, def)
			prev.ZIndex=6; Corner(prev,10); Stroke(prev,T.Border,1)

			-- swatches strip
			local swRow = Frame(row, UDim2.new(1,-46,1,0), UDim2.new(0,44,0,0), T.Black)
			swRow.BackgroundTransparency=1; swRow.ZIndex=5
			local swLL = Instance.new("UIListLayout")
			swLL.FillDirection=Enum.FillDirection.Horizontal
			swLL.VerticalAlignment=Enum.VerticalAlignment.Center
			swLL.Padding=UDim.new(0,5); swLL.Parent=swRow

			local selColor = def
			local activeRing = nil

			for _, col in swatches do
				local sw = Frame(swRow, UDim2.new(0,26,0,26), nil, col)
				sw.ZIndex=6; Corner(sw,7)

				local ring = Stroke(sw, T.White, 2, col==def and 0 or 1)

				if col==def then activeRing = ring end

				local hit = Btn(sw,"",0,T.Black,T.White)
				hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=7
				hit.MouseButton1Click:Connect(function()
					selColor = col
					FT(prev, {BackgroundColor3=col}, 0.18)
					if activeRing then FT(activeRing, {Transparency=1}, 0.1) end
					FT(ring, {Transparency=0}, 0.1)
					activeRing = ring
					pcall(cb, col)
				end)
			end

			local CP = {}
			function CP:Get() return selColor end
			function CP:Set(c) selColor=c; prev.BackgroundColor3=c end
			return CP
		end

		-- ╔════════════════════════════════════════════╗
		-- ║  PROGRESS BAR                              ║
		-- ╚════════════════════════════════════════════╝
		function API:AddProgressBar(opt)
			opt = opt or {}
			local name  = opt.Name  or "Progress"
			local val   = opt.Value or 0
			local color = opt.Color or T.Accent

			local card = Card(56)
			Pad(card,8,8,14,14)

			local row = Frame(card,UDim2.new(1,0,0,20),nil,T.Black)
			row.BackgroundTransparency=1; row.ZIndex=5

			local nl = Lbl(row,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.65,0,1,0); nl.ZIndex=6

			local vl = Lbl(row,tostring(val).."%",13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.35,0,1,0); vl.ZIndex=6

			local tBG = Frame(card,UDim2.new(1,0,0,8),UDim2.new(0,0,0,30),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,4); Stroke(tBG,T.Border,1)

			local fillF = Frame(tBG,UDim2.new(val/100,0,1,0),nil,color)
			fillF.ZIndex=6; Corner(fillF,4)

			local fg = Instance.new("UIGradient")
			fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)})
			fg.Parent=fillF

			local PB = {}
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