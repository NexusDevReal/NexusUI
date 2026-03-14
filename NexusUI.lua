--[[
   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗   ██╗██╗
   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║   ██║██║
   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║   ██║██║
   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║   ██║██║
   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╔╝██║
   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝
   
   NexusUI Library v1.0 — by NexusDev
   Full-featured Roblox Luau UI Library
   • iOS Toggle  • Button  • Slider  • Dropdown
   • TextBox  • Label  • Separator  • ColorPicker
   • TitleBar (Minimize + Close)  • Tabs  • Mobile Support
--]]

local NexusUI = {}
NexusUI.__index = NexusUI

-- ══════════════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════════════
local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local TextService    = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════
--              THEME
-- ══════════════════════════════════════════════
local Theme = {
	-- Base Colors
	Background     = Color3.fromRGB(18, 14, 35),
	Surface        = Color3.fromRGB(28, 22, 52),
	SurfaceHigh    = Color3.fromRGB(38, 30, 68),
	SurfaceBorder  = Color3.fromRGB(55, 42, 95),

	-- Accent
	Accent         = Color3.fromRGB(138, 80, 255),
	AccentLight    = Color3.fromRGB(168, 120, 255),
	AccentDark     = Color3.fromRGB(100, 50, 200),
	AccentGlow     = Color3.fromRGB(100, 40, 180),

	-- Text
	TextPrimary    = Color3.fromRGB(240, 235, 255),
	TextSecondary  = Color3.fromRGB(160, 145, 200),
	TextMuted      = Color3.fromRGB(100, 88, 135),
	TextDisabled   = Color3.fromRGB(70, 60, 100),

	-- Status
	Success        = Color3.fromRGB(80, 220, 140),
	Danger         = Color3.fromRGB(255, 80, 100),
	Warning        = Color3.fromRGB(255, 190, 60),
	Info           = Color3.fromRGB(60, 180, 255),

	-- Misc
	ToggleOff      = Color3.fromRGB(55, 50, 80),
	Shadow         = Color3.fromRGB(8, 5, 20),
	White          = Color3.fromRGB(255, 255, 255),
	Transparent    = Color3.fromRGB(0, 0, 0),
}

-- ══════════════════════════════════════════════
--              UTILITY FUNCTIONS
-- ══════════════════════════════════════════════
local function Tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function FastTween(obj, props, t)
	t = t or 0.2
	return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

local function SpringTween(obj, props, t)
	t = t or 0.35
	return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function AddCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function AddStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.SurfaceBorder
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function AddPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 6)
	p.PaddingBottom = UDim.new(0, bottom or 6)
	p.PaddingLeft   = UDim.new(0, left   or 10)
	p.PaddingRight  = UDim.new(0, right  or 10)
	p.Parent = parent
	return p
end

local function MakeFrame(props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = props.Color or Theme.Surface
	f.BorderSizePixel  = 0
	f.Size   = props.Size   or UDim2.new(1, 0, 0, 40)
	f.Position = props.Position or UDim2.new(0, 0, 0, 0)
	if props.Parent then f.Parent = props.Parent end
	if props.ZIndex then f.ZIndex = props.ZIndex end
	f.ClipsDescendants = props.Clip or false
	return f
end

local function MakeLabel(props)
	local l = Instance.new("TextLabel")
	l.Text = props.Text or ""
	l.TextColor3 = props.TextColor or Theme.TextPrimary
	l.BackgroundTransparency = 1
	l.Font = props.Font or Enum.Font.GothamBold
	l.TextSize = props.TextSize or 14
	l.Size = props.Size or UDim2.new(1, 0, 1, 0)
	l.Position = props.Position or UDim2.new(0, 0, 0, 0)
	l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
	l.TextWrapped = props.Wrap or false
	l.RichText = props.Rich or false
	if props.Parent then l.Parent = props.Parent end
	return l
end

local function MakeButton(props)
	local b = Instance.new("TextButton")
	b.Text = props.Text or ""
	b.TextColor3 = props.TextColor or Theme.TextPrimary
	b.BackgroundColor3 = props.Color or Theme.SurfaceHigh
	b.BorderSizePixel = 0
	b.Font = props.Font or Enum.Font.GothamBold
	b.TextSize = props.TextSize or 14
	b.Size = props.Size or UDim2.new(1, 0, 0, 36)
	b.Position = props.Position or UDim2.new(0, 0, 0, 0)
	b.AutoButtonColor = false
	if props.Parent then b.Parent = props.Parent end
	return b
end

-- Mobile detection
local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- ══════════════════════════════════════════════
--              DRAGGING
-- ══════════════════════════════════════════════
local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			frame.Position = UDim2.new(
				framePos.X.Scale,
				framePos.X.Offset + delta.X,
				framePos.Y.Scale,
				framePos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ══════════════════════════════════════════════
--              NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════
local NotifHolder = nil

local function InitNotifHolder(screenGui)
	NotifHolder = Instance.new("Frame")
	NotifHolder.Name = "NexusNotifications"
	NotifHolder.BackgroundTransparency = 1
	NotifHolder.Size = UDim2.new(0, 300, 1, 0)
	NotifHolder.Position = UDim2.new(1, -310, 0, 0)
	NotifHolder.AnchorPoint = Vector2.new(0, 0)
	NotifHolder.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 8)
	layout.Parent = NotifHolder

	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = NotifHolder
end

function NexusUI:Notify(options)
	options = options or {}
	local title    = options.Title    or "Notification"
	local desc     = options.Desc     or ""
	local duration = options.Duration or 4
	local icon     = options.Icon     or "ℹ"
	local color    = options.Color    or Theme.Accent

	if not NotifHolder then return end

	local notif = MakeFrame({
		Size   = UDim2.new(1, 0, 0, 70),
		Color  = Theme.Surface,
		Parent = NotifHolder,
	})
	notif.Position = UDim2.new(1, 10, 0, 0)
	AddCorner(notif, 12)
	AddStroke(notif, color, 1)

	-- Accent line
	local line = MakeFrame({ Size = UDim2.new(0, 4, 1, -12), Color = color, Parent = notif })
	line.Position = UDim2.new(0, 0, 0, 6)
	line.AnchorPoint = Vector2.new(0, 0)
	AddCorner(line, 4)

	-- Icon
	local iconLbl = MakeLabel({
		Text = icon, TextSize = 22, TextColor = color,
		Size = UDim2.new(0, 36, 1, 0), Position = UDim2.new(0, 12, 0, 0),
		XAlign = Enum.TextXAlignment.Center, Parent = notif,
	})

	-- Title
	MakeLabel({
		Text = title, TextSize = 13, Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -60, 0, 24), Position = UDim2.new(0, 50, 0, 10),
		Parent = notif,
	})

	-- Description
	MakeLabel({
		Text = desc, TextSize = 11, TextColor = Theme.TextSecondary,
		Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 50, 0, 34),
		Wrap = true, Parent = notif,
	})

	-- Slide in
	FastTween(notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)

	-- Progress bar
	local prog = MakeFrame({ Size = UDim2.new(1, 0, 0, 3), Color = color, Parent = notif })
	prog.AnchorPoint = Vector2.new(0, 1)
	prog.Position = UDim2.new(0, 0, 1, 0)
	AddCorner(prog, 3)
	Tween(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })

	-- Auto dismiss
	task.delay(duration, function()
		FastTween(notif, { Position = UDim2.new(1, 10, 0, 0) }, 0.25)
		task.wait(0.3)
		notif:Destroy()
	end)

	return notif
end

-- ══════════════════════════════════════════════
--              WINDOW CREATION
-- ══════════════════════════════════════════════
function NexusUI:CreateWindow(options)
	options = options or {}
	local title   = options.Title   or "NexusUI"
	local subtitle = options.Subtitle or "v1.0"
	local size    = options.Size    or UDim2.new(0, 360, 0, 480)
	local pos     = options.Position or UDim2.new(0.5, -180, 0.5, -240)
	local icon    = options.Icon    or "⬡"

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name  = "NexusUI_" .. title
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999
	screenGui.IgnoreGuiInset = true

	-- Parent to CoreGui (preferred) or PlayerGui
	local ok = pcall(function()
		screenGui.Parent = game:GetService("CoreGui")
	end)
	if not ok then
		screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	InitNotifHolder(screenGui)

	-- ── Shadow ────────────────────────────────
	local shadow = MakeFrame({
		Size = UDim2.new(0, size.X.Offset + 30, 0, size.Y.Offset + 30),
		Color = Theme.Shadow,
		Parent = screenGui,
	})
	shadow.Position = UDim2.new(pos.X.Scale, pos.X.Offset - 15, pos.Y.Scale, pos.Y.Offset - 15)
	shadow.BackgroundTransparency = 0.5
	shadow.ZIndex = 1
	AddCorner(shadow, 20)

	-- ── Main Window ───────────────────────────
	local window = MakeFrame({
		Size = size,
		Color = Theme.Background,
		Parent = screenGui,
	})
	window.Position = pos
	window.ZIndex = 2
	AddCorner(window, 14)
	AddStroke(window, Theme.SurfaceBorder, 1)

	-- ── TitleBar ──────────────────────────────
	local titleBar = MakeFrame({
		Size = UDim2.new(1, 0, 0, 50),
		Color = Theme.Surface,
		Parent = window,
	})
	AddCorner(titleBar, 14)

	-- Fix bottom corners of titlebar
	local titleBarFix = MakeFrame({
		Size = UDim2.new(1, 0, 0, 14),
		Color = Theme.Surface,
		Parent = titleBar,
	})
	titleBarFix.Position = UDim2.new(0, 0, 1, -14)

	-- Drag handle
	MakeDraggable(window, titleBar)
	-- Also drag shadow
	titleBar.InputBegan:Connect(function()
		-- sync shadow
	end)
	
	-- Sync shadow with window
	RunService.RenderStepped:Connect(function()
		shadow.Position = UDim2.new(
			window.Position.X.Scale,
			window.Position.X.Offset - 15,
			window.Position.Y.Scale,
			window.Position.Y.Offset - 15
		)
	end)

	-- Icon circle
	local iconBg = MakeFrame({
		Size = UDim2.new(0, 34, 0, 34),
		Color = Theme.AccentDark,
		Parent = titleBar,
	})
	iconBg.Position = UDim2.new(0, 10, 0.5, -17)
	AddCorner(iconBg, 10)

	MakeLabel({
		Text = icon, TextSize = 18,
		TextColor = Theme.White,
		Size = UDim2.new(1, 0, 1, 0),
		XAlign = Enum.TextXAlignment.Center,
		Parent = iconBg,
	})

	-- Title text
	MakeLabel({
		Text = title, TextSize = 15, Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, -120, 0, 22),
		Position = UDim2.new(0, 52, 0, 6),
		Parent = titleBar,
	})

	-- Subtitle
	MakeLabel({
		Text = subtitle, TextSize = 11, TextColor = Theme.TextMuted,
		Font = Enum.Font.Gotham,
		Size = UDim2.new(1, -120, 0, 16),
		Position = UDim2.new(0, 52, 0, 26),
		Parent = titleBar,
	})

	-- ── Control Buttons (X and Minimize) ─────
	local function MakeControlBtn(xOffset, symbol, bgColor)
		local btn = MakeButton({
			Text = symbol, TextSize = 14,
			Color = bgColor,
			Size = UDim2.new(0, 26, 0, 26),
			Position = UDim2.new(1, xOffset, 0.5, -13),
			Parent = titleBar,
		})
		AddCorner(btn, 8)
		return btn
	end

	local closeBtn    = MakeControlBtn(-36, "✕", Theme.Danger)
	local minimizeBtn = MakeControlBtn(-66, "—", Theme.SurfaceHigh)
	AddStroke(minimizeBtn, Theme.SurfaceBorder, 1)

	-- Hover effects
	local function CtrlHover(btn, hoverColor, normalColor)
		btn.MouseEnter:Connect(function()
			FastTween(btn, { BackgroundColor3 = hoverColor }, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			FastTween(btn, { BackgroundColor3 = normalColor }, 0.15)
		end)
	end

	CtrlHover(closeBtn, Color3.fromRGB(255, 50, 80), Theme.Danger)
	CtrlHover(minimizeBtn, Theme.SurfaceBorder, Theme.SurfaceHigh)

	-- Close functionality
	closeBtn.MouseButton1Click:Connect(function()
		FastTween(window, { Size = UDim2.new(0, size.X.Offset, 0, 0) }, 0.3)
		FastTween(shadow, { BackgroundTransparency = 1 }, 0.3)
		task.wait(0.3)
		screenGui:Destroy()
	end)

	-- ── Content Body ──────────────────────────
	local body = MakeFrame({
		Size = UDim2.new(1, 0, 1, -50),
		Color = Theme.Background,
		Parent = window,
	})
	body.Position = UDim2.new(0, 0, 0, 50)
	body.ClipsDescendants = true
	AddCorner(body, 14)
	local bodyCornerFix = MakeFrame({ Size = UDim2.new(1, 0, 0, 14), Color = Theme.Background, Parent = body })

	-- Minimize
	local minimized = false
	local origSize = size
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			FastTween(window, { Size = UDim2.new(0, origSize.X.Offset, 0, 50) }, 0.35)
			minimizeBtn.Text = "▲"
		else
			FastTween(window, { Size = origSize }, 0.35)
			minimizeBtn.Text = "—"
		end
	end)

	-- ══════════════════════════════════════════
	--         TAB SYSTEM
	-- ══════════════════════════════════════════
	local tabBar = MakeFrame({
		Size = UDim2.new(1, -20, 0, 36),
		Color = Theme.SurfaceHigh,
		Parent = body,
	})
	tabBar.Position = UDim2.new(0, 10, 0, 16)
	AddCorner(tabBar, 10)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 3)
	tabLayout.Parent = tabBar
	AddPadding(tabBar, 3, 3, 4, 4)

	-- Scroll container for pages
	local pageHolder = Instance.new("ScrollingFrame")
	pageHolder.Name = "PageHolder"
	pageHolder.BackgroundTransparency = 1
	pageHolder.BorderSizePixel = 0
	pageHolder.Size = UDim2.new(1, 0, 1, -66)
	pageHolder.Position = UDim2.new(0, 0, 0, 66)
	pageHolder.ScrollBarThickness = 3
	pageHolder.ScrollBarImageColor3 = Theme.Accent
	pageHolder.ScrollBarImageTransparency = 0.4
	pageHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
	pageHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pageHolder.Parent = body

	local tabs = {}
	local activeTab = nil

	local WindowObject = {}
	WindowObject.ScreenGui = screenGui
	WindowObject.Window = window

	-- Notify shortcut
	function WindowObject:Notify(opts)
		return NexusUI:Notify(opts)
	end

	-- ── Add Tab ───────────────────────────────
	function WindowObject:AddTab(tabName, tabIcon)
		tabIcon = tabIcon or ""

		local tabBtn = MakeButton({
			Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
			TextSize = 12, Font = Enum.Font.GothamSemibold,
			Color = Color3.fromRGB(0,0,0),
			Size = UDim2.new(0, 90, 1, 0),
			Parent = tabBar,
		})
		tabBtn.BackgroundTransparency = 1
		tabBtn.TextColor3 = Theme.TextMuted
		AddCorner(tabBtn, 8)

		-- Page
		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Size = UDim2.new(1, 0, 1, 0)
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = Theme.Accent
		page.ScrollBarImageTransparency = 0.4
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = pageHolder

		local listLayout = Instance.new("UIListLayout")
		listLayout.FillDirection = Enum.FillDirection.Vertical
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 6)
		listLayout.Parent = page
		AddPadding(page, 8, 12, 10, 10)

		local tabData = { Btn = tabBtn, Page = page, Name = tabName }
		table.insert(tabs, tabData)

		local function Activate()
			if activeTab then
				FastTween(activeTab.Btn, {
					BackgroundTransparency = 1,
					TextColor3 = Theme.TextMuted,
				}, 0.2)
				activeTab.Page.Visible = false
			end
			activeTab = tabData
			FastTween(tabBtn, {
				BackgroundTransparency = 0,
				TextColor3 = Theme.TextPrimary,
			}, 0.2)
			tabBtn.BackgroundColor3 = Theme.Accent
			page.Visible = true
		end

		tabBtn.MouseButton1Click:Connect(Activate)

		if #tabs == 1 then
			Activate()
		end

		-- ════════════════════════════════════════
		--       SECTION / ELEMENT API
		-- ════════════════════════════════════════
		local TabAPI = {}

		-- ── Section ───────────────────────────
		function TabAPI:AddSection(sectionName)
			local section = MakeFrame({
				Size = UDim2.new(1, 0, 0, 30),
				Color = Color3.fromRGB(0, 0, 0),
				Parent = page,
			})
			section.BackgroundTransparency = 1
			section.Size = UDim2.new(1, 0, 0, 28)

			-- Line left
			local line1 = MakeFrame({ Size = UDim2.new(0.3, -8, 0, 1), Color = Theme.SurfaceBorder, Parent = section })
			line1.Position = UDim2.new(0, 0, 0.5, 0)

			-- Section label
			local lbl = MakeLabel({
				Text = sectionName:upper(), TextSize = 10,
				Font = Enum.Font.GothamBold,
				TextColor = Theme.TextMuted,
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0.3, 0, 0, 0),
				XAlign = Enum.TextXAlignment.Center,
				Parent = section,
			})

			-- Line right
			local line2 = MakeFrame({ Size = UDim2.new(0.3, -8, 0, 1), Color = Theme.SurfaceBorder, Parent = section })
			line2.Position = UDim2.new(0.7, 8, 0.5, 0)
		end

		-- ── Label ─────────────────────────────
		function TabAPI:AddLabel(text)
			local lbl = MakeFrame({ Size = UDim2.new(1, 0, 0, 32), Color = Theme.Surface, Parent = page })
			AddCorner(lbl, 8)
			AddPadding(lbl, 0, 0, 12, 12)
			MakeLabel({ Text = text, TextSize = 13, TextColor = Theme.TextSecondary, Wrap = true, Size = UDim2.new(1, 0, 1, 0), Parent = lbl })
		end

		-- ── Separator ─────────────────────────
		function TabAPI:AddSeparator()
			local sep = MakeFrame({ Size = UDim2.new(1, 0, 0, 1), Color = Theme.SurfaceBorder, Parent = page })
		end

		-- ════════════════════════════════════════
		--   BUTTON
		-- ════════════════════════════════════════
		function TabAPI:AddButton(options)
			options = options or {}
			local name     = options.Name     or "Button"
			local desc     = options.Desc     or ""
			local icon     = options.Icon     or ""
			local callback = options.Callback or function() end
			local color    = options.Color    or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 44), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			-- Icon
			if icon ~= "" then
				local iconLbl = MakeLabel({ Text = icon, TextSize = 18, TextColor = color,
					Size = UDim2.new(0, 28, 1, 0), XAlign = Enum.TextXAlignment.Center,
					Parent = container,
				})
			end

			local textOff = icon ~= "" and 30 or 0
			MakeLabel({
				Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, -(textOff + 80), 0.6, 0),
				Position = UDim2.new(0, textOff, 0.1, 0),
				Parent = container,
			})

			if desc ~= "" then
				container.Size = UDim2.new(1, 0, 0, 52)
				MakeLabel({
					Text = desc, TextSize = 11, TextColor = Theme.TextMuted,
					Size = UDim2.new(1, -(textOff + 80), 0, 14),
					Position = UDim2.new(0, textOff, 0.5, 2),
					Parent = container,
				})
			end

			local btn = MakeButton({
				Text = "RUN", TextSize = 11, Font = Enum.Font.GothamBold,
				Color = color,
				Size = UDim2.new(0, 60, 0, 28),
				TextColor = Theme.White,
				Parent = container,
			})
			btn.Position = UDim2.new(1, -60, 0.5, -14)
			AddCorner(btn, 8)

			btn.MouseEnter:Connect(function() FastTween(btn, { BackgroundColor3 = Theme.AccentLight }, 0.15) end)
			btn.MouseLeave:Connect(function() FastTween(btn, { BackgroundColor3 = color }, 0.15) end)

			btn.MouseButton1Click:Connect(function()
				FastTween(btn, { Size = UDim2.new(0, 54, 0, 24) }, 0.1)
				task.wait(0.1)
				FastTween(btn, { Size = UDim2.new(0, 60, 0, 28) }, 0.15)
				local ok, err = pcall(callback)
				if not ok then warn("[NexusUI] Button callback error: " .. tostring(err)) end
			end)

			return container
		end

		-- ════════════════════════════════════════
		--   TOGGLE (iOS-style)
		-- ════════════════════════════════════════
		function TabAPI:AddToggle(options)
			options = options or {}
			local name     = options.Name     or "Toggle"
			local desc     = options.Desc     or ""
			local default  = options.Default  or false
			local callback = options.Callback or function() end
			local color    = options.Color    or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 44), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, -70, 0.55, 0), Position = UDim2.new(0, 0, 0, 4), Parent = container })

			if desc ~= "" then
				container.Size = UDim2.new(1, 0, 0, 52)
				MakeLabel({ Text = desc, TextSize = 11, TextColor = Theme.TextMuted,
					Size = UDim2.new(1, -70, 0, 16), Position = UDim2.new(0, 0, 0.5, 2), Parent = container })
			end

			-- Toggle Track
			local track = MakeFrame({ Size = UDim2.new(0, 48, 0, 28), Color = Theme.ToggleOff, Parent = container })
			track.Position = UDim2.new(1, -48, 0.5, -14)
			AddCorner(track, 14)

			-- Toggle Thumb
			local thumb = MakeFrame({ Size = UDim2.new(0, 22, 0, 22), Color = Theme.White, Parent = track })
			thumb.Position = UDim2.new(0, 3, 0.5, -11)
			AddCorner(thumb, 11)

			local state = default
			local toggling = false

			local function UpdateToggle(animate)
				if state then
					if animate then
						FastTween(track, { BackgroundColor3 = color }, 0.25)
						SpringTween(thumb, { Position = UDim2.new(0, 23, 0.5, -11) }, 0.25)
					else
						track.BackgroundColor3 = color
						thumb.Position = UDim2.new(0, 23, 0.5, -11)
					end
				else
					if animate then
						FastTween(track, { BackgroundColor3 = Theme.ToggleOff }, 0.25)
						SpringTween(thumb, { Position = UDim2.new(0, 3, 0.5, -11) }, 0.25)
					else
						track.BackgroundColor3 = Theme.ToggleOff
						thumb.Position = UDim2.new(0, 3, 0.5, -11)
					end
				end
			end

			UpdateToggle(false)

			local function Toggle()
				if toggling then return end
				toggling = true
				state = not state
				UpdateToggle(true)
				local ok, err = pcall(callback, state)
				if not ok then warn("[NexusUI] Toggle callback error: " .. tostring(err)) end
				task.wait(0.3)
				toggling = false
			end

			track.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
					or i.UserInputType == Enum.UserInputType.Touch then
					Toggle()
				end
			end)

			local ToggleAPI = {}
			function ToggleAPI:Set(val)
				state = val
				UpdateToggle(true)
			end
			function ToggleAPI:Get() return state end

			return ToggleAPI
		end

		-- ════════════════════════════════════════
		--   SLIDER
		-- ════════════════════════════════════════
		function TabAPI:AddSlider(options)
			options = options or {}
			local name     = options.Name     or "Slider"
			local desc     = options.Desc     or ""
			local min      = options.Min      or 0
			local max      = options.Max      or 100
			local default  = options.Default  or min
			local suffix   = options.Suffix   or ""
			local callback = options.Callback or function() end
			local color    = options.Color    or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 62), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			-- Header row
			local headerRow = MakeFrame({ Size = UDim2.new(1, 0, 0, 22), Color = Color3.new(), Parent = container })
			headerRow.BackgroundTransparency = 1

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(0.7, 0, 1, 0), Parent = headerRow })

			local valueLbl = MakeLabel({
				Text = tostring(default) .. suffix,
				TextSize = 13, Font = Enum.Font.GothamBold, TextColor = color,
				Size = UDim2.new(0.3, 0, 1, 0), XAlign = Enum.TextXAlignment.Right,
				Parent = headerRow,
			})

			-- Track
			local trackBg = MakeFrame({ Size = UDim2.new(1, 0, 0, 8), Color = Theme.SurfaceHigh, Parent = container })
			trackBg.Position = UDim2.new(0, 0, 0, 30)
			AddCorner(trackBg, 4)

			local trackFill = MakeFrame({ Size = UDim2.new(0, 0, 1, 0), Color = color, Parent = trackBg })
			AddCorner(trackFill, 4)

			-- Knob
			local knob = MakeFrame({ Size = UDim2.new(0, 20, 0, 20), Color = Theme.White, Parent = trackBg })
			knob.Position = UDim2.new(0, -10, 0.5, -10)
			AddCorner(knob, 10)
			AddStroke(knob, color, 2)

			-- Shadow on knob
			local knobShadow = MakeFrame({ Size = UDim2.new(0, 24, 0, 24), Color = color, Parent = knob })
			knobShadow.BackgroundTransparency = 0.7
			knobShadow.Position = UDim2.new(0.5, -12, 0.5, -12)
			AddCorner(knobShadow, 12)

			local currentValue = math.clamp(default, min, max)

			local function UpdateSlider(val)
				currentValue = math.clamp(val, min, max)
				local pct = (currentValue - min) / (max - min)
				FastTween(trackFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.08)
				FastTween(knob, { Position = UDim2.new(pct, -10, 0.5, -10) }, 0.08)
				valueLbl.Text = tostring(math.round(currentValue)) .. suffix
			end

			UpdateSlider(default)

			local draggingSlider = false

			local function GetSliderValue(inputPos)
				local absPos = trackBg.AbsolutePosition
				local absSize = trackBg.AbsoluteSize
				local rel = (inputPos.X - absPos.X) / absSize.X
				return min + math.clamp(rel, 0, 1) * (max - min)
			end

			trackBg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
					or i.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					FastTween(knob, { Size = UDim2.new(0, 24, 0, 24) }, 0.1)
					UpdateSlider(GetSliderValue(i.Position))
					local ok, err = pcall(callback, math.round(currentValue))
					if not ok then warn("[NexusUI] Slider callback error: " .. tostring(err)) end
				end
			end)

			UserInputService.InputChanged:Connect(function(i)
				if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement
					or i.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(GetSliderValue(i.Position))
					local ok, err = pcall(callback, math.round(currentValue))
					if not ok then warn("[NexusUI] Slider callback error: " .. tostring(err)) end
				end
			end)

			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1
					or i.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = false
					FastTween(knob, { Size = UDim2.new(0, 20, 0, 20) }, 0.1)
				end
			end)

			local SliderAPI = {}
			function SliderAPI:Set(val) UpdateSlider(val) end
			function SliderAPI:Get() return math.round(currentValue) end

			return SliderAPI
		end

		-- ════════════════════════════════════════
		--   TEXTBOX
		-- ════════════════════════════════════════
		function TabAPI:AddTextBox(options)
			options = options or {}
			local name      = options.Name      or "TextBox"
			local placeholder = options.Placeholder or "Enter text..."
			local default   = options.Default   or ""
			local maxChars  = options.MaxChars  or 100
			local callback  = options.Callback  or function() end
			local color     = options.Color     or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 66), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 8, 8, 12, 12)

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, 0, 0, 20), Parent = container })

			local inputBg = MakeFrame({ Size = UDim2.new(1, 0, 0, 30), Color = Theme.SurfaceHigh, Parent = container })
			inputBg.Position = UDim2.new(0, 0, 0, 26)
			AddCorner(inputBg, 8)
			AddStroke(inputBg, Theme.SurfaceBorder, 1)

			local textBox = Instance.new("TextBox")
			textBox.PlaceholderText = placeholder
			textBox.PlaceholderColor3 = Theme.TextMuted
			textBox.Text = default
			textBox.TextColor3 = Theme.TextPrimary
			textBox.BackgroundTransparency = 1
			textBox.BorderSizePixel = 0
			textBox.Font = Enum.Font.Gotham
			textBox.TextSize = 13
			textBox.Size = UDim2.new(1, -16, 1, 0)
			textBox.Position = UDim2.new(0, 8, 0, 0)
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.ClearTextOnFocus = false
			textBox.MaxVisibleGraphemes = maxChars
			textBox.Parent = inputBg

			-- Focus glow
			textBox.Focused:Connect(function()
				FastTween(inputBg, { BackgroundColor3 = Theme.SurfaceBorder }, 0.2)
				FastTween(inputBg:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke"), { Color = color }, 0.2)
			end)
			textBox.FocusLost:Connect(function(enter)
				FastTween(inputBg, { BackgroundColor3 = Theme.SurfaceHigh }, 0.2)
				if enter then
					local ok, err = pcall(callback, textBox.Text)
					if not ok then warn("[NexusUI] TextBox callback error: " .. tostring(err)) end
				end
			end)

			local TBApi = {}
			function TBApi:Get() return textBox.Text end
			function TBApi:Set(t) textBox.Text = t end

			return TBApi
		end

		-- ════════════════════════════════════════
		--   DROPDOWN
		-- ════════════════════════════════════════
		function TabAPI:AddDropdown(options)
			options = options or {}
			local name     = options.Name     or "Dropdown"
			local items    = options.Items    or {"Option 1", "Option 2"}
			local default  = options.Default  or items[1]
			local callback = options.Callback or function() end
			local color    = options.Color    or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 44), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(0.4, 0, 1, 0), Parent = container })

			local selectedValue = default
			local isOpen = false

			-- Dropdown button
			local dropBtn = MakeButton({
				Text = selectedValue .. "  ▾",
				TextSize = 12, Font = Enum.Font.GothamSemibold,
				Color = Theme.SurfaceHigh,
				Size = UDim2.new(0.55, 0, 0, 30),
				Parent = container,
			})
			dropBtn.Position = UDim2.new(0.45, 0, 0.5, -15)
			dropBtn.TextXAlignment = Enum.TextXAlignment.Center
			AddCorner(dropBtn, 8)
			AddStroke(dropBtn, Theme.SurfaceBorder, 1)

			-- Dropdown list (portal above page)
			local dropList = MakeFrame({
				Size = UDim2.new(0, 0, 0, 0),
				Color = Theme.Surface,
				Parent = page,
			})
			dropList.ZIndex = 10
			dropList.ClipsDescendants = true
			dropList.Visible = false
			AddCorner(dropList, 10)
			AddStroke(dropList, Theme.SurfaceBorder, 1)

			local dropLayout = Instance.new("UIListLayout")
			dropLayout.FillDirection = Enum.FillDirection.Vertical
			dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
			dropLayout.Parent = dropList
			AddPadding(dropList, 4, 4, 6, 6)

			-- Populate items
			for _, item in ipairs(items) do
				local itemBtn = MakeButton({
					Text = item, TextSize = 12,
					Color = Color3.new(0,0,0),
					Size = UDim2.new(1, 0, 0, 30),
					Parent = dropList,
				})
				itemBtn.BackgroundTransparency = 1
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				AddCorner(itemBtn, 6)
				AddPadding(itemBtn, 0, 0, 8, 8)

				itemBtn.MouseEnter:Connect(function()
					FastTween(itemBtn, { BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHigh }, 0.1)
				end)
				itemBtn.MouseLeave:Connect(function()
					FastTween(itemBtn, { BackgroundTransparency = 1 }, 0.1)
				end)

				itemBtn.MouseButton1Click:Connect(function()
					selectedValue = item
					dropBtn.Text = item .. "  ▾"
					isOpen = false
					dropList.Visible = false
					local ok, err = pcall(callback, item)
					if not ok then warn("[NexusUI] Dropdown callback error: " .. tostring(err)) end
				end)
			end

			-- Toggle dropdown
			dropBtn.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				if isOpen then
					local itemCount = #items
					local listH = math.min(itemCount * 34 + 10, 180)
					dropList.Visible = true
					dropList.Size = UDim2.new(0.55, 0, 0, listH)
					dropList.Position = UDim2.new(0.45, 0, 1, 4)
					dropBtn.Text = selectedValue .. "  ▴"
				else
					dropList.Visible = false
					dropBtn.Text = selectedValue .. "  ▾"
				end
			end)

			local DropAPI = {}
			function DropAPI:Get() return selectedValue end
			function DropAPI:Set(val)
				selectedValue = val
				dropBtn.Text = val .. "  ▾"
			end
			function DropAPI:Refresh(newItems)
				for _, c in pairs(dropList:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				items = newItems
			end

			return DropAPI
		end

		-- ════════════════════════════════════════
		--   KEYBIND
		-- ════════════════════════════════════════
		function TabAPI:AddKeybind(options)
			options = options or {}
			local name     = options.Name     or "Keybind"
			local default  = options.Default  or Enum.KeyCode.F
			local callback = options.Callback or function() end

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 44), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(0.6, 0, 1, 0), Parent = container })

			local currentKey = default
			local listening = false

			local keyBtn = MakeButton({
				Text = "[" .. tostring(default.Name) .. "]",
				TextSize = 12, Font = Enum.Font.GothamBold,
				Color = Theme.SurfaceHigh,
				Size = UDim2.new(0, 90, 0, 28),
				Parent = container,
			})
			keyBtn.Position = UDim2.new(1, -90, 0.5, -14)
			AddCorner(keyBtn, 8)
			AddStroke(keyBtn, Theme.SurfaceBorder, 1)

			keyBtn.MouseButton1Click:Connect(function()
				listening = true
				keyBtn.Text = "[ ... ]"
				FastTween(keyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
			end)

			UserInputService.InputBegan:Connect(function(i, gpe)
				if gpe then return end
				if listening and i.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					currentKey = i.KeyCode
					keyBtn.Text = "[" .. tostring(i.KeyCode.Name) .. "]"
					FastTween(keyBtn, { BackgroundColor3 = Theme.SurfaceHigh }, 0.2)
				elseif not listening and i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == currentKey then
					local ok, err = pcall(callback)
					if not ok then warn("[NexusUI] Keybind callback error: " .. tostring(err)) end
				end
			end)

			local KBApi = {}
			function KBApi:Get() return currentKey end
			function KBApi:Set(key) currentKey = key; keyBtn.Text = "[" .. tostring(key.Name) .. "]" end

			return KBApi
		end

		-- ════════════════════════════════════════
		--   COLOR PICKER (simplified)
		-- ════════════════════════════════════════
		function TabAPI:AddColorPicker(options)
			options = options or {}
			local name     = options.Name     or "Color"
			local default  = options.Default  or Color3.fromRGB(138, 80, 255)
			local callback = options.Callback or function() end

			local presets = {
				Color3.fromRGB(255, 80, 100),
				Color3.fromRGB(255, 160, 60),
				Color3.fromRGB(255, 220, 60),
				Color3.fromRGB(80, 220, 140),
				Color3.fromRGB(60, 180, 255),
				Color3.fromRGB(138, 80, 255),
				Color3.fromRGB(255, 100, 200),
				Color3.fromRGB(255, 255, 255),
			}

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 56), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(0.35, 0, 0.5, 0), Parent = container })

			-- Current color preview
			local preview = MakeFrame({ Size = UDim2.new(0, 28, 0, 28), Color = default, Parent = container })
			preview.Position = UDim2.new(0.35, 0, 0.5, -14)
			AddCorner(preview, 8)
			AddStroke(preview, Theme.SurfaceBorder, 1)

			-- Presets
			local presetsHolder = MakeFrame({ Size = UDim2.new(0, 180, 0, 28), Color = Color3.new(), Parent = container })
			presetsHolder.BackgroundTransparency = 1
			presetsHolder.Position = UDim2.new(0.43, 0, 0.5, -14)

			local presetsLayout = Instance.new("UIListLayout")
			presetsLayout.FillDirection = Enum.FillDirection.Horizontal
			presetsLayout.Padding = UDim.new(0, 4)
			presetsLayout.Parent = presetsHolder

			local selectedColor = default

			for _, col in ipairs(presets) do
				local swatch = MakeButton({ Text = "", Color = col, Size = UDim2.new(0, 22, 0, 22), Parent = presetsHolder })
				AddCorner(swatch, 6)
				swatch.MouseButton1Click:Connect(function()
					selectedColor = col
					FastTween(preview, { BackgroundColor3 = col }, 0.2)
					local ok, err = pcall(callback, col)
					if not ok then warn("[NexusUI] ColorPicker callback error: " .. tostring(err)) end
				end)
			end

			local CPApi = {}
			function CPApi:Get() return selectedColor end
			function CPApi:Set(col) selectedColor = col; preview.BackgroundColor3 = col end

			return CPApi
		end

		-- ════════════════════════════════════════
		--   PROGRESS BAR
		-- ════════════════════════════════════════
		function TabAPI:AddProgressBar(options)
			options = options or {}
			local name  = options.Name  or "Progress"
			local value = options.Value or 0
			local color = options.Color or Theme.Accent

			local container = MakeFrame({ Size = UDim2.new(1, 0, 0, 48), Color = Theme.Surface, Parent = page })
			AddCorner(container, 10)
			AddStroke(container, Theme.SurfaceBorder, 1)
			AddPadding(container, 0, 0, 12, 12)

			local row = MakeFrame({ Size = UDim2.new(1, 0, 0, 20), Color = Color3.new(), Parent = container })
			row.BackgroundTransparency = 1

			MakeLabel({ Text = name, TextSize = 13, Font = Enum.Font.GothamBold,
				Size = UDim2.new(0.7, 0, 1, 0), Parent = row })

			local valLbl = MakeLabel({ Text = tostring(value) .. "%", TextSize = 13, Font = Enum.Font.GothamBold,
				TextColor = color, Size = UDim2.new(0.3, 0, 1, 0),
				XAlign = Enum.TextXAlignment.Right, Parent = row })

			local trackBg = MakeFrame({ Size = UDim2.new(1, 0, 0, 8), Color = Theme.SurfaceHigh, Parent = container })
			trackBg.Position = UDim2.new(0, 0, 0, 30)
			AddCorner(trackBg, 4)

			local fill = MakeFrame({ Size = UDim2.new(value/100, 0, 1, 0), Color = color, Parent = trackBg })
			AddCorner(fill, 4)

			local PBApi = {}
			function PBApi:Set(val)
				val = math.clamp(val, 0, 100)
				FastTween(fill, { Size = UDim2.new(val/100, 0, 1, 0) }, 0.3)
				valLbl.Text = tostring(math.round(val)) .. "%"
			end
			function PBApi:Get() return tonumber(valLbl.Text:gsub("%%", "")) end

			return PBApi
		end

		return TabAPI
	end

	return WindowObject
end

-- ══════════════════════════════════════════════
--              RETURN LIBRARY
-- ══════════════════════════════════════════════
return NexusUI