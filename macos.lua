local MacOSLib = {}
MacOSLib.__index = MacOSLib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function tween(obj, props, duration, style, direction)
	style = style or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(duration or 0.25, style, direction), props):Play()
end

local function create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(200, 200, 200)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function padding(parent, top, left, right, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

local function listlayout(parent, pad)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, pad or 0)
	l.Parent = parent
	return l
end

-- ═══════════════════════════════════════════
--   GLOW / GRADIENTE - Funções auxiliares
-- ═══════════════════════════════════════════

local function addGlow(parent, color, size, transparency)
	local glow = create("Frame", {
		Size = UDim2.new(1, size or 20, 1, size or 20),
		Position = UDim2.new(0.5, -(size or 20)/2, 0.5, -(size or 20)/2),
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = transparency or 0.8,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = parent,
	})
	corner(glow, 100)
	return glow
end

local function addGradient(parent, color1, color2, rotation)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(200, 200, 200))
	})
	grad.Rotation = rotation or 45
	grad.Parent = parent
	return grad
end

local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart = nil
	local startPos = nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ══════════════════════════════════════════════════════════
--   TEMAS (com cores de gradiente adicionais)
-- ══════════════════════════════════════════════════════════

local Themes = {}

Themes.Light = {
	Background  = Color3.fromRGB(245, 245, 247),
	Sidebar     = Color3.fromRGB(235, 235, 237),
	TopBar      = Color3.fromRGB(238, 238, 240),
	Text        = Color3.fromRGB(20, 20, 22),
	SubText     = Color3.fromRGB(110, 110, 115),
	Accent      = Color3.fromRGB(0, 122, 255),
	Divider     = Color3.fromRGB(210, 210, 215),
	TabActive   = Color3.fromRGB(255, 255, 255),
	TabInactive = Color3.fromRGB(235, 235, 237),
	ToggleOn    = Color3.fromRGB(48, 209, 88),
	ToggleOff   = Color3.fromRGB(180, 180, 185),
	SliderFill  = Color3.fromRGB(0, 122, 255),
	SliderBG    = Color3.fromRGB(210, 210, 215),
	InputBG     = Color3.fromRGB(255, 255, 255),
	Shadow      = Color3.fromRGB(0, 0, 0),
	White       = Color3.fromRGB(255, 255, 255),
	ButtonBG    = Color3.fromRGB(255, 255, 255),
	ButtonHover = Color3.fromRGB(240, 240, 245),
	IconStroke       = Color3.fromRGB(70, 70, 75),
	IconStrokeActive = Color3.fromRGB(0, 122, 255),
	Glass = { Window = 0.35, TopBar = 0.30, Sidebar = 0.32, Card = 0.25 },
	Gradient = { Top = Color3.fromRGB(255, 255, 255), Bottom = Color3.fromRGB(235, 235, 237) },
	Glow = Color3.fromRGB(255, 255, 255),
}

Themes.Dark = {
	Background  = Color3.fromRGB(24, 24, 26),
	Sidebar     = Color3.fromRGB(18, 18, 20),
	TopBar      = Color3.fromRGB(20, 20, 22),
	Text        = Color3.fromRGB(235, 235, 238),
	SubText     = Color3.fromRGB(150, 150, 156),
	Accent      = Color3.fromRGB(10, 132, 255),
	Divider     = Color3.fromRGB(58, 58, 62),
	TabActive   = Color3.fromRGB(46, 46, 50),
	TabInactive = Color3.fromRGB(24, 24, 26),
	ToggleOn    = Color3.fromRGB(48, 209, 88),
	ToggleOff   = Color3.fromRGB(80, 80, 85),
	SliderFill  = Color3.fromRGB(10, 132, 255),
	SliderBG    = Color3.fromRGB(64, 64, 68),
	InputBG     = Color3.fromRGB(56, 56, 60),
	Shadow      = Color3.fromRGB(0, 0, 0),
	White       = Color3.fromRGB(245, 245, 247),
	ButtonBG    = Color3.fromRGB(40, 40, 43),
	ButtonHover = Color3.fromRGB(50, 50, 54),
	IconStroke       = Color3.fromRGB(190, 190, 195),
	IconStrokeActive = Color3.fromRGB(10, 132, 255),
	Glass = { Window = 0.25, TopBar = 0.20, Sidebar = 0.22, Card = 0.18 },
	Gradient = { Top = Color3.fromRGB(30, 30, 32), Bottom = Color3.fromRGB(20, 20, 22) },
	Glow = Color3.fromRGB(30, 30, 35),
}

Themes.Nord = {
	Background  = Color3.fromRGB(46, 52, 64),
	Sidebar     = Color3.fromRGB(39, 44, 54),
	TopBar      = Color3.fromRGB(42, 48, 59),
	Text        = Color3.fromRGB(229, 233, 240),
	SubText     = Color3.fromRGB(150, 160, 180),
	Accent      = Color3.fromRGB(136, 192, 208),
	Divider     = Color3.fromRGB(67, 76, 94),
	TabActive   = Color3.fromRGB(59, 66, 82),
	TabInactive = Color3.fromRGB(46, 52, 64),
	ToggleOn    = Color3.fromRGB(163, 190, 140),
	ToggleOff   = Color3.fromRGB(76, 86, 106),
	SliderFill  = Color3.fromRGB(136, 192, 208),
	SliderBG    = Color3.fromRGB(67, 76, 94),
	InputBG     = Color3.fromRGB(59, 66, 82),
	Shadow      = Color3.fromRGB(0, 0, 0),
	White       = Color3.fromRGB(236, 239, 244),
	ButtonBG    = Color3.fromRGB(52, 59, 73),
	ButtonHover = Color3.fromRGB(62, 70, 87),
	IconStroke       = Color3.fromRGB(198, 205, 217),
	IconStrokeActive = Color3.fromRGB(136, 192, 208),
	Glass = { Window = 0.25, TopBar = 0.20, Sidebar = 0.22, Card = 0.18 },
	Gradient = { Top = Color3.fromRGB(50, 56, 68), Bottom = Color3.fromRGB(42, 48, 59) },
	Glow = Color3.fromRGB(50, 56, 68),
}

Themes.Rose = {
	Background  = Color3.fromRGB(255, 246, 248),
	Sidebar     = Color3.fromRGB(252, 235, 240),
	TopBar      = Color3.fromRGB(253, 238, 242),
	Text        = Color3.fromRGB(60, 30, 40),
	SubText     = Color3.fromRGB(150, 110, 125),
	Accent      = Color3.fromRGB(233, 79, 132),
	Divider     = Color3.fromRGB(240, 210, 220),
	TabActive   = Color3.fromRGB(255, 255, 255),
	TabInactive = Color3.fromRGB(252, 235, 240),
	ToggleOn    = Color3.fromRGB(233, 79, 132),
	ToggleOff   = Color3.fromRGB(225, 195, 205),
	SliderFill  = Color3.fromRGB(233, 79, 132),
	SliderBG    = Color3.fromRGB(240, 210, 220),
	InputBG     = Color3.fromRGB(255, 255, 255),
	Shadow      = Color3.fromRGB(0, 0, 0),
	White       = Color3.fromRGB(255, 255, 255),
	ButtonBG    = Color3.fromRGB(255, 255, 255),
	ButtonHover = Color3.fromRGB(250, 228, 235),
	IconStroke       = Color3.fromRGB(110, 60, 80),
	IconStrokeActive = Color3.fromRGB(233, 79, 132),
	Glass = { Window = 0.35, TopBar = 0.30, Sidebar = 0.32, Card = 0.25 },
	Gradient = { Top = Color3.fromRGB(255, 255, 255), Bottom = Color3.fromRGB(250, 240, 242) },
	Glow = Color3.fromRGB(255, 240, 242),
}

-- ══════════════════════════════════════════════════════════
--   ÍCONES MELHORADOS COM GRADIENTES E GLOW
-- ══════════════════════════════════════════════════════════

local Icons = {}

-- Função auxiliar para criar linha com efeito glow
local function line(parent, x1, y1, x2, y2, color, thickness)
	thickness = thickness or 0.07
	local dx, dy = x2 - x1, y2 - y1
	local length = math.sqrt(dx * dx + dy * dy)
	local angle = math.atan2(dy, dx)
	local midX, midY = (x1 + x2) / 2, (y1 + y2) / 2

	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local seg = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Rotation = math.deg(angle),
		Parent = container,
	})
	
	-- Glow na linha
	local glow = addGlow(seg, color, 4, 0.6)
	
	local segCorner = Instance.new("UICorner")
	segCorner.CornerRadius = UDim.new(1, 0)
	segCorner.Parent = seg
	
	local function layout()
		local absSize = container.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		seg.Size = UDim2.new(0, length * base, 0, thickness * base)
		seg.Position = UDim2.new(midX, 0, midY, 0)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return seg
end

-- Função auxiliar para arco com glow
local function arc(parent, cx, cy, r, startAngle, endAngle, color, thickness, segments)
	segments = segments or 8
	local prevX, prevY = nil, nil
	for i = 0, segments do
		local t = i / segments
		local a = math.rad(startAngle + (endAngle - startAngle) * t)
		local px = cx + math.cos(a) * r
		local py = cy + math.sin(a) * r
		if prevX then
			line(parent, prevX, prevY, px, py, color, thickness)
		end
		prevX, prevY = px, py
	end
end

-- Função auxiliar para anel com glow
local function ring(parent, cx, cy, r, color, thickness)
	thickness = thickness or 0.07
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local c = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = container,
	})
	corner(c, 100)
	
	-- Glow no anel
	addGlow(c, color, 6, 0.5)
	
	local ringStroke = stroke(c, color, 2, 0)
	local function layout()
		local absSize = container.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		c.Position = UDim2.new(cx, 0, cy, 0)
		c.Size = UDim2.new(0, r * 2 * base, 0, r * 2 * base)
		ringStroke.Thickness = math.max(1, thickness * base)
	end
	layout()
	container:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return c
end

-- Função auxiliar para retângulo arredondado com glow
local function roundRect(parent, x, y, w, h, color, radius)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local r = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(w, 0, h, 0),
		Parent = container,
	})
	corner(r, radius or 4)
	
	-- Glow no retângulo
	addGlow(r, color, 6, 0.5)
	
	local rectStroke = stroke(r, color, 2, 0)
	local function layout()
		local absSize = container.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		rectStroke.Thickness = math.max(1, 0.07 * base)
	end
	layout()
	container:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return r
end

-- ══════════════════════════════════════════════════════════
--   ÍCONES ESTILO LUCIDE MELHORADOS
-- ══════════════════════════════════════════════════════════

-- House (Principal) - com gradiente sutil
Icons.House = function(parent, color)
	-- Criar um container com gradiente
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	-- Gradiente suave no ícone
	local grad = addGradient(container, color, Color3.fromRGB(
		math.min(color.R * 1.1, 1) * 255,
		math.min(color.G * 1.1, 1) * 255,
		math.min(color.B * 1.1, 1) * 255
	), 45)
	
	line(container, 0.5, 0.08, 0.92, 0.46, color)
	line(container, 0.5, 0.08, 0.08, 0.46, color)
	line(container, 0.16, 0.4, 0.16, 0.92, color)
	line(container, 0.84, 0.4, 0.84, 0.92, color)
	line(container, 0.16, 0.92, 0.84, 0.92, color)
	line(container, 0.4, 0.92, 0.4, 0.62, color)
	line(container, 0.4, 0.62, 0.6, 0.62, color)
	line(container, 0.6, 0.62, 0.6, 0.92, color)
end

-- Settings (Config) - com gradiente
Icons.Settings = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local grad = addGradient(container, color, Color3.fromRGB(
		math.min(color.R * 1.2, 1) * 255,
		math.min(color.G * 1.2, 1) * 255,
		math.min(color.B * 1.2, 1) * 255
	), 60)
	
	ring(container, 0.5, 0.5, 0.14, color)
	local teeth = 8
	for i = 1, teeth do
		local angle = (i - 1) * (360 / teeth)
		local rad = math.rad(angle)
		local x1 = 0.5 + math.cos(rad) * 0.3
		local y1 = 0.5 + math.sin(rad) * 0.3
		local x2 = 0.5 + math.cos(rad) * 0.42
		local y2 = 0.5 + math.sin(rad) * 0.42
		line(container, x1, y1, x2, y2, color, 0.1)
	end
end

-- Palette (Visual) - com gradiente arco-íris
Icons.Palette = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	-- Gradiente colorido para a paleta
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 200, 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 255, 50)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(50, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 255))
	})
	grad.Rotation = 45
	grad.Parent = container
	
	ring(container, 0.48, 0.5, 0.42, color)
	
	local dots = { {0.34, 0.32, 0.07}, {0.56, 0.28, 0.07}, {0.7, 0.46, 0.07}, {0.36, 0.62, 0.07} }
	for _, d in ipairs(dots) do
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = container,
		})
		corner(dot, 100)
		addGlow(dot, color, 4, 0.5)
		local function layout()
			local absSize = container.AbsoluteSize
			local base = math.min(absSize.X, absSize.Y)
			if base <= 0 then return end
			dot.Position = UDim2.new(d[1], 0, d[2], 0)
			dot.Size = UDim2.new(0, d[3] * 2 * base, 0, d[3] * 2 * base)
		end
		layout()
		container:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	end
end

-- Volume (Áudio) - com gradiente
Icons.Volume = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local grad = addGradient(container, color, Color3.fromRGB(
		math.min(color.R * 0.8, 1) * 255,
		math.min(color.G * 0.8, 1) * 255,
		math.min(color.B * 0.8, 1) * 255
	), -45)
	
	line(container, 0.06, 0.4, 0.28, 0.4, color)
	line(container, 0.06, 0.4, 0.06, 0.6, color)
	line(container, 0.06, 0.6, 0.28, 0.6, color)
	line(container, 0.28, 0.4, 0.46, 0.22, color)
	line(container, 0.28, 0.6, 0.46, 0.78, color)
	line(container, 0.46, 0.22, 0.46, 0.78, color)
	arc(container, 0.42, 0.5, 0.18, -45, 45, color, 0.07, 5)
	arc(container, 0.42, 0.5, 0.32, -55, 55, color, 0.07, 6)
end

-- Star (Favoritos) - com brilho especial
Icons.Star = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	-- Brilho dourado
	local goldGrad = Instance.new("UIGradient")
	goldGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
		ColorSequenceKeypoint.new(0.5, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
	})
	goldGrad.Rotation = 90
	goldGrad.Parent = container
	
	local points = {}
	local cx, cy = 0.5, 0.52
	local outer, inner = 0.42, 0.18
	for i = 0, 9 do
		local angle = math.rad(-90 + i * 36)
		local r = (i % 2 == 0) and outer or inner
		table.insert(points, { cx + math.cos(angle) * r, cy + math.sin(angle) * r })
	end
	for i = 1, #points do
		local p1 = points[i]
		local p2 = points[(i % #points) + 1]
		line(container, p1[1], p1[2], p2[1], p2[2], color, 0.07)
	end
end

-- ══════════════════════════════════════════════════════════
--   ÍCONES FLUENT UI MELHORADOS
-- ══════════════════════════════════════════════════════════

Icons.FluentHome = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local grad = addGradient(container, color, Color3.fromRGB(
		math.min(color.R * 1.2, 1) * 255,
		math.min(color.G * 1.2, 1) * 255,
		math.min(color.B * 1.2, 1) * 255
	), 30)
	
	line(container, 0.5, 0.08, 0.88, 0.4, color)
	line(container, 0.5, 0.08, 0.12, 0.4, color)
	roundRect(container, 0.2, 0.38, 0.6, 0.5, color, 3)
	line(container, 0.42, 0.88, 0.42, 0.62, color)
	line(container, 0.42, 0.62, 0.58, 0.62, color)
	line(container, 0.58, 0.62, 0.58, 0.88, color)
end

Icons.FluentSettings = function(parent, color)
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	
	local grad = addGradient(container, color, Color3.fromRGB(
		math.min(color.R * 0.9, 1) * 255,
		math.min(color.G * 0.9, 1) * 255,
		math.min(color.B * 0.9, 1) * 255
	), -30)
	
	ring(container, 0.5, 0.5, 0.16, color)
	local teeth = 8
	for i = 1, teeth do
		local angle = (i - 1) * (360 / teeth)
		local rad = math.rad(angle)
		local x1 = 0.5 + math.cos(rad) * 0.32
		local y1 = 0.5 + math.sin(rad) * 0.32
		local x2 = 0.5 + math.cos(rad) * 0.44
		local y2 = 0.5 + math.sin(rad) * 0.44
		line(container, x1, y1, x2, y2, color, 0.13)
	end
end

-- ══════════════════════════════════════════════════════════
--   FUNÇÕES DA LIB
-- ══════════════════════════════════════════════════════════

local function drawIcon(container, name, color)
	local fn = Icons[name]
	if fn then
		fn(container, color)
	end
end

MacOSLib.Themes = Themes
MacOSLib.Icons = Icons

function MacOSLib:CreateWindow(config)
	config = config or {}
	local title       = config.Title     or "MacOS UI"
	local subtitle    = config.Subtitle  or "v1.0"
	local width       = config.Width     or 520
	local height      = config.Height    or 360
	local key         = config.ToggleKey or Enum.KeyCode.RightControl
	local themeName   = config.Theme     or "Light"
	local Theme       = Themes[themeName] or Themes.Light

	local gui = create("ScreenGui", {
		Name = "MacOSLib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		if gethui then
			gui.Parent = gethui()
		else
			gui.Parent = game:GetService("CoreGui")
		end
	end)
	if not gui.Parent then
		gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Sombra com gradiente
	local shadow = create("Frame", {
		Name = "Shadow",
		Size = UDim2.new(0, width + 20, 0, height + 20),
		Position = UDim2.new(0.5, -(width / 2) - 10, 0.5, -(height / 2) - 10),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = gui,
	})
	corner(shadow, 16)
	
	-- Gradiente na sombra
	addGradient(shadow, Color3.fromRGB(0, 0, 0), Color3.fromRGB(50, 50, 50), 45)

	local restoreSize = UDim2.new(0, width, 0, height)
	local restorePos = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	local isMaximized = false
	local isMinimized = false

	local window = create("CanvasGroup", {
		Name = "Window",
		Size = restoreSize,
		Position = restorePos,
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = Theme.Glass.Window,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = gui,
	})
	corner(window, 12)
	stroke(window, Theme.Divider, 1.5, 0.15)
	
	-- Gradiente na janela
	local windowGrad = addGradient(window, Theme.Gradient.Top, Theme.Gradient.Bottom, 45)
	
	-- Glow na janela
	addGlow(window, Theme.Glow, 8, 0.7)

	local topbar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.TopBar,
		BackgroundTransparency = Theme.Glass.TopBar,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = window,
	})
	
	-- Gradiente na topbar
	addGradient(topbar, Theme.Gradient.Top, Theme.Gradient.Bottom, 30)

	local topbarDivider = create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = topbar,
	})

	local trafficColors = {
		Color3.fromRGB(255, 95, 87),
		Color3.fromRGB(255, 189, 46),
		Color3.fromRGB(39, 201, 63),
	}
	local trafficX = 14
	for i = 1, 3 do
		local dot = create("Frame", {
			Size = UDim2.new(0, 13, 0, 13),
			Position = UDim2.new(0, trafficX, 0.5, -6),
			BackgroundColor3 = trafficColors[i],
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = topbar,
		})
		corner(dot, 50)
		-- Glow nos botões de tráfego
		addGlow(dot, trafficColors[i], 4, 0.4)

		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = dot,
		})

		if i == 1 then
			btn.MouseButton1Click:Connect(function()
				tween(shadow, { BackgroundTransparency = 1 }, 0.2)
				tween(window, { BackgroundTransparency = 1, Size = UDim2.new(0, width, 0, 0) }, 0.2)
				task.delay(0.25, function()
					gui:Destroy()
				end)
			end)
		elseif i == 2 then
			btn.MouseButton1Click:Connect(function()
				isMinimized = not isMinimized
				if isMinimized then
					tween(window, { Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, 44) }, 0.25)
					tween(shadow, { Size = UDim2.new(0, window.Size.X.Offset + 20, 0, 64) }, 0.25)
				else
					tween(window, { Size = restoreSize }, 0.25)
					tween(shadow, { Size = UDim2.new(0, restoreSize.X.Offset + 20, 0, restoreSize.Y.Offset + 20) }, 0.25)
				end
			end)
		elseif i == 3 then
			btn.MouseButton1Click:Connect(function()
				isMaximized = not isMaximized
				if isMaximized then
					isMinimized = false
					tween(window, {
						Size = UDim2.new(1, -40, 1, -40),
						Position = UDim2.new(0, 20, 0, 20),
					}, 0.25)
					tween(shadow, {
						Size = UDim2.new(1, -24, 1, -24),
						Position = UDim2.new(0, 12, 0, 12),
					}, 0.25)
				else
					tween(window, { Size = restoreSize, Position = restorePos }, 0.25)
					tween(shadow, {
						Size = UDim2.new(0, restoreSize.X.Offset + 20, 0, restoreSize.Y.Offset + 20),
					}, 0.25)
				end
			end)
		end
	end

	local titleLabel = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		ZIndex = 3,
		Parent = topbar,
	})

	local subtitleLabel = create("TextLabel", {
		Name = "Subtitle",
		Size = UDim2.new(0, 120, 1, 0),
		Position = UDim2.new(1, -128, 0, 0),
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = Theme.SubText,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = topbar,
	})

	makeDraggable(window, topbar)

	RunService.RenderStepped:Connect(function()
		shadow.Position = UDim2.new(
			window.Position.X.Scale,
			window.Position.X.Offset - 10,
			window.Position.Y.Scale,
			window.Position.Y.Offset - 10
		)
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == key then
			window.Visible = not window.Visible
			shadow.Visible = window.Visible
		end
	end)

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 130, 1, -44),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = Theme.Glass.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = window,
	})
	
	-- Gradiente na sidebar
	addGradient(sidebar, Theme.Gradient.Top, Theme.Gradient.Bottom, 45)

	local sidebarDivider = create("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local tabList = create("Frame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.new(0, 0, 0, 8),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	listlayout(tabList, 2)
	padding(tabList, 0, 8, 8, 0)

	local contentHolder = create("Frame", {
		Name = "ContentHolder",
		Size = UDim2.new(1, -130, 1, -44),
		Position = UDim2.new(0, 130, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = window,
	})

	window.Size = UDim2.new(0, width, 0, 0)
	window.BackgroundTransparency = 1
	shadow.BackgroundTransparency = 1
	tween(window, { Size = restoreSize, BackgroundTransparency = Theme.Glass.Window }, 0.3, Enum.EasingStyle.Back)
	tween(shadow, { BackgroundTransparency = 0.85 }, 0.3)

	local Window = {}
	Window._tabs = {}
	Window._activeTab = nil
	Window._theme = Theme
	Window._themeName = themeName
	Window._openDropdownClosers = {}

	function Window:_closeAllDropdowns()
		for _, closeFn in ipairs(Window._openDropdownClosers) do
			closeFn()
		end
	end

	function Window:SetTheme(newThemeName)
		local NewTheme = Themes[newThemeName]
		if not NewTheme then return end
		Theme = NewTheme
		Window._theme = NewTheme
		Window._themeName = newThemeName

		tween(window, { BackgroundColor3 = NewTheme.Background, BackgroundTransparency = NewTheme.Glass.Window }, 0.25)
		tween(topbar, { BackgroundColor3 = NewTheme.TopBar, BackgroundTransparency = NewTheme.Glass.TopBar }, 0.25)
		tween(sidebar, { BackgroundColor3 = NewTheme.Sidebar, BackgroundTransparency = NewTheme.Glass.Sidebar }, 0.25)
		tween(topbarDivider, { BackgroundColor3 = NewTheme.Divider }, 0.25)
		tween(sidebarDivider, { BackgroundColor3 = NewTheme.Divider }, 0.25)
		tween(titleLabel, { TextColor3 = NewTheme.Text }, 0.25)
		tween(subtitleLabel, { TextColor3 = NewTheme.SubText }, 0.25)
		
		-- Atualizar gradientes
		windowGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, NewTheme.Gradient.Top),
			ColorSequenceKeypoint.new(1, NewTheme.Gradient.Bottom)
		})
		
		local windowStroke = window:FindFirstChildOfClass("UIStroke")
		if windowStroke then
			tween(windowStroke, { Color = NewTheme.Divider }, 0.25)
		end

		for _, t in pairs(Window._tabs) do
			t:_repaint(NewTheme)
		end
	end

	function Window:_setActive(tab)
		if self._activeTab == tab then return end
		self._activeTab = tab
		self:_closeAllDropdowns()
		for _, t in pairs(self._tabs) do
			local isActive = (t == tab)
			tween(t._btn, {
				BackgroundColor3 = isActive and Theme.TabActive or Theme.TabInactive,
			}, 0.15)
			t._label.TextColor3 = isActive and Theme.Text or Theme.SubText
			t._label.Font = isActive and Enum.Font.GothamSemibold or Enum.Font.Gotham
			if t._iconHolder then
				local targetColor = isActive and Theme.IconStrokeActive or Theme.IconStroke
				for _, child in ipairs(t._iconHolder:GetDescendants()) do
					if child:IsA("Frame") and child.BackgroundTransparency == 0 then
						child.BackgroundColor3 = targetColor
					end
					local st = child:IsA("UIStroke") and child or nil
					if st then
						st.Color = targetColor
					end
				end
			end
			t._page.Visible = isActive
		end
	end

	function Window:Notify(ntitle, message, duration)
		duration = duration or 3
		local T = Window._theme
		local notif = create("Frame", {
			Size = UDim2.new(0, 260, 0, 64),
			Position = UDim2.new(1, 10, 1, -80),
			BackgroundColor3 = T.ButtonBG,
			BorderSizePixel = 0,
			ZIndex = 50,
			Parent = gui,
		})
		corner(notif, 12)
		stroke(notif, T.Divider, 1, 0.3)
		
		-- Gradiente na notificação
		addGradient(notif, T.Gradient.Top, T.Gradient.Bottom, 30)

		local ntitleLabel = create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 22),
			Position = UDim2.new(0, 14, 0, 10),
			BackgroundTransparency = 1,
			Text = ntitle,
			TextColor3 = T.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 50,
			Parent = notif,
		})
		local nmsg = create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 18),
			Position = UDim2.new(0, 14, 0, 32),
			BackgroundTransparency = 1,
			Text = message,
			TextColor3 = T.SubText,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 50,
			Parent = notif,
		})
		local bar = create("Frame", {
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, 1, -3),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			ZIndex = 50,
			Parent = notif,
		})
		corner(bar, 50)
		-- Glow na barra de progresso
		addGlow(bar, T.Accent, 4, 0.5)
		
		tween(notif, { Position = UDim2.new(1, -270, 1, -80) }, 0.4, Enum.EasingStyle.Back)
		tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			tween(notif, { Position = UDim2.new(1, 10, 1, -80) }, 0.3)
			task.delay(0.35, function()
				notif:Destroy()
			end)
		end)
	end

	function Window:CreateTab(name, icon)
		local tab = {}
		tab._widgets = {}

		local btn = create("TextButton", {
			Name = name .. "_Tab",
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.TabInactive,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = tabList,
		})
		corner(btn, 8)
		-- Glow sutil na aba
		addGlow(btn, Theme.Glow, 4, 0.8)

		local hasIcon = icon ~= nil and Icons[icon] ~= nil
		local iconHolder = nil
		if hasIcon then
			iconHolder = create("Frame", {
				Name = "Icon",
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 9, 0.5, -9),
				BackgroundTransparency = 1,
				Parent = btn,
			})
			drawIcon(iconHolder, icon, Theme.IconStroke)
		end

		local labelOffset = hasIcon and 34 or 10
		local label = create("TextLabel", {
			Name = "Label",
			Size = UDim2.new(1, -labelOffset - 4, 1, 0),
			Position = UDim2.new(0, labelOffset, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Theme.SubText,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

		local page = create("ScrollingFrame", {
			Name = name .. "_Page",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = contentHolder,
		})
		listlayout(page, 8)
		padding(page, 12, 14, 14, 12)

		tab._btn = btn
		tab._page = page
		tab._label = label
		tab._iconHolder = iconHolder
		tab._iconName = icon

		function tab:_repaint(NewTheme)
			local isActive = (Window._activeTab == tab)
			btn.BackgroundColor3 = isActive and NewTheme.TabActive or NewTheme.TabInactive
			label.TextColor3 = isActive and NewTheme.Text or NewTheme.SubText
			page.ScrollBarImageColor3 = NewTheme.Accent
			if iconHolder then
				iconHolder:ClearAllChildren()
				local targetColor = isActive and NewTheme.IconStrokeActive or NewTheme.IconStroke
				drawIcon(iconHolder, tab._iconName, targetColor)
			end
			for _, w in ipairs(tab._widgets) do
				w(NewTheme)
			end
		end

		btn.MouseButton1Click:Connect(function()
			Window:_setActive(tab)
		end)
		btn.MouseEnter:Connect(function()
			if Window._activeTab ~= tab then
				tween(btn, { BackgroundColor3 = Window._theme.ButtonHover }, 0.1)
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window._activeTab ~= tab then
				tween(btn, { BackgroundColor3 = Window._theme.TabInactive }, 0.1)
			end
		end)

		table.insert(Window._tabs, tab)
		if #Window._tabs == 1 then
			Window:_setActive(tab)
		end

		function tab:AddSection(text)
			local s = create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Text = string.upper(text),
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			table.insert(tab._widgets, function(T)
				s.TextColor3 = T.SubText
			end)
		end

		function tab:AddButton(text, callback)
			local row = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Theme.Glass.Card,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			local rowStroke = stroke(row, Theme.Divider, 1, 0.5)
			-- Glow no botão
			addGlow(row, Theme.Glow, 4, 0.7)

			local rowLabel = create("TextLabel", {
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})

			local chevHolder = create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -24, 0.5, -7),
				BackgroundTransparency = 1,
				Parent = row,
			})
			line(chevHolder, 0.3, 0.15, 0.7, 0.5, Theme.SubText, 0.12)
			line(chevHolder, 0.7, 0.5, 0.3, 0.85, Theme.SubText, 0.12)

			row.MouseEnter:Connect(function()
				tween(row, { BackgroundColor3 = Window._theme.ButtonHover }, 0.1)
			end)
			row.MouseLeave:Connect(function()
				tween(row, { BackgroundColor3 = Window._theme.ButtonBG }, 0.1)
			end)
			row.MouseButton1Click:Connect(function()
				tween(row, { BackgroundColor3 = Window._theme.Divider }, 0.08)
				task.delay(0.1, function()
					tween(row, { BackgroundColor3 = Window._theme.ButtonBG }, 0.1)
				end)
				if callback then callback() end
			end)

			table.insert(tab._widgets, function(T)
				row.BackgroundColor3 = T.ButtonBG
				row.BackgroundTransparency = T.Glass.Card
				rowStroke.Color = T.Divider
				rowLabel.TextColor3 = T.Text
				for _, c in ipairs(chevHolder:GetChildren()) do
					c.BackgroundColor3 = T.SubText
				end
			end)
			return row
		end

		function tab:AddToggle(text, default, callback)
			local value = default or false
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Theme.Glass.Card,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			local rowStroke = stroke(row, Theme.Divider, 1, 0.5)
			addGlow(row, Theme.Glow, 4, 0.7)

			local rowLabel = create("TextLabel", {
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})

			local track = create("Frame", {
				Size = UDim2.new(0, 36, 0, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
				BorderSizePixel = 0,
				Parent = row,
			})
			corner(track, 50)
			addGlow(track, value and Theme.ToggleOn or Theme.ToggleOff, 4, 0.6)

			local thumb = create("Frame", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, value and 18 or 2, 0.5, -8),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			corner(thumb, 50)
			addGlow(thumb, Theme.White, 3, 0.5)

			local clickArea = create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				Parent = row,
			})
			clickArea.MouseButton1Click:Connect(function()
				value = not value
				tween(track, { BackgroundColor3 = value and Window._theme.ToggleOn or Window._theme.ToggleOff }, 0.2)
				tween(thumb, { Position = UDim2.new(0, value and 18 or 2, 0.5, -8) }, 0.2)
				if callback then callback(value) end
			end)

			table.insert(tab._widgets, function(T)
				row.BackgroundColor3 = T.ButtonBG
				row.BackgroundTransparency = T.Glass.Card
				rowStroke.Color = T.Divider
				rowLabel.TextColor3 = T.Text
				thumb.BackgroundColor3 = T.White
				track.BackgroundColor3 = value and T.ToggleOn or T.ToggleOff
			end)

			local toggle = {}
			function toggle:Set(v)
				value = v
				tween(track, { BackgroundColor3 = value and Window._theme.ToggleOn or Window._theme.ToggleOff }, 0.2)
				tween(thumb, { Position = UDim2.new(0, value and 18 or 2, 0.5, -8) }, 0.2)
			end
			function toggle:Get() return value end
			return toggle
		end

		function tab:AddSlider(text, min, max, default, callback)
			min = min or 0
			max = max or 100
			local value = default or min

			local container = create("Frame", {
				Size = UDim2.new(1, 0, 0, 58),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Theme.Glass.Card,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(container, 8)
			local containerStroke = stroke(container, Theme.Divider, 1, 0.5)
			addGlow(container, Theme.Glow, 4, 0.7)

			local sliderLabel = create("TextLabel", {
				Size = UDim2.new(1, -16, 0, 28),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})
			local valLabel = create("TextLabel", {
				Size = UDim2.new(0, 50, 0, 28),
				Position = UDim2.new(1, -60, 0, 0),
				BackgroundTransparency = 1,
				Text = tostring(math.round(value)),
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = container,
			})

			local track = create("Frame", {
				Size = UDim2.new(1, -28, 0, 4),
				Position = UDim2.new(0, 14, 1, -18),
				BackgroundColor3 = Theme.SliderBG,
				BorderSizePixel = 0,
				Parent = container,
			})
			corner(track, 50)

			local fill = create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Theme.SliderFill,
				BorderSizePixel = 0,
				Parent = track,
			})
			corner(fill, 50)
			addGlow(fill, Theme.SliderFill, 4, 0.5)

			local knob = create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			corner(knob, 50)
			local knobStroke = stroke(knob, Theme.SliderFill, 2, 0)
			addGlow(knob, Theme.White, 4, 0.5)

			local dragging = false
			local function updateSlider(input)
				local relX = math.clamp(
					(input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
					0, 1
				)
				value = math.round(min + (max - min) * relX)
				valLabel.Text = tostring(value)
				tween(fill, { Size = UDim2.new(relX, 0, 1, 0) }, 0.05)
				tween(knob, { Position = UDim2.new(relX, -7, 0.5, -7) }, 0.05)
				if callback then callback(value) end
			end
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateSlider(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input)
				end
			end)

			table.insert(tab._widgets, function(T)
				container.BackgroundColor3 = T.ButtonBG
				container.BackgroundTransparency = T.Glass.Card
				containerStroke.Color = T.Divider
				sliderLabel.TextColor3 = T.Text
				valLabel.TextColor3 = T.SubText
				track.BackgroundColor3 = T.SliderBG
				fill.BackgroundColor3 = T.SliderFill
				knob.BackgroundColor3 = T.White
				knobStroke.Color = T.SliderFill
			end)

			local slider = {}
			function slider:Set(v)
				value = math.clamp(v, min, max)
				local relX = (value - min) / (max - min)
				valLabel.Text = tostring(value)
				tween(fill, { Size = UDim2.new(relX, 0, 1, 0) }, 0.1)
				tween(knob, { Position = UDim2.new(relX, -7, 0.5, -7) }, 0.1)
			end
			function slider:Get() return value end
			return slider
		end

		function tab:AddInput(text, placeholder, callback)
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Theme.Glass.Card,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			local rowStroke = stroke(row, Theme.Divider, 1, 0.5)
			addGlow(row, Theme.Glow, 4, 0.7)

			local inputLabel = create("TextLabel", {
				Size = UDim2.new(0.42, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})
			local inputBox = create("TextBox", {
				Size = UDim2.new(0.52, 0, 0, 24),
				Position = UDim2.new(0.44, 0, 0.5, -12),
				BackgroundColor3 = Theme.InputBG,
				BorderSizePixel = 0,
				Text = "",
				PlaceholderText = placeholder or "...",
				PlaceholderColor3 = Theme.SubText,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				ClearTextOnFocus = false,
				Parent = row,
			})
			corner(inputBox, 6)
			local inputStroke = stroke(inputBox, Theme.Accent, 1, 0.6)
			padding(inputBox, 0, 8, 8, 0)
			addGlow(inputBox, Theme.Glow, 3, 0.6)

			inputBox.FocusLost:Connect(function(enter)
				if enter and callback then
					callback(inputBox.Text)
				end
			end)

			table.insert(tab._widgets, function(T)
				row.BackgroundColor3 = T.ButtonBG
				row.BackgroundTransparency = T.Glass.Card
				rowStroke.Color = T.Divider
				inputLabel.TextColor3 = T.Text
				inputBox.BackgroundColor3 = T.InputBG
				inputBox.TextColor3 = T.Text
				inputBox.PlaceholderColor3 = T.SubText
				inputStroke.Color = T.Accent
			end)
			return inputBox
		end

		function tab:AddDropdown(text, options, callback)
			local selected = options[1] or ""
			local open = false

			local container = create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Theme.Glass.Card,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(container, 8)
			local containerStroke = stroke(container, Theme.Divider, 1, 0.5)
			addGlow(container, Theme.Glow, 4, 0.7)

			local ddLabel = create("TextLabel", {
				Size = UDim2.new(0.48, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = container,
			})

			local selectedLabel = create("TextButton", {
				Size = UDim2.new(0.46, 0, 0, 24),
				Position = UDim2.new(0.5, 0, 0.5, -12),
				BackgroundColor3 = Theme.InputBG,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = container,
			})
			corner(selectedLabel, 6)
			local selectedStroke = stroke(selectedLabel, Theme.Divider, 1, 0.5)
			addGlow(selectedLabel, Theme.Glow, 3, 0.6)

			local selectedText = create("TextLabel", {
				Size = UDim2.new(1, -24, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = selectedLabel,
			})

			local chevronHolder = create("Frame", {
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(1, -16, 0.5, -5),
				BackgroundTransparency = 1,
				Parent = selectedLabel,
			})
			line(chevronHolder, 0.12, 0.32, 0.5, 0.7, Theme.SubText, 0.16)
			line(chevronHolder, 0.5, 0.7, 0.88, 0.32, Theme.SubText, 0.16)

			local overlay = create("Frame", {
				Name = "DropdownOverlay",
				BackgroundTransparency = 1,
				ZIndex = 100,
				Visible = false,
				Parent = gui,
			})

			local dropList = create("Frame", {
				Size = UDim2.new(0, 0, 0, #options * 30 + 8),
				BackgroundColor3 = Theme.ButtonBG,
				BorderSizePixel = 0,
				ZIndex = 100,
				Parent = overlay,
			})
			corner(dropList, 8)
			local dropStroke = stroke(dropList, Theme.Divider, 1, 0.3)
			listlayout(dropList, 0)
			padding(dropList, 4, 0, 0, 4)
			addGlow(dropList, Theme.Glow, 6, 0.8)

			local optionButtons = {}
			for _, opt in ipairs(options) do
				local optBtn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					Text = opt,
					TextColor3 = Theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					ZIndex = 100,
					Parent = dropList,
				})
				table.insert(optionButtons, optBtn)
				optBtn.MouseEnter:Connect(function()
					tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = Window._theme.ButtonHover }, 0.08)
				end)
				optBtn.MouseLeave:Connect(function()
					tween(optBtn, { BackgroundTransparency = 1 }, 0.08)
				end)
				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					selectedText.Text = opt
					overlay.Visible = false
					open = false
					tween(chevronHolder, { Rotation = 0 }, 0.15)
				end)
				if callback then
					optBtn.MouseButton1Click:Connect(function()
						callback(opt)
					end)
				end
			end

			local function repositionOverlay()
				local pos = selectedLabel.AbsolutePosition
				local size = selectedLabel.AbsoluteSize
				overlay.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + 4)
				dropList.Size = UDim2.new(0, size.X, 0, #options * 30 + 8)
			end

			local moveConn = nil
			local function closeDropdown()
				if not open then return end
				open = false
				overlay.Visible = false
				tween(chevronHolder, { Rotation = 0 }, 0.15)
				if moveConn then
					moveConn:Disconnect()
					moveConn = nil
				end
			end
			table.insert(Window._openDropdownClosers, closeDropdown)

			selectedLabel.MouseButton1Click:Connect(function()
				if open then
					closeDropdown()
				else
					Window:_closeAllDropdowns()
					open = true
					repositionOverlay()
					overlay.Visible = true
					tween(chevronHolder, { Rotation = 180 }, 0.15)
					moveConn = RunService.RenderStepped:Connect(repositionOverlay)
				end
			end)

			table.insert(tab._widgets, function(T)
				container.BackgroundColor3 = T.ButtonBG
				container.BackgroundTransparency = T.Glass.Card
				containerStroke.Color = T.Divider
				ddLabel.TextColor3 = T.Text
				selectedLabel.BackgroundColor3 = T.InputBG
				selectedStroke.Color = T.Divider
				selectedText.TextColor3 = T.Text
				dropList.BackgroundColor3 = T.ButtonBG
				dropStroke.Color = T.Divider
				for _, c in ipairs(chevronHolder:GetChildren()) do
					c.BackgroundColor3 = T.SubText
				end
				for _, optBtn in ipairs(optionButtons) do
					optBtn.TextColor3 = T.Text
				end
				closeDropdown()
			end)

			local dd = {}
			function dd:Set(v) selected = v; selectedText.Text = v end
			function dd:Get() return selected end
			return dd
		end

		function tab:AddLabel(text)
			local lbl = create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.SubText,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			table.insert(tab._widgets, function(T)
				lbl.TextColor3 = T.SubText
			end)
		end

		return tab
	end

	return Window
end

return MacOSLib
