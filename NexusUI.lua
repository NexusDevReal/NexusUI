--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    NexusUI  v3.4  —  Roblox Luau UI Library                  ║
║    Full-featured, production-ready UI framework              ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  CHANGELOG                                                   ║
║  v1.0  Initial release. Basic window + elements.             ║
║  v2.0  iOS Toggle, Slider knob, Dropdown, Tabs.              ║
║  v3.0  Shadow system, tab tabs, scrollable pages.            ║
║  v3.1  BUGFIX: emoji garble, glow squares, scroll.           ║
║  v3.2  TitleBar redesign, shadow→UIStroke, AddCredit.        ║
║  v3.4  [NEW]                                                 ║
║    • UICorner on main frame bottom properly rounded          ║
║    • AddMultiDropdown  — multi-select with checkboxes        ║
║    • AddParagraph      — title + body text block             ║
║    • AddLabel          — transparent simple text display     ║
║    • Config Save/Load  — Win:SaveConfig / Win:LoadConfig     ║
║      (auto-registers every element that has an Id field)     ║
╚══════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")  -- for JSON config

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════════════════════════
local T = {
	BG          = Color3.fromRGB(13,  10,  28),
	Surface     = Color3.fromRGB(22,  17,  44),
	SurfaceHi   = Color3.fromRGB(32,  25,  58),
	SurfaceHi2  = Color3.fromRGB(44,  35,  76),
	Border      = Color3.fromRGB(52,  40,  88),
	BorderBri   = Color3.fromRGB(82,  62, 132),

	Accent      = Color3.fromRGB(130,  72, 245),
	AccentHi    = Color3.fromRGB(162, 112, 255),
	AccentLo    = Color3.fromRGB(90,   44, 192),

	TxtMain     = Color3.fromRGB(238, 232, 255),
	TxtSub      = Color3.fromRGB(152, 136, 196),
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

-- ════════════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ════════════════════════════════════════════════════════════
local function FT(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.18,
		Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
local function ST(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.28,
		Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
end
local function LT(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.25,
		Enum.EasingStyle.Linear, Enum.EasingDirection.Out), p):Play()
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
			local d=i.Position-mStart
			win.Position=UDim2.new(fStart.X.Scale,fStart.X.Offset+d.X,
				fStart.Y.Scale,fStart.Y.Offset+d.Y)
		end
	end)
end

-- ════════════════════════════════════════════════════════════
--  CONFIG SYSTEM  (Save / Load — shared across all windows)
-- ════════════════════════════════════════════════════════════
-- Each element that has an Id registers here.
-- Shape: _ConfigReg[windowName][id] = { Get = fn, Set = fn, Type = string }
local _ConfigReg = {}

local function _RegElement(winName, id, getter, setter, elType)
	if not id or id == "" then return end
	if not _ConfigReg[winName] then _ConfigReg[winName] = {} end
	_ConfigReg[winName][id] = { Get=getter, Set=setter, Type=elType }
end

-- Encode Color3 for JSON
local function _EncodeColor(c)
	return {r=math.round(c.R*255), g=math.round(c.G*255), b=math.round(c.B*255)}
end
local function _DecodeColor(t)
	return Color3.fromRGB(t.r, t.g, t.b)
end

-- ════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ════════════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI

-- ════════════════════════════════════════════════════════════
--  NOTIFICATION  (no emoji, clean card)
-- ════════════════════════════════════════════════════════════
local _NH = nil

local function _InitNotifHolder(sg)
	if _NH then _NH:Destroy() end
	_NH = Instance.new("Frame")
	_NH.Name                   = "NexusNotifHolder"
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
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	local icon   = opt.Icon     or "!"
	local accent = opt.Color    or T.Accent
	if not _NH then return end

	local card = Instance.new("Frame")
	card.BackgroundColor3 = T.NotifBG
	card.BorderSizePixel  = 0
	card.Size             = UDim2.new(1,0,0,72)
	card.Position         = UDim2.new(1,20,0,0)
	card.ZIndex           = 200
	card.Parent           = _NH
	Corner(card,12); Stroke(card,accent,1,0.3)
	FT(card, {Position=UDim2.new(0,0,0,0)}, 0.26)

	local bar = MkFrame(card,UDim2.new(0,4,1,-18),UDim2.new(0,0,0,9),accent)
	bar.ZIndex=201; Corner(bar,3)

	local icBox = MkFrame(card,UDim2.new(0,36,0,36),UDim2.new(0,12,0,18),T.SurfaceHi)
	icBox.ZIndex=201; Corner(icBox,10); Stroke(icBox,accent,1,0.4)
	local icLbl = MkLabel(icBox,icon,16,accent,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	icLbl.Size=UDim2.new(1,0,1,0); icLbl.ZIndex=202

	local function NLbl(txt,fs,fc,px,py,w,h)
		local l=Instance.new("TextLabel")
		l.Text=txt; l.TextSize=fs; l.TextColor3=fc
		l.Font=Enum.Font.GothamBold
		l.BackgroundTransparency=1; l.BorderSizePixel=0
		l.Size=UDim2.new(1,-76,0,h); l.Position=UDim2.new(0,58,0,py)
		l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true
		l.ZIndex=201; l.Parent=card; return l
	end
	NLbl(title,13,T.TxtMain,58,12,nil,20)
	if desc~="" then
		local dl=NLbl(desc,11,T.TxtSub,58,34,nil,18)
		dl.Font=Enum.Font.Gotham
	end

	local xB=Instance.new("TextButton")
	xB.Text="x"; xB.TextSize=11; xB.Font=Enum.Font.GothamBold
	xB.TextColor3=T.TxtMute; xB.BackgroundTransparency=1; xB.BorderSizePixel=0
	xB.Size=UDim2.new(0,20,0,20); xB.Position=UDim2.new(1,-24,0,5)
	xB.ZIndex=202; xB.Parent=card
	xB.MouseEnter:Connect(function() FT(xB,{TextColor3=T.Red},0.1) end)
	xB.MouseLeave:Connect(function() FT(xB,{TextColor3=T.TxtMute},0.1) end)

	local pgBg=MkFrame(card,UDim2.new(1,-18,0,3),UDim2.new(0,9,1,-8),T.SurfaceHi)
	pgBg.ZIndex=201; Corner(pgBg,2)
	local pgFill=MkFrame(pgBg,UDim2.new(1,0,1,0),nil,accent)
	pgFill.ZIndex=202; Corner(pgFill,2)
	LT(pgFill,{Size=UDim2.new(0,0,1,0)},dur)

	local gone=false
	local function Dismiss()
		if gone then return end; gone=true
		FT(card,{Position=UDim2.new(1,20,0,0)},0.2)
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
	opt = opt or {}
	local wTitle = opt.Title    or "NexusUI"
	local wSub   = opt.Subtitle or "v3.4"
	local wIcon  = opt.Icon     or "N"
	local wSize  = opt.Size     or UDim2.new(0,370,0,500)
	local wPos   = opt.Position or UDim2.new(0.5,-185,0.5,-250)
	local wName  = wTitle  -- used as key in config registry

	-- ── ScreenGui ──────────────────────────────────────────────
	local sg = Instance.new("ScreenGui")
	sg.Name            = "NexusUI_"..wTitle
	sg.ResetOnSpawn    = false
	sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder    = 999
	sg.IgnoreGuiInset  = true
	local ok=pcall(function() sg.Parent=game:GetService("CoreGui") end)
	if not ok then sg.Parent=LocalPlayer:WaitForChild("PlayerGui") end
	_InitNotifHolder(sg)

	-- ── Main Window Frame ─────────────────────────────────────
	-- FIX v3.4: UICorner(16) gives proper rounded corners on ALL 4 corners.
	-- The body and titlebar use fill frames to square-off the shared edge,
	-- so only the outer window's 4 corners are actually rounded.
	local win = MkFrame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)  -- ALL FOUR corners rounded — this is the main frame fix

	-- Accent UIStroke border (replaces shadow)
	Stroke(win, Color3.fromRGB(88, 56, 168), 1.5)

	-- Subtle top-edge glow (1px bright line)
	local topGlow = MkFrame(win, UDim2.new(1,-4,0,1), UDim2.new(0,2,0,0),
		Color3.fromRGB(138,88,255))
	topGlow.BackgroundTransparency=0.45; topGlow.ZIndex=10

	-- ── Title Bar ─────────────────────────────────────────────
	local titleBar = MkFrame(win, UDim2.new(1,0,0,60), nil, T.Surface)
	Corner(titleBar, 16)
	-- Square off only the bottom two corners of titleBar (the top stays rounded)
	MkFrame(titleBar, UDim2.new(1,0,0,16), UDim2.new(0,0,1,-16), T.Surface)

	-- 3-stop gradient top → bottom
	local tbG = Instance.new("UIGradient")
	tbG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(48,32,90)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(30,22,60)),
		ColorSequenceKeypoint.new(1,   T.Surface),
	})
	tbG.Rotation=90; tbG.Parent=titleBar

	-- Separator line at bottom of titlebar
	local tbSep = MkFrame(titleBar, UDim2.new(1,-24,0,1),
		UDim2.new(0,12,1,-1), Color3.fromRGB(68,48,108))
	tbSep.BackgroundTransparency=0.45; tbSep.ZIndex=5

	MakeDraggable(win, titleBar)

	-- Icon pill
	local iconPill = MkFrame(titleBar, UDim2.new(0,40,0,40), UDim2.new(0,12,0.5,-20), T.AccentLo)
	Corner(iconPill,12); Stroke(iconPill, T.AccentHi, 1, 0.3)
	local pillShine = MkFrame(iconPill, UDim2.new(1,-4,0,12), UDim2.new(0,2,0,2), T.White)
	pillShine.BackgroundTransparency=0.88; Corner(pillShine,6)
	MkLabel(iconPill, wIcon, 20, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center).ZIndex=4

	-- Title
	local titleL = MkLabel(titleBar, wTitle, 15, T.TxtMain, Enum.Font.GothamBold)
	titleL.Size=UDim2.new(1,-155,0,22); titleL.Position=UDim2.new(0,62,0,10)

	-- Version chip
	local verChip = MkFrame(titleBar, UDim2.new(0,0,0,18), UDim2.new(0,62,0,34), T.AccentLo)
	verChip.AutomaticSize=Enum.AutomaticSize.X; Corner(verChip,6); Stroke(verChip,T.Accent,1,0.5)
	local verLbl = MkLabel(verChip, wSub, 10, T.AccentHi, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	verLbl.Size=UDim2.new(1,0,1,0); Pad(verChip,0,0,7,7)

	-- ── Control buttons ───────────────────────────────────────
	-- Close
	local closeBox = MkFrame(titleBar, UDim2.new(0,28,0,28), UDim2.new(1,-38,0.5,-14), T.Red)
	Corner(closeBox,8)
	MkLabel(closeBox,"x",13,T.White,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	local closeBB = MkButton(closeBox,"",0,T.Black,T.White)
	closeBB.BackgroundTransparency=1; closeBB.Size=UDim2.new(1,0,1,0)
	closeBB.MouseEnter:Connect(function() FT(closeBox,{BackgroundColor3=Color3.fromRGB(255,40,70)},0.12) end)
	closeBB.MouseLeave:Connect(function() FT(closeBox,{BackgroundColor3=T.Red},0.12) end)
	closeBB.MouseButton1Click:Connect(function()
		FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,0),BackgroundTransparency=1},0.24)
		task.wait(0.26); sg:Destroy()
	end)

	-- Minimize
	local minBox = MkFrame(titleBar, UDim2.new(0,28,0,28), UDim2.new(1,-70,0.5,-14), T.SurfaceHi)
	Corner(minBox,8); Stroke(minBox,T.Border,1)
	local minLbl = MkLabel(minBox,"-",16,T.TxtSub,Enum.Font.GothamBold,
		Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	local minBB = MkButton(minBox,"",0,T.Black,T.White)
	minBB.BackgroundTransparency=1; minBB.Size=UDim2.new(1,0,1,0)
	minBB.MouseEnter:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi2},0.12) end)
	minBB.MouseLeave:Connect(function() FT(minBox,{BackgroundColor3=T.SurfaceHi},0.12) end)

	-- ── Body ─────────────────────────────────────────────────
	-- Body sits below titlebar. ClipsDescendants=true keeps elements inside.
	-- The body Frame has rounded bottom corners via Corner(body,16).
	-- A fill strip at the top squares-off just the top edge (shared with titlebar).
	local body = MkFrame(win, UDim2.new(1,0,1,-60), UDim2.new(0,0,0,60), T.BG, true, 2)
	Corner(body, 16)  -- bottom-left and bottom-right get proper rounding
	MkFrame(body, UDim2.new(1,0,0,16), nil, T.BG)  -- top-edge fill

	-- Bottom accent bar
	local bottomBar = MkFrame(win, UDim2.new(1,-4,0,5), UDim2.new(0,2,1,-5),
		Color3.fromRGB(72,48,132))
	bottomBar.BackgroundTransparency=0.62; bottomBar.ZIndex=3; Corner(bottomBar,4)

	-- ── Minimize logic ────────────────────────────────────────
	local minimized=false
	minBB.MouseButton1Click:Connect(function()
		minimized=not minimized
		if minimized then
			FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,60)},0.28); minLbl.Text="+"
		else
			FT(win,{Size=wSize},0.28); minLbl.Text="-"
		end
	end)

	-- ── Tab bar ───────────────────────────────────────────────
	local tabBar = MkFrame(body, UDim2.new(1,-20,0,36), UDim2.new(0,10,0,14), T.SurfaceHi, false, 3)
	Corner(tabBar,11); Stroke(tabBar,T.Border,1)
	local tabLL=Instance.new("UIListLayout")
	tabLL.FillDirection=Enum.FillDirection.Horizontal
	tabLL.VerticalAlignment=Enum.VerticalAlignment.Center
	tabLL.SortOrder=Enum.SortOrder.LayoutOrder
	tabLL.Padding=UDim.new(0,4); tabLL.Parent=tabBar
	Pad(tabBar,3,3,4,4)

	-- ── Content area + Dropdown overlay ──────────────────────
	local contentArea = MkFrame(body, UDim2.new(1,0,1,-68), UDim2.new(0,0,0,68), T.BG, false, 3)
	local dropOverlay = MkFrame(body, UDim2.new(1,0,1,-68), UDim2.new(0,0,0,68), T.Black, false, 50)
	dropOverlay.BackgroundTransparency=1

	local tabs={}; local activeTab=nil

	-- ════════════════════════════════════════════════════════
	--  WINDOW API
	-- ════════════════════════════════════════════════════════
	local WinAPI={}
	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	-- ── Config: Save ─────────────────────────────────────────
	function WinAPI:SaveConfig(configName)
		configName = configName or "default"
		local reg = _ConfigReg[wName]
		if not reg then
			warn("[NexusUI] No elements registered for config in window: "..wName)
			return
		end
		local data = {}
		for id, entry in reg do
			local v = entry.Get()
			if entry.Type == "color" then
				data[id] = _EncodeColor(v)
			elseif entry.Type == "multi" then
				data[id] = v  -- already a table of strings
			else
				data[id] = v
			end
		end
		local json = HttpService:JSONEncode(data)
		local path = "NexusUI_"..wName.."_"..configName..".json"
		local ok2, err = pcall(function() writefile(path, json) end)
		if ok2 then
			NexusUI:Notify({Title="Config Saved", Desc=path, Duration=3, Icon="OK", Color=T.Green})
		else
			-- Executor may not have writefile — print to output as fallback
			print("[NexusUI] Config '"..configName.."':\n"..json)
			NexusUI:Notify({Title="Config (no writefile)", Desc="Printed to output", Duration=3, Icon="!", Color=T.Yellow})
		end
	end

	-- ── Config: Load ─────────────────────────────────────────
	function WinAPI:LoadConfig(configName)
		configName = configName or "default"
		local reg = _ConfigReg[wName]
		if not reg then
			warn("[NexusUI] No elements registered for config in window: "..wName)
			return
		end
		local path = "NexusUI_"..wName.."_"..configName..".json"
		local ok2, json = pcall(function() return readfile(path) end)
		if not ok2 or not json then
			NexusUI:Notify({Title="Config Not Found", Desc=path, Duration=3, Icon="!", Color=T.Red})
			return
		end
		local data = HttpService:JSONDecode(json)
		for id, val in data do
			if reg[id] then
				local entry = reg[id]
				local ok3, err = pcall(function()
					if entry.Type == "color" then
						entry.Set(_DecodeColor(val))
					else
						entry.Set(val)
					end
				end)
				if not ok3 then
					warn("[NexusUI] Config load error for '"..id.."': "..tostring(err))
				end
			end
		end
		NexusUI:Notify({Title="Config Loaded", Desc=path, Duration=3, Icon="OK", Color=T.Green})
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
		tabBtn.Size=UDim2.new(0,10,1,0); tabBtn.ZIndex=4; tabBtn.Parent=tabBar
		Pad(tabBtn,0,0,10,10); Corner(tabBtn,8)

		local page=Instance.new("ScrollingFrame")
		page.BackgroundTransparency=1; page.BorderSizePixel=0
		page.Size=UDim2.new(1,0,1,0); page.CanvasSize=UDim2.new(0,0,0,0)
		page.AutomaticCanvasSize=Enum.AutomaticSize.Y
		page.ScrollBarThickness=4; page.ScrollBarImageColor3=T.Accent
		page.ScrollBarImageTransparency=0.4
		page.ScrollingDirection=Enum.ScrollingDirection.Y
		page.Visible=false; page.ZIndex=3; page.Parent=contentArea

		local ll=Instance.new("UIListLayout")
		ll.FillDirection=Enum.FillDirection.Vertical; ll.SortOrder=Enum.SortOrder.LayoutOrder
		ll.Padding=UDim.new(0,7); ll.Parent=page
		Pad(page,10,16,10,10)

		local tabData={Btn=tabBtn, Page=page}
		table.insert(tabs,tabData)

		local function Activate()
			if activeTab then
				FT(activeTab.Btn,{TextColor3=T.TxtMute,BackgroundTransparency=1},0.14)
				activeTab.Page.Visible=false
			end
			activeTab=tabData; tabBtn.BackgroundColor3=T.Accent
			FT(tabBtn,{TextColor3=T.White,BackgroundTransparency=0},0.14)
			page.Visible=true
		end
		tabBtn.MouseButton1Click:Connect(Activate)
		if #tabs==1 then Activate() end

		-- ──────────────────────────────────────────────────
		--  ELEMENT API
		-- ──────────────────────────────────────────────────
		local API={}

		local function Card(h)
			local c=MkFrame(page,UDim2.new(1,0,0,h),nil,T.Surface)
			c.ZIndex=4; Corner(c,12); Stroke(c,T.Border,1); Pad(c,0,0,14,14)
			return c
		end

		-- ══════════════════════════════════════════════════
		--  SECTION
		-- ══════════════════════════════════════════════════
		function API:AddSection(name)
			local w=MkFrame(page,UDim2.new(1,0,0,24),nil,T.Black)
			w.BackgroundTransparency=1; w.ZIndex=4
			MkFrame(w,UDim2.new(0.27,0,0,1),UDim2.new(0,0,0.5,0),T.Border).ZIndex=4
			MkFrame(w,UDim2.new(0.27,0,0,1),UDim2.new(0.73,0,0.5,0),T.Border).ZIndex=4
			local sl=MkLabel(w,name:upper(),10,T.TxtMute,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			sl.Size=UDim2.new(0.46,0,1,0); sl.Position=UDim2.new(0.27,0,0,0); sl.ZIndex=4
		end

		-- ══════════════════════════════════════════════════
		--  SEPARATOR
		-- ══════════════════════════════════════════════════
		function API:AddSeparator()
			MkFrame(page,UDim2.new(1,-20,0,1),UDim2.new(0,10,0,0),T.Border).ZIndex=4
		end

		-- ══════════════════════════════════════════════════
		--  LABEL  (NEW v3.4 — transparent bg, styled text)
		--  Simple one-line text display. No card background.
		-- ══════════════════════════════════════════════════
		function API:AddLabel(opt)
			opt = type(opt)=="string" and {Text=opt} or (opt or {})
			local text   = opt.Text      or "Label"
			local color  = opt.Color     or T.TxtSub
			local align  = opt.Align     or "Left"
			local size   = opt.TextSize  or 13
			local font   = opt.Bold      and Enum.Font.GothamBold or Enum.Font.Gotham

			local xa = align=="Center" and Enum.TextXAlignment.Center
				or align=="Right" and Enum.TextXAlignment.Right
				or Enum.TextXAlignment.Left

			local wrap = MkFrame(page, UDim2.new(1,0,0,26), nil, T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4

			local lbl = MkLabel(wrap, text, size, color, font, xa, Enum.TextYAlignment.Center, true)
			lbl.Size=UDim2.new(1,-20,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.ZIndex=5

			-- Return an update handle
			local LblAPI={}
			function LblAPI:SetText(t) lbl.Text=t end
			function LblAPI:SetColor(c) lbl.TextColor3=c end
			return LblAPI
		end

		-- ══════════════════════════════════════════════════
		--  PARAGRAPH  (NEW v3.4)
		--  Title + multi-line body text. Semi-transparent card.
		-- ══════════════════════════════════════════════════
		function API:AddParagraph(opt)
			opt = opt or {}
			local title   = opt.Title   or "Paragraph"
			local content = opt.Content or ""
			local color   = opt.Color   or T.TxtSub

			-- Measure approximate height: header + body lines
			local lineH   = 18
			local rawLines= math.max(1, math.ceil(#content / 42))
			local cardH   = 14 + 20 + 6 + rawLines * lineH + 14
			cardH = math.max(cardH, 58)

			-- Card with 30% transparent background
			local card = MkFrame(page, UDim2.new(1,0,0,cardH), nil, T.Surface)
			card.BackgroundTransparency=0.3; card.ZIndex=4
			Corner(card,12); Stroke(card,T.Border,1); Pad(card,10,10,14,14)

			-- Left accent strip
			local strip=MkFrame(card,UDim2.new(0,3,1,-20),UDim2.new(0,0,0,10),T.Accent)
			strip.ZIndex=5; Corner(strip,3)

			-- Title
			local tl=MkLabel(card,title,13,T.TxtMain,Enum.Font.GothamBold)
			tl.Size=UDim2.new(1,-10,0,20); tl.ZIndex=5

			-- Content body
			local cl=Instance.new("TextLabel")
			cl.Text=content; cl.TextSize=12; cl.Font=Enum.Font.Gotham
			cl.TextColor3=color; cl.BackgroundTransparency=1; cl.BorderSizePixel=0
			cl.Size=UDim2.new(1,-10,0,cardH-44); cl.Position=UDim2.new(0,0,0,26)
			cl.TextXAlignment=Enum.TextXAlignment.Left
			cl.TextYAlignment=Enum.TextYAlignment.Top
			cl.TextWrapped=true; cl.ZIndex=5; cl.Parent=card

			local PAPI={}
			function PAPI:SetTitle(t) tl.Text=t end
			function PAPI:SetContent(c) cl.Text=c end
			return PAPI
		end

		-- ══════════════════════════════════════════════════
		--  BUTTON
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
				local icB=MkFrame(card,UDim2.new(0,30,0,30),UDim2.new(0,0,0.5,-15),T.AccentLo)
				icB.ZIndex=5; Corner(icB,8); Stroke(icB,color,1,0.4)
				MkLabel(icB,icon,15,color,Enum.Font.GothamBold,
					Enum.TextXAlignment.Center,Enum.TextYAlignment.Center).ZIndex=6
			end

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,-(iOff+90),0,desc~="" and 20 or 32)
			nl.Position=UDim2.new(0,iOff,0,desc~="" and 5 or 0)
			nl.TextYAlignment=Enum.TextYAlignment.Center; nl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-(iOff+90),0,16); dl.Position=UDim2.new(0,iOff,0,28); dl.ZIndex=5
			end

			local pillW=74
			local aPill=MkFrame(card,UDim2.new(0,pillW,0,32),UDim2.new(1,-pillW,0.5,-16),color)
			aPill.ZIndex=5; Corner(aPill,9)
			local aGrad=Instance.new("UIGradient")
			aGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)})
			aGrad.Rotation=100; aGrad.Parent=aPill
			local aLbl=MkLabel(aPill,"Run",12,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			aLbl.ZIndex=6

			local aBB=MkButton(aPill,"",0,T.Black,T.White)
			aBB.BackgroundTransparency=1; aBB.Size=UDim2.new(1,0,1,0); aBB.ZIndex=7

			local running=false
			local function DoRun()
				if running then return end; running=true
				ST(aPill,{Size=UDim2.new(0,pillW-4,0,28)},0.1); task.wait(0.12)
				ST(aPill,{Size=UDim2.new(0,pillW,0,32)},0.16)
				aLbl.Text="Done"; task.delay(0.9,function() if aLbl and aLbl.Parent then aLbl.Text="Run" end end)
				pcall(cb); running=false
			end

			aBB.MouseEnter:Connect(function() aGrad.Enabled=false; FT(aPill,{BackgroundColor3=T.AccentHi},0.12) end)
			aBB.MouseLeave:Connect(function() aGrad.Enabled=true; FT(aPill,{BackgroundColor3=color},0.12) end)
			aBB.MouseButton1Click:Connect(DoRun)
			local cBB=MkButton(card,"",0,T.Black,T.White)
			cBB.BackgroundTransparency=1; cBB.Size=UDim2.new(1,-(pillW+6),1,0); cBB.ZIndex=5
			cBB.MouseEnter:Connect(function() FT(card,{BackgroundColor3=T.SurfaceHi},0.12) end)
			cBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},0.12) end)
			cBB.MouseButton1Click:Connect(DoRun)
		end

		-- ══════════════════════════════════════════════════
		--  TOGGLE  (iOS)
		-- ══════════════════════════════════════════════════
		function API:AddToggle(opt)
			opt=opt or {}
			local name=opt.Name or "Toggle"; local desc=opt.Desc or ""
			local def=opt.Default or false; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent; local id=opt.Id or ""

			local cardH=desc~="" and 58 or 46; local card=Card(cardH)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,-68,0,22); nl.Position=UDim2.new(0,0,0,desc~="" and 4 or 0)
			nl.TextYAlignment=Enum.TextYAlignment.Center; nl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,-68,0,16); dl.Position=UDim2.new(0,0,0,28); dl.ZIndex=5
			end

			local track=MkFrame(card,UDim2.new(0,50,0,28),UDim2.new(1,-50,0.5,-14),T.TogOff)
			track.ZIndex=5; Corner(track,14); Stroke(track,T.Border,1)
			local thumb=MkFrame(track,UDim2.new(0,22,0,22),UDim2.new(0,3,0.5,-11),T.White)
			thumb.ZIndex=6; Corner(thumb,11)
			local tStroke=Stroke(thumb,T.Border,1.5)

			local state=def; local busy=false
			local function Refresh(anim)
				if state then
					if anim then
						FT(track,{BackgroundColor3=color},0.22)
						ST(thumb,{Position=UDim2.new(0,25,0.5,-11)},0.26)
						FT(tStroke,{Color=color,Thickness=2},0.22)
					else
						track.BackgroundColor3=color; thumb.Position=UDim2.new(0,25,0.5,-11)
						tStroke.Color=color; tStroke.Thickness=2
					end
				else
					if anim then
						FT(track,{BackgroundColor3=T.TogOff},0.22)
						ST(thumb,{Position=UDim2.new(0,3,0.5,-11)},0.26)
						FT(tStroke,{Color=T.Border,Thickness=1.5},0.22)
					else
						track.BackgroundColor3=T.TogOff; thumb.Position=UDim2.new(0,3,0.5,-11)
						tStroke.Color=T.Border; tStroke.Thickness=1.5
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy then return end; busy=true; state=not state; Refresh(true)
				pcall(cb,state); task.wait(0.3); busy=false
			end
			track.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog={}
			function Tog:Set(v) state=v; Refresh(true) end
			function Tog:Get() return state end
			_RegElement(wName, id, function() return state end, function(v) state=v; Refresh(true) end, "bool")
			return Tog
		end

		-- ══════════════════════════════════════════════════
		--  SLIDER
		-- ══════════════════════════════════════════════════
		function API:AddSlider(opt)
			opt=opt or {}
			local name=opt.Name or "Slider"; local desc=opt.Desc or ""
			local min=opt.Min or 0; local max=opt.Max or 100
			local def=opt.Default or min; local sfx=opt.Suffix or ""
			local cb=opt.Callback or function() end; local color=opt.Color or T.Accent
			local id=opt.Id or ""

			local cardH=desc~="" and 74 or 62; local card=Card(cardH)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold)
			nl.Size=UDim2.new(0.62,0,0,20); nl.ZIndex=5
			local vl=MkLabel(card,tostring(def)..sfx,13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
			vl.Size=UDim2.new(0.38,0,0,20); vl.ZIndex=5

			if desc~="" then
				local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham)
				dl.Size=UDim2.new(1,0,0,14); dl.Position=UDim2.new(0,0,0,22); dl.ZIndex=5
			end

			local yOff=desc~="" and 44 or 30
			local tBG=MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,yOff),T.SurfaceHi)
			tBG.ZIndex=5; Corner(tBG,5); Stroke(tBG,T.Border,1)
			local fill=MkFrame(tBG,UDim2.new(0,0,1,0),nil,color)
			fill.ZIndex=6; Corner(fill,5)
			local fillG=Instance.new("UIGradient")
			fillG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)})
			fillG.Parent=fill

			local knob=MkFrame(tBG,UDim2.new(0,22,0,22),UDim2.new(0,-11,0.5,-11),T.White)
			knob.ZIndex=7; Corner(knob,11); local kRing=Stroke(knob,color,2)

			local val=math.clamp(def,min,max); local sliding=false
			local function SetVal(v)
				val=math.clamp(v,min,max)
				local pct=(val-min)/(max-min)
				FT(fill,{Size=UDim2.new(pct,0,1,0)},0.07)
				FT(knob,{Position=UDim2.new(pct,-11,0.5,-11)},0.07)
				vl.Text=tostring(math.round(val))..sfx
			end
			SetVal(def)

			local function FromPos(pos)
				return min+math.clamp((pos.X-tBG.AbsolutePosition.X)/tBG.AbsoluteSize.X,0,1)*(max-min)
			end

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=true; FT(knob,{Size=UDim2.new(0,26,0,26)},0.1)
					FT(kRing,{Thickness=3},0.1); SetVal(FromPos(i.Position)); pcall(cb,math.round(val))
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
				or i.UserInputType==Enum.UserInputType.Touch) then
					SetVal(FromPos(i.Position)); pcall(cb,math.round(val))
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1
				or i.UserInputType==Enum.UserInputType.Touch then
					sliding=false; FT(knob,{Size=UDim2.new(0,22,0,22)},0.12); FT(kRing,{Thickness=2},0.12)
				end
			end)

			local Sl={}
			function Sl:Set(v) SetVal(v) end
			function Sl:Get() return math.round(val) end
			_RegElement(wName, id, function() return math.round(val) end,
				function(v) SetVal(tonumber(v) or min) end, "number")
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
			local pillLbl=MkLabel(pill,selVal,12,T.TxtMain,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-28,1,0); pillLbl.Position=UDim2.new(0,10,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd
			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chevLbl.Size=UDim2.new(0,22,1,0); chevLbl.Position=UDim2.new(1,-24,0,0); chevLbl.ZIndex=6

			-- List frame on overlay
			local listFrame=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			listFrame.ZIndex=50; listFrame.Visible=false; listFrame.ClipsDescendants=true
			Corner(listFrame,12); Stroke(listFrame,T.BorderBri,1)

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
			sTB.Font=Enum.Font.Gotham; sTB.TextSize=12
			sTB.Size=UDim2.new(1,-14,1,0); sTB.Position=UDim2.new(0,7,0,0)
			sTB.TextXAlignment=Enum.TextXAlignment.Left; sTB.ClearTextOnFocus=false
			sTB.ZIndex=53; sTB.Parent=sBG

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
				local cAY=card.AbsolutePosition.Y; local cAH=card.AbsoluteSize.Y
				local yPos=(cAY-oAY)+cAH+4
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
					local lx=listFrame.AbsolutePosition.X; local ly=listFrame.AbsolutePosition.Y
					local lw=listFrame.AbsoluteSize.X; local lh=listFrame.AbsoluteSize.Y
					local px=pill.AbsolutePosition.X; local py=pill.AbsolutePosition.Y
					local pw=pill.AbsoluteSize.X; local ph=pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not (mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh)
					and not (mx>=px and mx<=px+pw and my>=py and my<=py+ph) then
						CloseList()
					end
				end
			end)

			local Drop={}
			function Drop:Get() return selVal end
			function Drop:Set(v) selVal=v; pillLbl.Text=v; BuildItems("") end
			function Drop:Refresh(ni) items=ni; selVal=ni[1] or ""; pillLbl.Text=selVal; BuildItems("") end
			_RegElement(wName, id, function() return selVal end,
				function(v) selVal=tostring(v); pillLbl.Text=selVal; BuildItems("") end, "string")
			return Drop
		end

		-- ══════════════════════════════════════════════════
		--  MULTI DROPDOWN  (NEW v3.4)
		--  Checkbox-style multi-select with a floating list.
		--  Callback fires with a table of selected strings.
		-- ══════════════════════════════════════════════════
		function API:AddMultiDropdown(opt)
			opt=opt or {}
			local name=opt.Name or "Multi Select"; local items=opt.Items or {"Item 1","Item 2"}
			local def=opt.Default or {}; local cb=opt.Callback or function() end
			local color=opt.Color or T.Accent; local id=opt.Id or ""

			local card=Card(46); local selected={}; local isOpen=false

			-- seed defaults
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
			pill.ZIndex=5; Corner(pill,10); Stroke(pill,T.Border,1)

			local pillLbl=MkLabel(pill,PillText(),12,T.TxtMain,Enum.Font.GothamSemibold)
			pillLbl.Size=UDim2.new(1,-28,1,0); pillLbl.Position=UDim2.new(0,10,0,0)
			pillLbl.ZIndex=6; pillLbl.TextTruncate=Enum.TextTruncate.AtEnd

			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			chevLbl.Size=UDim2.new(0,22,1,0); chevLbl.Position=UDim2.new(1,-24,0,0); chevLbl.ZIndex=6

			-- Selected count badge
			local badge=MkFrame(pill,UDim2.new(0,18,0,18),UDim2.new(1,-44,0.5,-9),T.Accent)
			badge.ZIndex=7; Corner(badge,9)
			local badgeLbl=MkLabel(badge,"0",10,T.White,Enum.Font.GothamBold,
				Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			badgeLbl.ZIndex=8
			local function RefreshBadge()
				local n=#GetSelected()
				badgeLbl.Text=tostring(n)
				badge.BackgroundTransparency = n==0 and 1 or 0
			end
			RefreshBadge()

			-- Floating list on overlay
			local listFrame=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface)
			listFrame.ZIndex=50; listFrame.Visible=false; listFrame.ClipsDescendants=true
			Corner(listFrame,12); Stroke(listFrame,T.BorderBri,1)

			local listInner=MkFrame(listFrame,UDim2.new(1,0,1,0),nil,T.Black)
			listInner.BackgroundTransparency=1; listInner.ZIndex=51
			local liLL=Instance.new("UIListLayout")
			liLL.FillDirection=Enum.FillDirection.Vertical; liLL.SortOrder=Enum.SortOrder.LayoutOrder
			liLL.Padding=UDim.new(0,3); liLL.Parent=listInner; Pad(listInner,5,5,5,5)

			-- Top action bar: "Select All" | "Clear"
			local actionRow=MkFrame(listInner,UDim2.new(1,0,0,28),nil,T.SurfaceHi)
			actionRow.ZIndex=52; Corner(actionRow,8)

			local selAllBtn=MkButton(actionRow,"Select All",11,T.AccentLo,T.AccentHi,Enum.Font.GothamBold)
			selAllBtn.BackgroundTransparency=1; selAllBtn.Size=UDim2.new(0.5,0,1,0)
			selAllBtn.TextXAlignment=Enum.TextXAlignment.Center

			local clearBtn=MkButton(actionRow,"Clear",11,T.AccentLo,T.TxtMute,Enum.Font.GothamBold)
			clearBtn.BackgroundTransparency=1; clearBtn.Size=UDim2.new(0.5,0,1,0)
			clearBtn.Position=UDim2.new(0.5,0,0,0)
			clearBtn.TextXAlignment=Enum.TextXAlignment.Center

			-- Items
			local itemsSF=Instance.new("ScrollingFrame")
			itemsSF.BackgroundTransparency=1; itemsSF.BorderSizePixel=0
			itemsSF.Size=UDim2.new(1,0,0,0); itemsSF.CanvasSize=UDim2.new(0,0,0,0)
			itemsSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			itemsSF.ScrollBarThickness=2; itemsSF.ScrollBarImageColor3=T.Accent
			itemsSF.ZIndex=52; itemsSF.Parent=listInner
			local iLL=Instance.new("UIListLayout")
			iLL.FillDirection=Enum.FillDirection.Vertical; iLL.SortOrder=Enum.SortOrder.LayoutOrder
			iLL.Padding=UDim.new(0,2); iLL.Parent=itemsSF

			local rowRefs={}  -- { item=string, ckLbl=lbl, rowFrame=frame }

			local function BuildMultiItems()
				for _,r in rowRefs do r.rowFrame.Parent=nil end; rowRefs={}
				for _,item in items do
					local row=MkFrame(itemsSF,UDim2.new(1,0,0,34),nil,T.Black)
					row.BackgroundTransparency=1; row.ZIndex=53; Corner(row,7)

					-- Checkbox square
					local cbBox=MkFrame(row,UDim2.new(0,20,0,20),UDim2.new(0,6,0.5,-10),T.SurfaceHi2)
					cbBox.ZIndex=54; Corner(cbBox,5); Stroke(cbBox,T.Border,1)

					local ckMark=MkLabel(cbBox,selected[item] and ">" or "",11,color,Enum.Font.GothamBold,
						Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
					ckMark.ZIndex=55

					if selected[item] then
						cbBox.BackgroundColor3=T.AccentLo
						Stroke(cbBox,color,1)
					end

					local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham)
					iLbl.Size=UDim2.new(1,-36,1,0); iLbl.Position=UDim2.new(0,34,0,0); iLbl.ZIndex=54

					local hit=MkButton(row,"",0,T.Black,T.White)
					hit.BackgroundTransparency=1; hit.Size=UDim2.new(1,0,1,0); hit.ZIndex=55
					hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},0.1) end)
					hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},0.1) end)

					hit.MouseButton1Click:Connect(function()
						selected[item]=not selected[item]
						ckMark.Text=selected[item] and ">" or ""
						if selected[item] then
							FT(cbBox,{BackgroundColor3=T.AccentLo},0.12)
						else
							FT(cbBox,{BackgroundColor3=T.SurfaceHi2},0.12)
						end
						pillLbl.Text=PillText(); RefreshBadge()
						pcall(cb, GetSelected())
					end)
					table.insert(rowRefs,{item=item, ckLbl=ckMark, rowFrame=row})
				end
				itemsSF.Size=UDim2.new(1,0,0,math.min(#items,5)*36+4)
			end
			BuildMultiItems()

			selAllBtn.MouseButton1Click:Connect(function()
				for _,item in items do selected[item]=true end
				BuildMultiItems(); pillLbl.Text=PillText(); RefreshBadge(); pcall(cb,GetSelected())
			end)
			clearBtn.MouseButton1Click:Connect(function()
				for _,item in items do selected[item]=false end
				BuildMultiItems(); pillLbl.Text=PillText(); RefreshBadge(); pcall(cb,GetSelected())
			end)

			local function CloseMulti()
				if not isOpen then return end; isOpen=false
				FT(listFrame,{Size=UDim2.new(1,-20,0,0)},0.18)
				FT(chevLbl,{Rotation=0},0.18); FT(pill,{BackgroundColor3=T.SurfaceHi},0.12)
				task.wait(0.2); listFrame.Visible=false
			end

			local pillBB=MkButton(pill,"",0,T.Black,T.White)
			pillBB.BackgroundTransparency=1; pillBB.Size=UDim2.new(1,0,1,0); pillBB.ZIndex=7
			pillBB.MouseButton1Click:Connect(function()
				if isOpen then CloseMulti(); return end
				isOpen=true; BuildMultiItems()
				local oAY=dropOverlay.AbsolutePosition.Y
				local cAY=card.AbsolutePosition.Y; local cAH=card.AbsoluteSize.Y
				local yPos=(cAY-oAY)+cAH+4
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
					local lx=listFrame.AbsolutePosition.X; local ly=listFrame.AbsolutePosition.Y
					local lw=listFrame.AbsoluteSize.X; local lh=listFrame.AbsoluteSize.Y
					local px=pill.AbsolutePosition.X; local py=pill.AbsolutePosition.Y
					local pw=pill.AbsoluteSize.X; local ph=pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not(mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh)
					and not(mx>=px and mx<=px+pw and my>=py and my<=py+ph) then
						CloseMulti()
					end
				end
			end)

			local MD={}
			function MD:Get() return GetSelected() end
			function MD:Set(tbl)
				for _,item in items do selected[item]=false end
				for _,v in tbl do selected[v]=true end
				pillLbl.Text=PillText(); RefreshBadge(); BuildMultiItems()
			end
			_RegElement(wName, id,
				function() return GetSelected() end,
				function(v) if type(v)=="table" then for _,item in items do selected[item]=false end
					for _,s in v do selected[s]=true end; pillLbl.Text=PillText(); RefreshBadge(); BuildMultiItems() end end,
				"multi")
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

			local card=Card(68); Pad(card,8,8,14,14)
			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold)
			nl.Size=UDim2.new(1,0,0,18); nl.ZIndex=5

			local inBG=MkFrame(card,UDim2.new(1,0,0,32),UDim2.new(0,0,0,22),T.SurfaceHi)
			inBG.ZIndex=5; Corner(inBG,9); local inS=Stroke(inBG,T.Border,1)
			local pre=MkLabel(inBG,">",15,T.TxtMute,Enum.Font.GothamBold,
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
				FT(inS,{Color=color,Thickness=1.5},0.15); FT(pre,{TextColor3=color},0.15)
			end)
			tb.FocusLost:Connect(function(enter)
				FT(inBG,{BackgroundColor3=T.SurfaceHi},0.15)
				FT(inS,{Color=T.Border,Thickness=1},0.15); FT(pre,{TextColor3=T.TxtMute},0.15)
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
			_RegElement(wName, id, function() return tb.Text end,
				function(v) tb.Text=tostring(v) end, "string")
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
			local kPill=MkFrame(card,UDim2.new(0,110,0,30),UDim2.new(1,-110,0.5,-15),T.SurfaceHi)
			kPill.ZIndex=5; Corner(kPill,8); Stroke(kPill,T.Border,1)
			local kLbl=MkLabel(kPill,"["..tostring(def.Name).."]",11,T.TxtMain,
				Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
			kLbl.ZIndex=6
			local kBB=MkButton(kPill,"",0,T.Black,T.White)
			kBB.BackgroundTransparency=1; kBB.Size=UDim2.new(1,0,1,0); kBB.ZIndex=7
			kBB.MouseButton1Click:Connect(function()
				listening=true; kLbl.Text="[  ?  ]"; FT(kPill,{BackgroundColor3=T.AccentLo},0.12)
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
					FT(ring,{Transparency=0},0.1); activeRing=ring; pcall(cb,col)
				end)
			end

			local CP={}
			function CP:Get() return selColor end
			function CP:Set(c) selColor=c; prev.BackgroundColor3=c end
			_RegElement(wName, id, function() return selColor end,
				function(v) selColor=v; prev.BackgroundColor3=v end, "color")
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

		-- ══════════════════════════════════════════════════
		--  CREDIT  (transparent bg, styled centred text)
		-- ══════════════════════════════════════════════════
		function API:AddCredit(line1, line2)
			line1=line1 or "Credit"; line2=line2 or ""
			local wrap=MkFrame(page,UDim2.new(1,0,0,line2~="" and 72 or 54),nil,T.Black)
			wrap.BackgroundTransparency=1; wrap.ZIndex=4

			MkFrame(wrap,UDim2.new(0.3,0,0,1),UDim2.new(0.05,0,0,0),Color3.fromRGB(90,58,160)).BackgroundTransparency=0.5
			MkFrame(wrap,UDim2.new(0.3,0,0,1),UDim2.new(0.65,0,0,0),Color3.fromRGB(90,58,160)).BackgroundTransparency=0.5

			local l1=Instance.new("TextLabel")
			l1.Text=line1; l1.TextSize=14; l1.Font=Enum.Font.GothamBold
			l1.TextColor3=Color3.fromRGB(196,170,255); l1.BackgroundTransparency=1
			l1.BorderSizePixel=0; l1.Size=UDim2.new(1,0,0,22); l1.Position=UDim2.new(0,0,0,8)
			l1.TextXAlignment=Enum.TextXAlignment.Center; l1.ZIndex=5; l1.Parent=wrap

			if line2~="" then
				local l2=Instance.new("TextLabel")
				l2.Text=line2; l2.TextSize=11; l2.Font=Enum.Font.Gotham
				l2.TextColor3=Color3.fromRGB(110,90,150); l2.BackgroundTransparency=1
				l2.BorderSizePixel=0; l2.Size=UDim2.new(1,0,0,18); l2.Position=UDim2.new(0,0,0,34)
				l2.TextXAlignment=Enum.TextXAlignment.Center; l2.ZIndex=5; l2.Parent=wrap
			end

			MkFrame(wrap,UDim2.new(0.3,0,0,1),UDim2.new(0.05,0,1,-1),Color3.fromRGB(90,58,160)).BackgroundTransparency=0.5
			MkFrame(wrap,UDim2.new(0.3,0,0,1),UDim2.new(0.65,0,1,-1),Color3.fromRGB(90,58,160)).BackgroundTransparency=0.5
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

return NexusUI
