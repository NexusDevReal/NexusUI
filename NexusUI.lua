--[[
NexusUI v1.8  — Roblox Luau UI Library
See changelog and usage at the bottom of this file.
]]--

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local HttpService=game:GetService("HttpService")
local LocalPlayer=Players.LocalPlayer

local T={
	BG=Color3.fromRGB(11,8,24),Surface=Color3.fromRGB(20,15,40),
	SurfaceHi=Color3.fromRGB(30,23,56),SurfaceHi2=Color3.fromRGB(42,32,72),
	SurfaceHi3=Color3.fromRGB(54,42,90),Border=Color3.fromRGB(58,44,96),
	BorderBri=Color3.fromRGB(90,68,148),BorderGlow=Color3.fromRGB(110,80,200),
	Accent=Color3.fromRGB(138,76,255),AccentHi=Color3.fromRGB(170,118,255),
	AccentLo=Color3.fromRGB(94,48,205),AccentDeep=Color3.fromRGB(62,30,148),
	TxtMain=Color3.fromRGB(242,236,255),TxtSub=Color3.fromRGB(158,140,202),
	TxtMute=Color3.fromRGB(90,75,126),TxtOff=Color3.fromRGB(54,44,82),
	Green=Color3.fromRGB(68,214,132),Red=Color3.fromRGB(248,64,92),
	Yellow=Color3.fromRGB(252,188,52),Blue=Color3.fromRGB(52,172,254),
	TogOff=Color3.fromRGB(40,32,66),NotifBG=Color3.fromRGB(18,13,38),
	CardShine=Color3.fromRGB(255,255,255),White=Color3.fromRGB(255,255,255),Black=Color3.fromRGB(0,0,0),
}

local function FT(o,p,t) TweenService:Create(o,TweenInfo.new(t or .18,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play() end
local function ST(o,p,t) TweenService:Create(o,TweenInfo.new(t or .30,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end
local function LT(o,p,t) TweenService:Create(o,TweenInfo.new(t or .25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),p):Play() end
local function ET(o,p,t) TweenService:Create(o,TweenInfo.new(t or .36,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out),p):Play() end

local function Corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function Stroke(p,col,thick,trans) local s=Instance.new("UIStroke");s.Color=col or T.Border;s.Thickness=thick or 1;s.Transparency=trans or 0;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=p;return s end
local function Pad(p,top,bot,left,right) local u=Instance.new("UIPadding");u.PaddingTop=UDim.new(0,top or 8);u.PaddingBottom=UDim.new(0,bot or 8);u.PaddingLeft=UDim.new(0,left or 10);u.PaddingRight=UDim.new(0,right or 10);u.Parent=p;return u end
local function MkFrame(par,sz,pos,col,clip,zi) local f=Instance.new("Frame");f.Size=sz or UDim2.new(1,0,0,40);f.Position=pos or UDim2.new(0,0,0,0);f.BackgroundColor3=col or T.Surface;f.BorderSizePixel=0;f.ClipsDescendants=clip or false;if zi then f.ZIndex=zi end;f.Parent=par;return f end
local function MkLabel(par,text,sz,col,font,xa,ya,wrap) local l=Instance.new("TextLabel");l.Text=text or "";l.TextSize=sz or 13;l.TextColor3=col or T.TxtMain;l.Font=font or Enum.Font.GothamBold;l.BackgroundTransparency=1;l.BorderSizePixel=0;l.Size=UDim2.new(1,0,1,0);l.TextXAlignment=xa or Enum.TextXAlignment.Left;l.TextYAlignment=ya or Enum.TextYAlignment.Center;l.TextWrapped=wrap or false;l.RichText=false;l.Parent=par;return l end
local function MkButton(par,text,sz,col,tcol,font) local b=Instance.new("TextButton");b.Text=text or "";b.TextSize=sz or 13;b.TextColor3=tcol or T.TxtMain;b.BackgroundColor3=col or T.SurfaceHi;b.Font=font or Enum.Font.GothamBold;b.BorderSizePixel=0;b.AutoButtonColor=false;b.Size=UDim2.new(1,0,1,0);b.Parent=par;return b end
local function CardShine(c) local s=MkFrame(c,UDim2.new(1,-6,0,1),UDim2.new(0,3,0,1),T.CardShine);s.BackgroundTransparency=.88;s.ZIndex=(c.ZIndex or 4)+1;Corner(s,2);local g=Instance.new("UIGradient");g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.12,.88),NumberSequenceKeypoint.new(.5,.82),NumberSequenceKeypoint.new(.88,.88),NumberSequenceKeypoint.new(1,1)});g.Parent=s;return s end

-- ── MkIcon v1.8 ──────────────────────────────────────────────
local _SCALE_MAP={Fit=Enum.ScaleType.Fit,Crop=Enum.ScaleType.Crop,Stretch=Enum.ScaleType.Stretch}
local function _ResolveIcon(icon)
	if type(icon)~="string" or icon=="" then return false,nil end
	if icon:match("^rbxassetid://%d+$") then return true,icon end
	if icon:match("^rbxthumb://") then return true,icon end
	if icon:match("^rbxgameasset://") then return true,icon end
	if icon:match("^https?://") then return true,icon end
	if icon:match("^%d+$") then return true,"rbxassetid://"..icon end
	return false,nil
end
local function _IconArgs(ia,ts,tc,is,zi)
	if type(ia)=="table" then local o=ia;return tostring(o.Icon or ""),o.Size or UDim2.new(.72,0,.72,0),o.Color or T.White,o.NoTint or false,o.Trans or 0,o.Scale or "Fit",o.TextSize or 18,o.Font or Enum.Font.GothamBold,o.ZIndex or 4 end
	return tostring(ia or ""),is or UDim2.new(.72,0,.72,0),tc or T.White,false,0,"Fit",ts or 18,Enum.Font.GothamBold,zi or 4
end
local function MkIcon(par,ia,ts,tc,is,zi)
	local icon,size,color,noTint,trans,scaleKey,tSize,font,zIndex=_IconArgs(ia,ts,tc,is,zi)
	local isImg,url=_ResolveIcon(icon)
	if isImg then
		local img=Instance.new("ImageLabel");img.Image=url;img.BackgroundTransparency=1;img.BorderSizePixel=0
		img.Size=size;img.AnchorPoint=Vector2.new(.5,.5);img.Position=UDim2.new(.5,0,.5,0)
		img.ImageColor3=noTint and T.White or color;img.ImageTransparency=trans
		img.ScaleType=_SCALE_MAP[scaleKey] or Enum.ScaleType.Fit;img.ZIndex=zIndex;img.Parent=par
		rawset(img,"IsImage",true);return img
	else
		local lbl=Instance.new("TextLabel");lbl.Text=icon;lbl.TextSize=tSize;lbl.TextColor3=color
		lbl.Font=font;lbl.BackgroundTransparency=1;lbl.BorderSizePixel=0;lbl.Size=UDim2.new(1,0,1,0)
		lbl.TextXAlignment=Enum.TextXAlignment.Center;lbl.TextYAlignment=Enum.TextYAlignment.Center
		lbl.ZIndex=zIndex;lbl.Parent=par;rawset(lbl,"IsImage",false);return lbl
	end
end

-- ── Drag ─────────────────────────────────────────────────────
local function MakeDraggable(win,handle)
	handle=handle or win
	local drag,dragIn,mS,fS=false,nil,nil,nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			drag=true;mS=i.Position;fS=win.Position
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
		end
	end)
	handle.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragIn=i end end)
	UserInputService.InputChanged:Connect(function(i) if i==dragIn and drag then local d=i.Position-mS;win.Position=UDim2.new(fS.X.Scale,fS.X.Offset+d.X,fS.Y.Scale,fS.Y.Offset+d.Y) end end)
end

-- ── Config ───────────────────────────────────────────────────
local _CR={}
local function _Reg(wn,id,g,s,t) if not id or id=="" then return end;if not _CR[wn] then _CR[wn]={} end;_CR[wn][id]={Get=g,Set=s,Type=t} end
local function _EC(c) return{r=math.round(c.R*255),g=math.round(c.G*255),b=math.round(c.B*255)} end
local function _DC(t) return Color3.fromRGB(t.r,t.g,t.b) end

-- ── Shared dropdown tracker ───────────────────────────────────
local _ActiveDrop=nil
local function _RegDrop(fn) if _ActiveDrop and _ActiveDrop~=fn then pcall(_ActiveDrop) end;_ActiveDrop=fn end
local function _ClrDrop(fn) if _ActiveDrop==fn then _ActiveDrop=nil end end

-- ── Notifications ────────────────────────────────────────────
local _NH=nil
local function _InitNH(sg)
	if _NH then _NH:Destroy() end
	_NH=Instance.new("Frame");_NH.Name="NexusNotifHolder";_NH.BackgroundTransparency=1;_NH.BorderSizePixel=0
	_NH.Size=UDim2.new(0,296,1,-20);_NH.Position=UDim2.new(1,-304,0,10);_NH.ZIndex=200;_NH.Parent=sg
	local ul=Instance.new("UIListLayout");ul.FillDirection=Enum.FillDirection.Vertical;ul.VerticalAlignment=Enum.VerticalAlignment.Bottom;ul.SortOrder=Enum.SortOrder.LayoutOrder;ul.Padding=UDim.new(0,8);ul.Parent=_NH
end

local NexusUI={}
NexusUI.__index=NexusUI

function NexusUI:Notify(opt)
	opt=opt or {};local title=opt.Title or "Notification";local desc=opt.Desc or "";local dur=opt.Duration or 4
	local icon=opt.Icon or "!";local accent=opt.Color or T.Accent
	if not _NH then return end
	local card=MkFrame(_NH,UDim2.new(1,0,0,74),UDim2.new(1,20,0,0),T.NotifBG)
	card.ZIndex=200;Corner(card,13);Stroke(card,accent,1,.25);CardShine(card)
	local eg=MkFrame(card,UDim2.new(0,3,1,0),nil,accent);eg.ZIndex=201;Corner(eg,3)
	local egG=Instance.new("UIGradient");egG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,accent),ColorSequenceKeypoint.new(1,T.AccentDeep)});egG.Rotation=90;egG.Parent=eg
	local icBox=MkFrame(card,UDim2.new(0,4,0,4),UDim2.new(0,30,.5,-2),T.SurfaceHi);icBox.ZIndex=202;Corner(icBox,11);Stroke(icBox,accent,1,.35)
	MkIcon(icBox,icon,15,accent,UDim2.new(.7,0,.7,0),203)
	local tl=Instance.new("TextLabel");tl.Text=title;tl.TextSize=13;tl.Font=Enum.Font.GothamBold;tl.TextColor3=T.TxtMain;tl.BackgroundTransparency=1;tl.BorderSizePixel=0;tl.Size=UDim2.new(1,-78,0,20);tl.Position=UDim2.new(0,58,0,12);tl.TextXAlignment=Enum.TextXAlignment.Left;tl.ZIndex=201;tl.Parent=card
	if desc~="" then local dl=Instance.new("TextLabel");dl.Text=desc;dl.TextSize=11;dl.Font=Enum.Font.Gotham;dl.TextColor3=T.TxtSub;dl.BackgroundTransparency=1;dl.BorderSizePixel=0;dl.Size=UDim2.new(1,-78,0,18);dl.Position=UDim2.new(0,58,0,34);dl.TextXAlignment=Enum.TextXAlignment.Left;dl.TextWrapped=true;dl.ZIndex=201;dl.Parent=card end
	local xB=Instance.new("TextButton");xB.Text="x";xB.TextSize=11;xB.Font=Enum.Font.GothamBold;xB.TextColor3=T.TxtMute;xB.BackgroundTransparency=1;xB.BorderSizePixel=0;xB.Size=UDim2.new(0,20,0,20);xB.Position=UDim2.new(1,-24,0,5);xB.ZIndex=202;xB.Parent=card
	xB.MouseEnter:Connect(function() FT(xB,{TextColor3=T.Red},.1) end);xB.MouseLeave:Connect(function() FT(xB,{TextColor3=T.TxtMute},.1) end)
	local pgBg=MkFrame(card,UDim2.new(1,-20,0,3),UDim2.new(0,10,1,-9),T.SurfaceHi);pgBg.ZIndex=201;Corner(pgBg,2)
	local pgFill=MkFrame(pgBg,UDim2.new(1,0,1,0),nil,accent);pgFill.ZIndex=202;Corner(pgFill,2);LT(pgFill,{Size=UDim2.new(0,0,1,0)},dur)
	FT(card,{Position=UDim2.new(0,0,0,0)},.26)
	task.delay(.05,function() if card and card.Parent then ST(icBox,{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,12,.5,-18)},.32) end end)
	local gone=false
	local function Dismiss() if gone then return end;gone=true;FT(card,{Position=UDim2.new(1,20,0,0),BackgroundTransparency=1},.2);task.wait(.22);card:Destroy() end
	xB.MouseButton1Click:Connect(Dismiss);task.delay(dur,Dismiss);return card
end

function NexusUI:CreateWindow(opt)
	opt=opt or {}
	local wTitle=opt.Title or "NexusUI";local wSub=opt.Subtitle or "v3.7";local wIcon=opt.Icon or "N"
	local wSize=opt.Size or UDim2.new(0,370,0,500);local wPos=opt.Position or UDim2.new(.5,-185,.5,-250)
	local wName=wTitle
	local sg=Instance.new("ScreenGui");sg.Name="NexusUI_"..wTitle;sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.DisplayOrder=999;sg.IgnoreGuiInset=true
	local ok=pcall(function() sg.Parent=game:GetService("CoreGui") end);if not ok then sg.Parent=LocalPlayer:WaitForChild("PlayerGui") end
	_InitNH(sg)

	-- Main window
	local win=MkFrame(sg,wSize,wPos,T.BG,false,2);Corner(win,16)
	local winS=Stroke(win,Color3.fromRGB(80,50,158),1.5)
	local tglow=MkFrame(win,UDim2.new(1,-6,0,1),UDim2.new(0,3,0,0),Color3.fromRGB(148,96,255));tglow.BackgroundTransparency=.5;tglow.ZIndex=10
	win.BackgroundTransparency=1;win.Size=UDim2.new(0,wSize.X.Offset,0,wSize.Y.Offset*.88);win.Position=UDim2.new(wPos.X.Scale,wPos.X.Offset,wPos.Y.Scale,wPos.Y.Offset+22)
	task.defer(function() FT(win,{BackgroundTransparency=0,Size=wSize,Position=wPos},.32);FT(winS,{Color=Color3.fromRGB(100,62,195)},.4) end)

	-- Title bar
	local tBar=MkFrame(win,UDim2.new(1,0,0,62),nil,T.Surface);Corner(tBar,16);MkFrame(tBar,UDim2.new(1,0,0,16),UDim2.new(0,0,1,-16),T.Surface)
	local tbG=Instance.new("UIGradient");tbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(52,34,96)),ColorSequenceKeypoint.new(.5,Color3.fromRGB(34,24,66)),ColorSequenceKeypoint.new(1,T.Surface)});tbG.Rotation=90;tbG.Parent=tBar
	local tbSep=MkFrame(tBar,UDim2.new(1,-28,0,1),UDim2.new(0,14,1,-1),Color3.fromRGB(80,56,120));tbSep.BackgroundTransparency=.55;tbSep.ZIndex=5
	local sG=Instance.new("UIGradient");sG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.1,.55),NumberSequenceKeypoint.new(.9,.55),NumberSequenceKeypoint.new(1,1)});sG.Parent=tbSep
	MakeDraggable(win,tBar)

	-- Icon pill
	local iPill=MkFrame(tBar,UDim2.new(0,42,0,42),UDim2.new(0,12,.5,-21),T.AccentLo);Corner(iPill,13);Stroke(iPill,T.AccentHi,1.5,.2)
	local pSh=MkFrame(iPill,UDim2.new(1,-4,0,14),UDim2.new(0,2,0,2),T.White);pSh.BackgroundTransparency=.84;Corner(pSh,8)
	local pShG=Instance.new("UIGradient");pShG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.84),NumberSequenceKeypoint.new(.5,.76),NumberSequenceKeypoint.new(1,.84)});pShG.Parent=pSh
	local pGlow=MkFrame(tBar,UDim2.new(0,52,0,52),UDim2.new(0,7,.5,-26),T.Accent);pGlow.BackgroundTransparency=.82;Corner(pGlow,16);pGlow.ZIndex=2
	MkIcon(iPill,wIcon,20,T.White,UDim2.new(.72,0,.72,0),4)
	local titleL=MkLabel(tBar,wTitle,15,T.TxtMain,Enum.Font.GothamBold);titleL.Size=UDim2.new(1,-158,0,22);titleL.Position=UDim2.new(0,64,0,10)
	local vC=MkFrame(tBar,UDim2.new(0,0,0,18),UDim2.new(0,64,0,36),T.AccentDeep);vC.AutomaticSize=Enum.AutomaticSize.X;Corner(vC,6);Stroke(vC,T.Accent,1,.45)
	local vL=MkLabel(vC,wSub,10,T.AccentHi,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);vL.Size=UDim2.new(1,0,1,0);Pad(vC,0,0,8,8)

	-- Control buttons
	local function MkCtrl(xOff,col) local box=MkFrame(tBar,UDim2.new(0,28,0,28),UDim2.new(1,xOff,.5,-14),col);Corner(box,9);local bb=MkButton(box,"",0,T.Black,T.White);bb.BackgroundTransparency=1;bb.Size=UDim2.new(1,0,1,0);return box,bb end
	local cBox,cBB=MkCtrl(-38,T.Red);MkLabel(cBox,"x",12,T.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	cBB.MouseEnter:Connect(function() FT(cBox,{BackgroundColor3=Color3.fromRGB(255,44,72)},.12);ST(cBox,{Size=UDim2.new(0,30,0,30)},.14) end)
	cBB.MouseLeave:Connect(function() FT(cBox,{BackgroundColor3=T.Red},.12);FT(cBox,{Size=UDim2.new(0,28,0,28)},.12) end)
	cBB.MouseButton1Click:Connect(function() FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,0),BackgroundTransparency=1},.22);task.wait(.24);sg:Destroy() end)
	local mBox,mBB=MkCtrl(-70,T.SurfaceHi);Stroke(mBox,T.Border,1)
	local mLbl=MkLabel(mBox,"-",15,T.TxtSub,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center)
	mBB.MouseEnter:Connect(function() FT(mBox,{BackgroundColor3=T.SurfaceHi2},.12);ST(mBox,{Size=UDim2.new(0,30,0,30)},.14) end)
	mBB.MouseLeave:Connect(function() FT(mBox,{BackgroundColor3=T.SurfaceHi},.12);FT(mBox,{Size=UDim2.new(0,28,0,28)},.12) end)

	-- Body
	local body=MkFrame(win,UDim2.new(1,0,1,-62),UDim2.new(0,0,0,62),T.BG,true,2);Corner(body,16);MkFrame(body,UDim2.new(1,0,0,16),nil,T.BG)
	local vig=MkFrame(body,UDim2.new(1,0,1,0),nil,T.Black);vig.BackgroundTransparency=.92;vig.ZIndex=1
	local vigG=Instance.new("UIGradient");vigG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.75),NumberSequenceKeypoint.new(.15,1),NumberSequenceKeypoint.new(.85,1),NumberSequenceKeypoint.new(1,.75)});vigG.Parent=vig
	local botBar=MkFrame(win,UDim2.new(1,-6,0,4),UDim2.new(0,3,1,-4),Color3.fromRGB(78,52,142));botBar.BackgroundTransparency=.58;botBar.ZIndex=3;Corner(botBar,4)
	local bbG=Instance.new("UIGradient");bbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentDeep),ColorSequenceKeypoint.new(.5,T.Accent),ColorSequenceKeypoint.new(1,T.AccentDeep)});bbG.Parent=botBar

	-- Minimize
	local minimized=false
	mBB.MouseButton1Click:Connect(function()
		minimized=not minimized
		if minimized then FT(win,{Size=UDim2.new(0,wSize.X.Offset,0,62)},.28);mLbl.Text="+"
		else FT(win,{Size=wSize},.28);mLbl.Text="-" end
	end)

	-- Tab bar with sliding indicator
	local tabBar=MkFrame(body,UDim2.new(1,-20,0,36),UDim2.new(0,10,0,14),T.SurfaceHi,false,3);Corner(tabBar,11);Stroke(tabBar,T.Border,1)
	local tabInd=MkFrame(tabBar,UDim2.new(0,40,0,28),UDim2.new(0,4,.5,-14),T.Accent);tabInd.ZIndex=3;Corner(tabInd,8)
	local tiG=Instance.new("UIGradient");tiG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,T.AccentLo)});tiG.Rotation=90;tiG.Parent=tabInd
	local tabLL=Instance.new("UIListLayout");tabLL.FillDirection=Enum.FillDirection.Horizontal;tabLL.VerticalAlignment=Enum.VerticalAlignment.Center;tabLL.SortOrder=Enum.SortOrder.LayoutOrder;tabLL.Padding=UDim.new(0,4);tabLL.Parent=tabBar;Pad(tabBar,3,3,4,4)

	-- Content area with UICorner
	local contentArea=MkFrame(body,UDim2.new(1,-2,1,-70),UDim2.new(0,1,0,68),T.BG,false,3);Corner(contentArea,12)
	local caFill=MkFrame(contentArea,UDim2.new(1,0,0,12),nil,T.BG);caFill.ZIndex=3
	local dropOverlay=MkFrame(body,UDim2.new(1,0,1,-68),UDim2.new(0,0,0,68),T.Black,false,50);dropOverlay.BackgroundTransparency=1

	local tabs={};local activeTab=nil
	local WinAPI={}
	function WinAPI:Notify(o) return NexusUI:Notify(o) end
	function WinAPI:SaveConfig(name)
		name=name or "default";local reg=_CR[wName];if not reg then warn("[NexusUI] No elements registered.");return end
		local data={};for id,entry in reg do local v=entry.Get();data[id]=entry.Type=="color" and _EC(v) or v end
		local json=HttpService:JSONEncode(data);local path="NexusUI_"..wName.."_"..name..".json"
		local ok2=pcall(function() writefile(path,json) end)
		if ok2 then NexusUI:Notify({Title="Config Saved",Desc=path,Duration=3,Icon="OK",Color=T.Green})
		else print("[NexusUI] Config '"..name.."':\n"..json);NexusUI:Notify({Title="Config (no writefile)",Desc="Printed to output",Duration=3,Icon="!",Color=T.Yellow}) end
	end
	function WinAPI:LoadConfig(name)
		name=name or "default";local reg=_CR[wName];if not reg then warn("[NexusUI] No elements registered.");return end
		local path="NexusUI_"..wName.."_"..name..".json"
		local ok2,json=pcall(function() return readfile(path) end)
		if not ok2 or not json then NexusUI:Notify({Title="Config Not Found",Desc=path,Duration=3,Icon="!",Color=T.Red});return end
		for id,val in HttpService:JSONDecode(json) do if reg[id] then pcall(function() reg[id].Set(reg[id].Type=="color" and _DC(val) or val) end) end end
		NexusUI:Notify({Title="Config Loaded",Desc=path,Duration=3,Icon="OK",Color=T.Green})
	end

	-- AddTab
	function WinAPI:AddTab(tabName)
		local tBtn=Instance.new("TextButton");tBtn.Text=tabName;tBtn.TextSize=12;tBtn.Font=Enum.Font.GothamSemibold;tBtn.TextColor3=T.TxtMute;tBtn.BackgroundColor3=T.Black;tBtn.BackgroundTransparency=1;tBtn.BorderSizePixel=0;tBtn.AutoButtonColor=false;tBtn.AutomaticSize=Enum.AutomaticSize.X;tBtn.Size=UDim2.new(0,10,1,0);tBtn.ZIndex=5;tBtn.Parent=tabBar;Pad(tBtn,0,0,10,10);Corner(tBtn,8)
		local page=Instance.new("ScrollingFrame");page.BackgroundTransparency=1;page.BorderSizePixel=0;page.Size=UDim2.new(1,0,1,0);page.CanvasSize=UDim2.new(0,0,0,0);page.AutomaticCanvasSize=Enum.AutomaticSize.Y;page.ScrollBarThickness=3;page.ScrollBarImageColor3=T.Accent;page.ScrollBarImageTransparency=.5;page.ScrollingDirection=Enum.ScrollingDirection.Y;page.Visible=false;page.ZIndex=3;page.Parent=contentArea
		local ll=Instance.new("UIListLayout");ll.FillDirection=Enum.FillDirection.Vertical;ll.SortOrder=Enum.SortOrder.LayoutOrder;ll.Padding=UDim.new(0,7);ll.Parent=page;Pad(page,10,18,10,10)
		local tabData={Btn=tBtn,Page=page};table.insert(tabs,tabData)
		local function Activate()
			if activeTab then FT(activeTab.Btn,{TextColor3=T.TxtMute},.16);activeTab.Page.Visible=false end
			activeTab=tabData;FT(tBtn,{TextColor3=T.White},.16);page.Visible=true
			task.defer(function()
				if not tBtn.Parent then return end
				local rx=tBtn.AbsolutePosition.X-tabBar.AbsolutePosition.X-4
				FT(tabInd,{Size=UDim2.new(0,tBtn.AbsoluteSize.X,0,28),Position=UDim2.new(0,rx,.5,-14)},.22)
			end)
		end
		tBtn.MouseButton1Click:Connect(Activate)
		if #tabs==1 then task.defer(Activate) end

		local API={}
		local function Card(h,semi)
			local c=MkFrame(page,UDim2.new(1,0,0,h),nil,T.Surface)
			if semi then c.BackgroundTransparency=.22 end
			c.ZIndex=4;Corner(c,12);Stroke(c,T.Border,1);Pad(c,0,0,14,14);CardShine(c);return c
		end

		function API:AddSection(name)
			local w=MkFrame(page,UDim2.new(1,0,0,26),nil,T.Black);w.BackgroundTransparency=1;w.ZIndex=4
			local function FL(xs,xo,ws) local l=MkFrame(w,UDim2.new(ws,-4,0,1),UDim2.new(xs,xo,.5,0),T.BorderBri);l.ZIndex=4;local g=Instance.new("UIGradient");g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,xs==0 and 1 or .4),NumberSequenceKeypoint.new(.5,.4),NumberSequenceKeypoint.new(1,xs==0 and .4 or 1)});g.Parent=l end
			FL(0,0,.28);FL(.72,0,.28)
			local sp="";for i=1,#name do sp=sp..name:sub(i,i);if i<#name then sp=sp.." " end end
			local sl=MkLabel(w,sp:upper(),9,T.TxtMute,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);sl.Size=UDim2.new(.44,0,1,0);sl.Position=UDim2.new(.28,0,0,0);sl.ZIndex=4
		end

		function API:AddSeparator()
			local s=MkFrame(page,UDim2.new(1,-24,0,1),UDim2.new(0,12,0,0),T.Border);s.ZIndex=4
			local sg2=Instance.new("UIGradient");sg2.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.1,0),NumberSequenceKeypoint.new(.9,0),NumberSequenceKeypoint.new(1,1)});sg2.Parent=s
		end

		function API:AddLabel(opt)
			opt=type(opt)=="string" and {Text=opt} or (opt or {})
			local text=opt.Text or "Label";local color=opt.Color or T.TxtSub;local align=opt.Align or "Left";local size=opt.TextSize or 13
			local font=opt.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
			local xa=align=="Center" and Enum.TextXAlignment.Center or align=="Right" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
			local wrap=MkFrame(page,UDim2.new(1,0,0,26),nil,T.Black);wrap.BackgroundTransparency=1;wrap.ZIndex=4
			local lbl=MkLabel(wrap,text,size,color,font,xa,Enum.TextYAlignment.Center,true);lbl.Size=UDim2.new(1,-20,1,0);lbl.Position=UDim2.new(0,10,0,0);lbl.ZIndex=5
			local L={};function L:SetText(t) lbl.Text=t end;function L:SetColor(c) lbl.TextColor3=c end;return L
		end

		function API:AddParagraph(opt)
			opt=opt or {};local title=opt.Title or "Paragraph";local content=opt.Content or "";local color=opt.Color or T.TxtSub
			local lines=math.max(1,math.ceil(#content/40));local cardH=math.max(14+22+8+lines*18+14,60)
			local card=MkFrame(page,UDim2.new(1,0,0,cardH),nil,T.Surface);card.BackgroundTransparency=.22;card.ZIndex=4;Corner(card,12);Stroke(card,T.Border,1,.2);Pad(card,10,10,14,14);CardShine(card)
			local strip=MkFrame(card,UDim2.new(0,3,1,-20),UDim2.new(0,0,0,10),T.Accent);strip.ZIndex=5;Corner(strip,3)
			local sG2=Instance.new("UIGradient");sG2.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,T.AccentLo)});sG2.Rotation=90;sG2.Parent=strip
			local tl=MkLabel(card,title,13,T.TxtMain,Enum.Font.GothamBold);tl.Size=UDim2.new(1,-10,0,22);tl.ZIndex=5
			local cl=Instance.new("TextLabel");cl.Text=content;cl.TextSize=12;cl.Font=Enum.Font.Gotham;cl.TextColor3=color;cl.BackgroundTransparency=1;cl.BorderSizePixel=0;cl.Size=UDim2.new(1,-10,0,cardH-46);cl.Position=UDim2.new(0,0,0,28);cl.TextXAlignment=Enum.TextXAlignment.Left;cl.TextYAlignment=Enum.TextYAlignment.Top;cl.TextWrapped=true;cl.ZIndex=5;cl.Parent=card
			local P={};function P:SetTitle(t) tl.Text=t end;function P:SetContent(c) cl.Text=c end;return P
		end

		function API:AddButton(opt)
			opt=opt or {};local name=opt.Name or "Button";local desc=opt.Desc or "";local icon=opt.Icon or "";local cb=opt.Callback or function() end;local color=opt.Color or T.Accent
			local cardH=desc~="" and 60 or 48;local card=Card(cardH)
			local iOff=0
			if icon~="" then
				iOff=40;local icB=MkFrame(card,UDim2.new(0,30,0,30),UDim2.new(0,0,.5,-15),T.AccentDeep);icB.ZIndex=5;Corner(icB,9);Stroke(icB,color,1,.3)
				MkIcon(icB,icon,15,color,UDim2.new(.72,0,.72,0),6)
			end
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(1,-(iOff+92),0,desc~="" and 20 or 32);nl.Position=UDim2.new(0,iOff,0,desc~="" and 5 or 0);nl.TextYAlignment=Enum.TextYAlignment.Center;nl.ZIndex=5
			if desc~="" then local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham);dl.Size=UDim2.new(1,-(iOff+92),0,16);dl.Position=UDim2.new(0,iOff,0,28);dl.ZIndex=5 end
			local pW=78;local aP=MkFrame(card,UDim2.new(0,pW,0,32),UDim2.new(1,-pW,.5,-16),color);aP.ZIndex=5;Corner(aP,10)
			local aGrad=Instance.new("UIGradient");aGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)});aGrad.Rotation=95;aGrad.Parent=aP
			local pSh=MkFrame(aP,UDim2.new(1,-6,0,10),UDim2.new(0,3,0,2),T.White);pSh.BackgroundTransparency=.82;pSh.ZIndex=6;Corner(pSh,4)
			local psG=Instance.new("UIGradient");psG.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.3,.82),NumberSequenceKeypoint.new(.7,.82),NumberSequenceKeypoint.new(1,1)});psG.Parent=pSh
			local aLbl=MkLabel(aP,"Run",12,T.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);aLbl.ZIndex=7
			local aBB=MkButton(aP,"",0,T.Black,T.White);aBB.BackgroundTransparency=1;aBB.Size=UDim2.new(1,0,1,0);aBB.ZIndex=8
			local running=false
			local function DoRun()
				if running then return end;running=true;FT(aP,{Size=UDim2.new(0,pW-6,0,26)},.08);task.wait(.09);ST(aP,{Size=UDim2.new(0,pW,0,32)},.2)
				aLbl.Text="Done";FT(aLbl,{TextColor3=T.Green},.1);task.delay(.85,function() if aLbl and aLbl.Parent then aLbl.Text="Run";FT(aLbl,{TextColor3=T.White},.15) end end)
				pcall(cb);running=false
			end
			aBB.MouseEnter:Connect(function() aGrad.Enabled=false;FT(aP,{BackgroundColor3=T.AccentHi},.12) end);aBB.MouseLeave:Connect(function() aGrad.Enabled=true;FT(aP,{BackgroundColor3=color},.12) end);aBB.MouseButton1Click:Connect(DoRun)
			local cBB=MkButton(card,"",0,T.Black,T.White);cBB.BackgroundTransparency=1;cBB.Size=UDim2.new(1,-(pW+8),1,0);cBB.ZIndex=5
			cBB.MouseEnter:Connect(function() FT(card,{BackgroundColor3=T.SurfaceHi},.14) end);cBB.MouseLeave:Connect(function() FT(card,{BackgroundColor3=T.Surface},.14) end);cBB.MouseButton1Click:Connect(DoRun)
		end

		function API:AddToggle(opt)
			opt=opt or {};local name=opt.Name or "Toggle";local desc=opt.Desc or "";local def=opt.Default or false;local cb=opt.Callback or function() end;local color=opt.Color or T.Accent;local id=opt.Id or ""
			local cardH=desc~="" and 58 or 46;local card=Card(cardH)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(1,-70,0,22);nl.Position=UDim2.new(0,0,0,desc~="" and 4 or 0);nl.TextYAlignment=Enum.TextYAlignment.Center;nl.ZIndex=5
			if desc~="" then local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham);dl.Size=UDim2.new(1,-70,0,16);dl.Position=UDim2.new(0,0,0,28);dl.ZIndex=5 end
			local track=MkFrame(card,UDim2.new(0,52,0,28),UDim2.new(1,-52,.5,-14),T.TogOff);track.ZIndex=5;Corner(track,14);Stroke(track,T.Border,1)
			local tIn=MkFrame(track,UDim2.new(1,0,.5,0),UDim2.new(0,0,.5,0),T.Black);tIn.BackgroundTransparency=.88;tIn.ZIndex=5
			local thumb=MkFrame(track,UDim2.new(0,22,0,22),UDim2.new(0,3,.5,-11),T.White);thumb.ZIndex=6;Corner(thumb,11);local tStr=Stroke(thumb,T.Border,1.5)
			local tSh=MkFrame(thumb,UDim2.new(1,-4,0,8),UDim2.new(0,2,0,2),T.White);tSh.BackgroundTransparency=.82;tSh.ZIndex=7;Corner(tSh,4)
			local state=def;local busy=false
			local function Refresh(anim)
				if state then
					if anim then FT(track,{BackgroundColor3=color},.2);ST(thumb,{Position=UDim2.new(0,27,.5,-11)},.24);FT(tStr,{Color=color,Thickness=2},.2);FT(thumb,{Size=UDim2.new(0,18,0,22)},.06);task.delay(.07,function() if thumb and thumb.Parent then ET(thumb,{Size=UDim2.new(0,22,0,22)},.28) end end)
					else track.BackgroundColor3=color;thumb.Position=UDim2.new(0,27,.5,-11);tStr.Color=color;tStr.Thickness=2 end
				else
					if anim then FT(track,{BackgroundColor3=T.TogOff},.2);ST(thumb,{Position=UDim2.new(0,3,.5,-11)},.24);FT(tStr,{Color=T.Border,Thickness=1.5},.2);FT(thumb,{Size=UDim2.new(0,18,0,22)},.06);task.delay(.07,function() if thumb and thumb.Parent then ET(thumb,{Size=UDim2.new(0,22,0,22)},.28) end end)
					else track.BackgroundColor3=T.TogOff;thumb.Position=UDim2.new(0,3,.5,-11);tStr.Color=T.Border;tStr.Thickness=1.5 end
				end
			end
			Refresh(false)
			local function Toggle() if busy then return end;busy=true;state=not state;Refresh(true);pcall(cb,state);task.wait(.32);busy=false end
			track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Toggle() end end)
			local Tog={};function Tog:Set(v) state=v;Refresh(true) end;function Tog:Get() return state end
			_Reg(wName,id,function() return state end,function(v) state=v;Refresh(true) end,"bool");return Tog
		end

		function API:AddSlider(opt)
			opt=opt or {};local name=opt.Name or "Slider";local desc=opt.Desc or "";local min=opt.Min or 0;local max=opt.Max or 100;local def=opt.Default or min;local sfx=opt.Suffix or "";local cb=opt.Callback or function() end;local color=opt.Color or T.Accent;local id=opt.Id or ""
			local cardH=desc~="" and 76 or 64;local card=Card(cardH)
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(.62,0,0,20);nl.ZIndex=5
			local vl=MkLabel(card,tostring(def)..sfx,13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right);vl.Size=UDim2.new(.38,0,0,20);vl.ZIndex=5
			if desc~="" then local dl=MkLabel(card,desc,11,T.TxtMute,Enum.Font.Gotham);dl.Size=UDim2.new(1,0,0,14);dl.Position=UDim2.new(0,0,0,22);dl.ZIndex=5 end
			local yOff=desc~="" and 44 or 30
			local tBG=MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,yOff),T.SurfaceHi);tBG.ZIndex=5;Corner(tBG,5);Stroke(tBG,T.Border,1)
			local tBGg=Instance.new("UIGradient");tBGg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.SurfaceHi2),ColorSequenceKeypoint.new(1,T.SurfaceHi)});tBGg.Rotation=90;tBGg.Parent=tBG
			local fill=MkFrame(tBG,UDim2.new(0,0,1,0),nil,color);fill.ZIndex=6;Corner(fill,5)
			local fG=Instance.new("UIGradient");fG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)});fG.Parent=fill
			local fSh=MkFrame(fill,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White);fSh.BackgroundTransparency=.86;fSh.ZIndex=7;Corner(fSh,4)
			local knob=MkFrame(tBG,UDim2.new(0,22,0,22),UDim2.new(0,-11,.5,-11),T.White);knob.ZIndex=7;Corner(knob,11);local kR=Stroke(knob,color,2)
			local kSh=MkFrame(knob,UDim2.new(1,-4,0,8),UDim2.new(0,2,0,2),T.White);kSh.BackgroundTransparency=.82;kSh.ZIndex=8;Corner(kSh,4)
			local tGlow=Stroke(tBG,T.AccentHi,2,1)
			local val=math.clamp(def,min,max);local sliding=false
			local function SetVal(v) val=math.clamp(v,min,max);local pct=(val-min)/(max-min);FT(fill,{Size=UDim2.new(pct,0,1,0)},.06);FT(knob,{Position=UDim2.new(pct,-11,.5,-11)},.06);vl.Text=tostring(math.round(val))..sfx end
			SetVal(def)
			local function FP(p2) return min+math.clamp((p2.X-tBG.AbsolutePosition.X)/tBG.AbsoluteSize.X,0,1)*(max-min) end
			tBG.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true;ST(knob,{Size=UDim2.new(0,26,0,26)},.12);FT(kR,{Thickness=3},.12);FT(tGlow,{Transparency=.5},.2);SetVal(FP(i.Position));pcall(cb,math.round(val)) end end)
			UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then SetVal(FP(i.Position));pcall(cb,math.round(val)) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false;FT(knob,{Size=UDim2.new(0,22,0,22)},.14);FT(kR,{Thickness=2},.14);FT(tGlow,{Transparency=1},.22) end end)
			local Sl={};function Sl:Set(v) SetVal(v) end;function Sl:Get() return math.round(val) end
			_Reg(wName,id,function() return math.round(val) end,function(v) SetVal(tonumber(v) or min) end,"number");return Sl
		end

		-- ── DROPDOWN v3.7 ── nil default, placeholder, Clear(), SetItems() ──
		function API:AddDropdown(opt)
			opt=opt or {}
			local name=opt.Name or "Dropdown";local items=opt.Items or {}
			local rawDefault=opt.Default       -- nil = no selection; string = pre-select
			local placeholder=opt.Placeholder or "Select..."
			local cb=opt.Callback or function() end;local color=opt.Color or T.Accent;local id=opt.Id or ""
			local card=Card(46);local selVal=rawDefault;local isOpen=false

			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(.36,0,1,0);nl.ZIndex=5
			local pill=MkFrame(card,UDim2.new(.62,0,0,32),UDim2.new(.38,0,.5,-16),T.SurfaceHi);pill.ZIndex=5;Corner(pill,10);Stroke(pill,T.Border,1);CardShine(pill)
			local pillLbl=MkLabel(pill,selVal or placeholder,12,selVal and T.TxtMain or T.TxtMute,Enum.Font.GothamSemibold);pillLbl.Size=UDim2.new(1,-28,1,0);pillLbl.Position=UDim2.new(0,10,0,0);pillLbl.ZIndex=6;pillLbl.TextTruncate=Enum.TextTruncate.AtEnd
			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);chevLbl.Size=UDim2.new(0,22,1,0);chevLbl.Position=UDim2.new(1,-24,0,0);chevLbl.ZIndex=6

			local lF=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface);lF.ZIndex=50;lF.Visible=false;lF.ClipsDescendants=true;Corner(lF,12);Stroke(lF,T.BorderGlow,1,.3);CardShine(lF)
			local lI=MkFrame(lF,UDim2.new(1,0,1,0),nil,T.Black);lI.BackgroundTransparency=1;lI.ZIndex=51
			local liLL=Instance.new("UIListLayout");liLL.FillDirection=Enum.FillDirection.Vertical;liLL.SortOrder=Enum.SortOrder.LayoutOrder;liLL.Padding=UDim.new(0,3);liLL.Parent=lI;Pad(lI,5,5,5,5)
			local sBG=MkFrame(lI,UDim2.new(1,0,0,30),nil,T.SurfaceHi);sBG.ZIndex=52;Corner(sBG,8);Stroke(sBG,T.Border,1)
			local sTB=Instance.new("TextBox");sTB.PlaceholderText="Search...";sTB.PlaceholderColor3=T.TxtMute;sTB.Text="";sTB.TextColor3=T.TxtMain;sTB.BackgroundTransparency=1;sTB.Font=Enum.Font.Gotham;sTB.TextSize=12;sTB.Size=UDim2.new(1,-14,1,0);sTB.Position=UDim2.new(0,7,0,0);sTB.TextXAlignment=Enum.TextXAlignment.Left;sTB.ClearTextOnFocus=false;sTB.ZIndex=53;sTB.Parent=sBG
			local iSF=Instance.new("ScrollingFrame");iSF.BackgroundTransparency=1;iSF.BorderSizePixel=0;iSF.Size=UDim2.new(1,0,0,0);iSF.CanvasSize=UDim2.new(0,0,0,0);iSF.AutomaticCanvasSize=Enum.AutomaticSize.Y;iSF.ScrollBarThickness=2;iSF.ScrollBarImageColor3=T.Accent;iSF.ZIndex=52;iSF.Parent=lI
			local iLL2=Instance.new("UIListLayout");iLL2.FillDirection=Enum.FillDirection.Vertical;iLL2.SortOrder=Enum.SortOrder.LayoutOrder;iLL2.Padding=UDim.new(0,2);iLL2.Parent=iSF
			local allRows={}
			local function Close()
				if not isOpen then return end;isOpen=false;FT(lF,{Size=UDim2.new(1,-20,0,0)},.18);FT(chevLbl,{Rotation=0},.18);FT(pill,{BackgroundColor3=T.SurfaceHi},.12);task.wait(.2);lF.Visible=false;sTB.Text="";_ClrDrop(Close)
			end
			local function Build(filter)
				filter=(filter or ""):lower();for _,r in allRows do r.Parent=nil end;allRows={};local cnt=0
				for _,item in items do
					if filter=="" or item:lower():find(filter,1,true) then
						cnt+=1;local row=MkFrame(iSF,UDim2.new(1,0,0,32),nil,T.Black);row.BackgroundTransparency=1;row.ZIndex=53;Corner(row,7)
						local ck=MkLabel(row,selVal==item and ">" or "",12,color,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);ck.Size=UDim2.new(0,24,1,0);ck.ZIndex=54
						local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham);iLbl.Size=UDim2.new(1,-28,1,0);iLbl.Position=UDim2.new(0,26,0,0);iLbl.ZIndex=54
						local hit=MkButton(row,"",0,T.Black,T.White);hit.BackgroundTransparency=1;hit.Size=UDim2.new(1,0,1,0);hit.ZIndex=55
						hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},.1) end);hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},.1) end)
						hit.MouseButton1Click:Connect(function() selVal=item;pillLbl.Text=item;FT(pillLbl,{TextColor3=T.TxtMain},.12);Close();Build("");pcall(cb,item) end)
						table.insert(allRows,row)
					end
				end
				iSF.Size=UDim2.new(1,0,0,math.min(cnt,5)*34+4)
			end
			Build("");sTB:GetPropertyChangedSignal("Text"):Connect(function() Build(sTB.Text) end)
			local pBB=MkButton(pill,"",0,T.Black,T.White);pBB.BackgroundTransparency=1;pBB.Size=UDim2.new(1,0,1,0);pBB.ZIndex=7
			pBB.MouseButton1Click:Connect(function()
				if isOpen then Close();return end
				_RegDrop(Close);isOpen=true;Build("")
				local oAY=dropOverlay.AbsolutePosition.Y;local yPos=(card.AbsolutePosition.Y-oAY)+card.AbsoluteSize.Y+4
				local lH=44+math.min(#items,5)*34+10;lF.Position=UDim2.new(0,10,0,yPos);lF.Size=UDim2.new(1,-20,0,0);lF.Visible=true
				FT(lF,{Size=UDim2.new(1,-20,0,lH)},.22);FT(chevLbl,{Rotation=180},.18);FT(pill,{BackgroundColor3=T.SurfaceHi2},.12)
			end)
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
					local lx,ly,lw,lh=lF.AbsolutePosition.X,lF.AbsolutePosition.Y,lF.AbsoluteSize.X,lF.AbsoluteSize.Y
					local px,py,pw,ph=pill.AbsolutePosition.X,pill.AbsolutePosition.Y,pill.AbsoluteSize.X,pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not(mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh) and not(mx>=px and mx<=px+pw and my>=py and my<=py+ph) then Close() end
				end
			end)

			local Drop={}
			function Drop:Get() return selVal end
			function Drop:Set(v) selVal=v;pillLbl.Text=v or placeholder;FT(pillLbl,{TextColor3=v and T.TxtMain or T.TxtMute},.12);Build("") end
			function Drop:Clear() selVal=nil;pillLbl.Text=placeholder;FT(pillLbl,{TextColor3=T.TxtMute},.12);Build("") end
			function Drop:SetItems(ni) items=ni or {};selVal=nil;pillLbl.Text=placeholder;pillLbl.TextColor3=T.TxtMute;Build("") end
			function Drop:SetPlaceholder(s) placeholder=s or "Select...";if selVal==nil then pillLbl.Text=placeholder end end
			_Reg(wName,id,function() return selVal end,function(v) selVal=tostring(v);pillLbl.Text=selVal;pillLbl.TextColor3=T.TxtMain;Build("") end,"string")
			return Drop
		end

		-- ── MULTI DROPDOWN v1.8 ── Placeholder, Clear(), SetItems() ──
		function API:AddMultiDropdown(opt)
			opt=opt or {};local name=opt.Name or "Multi Select";local items=opt.Items or {};local def=opt.Default or {};local placeholder=opt.Placeholder or "Select..."
			local cb=opt.Callback or function() end;local color=opt.Color or T.Accent;local id=opt.Id or ""
			local card=Card(46);local selected={};local isOpen=false
			for _,v in def do selected[v]=true end
			local function GetSel() local t={};for _,item in items do if selected[item] then table.insert(t,item) end end;return t end
			local function PT() local t=GetSel();if #t==0 then return placeholder elseif #t==1 then return t[1] else return t[1].." +"..tostring(#t-1) end end
			local function PC() return #GetSel()>0 and T.TxtMain or T.TxtMute end
			local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(.36,0,1,0);nl.ZIndex=5
			local pill=MkFrame(card,UDim2.new(.62,0,0,32),UDim2.new(.38,0,.5,-16),T.SurfaceHi);pill.ZIndex=5;Corner(pill,10);Stroke(pill,T.Border,1);CardShine(pill)
			local pillLbl=MkLabel(pill,PT(),12,PC(),Enum.Font.GothamSemibold);pillLbl.Size=UDim2.new(1,-46,1,0);pillLbl.Position=UDim2.new(0,10,0,0);pillLbl.ZIndex=6;pillLbl.TextTruncate=Enum.TextTruncate.AtEnd
			local chevLbl=MkLabel(pill,"v",13,T.TxtSub,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);chevLbl.Size=UDim2.new(0,22,1,0);chevLbl.Position=UDim2.new(1,-24,0,0);chevLbl.ZIndex=6
			local badge=MkFrame(pill,UDim2.new(0,18,0,18),UDim2.new(1,-44,.5,-9),T.Accent);badge.ZIndex=7;Corner(badge,9)
			local badgeLbl=MkLabel(badge,"0",10,T.White,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);badgeLbl.ZIndex=8
			local function RefBadge() local n=#GetSel();badgeLbl.Text=tostring(n);badge.BackgroundTransparency=n==0 and 1 or 0;pillLbl.Text=PT();FT(pillLbl,{TextColor3=PC()},.12) end
			RefBadge()
			local lF=MkFrame(dropOverlay,UDim2.new(1,-20,0,0),UDim2.new(0,10,0,0),T.Surface);lF.ZIndex=50;lF.Visible=false;lF.ClipsDescendants=true;Corner(lF,12);Stroke(lF,T.BorderGlow,1,.3);CardShine(lF)
			local lI=MkFrame(lF,UDim2.new(1,0,1,0),nil,T.Black);lI.BackgroundTransparency=1;lI.ZIndex=51
			local liLL2=Instance.new("UIListLayout");liLL2.FillDirection=Enum.FillDirection.Vertical;liLL2.SortOrder=Enum.SortOrder.LayoutOrder;liLL2.Padding=UDim.new(0,3);liLL2.Parent=lI;Pad(lI,5,5,5,5)
			local aRow=MkFrame(lI,UDim2.new(1,0,0,28),nil,T.SurfaceHi);aRow.ZIndex=52;Corner(aRow,8)
			local sAB=MkButton(aRow,"Select All",11,T.AccentLo,T.AccentHi,Enum.Font.GothamBold);sAB.BackgroundTransparency=1;sAB.Size=UDim2.new(.5,0,1,0);sAB.TextXAlignment=Enum.TextXAlignment.Center
			local cAB=MkButton(aRow,"Clear",11,T.AccentLo,T.TxtMute,Enum.Font.GothamBold);cAB.BackgroundTransparency=1;cAB.Size=UDim2.new(.5,0,1,0);cAB.Position=UDim2.new(.5,0,0,0);cAB.TextXAlignment=Enum.TextXAlignment.Center
			local iSF2=Instance.new("ScrollingFrame");iSF2.BackgroundTransparency=1;iSF2.BorderSizePixel=0;iSF2.Size=UDim2.new(1,0,0,0);iSF2.CanvasSize=UDim2.new(0,0,0,0);iSF2.AutomaticCanvasSize=Enum.AutomaticSize.Y;iSF2.ScrollBarThickness=2;iSF2.ScrollBarImageColor3=T.Accent;iSF2.ZIndex=52;iSF2.Parent=lI
			local iLL3=Instance.new("UIListLayout");iLL3.FillDirection=Enum.FillDirection.Vertical;iLL3.SortOrder=Enum.SortOrder.LayoutOrder;iLL3.Padding=UDim.new(0,2);iLL3.Parent=iSF2
			local rowRefs={}
			local function BuildMI()
				for _,r in rowRefs do r.Parent=nil end;rowRefs={}
				for _,item in items do
					local row=MkFrame(iSF2,UDim2.new(1,0,0,34),nil,T.Black);row.BackgroundTransparency=1;row.ZIndex=53;Corner(row,7)
					local cbBox=MkFrame(row,UDim2.new(0,20,0,20),UDim2.new(0,6,.5,-10),T.SurfaceHi2);cbBox.ZIndex=54;Corner(cbBox,5);Stroke(cbBox,T.Border,1)
					local ckM=MkLabel(cbBox,selected[item] and ">" or "",11,color,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);ckM.ZIndex=55
					if selected[item] then cbBox.BackgroundColor3=T.AccentDeep end
					local iLbl=MkLabel(row,item,12,T.TxtMain,Enum.Font.Gotham);iLbl.Size=UDim2.new(1,-36,1,0);iLbl.Position=UDim2.new(0,34,0,0);iLbl.ZIndex=54
					local hit=MkButton(row,"",0,T.Black,T.White);hit.BackgroundTransparency=1;hit.Size=UDim2.new(1,0,1,0);hit.ZIndex=55
					hit.MouseEnter:Connect(function() FT(row,{BackgroundColor3=T.SurfaceHi2,BackgroundTransparency=0},.1) end);hit.MouseLeave:Connect(function() FT(row,{BackgroundTransparency=1},.1) end)
					hit.MouseButton1Click:Connect(function() selected[item]=not selected[item];ckM.Text=selected[item] and ">" or "";FT(cbBox,{BackgroundColor3=selected[item] and T.AccentDeep or T.SurfaceHi2},.12);RefBadge();pcall(cb,GetSel()) end)
					table.insert(rowRefs,row)
				end
				iSF2.Size=UDim2.new(1,0,0,math.min(#items,5)*36+4)
			end
			BuildMI()
			sAB.MouseButton1Click:Connect(function() for _,i in items do selected[i]=true end;BuildMI();RefBadge();pcall(cb,GetSel()) end)
			cAB.MouseButton1Click:Connect(function() for _,i in items do selected[i]=false end;BuildMI();RefBadge();pcall(cb,GetSel()) end)
			local function CloseM() if not isOpen then return end;isOpen=false;FT(lF,{Size=UDim2.new(1,-20,0,0)},.18);FT(chevLbl,{Rotation=0},.18);FT(pill,{BackgroundColor3=T.SurfaceHi},.12);task.wait(.2);lF.Visible=false;_ClrDrop(CloseM) end
			local pBB=MkButton(pill,"",0,T.Black,T.White);pBB.BackgroundTransparency=1;pBB.Size=UDim2.new(1,0,1,0);pBB.ZIndex=7
			pBB.MouseButton1Click:Connect(function()
				if isOpen then CloseM();return end
				_RegDrop(CloseM);isOpen=true;BuildMI()
				local oAY=dropOverlay.AbsolutePosition.Y;local yPos=(card.AbsolutePosition.Y-oAY)+card.AbsoluteSize.Y+4
				local lH=38+math.min(#items,5)*36+12;lF.Position=UDim2.new(0,10,0,yPos);lF.Size=UDim2.new(1,-20,0,0);lF.Visible=true
				FT(lF,{Size=UDim2.new(1,-20,0,lH)},.22);FT(chevLbl,{Rotation=180},.18);FT(pill,{BackgroundColor3=T.SurfaceHi2},.12)
			end)
			UserInputService.InputBegan:Connect(function(i)
				if not isOpen then return end
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
					local lx,ly,lw,lh=lF.AbsolutePosition.X,lF.AbsolutePosition.Y,lF.AbsoluteSize.X,lF.AbsoluteSize.Y
					local px,py,pw,ph=pill.AbsolutePosition.X,pill.AbsolutePosition.Y,pill.AbsoluteSize.X,pill.AbsoluteSize.Y
					local mx,my=i.Position.X,i.Position.Y
					if not(mx>=lx and mx<=lx+lw and my>=ly and my<=ly+lh) and not(mx>=px and mx<=px+pw and my>=py and my<=py+ph) then CloseM() end
				end
			end)
			local MD={}
			function MD:Get() return GetSel() end
			function MD:Set(tbl) for _,i in items do selected[i]=false end;if tbl then for _,v in tbl do selected[v]=true end end;BuildMI();RefBadge() end
			function MD:Clear() for _,i in items do selected[i]=false end;BuildMI();RefBadge();pcall(cb,{}) end
			function MD:SetItems(ni) items=ni or {};for _,i in items do selected[i]=false end;BuildMI();RefBadge() end
			_Reg(wName,id,function() return GetSel() end,function(v) if type(v)=="table" then for _,i in items do selected[i]=false end;for _,s in v do selected[s]=true end;BuildMI();RefBadge() end end,"multi")
			return MD
		end

		function API:AddTextBox(opt)
			opt=opt or {};local name=opt.Name or "Input";local ph=opt.Placeholder or "Type here...";local def=opt.Default or "";local numOnly=opt.NumberOnly or false;local cb=opt.Callback or function() end;local color=opt.Color or T.Accent;local id=opt.Id or ""
			local card=Card(70);Pad(card,8,8,14,14)
			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold);nl.Size=UDim2.new(1,0,0,18);nl.ZIndex=5
			local inBG=MkFrame(card,UDim2.new(1,0,0,32),UDim2.new(0,0,0,24),T.SurfaceHi);inBG.ZIndex=5;Corner(inBG,10);local inS=Stroke(inBG,T.Border,1);CardShine(inBG)
			local pre=MkLabel(inBG,">",14,T.TxtMute,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);pre.Size=UDim2.new(0,26,1,0);pre.ZIndex=6
			local tb=Instance.new("TextBox");tb.Text=def;tb.PlaceholderText=ph;tb.PlaceholderColor3=T.TxtMute;tb.TextColor3=T.TxtMain;tb.BackgroundTransparency=1;tb.Font=Enum.Font.Gotham;tb.TextSize=13;tb.Size=UDim2.new(1,-40,1,0);tb.Position=UDim2.new(0,28,0,0);tb.TextXAlignment=Enum.TextXAlignment.Left;tb.ClearTextOnFocus=false;tb.ZIndex=6;tb.Parent=inBG
			tb.Focused:Connect(function() FT(inBG,{BackgroundColor3=T.SurfaceHi2},.15);FT(inS,{Color=T.BorderGlow,Thickness=1.5},.15);FT(pre,{TextColor3=color},.15) end)
			tb.FocusLost:Connect(function(enter) FT(inBG,{BackgroundColor3=T.SurfaceHi},.15);FT(inS,{Color=T.Border,Thickness=1},.15);FT(pre,{TextColor3=T.TxtMute},.15);if enter then pcall(cb,tb.Text) end end)
			if numOnly then tb:GetPropertyChangedSignal("Text"):Connect(function() local c2=tb.Text:gsub("[^%d%.%-]","");if tb.Text~=c2 then tb.Text=c2 end end) end
			local TBx={};function TBx:Get() return tb.Text end;function TBx:Set(v) tb.Text=tostring(v) end
			_Reg(wName,id,function() return tb.Text end,function(v) tb.Text=tostring(v) end,"string");return TBx
		end

		function API:AddKeybind(opt)
			opt=opt or {};local name=opt.Name or "Keybind";local def=opt.Default or Enum.KeyCode.F;local cb=opt.Callback or function() end
			local card=Card(46);local nl=MkLabel(card,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(.52,0,1,0);nl.ZIndex=5
			local curKey=def;local listening=false
			local kPill=MkFrame(card,UDim2.new(0,114,0,30),UDim2.new(1,-114,.5,-15),T.SurfaceHi);kPill.ZIndex=5;Corner(kPill,8);Stroke(kPill,T.Border,1);CardShine(kPill)
			local kLbl=MkLabel(kPill,"["..tostring(def.Name).."]",11,T.TxtMain,Enum.Font.GothamBold,Enum.TextXAlignment.Center,Enum.TextYAlignment.Center);kLbl.ZIndex=6
			local kBB=MkButton(kPill,"",0,T.Black,T.White);kBB.BackgroundTransparency=1;kBB.Size=UDim2.new(1,0,1,0);kBB.ZIndex=7
			kBB.MouseButton1Click:Connect(function() listening=true;kLbl.Text="[  ?  ]";FT(kPill,{BackgroundColor3=T.AccentDeep},.12);Stroke(kPill,T.Accent,1) end)
			UserInputService.InputBegan:Connect(function(i,gpe)
				if gpe then return end
				if listening and i.UserInputType==Enum.UserInputType.Keyboard then listening=false;curKey=i.KeyCode;kLbl.Text="["..tostring(i.KeyCode.Name).."]";FT(kPill,{BackgroundColor3=T.SurfaceHi},.15)
				elseif not listening and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==curKey then pcall(cb) end
			end)
			local KB={};function KB:Get() return curKey end;function KB:Set(k) curKey=k;kLbl.Text="["..tostring(k.Name).."]" end;return KB
		end

		function API:AddColorPicker(opt)
			opt=opt or {};local name=opt.Name or "Color";local def=opt.Default or T.Accent;local cb=opt.Callback or function() end;local id=opt.Id or ""
			local sw={Color3.fromRGB(248,68,92),Color3.fromRGB(252,150,52),Color3.fromRGB(252,214,52),Color3.fromRGB(68,214,132),Color3.fromRGB(52,172,254),Color3.fromRGB(138,76,255),Color3.fromRGB(248,72,200),Color3.fromRGB(200,200,210)}
			local card=Card(66);Pad(card,8,8,14,14)
			local nl=MkLabel(card,name,12,T.TxtSub,Enum.Font.GothamBold);nl.Size=UDim2.new(1,0,0,18);nl.ZIndex=5
			local row=MkFrame(card,UDim2.new(1,0,0,38),UDim2.new(0,0,0,22),T.Black);row.BackgroundTransparency=1;row.ZIndex=5
			local prev=MkFrame(row,UDim2.new(0,38,0,38),nil,def);prev.ZIndex=6;Corner(prev,11);Stroke(prev,T.Border,1);CardShine(prev)
			local swRow=MkFrame(row,UDim2.new(1,-48,1,0),UDim2.new(0,46,0,0),T.Black);swRow.BackgroundTransparency=1;swRow.ZIndex=5
			local swLL=Instance.new("UIListLayout");swLL.FillDirection=Enum.FillDirection.Horizontal;swLL.VerticalAlignment=Enum.VerticalAlignment.Center;swLL.Padding=UDim.new(0,5);swLL.Parent=swRow
			local selColor=def;local activeRing=nil
			for _,col in sw do
				local s2=MkFrame(swRow,UDim2.new(0,28,0,28),nil,col);s2.ZIndex=6;Corner(s2,8);CardShine(s2)
				local ring=Stroke(s2,T.White,2,col==def and 0 or 1);if col==def then activeRing=ring end
				local hit=MkButton(s2,"",0,T.Black,T.White);hit.BackgroundTransparency=1;hit.Size=UDim2.new(1,0,1,0);hit.ZIndex=7
				hit.MouseEnter:Connect(function() ST(s2,{Size=UDim2.new(0,30,0,30)},.14) end);hit.MouseLeave:Connect(function() FT(s2,{Size=UDim2.new(0,28,0,28)},.12) end)
				hit.MouseButton1Click:Connect(function() selColor=col;FT(prev,{BackgroundColor3=col},.18);if activeRing then FT(activeRing,{Transparency=1},.1) end;FT(ring,{Transparency=0},.1);activeRing=ring;pcall(cb,col) end)
			end
			local CP={};function CP:Get() return selColor end;function CP:Set(c) selColor=c;prev.BackgroundColor3=c end
			_Reg(wName,id,function() return selColor end,function(v) selColor=v;prev.BackgroundColor3=v end,"color");return CP
		end

		function API:AddProgressBar(opt)
			opt=opt or {};local name=opt.Name or "Progress";local val=opt.Value or 0;local color=opt.Color or T.Accent
			local card=Card(54);Pad(card,8,8,14,14)
			local row=MkFrame(card,UDim2.new(1,0,0,20),nil,T.Black);row.BackgroundTransparency=1;row.ZIndex=5
			local nl=MkLabel(row,name,13,T.TxtMain,Enum.Font.GothamBold);nl.Size=UDim2.new(.65,0,1,0);nl.ZIndex=6
			local vl=MkLabel(row,tostring(val).."%",13,color,Enum.Font.GothamBold,Enum.TextXAlignment.Right);vl.Size=UDim2.new(.35,0,1,0);vl.ZIndex=6
			local tBG=MkFrame(card,UDim2.new(1,0,0,10),UDim2.new(0,0,0,30),T.SurfaceHi);tBG.ZIndex=5;Corner(tBG,5);Stroke(tBG,T.Border,1)
			local fillF=MkFrame(tBG,UDim2.new(val/100,0,1,0),nil,color);fillF.ZIndex=6;Corner(fillF,5)
			local fg=Instance.new("UIGradient");fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentHi),ColorSequenceKeypoint.new(1,color)});fg.Parent=fillF
			local fSh=MkFrame(fillF,UDim2.new(1,0,0,4),UDim2.new(0,0,0,1),T.White);fSh.BackgroundTransparency=.86;fSh.ZIndex=7;Corner(fSh,4)
			local PB={};function PB:Set(v) v=math.clamp(v,0,100);FT(fillF,{Size=UDim2.new(v/100,0,1,0)},.4);vl.Text=tostring(math.round(v)).."%" end;function PB:Get() return tonumber(vl.Text:gsub("%%","")) end;return PB
		end

		function API:AddCredit(l1,l2)
			l1=l1 or "Credit";l2=l2 or ""
			local wrap=MkFrame(page,UDim2.new(1,0,0,l2~="" and 72 or 54),nil,T.Black);wrap.BackgroundTransparency=1;wrap.ZIndex=4
			local function FadeLn(xs,xo,w) local l=MkFrame(wrap,UDim2.new(w,0,0,1),UDim2.new(xs,xo,0,0),T.Accent);l.BackgroundTransparency=.6;l.ZIndex=4;local g=Instance.new("UIGradient");g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,xs==0 and 1 or .6),NumberSequenceKeypoint.new(.5,.55),NumberSequenceKeypoint.new(1,xs==0 and .6 or 1)});g.Parent=l end
			FadeLn(.05,0,.3);FadeLn(.65,0,.3)
			local lb1=Instance.new("TextLabel");lb1.Text=l1;lb1.TextSize=14;lb1.Font=Enum.Font.GothamBold;lb1.TextColor3=Color3.fromRGB(200,174,255);lb1.BackgroundTransparency=1;lb1.BorderSizePixel=0;lb1.Size=UDim2.new(1,0,0,22);lb1.Position=UDim2.new(0,0,0,8);lb1.TextXAlignment=Enum.TextXAlignment.Center;lb1.ZIndex=5;lb1.Parent=wrap
			if l2~="" then local lb2=Instance.new("TextLabel");lb2.Text=l2;lb2.TextSize=11;lb2.Font=Enum.Font.Gotham;lb2.TextColor3=Color3.fromRGB(114,94,156);lb2.BackgroundTransparency=1;lb2.BorderSizePixel=0;lb2.Size=UDim2.new(1,0,0,18);lb2.Position=UDim2.new(0,0,0,34);lb2.TextXAlignment=Enum.TextXAlignment.Center;lb2.ZIndex=5;lb2.Parent=wrap end
			FadeLn(.05,0,.3);FadeLn(.65,0,.3)
		end

		return API
	end -- AddTab

	return WinAPI
end -- CreateWindow

-- Expose MkIcon for advanced use
NexusUI.MkIcon=MkIcon

return NexusUI
