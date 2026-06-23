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
--   SISTEMA DE ÍCONES LUCIDE (v2)
--
--   Abordagem: cada ícone é desenhado com uma função que
--   recebe um Frame container (quadrado) e uma cor, e
--   posiciona elementos dentro dele usando coordenadas
--   normalizadas (0–1). Os paths seguem fielmente os SVG
--   originais do Lucide (viewBox 24x24, stroke-width 2,
--   stroke-linecap round, stroke-linejoin round).
--
--   Funções auxiliares internas:
--     ln(p, x1,y1,x2,y2, cor, esp)  → segmento de reta
--     cr(p, cx,cy, r, cor, esp)      → círculo (ring)
--     rr(p, x,y,w,h, cor, rad)       → rect arredondado
--     ar(p, cx,cy, r, a0,a1, cor, esp, segs) → arco
--     pt(p, pontos, cor, esp)        → polyline (lista de {x,y})
--
--   Os ícones ficam em MacOSLib.Icons e são referenciados
--   pelo nome em kebab-case do Lucide, ex:
--     "house", "settings", "palette", "volume-2", "info",
--     "bell", "star", "shield", "monitor", "user", "sliders-horizontal"
--
--   Para usar em CreateTab passe o nome como string:
--     Win:CreateTab("Principal", "house")
-- ══════════════════════════════════════════════════════════

local Icons = {}

-- ── primitivos ────────────────────────────────────────────

-- segmento de reta com pontas redondas (replica stroke-linecap:round do Lucide)
-- coordenadas normalizadas 0–1 dentro do container
local function ln(parent, x1, y1, x2, y2, color, thickness)
	thickness = thickness or 0.08
	local dx, dy = x2 - x1, y2 - y1
	local length = math.sqrt(dx * dx + dy * dy)
	if length < 0.001 then return end
	local angle = math.atan2(dy, dx)
	local midX, midY = (x1 + x2) / 2, (y1 + y2) / 2

	local seg = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Rotation = math.deg(angle),
		Parent = parent,
	})
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = seg

	local function layout()
		local abs = parent.AbsoluteSize
		local base = math.min(abs.X, abs.Y)
		if base <= 0 then return end
		seg.Size = UDim2.new(0, length * base, 0, thickness * base)
		seg.Position = UDim2.new(midX, 0, midY, 0)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return seg
end

-- círculo (apenas contorno)
local function cr(parent, cx, cy, r, color, thickness)
	thickness = thickness or 0.08
	local ring = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	corner(ring, 100)
	local s = stroke(ring, color, 2, 0)
	local function layout()
		local abs = parent.AbsoluteSize
		local base = math.min(abs.X, abs.Y)
		if base <= 0 then return end
		ring.Position = UDim2.new(cx, 0, cy, 0)
		ring.Size = UDim2.new(0, r * 2 * base, 0, r * 2 * base)
		s.Thickness = math.max(1, thickness * base)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return ring
end

-- retângulo arredondado (apenas contorno)
local function rr(parent, x, y, w, h, color, rad, thickness)
	thickness = thickness or 0.08
	local f = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(w, 0, h, 0),
		Parent = parent,
	})
	corner(f, rad or 3)
	local s = stroke(f, color, 2, 0)
	local function layout()
		local abs = parent.AbsoluteSize
		local base = math.min(abs.X, abs.Y)
		if base <= 0 then return end
		s.Thickness = math.max(1, thickness * base)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return f
end

-- arco (aprox. por segmentos)
local function ar(parent, cx, cy, r, startDeg, endDeg, color, thickness, segs)
	segs = segs or 10
	thickness = thickness or 0.08
	local prev = nil
	for i = 0, segs do
		local t = i / segs
		local a = math.rad(startDeg + (endDeg - startDeg) * t)
		local px = cx + math.cos(a) * r
		local py = cy + math.sin(a) * r
		if prev then
			ln(parent, prev[1], prev[2], px, py, color, thickness)
		end
		prev = {px, py}
	end
end

-- polyline: lista de {x, y} em coordenadas normalizadas
local function pt(parent, points, color, thickness)
	for i = 1, #points - 1 do
		ln(parent, points[i][1], points[i][2], points[i+1][1], points[i+1][2], color, thickness)
	end
end

-- ponto (dot) preenchido
local function dot(parent, cx, cy, r, color)
	local d = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(d, 100)
	local function layout()
		local abs = parent.AbsoluteSize
		local base = math.min(abs.X, abs.Y)
		if base <= 0 then return end
		d.Position = UDim2.new(cx, 0, cy, 0)
		d.Size = UDim2.new(0, r * 2 * base, 0, r * 2 * base)
	end
	layout()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	return d
end

-- ── ícones Lucide ─────────────────────────────────────────
-- Cada ícone segue fielmente o SVG original do Lucide (viewBox 0 0 24 24).
-- As coordenadas são divididas por 24 para normalizar em 0–1.
-- ── Escala: coord_lucide / 24

-- house  (Lucide: path "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"
--         + path "M3 10.977V19a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-8.101"
--         + path "M3 10.977 10.328 4.57a2 2 0 0 1 2.7-.089L21 10.977")
Icons["house"] = function(parent, color)
	-- telhado (duas retas para o pico)
	pt(parent, {
		{3/24, 10.977/24},
		{10.328/24, 4.57/24},
	}, color)
	pt(parent, {
		{10.328/24, 4.57/24},
		{21/24, 10.977/24},
	}, color)
	-- paredes laterais + base
	pt(parent, {
		{3/24, 10.977/24},
		{3/24, 19/24},
		{21/24, 19/24},
		{21/24, 10.977/24},
	}, color)
	-- porta
	pt(parent, {
		{10/24, 21/24},
		{10/24, 13/24},
		{14/24, 13/24},
		{14/24, 21/24},
	}, color)
	ln(parent, 3/24, 21/24, 21/24, 21/24, color)
end

-- settings (engrenagem — Lucide: path com anel central + 8 dentes)
Icons["settings"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.125, color)
	local teeth = 8
	for i = 1, teeth do
		local a = math.rad((i - 1) * 45)
		-- dentes mais fiéis ao Lucide (largura proporcional)
		local aOff = math.rad(8)
		local r1, r2 = 0.295, 0.42
		local p1x = 0.5 + math.cos(a - aOff) * r1
		local p1y = 0.5 + math.sin(a - aOff) * r1
		local p2x = 0.5 + math.cos(a - aOff) * r2
		local p2y = 0.5 + math.sin(a - aOff) * r2
		local p3x = 0.5 + math.cos(a + aOff) * r2
		local p3y = 0.5 + math.sin(a + aOff) * r2
		local p4x = 0.5 + math.cos(a + aOff) * r1
		local p4y = 0.5 + math.sin(a + aOff) * r1
		pt(parent, {
			{p1x, p1y}, {p2x, p2y}, {p3x, p3y}, {p4x, p4y},
		}, color, 0.07)
	end
end

-- settings-2 (variante mais limpa — igual ao "settings-2" do Lucide)
Icons["settings-2"] = function(parent, color)
	-- 3 linhas horizontais com círculo de ajuste em cada
	local ys = {0.28, 0.5, 0.72}
	local kx = {0.65, 0.35, 0.55}
	for i, y in ipairs(ys) do
		ln(parent, 0.1, y, 0.9, y, color, 0.07)
		cr(parent, kx[i], y, 0.07, color, 0.08)
	end
end

-- sliders-horizontal
Icons["sliders-horizontal"] = function(parent, color)
	local ys = {0.28, 0.5, 0.72}
	local kx = {0.65, 0.35, 0.55}
	for i, y in ipairs(ys) do
		ln(parent, 0.1, y, 0.9, y, color, 0.07)
		dot(parent, kx[i], y, 0.07, color)
	end
end

-- palette (Lucide: círculo com buraco + gotas de tinta)
Icons["palette"] = function(parent, color)
	-- corpo circular grande
	ar(parent, 0.5, 0.5, 0.4, -30, 280, color, 0.08, 14)
	-- "polegar" (thumb notch) no canto inferior direito
	ar(parent, 0.72, 0.68, 0.1, 90, 360, color, 0.08, 8)
	-- pontos de cor
	dot(parent, 0.35, 0.32, 0.055, color)
	dot(parent, 0.55, 0.27, 0.055, color)
	dot(parent, 0.72, 0.40, 0.055, color)
	dot(parent, 0.38, 0.62, 0.055, color)
end

-- volume-2 (Lucide)
Icons["volume-2"] = function(parent, color)
	-- corpo do alto-falante
	pt(parent, {
		{11/24, 5/24},
		{6/24, 9/24},
		{2/24, 9/24},
		{2/24, 15/24},
		{6/24, 15/24},
		{11/24, 19/24},
		{11/24, 5/24},
	}, color)
	-- onda 1
	ar(parent, 11/24, 12/24, 3.5/24, -45, 45, color, 0.08, 6)
	-- onda 2
	ar(parent, 11/24, 12/24, 6/24, -55, 55, color, 0.08, 8)
end

-- volume (sem ondas)
Icons["volume"] = function(parent, color)
	pt(parent, {
		{11/24, 5/24},
		{6/24, 9/24},
		{2/24, 9/24},
		{2/24, 15/24},
		{6/24, 15/24},
		{11/24, 19/24},
		{11/24, 5/24},
	}, color)
	ar(parent, 11/24, 12/24, 3.5/24, -45, 45, color, 0.08, 6)
end

-- volume-x (mudo)
Icons["volume-x"] = function(parent, color)
	pt(parent, {
		{11/24, 5/24},
		{6/24, 9/24},
		{2/24, 9/24},
		{2/24, 15/24},
		{6/24, 15/24},
		{11/24, 19/24},
		{11/24, 5/24},
	}, color)
	ln(parent, 23/24, 9/24, 17/24, 15/24, color)
	ln(parent, 17/24, 9/24, 23/24, 15/24, color)
end

-- info (Lucide: círculo + ponto + linha)
Icons["info"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
	dot(parent, 0.5, 7.5/24, 0.04, color)
	ln(parent, 0.5, 11/24, 0.5, 17/24, color)
end

-- bell (Lucide)
Icons["bell"] = function(parent, color)
	-- arco superior do sino
	ar(parent, 12/24, 10/24, 6/24, 200, 340, color, 0.08, 8)
	-- haste do sino (corpo)
	ln(parent, 6/24, 10/24, 6/24, 16/24, color)
	ln(parent, 18/24, 10/24, 18/24, 16/24, color)
	-- borda inferior
	ln(parent, 4/24, 16/24, 20/24, 16/24, color)
	-- clapper (lingueta)
	ar(parent, 12/24, 16/24, 2/24, 0, 180, color, 0.08, 6)
	-- haste do badalo no topo
	ln(parent, 12/24, 2/24, 12/24, 4/24, color)
end

-- bell-off
Icons["bell-off"] = function(parent, color)
	ln(parent, 8/24, 8/24, 6/24, 10/24, color)
	ln(parent, 6/24, 10/24, 6/24, 16/24, color)
	ln(parent, 4/24, 16/24, 20/24, 16/24, color)
	ar(parent, 12/24, 16/24, 2/24, 0, 180, color, 0.08, 6)
	ln(parent, 12/24, 2/24, 12/24, 4/24, color)
	ar(parent, 12/24, 10/24, 6/24, -20, 160, color, 0.08, 6)
	ln(parent, 18/24, 10/24, 18/24, 16/24, color)
	ln(parent, 2/24, 2/24, 22/24, 22/24, color)
end

-- star (Lucide: estrela 5 pontas)
Icons["star"] = function(parent, color)
	local pts = {}
	for i = 0, 9 do
		local a = math.rad(-90 + i * 36)
		local r = (i % 2 == 0) and 0.43 or 0.18
		table.insert(pts, {0.5 + math.cos(a) * r, 0.52 + math.sin(a) * r})
	end
	table.insert(pts, pts[1])
	pt(parent, pts, color)
end

-- shield (Lucide)
Icons["shield"] = function(parent, color)
	pt(parent, {
		{12/24, 22/24},
		{4/24, 16/24},
		{4/24, 6.5/24},
		{12/24, 2/24},
		{20/24, 6.5/24},
		{20/24, 16/24},
		{12/24, 22/24},
	}, color)
end

-- shield-check
Icons["shield-check"] = function(parent, color)
	pt(parent, {
		{12/24, 22/24},
		{4/24, 16/24},
		{4/24, 6.5/24},
		{12/24, 2/24},
		{20/24, 6.5/24},
		{20/24, 16/24},
		{12/24, 22/24},
	}, color)
	pt(parent, {
		{8/24, 12/24},
		{11/24, 15/24},
		{16/24, 9/24},
	}, color)
end

-- monitor (Lucide)
Icons["monitor"] = function(parent, color)
	rr(parent, 2/24, 3/24, 20/24, 14/24, color, 5)
	ln(parent, 12/24, 17/24, 12/24, 21/24, color)
	ln(parent, 8/24, 21/24, 16/24, 21/24, color)
end

-- monitor-check
Icons["monitor-check"] = function(parent, color)
	rr(parent, 2/24, 3/24, 20/24, 14/24, color, 5)
	ln(parent, 12/24, 17/24, 12/24, 21/24, color)
	ln(parent, 8/24, 21/24, 16/24, 21/24, color)
	pt(parent, {
		{7.5/24, 10.5/24},
		{10/24, 13/24},
		{16.5/24, 7.5/24},
	}, color)
end

-- user (Lucide)
Icons["user"] = function(parent, color)
	cr(parent, 12/24, 7/24, 4/24, color)
	ar(parent, 12/24, 22/24, 8/24, 195, 345, color, 0.08, 10)
end

-- user-round
Icons["user-round"] = function(parent, color)
	cr(parent, 0.5, 7.5/24, 0.167, color)
	ar(parent, 0.5, 22/24, 8.5/24, 195, 345, color, 0.08, 10)
end

-- users (Lucide — dois usuários)
Icons["users"] = function(parent, color)
	cr(parent, 9/24, 7/24, 3.5/24, color)
	ar(parent, 9/24, 21/24, 7/24, 200, 340, color, 0.08, 8)
	ln(parent, 22/24, 21/24, 22/24, 15/24, color)
	ar(parent, 19/24, 7/24, 3/24, -50, 55, color, 0.08, 5)
	ar(parent, 22/24, 21/24, 5/24, 210, 330, color, 0.08, 6)
end

-- check (Lucide: apenas o tick)
Icons["check"] = function(parent, color)
	pt(parent, {
		{4/24, 12/24},
		{9/24, 17/24},
		{20/24, 6/24},
	}, color)
end

-- check-circle
Icons["check-circle"] = function(parent, color)
	ar(parent, 0.5, 0.5, 0.41, 30, 330, color, 0.08, 12)
	pt(parent, {
		{8/24, 12/24},
		{11/24, 15/24},
		{16/24, 9/24},
	}, color)
end

-- circle (simples)
Icons["circle"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
end

-- x (fechar)
Icons["x"] = function(parent, color)
	ln(parent, 5/24, 5/24, 19/24, 19/24, color)
	ln(parent, 19/24, 5/24, 5/24, 19/24, color)
end

-- x-circle
Icons["x-circle"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
	ln(parent, 9/24, 9/24, 15/24, 15/24, color)
	ln(parent, 15/24, 9/24, 9/24, 15/24, color)
end

-- alert-triangle (Lucide)
Icons["alert-triangle"] = function(parent, color)
	pt(parent, {
		{12/24, 2/24},
		{2/24, 22/24},
		{22/24, 22/24},
		{12/24, 2/24},
	}, color)
	ln(parent, 12/24, 9/24, 12/24, 14/24, color)
	dot(parent, 12/24, 18/24, 0.04, color)
end

-- alert-circle
Icons["alert-circle"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
	ln(parent, 12/24, 8/24, 12/24, 13/24, color)
	dot(parent, 12/24, 17/24, 0.04, color)
end

-- search (lupa — Lucide)
Icons["search"] = function(parent, color)
	cr(parent, 11/24, 11/24, 7/24, color)
	ln(parent, 21/24, 21/24, 16.65/24, 16.65/24, color)
end

-- eye (Lucide)
Icons["eye"] = function(parent, color)
	ar(parent, 0.5, 0.5, 0.4, -30, 210, color, 0.08, 10)
	ar(parent, 0.5, 0.5, 0.4, 330, 570, color, 0.08, 10)
	cr(parent, 0.5, 0.5, 0.125, color)
end

-- eye-off
Icons["eye-off"] = function(parent, color)
	ar(parent, 0.5, 0.5, 0.4, -30, 120, color, 0.08, 7)
	ar(parent, 0.5, 0.5, 0.4, 330, 480, color, 0.08, 7)
	ln(parent, 2/24, 2/24, 22/24, 22/24, color)
end

-- lock (Lucide)
Icons["lock"] = function(parent, color)
	rr(parent, 3/24, 11/24, 18/24, 11/24, color, 4)
	ar(parent, 0.5, 11/24, 5/24, 195, 345, color, 0.08, 8)
	dot(parent, 0.5, 16/24, 0.04, color)
end

-- unlock
Icons["unlock"] = function(parent, color)
	rr(parent, 3/24, 11/24, 18/24, 11/24, color, 4)
	ar(parent, 0.5, 11/24, 5/24, 200, 360, color, 0.08, 8)
	ln(parent, 17/24, 6/24, 17/24, 11/24, color)
end

-- key (Lucide)
Icons["key"] = function(parent, color)
	cr(parent, 8/24, 10/24, 5/24, color)
	ln(parent, 13/24, 14.5/24, 21/24, 6/24, color)
	ln(parent, 19/24, 8/24, 21/24, 6/24, color)
	ln(parent, 19/24, 8/24, 17/24, 10/24, color)
end

-- download (Lucide)
Icons["download"] = function(parent, color)
	ln(parent, 12/24, 3/24, 12/24, 15/24, color)
	pt(parent, {
		{7/24, 10/24},
		{12/24, 15/24},
		{17/24, 10/24},
	}, color)
	ln(parent, 3/24, 21/24, 21/24, 21/24, color)
end

-- upload (Lucide)
Icons["upload"] = function(parent, color)
	ln(parent, 12/24, 15/24, 12/24, 3/24, color)
	pt(parent, {
		{7/24, 8/24},
		{12/24, 3/24},
		{17/24, 8/24},
	}, color)
	ln(parent, 3/24, 21/24, 21/24, 21/24, color)
end

-- refresh-cw (Lucide — setas circulares)
Icons["refresh-cw"] = function(parent, color)
	ar(parent, 0.5, 0.5, 0.38, -60, 210, color, 0.08, 12)
	-- seta no fim
	pt(parent, {
		{21/24, 8/24},
		{20.4/24, 3/24},
		{15.5/24, 3.5/24},
	}, color)
	ar(parent, 0.5, 0.5, 0.38, 120, 390, color, 0.08, 12)
	pt(parent, {
		{3/24, 16/24},
		{3.6/24, 21/24},
		{8.5/24, 20.5/24},
	}, color)
end

-- trash-2 (Lucide)
Icons["trash-2"] = function(parent, color)
	ln(parent, 3/24, 6/24, 21/24, 6/24, color)
	pt(parent, {
		{8/24, 6/24},
		{8/24, 21/24},
		{16/24, 21/24},
		{16/24, 6/24},
	}, color)
	ln(parent, 19/24, 6/24, 19/24, 4/24, color)
	ln(parent, 5/24, 6/24, 5/24, 4/24, color)
	rr(parent, 5/24, 2/24, 14/24, 2.5/24, color, 2)
	ln(parent, 10/24, 11/24, 10/24, 17/24, color)
	ln(parent, 14/24, 11/24, 14/24, 17/24, color)
end

-- edit (Lucide: lápis)
Icons["edit"] = function(parent, color)
	pt(parent, {
		{3/24, 17/24},
		{16/24, 4/24},
		{20/24, 8/24},
		{7/24, 21/24},
		{3/24, 21/24},
		{3/24, 17/24},
	}, color)
	ln(parent, 14/24, 6/24, 18/24, 10/24, color)
end

-- copy (Lucide)
Icons["copy"] = function(parent, color)
	rr(parent, 9/24, 1/24, 13/24, 13/24, color, 3)
	rr(parent, 2/24, 7/24, 13/24, 15/24, color, 3)
end

-- clipboard (Lucide)
Icons["clipboard"] = function(parent, color)
	rr(parent, 5/24, 3/24, 14/24, 18/24, color, 4)
	rr(parent, 9/24, 1/24, 6/24, 4/24, color, 3)
end

-- send (Lucide — avião de papel)
Icons["send"] = function(parent, color)
	pt(parent, {
		{22/24, 2/24},
		{11/24, 13/24},
	}, color)
	pt(parent, {
		{22/24, 2/24},
		{15/24, 22/24},
		{11/24, 13/24},
		{2/24, 9/24},
		{22/24, 2/24},
	}, color)
end

-- message-circle (Lucide)
Icons["message-circle"] = function(parent, color)
	ar(parent, 0.5, 0.458, 0.383, -60, 245, color, 0.08, 12)
	pt(parent, {
		{5/24, 19/24},
		{2/24, 22/24},
	}, color)
end

-- mail (Lucide)
Icons["mail"] = function(parent, color)
	rr(parent, 2/24, 4/24, 20/24, 16/24, color, 4)
	pt(parent, {
		{2/24, 7/24},
		{12/24, 13/24},
		{22/24, 7/24},
	}, color)
end

-- link (Lucide)
Icons["link"] = function(parent, color)
	ar(parent, 9/24, 12/24, 3.5/24, 90, 270, color, 0.08, 8)
	ar(parent, 15/24, 12/24, 3.5/24, -90, 90, color, 0.08, 8)
	ln(parent, 9/24, 12/24, 15/24, 12/24, color)
	ln(parent, 9/24, 8.5/24, 15/24, 8.5/24, color)
	ln(parent, 9/24, 15.5/24, 15/24, 15.5/24, color)
end

-- external-link
Icons["external-link"] = function(parent, color)
	pt(parent, {
		{18/24, 13/24},
		{18/24, 19/24},
		{5/24, 19/24},
		{5/24, 6/24},
		{11/24, 6/24},
	}, color)
	ln(parent, 15/24, 3/24, 21/24, 3/24, color)
	ln(parent, 21/24, 3/24, 21/24, 9/24, color)
	ln(parent, 10/24, 14/24, 21/24, 3/24, color)
end

-- home (alias de house)
Icons["home"] = Icons["house"]

-- layers
Icons["layers"] = function(parent, color)
	pt(parent, {
		{2/24, 12/24}, {12/24, 17/24}, {22/24, 12/24},
	}, color)
	pt(parent, {
		{2/24, 7/24}, {12/24, 12/24}, {22/24, 7/24}, {12/24, 2/24}, {2/24, 7/24},
	}, color)
	pt(parent, {
		{2/24, 17/24}, {12/24, 22/24}, {22/24, 17/24},
	}, color)
end

-- package (Lucide)
Icons["package"] = function(parent, color)
	pt(parent, {
		{16.5/24, 9.4/24}, {7.5/24, 4.21/24},
	}, color)
	pt(parent, {
		{21/24, 16/24}, {21/24, 8/24}, {12/24, 3/24},
		{3/24, 8/24}, {3/24, 16/24}, {12/24, 21/24}, {21/24, 16/24},
	}, color)
	ln(parent, 3.27/24, 6.96/24, 12/24, 12.01/24, color)
	ln(parent, 12/24, 22.08/24, 12/24, 12/24, color)
end

-- code (Lucide: colchetes angulares)
Icons["code"] = function(parent, color)
	pt(parent, {
		{16/24, 18/24}, {22/24, 12/24}, {16/24, 6/24},
	}, color)
	pt(parent, {
		{8/24, 6/24}, {2/24, 12/24}, {8/24, 18/24},
	}, color)
end

-- terminal
Icons["terminal"] = function(parent, color)
	pt(parent, {
		{4/24, 17/24}, {10/24, 12/24}, {4/24, 7/24},
	}, color)
	ln(parent, 12/24, 19/24, 20/24, 19/24, color)
end

-- cpu
Icons["cpu"] = function(parent, color)
	rr(parent, 7/24, 7/24, 10/24, 10/24, color, 3)
	rr(parent, 2/24, 2/24, 20/24, 20/24, color, 3)
	for i = 1, 3 do
		local y = (6 + i * 3) / 24
		ln(parent, 2/24, y, 7/24, y, color)
		ln(parent, 17/24, y, 22/24, y, color)
	end
	for i = 1, 3 do
		local x = (6 + i * 3) / 24
		ln(parent, x, 2/24, x, 7/24, color)
		ln(parent, x, 17/24, x, 22/24, color)
	end
end

-- wifi
Icons["wifi"] = function(parent, color)
	ar(parent, 0.5, 14/24, 10.5/24, 225, 315, color, 0.08, 5)
	ar(parent, 0.5, 14/24, 7/24, 225, 315, color, 0.08, 5)
	ar(parent, 0.5, 14/24, 3.5/24, 225, 315, color, 0.08, 5)
	dot(parent, 0.5, 20/24, 0.045, color)
end

-- bluetooth
Icons["bluetooth"] = function(parent, color)
	pt(parent, {
		{6.5/24, 8.5/24}, {17.5/24, 15.5/24},
		{12/24, 20/24}, {12/24, 4/24},
		{17.5/24, 8.5/24}, {6.5/24, 15.5/24},
	}, color)
end

-- battery
Icons["battery"] = function(parent, color)
	rr(parent, 2/24, 7/24, 18/24, 10/24, color, 3)
	ln(parent, 22/24, 10/24, 22/24, 14/24, color)
end

-- battery-charging
Icons["battery-charging"] = function(parent, color)
	pt(parent, {
		{5/24, 7/24}, {2/24, 7/24}, {2/24, 17/24},
		{13/24, 17/24}, {13/24, 13/24}, {20/24, 13/24},
	}, color)
	pt(parent, {
		{11/24, 7/24}, {7/24, 13/24}, {13/24, 13/24}, {9/24, 19/24},
	}, color)
	ln(parent, 22/24, 10/24, 22/24, 14/24, color)
end

-- map-pin (Lucide)
Icons["map-pin"] = function(parent, color)
	ar(parent, 12/24, 10/24, 6/24, 180, 360, color, 0.08, 10)
	ar(parent, 12/24, 10/24, 6/24, 0, 90, color, 0.08, 5)
	ln(parent, 18/24, 10/24, 12/24, 22/24, color)
	ln(parent, 12/24, 22/24, 6/24, 10/24, color)
end

-- globe
Icons["globe"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
	ar(parent, 0.5, 0.5, 0.18, 90, 270, color, 0.08, 6)
	ar(parent, 0.5, 0.5, 0.18, -90, 90, color, 0.08, 6)
	ln(parent, 2/24, 12/24, 22/24, 12/24, color)
	ln(parent, 12/24, 2/24, 12/24, 22/24, color)
end

-- image (Lucide)
Icons["image"] = function(parent, color)
	rr(parent, 3/24, 3/24, 18/24, 18/24, color, 4)
	cr(parent, 8.5/24, 8.5/24, 1.5/24, color)
	pt(parent, {
		{3/24, 15/24},
		{8/24, 10/24},
		{12/24, 14/24},
		{15/24, 11/24},
		{21/24, 17/24},
	}, color)
end

-- music
Icons["music"] = function(parent, color)
	ln(parent, 9/24, 18/24, 9/24, 5/24, color)
	ln(parent, 15/24, 16/24, 15/24, 3/24, color)
	ln(parent, 9/24, 5/24, 15/24, 3/24, color)
	cr(parent, 6/24, 18/24, 3/24, color)
	cr(parent, 12/24, 16/24, 3/24, color)
end

-- mic
Icons["mic"] = function(parent, color)
	rr(parent, 9/24, 2/24, 6/24, 12/24, color, 100)
	ar(parent, 12/24, 14/24, 8/24, 0, 180, color, 0.08, 8)
	ln(parent, 12/24, 22/24, 12/24, 18.5/24, color)
	ln(parent, 8/24, 22/24, 16/24, 22/24, color)
end

-- headphones
Icons["headphones"] = function(parent, color)
	ar(parent, 12/24, 10/24, 9/24, 200, 340, color, 0.08, 10)
	rr(parent, 3/24, 14/24, 3.5/24, 6/24, color, 100)
	rr(parent, 17.5/24, 14/24, 3.5/24, 6/24, color, 100)
end

-- camera
Icons["camera"] = function(parent, color)
	rr(parent, 2/24, 6/24, 20/24, 16/24, color, 4)
	pt(parent, {
		{8/24, 6/24}, {10/24, 2/24}, {14/24, 2/24}, {16/24, 6/24},
	}, color)
	cr(parent, 12/24, 13/24, 3.5/24, color)
end

-- video
Icons["video"] = function(parent, color)
	rr(parent, 2/24, 7/24, 14/24, 10/24, color, 4)
	pt(parent, {
		{16/24, 9/24}, {22/24, 5/24}, {22/24, 19/24}, {16/24, 15/24},
	}, color)
end

-- film
Icons["film"] = function(parent, color)
	rr(parent, 2/24, 2/24, 20/24, 20/24, color, 4)
	ln(parent, 7/24, 2/24, 7/24, 22/24, color)
	ln(parent, 17/24, 2/24, 17/24, 22/24, color)
	ln(parent, 2/24, 12/24, 22/24, 12/24, color)
	ln(parent, 2/24, 7/24, 7/24, 7/24, color)
	ln(parent, 2/24, 17/24, 7/24, 17/24, color)
	ln(parent, 17/24, 7/24, 22/24, 7/24, color)
	ln(parent, 17/24, 17/24, 22/24, 17/24, color)
end

-- book
Icons["book"] = function(parent, color)
	pt(parent, {
		{4/24, 19/24},
		{4/24, 3/24},
		{12/24, 3/24},
		{12/24, 19/24},
		{4/24, 19/24},
	}, color)
	ln(parent, 12/24, 3/24, 20/24, 3/24, color)
	ln(parent, 20/24, 3/24, 20/24, 19/24, color)
	ln(parent, 4/24, 19/24, 20/24, 19/24, color)
	ln(parent, 12/24, 3/24, 12/24, 19/24, color)
end

-- bookmark
Icons["bookmark"] = function(parent, color)
	pt(parent, {
		{19/24, 21/24},
		{12/24, 16/24},
		{5/24, 21/24},
		{5/24, 3/24},
		{19/24, 3/24},
		{19/24, 21/24},
	}, color)
end

-- tag
Icons["tag"] = function(parent, color)
	pt(parent, {
		{12/24, 2/24},
		{2/24, 2/24},
		{2/24, 12/24},
		{17.27/24, 22.73/24},
		{22/24, 18/24},
		{12/24, 2/24},
	}, color)
	dot(parent, 7/24, 7/24, 0.04, color)
end

-- folder
Icons["folder"] = function(parent, color)
	pt(parent, {
		{22/24, 19/24},
		{2/24, 19/24},
		{2/24, 5/24},
		{10/24, 5/24},
		{12/24, 8/24},
		{22/24, 8/24},
		{22/24, 19/24},
	}, color)
end

-- file
Icons["file"] = function(parent, color)
	pt(parent, {
		{13/24, 2/24},
		{3/24, 2/24},
		{3/24, 22/24},
		{21/24, 22/24},
		{21/24, 10/24},
		{13/24, 2/24},
		{13/24, 10/24},
		{21/24, 10/24},
	}, color)
end

-- file-text
Icons["file-text"] = function(parent, color)
	pt(parent, {
		{13/24, 2/24},
		{3/24, 2/24},
		{3/24, 22/24},
		{21/24, 22/24},
		{21/24, 10/24},
		{13/24, 2/24},
		{13/24, 10/24},
		{21/24, 10/24},
	}, color)
	ln(parent, 7/24, 13/24, 17/24, 13/24, color)
	ln(parent, 7/24, 17/24, 17/24, 17/24, color)
end

-- log-out
Icons["log-out"] = function(parent, color)
	pt(parent, {
		{9/24, 21/24}, {3/24, 21/24}, {3/24, 3/24}, {9/24, 3/24},
	}, color)
	ln(parent, 16/24, 17/24, 21/24, 12/24, color)
	ln(parent, 21/24, 12/24, 16/24, 7/24, color)
	ln(parent, 9/24, 12/24, 21/24, 12/24, color)
end

-- log-in
Icons["log-in"] = function(parent, color)
	pt(parent, {
		{15/24, 3/24}, {21/24, 3/24}, {21/24, 21/24}, {15/24, 21/24},
	}, color)
	ln(parent, 8/24, 17/24, 3/24, 12/24, color)
	ln(parent, 3/24, 12/24, 8/24, 7/24, color)
	ln(parent, 3/24, 12/24, 15/24, 12/24, color)
end

-- zap (raio)
Icons["zap"] = function(parent, color)
	pt(parent, {
		{13/24, 2/24},
		{3/24, 14/24},
		{12/24, 14/24},
		{11/24, 22/24},
		{21/24, 10/24},
		{12/24, 10/24},
		{13/24, 2/24},
	}, color)
end

-- sun
Icons["sun"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.167, color)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		local x1 = 0.5 + math.cos(a) * 0.28
		local y1 = 0.5 + math.sin(a) * 0.28
		local x2 = 0.5 + math.cos(a) * 0.41
		local y2 = 0.5 + math.sin(a) * 0.41
		ln(parent, x1, y1, x2, y2, color)
	end
end

-- moon
Icons["moon"] = function(parent, color)
	ar(parent, 14/24, 12/24, 9/24, 120, 300, color, 0.08, 10)
	ln(parent, 14/24, 3/24, 14/24, 4/24, color)
end

-- cloud
Icons["cloud"] = function(parent, color)
	ar(parent, 12/24, 12/24, 6/24, 200, 340, color, 0.08, 8)
	ar(parent, 8.5/24, 12/24, 3.5/24, 200, 270, color, 0.08, 4)
	ln(parent, 5/24, 12/24, 19/24, 12/24, color)
	ar(parent, 16/24, 10/24, 4/24, 270, 360, color, 0.08, 4)
	ar(parent, 12/24, 8/24, 4/24, 0, 180, color, 0.08, 6)
end

-- clock
Icons["clock"] = function(parent, color)
	cr(parent, 0.5, 0.5, 0.41, color)
	ln(parent, 12/24, 7/24, 12/24, 12/24, color)
	ln(parent, 12/24, 12/24, 16/24, 14/24, color)
end

-- calendar
Icons["calendar"] = function(parent, color)
	rr(parent, 3/24, 4/24, 18/24, 18/24, color, 4)
	ln(parent, 16/24, 2/24, 16/24, 6/24, color)
	ln(parent, 8/24, 2/24, 8/24, 6/24, color)
	ln(parent, 3/24, 10/24, 21/24, 10/24, color)
end

-- chart-bar (Lucide: bar-chart-2)
Icons["bar-chart-2"] = function(parent, color)
	ln(parent, 18/24, 20/24, 18/24, 10/24, color)
	ln(parent, 12/24, 20/24, 12/24, 4/24, color)
	ln(parent, 6/24, 20/24, 6/24, 14/24, color)
end

-- trending-up
Icons["trending-up"] = function(parent, color)
	pt(parent, {
		{2/24, 18/24},
		{8/24, 12/24},
		{12/24, 16/24},
		{22/24, 6/24},
	}, color)
	pt(parent, {
		{17/24, 6/24}, {22/24, 6/24}, {22/24, 11/24},
	}, color)
end

-- list
Icons["list"] = function(parent, color)
	ln(parent, 8/24, 6/24, 21/24, 6/24, color)
	ln(parent, 8/24, 12/24, 21/24, 12/24, color)
	ln(parent, 8/24, 18/24, 21/24, 18/24, color)
	dot(parent, 3/24, 6/24, 0.05, color)
	dot(parent, 3/24, 12/24, 0.05, color)
	dot(parent, 3/24, 18/24, 0.05, color)
end

-- grid
Icons["grid"] = function(parent, color)
	rr(parent, 3/24, 3/24, 7/24, 7/24, color, 2)
	rr(parent, 14/24, 3/24, 7/24, 7/24, color, 2)
	rr(parent, 3/24, 14/24, 7/24, 7/24, color, 2)
	rr(parent, 14/24, 14/24, 7/24, 7/24, color, 2)
end

-- layout
Icons["layout"] = function(parent, color)
	rr(parent, 3/24, 3/24, 18/24, 18/24, color, 4)
	ln(parent, 3/24, 9/24, 21/24, 9/24, color)
	ln(parent, 9/24, 9/24, 9/24, 21/24, color)
end

-- sidebar
Icons["sidebar"] = function(parent, color)
	rr(parent, 3/24, 3/24, 18/24, 18/24, color, 4)
	ln(parent, 9/24, 3/24, 9/24, 21/24, color)
end

-- menu (hamburger)
Icons["menu"] = function(parent, color)
	ln(parent, 3/24, 6/24, 21/24, 6/24, color)
	ln(parent, 3/24, 12/24, 21/24, 12/24, color)
	ln(parent, 3/24, 18/24, 21/24, 18/24, color)
end

-- more-horizontal (três pontos)
Icons["more-horizontal"] = function(parent, color)
	dot(parent, 12/24, 12/24, 0.05, color)
	dot(parent, 5/24, 12/24, 0.05, color)
	dot(parent, 19/24, 12/24, 0.05, color)
end

-- more-vertical
Icons["more-vertical"] = function(parent, color)
	dot(parent, 12/24, 12/24, 0.05, color)
	dot(parent, 12/24, 5/24, 0.05, color)
	dot(parent, 12/24, 19/24, 0.05, color)
end

-- plus
Icons["plus"] = function(parent, color)
	ln(parent, 12/24, 4/24, 12/24, 20/24, color)
	ln(parent, 4/24, 12/24, 20/24, 12/24, color)
end

-- minus
Icons["minus"] = function(parent, color)
	ln(parent, 4/24, 12/24, 20/24, 12/24, color)
end

-- chevron-right
Icons["chevron-right"] = function(parent, color)
	pt(parent, {
		{9/24, 18/24},
		{15/24, 12/24},
		{9/24, 6/24},
	}, color)
end

-- chevron-left
Icons["chevron-left"] = function(parent, color)
	pt(parent, {
		{15/24, 18/24},
		{9/24, 12/24},
		{15/24, 6/24},
	}, color)
end

-- chevron-down
Icons["chevron-down"] = function(parent, color)
	pt(parent, {
		{6/24, 9/24},
		{12/24, 15/24},
		{18/24, 9/24},
	}, color)
end

-- chevron-up
Icons["chevron-up"] = function(parent, color)
	pt(parent, {
		{6/24, 15/24},
		{12/24, 9/24},
		{18/24, 15/24},
	}, color)
end

-- arrow-right
Icons["arrow-right"] = function(parent, color)
	ln(parent, 4/24, 12/24, 20/24, 12/24, color)
	pt(parent, {
		{14/24, 6/24}, {20/24, 12/24}, {14/24, 18/24},
	}, color)
end

-- arrow-left
Icons["arrow-left"] = function(parent, color)
	ln(parent, 20/24, 12/24, 4/24, 12/24, color)
	pt(parent, {
		{10/24, 18/24}, {4/24, 12/24}, {10/24, 6/24},
	}, color)
end

-- arrow-up
Icons["arrow-up"] = function(parent, color)
	ln(parent, 12/24, 20/24, 12/24, 4/24, color)
	pt(parent, {
		{6/24, 10/24}, {12/24, 4/24}, {18/24, 10/24},
	}, color)
end

-- arrow-down
Icons["arrow-down"] = function(parent, color)
	ln(parent, 12/24, 4/24, 12/24, 20/24, color)
	pt(parent, {
		{6/24, 14/24}, {12/24, 20/24}, {18/24, 14/24},
	}, color)
end

-- filter
Icons["filter"] = function(parent, color)
	pt(parent, {
		{22/24, 3/24}, {2/24, 3/24}, {10/24, 12.46/24}, {10/24, 19/24},
		{14/24, 21/24}, {14/24, 12.46/24}, {22/24, 3/24},
	}, color)
end

-- sort-asc
Icons["sort-asc"] = function(parent, color)
	ln(parent, 3/24, 8/24, 13/24, 8/24, color)
	ln(parent, 3/24, 14/24, 9/24, 14/24, color)
	ln(parent, 3/24, 20/24, 5/24, 20/24, color)
	pt(parent, {
		{18/24, 20/24}, {18/24, 4/24},
	}, color)
	pt(parent, {
		{14/24, 8/24}, {18/24, 4/24}, {22/24, 8/24},
	}, color)
end

-- heart (Lucide)
Icons["heart"] = function(parent, color)
	ar(parent, 8.5/24, 9/24, 4.5/24, 180, 360, color, 0.08, 8)
	ar(parent, 15.5/24, 9/24, 4.5/24, 180, 360, color, 0.08, 8)
	ln(parent, 4/24, 13.5/24, 12/24, 22/24, color)
	ln(parent, 12/24, 22/24, 20/24, 13.5/24, color)
	ln(parent, 4/24, 9/24, 4/24, 13.5/24, color)
	ln(parent, 20/24, 9/24, 20/24, 13.5/24, color)
end

-- thumbs-up
Icons["thumbs-up"] = function(parent, color)
	pt(parent, {
		{7/24, 22/24}, {7/24, 13/24},
	}, color)
	pt(parent, {
		{7/24, 13/24}, {4/24, 13/24}, {4/24, 22/24}, {7/24, 22/24},
	}, color)
	pt(parent, {
		{7/24, 13/24},
		{10.5/24, 2/24},
		{14/24, 2/24},
		{14/24, 6/24},
		{20/24, 6/24},
		{20/24, 13/24},
		{7/24, 13/24},
	}, color)
end

-- ── sistema de paleta de ícones Fluent (mantido para compatibilidade)
-- Esses são aliases para os equivalentes Lucide
Icons["FluentHome"] = Icons["house"]
Icons["FluentSettings"] = Icons["settings"]
Icons["FluentPalette"] = Icons["palette"]
Icons["FluentVolume"] = Icons["volume-2"]
Icons["FluentInfo"] = Icons["info"]
Icons["FluentBell"] = Icons["bell"]
Icons["FluentShield"] = Icons["shield"]
Icons["FluentUser"] = Icons["user"]

-- ── aliases legados (nomes antigos da v1 → novos nomes Lucide)
Icons["House"]    = Icons["house"]
Icons["Settings"] = Icons["settings"]
Icons["Palette"]  = Icons["palette"]
Icons["Sliders"]  = Icons["sliders-horizontal"]
Icons["Volume"]   = Icons["volume-2"]
Icons["Info"]     = Icons["info"]
Icons["Star"]     = Icons["star"]
Icons["Shield"]   = Icons["shield"]
Icons["Monitor"]  = Icons["monitor"]
Icons["User"]     = Icons["user"]
Icons["Bell"]     = Icons["bell"]

local function drawIcon(container, name, color)
	local fn = Icons[name]
	if fn then
		fn(container, color)
	end
end

-- ══════════════════════════════════════════════════════════
--   TEMAS
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

MacOSLib.Themes = Themes
MacOSLib.Icons = Icons

-- ══════════════════════════════════════════════════════════
--   CreateWindow
-- ══════════════════════════════════════════════════════════

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

	local trafficColors = {
		Color3.fromRGB(255, 95, 87),
		Color3.fromRGB(255, 189, 46),
		Color3.fromRGB(39, 201, 63),
	}
	local trafficX = 14
	for i = 1, 3 do
		local dot2 = create("Frame", {
			Size = UDim2.new(0, 13, 0, 13),
			Position = UDim2.new(0, trafficX, 0.5, -6),
			BackgroundColor3 = trafficColors[i],
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = topbar,
		})
		corner(dot2, 50)
		trafficX = trafficX + 20

		local btn = create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = dot2,
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
					tween(shadow, { Size = UDim2.new(0, window.Size.X.Offset + 16, 0, 60) }, 0.25)
				else
					tween(window, { Size = restoreSize }, 0.25)
					tween(shadow, { Size = UDim2.new(0, restoreSize.X.Offset + 16, 0, restoreSize.Y.Offset + 16) }, 0.25)
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
					if child:IsA("UIStroke") then
						child.Color = targetColor
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

		create("TextLabel", {
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
		create("TextLabel", {
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

	-- ══════════════════════════════════════════════════════
	-- CreateTab
	-- "icon" agora aceita nomes no padrão Lucide (kebab-case),
	-- ex: "house", "settings", "palette", "volume-2", "info",
	-- "bell", "star", "shield", "monitor", "user",
	-- "sliders-horizontal", "search", "eye", "lock", etc.
	--
	-- Os nomes legados da v1 também continuam funcionando:
	-- "House", "Settings", "Palette", "Volume", "Info",
	-- "Bell", "Star", "Shield", "Monitor", "User", "Sliders"
	-- ══════════════════════════════════════════════════════
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

		-- ── Widgets ──────────────────────────────────────

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

			-- chevron vetorial (estilo Lucide chevron-right)
			local chevHolder = create("Frame", {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -24, 0.5, -7),
				BackgroundTransparency = 1,
				Parent = row,
			})
			ln(chevHolder, 0.3, 0.15, 0.7, 0.5, Theme.SubText, 0.12)
			ln(chevHolder, 0.7, 0.5, 0.3, 0.85, Theme.SubText, 0.12)

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
					if c:IsA("Frame") then c.BackgroundColor3 = T.SubText end
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

			local chevronHolder = create("Frame", {
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.new(1, -16, 0.5, -5),
				BackgroundTransparency = 1,
				Parent = selectedLabel,
			})
			ln(chevronHolder, 0.12, 0.32, 0.5, 0.7, Theme.SubText, 0.16)
			ln(chevronHolder, 0.5, 0.7, 0.88, 0.32, Theme.SubText, 0.16)

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
					if c:IsA("Frame") then c.BackgroundColor3 = T.SubText end
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
