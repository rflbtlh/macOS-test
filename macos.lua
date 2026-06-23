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
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(200, 200, 200)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

local function padding(parent, top, left, right, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
end

local function listlayout(parent, pad)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, pad or 0)
	l.Parent = parent
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

local Theme = {
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
	IconStroke  = Color3.fromRGB(60, 60, 64),
	IconStrokeActive = Color3.fromRGB(0, 122, 255),
}

-- ── Configuração do efeito "vidro" (glass) ──────────────
-- Roblox não tem blur nativo por trás de elementos de UI (como o
-- backdrop-filter do CSS), então simulamos o efeito "vidro fosco"
-- combinando transparência alta com cores e bordas claras.
-- Ajuste os valores de Alpha para controlar o quão transparente cada
-- parte fica (0 = opaco, 1 = invisível). Entre 0.25 e 0.45 fica bom.
local Glass = {
	WindowAlpha  = 0.35, -- transparência do corpo da janela
	TopBarAlpha  = 0.30, -- transparência da topbar
	SidebarAlpha = 0.32, -- transparência da sidebar
	CardAlpha    = 0.25, -- transparência dos cards (botões, sliders, etc)
}

-- ══════════════════════════════════════════════════════════
--   ÍCONES VETORIAIS
--   Em vez de emojis (que variam de fonte pra fonte e não
--   seguem o tema), os ícones aqui são desenhados na hora com
--   Frames + UICorner formando traços geométricos simples.
--   Isso garante visual consistente, nítido em qualquer
--   resolução e sem depender de nenhum asset externo.
--
--   Cada função de ícone recebe um "parent" (geralmente um
--   Frame quadrado de tamanho fixo) e desenha dentro dele,
--   usando Scale (0 a 1) para todas as posições/tamanhos —
--   assim o ícone escala automaticamente com o container.
-- ══════════════════════════════════════════════════════════

local Icons = {}

-- pequeno helper pra criar um "traço" (linha) dentro do ícone
local function iconLine(parent, x, y, w, h, color, rounded)
	local line = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(w, 0, h, 0),
		Parent = parent,
	})
	if rounded then
		corner(line, 100)
	end
	return line
end

-- Casa (Home) — usada em tabs gerais / página inicial
Icons.Home = function(parent, color)
	color = color or Theme.IconStroke
	-- telhado (triângulo feito com um quadrado rotacionado)
	local roof = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.32, 0),
		Size = UDim2.new(0.62, 0, 0.62, 0),
		Rotation = 45,
		Parent = parent,
	})
	corner(roof, 3)
	-- corpo da casa
	iconLine(parent, 0.22, 0.46, 0.56, 0.4, color, false)
	-- porta (recorte usando a cor de fundo do card por cima)
	local door = create("Frame", {
		BackgroundColor3 = Theme.ButtonBG,
		BackgroundTransparency = Glass.CardAlpha,
		BorderSizePixel = 0,
		Position = UDim2.new(0.42, 0, 0.62, 0),
		Size = UDim2.new(0.16, 0, 0.24, 0),
		ZIndex = 2,
		Parent = parent,
	})
	door.ZIndex = (parent:FindFirstChild("UIListLayout") and 1) or 2
end

-- Paleta de cores — usada em tabs de visual/aparência
Icons.Palette = function(parent, color)
	color = color or Theme.IconStroke
	local base = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.46, 0, 0.5, 0),
		Size = UDim2.new(0.74, 0, 0.6, 0),
		Parent = parent,
	})
	corner(base, 100)
	-- "furo" do polegar
	local thumbHole = create("Frame", {
		BackgroundColor3 = Theme.ButtonBG,
		BackgroundTransparency = Glass.CardAlpha,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.78, 0, 0.62, 0),
		Size = UDim2.new(0.26, 0, 0.26, 0),
		Parent = base,
	})
	corner(thumbHole, 100)
	-- pingos de tinta
	local dotPositions = {
		{0.28, 0.32}, {0.5, 0.24}, {0.7, 0.34},
	}
	for _, p in ipairs(dotPositions) do
		local dot = create("Frame", {
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(p[1], 0, p[2], 0),
			Size = UDim2.new(0.14, 0, 0.14, 0),
			Parent = base,
		})
		corner(dot, 100)
	end
end

-- Engrenagem — usada em tabs de configurações
Icons.Gear = function(parent, color)
	color = color or Theme.IconStroke
	local center = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.42, 0, 0.42, 0),
		Parent = parent,
	})
	corner(center, 100)
	local hole = create("Frame", {
		BackgroundColor3 = Theme.ButtonBG,
		BackgroundTransparency = Glass.CardAlpha,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.16, 0, 0.16, 0),
		Parent = center,
	})
	corner(hole, 100)
	-- "dentes" da engrenagem em 4 direções
	local toothPositions = {
		{0.5, 0.06, 0.18, 0.22},
		{0.5, 0.94, 0.18, 0.22},
		{0.06, 0.5, 0.22, 0.18},
		{0.94, 0.5, 0.22, 0.18},
	}
	for _, t in ipairs(toothPositions) do
		local tooth = create("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(t[1], 0, t[2], 0),
			Size = UDim2.new(t[3], 0, t[4], 0),
			Parent = parent,
		})
		corner(tooth, 2)
	end
end

-- Controle deslizante / Display — usada em tabs de câmera/gráficos
Icons.Sliders = function(parent, color)
	color = color or Theme.IconStroke
	local rows = {0.22, 0.5, 0.78}
	for i, y in ipairs(rows) do
		iconLine(parent, 0.12, y - 0.04, 0.76, 0.08, Theme.Divider, true)
		local knobX = (i == 1 and 0.66) or (i == 2 and 0.32) or 0.52
		local knob = create("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(knobX, 0, y, 0),
			Size = UDim2.new(0.16, 0, 0.16, 0),
			Parent = parent,
		})
		corner(knob, 100)
	end
end

-- Alto-falante — usada em tabs de áudio
Icons.Speaker = function(parent, color)
	color = color or Theme.IconStroke
	local body = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.32, 0, 0.5, 0),
		Size = UDim2.new(0.22, 0, 0.42, 0),
		Parent = parent,
	})
	corner(body, 3)
	local cone = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.46, 0, 0.5, 0),
		Size = UDim2.new(0.2, 0, 0.7, 0),
		Rotation = 0,
		Parent = parent,
	})
	corner(cone, 100)
	-- ondas sonoras (dois arcos simples feitos com strokes em frames vazados)
	for i, r in ipairs({0.16, 0.28}) do
		local wave = create("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.6 + (i * 0.1), 0, 0.5, 0),
			Size = UDim2.new(r, 0, r * 2.2, 0),
			Parent = parent,
		})
		corner(wave, 100)
		stroke(wave, color, 2, 0)
	end
end

-- Informação (i circular) — usada em tabs de info/sobre
Icons.Info = function(parent, color)
	color = color or Theme.IconStroke
	local circle = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.82, 0, 0.82, 0),
		Parent = parent,
	})
	corner(circle, 100)
	stroke(circle, color, 2, 0)
	local dot = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.28, 0),
		Size = UDim2.new(0.12, 0, 0.12, 0),
		Parent = parent,
	})
	corner(dot, 100)
	iconLine(parent, 0.44, 0.46, 0.12, 0.32, color, true)
end

-- Estrela — uso geral / favoritos / destaque
Icons.Star = function(parent, color)
	color = color or Theme.IconStroke
	-- aproximação simples de estrela com dois quadrados rotacionados (efeito "diamante duplo")
	local a = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.62, 0, 0.62, 0),
		Rotation = 0,
		Parent = parent,
	})
	corner(a, 4)
	local b = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.62, 0, 0.62, 0),
		Rotation = 45,
		Parent = parent,
	})
	corner(b, 4)
end

-- Escudo — uso geral / segurança / proteção
Icons.Shield = function(parent, color)
	color = color or Theme.IconStroke
	local top = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.4, 0),
		Size = UDim2.new(0.6, 0, 0.5, 0),
		Parent = parent,
	})
	corner(top, 100)
	local bottom = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.62, 0),
		Size = UDim2.new(0.6, 0, 0.42, 0),
		Rotation = 45,
		Parent = parent,
	})
end

-- Função genérica pra desenhar um ícone por nome dentro de um container
local function drawIcon(container, name, color)
	local fn = Icons[name]
	if fn then
		fn(container, color)
	end
end

function MacOSLib:CreateWindow(config)
	config = config or {}
	local title    = config.Title     or "MacOS UI"
	local subtitle = config.Subtitle  or "v1.0"
	local width    = config.Width     or 520
	local height   = config.Height    or 360
	local key      = config.ToggleKey or Enum.KeyCode.RightControl

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
		Parent = gui,
	})
	corner(shadow, 16)

	local window = create("Frame", {
		Name = "Window",
		Size = UDim2.new(0, width, 0, height),
		Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = Glass.WindowAlpha,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	})
	corner(window, 12)
	stroke(window, Theme.Divider, 1.5, 0.15)

	local topbar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.TopBar,
		BackgroundTransparency = Glass.TopBarAlpha,
		BorderSizePixel = 0,
		Parent = window,
	})
	corner(topbar, 12)

	local topbarFix = create("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.TopBar,
		BackgroundTransparency = Glass.TopBarAlpha,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local topbarDivider = create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
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
			Parent = topbar,
		})
		corner(dot, 50)
		trafficX = trafficX + 20
		if i == 1 then
			local closeBtn = create("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				Parent = dot,
			})
			closeBtn.MouseButton1Click:Connect(function()
				tween(shadow, { BackgroundTransparency = 1 }, 0.2)
				tween(window, { BackgroundTransparency = 1, Size = UDim2.new(0, width, 0, 0) }, 0.2)
				task.delay(0.25, function()
					gui:Destroy()
				end)
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
		BackgroundTransparency = Glass.SidebarAlpha,
		BorderSizePixel = 0,
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

	local contentHolder = create("Frame", {
		Name = "ContentHolder",
		Size = UDim2.new(1, -130, 1, -44),
		Position = UDim2.new(0, 130, 0, 44),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = window,
	})

	window.Size = UDim2.new(0, width, 0, 0)
	window.BackgroundTransparency = 1
	shadow.BackgroundTransparency = 1
	tween(window, { Size = UDim2.new(0, width, 0, height), BackgroundTransparency = Glass.WindowAlpha }, 0.3, Enum.EasingStyle.Back)
	tween(shadow, { BackgroundTransparency = 0.82 }, 0.3)

	local Window = {}
	Window._tabs = {}
	Window._activeTab = nil

	function Window:_setActive(tab)
		if self._activeTab == tab then return end
		self._activeTab = tab
		for _, t in pairs(self._tabs) do
			local isActive = (t == tab)
			tween(t._btn, {
				BackgroundColor3 = isActive and Theme.TabActive or Theme.TabInactive,
			}, 0.15)
			t._label.TextColor3 = isActive and Theme.Text or Theme.SubText
			t._label.Font = isActive and Enum.Font.GothamSemibold or Enum.Font.Gotham
			-- atualiza a cor dos traços do ícone vetorial pra refletir o estado ativo
			if t._iconHolder then
				for _, child in ipairs(t._iconHolder:GetDescendants()) do
					if child:IsA("Frame") and child.BackgroundColor3 == Theme.IconStroke then
						child.BackgroundColor3 = isActive and Theme.IconStrokeActive or Theme.IconStroke
					end
					if child:IsA("UIStroke") and child.Color == Theme.IconStroke then
						child.Color = isActive and Theme.IconStrokeActive or Theme.IconStroke
					end
				end
			end
			t._page.Visible = isActive
		end
	end

	function Window:Notify(ntitle, message, duration)
		duration = duration or 3
		local notif = create("Frame", {
			Size = UDim2.new(0, 260, 0, 64),
			Position = UDim2.new(1, 10, 1, -80),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Parent = gui,
		})
		corner(notif, 12)
		stroke(notif, Theme.Divider, 1, 0.3)

		local ntitleLabel = create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 22),
			Position = UDim2.new(0, 14, 0, 10),
			BackgroundTransparency = 1,
			Text = ntitle,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = notif,
		})
		local nmsg = create("TextLabel", {
			Size = UDim2.new(1, -16, 0, 18),
			Position = UDim2.new(0, 14, 0, 32),
			BackgroundTransparency = 1,
			Text = message,
			TextColor3 = Theme.SubText,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = notif,
		})
		local bar = create("Frame", {
			Size = UDim2.new(1, 0, 0, 3),
			Position = UDim2.new(0, 0, 1, -3),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
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
	-- "icon" agora é opcional e espera o NOME de um ícone vetorial
	-- registrado em Icons (ex: "Home", "Gear", "Palette", "Sliders",
	-- "Speaker", "Info", "Star", "Shield"). Se omitido ou inválido,
	-- a tab simplesmente não mostra ícone.
	function Window:CreateTab(name, icon)
		local tab = {}

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

		btn.MouseButton1Click:Connect(function()
			Window:_setActive(tab)
		end)
		btn.MouseEnter:Connect(function()
			if Window._activeTab ~= tab then
				tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window._activeTab ~= tab then
				tween(btn, { BackgroundColor3 = Theme.TabInactive }, 0.1)
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
		end

		function tab:AddButton(text, callback)
			local row = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Glass.CardAlpha,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			stroke(row, Theme.Divider, 1, 0.5)

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
			local chevron = create("TextLabel", {
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(1, -26, 0, 0),
				BackgroundTransparency = 1,
				Text = ">",
				TextColor3 = Theme.SubText,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Parent = row,
			})
			row.MouseEnter:Connect(function()
				tween(row, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
			end)
			row.MouseLeave:Connect(function()
				tween(row, { BackgroundColor3 = Theme.ButtonBG }, 0.1)
			end)
			row.MouseButton1Click:Connect(function()
				tween(row, { BackgroundColor3 = Theme.Divider }, 0.08)
				task.delay(0.1, function()
					tween(row, { BackgroundColor3 = Theme.ButtonBG }, 0.1)
				end)
				if callback then callback() end
			end)
			return row
		end

		function tab:AddToggle(text, default, callback)
			local value = default or false
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Glass.CardAlpha,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			stroke(row, Theme.Divider, 1, 0.5)

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
				Size = UDim2.new(0, 44, 0, 26),
				Position = UDim2.new(1, -54, 0.5, -13),
				BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
				BorderSizePixel = 0,
				Parent = row,
			})
			corner(track, 50)

			local thumb = create("Frame", {
				Size = UDim2.new(0, 22, 0, 22),
				Position = UDim2.new(0, value and 20 or 2, 0.5, -11),
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
				tween(track, { BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
				tween(thumb, { Position = UDim2.new(0, value and 20 or 2, 0.5, -11) }, 0.2)
				if callback then callback(value) end
			end)

			local toggle = {}
			function toggle:Set(v)
				value = v
				tween(track, { BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
				tween(thumb, { Position = UDim2.new(0, value and 20 or 2, 0.5, -11) }, 0.2)
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
				BackgroundTransparency = Glass.CardAlpha,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(container, 8)
			stroke(container, Theme.Divider, 1, 0.5)

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
			stroke(knob, Theme.SliderFill, 2, 0)

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
				BackgroundTransparency = Glass.CardAlpha,
				BorderSizePixel = 0,
				LayoutOrder = #page:GetChildren(),
				Parent = page,
			})
			corner(row, 8)
			stroke(row, Theme.Divider, 1, 0.5)

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
			stroke(inputBox, Theme.Accent, 1, 0.6)
			padding(inputBox, 0, 8, 8, 0)

			inputBox.FocusLost:Connect(function(enter)
				if enter and callback then
					callback(inputBox.Text)
				end
			end)
			return inputBox
		end

		function tab:AddDropdown(text, options, callback)
			local selected = options[1] or ""
			local open = false

			local container = create("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ButtonBG,
				BackgroundTransparency = Glass.CardAlpha,
				BorderSizePixel = 0,
				ClipsDescendants = false,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 5,
				Parent = page,
			})
			corner(container, 8)
			stroke(container, Theme.Divider, 1, 0.5)

			local ddLabel = create("TextLabel", {
				Size = UDim2.new(0.48, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
				Parent = container,
			})

			local selectedLabel = create("TextButton", {
				Size = UDim2.new(0.46, 0, 0, 24),
				Position = UDim2.new(0.5, 0, 0.5, -12),
				BackgroundColor3 = Theme.InputBG,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
				Parent = container,
			})
			corner(selectedLabel, 6)
			stroke(selectedLabel, Theme.Divider, 1, 0.5)

			local selectedText = create("TextLabel", {
				Size = UDim2.new(1, -24, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
				Parent = selectedLabel,
			})

			-- seta (chevron) vetorial em vez de "v" como texto
			local chevronHolder = create("Frame", {
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(1, -16, 0.5, -5),
				BackgroundTransparency = 1,
				ZIndex = 5,
				Parent = selectedLabel,
			})
			local chevA = create("Frame", {
				BackgroundColor3 = Theme.SubText,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.28, 0, 0.5, 0),
				Size = UDim2.new(0.55, 0, 0.16, 0),
				Rotation = 45,
				ZIndex = 5,
				Parent = chevronHolder,
			})
			corner(chevA, 100)
			local chevB = create("Frame", {
				BackgroundColor3 = Theme.SubText,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.72, 0, 0.5, 0),
				Size = UDim2.new(0.55, 0, 0.16, 0),
				Rotation = -45,
				ZIndex = 5,
				Parent = chevronHolder,
			})
			corner(chevB, 100)

			local dropList = create("Frame", {
				Size = UDim2.new(0.46, 0, 0, #options * 30 + 8),
				Position = UDim2.new(0.5, 0, 1, 4),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 10,
				Parent = container,
			})
			corner(dropList, 8)
			stroke(dropList, Theme.Divider, 1, 0.3)
			listlayout(dropList, 0)
			padding(dropList, 4, 0, 0, 4)

			for _, opt in ipairs(options) do
				local optBtn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					Text = opt,
					TextColor3 = Theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					ZIndex = 10,
					Parent = dropList,
				})
				optBtn.MouseEnter:Connect(function()
					tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = Theme.ButtonHover }, 0.08)
				end)
				optBtn.MouseLeave:Connect(function()
					tween(optBtn, { BackgroundTransparency = 1 }, 0.08)
				end)
				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					selectedText.Text = opt
					dropList.Visible = false
					open = false
					if callback then callback(opt) end
				end)
			end

			selectedLabel.MouseButton1Click:Connect(function()
				open = not open
				dropList.Visible = open
				tween(chevronHolder, { Rotation = open and 180 or 0 }, 0.15)
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
		end

		return tab
	end

	return Window
end

return MacOSLib
