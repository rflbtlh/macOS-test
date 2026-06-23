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
--   TEMAS
--   Cada tema é uma tabela completa de cores. Pra criar um
--   tema novo, basta copiar um existente e trocar as cores.
--   "Glass" controla a transparência de cada camada (igual
--   em todos os temas, mas pode ser sobrescrito por tema se
--   quiser um vidro mais ou menos opaco em algum deles).
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
}

-- ══════════════════════════════════════════════════════════
--   ÍCONES ESTILO LUCIDE
--   Lucide usa traços finos (stroke, sem preenchimento),
--   pontas redondas e viewBox 24x24 com stroke-width 2.
--   Reproduzimos isso aqui com "linhas" (Frames bem finos
--   com UICorner total, ou seja, formato cápsula) — a mesma
--   técnica de ponta arredondada do Lucide, só que feita com
--   Frames em vez de SVG <path>, já que o Roblox não
--   renderiza SVG nativamente.
--
--   Cada ícone recebe um container quadrado (em Scale 0–1)
--   e uma cor, e desenha os traços dentro dele.
-- ══════════════════════════════════════════════════════════

local Icons = {}

-- desenha uma "linha" fina com ponta redonda entre dois pontos relativos (0–1)
--
-- IMPORTANTE: no Roblox, a propriedade Rotation de um Frame SEMPRE
-- gira em torno do CENTRO do frame, mesmo que o AnchorPoint seja
-- outro (ex: a ponta esquerda). Isso é uma particularidade conhecida
-- do motor (rotação ignora AnchorPoint). Por isso usamos AnchorPoint
-- (0.5, 0.5) e calculamos o PONTO MÉDIO entre (x1,y1) e (x2,y2) como
-- posição central do frame — assim a rotação em torno do centro
-- coincide exatamente com o segmento que queremos desenhar.
--
-- O corner usa UDim.new(1, 0) (Scale = 1) em vez de um valor fixo em
-- pixels: isso garante uma "cápsula" perfeita (raio = metade da
-- espessura) em qualquer tamanho de ícone, igual ao stroke-linecap
-- "round" do Lucide — um corner fixo em offset deformava a ponta em
-- ícones pequenos.
local function line(parent, x1, y1, x2, y2, color, thickness)
	thickness = thickness or 0.07
	local dx, dy = x2 - x1, y2 - y1
	local length = math.sqrt(dx * dx + dy * dy)
	local angle = math.atan2(dy, dx)
	local midX, midY = (x1 + x2) / 2, (y1 + y2) / 2

	local seg = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Rotation = math.deg(angle),
		Parent = parent,
	})
	local segCorner = Instance.new("UICorner")
	segCorner.CornerRadius = UDim.new(1, 0)
	segCorner.Parent = seg
	local function layout()
		local absSize = parent.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		seg.Size = UDim2.new(0, length * base, 0, thickness * base)
		seg.Position = UDim2.new(midX, 0, midY, 0)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return seg
end

-- desenha um arco suave (curva) entre dois ângulos, em torno de um
-- centro relativo (cx, cy) e raio "r" — usado pra suavizar ícones
-- que no Lucide original usam curvas (Volume, Bell) em vez de só
-- segmentos retos. Internamente é feito com vários segmentos curtos
-- de "line()" interpolados, mas a olho nu aparenta uma curva contínua.
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

-- desenha um círculo (apenas contorno, igual ao stroke do Lucide)
local function ring(parent, cx, cy, r, color, thickness)
	thickness = thickness or 0.07
	local c = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	corner(c, 100)
	local ringStroke = stroke(c, color, 2, 0)
	local function layout()
		local absSize = parent.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		c.Position = UDim2.new(cx, 0, cy, 0)
		c.Size = UDim2.new(0, r * 2 * base, 0, r * 2 * base)
		ringStroke.Thickness = math.max(1, thickness * base)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	c.ZIndex = 1
	return c
end

-- desenha um retângulo arredondado (apenas contorno)
local function roundRect(parent, x, y, w, h, color, radius)
	local r = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(w, 0, h, 0),
		Parent = parent,
	})
	corner(r, radius or 4)
	local rectStroke = stroke(r, color, 2, 0)
	local function layout()
		local absSize = parent.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		rectStroke.Thickness = math.max(1, 0.07 * base)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return r
end

-- house (Principal)
Icons.House = function(parent, color)
	line(parent, 0.5, 0.08, 0.92, 0.46, color)
	line(parent, 0.5, 0.08, 0.08, 0.46, color)
	line(parent, 0.16, 0.4, 0.16, 0.92, color)
	line(parent, 0.84, 0.4, 0.84, 0.92, color)
	line(parent, 0.16, 0.92, 0.84, 0.92, color)
	line(parent, 0.4, 0.92, 0.4, 0.62, color)
	line(parent, 0.4, 0.62, 0.6, 0.62, color)
	line(parent, 0.6, 0.62, 0.6, 0.92, color)
end

-- palette (Visual)
Icons.Palette = function(parent, color)
	-- corpo externo da paleta (circulo grande levemente assimétrico, aproximado por anel)
	ring(parent, 0.48, 0.5, 0.42, color)
	-- pingos de tinta
	local dots = { {0.34, 0.32, 0.07}, {0.56, 0.28, 0.07}, {0.7, 0.46, 0.07}, {0.36, 0.62, 0.07} }
	for _, d in ipairs(dots) do
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = parent,
		})
		corner(dot, 100)
		local function layout()
			local absSize = parent.AbsoluteSize
			local base = math.min(absSize.X, absSize.Y)
			if base <= 0 then return end
			dot.Position = UDim2.new(d[1], 0, d[2], 0)
			dot.Size = UDim2.new(0, d[3] * 2 * base, 0, d[3] * 2 * base)
		end
		layout()
		parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	end
end

-- settings / gear (Config)
Icons.Settings = function(parent, color)
	ring(parent, 0.5, 0.5, 0.14, color)
	local teeth = 8
	for i = 1, teeth do
		local angle = (i - 1) * (360 / teeth)
		local rad = math.rad(angle)
		local x1 = 0.5 + math.cos(rad) * 0.3
		local y1 = 0.5 + math.sin(rad) * 0.3
		local x2 = 0.5 + math.cos(rad) * 0.42
		local y2 = 0.5 + math.sin(rad) * 0.42
		line(parent, x1, y1, x2, y2, color, 0.1)
	end
end

-- sliders-horizontal (uso geral)
Icons.Sliders = function(parent, color)
	local rows = { 0.26, 0.5, 0.74 }
	local knobX = { 0.66, 0.34, 0.56 }
	for i, y in ipairs(rows) do
		line(parent, 0.08, y, 0.92, y, color, 0.07)
		local knob = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = parent,
		})
		corner(knob, 100)
		local function layout()
			local absSize = parent.AbsoluteSize
			local base = math.min(absSize.X, absSize.Y)
			if base <= 0 then return end
			knob.Position = UDim2.new(knobX[i], 0, y, 0)
			knob.Size = UDim2.new(0, 0.1 * base, 0, 0.1 * base)
		end
		layout()
		parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	end
end

-- volume-2 / speaker (Áudio)
Icons.Volume = function(parent, color)
	-- corpo do alto-falante (mesma silhueta do "volume-2" do Lucide)
	line(parent, 0.06, 0.4, 0.28, 0.4, color)
	line(parent, 0.06, 0.4, 0.06, 0.6, color)
	line(parent, 0.06, 0.6, 0.28, 0.6, color)
	line(parent, 0.28, 0.4, 0.46, 0.22, color)
	line(parent, 0.28, 0.6, 0.46, 0.78, color)
	line(parent, 0.46, 0.22, 0.46, 0.78, color)
	-- ondas sonoras como arcos suaves (em vez de segmentos retos),
	-- mais fiel ao traço curvo do ícone original do Lucide
	arc(parent, 0.42, 0.5, 0.18, -45, 45, color, 0.07, 5)
	arc(parent, 0.42, 0.5, 0.32, -55, 55, color, 0.07, 6)
end

-- info (Sobre)
Icons.Info = function(parent, color)
	ring(parent, 0.5, 0.5, 0.4, color)
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(dot, 100)
	local function dotLayout()
		local absSize = parent.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		dot.Position = UDim2.new(0.5, 0, 0.28, 0)
		dot.Size = UDim2.new(0, 0.07 * base, 0, 0.07 * base)
	end
	dotLayout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(dotLayout)
	line(parent, 0.5, 0.46, 0.5, 0.74, color)
end

-- star (uso geral / favoritos)
Icons.Star = function(parent, color)
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
		line(parent, p1[1], p1[2], p2[1], p2[2], color, 0.07)
	end
end

-- shield (uso geral / segurança)
Icons.Shield = function(parent, color)
	line(parent, 0.5, 0.06, 0.86, 0.22, color)
	line(parent, 0.86, 0.22, 0.86, 0.5, color)
	line(parent, 0.86, 0.5, 0.5, 0.92, color)
	line(parent, 0.5, 0.92, 0.14, 0.5, color)
	line(parent, 0.14, 0.5, 0.14, 0.22, color)
	line(parent, 0.14, 0.22, 0.5, 0.06, color)
end

-- monitor (gráficos / display)
Icons.Monitor = function(parent, color)
	roundRect(parent, 0.08, 0.14, 0.84, 0.56, color, 6)
	line(parent, 0.5, 0.7, 0.5, 0.86, color)
	line(parent, 0.3, 0.86, 0.7, 0.86, color)
end

-- user (perfil)
Icons.User = function(parent, color)
	ring(parent, 0.5, 0.32, 0.16, color)
	line(parent, 0.18, 0.88, 0.22, 0.68, color)
	line(parent, 0.22, 0.68, 0.78, 0.68, color)
	line(parent, 0.78, 0.68, 0.82, 0.88, color)
	line(parent, 0.18, 0.88, 0.82, 0.88, color)
end

-- bell (notificações)
Icons.Bell = function(parent, color)
	-- corpo do sino com ombros curvos (igual ao "bell" do Lucide)
	arc(parent, 0.5, 0.42, 0.28, 200, 340, color, 0.07, 6)
	line(parent, 0.22, 0.58, 0.22, 0.42, color)
	line(parent, 0.78, 0.58, 0.78, 0.42, color)
	line(parent, 0.2, 0.6, 0.8, 0.6, color)
	-- badulaque (clapper)
	line(parent, 0.44, 0.7, 0.56, 0.7, color, 0.07)
end

-- ══════════════════════════════════════════════════════════
--   ÍCONES ESTILO FLUENT UI (Microsoft)
--   Mesma técnica vetorial dos ícones Lucide acima (sem
--   nenhum asset externo ou loadstring de terceiros — só
--   Frames desenhados na hora). A diferença é só de ESTILO:
--   a Fluent UI "regular" tende a ter formas mais geométricas
--   e cantos mais retos que o Lucide (que é mais orgânico e
--   com cantos bem arredondados). Use o nome com prefixo
--   "Fluent" em CreateTab, ex: CreateTab("Principal", "FluentHome")
-- ══════════════════════════════════════════════════════════

Icons.FluentHome = function(parent, color)
	-- telhado triangular mais reto/geométrico (estilo Fluent)
	line(parent, 0.5, 0.08, 0.88, 0.4, color)
	line(parent, 0.5, 0.08, 0.12, 0.4, color)
	roundRect(parent, 0.2, 0.38, 0.6, 0.5, color, 3)
	-- porta retangular reta (sem arredondamento, característico da Fluent)
	line(parent, 0.42, 0.88, 0.42, 0.62, color)
	line(parent, 0.42, 0.62, 0.58, 0.62, color)
	line(parent, 0.58, 0.62, 0.58, 0.88, color)
end

Icons.FluentSettings = function(parent, color)
	-- engrenagem com dentes retangulares retos (Fluent usa menos
	-- curvas que o Lucide nos dentes da engrenagem)
	ring(parent, 0.5, 0.5, 0.16, color)
	local teeth = 8
	for i = 1, teeth do
		local angle = (i - 1) * (360 / teeth)
		local rad = math.rad(angle)
		local x1 = 0.5 + math.cos(rad) * 0.32
		local y1 = 0.5 + math.sin(rad) * 0.32
		local x2 = 0.5 + math.cos(rad) * 0.44
		local y2 = 0.5 + math.sin(rad) * 0.44
		line(parent, x1, y1, x2, y2, color, 0.13)
	end
end

Icons.FluentPalette = function(parent, color)
	-- formato mais "quadrado/geométrico" que a paleta orgânica do Lucide
	roundRect(parent, 0.14, 0.14, 0.72, 0.72, color, 14)
	local dots = { {0.34, 0.34, 0.07}, {0.66, 0.34, 0.07}, {0.34, 0.66, 0.07}, {0.66, 0.66, 0.07} }
	for _, d in ipairs(dots) do
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = parent,
		})
		corner(dot, 100)
		local function layout()
			local absSize = parent.AbsoluteSize
			local base = math.min(absSize.X, absSize.Y)
			if base <= 0 then return end
			dot.Position = UDim2.new(d[1], 0, d[2], 0)
			dot.Size = UDim2.new(0, d[3] * 2 * base, 0, d[3] * 2 * base)
		end
		layout()
		parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	end
end

Icons.FluentVolume = function(parent, color)
	roundRect(parent, 0.06, 0.4, 0.22, 0.2, color, 2)
	line(parent, 0.28, 0.4, 0.46, 0.22, color)
	line(parent, 0.28, 0.6, 0.46, 0.78, color)
	line(parent, 0.46, 0.22, 0.46, 0.78, color)
	-- ondas retas e curtas, mais "técnicas" que orgânicas
	line(parent, 0.6, 0.42, 0.68, 0.42, color, 0.07)
	line(parent, 0.6, 0.58, 0.68, 0.58, color, 0.07)
	line(parent, 0.76, 0.32, 0.84, 0.32, color, 0.07)
	line(parent, 0.76, 0.68, 0.84, 0.68, color, 0.07)
end

Icons.FluentInfo = function(parent, color)
	roundRect(parent, 0.1, 0.1, 0.8, 0.8, color, 100)
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(dot, 100)
	local function dotLayout()
		local absSize = parent.AbsoluteSize
		local base = math.min(absSize.X, absSize.Y)
		if base <= 0 then return end
		dot.Position = UDim2.new(0.5, 0, 0.3, 0)
		dot.Size = UDim2.new(0, 0.08 * base, 0, 0.08 * base)
	end
	dotLayout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(dotLayout)
	line(parent, 0.5, 0.46, 0.5, 0.72, color, 0.1)
end

Icons.FluentBell = function(parent, color)
	-- sino com ombros retos (sem o arco suave da versão Lucide)
	line(parent, 0.5, 0.12, 0.5, 0.2, color)
	line(parent, 0.5, 0.2, 0.28, 0.36, color)
	line(parent, 0.28, 0.36, 0.22, 0.6, color)
	line(parent, 0.5, 0.2, 0.72, 0.36, color)
	line(parent, 0.72, 0.36, 0.78, 0.6, color)
	line(parent, 0.2, 0.6, 0.8, 0.6, color)
	line(parent, 0.44, 0.7, 0.56, 0.7, color, 0.07)
end

Icons.FluentShield = function(parent, color)
	-- escudo com topo reto (mais geométrico que o do Lucide, que é mais pontudo)
	line(parent, 0.22, 0.16, 0.78, 0.16, color)
	line(parent, 0.22, 0.16, 0.18, 0.46, color)
	line(parent, 0.78, 0.16, 0.82, 0.46, color)
	line(parent, 0.18, 0.46, 0.5, 0.88, color)
	line(parent, 0.82, 0.46, 0.5, 0.88, color)
end

Icons.FluentUser = function(parent, color)
	ring(parent, 0.5, 0.3, 0.15, color)
	roundRect(parent, 0.2, 0.56, 0.6, 0.32, color, 12)
end

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
	local subtitle     = config.Subtitle  or "v1.0"
	local width        = config.Width     or 520
	local height       = config.Height    or 360
	local key          = config.ToggleKey or Enum.KeyCode.RightControl
	local themeName    = config.Theme     or "Light"
	local Theme        = Themes[themeName] or Themes.Light

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

	local shadow = create("Frame", {
		Name = "Shadow",
		Size = UDim2.new(0, width + 16, 0, height + 16),
		Position = UDim2.new(0.5, -(width / 2) - 8, 0.5, -(height / 2) - 8),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = gui,
	})
	corner(shadow, 16)

	-- restoreSize guarda o tamanho/posição "normal" da janela pra
	-- restaurar quando o usuário sair do modo maximizado.
	local restoreSize = UDim2.new(0, width, 0, height)
	local restorePos = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	local isMaximized = false
	local isMinimized = false

	-- IMPORTANTE: usamos CanvasGroup em vez de Frame aqui.
	-- ClipsDescendants normal SÓ recorta no formato retangular do
	-- frame, mesmo com UICorner aplicado (isso é uma limitação
	-- conhecida e documentada do Roblox: UICorner é puramente visual
	-- e não redefine a área de clipe). CanvasGroup é o único jeito
	-- confiável de fazer o corte respeitar o canto arredondado de
	-- verdade — é ele que resolve o bug dos "cantos retos" no topo
	-- e na lateral esquerda que apareciam antes.
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

	-- FIX: topbar não tem mais o "topbarFix" duplicado (era ele que
	-- criava a linha visível no meio do título). Um único UICorner
	-- com Z-index correto já resolve o arredondamento do topo.
	local topbar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.TopBar,
		BackgroundTransparency = Theme.Glass.TopBar,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = window,
	})

	local topbarDivider = create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = topbar,
	})

	-- FIX: a janela inteira (window) já tem ClipsDescendants = true e
	-- UICorner com raio 12. Antes a topbar tinha seu próprio UICorner
	-- de raio 12 também, mas como ela é maior que o raio nas bordas
	-- inferiores, o corner ali não fazia diferença — o bug real do
	-- "canto reto" estava no ContentHolder (ver mais abaixo), que não
	-- herdava nenhum corner e vazava por fora do clip da janela em
	-- certas resoluções. Resolvido fazendo o ContentHolder ocupar
	-- exatamente a área restante sem nenhuma sobreposição de pixel
	-- com a borda da window, então o ClipsDescendants da própria
	-- window cuida do arredondamento.

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
		trafficX = trafficX + 20

		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = dot,
		})

		if i == 1 then
			-- fechar
			btn.MouseButton1Click:Connect(function()
				tween(shadow, { BackgroundTransparency = 1 }, 0.2)
				tween(window, { BackgroundTransparency = 1, Size = UDim2.new(0, width, 0, 0) }, 0.2)
				task.delay(0.25, function()
					gui:Destroy()
				end)
			end)
		elseif i == 2 then
			-- minimizar: encolhe a janela até só sobrar a topbar
			btn.MouseButton1Click:Connect(function()
				isMinimized = not isMinimized
				if isMinimized then
					tween(window, { Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, 44) }, 0.25)
					tween(shadow, { Size = UDim2.new(0, window.Size.X.Offset + 16, 0, 60) }, 0.25)
				else
					local target = isMaximized and restoreSize or restoreSize
					tween(window, { Size = restoreSize }, 0.25)
					tween(shadow, { Size = UDim2.new(0, restoreSize.X.Offset + 16, 0, restoreSize.Y.Offset + 16) }, 0.25)
				end
			end)
		elseif i == 3 then
			-- maximizar: ocupa quase toda a tela, alterna de volta ao tamanho original
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
						Size = UDim2.new(0, restoreSize.X.Offset + 16, 0, restoreSize.Y.Offset + 16),
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
			window.Position.X.Offset - 8,
			window.Position.Y.Scale,
			window.Position.Y.Offset - 8
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

	-- FIX: ContentHolder agora fica estritamente dentro da área da
	-- window (sem encostar 1px nas bordas externas), e a window é
	-- quem corta (ClipsDescendants) qualquer coisa que vaze. Isso
	-- elimina o "canto reto" que aparecia no inferior direito.
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
	tween(shadow, { BackgroundTransparency = 0.82 }, 0.3)

	local Window = {}
	Window._tabs = {}
	Window._activeTab = nil
	Window._theme = Theme
	Window._themeName = themeName
	Window._openDropdownClosers = {} -- registradas por AddDropdown, chamadas ao trocar de tab/tema

	function Window:_closeAllDropdowns()
		for _, closeFn in ipairs(Window._openDropdownClosers) do
			closeFn()
		end
	end

	-- ── Sistema de troca de tema em tempo real ──────────────
	-- Cada widget criado (botão, slider, dropdown, etc.) registra
	-- sua própria função de repaint em tab._widgets. Quando o tema
	-- muda, percorremos todas as tabs já criadas e chamamos essas
	-- funções, que atualizam cor/transparência sem precisar recriar
	-- nenhuma instância.

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
		local windowStroke = window:FindFirstChildOfClass("UIStroke")
		if windowStroke then
			tween(windowStroke, { Color = NewTheme.Divider }, 0.25)
		end

		-- repinta todas as tabs, páginas e widgets já criados
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
		tween(notif, { Position = UDim2.new(1, -270, 1, -80) }, 0.4, Enum.EasingStyle.Back)
		tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			tween(notif, { Position = UDim2.new(1, 10, 1, -80) }, 0.3)
			task.delay(0.35, function()
				notif:Destroy()
			end)
		end)
	end

	-- ── CreateTab ──────────────────────────────────────────
	-- "icon" é o NOME de um ícone Lucide-style registrado em
	-- Icons (ex: "House", "Settings", "Palette", "Sliders",
	-- "Volume", "Info", "Star", "Shield", "Monitor", "User",
	-- "Bell"). Se omitido ou inválido, a tab não mostra ícone.
	function Window:CreateTab(name, icon)
		local tab = {}
		tab._widgets = {} -- guarda widgets pra repaint de tema

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

		-- repinta a tab e todos os widgets dela quando o tema muda
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

			-- chevron vetorial (estilo Lucide chevron-right) em vez de ">"
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

			local thumb = create("Frame", {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, value and 18 or 2, 0.5, -8),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			corner(thumb, 50)

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

			local knob = create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			corner(knob, 50)
			local knobStroke = stroke(knob, Theme.SliderFill, 2, 0)

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

			-- chevron-down vetorial (estilo Lucide)
			local chevronHolder = create("Frame", {
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(1, -16, 0.5, -5),
				BackgroundTransparency = 1,
				Parent = selectedLabel,
			})
			line(chevronHolder, 0.12, 0.32, 0.5, 0.7, Theme.SubText, 0.16)
			line(chevronHolder, 0.5, 0.7, 0.88, 0.32, Theme.SubText, 0.16)

			-- ── Overlay do menu suspenso ─────────────────────────
			-- IMPORTANTE: o painel de opções (dropList) NÃO é filho
			-- de "container" nem de "page". Se fosse, ele ficaria
			-- preso dentro do ScrollingFrame da aba (que corta
			-- conteúdo fora da área visível) e, mais grave, perderia
			-- a "queda de braço" de profundidade pra qualquer outro
			-- card que viesse depois dele na lista (Z-index no
			-- Roblox é hierárquico: filhos nunca furam a "camada" de
			-- outro ramo da árvore). A solução usada por toda lib de
			-- UI séria no Roblox é desenhar o menu num overlay
			-- separado, direto no ScreenGui raiz, e posicioná-lo
			-- manualmente em coordenadas absolutas de tela.
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

			-- recalcula a posição do overlay em coordenadas absolutas
			-- de tela, sempre relativa à posição atual de selectedLabel
			-- (que pode se mover se a janela for arrastada/redimensionada)
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
					-- fecha qualquer outro dropdown aberto antes de abrir este
					Window:_closeAllDropdowns()
					open = true
					repositionOverlay()
					overlay.Visible = true
					tween(chevronHolder, { Rotation = 180 }, 0.15)
					-- mantém o overlay colado embaixo do dropdown mesmo
					-- se a janela for arrastada enquanto está aberto
					moveConn = RunService.RenderStepped:Connect(repositionOverlay)
				end
			end)

			-- fecha o dropdown se o tema mudar (evita overlay com
			-- cores velhas pendurado na tela) e se a tab perder foco
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
