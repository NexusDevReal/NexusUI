--[[
╔══════════════════════════════════════════════════════════════════╗
║   NexusUI  v1.8 —  Roblox Luau UI Library                       ║
╠══════════════════════════════════════════════════════════════════╣
║  Roblox Asset Image Support (MkIcon):                            ║
║    "N"                      → TextLabel  (ASCII text icon)       ║
║    "rbxassetid://123456789" → ImageLabel (full asset URL)        ║
║    "123456789"              → ImageLabel (raw numeric ID)        ║
║    "rbxthumb://..."         → ImageLabel (thumbnail URL)         ║
║    {Icon="...", Color=...,  → Extended options table             ║
║     Size=UDim2, NoTint=bool, Trans=0.0, Scale="Fit"}             ║
║                                                                  ║
║  Supported everywhere:                                           ║
║    Window Icon  · Notification Icon  · Button Icon               ║
║    Tab Icon  · Section Icon                                      ║
║                                                                  ║
║  ID System:                                                      ║
║    Id="key" on any element → registers for Config + query        ║
║    Win:GetValue(id)   Win:SetValue(id,v)                         ║
║    Win:GetElement(id) Win:ListIds()                              ║
║    Win:SaveConfig(name)  Win:LoadConfig(name)                    ║
║                                                                  ║
║  Dropdown nil-start:                                             ║
║    Default=nil → shows Placeholder, :IsEmpty(), :Clear()        ║
║                                                                  ║
║  Every element has: :SetVisible(bool)  :Destroy()               ║
╚══════════════════════════════════════════════════════════════════╝
-- ═══════════════════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════════════════════════════
local T = {
	-- Backgrounds
	BG          = Color3.fromRGB( 11,   8,  24),
	Surface     = Color3.fromRGB( 20,  15,  40),
	SurfaceHi   = Color3.fromRGB( 30,  23,  56),
	SurfaceHi2  = Color3.fromRGB( 42,  32,  72),
	SurfaceHi3  = Color3.fromRGB( 54,  42,  90),
	-- Borders
	Border      = Color3.fromRGB( 58,  44,  96),
	BorderBri   = Color3.fromRGB( 90,  68, 148),
	BorderGlow  = Color3.fromRGB(110,  80, 200),
	-- Accent
	Accent      = Color3.fromRGB(138,  76, 255),
	AccentHi    = Color3.fromRGB(170, 118, 255),
	AccentLo    = Color3.fromRGB( 94,  48, 205),
	AccentDeep  = Color3.fromRGB( 62,  30, 148),
	-- Text
	TxtMain     = Color3.fromRGB(242, 236, 255),
	TxtSub      = Color3.fromRGB(158, 140, 202),
	TxtMute     = Color3.fromRGB( 90,  75, 126),
	TxtOff      = Color3.fromRGB( 54,  44,  82),
	-- Status
	Green       = Color3.fromRGB( 68, 214, 132),
	Red         = Color3.fromRGB(248,  64,  92),
	Yellow      = Color3.fromRGB(252, 188,  52),
	Blue        = Color3.fromRGB( 52, 172, 254),
	-- Misc
	TogOff      = Color3.fromRGB( 40,  32,  66),
	NotifBG     = Color3.fromRGB( 18,  13,  38),
	White       = Color3.fromRGB(255, 255, 255),
	Black       = Color3.fromRGB(  0,   0,   0),
}

-- ═══════════════════════════════════════════════════════════════
--  TWEEN SHORTCUTS
-- ═══════════════════════════════════════════════════════════════
-- FT: fast smooth  |  ST: spring/bounce  |  LT: linear  |  ET: elastic
local function FT(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.18,
		Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play()
end
local function ST(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.30,
		Enum.EasingStyle.Back, Enum.EasingDirection.Out), p):Play()
end
local function LT(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.25,
		Enum.EasingStyle.Linear, Enum.EasingDirection.Out), p):Play()
end
local function ET(o, p, t)
	TweenService:Create(o, TweenInfo.new(t or 0.36,
		Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), p):Play()
end

-- ═══════════════════════════════════════════════════════════════
--  UI PRIMITIVES
-- ═══════════════════════════════════════════════════════════════
local function Corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function Stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color           = color or T.Border
	s.Thickness       = thickness or 1
	s.Transparency    = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function Pad(parent, top, bottom, left, right)
	local u = Instance.new("UIPadding")
	u.PaddingTop    = UDim.new(0, top    or 8)
	u.PaddingBottom = UDim.new(0, bottom or 8)
	u.PaddingLeft   = UDim.new(0, left   or 10)
	u.PaddingRight  = UDim.new(0, right  or 10)
	u.Parent = parent
	return u
end

local function MkFrame(parent, size, pos, color, clip, zIndex)
	local f = Instance.new("Frame")
	f.Size             = size  or UDim2.new(1, 0, 0, 40)
	f.Position         = pos   or UDim2.new(0, 0, 0,  0)
	f.BackgroundColor3 = color or T.Surface
	f.BorderSizePixel  = 0
	f.ClipsDescendants = clip or false
	if zIndex then f.ZIndex = zIndex end
	f.Parent = parent
	return f
end

local function MkLabel(parent, text, size, color, font, xAlign, yAlign, wrap)
	local l = Instance.new("TextLabel")
	l.Text             = text  or ""
	l.TextSize         = size  or 13
	l.TextColor3       = color or T.TxtMain
	l.Font             = font  or Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.BorderSizePixel  = 0
	l.Size             = UDim2.new(1, 0, 1, 0)
	l.TextXAlignment   = xAlign or Enum.TextXAlignment.Left
	l.TextYAlignment   = yAlign or Enum.TextYAlignment.Center
	l.TextWrapped      = wrap or false
	l.RichText         = false
	l.Parent = parent
	return l
end

local function MkButton(parent, text, textSize, bgColor, textColor, font)
	local b = Instance.new("TextButton")
	b.Text             = text      or ""
	b.TextSize         = textSize  or 13
	b.TextColor3       = textColor or T.TxtMain
	b.BackgroundColor3 = bgColor   or T.SurfaceHi
	b.Font             = font      or Enum.Font.GothamBold
	b.BorderSizePixel  = 0
	b.AutoButtonColor  = false
	b.Size             = UDim2.new(1, 0, 1, 0)
	b.Parent = parent
	return b
end

-- Glass top-shine on cards/pills
local function CardShine(card)
	local s = MkFrame(card, UDim2.new(1, -6, 0, 1), UDim2.new(0, 3, 0, 1), T.White)
	s.BackgroundTransparency = 0.88
	s.ZIndex = (card.ZIndex or 4) + 1
	Corner(s, 2)
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,    1),
		NumberSequenceKeypoint.new(0.12, 0.88),
		NumberSequenceKeypoint.new(0.5,  0.82),
		NumberSequenceKeypoint.new(0.88, 0.88),
		NumberSequenceKeypoint.new(1,    1),
	})
	g.Parent = s
	return s
end

-- ═══════════════════════════════════════════════════════════════
--  MkIcon — Unified Icon Renderer
--
--  Accepted formats for `iconArg`:
--    "N"                     → TextLabel  (plain ASCII/text)
--    "rbxassetid://12345"    → ImageLabel (Roblox asset)
--    "12345"                 → ImageLabel (raw numeric ID → rbxassetid)
--    "rbxthumb://type=..."   → ImageLabel (thumbnail URL)
--    {Icon=..., Color=...,
--     Size=UDim2, NoTint=bool,
--     Trans=number,
--     Scale="Fit"|"Crop"|"Stretch",
--     TextSize=number,
--     Font=Enum.Font}        → Extended options table
--
--  `parent`    — Instance to parent the created label/image into
--  `iconArg`   — String or table as described above
--  `textSize`  — Default text size (ignored for images)
--  `textColor` — Tint colour (for images this sets ImageColor3)
--  `imgSize`   — UDim2 size for images (default 72% of parent)
--  `zIndex`    — ZIndex of the created instance
--
--  Returns the created TextLabel or ImageLabel.
-- ═══════════════════════════════════════════════════════════════
local _ScaleTypes = {
	Fit     = Enum.ScaleType.Fit,
	Crop    = Enum.ScaleType.Crop,
	Stretch = Enum.ScaleType.Stretch,
}

local function _ResolveAssetUrl(icon)
	-- Returns (true, url) if icon should be rendered as an image,
	-- or (false, nil) if it should be rendered as text.
	if type(icon) ~= "string" or icon == "" then return false, nil end
	-- Full rbxassetid URL
	if icon:match("^rbxassetid://%d+$") then
		return true, icon
	end
	-- Thumbnail URL
	if icon:match("^rbxthumb://") then
		return true, icon
	end
	-- Game-asset URL
	if icon:match("^rbxgameasset://") then
		return true, icon
	end
	-- Raw numeric string — treat as asset ID
	if icon:match("^%d+$") then
		return true, "rbxassetid://" .. icon
	end
	-- HTTP(S) URL (for external images when allowed)
	if icon:match("^https?://") then
		return true, icon
	end
	return false, nil
end

local function MkIcon(parent, iconArg, textSize, textColor, imgSize, zIndex)
	-- Parse extended options table if provided
	local icon, size, color, noTint, trans, scaleKey, tSize, font, zi
	if type(iconArg) == "table" then
		local o = iconArg
		icon     = tostring(o.Icon or "")
		size     = o.Size      or UDim2.new(0.72, 0, 0.72, 0)
		color    = o.Color     or textColor or T.White
		noTint   = o.NoTint    or false
		trans    = o.Trans     or 0
		scaleKey = o.Scale     or "Fit"
		tSize    = o.TextSize  or textSize or 18
		font     = o.Font      or Enum.Font.GothamBold
		zi       = o.ZIndex    or zIndex or 4
	else
		icon     = tostring(iconArg or "")
		size     = imgSize  or UDim2.new(0.72, 0, 0.72, 0)
		color    = textColor or T.White
		noTint   = false
		trans    = 0
		scaleKey = "Fit"
		tSize    = textSize or 18
		font     = Enum.Font.GothamBold
		zi       = zIndex or 4
	end

	local isImage, url = _ResolveAssetUrl(icon)

	if isImage then
		-- ── Image Icon ────────────────────────────────────────
		local img = Instance.new("ImageLabel")
		img.Image                  = url
		img.BackgroundTransparency = 1
		img.BorderSizePixel        = 0
		img.Size                   = size
		img.AnchorPoint            = Vector2.new(0.5, 0.5)
		img.Position               = UDim2.new(0.5, 0, 0.5, 0)
		img.ImageColor3            = noTint and T.White or color
		img.ImageTransparency      = trans
		img.ScaleType              = _ScaleTypes[scaleKey] or Enum.ScaleType.Fit
		img.ZIndex                 = zi
		img.Parent                 = parent
		return img
	else
		-- ── Text Icon ─────────────────────────────────────────
		local lbl = Instance.new("TextLabel")
		lbl.Text                  = icon
		lbl.TextSize              = tSize
		lbl.TextColor3            = color
		lbl.Font                  = font
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

-- ═══════════════════════════════════════════════════════════════
--  DRAG SYSTEM  (mouse + touch)
-- ═══════════════════════════════════════════════════════════════
local function MakeDraggable(win, handle)
	handle = handle or win
	local dragging, dragInput, mouseStart, frameStart = false, nil, nil, nil

	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging   = true
			mouseStart = i.Position
			frameStart = win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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
		if i == dragInput and dragging then
			local delta = i.Position - mouseStart
			win.Position = UDim2.new(
				frameStart.X.Scale, frameStart.X.Offset + delta.X,
				frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
			)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════
--  SAFE CALLBACK  — pcall + warn; never crashes the UI
-- ═══════════════════════════════════════════════════════════════
local function SafeCall(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[NexusUI] Callback error: " .. tostring(err))
	end
end

-- ═══════════════════════════════════════════════════════════════
--  CONFIG REGISTRY
--  Shape: _ConfigReg[windowName][id] = { Get, Set, Type, API }
-- ═══════════════════════════════════════════════════════════════
local _ConfigReg = {}

local function _RegElement(winName, id, getter, setter, elType, api)
	if not id or id == "" then return end
	if not _ConfigReg[winName] then
		_ConfigReg[winName] = {}
	end
	if _ConfigReg[winName][id] then
		warn(("[NexusUI] Duplicate Id '%s' in '%s' — overwritten"):format(id, winName))
	end
	_ConfigReg[winName][id] = { Get = getter, Set = setter, Type = elType, API = api }
end

local function _EncodeColor(c)
	return { r = math.round(c.R * 255), g = math.round(c.G * 255), b = math.round(c.B * 255) }
end
local function _DecodeColor(t)
	return Color3.fromRGB(t.r, t.g, t.b)
end

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ═══════════════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.MkIcon  = MkIcon   -- exposed for advanced user scripts

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local _NotifHolder = nil

local function _InitNotifHolder(sg)
	if _NotifHolder then _NotifHolder:Destroy() end

	_NotifHolder = Instance.new("Frame")
	_NotifHolder.Name                  = "NexusNotifHolder"
	_NotifHolder.BackgroundTransparency = 1
	_NotifHolder.BorderSizePixel        = 0
	_NotifHolder.Size                   = UDim2.new(0, 296, 1, -20)
	_NotifHolder.Position               = UDim2.new(1, -304, 0, 10)
	_NotifHolder.ZIndex                 = 200
	_NotifHolder.Parent                 = sg

	local layout = Instance.new("UIListLayout")
	layout.FillDirection     = Enum.FillDirection.Vertical
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.SortOrder         = Enum.SortOrder.LayoutOrder
	layout.Padding           = UDim.new(0, 8)
	layout.Parent            = _NotifHolder
end

function NexusUI:Notify(opt)
	opt = opt or {}
	local title  = opt.Title    or "Notification"
	local desc   = opt.Desc     or ""
	local dur    = opt.Duration or 4
	-- Icon supports text ("OK", "!") or asset ID ("rbxassetid://…")
	local icon   = opt.Icon     or "!"
	local accent = opt.Color    or T.Accent
	if not _NotifHolder then return end

	-- Card (starts off-screen to the right)
	local card = MkFrame(_NotifHolder, UDim2.new(1, 0, 0, 74), UDim2.new(1, 20, 0, 0), T.NotifBG)
	card.ZIndex = 200
	Corner(card, 13)
	Stroke(card, accent, 1, 0.25)
	CardShine(card)

	-- Left edge gradient bar
	local edgeBar = MkFrame(card, UDim2.new(0, 3, 1, 0), nil, accent)
	edgeBar.ZIndex = 201; Corner(edgeBar, 3)
	local edgeG = Instance.new("UIGradient")
	edgeG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accent),
		ColorSequenceKeypoint.new(1, T.AccentDeep),
	})
	edgeG.Rotation = 90; edgeG.Parent = edgeBar

	-- Icon bubble — starts tiny, springs to full size
	local icBox = MkFrame(card, UDim2.new(0, 4, 0, 4), UDim2.new(0, 30, 0.5, -2), T.SurfaceHi)
	icBox.ZIndex = 202; Corner(icBox, 11); Stroke(icBox, accent, 1, 0.35)
	-- MkIcon renders either a text label or an ImageLabel depending on `icon`
	MkIcon(icBox, icon, 15, accent, UDim2.new(0.70, 0, 0.70, 0), 203)

	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Text               = title
	titleLbl.TextSize           = 13
	titleLbl.Font               = Enum.Font.GothamBold
	titleLbl.TextColor3         = T.TxtMain
	titleLbl.BackgroundTransparency = 1
	titleLbl.BorderSizePixel    = 0
	titleLbl.Size               = UDim2.new(1, -78, 0, 20)
	titleLbl.Position           = UDim2.new(0, 58, 0, 12)
	titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
	titleLbl.ZIndex             = 201
	titleLbl.Parent             = card

	-- Description
	if desc ~= "" then
		local descLbl = Instance.new("TextLabel")
		descLbl.Text               = desc
		descLbl.TextSize           = 11
		descLbl.Font               = Enum.Font.Gotham
		descLbl.TextColor3         = T.TxtSub
		descLbl.BackgroundTransparency = 1
		descLbl.BorderSizePixel    = 0
		descLbl.Size               = UDim2.new(1, -78, 0, 18)
		descLbl.Position           = UDim2.new(0, 58, 0, 34)
		descLbl.TextXAlignment     = Enum.TextXAlignment.Left
		descLbl.TextWrapped        = true
		descLbl.ZIndex             = 201
		descLbl.Parent             = card
	end

	-- Close button
	local xBtn = Instance.new("TextButton")
	xBtn.Text               = "x"
	xBtn.TextSize           = 11
	xBtn.Font               = Enum.Font.GothamBold
	xBtn.TextColor3         = T.TxtMute
	xBtn.BackgroundTransparency = 1
	xBtn.BorderSizePixel    = 0
	xBtn.Size               = UDim2.new(0, 20, 0, 20)
	xBtn.Position           = UDim2.new(1, -24, 0, 5)
	xBtn.ZIndex             = 202
	xBtn.Parent             = card
	xBtn.MouseEnter:Connect(function() FT(xBtn, { TextColor3 = T.Red }, 0.10) end)
	xBtn.MouseLeave:Connect(function() FT(xBtn, { TextColor3 = T.TxtMute }, 0.10) end)

	-- Progress bar
	local pgBg = MkFrame(card, UDim2.new(1, -20, 0, 3), UDim2.new(0, 10, 1, -9), T.SurfaceHi)
	pgBg.ZIndex = 201; Corner(pgBg, 2)
	local pgFill = MkFrame(pgBg, UDim2.new(1, 0, 1, 0), nil, accent)
	pgFill.ZIndex = 202; Corner(pgFill, 2)
	LT(pgFill, { Size = UDim2.new(0, 0, 1, 0) }, dur)

	-- Slide card in from right
	FT(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.26)

	-- Icon bubble springs in (delayed slightly for drama)
	task.delay(0.05, function()
		if card and card.Parent then
			ST(icBox, { Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 12, 0.5, -18) }, 0.32)
		end
	end)

	-- Dismiss
	local dismissed = false
	local function Dismiss()
		if dismissed then return end; dismissed = true
		FT(card, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, 0.20)
		task.wait(0.22); card:Destroy()
	end
	xBtn.MouseButton1Click:Connect(Dismiss)
	task.delay(dur, Dismiss)
	return card
end

-- ═══════════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(opt)
	opt = opt or {}
	local wTitle  = opt.Title    or "NexusUI"
	local wSub    = opt.Subtitle or "v1.8"
	-- Icon can be text ("W") or asset ("rbxassetid://123" / "123456789")
	local wIcon   = opt.Icon     or "N"
	local wSize   = opt.Size     or UDim2.new(0, 370, 0, 500)
	local wPos    = opt.Position or UDim2.new(0.5, -185, 0.5, -250)
	local wName   = wTitle   -- used as config registry key

	-- ──────────────────────────────────────────────────────────
	--  ScreenGui
	-- ──────────────────────────────────────────────────────────
	local sg = Instance.new("ScreenGui")
	sg.Name            = "NexusUI_" .. wTitle
	sg.ResetOnSpawn    = false
	sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder    = 999
	sg.IgnoreGuiInset  = true
	local coreOk = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not coreOk then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	_InitNotifHolder(sg)

	-- ──────────────────────────────────────────────────────────
	--  Main Window Frame
	-- ──────────────────────────────────────────────────────────
	local win = MkFrame(sg, wSize, wPos, T.BG, false, 2)
	Corner(win, 16)

	-- Accent UIStroke border
	local winStroke = Stroke(win, Color3.fromRGB(80, 50, 158), 1.5)

	-- Top-edge glow line
	local topGlow = MkFrame(win, UDim2.new(1, -6, 0, 1), UDim2.new(0, 3, 0, 0),
		Color3.fromRGB(148, 96, 255))
	topGlow.BackgroundTransparency = 0.50
	topGlow.ZIndex = 10

	-- Spawn animation: window starts small + transparent
	win.BackgroundTransparency = 1
	win.Size     = UDim2.new(0, wSize.X.Offset, 0, wSize.Y.Offset * 0.88)
	win.Position = UDim2.new(wPos.X.Scale, wPos.X.Offset, wPos.Y.Scale, wPos.Y.Offset + 22)
	task.defer(function()
		FT(win,       { BackgroundTransparency = 0, Size = wSize, Position = wPos }, 0.32)
		FT(winStroke, { Color = Color3.fromRGB(100, 62, 195) }, 0.40)
	end)

	-- ──────────────────────────────────────────────────────────
	--  Title Bar
	-- ──────────────────────────────────────────────────────────
	local titleBar = MkFrame(win, UDim2.new(1, 0, 0, 62), nil, T.Surface)
	Corner(titleBar, 16)
	-- Fill the shared bottom edge of titleBar so it looks flat where body starts
	MkFrame(titleBar, UDim2.new(1, 0, 0, 16), UDim2.new(0, 0, 1, -16), T.Surface)

	-- Deep-to-surface gradient
	local tbGrad = Instance.new("UIGradient")
	tbGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,    Color3.fromRGB(52, 34, 96)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(34, 24, 66)),
		ColorSequenceKeypoint.new(1,    T.Surface),
	})
	tbGrad.Rotation = 90; tbGrad.Parent = titleBar

	-- Bottom separator with fade-out gradient
	local tbSep = MkFrame(titleBar, UDim2.new(1, -28, 0, 1),
		UDim2.new(0, 14, 1, -1), Color3.fromRGB(80, 56, 120))
	tbSep.BackgroundTransparency = 0.55; tbSep.ZIndex = 5
	local sepGrad = Instance.new("UIGradient")
	sepGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   1),
		NumberSequenceKeypoint.new(0.1, 0.55),
		NumberSequenceKeypoint.new(0.9, 0.55),
		NumberSequenceKeypoint.new(1,   1),
	})
	sepGrad.Parent = tbSep

	MakeDraggable(win, titleBar)

	-- Icon pill (MkIcon — supports both text + asset image)
	local iconPill = MkFrame(titleBar, UDim2.new(0, 42, 0, 42), UDim2.new(0, 12, 0.5, -21), T.AccentLo)
	Corner(iconPill, 13); Stroke(iconPill, T.AccentHi, 1.5, 0.2)
	-- Pill inner shine
	local pillShine = MkFrame(iconPill, UDim2.new(1, -4, 0, 14), UDim2.new(0, 2, 0, 2), T.White)
	pillShine.BackgroundTransparency = 0.84; Corner(pillShine, 8)
	local pillShineG = Instance.new("UIGradient")
	pillShineG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.84),
		NumberSequenceKeypoint.new(0.5, 0.76),
		NumberSequenceKeypoint.new(1,   0.84),
	})
	pillShineG.Parent = pillShine
	-- Soft glow halo behind the pill
	local pillGlow = MkFrame(titleBar, UDim2.new(0, 52, 0, 52), UDim2.new(0, 7, 0.5, -26), T.Accent)
	pillGlow.BackgroundTransparency = 0.82; Corner(pillGlow, 16); pillGlow.ZIndex = 2
	-- This call creates either an ImageLabel or TextLabel depending on wIcon
	MkIcon(iconPill, wIcon, 20, T.White, UDim2.new(0.72, 0, 0.72, 0), 4)

	-- Window title text
	local titleLbl = MkLabel(titleBar, wTitle, 15, T.TxtMain, Enum.Font.GothamBold)
	titleLbl.Size     = UDim2.new(1, -158, 0, 22)
	titleLbl.Position = UDim2.new(0, 64, 0, 10)

	-- Version badge chip
	local verChip = MkFrame(titleBar, UDim2.new(0, 0, 0, 18), UDim2.new(0, 64, 0, 34), T.AccentDeep)
	verChip.AutomaticSize = Enum.AutomaticSize.X
	Corner(verChip, 6); Stroke(verChip, T.Accent, 1, 0.45)
	local verLbl = MkLabel(verChip, wSub, 10, T.AccentHi, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	verLbl.Size = UDim2.new(1, 0, 1, 0); Pad(verChip, 0, 0, 8, 8)

	-- Control buttons factory
	local function MkCtrlBtn(xOffset, bgColor)
		local box = MkFrame(titleBar, UDim2.new(0, 28, 0, 28),
			UDim2.new(1, xOffset, 0.5, -14), bgColor)
		Corner(box, 9)
		local bb = MkButton(box, "", 0, T.Black, T.White)
		bb.BackgroundTransparency = 1; bb.Size = UDim2.new(1, 0, 1, 0)
		-- Hover: brighten + slight grow
		bb.MouseEnter:Connect(function()
			ST(box, { Size = UDim2.new(0, 30, 0, 30) }, 0.14)
		end)
		bb.MouseLeave:Connect(function()
			FT(box, { Size = UDim2.new(0, 28, 0, 28) }, 0.12)
		end)
		return box, bb
	end

	-- Close
	local closeBox, closeBB = MkCtrlBtn(-38, T.Red)
	MkLabel(closeBox, "x", 12, T.White, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	closeBB.MouseEnter:Connect(function() FT(closeBox, { BackgroundColor3 = Color3.fromRGB(255, 44, 72) }, 0.12) end)
	closeBB.MouseLeave:Connect(function() FT(closeBox, { BackgroundColor3 = T.Red }, 0.12) end)
	closeBB.MouseButton1Click:Connect(function()
		FT(win, { Size = UDim2.new(0, wSize.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.22)
		task.wait(0.24)
		if _ConfigReg[wName] then _ConfigReg[wName] = nil end
		sg:Destroy()
	end)

	-- Minimize
	local minBox, minBB = MkCtrlBtn(-70, T.SurfaceHi)
	Stroke(minBox, T.Border, 1)
	local minLbl = MkLabel(minBox, "-", 15, T.TxtSub, Enum.Font.GothamBold,
		Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
	minBB.MouseEnter:Connect(function() FT(minBox, { BackgroundColor3 = T.SurfaceHi2 }, 0.12) end)
	minBB.MouseLeave:Connect(function() FT(minBox, { BackgroundColor3 = T.SurfaceHi }, 0.12) end)

	-- ──────────────────────────────────────────────────────────
	--  Body
	-- ──────────────────────────────────────────────────────────
	local body = MkFrame(win, UDim2.new(1, 0, 1, -62), UDim2.new(0, 0, 0, 62), T.BG, true, 2)
	Corner(body, 16)
	-- Fill top-edge so body doesn't show rounded corners under titlebar
	MkFrame(body, UDim2.new(1, 0, 0, 16), nil, T.BG)

	-- Subtle side-vignette
	local vignette = MkFrame(body, UDim2.new(1, 0, 1, 0), nil, T.Black)
	vignette.BackgroundTransparency = 0.92; vignette.ZIndex = 1
	local vigG = Instance.new("UIGradient")
	vigG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,    0.75),
		NumberSequenceKeypoint.new(0.15, 1),
		NumberSequenceKeypoint.new(0.85, 1),
		NumberSequenceKeypoint.new(1,    0.75),
	})
	vigG.Parent = vignette

	-- Bottom accent strip
	local btmBar = MkFrame(win, UDim2.new(1, -6, 0, 4), UDim2.new(0, 3, 1, -4),
		Color3.fromRGB(78, 52, 142))
	btmBar.BackgroundTransparency = 0.58; btmBar.ZIndex = 3; Corner(btmBar, 4)
	local btmGrad = Instance.new("UIGradient")
	btmGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   T.AccentDeep),
		ColorSequenceKeypoint.new(0.5, T.Accent),
		ColorSequenceKeypoint.new(1,   T.AccentDeep),
	})
	btmGrad.Parent = btmBar

	-- Minimize logic
	local minimized = false
	minBB.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			FT(win, { Size = UDim2.new(0, wSize.X.Offset, 0, 62) }, 0.28)
			minLbl.Text = "+"
		else
			FT(win, { Size = wSize }, 0.28)
			minLbl.Text = "-"
		end
	end)

	-- ──────────────────────────────────────────────────────────
	--  Tab Bar with sliding indicator
	-- ──────────────────────────────────────────────────────────
	local tabBar = MkFrame(body, UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 14),
		T.SurfaceHi, false, 3)
	Corner(tabBar, 11); Stroke(tabBar, T.Border, 1)

	-- Sliding active-tab indicator pill
	local tabInd = MkFrame(tabBar, UDim2.new(0, 40, 0, 28), UDim2.new(0, 4, 0.5, -14), T.Accent)
	tabInd.ZIndex = 3; Corner(tabInd, 8)
	local tabIndG = Instance.new("UIGradient")
	tabIndG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, T.AccentHi),
		ColorSequenceKeypoint.new(1, T.AccentLo),
	})
	tabIndG.Rotation = 90; tabIndG.Parent = tabInd

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection     = Enum.FillDirection.Horizontal
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.SortOrder         = Enum.SortOrder.LayoutOrder
	tabLayout.Padding           = UDim.new(0, 4)
	tabLayout.Parent            = tabBar
	Pad(tabBar, 3, 3, 4, 4)

	-- Content + dropdown overlay
	local contentArea  = MkFrame(body, UDim2.new(1, 0, 1, -68), UDim2.new(0, 0, 0, 68), T.BG, false, 3)
	local dropOverlay  = MkFrame(body, UDim2.new(1, 0, 1, -68), UDim2.new(0, 0, 0, 68), T.Black, false, 50)
	dropOverlay.BackgroundTransparency = 1

	local tabs      = {}
	local activeTab = nil

	-- ══════════════════════════════════════════════════════════
	--  WINDOW API TABLE
	-- ══════════════════════════════════════════════════════════
	local WinAPI = {}

	function WinAPI:Notify(o) return NexusUI:Notify(o) end

	function WinAPI:Destroy()
		FT(win, { Size = UDim2.new(0, wSize.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.22)
		task.wait(0.24)
		if _ConfigReg[wName] then _ConfigReg[wName] = nil end
		sg:Destroy()
	end

	local winHidden = false
	function WinAPI:Toggle()
		winHidden = not winHidden
		if winHidden then
			FT(win, { Size = UDim2.new(0, wSize.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.20)
		else
			FT(win, { Size = wSize, BackgroundTransparency = 0 }, 0.25)
		end
	end

	-- Config: Save
	function WinAPI:SaveConfig(configName)
		configName = configName or "default"
		local reg = _ConfigReg[wName]
		if not reg then
			warn("[NexusUI] SaveConfig: no registered IDs in '" .. wName .. "'"); return
		end
		local data = {}
		for id, entry in reg do
			local v = entry.Get()
			data[id] = entry.Type == "color" and _EncodeColor(v) or v
		end
		local json = HttpService:JSONEncode(data)
		local path = "NexusUI_" .. wName .. "_" .. configName .. ".json"
		local ok, _ = pcall(function() writefile(path, json) end)
		if ok then
			NexusUI:Notify({ Title="Config Saved", Desc=path, Duration=3, Icon="OK", Color=T.Green })
		else
			print("[NexusUI] Config '" .. configName .. "':\n" .. json)
			NexusUI:Notify({ Title="Saved (print fallback)", Desc="Check Output", Duration=3, Icon="!", Color=T.Yellow })
		end
	end

	-- Config: Load
	function WinAPI:LoadConfig(configName)
		configName = configName or "default"
		local reg = _ConfigReg[wName]
		if not reg then
			warn("[NexusUI] LoadConfig: no registered IDs in '" .. wName .. "'"); return
		end
		local path = "NexusUI_" .. wName .. "_" .. configName .. ".json"
		local ok, json = pcall(function() return readfile(path) end)
		if not ok or not json then
			NexusUI:Notify({ Title="Config Not Found", Desc=path, Duration=3, Icon="!", Color=T.Red }); return
		end
		local data = HttpService:JSONDecode(json)
		for id, val in data do
			local entry = reg[id]
			if entry then
				pcall(function()
					entry.Set(entry.Type == "color" and _DecodeColor(val) or val)
				end)
			end
			-- Missing IDs are silently skipped
		end
		NexusUI:Notify({ Title="Config Loaded", Desc=path, Duration=3, Icon="OK", Color=T.Green })
	end

	-- ID query helpers
	function WinAPI:GetValue(id)
		local reg = _ConfigReg[wName]
		if not reg or not reg[id] then
			warn("[NexusUI] GetValue: unknown Id '" .. tostring(id) .. "'"); return nil
		end
		return reg[id].Get()
	end

	function WinAPI:SetValue(id, val)
		local reg = _ConfigReg[wName]
		if not reg or not reg[id] then
			warn("[NexusUI] SetValue: unknown Id '" .. tostring(id) .. "'"); return
		end
		local entry = reg[id]
		pcall(function()
			entry.Set(entry.Type == "color" and (type(val) == "table" and _DecodeColor(val) or val) or val)
		end)
	end

	function WinAPI:GetElement(id)
		local reg = _ConfigReg[wName]
		if not reg or not reg[id] then
			warn("[NexusUI] GetElement: unknown Id '" .. tostring(id) .. "'"); return nil
		end
		return reg[id].API
	end

	function WinAPI:ListIds()
		local reg = _ConfigReg[wName] or {}
		local out = {}
		for id, entry in reg do out[id] = entry.Type end
		return out
	end

	-- ══════════════════════════════════════════════════════════
	--  ADD TAB
	-- ══════════════════════════════════════════════════════════
	function WinAPI:AddTab(tabName, tabIcon)
		-- tabIcon is optional; supports same format as MkIcon
		local tabBtn = Instance.new("TextButton")
		tabBtn.Text               = tabName
		tabBtn.TextSize           = 12
		tabBtn.Font               = Enum.Font.GothamSemibold
		tabBtn.TextColor3         = T.TxtMute
		tabBtn.BackgroundColor3   = T.Black
		tabBtn.BackgroundTransparency = 1
		tabBtn.BorderSizePixel    = 0
		tabBtn.AutoButtonColor    = false
		tabBtn.AutomaticSize      = Enum.AutomaticSize.X
		tabBtn.Size               = UDim2.new(0, 10, 1, 0)
		tabBtn.ZIndex             = 5
		tabBtn.Parent             = tabBar
		Pad(tabBtn, 0, 0, 10, 10); Corner(tabBtn, 8)

		-- Scrollable page
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel        = 0
		page.Size                   = UDim2.new(1, 0, 1, 0)
		page.CanvasSize             = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		page.ScrollBarThickness     = 3
		page.ScrollBarImageColor3   = T.Accent
		page.ScrollBarImageTransparency = 0.5
		page.ScrollingDirection     = Enum.ScrollingDirection.Y
		page.Visible                = false
		page.ZIndex                 = 3
		page.Parent                 = contentArea

		local listLayout = Instance.new("UIListLayout")
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder     = Enum.SortOrder.LayoutOrder
		listLayout.Padding       = UDim.new(0, 7)
		listLayout.Parent        = page
		Pad(page, 10, 18, 10, 10)

		local tabData = { Btn = tabBtn, Page = page }
		table.insert(tabs, tabData)

		local function Activate()
			if activeTab then
				FT(activeTab.Btn, { TextColor3 = T.TxtMute }, 0.16)
				activeTab.Page.Visible = false
			end
			activeTab = tabData
			FT(tabBtn, { TextColor3 = T.White }, 0.16)
			page.Visible = true
			-- Slide indicator to this tab
			task.defer(function()
				if not tabBtn.Parent then return end
				local relX = tabBtn.AbsolutePosition.X - tabBar.AbsolutePosition.X - 4
				FT(tabInd, {
					Size     = UDim2.new(0, tabBtn.AbsoluteSize.X, 0, 28),
					Position = UDim2.new(0, relX, 0.5, -14),
				}, 0.22)
			end)
		end

		tabBtn.MouseButton1Click:Connect(Activate)
		if #tabs == 1 then task.defer(Activate) end

		-- ─────────────────────────────────────────────────────
		--  ELEMENT API
		-- ─────────────────────────────────────────────────────
		local API = {}

		-- Tab helpers
		function API:Select()    Activate() end
		function API:SetVisible(v)
			tabBtn.Visible = v
			if not v and activeTab == tabData then
				for _, td in tabs do
					if td.Btn.Visible then
						FT(td.Btn, { TextColor3 = T.White }, 0.16); activeTab = td; td.Page.Visible = true
						task.defer(function()
							local rx = td.Btn.AbsolutePosition.X - tabBar.AbsolutePosition.X - 4
							FT(tabInd, { Size = UDim2.new(0, td.Btn.AbsoluteSize.X, 0, 28),
								Position = UDim2.new(0, rx, 0.5, -14) }, 0.22)
						end); break
					end
				end
			end
		end

		-- Base card builder — glass shine on every card
		local function Card(height, semiTrans)
			local c = MkFrame(page, UDim2.new(1, 0, 0, height), nil, T.Surface)
			c.ZIndex = 4
			if semiTrans then c.BackgroundTransparency = 0.22 end
			Corner(c, 12); Stroke(c, T.Border, 1); Pad(c, 0, 0, 14, 14); CardShine(c)
			return c
		end

		-- Wrap helper: add :SetVisible() and :Destroy() to any element API
		local function WrapEl(container, elAPI)
			elAPI = elAPI or {}
			function elAPI:SetVisible(v) container.Visible = v end
			function elAPI:Destroy()     container:Destroy() end
			return elAPI
		end

		-- ══════════════════════════════════════════════════════
		--  SECTION
		-- ══════════════════════════════════════════════════════
		function API:AddSection(name, sectionIcon)
			-- sectionIcon is optional, supports text or asset
			local wrap = MkFrame(page, UDim2.new(1, 0, 0, 26), nil, T.Black)
			wrap.BackgroundTransparency = 1; wrap.ZIndex = 4

			-- Fade lines
			local function FadeLine(xScale, xOff, lineWidth)
				local l = MkFrame(wrap, UDim2.new(lineWidth, -4, 0, 1),
					UDim2.new(xScale, xOff, 0.5, 0), T.BorderBri)
				l.ZIndex = 4
				local g = Instance.new("UIGradient")
				g.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0,   xScale == 0 and 1 or 0.4),
					NumberSequenceKeypoint.new(0.5, 0.4),
					NumberSequenceKeypoint.new(1,   xScale == 0 and 0.4 or 1),
				})
				g.Parent = l
			end
			FadeLine(0,    0, 0.28)
			FadeLine(0.72, 0, 0.28)

			-- Optional icon before the text
			local xStart = 0.28
			if sectionIcon then
				local icHolder = MkFrame(wrap, UDim2.new(0, 16, 0, 16),
					UDim2.new(0.28, 0, 0.5, -8), T.Black)
				icHolder.BackgroundTransparency = 1; icHolder.ZIndex = 4
				MkIcon(icHolder, sectionIcon, 12, T.TxtMute,
					UDim2.new(1, 0, 1, 0), 5)
				xStart = 0.28 + 0.06
			end

			-- Letter-spaced name
			local spaced = ""
			for i = 1, #name do
				spaced = spaced .. name:sub(i, i)
				if i < #name then spaced = spaced .. " " end
			end
			local sl = MkLabel(wrap, spaced:upper(), 9, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			sl.Size     = UDim2.new(0.44, 0, 1, 0)
			sl.Position = UDim2.new(xStart, 0, 0, 0)
			sl.ZIndex   = 4
		end

		-- ══════════════════════════════════════════════════════
		--  SEPARATOR
		-- ══════════════════════════════════════════════════════
		function API:AddSeparator()
			local s = MkFrame(page, UDim2.new(1, -24, 0, 1), UDim2.new(0, 12, 0, 0), T.Border)
			s.ZIndex = 4
			local g = Instance.new("UIGradient")
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0,   1),
				NumberSequenceKeypoint.new(0.1, 0),
				NumberSequenceKeypoint.new(0.9, 0),
				NumberSequenceKeypoint.new(1,   1),
			})
			g.Parent = s
		end

		-- ══════════════════════════════════════════════════════
		--  LABEL  (transparent background, simple text display)
		-- ══════════════════════════════════════════════════════
		function API:AddLabel(opt)
			opt = type(opt) == "string" and { Text = opt } or (opt or {})
			local text  = opt.Text     or "Label"
			local color = opt.Color    or T.TxtSub
			local align = opt.Align    or "Left"
			local size  = opt.TextSize or 13
			local font  = opt.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
			local xa    = align == "Center" and Enum.TextXAlignment.Center
				or align == "Right" and Enum.TextXAlignment.Right
				or Enum.TextXAlignment.Left

			local wrap = MkFrame(page, UDim2.new(1, 0, 0, 26), nil, T.Black)
			wrap.BackgroundTransparency = 1; wrap.ZIndex = 4

			local lbl = MkLabel(wrap, text, size, color, font, xa, Enum.TextYAlignment.Center, true)
			lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.ZIndex = 5

			local L = WrapEl(wrap)
			function L:SetText(t)  lbl.Text      = t end
			function L:SetColor(c) lbl.TextColor3 = c end
			function L:SetSize(n)  lbl.TextSize   = n end
			return L
		end

		-- ══════════════════════════════════════════════════════
		--  PARAGRAPH
		-- ══════════════════════════════════════════════════════
		function API:AddParagraph(opt)
			opt = opt or {}
			local title   = opt.Title   or "Paragraph"
			local content = opt.Content or ""
			local color   = opt.Color   or T.TxtSub

			local rawLines = math.max(1, math.ceil(#content / 40))
			local cardH    = math.max(14 + 22 + 8 + rawLines * 18 + 14, 60)

			local card = MkFrame(page, UDim2.new(1, 0, 0, cardH), nil, T.Surface)
			card.BackgroundTransparency = 0.22; card.ZIndex = 4
			Corner(card, 12); Stroke(card, T.Border, 1, 0.2); Pad(card, 10, 10, 14, 14); CardShine(card)

			-- Left accent strip with gradient
			local strip = MkFrame(card, UDim2.new(0, 3, 1, -20), UDim2.new(0, 0, 0, 10), T.Accent)
			strip.ZIndex = 5; Corner(strip, 3)
			local stripG = Instance.new("UIGradient")
			stripG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, T.AccentLo),
			})
			stripG.Rotation = 90; stripG.Parent = strip

			local titleLbl = MkLabel(card, title, 13, T.TxtMain, Enum.Font.GothamBold)
			titleLbl.Size = UDim2.new(1, -10, 0, 22); titleLbl.ZIndex = 5

			local contentLbl = Instance.new("TextLabel")
			contentLbl.Text               = content
			contentLbl.TextSize           = 12
			contentLbl.Font               = Enum.Font.Gotham
			contentLbl.TextColor3         = color
			contentLbl.BackgroundTransparency = 1
			contentLbl.BorderSizePixel    = 0
			contentLbl.Size               = UDim2.new(1, -10, 0, cardH - 46)
			contentLbl.Position           = UDim2.new(0, 0, 0, 28)
			contentLbl.TextXAlignment     = Enum.TextXAlignment.Left
			contentLbl.TextYAlignment     = Enum.TextYAlignment.Top
			contentLbl.TextWrapped        = true
			contentLbl.ZIndex             = 5
			contentLbl.Parent             = card

			local P = WrapEl(card)
			function P:SetTitle(t)   titleLbl.Text      = t end
			function P:SetContent(c) contentLbl.Text    = c end
			function P:SetColor(c)   contentLbl.TextColor3 = c end
			return P
		end

		-- ══════════════════════════════════════════════════════
		--  BUTTON
		--  Icon supports: "L" (text) or "rbxassetid://123" (image)
		-- ══════════════════════════════════════════════════════
		function API:AddButton(opt)
			opt = opt or {}
			local name    = opt.Name     or "Button"
			local desc    = opt.Desc     or ""
			local icon    = opt.Icon     or ""   -- text or asset ID
			local cb      = opt.Callback or function() end
			local color   = opt.Color    or T.Accent
			local enabled = true

			local cardH = desc ~= "" and 60 or 48
			local card  = Card(cardH)

			-- Optional icon box (left side)
			local iconOffset = 0
			if icon ~= "" then
				iconOffset = 40
				local icBox = MkFrame(card, UDim2.new(0, 30, 0, 30), UDim2.new(0, 0, 0.5, -15), T.AccentDeep)
				icBox.ZIndex = 5; Corner(icBox, 9); Stroke(icBox, color, 1, 0.3)
				-- MkIcon auto-detects text vs. image asset
				MkIcon(icBox, icon, 15, color, UDim2.new(0.70, 0, 0.70, 0), 6)
			end

			-- Name label
			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size     = UDim2.new(1, -(iconOffset + 92), 0, desc ~= "" and 20 or 32)
			nameLbl.Position = UDim2.new(0, iconOffset, 0, desc ~= "" and 5 or 0)
			nameLbl.TextYAlignment = Enum.TextYAlignment.Center; nameLbl.ZIndex = 5

			local descLbl
			if desc ~= "" then
				descLbl = MkLabel(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				descLbl.Size     = UDim2.new(1, -(iconOffset + 92), 0, 16)
				descLbl.Position = UDim2.new(0, iconOffset, 0, 28)
				descLbl.ZIndex   = 5
			end

			-- Action pill (right side, gradient)
			local pillW  = 78
			local aPill  = MkFrame(card, UDim2.new(0, pillW, 0, 32), UDim2.new(1, -pillW, 0.5, -16), color)
			aPill.ZIndex = 5; Corner(aPill, 10)
			local aGrad  = Instance.new("UIGradient")
			aGrad.Color  = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, color),
			})
			aGrad.Rotation = 95; aGrad.Parent = aPill
			-- Pill shine
			local pSh = MkFrame(aPill, UDim2.new(1, -6, 0, 10), UDim2.new(0, 3, 0, 2), T.White)
			pSh.BackgroundTransparency = 0.82; pSh.ZIndex = 6; Corner(pSh, 4)

			local actionLbl = MkLabel(aPill, "Run", 12, T.White, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			actionLbl.ZIndex = 7

			local aBB = MkButton(aPill, "", 0, T.Black, T.White)
			aBB.BackgroundTransparency = 1; aBB.Size = UDim2.new(1, 0, 1, 0); aBB.ZIndex = 8

			local running = false
			local function DoRun()
				if running or not enabled then return end; running = true
				-- Press ripple
				FT(aPill, { Size = UDim2.new(0, pillW - 6, 0, 26) }, 0.08)
				task.wait(0.09)
				ST(aPill, { Size = UDim2.new(0, pillW, 0, 32) }, 0.20)
				actionLbl.Text = "Done"; FT(actionLbl, { TextColor3 = T.Green }, 0.1)
				task.delay(0.85, function()
					if actionLbl and actionLbl.Parent then
						actionLbl.Text = "Run"; FT(actionLbl, { TextColor3 = T.White }, 0.15)
					end
				end)
				SafeCall(cb); running = false
			end

			aBB.MouseEnter:Connect(function() aGrad.Enabled = false; FT(aPill, { BackgroundColor3 = T.AccentHi }, 0.12) end)
			aBB.MouseLeave:Connect(function() aGrad.Enabled = true;  FT(aPill, { BackgroundColor3 = color    }, 0.12) end)
			aBB.MouseButton1Click:Connect(DoRun)

			local cBB = MkButton(card, "", 0, T.Black, T.White)
			cBB.BackgroundTransparency = 1; cBB.Size = UDim2.new(1, -(pillW + 8), 1, 0); cBB.ZIndex = 5
			cBB.MouseEnter:Connect(function() if enabled then FT(card, { BackgroundColor3 = T.SurfaceHi }, 0.14) end end)
			cBB.MouseLeave:Connect(function() FT(card, { BackgroundColor3 = T.Surface }, 0.14) end)
			cBB.MouseButton1Click:Connect(DoRun)

			local B = WrapEl(card)
			function B:SetName(s)    nameLbl.Text = s end
			function B:SetDesc(s)    if descLbl then descLbl.Text = s end end
			function B:SetEnabled(v)
				enabled = v
				FT(card,    { BackgroundTransparency = v and 0 or 0.45 }, 0.18)
				FT(nameLbl, { TextColor3 = v and T.TxtMain or T.TxtOff }, 0.18)
				FT(aPill,   { BackgroundTransparency = v and 0 or 0.60 }, 0.18)
			end
			return B
		end

		-- ══════════════════════════════════════════════════════
		--  TOGGLE  (iOS-style)
		-- ══════════════════════════════════════════════════════
		function API:AddToggle(opt)
			opt = opt or {}
			local name    = opt.Name     or "Toggle"
			local desc    = opt.Desc     or ""
			local default = opt.Default  or false
			local cb      = opt.Callback or function() end
			local color   = opt.Color    or T.Accent
			local id      = opt.Id       or ""
			local enabled = true

			local cardH = desc ~= "" and 58 or 46
			local card  = Card(cardH)

			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size     = UDim2.new(1, -70, 0, 22)
			nameLbl.Position = UDim2.new(0, 0, 0, desc ~= "" and 4 or 0)
			nameLbl.TextYAlignment = Enum.TextYAlignment.Center; nameLbl.ZIndex = 5

			if desc ~= "" then
				local descLbl = MkLabel(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				descLbl.Size     = UDim2.new(1, -70, 0, 16)
				descLbl.Position = UDim2.new(0, 0, 0, 28); descLbl.ZIndex = 5
			end

			-- Track
			local track = MkFrame(card, UDim2.new(0, 52, 0, 28), UDim2.new(1, -52, 0.5, -14), T.TogOff)
			track.ZIndex = 5; Corner(track, 14); Stroke(track, T.Border, 1)
			local tInner = MkFrame(track, UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0), T.Black)
			tInner.BackgroundTransparency = 0.88; tInner.ZIndex = 5

			-- Thumb + shine
			local thumb = MkFrame(track, UDim2.new(0, 22, 0, 22), UDim2.new(0, 3, 0.5, -11), T.White)
			thumb.ZIndex = 6; Corner(thumb, 11)
			local tStroke = Stroke(thumb, T.Border, 1.5)
			local tShine  = MkFrame(thumb, UDim2.new(1, -4, 0, 8), UDim2.new(0, 2, 0, 2), T.White)
			tShine.BackgroundTransparency = 0.82; tShine.ZIndex = 7; Corner(tShine, 4)

			local state = default; local busy = false

			local function Refresh(animate)
				if state then
					if animate then
						FT(track,   { BackgroundColor3 = color }, 0.20)
						ST(thumb,   { Position = UDim2.new(0, 27, 0.5, -11) }, 0.24)
						FT(tStroke, { Color = color, Thickness = 2 }, 0.20)
						FT(thumb,   { Size = UDim2.new(0, 18, 0, 22) }, 0.06)
						task.delay(0.07, function()
							if thumb and thumb.Parent then
								ET(thumb, { Size = UDim2.new(0, 22, 0, 22) }, 0.28)
							end
						end)
					else
						track.BackgroundColor3 = color
						thumb.Position = UDim2.new(0, 27, 0.5, -11)
						tStroke.Color = color; tStroke.Thickness = 2
					end
				else
					if animate then
						FT(track,   { BackgroundColor3 = T.TogOff }, 0.20)
						ST(thumb,   { Position = UDim2.new(0, 3, 0.5, -11) }, 0.24)
						FT(tStroke, { Color = T.Border, Thickness = 1.5 }, 0.20)
						FT(thumb,   { Size = UDim2.new(0, 18, 0, 22) }, 0.06)
						task.delay(0.07, function()
							if thumb and thumb.Parent then
								ET(thumb, { Size = UDim2.new(0, 22, 0, 22) }, 0.28)
							end
						end)
					else
						track.BackgroundColor3 = T.TogOff
						thumb.Position = UDim2.new(0, 3, 0.5, -11)
						tStroke.Color = T.Border; tStroke.Thickness = 1.5
					end
				end
			end
			Refresh(false)

			local function Toggle()
				if busy or not enabled then return end
				busy  = true; state = not state; Refresh(true)
				SafeCall(cb, state); task.wait(0.32); busy = false
			end
			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then Toggle() end
			end)

			local Tog = WrapEl(card)
			function Tog:Set(v)       state = v; Refresh(true) end
			function Tog:Get()        return state end
			function Tog:Fire()       SafeCall(cb, state) end
			function Tog:SetEnabled(v)
				enabled = v
				FT(card,  { BackgroundTransparency = v and 0 or 0.45 }, 0.18)
				FT(track, { BackgroundTransparency = v and 0 or 0.50 }, 0.18)
			end
			_RegElement(wName, id, function() return state end,
				function(v) state = v; Refresh(true) end, "bool", Tog)
			return Tog
		end

		-- ══════════════════════════════════════════════════════
		--  SLIDER
		-- ══════════════════════════════════════════════════════
		function API:AddSlider(opt)
			opt = opt or {}
			local name   = opt.Name     or "Slider"
			local desc   = opt.Desc     or ""
			local minVal = opt.Min      or 0
			local maxVal = opt.Max      or 100
			local defVal = opt.Default  or minVal
			local suffix = opt.Suffix   or ""
			local cb     = opt.Callback or function() end
			local color  = opt.Color    or T.Accent
			local id     = opt.Id       or ""

			local cardH = desc ~= "" and 76 or 64
			local card  = Card(cardH)

			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(0.62, 0, 0, 20); nameLbl.ZIndex = 5

			local valLbl = MkLabel(card, tostring(defVal) .. suffix, 13, color,
				Enum.Font.GothamBold, Enum.TextXAlignment.Right)
			valLbl.Size = UDim2.new(0.38, 0, 0, 20); valLbl.ZIndex = 5

			if desc ~= "" then
				local descLbl = MkLabel(card, desc, 11, T.TxtMute, Enum.Font.Gotham)
				descLbl.Size     = UDim2.new(1, 0, 0, 14)
				descLbl.Position = UDim2.new(0, 0, 0, 22); descLbl.ZIndex = 5
			end

			local yOff = desc ~= "" and 44 or 30

			-- Track
			local tBG = MkFrame(card, UDim2.new(1, 0, 0, 10), UDim2.new(0, 0, 0, yOff), T.SurfaceHi)
			tBG.ZIndex = 5; Corner(tBG, 5); Stroke(tBG, T.Border, 1)
			local tBGg = Instance.new("UIGradient")
			tBGg.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.SurfaceHi2),
				ColorSequenceKeypoint.new(1, T.SurfaceHi),
			})
			tBGg.Rotation = 90; tBGg.Parent = tBG

			-- Fill + shine
			local fill = MkFrame(tBG, UDim2.new(0, 0, 1, 0), nil, color)
			fill.ZIndex = 6; Corner(fill, 5)
			local fillG = Instance.new("UIGradient")
			fillG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, color),
			})
			fillG.Parent = fill
			local fShine = MkFrame(fill, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 1), T.White)
			fShine.BackgroundTransparency = 0.86; fShine.ZIndex = 7; Corner(fShine, 4)

			-- Knob + shine + ring
			local knob = MkFrame(tBG, UDim2.new(0, 22, 0, 22), UDim2.new(0, -11, 0.5, -11), T.White)
			knob.ZIndex = 7; Corner(knob, 11)
			local kRing   = Stroke(knob, color, 2)
			local kShine  = MkFrame(knob, UDim2.new(1, -4, 0, 8), UDim2.new(0, 2, 0, 2), T.White)
			kShine.BackgroundTransparency = 0.82; kShine.ZIndex = 8; Corner(kShine, 4)
			local trackGlow = Stroke(tBG, T.AccentHi, 2, 1)

			local val = math.clamp(defVal, minVal, maxVal); local sliding = false

			local function SetVal(v)
				val = math.clamp(v, minVal, maxVal)
				local pct = (val - minVal) / (maxVal - minVal)
				FT(fill, { Size     = UDim2.new(pct,   0, 1,   0) }, 0.06)
				FT(knob, { Position = UDim2.new(pct, -11, 0.5, -11) }, 0.06)
				valLbl.Text = tostring(math.round(val)) .. suffix
			end
			SetVal(defVal)

			local function FromInputPos(pos)
				local ax = tBG.AbsolutePosition.X
				local aw = tBG.AbsoluteSize.X
				return minVal + math.clamp((pos.X - ax) / aw, 0, 1) * (maxVal - minVal)
			end

			tBG.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then
					sliding = true
					ST(knob,      { Size = UDim2.new(0, 26, 0, 26) }, 0.12)
					FT(kRing,     { Thickness = 3 }, 0.12)
					FT(trackGlow, { Transparency = 0.5 }, 0.20)
					SetVal(FromInputPos(i.Position)); SafeCall(cb, math.round(val))
				end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
				or  i.UserInputType == Enum.UserInputType.Touch) then
					SetVal(FromInputPos(i.Position)); SafeCall(cb, math.round(val))
				end
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then
					sliding = false
					FT(knob,      { Size = UDim2.new(0, 22, 0, 22) }, 0.14)
					FT(kRing,     { Thickness = 2 }, 0.14)
					FT(trackGlow, { Transparency = 1 }, 0.22)
				end
			end)

			local Sl = WrapEl(card)
			function Sl:Set(v)       SetVal(v) end
			function Sl:Get()        return math.round(val) end
			function Sl:SetMin(n)    minVal = n; SetVal(val) end
			function Sl:SetMax(n)    maxVal = n; SetVal(val) end
			function Sl:SetSuffix(s) suffix = s; valLbl.Text = tostring(math.round(val)) .. s end
			_RegElement(wName, id,
				function() return math.round(val) end,
				function(v) SetVal(tonumber(v) or minVal) end,
				"number", Sl)
			return Sl
		end

		-- ══════════════════════════════════════════════════════
		--  DROPDOWN  (single-select, nil-default support)
		-- ══════════════════════════════════════════════════════
		function API:AddDropdown(opt)
			opt = opt or {}
			local name        = opt.Name        or "Dropdown"
			local items       = opt.Items       or { "Option 1", "Option 2" }
			local cb          = opt.Callback    or function() end
			local color       = opt.Color       or T.Accent
			local id          = opt.Id          or ""
			local placeholder = opt.Placeholder or "Select..."
			-- nil / false / "" all mean "no selection at start"
			local hasDefault  = opt.Default ~= nil and opt.Default ~= false and opt.Default ~= ""
			local selVal      = hasDefault and opt.Default or nil
			local isOpen      = false

			local card = Card(46)
			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(0.36, 0, 1, 0); nameLbl.ZIndex = 5

			-- Pill
			local pill = MkFrame(card, UDim2.new(0.62, 0, 0, 32), UDim2.new(0.38, 0, 0.5, -16), T.SurfaceHi)
			pill.ZIndex = 5; Corner(pill, 10); Stroke(pill, T.Border, 1); CardShine(pill)

			local pillLbl = MkLabel(pill, selVal or placeholder, 12,
				selVal and T.TxtMain or T.TxtMute, Enum.Font.GothamSemibold)
			pillLbl.Size = UDim2.new(1, -28, 1, 0); pillLbl.Position = UDim2.new(0, 10, 0, 0)
			pillLbl.ZIndex = 6; pillLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local chevLbl = MkLabel(pill, "v", 13, T.TxtSub, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			chevLbl.Size = UDim2.new(0, 22, 1, 0); chevLbl.Position = UDim2.new(1, -24, 0, 0); chevLbl.ZIndex = 6

			local function RefreshPill()
				if selVal then
					pillLbl.Text = selVal; FT(pillLbl, { TextColor3 = T.TxtMain }, 0.15)
				else
					pillLbl.Text = placeholder; FT(pillLbl, { TextColor3 = T.TxtMute }, 0.15)
				end
			end

			-- Floating list frame (parented to overlay so it's never clipped)
			local listFrame = MkFrame(dropOverlay, UDim2.new(1, -20, 0, 0), UDim2.new(0, 10, 0, 0), T.Surface)
			listFrame.ZIndex = 50; listFrame.Visible = false; listFrame.ClipsDescendants = true
			Corner(listFrame, 12); Stroke(listFrame, T.BorderGlow, 1, 0.3); CardShine(listFrame)

			local listInner = MkFrame(listFrame, UDim2.new(1, 0, 1, 0), nil, T.Black)
			listInner.BackgroundTransparency = 1; listInner.ZIndex = 51
			local listLL = Instance.new("UIListLayout")
			listLL.FillDirection = Enum.FillDirection.Vertical
			listLL.SortOrder     = Enum.SortOrder.LayoutOrder
			listLL.Padding       = UDim.new(0, 3)
			listLL.Parent        = listInner; Pad(listInner, 5, 5, 5, 5)

			-- Search bar
			local sBG = MkFrame(listInner, UDim2.new(1, 0, 0, 30), nil, T.SurfaceHi)
			sBG.ZIndex = 52; Corner(sBG, 8); Stroke(sBG, T.Border, 1)
			local sTB = Instance.new("TextBox")
			sTB.PlaceholderText  = "Search..."
			sTB.PlaceholderColor3 = T.TxtMute
			sTB.Text             = ""; sTB.TextColor3 = T.TxtMain
			sTB.BackgroundTransparency = 1; sTB.Font = Enum.Font.Gotham; sTB.TextSize = 12
			sTB.Size = UDim2.new(1, -14, 1, 0); sTB.Position = UDim2.new(0, 7, 0, 0)
			sTB.TextXAlignment = Enum.TextXAlignment.Left
			sTB.ClearTextOnFocus = false; sTB.ZIndex = 53; sTB.Parent = sBG

			-- Items scroll frame
			local itemsSF = Instance.new("ScrollingFrame")
			itemsSF.BackgroundTransparency = 1; itemsSF.BorderSizePixel = 0
			itemsSF.Size = UDim2.new(1, 0, 0, 0); itemsSF.CanvasSize = UDim2.new(0, 0, 0, 0)
			itemsSF.AutomaticCanvasSize = Enum.AutomaticSize.Y
			itemsSF.ScrollBarThickness = 2; itemsSF.ScrollBarImageColor3 = T.Accent
			itemsSF.ZIndex = 52; itemsSF.Parent = listInner
			local iLL = Instance.new("UIListLayout")
			iLL.FillDirection = Enum.FillDirection.Vertical; iLL.SortOrder = Enum.SortOrder.LayoutOrder
			iLL.Padding = UDim.new(0, 2); iLL.Parent = itemsSF

			local allRows = {}

			local function CloseList()
				if not isOpen then return end; isOpen = false
				FT(listFrame, { Size = UDim2.new(1, -20, 0, 0) }, 0.18)
				FT(chevLbl,   { Rotation = 0 }, 0.18)
				FT(pill,      { BackgroundColor3 = T.SurfaceHi }, 0.12)
				task.wait(0.20); listFrame.Visible = false; sTB.Text = ""
			end

			local function BuildItems(filter)
				filter = (filter or ""):lower()
				for _, r in allRows do r.Parent = nil end; allRows = {}
				local count = 0
				for _, item in items do
					if filter == "" or item:lower():find(filter, 1, true) then
						count += 1
						local row = MkFrame(itemsSF, UDim2.new(1, 0, 0, 32), nil, T.Black)
						row.BackgroundTransparency = 1; row.ZIndex = 53; Corner(row, 7)

						local ck = MkLabel(row, selVal == item and ">" or "", 12, color,
							Enum.Font.GothamBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
						ck.Size = UDim2.new(0, 24, 1, 0); ck.ZIndex = 54

						local iLbl = MkLabel(row, item, 12, T.TxtMain, Enum.Font.Gotham)
						iLbl.Size = UDim2.new(1, -28, 1, 0); iLbl.Position = UDim2.new(0, 26, 0, 0); iLbl.ZIndex = 54

						local hit = MkButton(row, "", 0, T.Black, T.White)
						hit.BackgroundTransparency = 1; hit.Size = UDim2.new(1, 0, 1, 0); hit.ZIndex = 55
						hit.MouseEnter:Connect(function() FT(row, { BackgroundColor3 = T.SurfaceHi2, BackgroundTransparency = 0 }, 0.10) end)
						hit.MouseLeave:Connect(function() FT(row, { BackgroundTransparency = 1 }, 0.10) end)
						hit.MouseButton1Click:Connect(function()
							selVal = item; RefreshPill(); CloseList(); BuildItems(""); SafeCall(cb, item)
						end)
						table.insert(allRows, row)
					end
				end
				itemsSF.Size = UDim2.new(1, 0, 0, math.min(count, 5) * 34 + 4)
			end
			BuildItems("")
			sTB:GetPropertyChangedSignal("Text"):Connect(function() BuildItems(sTB.Text) end)

			local pillBB = MkButton(pill, "", 0, T.Black, T.White)
			pillBB.BackgroundTransparency = 1; pillBB.Size = UDim2.new(1, 0, 1, 0); pillBB.ZIndex = 7
			pillBB.MouseButton1Click:Connect(function()
				if isOpen then CloseList(); return end
				isOpen = true; BuildItems("")
				local oAY  = dropOverlay.AbsolutePosition.Y
				local yPos = (card.AbsolutePosition.Y - oAY) + card.AbsoluteSize.Y + 4
				local listH = 44 + math.min(#items, 5) * 34 + 10
				listFrame.Position = UDim2.new(0, 10, 0, yPos)
				listFrame.Size     = UDim2.new(1, -20, 0, 0)
				listFrame.Visible  = true
				FT(listFrame, { Size = UDim2.new(1, -20, 0, listH) }, 0.22)
				FT(chevLbl,   { Rotation = 180 }, 0.18)
				FT(pill,      { BackgroundColor3 = T.SurfaceHi2 }, 0.12)
			end)

			-- Click-outside-to-close
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then
					local lx, ly = listFrame.AbsolutePosition.X, listFrame.AbsolutePosition.Y
					local lw, lh = listFrame.AbsoluteSize.X,     listFrame.AbsoluteSize.Y
					local px, py = pill.AbsolutePosition.X,      pill.AbsolutePosition.Y
					local pw, ph = pill.AbsoluteSize.X,          pill.AbsoluteSize.Y
					local mx, my = i.Position.X, i.Position.Y
					if not (mx >= lx and mx <= lx + lw and my >= ly and my <= ly + lh)
					and not (mx >= px and mx <= px + pw and my >= py and my <= py + ph) then
						CloseList()
					end
				end
			end)

			local Drop = WrapEl(card)
			function Drop:Get()          return selVal end
			function Drop:IsEmpty()      return selVal == nil end
			function Drop:IsSelected(v)  return selVal == v end
			function Drop:Set(v)
				selVal = (v == "" or v == nil) and nil or v
				RefreshPill(); BuildItems("")
			end
			function Drop:Clear()
				selVal = nil; RefreshPill(); BuildItems("")
			end
			function Drop:Refresh(newItems)
				items = newItems
				local found = false
				for _, v in newItems do if v == selVal then found = true; break end end
				if not found then selVal = nil end
				RefreshPill(); BuildItems("")
			end
			function Drop:AddItem(item)
				table.insert(items, item); BuildItems("")
			end
			function Drop:RemoveItem(item)
				for i, v in items do if v == item then table.remove(items, i); break end end
				if selVal == item then selVal = nil; RefreshPill() end
				BuildItems("")
			end
			function Drop:SetPlaceholder(s)
				placeholder = s; if not selVal then pillLbl.Text = s end
			end
			_RegElement(wName, id,
				function() return selVal end,
				function(v) selVal = (v == "" or v == nil) and nil or tostring(v); RefreshPill(); BuildItems("") end,
				"string", Drop)
			return Drop
		end

		-- ══════════════════════════════════════════════════════
		--  MULTI DROPDOWN
		-- ══════════════════════════════════════════════════════
		function API:AddMultiDropdown(opt)
			opt = opt or {}
			local name        = opt.Name        or "Multi Select"
			local items       = opt.Items       or { "Item 1", "Item 2" }
			local cb          = opt.Callback    or function() end
			local color       = opt.Color       or T.Accent
			local id          = opt.Id          or ""
			local placeholder = opt.Placeholder or "None selected"

			local card     = Card(46)
			local selected = {}
			local isOpen   = false

			if type(opt.Default) == "table" then
				for _, v in opt.Default do selected[v] = true end
			end

			local function GetSelected()
				local t = {}
				for _, item in items do if selected[item] then table.insert(t, item) end end
				return t
			end
			local function PillText()
				local t = GetSelected()
				if #t == 0 then return placeholder
				elseif #t == 1 then return t[1]
				else return t[1] .. " +" .. tostring(#t - 1)
				end
			end

			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(0.36, 0, 1, 0); nameLbl.ZIndex = 5

			local pill = MkFrame(card, UDim2.new(0.62, 0, 0, 32), UDim2.new(0.38, 0, 0.5, -16), T.SurfaceHi)
			pill.ZIndex = 5; Corner(pill, 10); Stroke(pill, T.Border, 1); CardShine(pill)

			local pillLbl = MkLabel(pill, PillText(), 12,
				#GetSelected() > 0 and T.TxtMain or T.TxtMute, Enum.Font.GothamSemibold)
			pillLbl.Size = UDim2.new(1, -46, 1, 0); pillLbl.Position = UDim2.new(0, 10, 0, 0)
			pillLbl.ZIndex = 6; pillLbl.TextTruncate = Enum.TextTruncate.AtEnd

			local chevLbl = MkLabel(pill, "v", 13, T.TxtSub, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			chevLbl.Size = UDim2.new(0, 22, 1, 0); chevLbl.Position = UDim2.new(1, -24, 0, 0); chevLbl.ZIndex = 6

			local badge = MkFrame(pill, UDim2.new(0, 18, 0, 18), UDim2.new(1, -44, 0.5, -9), T.Accent)
			badge.ZIndex = 7; Corner(badge, 9)
			local badgeLbl = MkLabel(badge, "0", 10, T.White, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			badgeLbl.ZIndex = 8

			local function RefBadge()
				local n = #GetSelected()
				badgeLbl.Text = tostring(n)
				badge.BackgroundTransparency = n == 0 and 1 or 0
				pillLbl.Text = PillText()
				FT(pillLbl, { TextColor3 = n > 0 and T.TxtMain or T.TxtMute }, 0.15)
			end
			RefBadge()

			local listFrame = MkFrame(dropOverlay, UDim2.new(1, -20, 0, 0), UDim2.new(0, 10, 0, 0), T.Surface)
			listFrame.ZIndex = 50; listFrame.Visible = false; listFrame.ClipsDescendants = true
			Corner(listFrame, 12); Stroke(listFrame, T.BorderGlow, 1, 0.3); CardShine(listFrame)

			local listInner = MkFrame(listFrame, UDim2.new(1, 0, 1, 0), nil, T.Black)
			listInner.BackgroundTransparency = 1; listInner.ZIndex = 51
			local listLL2 = Instance.new("UIListLayout")
			listLL2.FillDirection = Enum.FillDirection.Vertical
			listLL2.SortOrder     = Enum.SortOrder.LayoutOrder
			listLL2.Padding       = UDim.new(0, 3)
			listLL2.Parent        = listInner; Pad(listInner, 5, 5, 5, 5)

			-- Action bar
			local aRow = MkFrame(listInner, UDim2.new(1, 0, 0, 28), nil, T.SurfaceHi)
			aRow.ZIndex = 52; Corner(aRow, 8)
			local sAB = MkButton(aRow, "Select All", 11, T.AccentLo, T.AccentHi, Enum.Font.GothamBold)
			sAB.BackgroundTransparency = 1; sAB.Size = UDim2.new(0.5, 0, 1, 0)
			sAB.TextXAlignment = Enum.TextXAlignment.Center
			local cAB = MkButton(aRow, "Clear", 11, T.AccentLo, T.TxtMute, Enum.Font.GothamBold)
			cAB.BackgroundTransparency = 1; cAB.Size = UDim2.new(0.5, 0, 1, 0)
			cAB.Position = UDim2.new(0.5, 0, 0, 0); cAB.TextXAlignment = Enum.TextXAlignment.Center

			-- Items scroll
			local mItemsSF = Instance.new("ScrollingFrame")
			mItemsSF.BackgroundTransparency = 1; mItemsSF.BorderSizePixel = 0
			mItemsSF.Size = UDim2.new(1, 0, 0, 0); mItemsSF.CanvasSize = UDim2.new(0, 0, 0, 0)
			mItemsSF.AutomaticCanvasSize = Enum.AutomaticSize.Y
			mItemsSF.ScrollBarThickness = 2; mItemsSF.ScrollBarImageColor3 = T.Accent
			mItemsSF.ZIndex = 52; mItemsSF.Parent = listInner
			local mILL = Instance.new("UIListLayout")
			mILL.FillDirection = Enum.FillDirection.Vertical; mILL.SortOrder = Enum.SortOrder.LayoutOrder
			mILL.Padding = UDim.new(0, 2); mILL.Parent = mItemsSF

			local rowRefs = {}
			local function BuildMI()
				for _, r in rowRefs do r.rowFrame.Parent = nil end; rowRefs = {}
				for _, item in items do
					local row = MkFrame(mItemsSF, UDim2.new(1, 0, 0, 34), nil, T.Black)
					row.BackgroundTransparency = 1; row.ZIndex = 53; Corner(row, 7)

					local cbBox = MkFrame(row, UDim2.new(0, 20, 0, 20), UDim2.new(0, 6, 0.5, -10), T.SurfaceHi2)
					cbBox.ZIndex = 54; Corner(cbBox, 5); Stroke(cbBox, T.Border, 1)
					if selected[item] then cbBox.BackgroundColor3 = T.AccentDeep end

					local ckMark = MkLabel(cbBox, selected[item] and ">" or "", 11, color,
						Enum.Font.GothamBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
					ckMark.ZIndex = 55

					local iLbl = MkLabel(row, item, 12, T.TxtMain, Enum.Font.Gotham)
					iLbl.Size = UDim2.new(1, -36, 1, 0); iLbl.Position = UDim2.new(0, 34, 0, 0); iLbl.ZIndex = 54

					local hit = MkButton(row, "", 0, T.Black, T.White)
					hit.BackgroundTransparency = 1; hit.Size = UDim2.new(1, 0, 1, 0); hit.ZIndex = 55
					hit.MouseEnter:Connect(function() FT(row, { BackgroundColor3 = T.SurfaceHi2, BackgroundTransparency = 0 }, 0.10) end)
					hit.MouseLeave:Connect(function() FT(row, { BackgroundTransparency = 1 }, 0.10) end)
					hit.MouseButton1Click:Connect(function()
						selected[item] = not selected[item]
						ckMark.Text = selected[item] and ">" or ""
						FT(cbBox, { BackgroundColor3 = selected[item] and T.AccentDeep or T.SurfaceHi2 }, 0.12)
						RefBadge(); SafeCall(cb, GetSelected())
					end)
					table.insert(rowRefs, { item = item, rowFrame = row })
				end
				mItemsSF.Size = UDim2.new(1, 0, 0, math.min(#items, 5) * 36 + 4)
			end
			BuildMI()

			sAB.MouseButton1Click:Connect(function()
				for _, i in items do selected[i] = true end
				BuildMI(); RefBadge(); SafeCall(cb, GetSelected())
			end)
			cAB.MouseButton1Click:Connect(function()
				for _, i in items do selected[i] = false end
				BuildMI(); RefBadge(); SafeCall(cb, GetSelected())
			end)

			local function CloseMulti()
				if not isOpen then return end; isOpen = false
				FT(listFrame, { Size = UDim2.new(1, -20, 0, 0) }, 0.18)
				FT(chevLbl,   { Rotation = 0 }, 0.18)
				FT(pill,      { BackgroundColor3 = T.SurfaceHi }, 0.12)
				task.wait(0.20); listFrame.Visible = false
			end

			local pBB = MkButton(pill, "", 0, T.Black, T.White)
			pBB.BackgroundTransparency = 1; pBB.Size = UDim2.new(1, 0, 1, 0); pBB.ZIndex = 7
			pBB.MouseButton1Click:Connect(function()
				if isOpen then CloseMulti(); return end
				isOpen = true; BuildMI()
				local oAY  = dropOverlay.AbsolutePosition.Y
				local yPos = (card.AbsolutePosition.Y - oAY) + card.AbsoluteSize.Y + 4
				local listH = 38 + math.min(#items, 5) * 36 + 12
				listFrame.Position = UDim2.new(0, 10, 0, yPos)
				listFrame.Size     = UDim2.new(1, -20, 0, 0)
				listFrame.Visible  = true
				FT(listFrame, { Size = UDim2.new(1, -20, 0, listH) }, 0.22)
				FT(chevLbl,   { Rotation = 180 }, 0.18)
				FT(pill,      { BackgroundColor3 = T.SurfaceHi2 }, 0.12)
			end)
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType == Enum.UserInputType.MouseButton1
				or i.UserInputType == Enum.UserInputType.Touch then
					local lx, ly = listFrame.AbsolutePosition.X, listFrame.AbsolutePosition.Y
					local lw, lh = listFrame.AbsoluteSize.X,     listFrame.AbsoluteSize.Y
					local px, py = pill.AbsolutePosition.X,      pill.AbsolutePosition.Y
					local pw, ph = pill.AbsoluteSize.X,          pill.AbsoluteSize.Y
					local mx, my = i.Position.X, i.Position.Y
					if not (mx >= lx and mx <= lx + lw and my >= ly and my <= ly + lh)
					and not (mx >= px and mx <= px + pw and my >= py and my <= py + ph) then
						CloseMulti()
					end
				end
			end)

			local MD = WrapEl(card)
			function MD:Get()         return GetSelected() end
			function MD:IsEmpty()     return #GetSelected() == 0 end
			function MD:IsSelected(v) return selected[v] == true end
			function MD:Set(tbl)
				for _, i in items do selected[i] = false end
				if tbl then for _, v in tbl do selected[v] = true end end
				BuildMI(); RefBadge()
			end
			function MD:Clear()
				for _, i in items do selected[i] = false end
				BuildMI(); RefBadge(); SafeCall(cb, {})
			end
			function MD:AddItem(item)   table.insert(items, item); BuildMI() end
			function MD:RemoveItem(item)
				for i, v in items do if v == item then table.remove(items, i); break end end
				selected[item] = nil; BuildMI(); RefBadge()
			end
			function MD:SetPlaceholder(s)
				placeholder = s; if #GetSelected() == 0 then pillLbl.Text = s end
			end
			_RegElement(wName, id,
				function() return GetSelected() end,
				function(v)
					if type(v) == "table" then
						for _, i in items do selected[i] = false end
						for _, s in v do selected[s] = true end
						BuildMI(); RefBadge()
					end
				end,
				"multi", MD)
			return MD
		end

		-- ══════════════════════════════════════════════════════
		--  TEXTBOX
		-- ══════════════════════════════════════════════════════
		function API:AddTextBox(opt)
			opt = opt or {}
			local name     = opt.Name        or "Input"
			local ph       = opt.Placeholder or "Type here..."
			local default  = opt.Default     or ""
			local numOnly  = opt.NumberOnly  or false
			local cb       = opt.Callback    or function() end
			local color    = opt.Color       or T.Accent
			local id       = opt.Id          or ""

			local card = Card(70); Pad(card, 8, 8, 14, 14)
			local nameLbl = MkLabel(card, name, 12, T.TxtSub, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(1, 0, 0, 18); nameLbl.ZIndex = 5

			local inBG = MkFrame(card, UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 24), T.SurfaceHi)
			inBG.ZIndex = 5; Corner(inBG, 10)
			local inStroke = Stroke(inBG, T.Border, 1); CardShine(inBG)

			local preLbl = MkLabel(inBG, ">", 14, T.TxtMute, Enum.Font.GothamBold,
				Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			preLbl.Size = UDim2.new(0, 26, 1, 0); preLbl.ZIndex = 6

			local tb = Instance.new("TextBox")
			tb.Text             = default
			tb.PlaceholderText  = ph
			tb.PlaceholderColor3 = T.TxtMute
			tb.TextColor3       = T.TxtMain
			tb.BackgroundTransparency = 1
			tb.Font             = Enum.Font.Gotham
			tb.TextSize         = 13
			tb.Size             = UDim2.new(1, -40, 1, 0)
			tb.Position         = UDim2.new(0, 28, 0, 0)
			tb.TextXAlignment   = Enum.TextXAlignment.Left
			tb.ClearTextOnFocus = false
			tb.ZIndex           = 6
			tb.Parent           = inBG

			tb.Focused:Connect(function()
				FT(inBG,    { BackgroundColor3 = T.SurfaceHi2 }, 0.15)
				FT(inStroke,{ Color = T.BorderGlow, Thickness = 1.5 }, 0.15)
				FT(preLbl,  { TextColor3 = color }, 0.15)
			end)
			tb.FocusLost:Connect(function(enter)
				FT(inBG,    { BackgroundColor3 = T.SurfaceHi }, 0.15)
				FT(inStroke,{ Color = T.Border, Thickness = 1 }, 0.15)
				FT(preLbl,  { TextColor3 = T.TxtMute }, 0.15)
				if enter then SafeCall(cb, tb.Text) end
			end)
			if numOnly then
				tb:GetPropertyChangedSignal("Text"):Connect(function()
					local clean = tb.Text:gsub("[^%d%.%-]", "")
					if tb.Text ~= clean then tb.Text = clean end
				end)
			end

			local TBx = WrapEl(card)
			function TBx:Get()              return tb.Text end
			function TBx:Set(v)             tb.Text = tostring(v) end
			function TBx:Clear()            tb.Text = "" end
			function TBx:Focus()            tb:CaptureFocus() end
			function TBx:SetPlaceholder(s)  tb.PlaceholderText = s end
			_RegElement(wName, id,
				function() return tb.Text end,
				function(v) tb.Text = tostring(v) end,
				"string", TBx)
			return TBx
		end

		-- ══════════════════════════════════════════════════════
		--  KEYBIND
		-- ══════════════════════════════════════════════════════
		function API:AddKeybind(opt)
			opt = opt or {}
			local name = opt.Name     or "Keybind"
			local def  = opt.Default  or Enum.KeyCode.F
			local cb   = opt.Callback or function() end

			local card = Card(46)
			local nameLbl = MkLabel(card, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(0.52, 0, 1, 0); nameLbl.ZIndex = 5

			local curKey   = def
			local listening = false

			local kPill = MkFrame(card, UDim2.new(0, 114, 0, 30), UDim2.new(1, -114, 0.5, -15), T.SurfaceHi)
			kPill.ZIndex = 5; Corner(kPill, 8); Stroke(kPill, T.Border, 1); CardShine(kPill)

			local kLbl = MkLabel(kPill, "[" .. tostring(def.Name) .. "]", 11, T.TxtMain,
				Enum.Font.GothamBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
			kLbl.ZIndex = 6

			local kBB = MkButton(kPill, "", 0, T.Black, T.White)
			kBB.BackgroundTransparency = 1; kBB.Size = UDim2.new(1, 0, 1, 0); kBB.ZIndex = 7
			kBB.MouseButton1Click:Connect(function()
				listening = true; kLbl.Text = "[  ?  ]"
				FT(kPill, { BackgroundColor3 = T.AccentDeep }, 0.12)
				Stroke(kPill, T.Accent, 1)
			end)

			UserInputService.InputBegan:Connect(function(i, gpe)
				if gpe then return end
				if listening and i.UserInputType == Enum.UserInputType.Keyboard then
					listening = false; curKey = i.KeyCode
					kLbl.Text = "[" .. tostring(i.KeyCode.Name) .. "]"
					FT(kPill, { BackgroundColor3 = T.SurfaceHi }, 0.15)
				elseif not listening
				  and i.UserInputType == Enum.UserInputType.Keyboard
				  and i.KeyCode == curKey then
					SafeCall(cb)
				end
			end)

			local KB = WrapEl(card)
			function KB:Get()    return curKey end
			function KB:Set(k)   curKey = k; kLbl.Text = "[" .. tostring(k.Name) .. "]" end
			return KB
		end

		-- ══════════════════════════════════════════════════════
		--  COLOR PICKER
		-- ══════════════════════════════════════════════════════
		function API:AddColorPicker(opt)
			opt = opt or {}
			local name = opt.Name     or "Color"
			local def  = opt.Default  or T.Accent
			local cb   = opt.Callback or function() end
			local id   = opt.Id       or ""

			local swatches = {
				Color3.fromRGB(248,  68,  92),
				Color3.fromRGB(252, 150,  52),
				Color3.fromRGB(252, 214,  52),
				Color3.fromRGB( 68, 214, 132),
				Color3.fromRGB( 52, 172, 254),
				Color3.fromRGB(138,  76, 255),
				Color3.fromRGB(248,  72, 200),
				Color3.fromRGB(200, 200, 210),
			}

			local card = Card(66); Pad(card, 8, 8, 14, 14)
			local nameLbl = MkLabel(card, name, 12, T.TxtSub, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(1, 0, 0, 18); nameLbl.ZIndex = 5

			local row = MkFrame(card, UDim2.new(1, 0, 0, 38), UDim2.new(0, 0, 0, 22), T.Black)
			row.BackgroundTransparency = 1; row.ZIndex = 5

			local prevBox = MkFrame(row, UDim2.new(0, 38, 0, 38), nil, def)
			prevBox.ZIndex = 6; Corner(prevBox, 11); Stroke(prevBox, T.Border, 1); CardShine(prevBox)

			local swRow = MkFrame(row, UDim2.new(1, -48, 1, 0), UDim2.new(0, 46, 0, 0), T.Black)
			swRow.BackgroundTransparency = 1; swRow.ZIndex = 5
			local swLL = Instance.new("UIListLayout")
			swLL.FillDirection     = Enum.FillDirection.Horizontal
			swLL.VerticalAlignment = Enum.VerticalAlignment.Center
			swLL.Padding           = UDim.new(0, 5)
			swLL.Parent            = swRow

			local selColor  = def
			local activeRing = nil

			for _, col in swatches do
				local sw = MkFrame(swRow, UDim2.new(0, 28, 0, 28), nil, col)
				sw.ZIndex = 6; Corner(sw, 8); CardShine(sw)
				local ring = Stroke(sw, T.White, 2, col == def and 0 or 1)
				if col == def then activeRing = ring end

				local hit = MkButton(sw, "", 0, T.Black, T.White)
				hit.BackgroundTransparency = 1; hit.Size = UDim2.new(1, 0, 1, 0); hit.ZIndex = 7
				hit.MouseEnter:Connect(function() ST(sw, { Size = UDim2.new(0, 30, 0, 30) }, 0.14) end)
				hit.MouseLeave:Connect(function() FT(sw, { Size = UDim2.new(0, 28, 0, 28) }, 0.12) end)
				hit.MouseButton1Click:Connect(function()
					selColor = col
					FT(prevBox, { BackgroundColor3 = col }, 0.18)
					if activeRing then FT(activeRing, { Transparency = 1 }, 0.1) end
					FT(ring, { Transparency = 0 }, 0.1); activeRing = ring
					SafeCall(cb, col)
				end)
			end

			local CP = WrapEl(card)
			function CP:Get()    return selColor end
			function CP:Set(c)   selColor = c; prevBox.BackgroundColor3 = c
				if activeRing then activeRing.Transparency = 1; activeRing = nil end
			end
			_RegElement(wName, id,
				function() return selColor end,
				function(v) selColor = v; prevBox.BackgroundColor3 = v end,
				"color", CP)
			return CP
		end

		-- ══════════════════════════════════════════════════════
		--  PROGRESS BAR
		-- ══════════════════════════════════════════════════════
		function API:AddProgressBar(opt)
			opt = opt or {}
			local name    = opt.Name  or "Progress"
			local initVal = opt.Value or 0
			local color   = opt.Color or T.Accent

			local card = Card(54); Pad(card, 8, 8, 14, 14)

			local row = MkFrame(card, UDim2.new(1, 0, 0, 20), nil, T.Black)
			row.BackgroundTransparency = 1; row.ZIndex = 5

			local nameLbl = MkLabel(row, name, 13, T.TxtMain, Enum.Font.GothamBold)
			nameLbl.Size = UDim2.new(0.65, 0, 1, 0); nameLbl.ZIndex = 6

			local valLbl = MkLabel(row, tostring(initVal) .. "%", 13, color,
				Enum.Font.GothamBold, Enum.TextXAlignment.Right)
			valLbl.Size = UDim2.new(0.35, 0, 1, 0); valLbl.ZIndex = 6

			local tBG = MkFrame(card, UDim2.new(1, 0, 0, 10), UDim2.new(0, 0, 0, 30), T.SurfaceHi)
			tBG.ZIndex = 5; Corner(tBG, 5); Stroke(tBG, T.Border, 1)

			local fillF = MkFrame(tBG, UDim2.new(initVal / 100, 0, 1, 0), nil, color)
			fillF.ZIndex = 6; Corner(fillF, 5)

			local fGrad = Instance.new("UIGradient")
			fGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, T.AccentHi),
				ColorSequenceKeypoint.new(1, color),
			})
			fGrad.Parent = fillF

			local fShine = MkFrame(fillF, UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 1), T.White)
			fShine.BackgroundTransparency = 0.86; fShine.ZIndex = 7; Corner(fShine, 4)

			local PB = WrapEl(card)
			function PB:Set(v)
				v = math.clamp(v, 0, 100)
				FT(fillF, { Size = UDim2.new(v / 100, 0, 1, 0) }, 0.40)
				valLbl.Text = tostring(math.round(v)) .. "%"
			end
			function PB:Get()
				return tonumber(valLbl.Text:gsub("%%", ""))
			end
			-- Smooth animated update over a custom duration
			function PB:Animate(v, duration)
				v = math.clamp(v, 0, 100)
				LT(fillF, { Size = UDim2.new(v / 100, 0, 1, 0) }, duration or 1)
				valLbl.Text = tostring(math.round(v)) .. "%"
			end
			return PB
		end

		-- ══════════════════════════════════════════════════════
		--  CREDIT  (transparent, styled centred text)
		-- ══════════════════════════════════════════════════════
		function API:AddCredit(line1, line2)
			line1 = line1 or "Credit"; line2 = line2 or ""
			local wrap = MkFrame(page, UDim2.new(1, 0, 0, line2 ~= "" and 72 or 54), nil, T.Black)
			wrap.BackgroundTransparency = 1; wrap.ZIndex = 4

			local function FadeLine(xScale, xOff, lineWidth)
				local l = MkFrame(wrap, UDim2.new(lineWidth, 0, 0, 1), UDim2.new(xScale, xOff, 0, 0), T.Accent)
				l.BackgroundTransparency = 0.60; l.ZIndex = 4
				local g = Instance.new("UIGradient")
				g.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0,   xScale == 0 and 1 or 0.6),
					NumberSequenceKeypoint.new(0.5, 0.55),
					NumberSequenceKeypoint.new(1,   xScale == 0 and 0.6 or 1),
				})
				g.Parent = l
			end
			FadeLine(0.05, 0, 0.3); FadeLine(0.65, 0, 0.3)

			local l1 = Instance.new("TextLabel")
			l1.Text               = line1
			l1.TextSize           = 14
			l1.Font               = Enum.Font.GothamBold
			l1.TextColor3         = Color3.fromRGB(200, 174, 255)
			l1.BackgroundTransparency = 1; l1.BorderSizePixel = 0
			l1.Size               = UDim2.new(1, 0, 0, 22)
			l1.Position           = UDim2.new(0, 0, 0, 8)
			l1.TextXAlignment     = Enum.TextXAlignment.Center
			l1.ZIndex             = 5; l1.Parent = wrap

			if line2 ~= "" then
				local l2 = Instance.new("TextLabel")
				l2.Text               = line2
				l2.TextSize           = 11
				l2.Font               = Enum.Font.Gotham
				l2.TextColor3         = Color3.fromRGB(114, 94, 156)
				l2.BackgroundTransparency = 1; l2.BorderSizePixel = 0
				l2.Size               = UDim2.new(1, 0, 0, 18)
				l2.Position           = UDim2.new(0, 0, 0, 34)
				l2.TextXAlignment     = Enum.TextXAlignment.Center
				l2.ZIndex             = 5; l2.Parent = wrap
			end

			FadeLine(0.05, 0, 0.3); FadeLine(0.65, 0, 0.3)
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

return NexusUI
