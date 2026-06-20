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

local function create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function makeCorner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

local function makeStroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(200, 200, 200),
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
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

-- theme/color
local Theme = {
    Background = Color3.fromRGB(245, 245, 247),
    Sidebar         = Color3.fromRGB(235, 235, 237),
    TopBar          = Color3.fromRGB(238, 238, 240),
    Text            = Color3.fromRGB(20,  20,  22),
    SubText         = Color3.fromRGB(110, 110, 115),
    Accent          = Color3.fromRGB(0,   122, 255),
    AccentHover     = Color3.fromRGB(30,  142, 255),
    Divider         = Color3.fromRGB(210, 210, 215),
    TabActive       = Color3.fromRGB(255, 255, 255),
    TabInactive     = Color3.fromRGB(235, 235, 237),
    Toggle_On       = Color3.fromRGB(48,  209, 88),
    Toggle_Off      = Color3.fromRGB(180, 180, 185),
    SliderFill      = Color3.fromRGB(0,   122, 255),
    SliderBG        = Color3.fromRGB(210, 210, 215),
    InputBG         = Color3.fromRGB(255, 255, 255),
    Shadow          = Color3.fromRGB(0,   0,   0),
    White           = Color3.fromRGB(255, 255, 255),
    ButtonBG        = Color3.fromRGB(255, 255, 255),
    ButtonHover     = Color3.fromRGB(240, 240, 245),
}

function MacOSLib:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "MacOS UI"
    local subtitle = config.Subtitle or "by MacOSLib"
    local width    = config.Width    or 520
    local height   = config.Height   or 360
    local key      = config.ToggleKey or Enum.KeyCode.RightControl

    -- ScreenGui
    local gui = create("ScreenGui", {
        Name = "MacOSLib_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end

    local shadow = create("Frame", {
        Name = "Shadow",
        Size = UDim2.new(0, width + 16, 0, height + 16),
        Position = UDim2.new(0.5, -(width/2) - 8, 0.5, -(height/2) - 8),
        BackgroundColor3 = Theme.Shadow,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Parent = gui,
    })
    makeCorner(16):Parent = shadow

    -- main window
    local window = create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = gui,
    })
    makeCorner(12):Parent = window
    makeStroke(Theme.Divider, 1, 0.3):Parent = window

    -- topbar
    local topbar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.TopBar,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Parent = window,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 12) }):Parent = topbar
    -- cobrir cantos inferiores do topbar
    create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.TopBar,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Parent = topbar,
    })

    -- topbar divisor
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = topbar,
    })

    local trafficX = 14
    for i, color in ipairs({
        Color3.fromRGB(255, 95, 87), -- close
        Color3.fromRGB(255, 189, 46), -- minimize
        Color3.fromRGB(39, 201, 63), -- maximize
    }) do
        local btn = create("Frame", {
            Name = "TrafficLight" .. i,
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(0, trafficX, 0.5, -6),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = topbar,
        })
        makeCorner(50):Parent = btn
        trafficX = trafficX + 20

        -- close button
        if i == 1 then
            local closeBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = btn,
            })
            closeBtn.MouseButton1Click:Connect(function()
                tween(gui.Shadow, { BackgroundTransparency = 1 }, 0.2)
                tween(window, { BackgroundTransparency = 1, Size = UDim2.new(0, width, 0, 0) }, 0.2)
                task.delay(0.22, function() gui:Destroy() end)
            end)
        end
    end

    -- title
    create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = topbar,
    })

    -- subtitle
    create("TextLabel", {
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
    local baseWindowPos, baseShadowPos
    RunService.RenderStepped:Connect(function()
        shadow.Position = UDim2.new(
            window.Position.X.Scale,
            window.Position.X.Offset - 8,
            window.Position.Y.Scale,
            window.Position.Y.Offset - 8
        )
    end)

    -- visibility toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == key then
            window.Visible = not window.Visible
            shadow.Visible = window.Visible
        end
    end)

    -- tabs sidebar
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 130, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = window,
    })

    -- divider sidebar
    create("Frame", {
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
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabList,
    })
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = tabList,
    })

    -- content area
    local contentHolder = create("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -130, 1, -44),
        Position = UDim2.new(0, 130, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = window,
    })

    -- animation entry
    window.Size = UDim2.new(0, width, 0, 0)
    window.BackgroundTransparency = 1
    shadow.BackgroundTransparency = 1
    tween(window, { Size = UDim2.new(0, width, 0, height), BackgroundTransparency = 0.04 }, 0.3, Enum.EasingStyle.Back)
    tween(shadow, { BackgroundTransparency = 0.82 }, 0.3)

    -- window

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
                BackgroundTransparency = isActive and 0 or 0,
            }, 0.15)
            t._btn.Label.TextColor3 = isActive and Theme.Text or Theme.SubText
            t._btn.Label.Font = isActive and Enum.Font.GothamSemibold or Enum.Font.Gotham
            t._page.Visible = isActive
        end
    end

    -- create tab
    function Window:CreateTab(name, icon)
        local tab = {}

        -- sidebar button
        local btn = create("TextButton", {
            Name = name .. "_Tab",
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
        })
        makeCorner(8):Parent = btn

        -- icon
        if icon then
            create("TextLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = icon,
                TextSize = 16,
                Font = Enum.Font.Gotham,
                TextColor3 = Theme.SubText,
                Parent = btn,
            })
        end

        local labelOffset = icon and 32 or 10
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

        -- content page
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
        create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = page,
        })
        create("UIPadding", {
            PaddingTop    = UDim.new(0, 12),
            PaddingLeft   = UDim.new(0, 14),
            PaddingRight  = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 12),
            Parent = page,
        })

        tab._btn  = btn
        tab._btn.Label = label
        tab._page = page
        tab._window = self

        btn.MouseButton1Click:Connect(function()
            self:_setActive(tab)
        end)
        btn.MouseEnter:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.TabInactive }, 0.1)
            end
        end)

        table.insert(self._tabs, tab)
        if #self._tabs == 1 then
            self:_setActive(tab)
        end

	-- tab elements

        -- section
        function tab:AddSection(text)
            create("TextLabel", {
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

        -- button
        function tab:AddButton(text, callback)
            local btn2 = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.ButtonBG,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = #page:GetChildren(),
                Parent = page,
            })
            makeCorner(8):Parent = btn2
            makeStroke(Theme.Divider, 1, 0.5):Parent = btn2

            create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn2,
            })

            -- chevron
            create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -26, 0, 0),
                BackgroundTransparency = 1,
                Text = "›",
                TextColor3 = Theme.SubText,
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                Parent = btn2,
            })

            btn2.MouseEnter:Connect(function()
                tween(btn2, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
            end)
            btn2.MouseLeave:Connect(function()
                tween(btn2, { BackgroundColor3 = Theme.ButtonBG }, 0.1)
            end)
            btn2.MouseButton1Click:Connect(function()
                tween(btn2, { BackgroundColor3 = Theme.Divider }, 0.08)
                task.delay(0.1, function()
                    tween(btn2, { BackgroundColor3 = Theme.ButtonBG }, 0.1)
                end)
                if callback then callback() end
            end)

            return btn2
        end

        -- toggle
        function tab:AddToggle(text, default, callback)
            local value = default or false

            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.ButtonBG,
                BorderSizePixel = 0,
                LayoutOrder = #page:GetChildren(),
                Parent = page,
            })
            makeCorner(8):Parent = row
            makeStroke(Theme.Divider, 1, 0.5):Parent = row

            create("TextLabel", {
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

            -- track
            local track = create("Frame", {
                Size = UDim2.new(0, 44, 0, 26),
                Position = UDim2.new(1, -54, 0.5, -13),
                BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel = 0,
                Parent = row,
            })
            makeCorner(50):Parent = track

            -- thumb
            local thumb = create("Frame", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(0, value and 20 or 2, 0.5, -11),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = track,
            })
            makeCorner(50):Parent = thumb
            -- sombra no thumb
            create("UIStroke", {
                Color = Color3.fromRGB(0,0,0),
                Thickness = 0.5,
                Transparency = 0.8,
                Parent = thumb,
            })

            local clickArea = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = row,
            })

            clickArea.MouseButton1Click:Connect(function()
                value = not value
                tween(track, { BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off }, 0.2)
                tween(thumb, { Position = UDim2.new(0, value and 20 or 2, 0.5, -11) }, 0.2)
                if callback then callback(value) end
            end)

            local toggle = {}
            function toggle:Set(v)
                value = v
                tween(track, { BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off }, 0.2)
                tween(thumb, { Position = UDim2.new(0, value and 20 or 2, 0.5, -11) }, 0.2)
            end
            function toggle:Get() return value end
            return toggle
        end

        -- slider
        function tab:AddSlider(text, min, max, default, callback)
            min = min or 0
            max = max or 100
            local value = default or min

            local container = create("Frame", {
                Size = UDim2.new(1, 0, 0, 58),
                BackgroundColor3 = Theme.ButtonBG,
                BorderSizePixel = 0,
                LayoutOrder = #page:GetChildren(),
                Parent = page,
            })
            makeCorner(8):Parent = container
            makeStroke(Theme.Divider, 1, 0.5):Parent = container

            -- label + value
            create("TextLabel", {
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

            -- slider trail
            local track = create("Frame", {
                Size = UDim2.new(1, -28, 0, 4),
                Position = UDim2.new(0, 14, 1, -18),
                BackgroundColor3 = Theme.SliderBG,
                BorderSizePixel = 0,
                Parent = container,
            })
            makeCorner(50):Parent = track

            local fill = create("Frame", {
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel = 0,
                Parent = track,
            })
            makeCorner(50):Parent = fill

            -- thumb
            local knob = create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Parent = track,
            })
            makeCorner(50):Parent = knob
            makeStroke(Theme.SliderFill, 2, 0):Parent = knob

            -- interaction
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

        -- input text
        function tab:AddInput(text, placeholder, callback)
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.ButtonBG,
                BorderSizePixel = 0,
                LayoutOrder = #page:GetChildren(),
                Parent = page,
            })
            makeCorner(8):Parent = row
            makeStroke(Theme.Divider, 1, 0.5):Parent = row

            create("TextLabel", {
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
            makeCorner(6):Parent = inputBox
            makeStroke(Theme.Accent, 1, 0.6):Parent = inputBox
            create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = inputBox,
            })

            inputBox.FocusLost:Connect(function(enter)
                if enter and callback then
                    callback(inputBox.Text)
                end
            end)

            return inputBox
        end

        -- dropdown
        function tab:AddDropdown(text, options, callback)
            local selected = options[1] or ""
            local open = false

            local container = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.ButtonBG,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                LayoutOrder = #page:GetChildren(),
                ZIndex = 5,
                Parent = page,
            })
            makeCorner(8):Parent = container
            makeStroke(Theme.Divider, 1, 0.5):Parent = container

            create("TextLabel", {
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
                Text = selected .. "  ▾",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = container,
            })
            makeCorner(6):Parent = selectedLabel
            makeStroke(Theme.Divider, 1, 0.5):Parent = selectedLabel

            -- dropdown list
            local dropList = create("Frame", {
                Size = UDim2.new(0.46, 0, 0, #options * 30 + 8),
                Position = UDim2.new(0.5, 0, 1, 4),
                BackgroundColor3 = Theme.White,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 10,
                Parent = container,
            })
            makeCorner(8):Parent = dropList
            makeStroke(Theme.Divider, 1, 0.3):Parent = dropList
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0),
                Parent = dropList,
            })
            create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                Parent = dropList,
            })

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
                    selectedLabel.Text = opt .. "  ▾"
                    dropList.Visible = false
                    open = false
                    if callback then callback(opt) end
                end)
            end

            selectedLabel.MouseButton1Click:Connect(function()
                open = not open
                dropList.Visible = open
            end)

            local dd = {}
            function dd:Set(v) selected = v; selectedLabel.Text = v .. "  ▾" end
            function dd:Get() return selected end
            return dd
        end

        -- label
        function tab:AddLabel(text)
            create("TextLabel", {
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

    -- notify
    function Window:Notify(title, message, duration)
        duration = duration or 3

        local notif = create("Frame", {
            Size = UDim2.new(0, 260, 0, 64),
            Position = UDim2.new(1, 10, 1, -80),
            BackgroundColor3 = Theme.White,
            BorderSizePixel = 0,
            Parent = gui,
        })
        makeCorner(12):Parent = notif
        makeStroke(Theme.Divider, 1, 0.3):Parent = notif

        create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 22),
            Position = UDim2.new(0, 14, 0, 10),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif,
        })
        create("TextLabel", {
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
        makeCorner(50):Parent = bar

        tween(notif, { Position = UDim2.new(1, -270, 1, -80) }, 0.4, Enum.EasingStyle.Back)
        tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)

        task.delay(duration, function()
            tween(notif, { Position = UDim2.new(1, 10, 1, -80) }, 0.3)
            task.delay(0.35, function() notif:Destroy() end)
        end)
    end

    return Window
end

return MacOSLib
