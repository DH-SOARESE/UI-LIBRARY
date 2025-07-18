--[[
    DarkUI - Biblioteca de Interface de Usuário Dark Theme para Lua
    Otimizada para dispositivos móveis, executores como Delta, e integração via loadstring.
    Recursos: Menu com abas, ScrollView vertical, quadros, sliders, checkboxes, dropdowns, botões Show/Hide e Locked/Unlocked.
    Autor: github.com/roberto2929w
]]

local DarkUI = {}
local UIS = game:GetService("UserInputService")

--==[ Configuração do Tema ]==--
local theme = {
    bg = Color3.fromRGB(20, 20, 20),
    frame = Color3.fromRGB(30, 30, 30),
    border = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(0, 120, 255),
    text = Color3.fromRGB(255,255,255),
    shadow = Color3.fromRGB(10,10,10),
}

local font = Enum.Font.GothamBold

--==[ Funções Utilitárias ]==--
local function create(instance, props)
    local obj = Instance.new(instance)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function round(num, dec) return tonumber(string.format("%."..(dec or 0).."f", num)) end

--==[ Botão Centralizado ]==--
function DarkUI:CreateButton(parent, text, callback, state, toggleTexts)
    local btn = create("TextButton", {
        Parent = parent,
        Size = UDim2.new(0, 120, 0, 38),
        BackgroundColor3 = theme.bg,
        BorderColor3 = theme.accent,
        BorderSizePixel = 2,
        Text = toggleTexts and toggleTexts[state and 1 or 2] or text,
        TextColor3 = theme.text,
        Font = font,
        TextSize = 18,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
    })

    btn.MouseButton1Click:Connect(function()
        state = not state
        if toggleTexts then
            btn.Text = toggleTexts[state and 1 or 2]
        end
        callback(state)
    end)

    return btn, function(newState)
        state = newState
        if toggleTexts then
            btn.Text = toggleTexts[state and 1 or 2]
        end
    end
end

--==[ Quadro com borda sutil ]==--
function DarkUI:CreateFrame(parent, title)
    local frame = create("Frame", {
        Parent = parent,
        BackgroundColor3 = theme.frame,
        Size = UDim2.new(1, -24, 0, 120),
        BorderSizePixel = 1,
        BorderColor3 = theme.border,
        CornerRadius = UDim.new(0, 8),
    })
    create("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})

    local lbl = create("TextLabel", {
        Parent = frame,
        Text = title,
        Font = font,
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,0,0,4),
    })

    return frame
end

--==[ Sliders ]==--
function DarkUI:CreateSlider(parent, min, max, value, callback)
    local frame = create("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 44),
    })
    local sliderBar = create("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.border,
        Size = UDim2.new(1, -32, 0, 6),
        Position = UDim2.new(0, 16, 0, 20),
    })
    create("UICorner", {Parent = sliderBar, CornerRadius = UDim.new(1,0)})
    local knob = create("Frame", {
        Parent = sliderBar,
        BackgroundColor3 = theme.accent,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8),
    })
    create("UICorner", {Parent = knob, CornerRadius = UDim.new(1,0)})
    local valueLabel = create("TextLabel", {
        Parent = frame,
        Text = tostring(value),
        Font = font,
        TextSize = 14,
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -40, 0, 0),
    })

    local dragging = false
    local function setValue(x)
        local rel = math.clamp((x-sliderBar.AbsolutePosition.X)/sliderBar.AbsoluteSize.X, 0, 1)
        local val = round(min + (max-min)*rel, 2)
        knob.Position = UDim2.new(rel, -8, 0.5, -8)
        valueLabel.Text = tostring(val)
        callback(val)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setValue(input.Position.X)
        end
    end)

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setValue(input.Position.X)
            dragging = true
        end
    end)

    return frame
end

--==[ Checkbox ]==--
function DarkUI:CreateCheckbox(parent, text, state, callback)
    local frame = create("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
    })
    local box = create("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.bg,
        BorderColor3 = theme.accent,
        BorderSizePixel = 2,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0, 4),
    })
    create("UICorner", {Parent = box, CornerRadius = UDim.new(0,6)})
    local check = create("TextLabel", {
        Parent = box,
        Text = state and "✓" or "",
        Font = font,
        TextSize = 18,
        BackgroundTransparency = 1,
        TextColor3 = theme.accent,
        Size = UDim2.new(1,0,1,0),
    })
    local lbl = create("TextLabel", {
        Parent = frame,
        Text = text,
        Font = font,
        TextSize = 14,
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
    })

    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            check.Text = state and "✓" or ""
            callback(state)
        end
    end)
    return frame
end

--==[ Dropdown ]==--
function DarkUI:CreateDropdown(parent, items, selectedIdx, callback)
    local frame = create("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
    })
    local btn = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.bg,
        BorderColor3 = theme.accent,
        BorderSizePixel = 2,
        Text = items[selectedIdx],
        TextColor3 = theme.text,
        Font = font,
        TextSize = 16,
        AutoButtonColor = false,
    })
    local ddFrame = create("Frame", {
        Parent = frame,
        BackgroundColor3 = theme.bg,
        BorderColor3 = theme.accent,
        BorderSizePixel = 2,
        Size = UDim2.new(1,0,0,0),
        Position = UDim2.new(0,0,0,38),
        Visible = false,
        ZIndex = 5,
    })
    create("UICorner", {Parent = ddFrame, CornerRadius = UDim.new(0,6)})
    local layout = create("UIListLayout", {Parent = ddFrame, Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder})

    btn.MouseButton1Click:Connect(function()
        ddFrame.Visible = not ddFrame.Visible
        ddFrame.Size = UDim2.new(1,0,0,ddFrame.Visible and (#items*34) or 0)
    end)
    for i, item in ipairs(items) do
        local opt = create("TextButton", {
            Parent = ddFrame,
            Size = UDim2.new(1,0,0,32),
            BackgroundColor3 = theme.bg,
            BorderSizePixel = 0,
            Text = item,
            TextColor3 = theme.text,
            Font = font,
            TextSize = 16,
            AutoButtonColor = true,
        })
        opt.MouseButton1Click:Connect(function()
            selectedIdx = i
            btn.Text = item
            ddFrame.Visible = false
            ddFrame.Size = UDim2.new(1,0,0,0)
            callback(item)
        end)
    end
    return frame
end

--==[ Quadrado Simples ]==--
function DarkUI:CreateSquare(parent, color)
    local frame = create("Frame", {
        Parent = parent,
        BackgroundColor3 = color or theme.accent,
        Size = UDim2.new(0, 44, 0, 44),
        BorderSizePixel = 2,
        BorderColor3 = theme.border,
    })
    create("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})
    return frame
end

--==[ ScrollView Vertical ]==--
function DarkUI:CreateScrollView(parent)
    local scroll = create("ScrollingFrame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = theme.accent,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
    })
    local layout = create("UIListLayout", {
        Parent = scroll,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
    end)
    return scroll
end

--==[ Menu com Abas Horizontais ]==--
function DarkUI:CreateMenu(tabs, parent)
    -- Menu Container
    local menu = create("Frame", {
        Parent = parent,
        Size = UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250),
        BackgroundColor3 = theme.bg,
        BorderSizePixel = 2,
        BorderColor3 = theme.accent,
        Visible = true,
        AnchorPoint = Vector2.new(0.5,0.5),
    })
    create("UICorner", {Parent = menu, CornerRadius = UDim.new(0,12)})
    local shadow = create("Frame", {
        Parent = menu,
        Size = UDim2.new(1,12,1,12),
        Position = UDim2.new(0,-6,0,-6),
        BackgroundColor3 = theme.shadow,
        BorderSizePixel = 0,
        ZIndex = 0,
    })
    shadow.BackgroundTransparency = 0.8

    -- Abas Horizontais
    local tabBar = create("Frame", {
        Parent = menu,
        Size = UDim2.new(1,0,0,48),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
    })
    local tabLayout = create("UIListLayout", {
        Parent = tabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Área de Conteúdo com ScrollView Vertical
    local contentFrame = create("Frame", {
        Parent = menu,
        Size = UDim2.new(1,0,1,-48),
        Position = UDim2.new(0,0,0,48),
        BackgroundTransparency = 1,
    })
    local tabContents = {}
    local activeTab = 1
    for i, tabName in ipairs(tabs) do
        local tabBtn = create("TextButton", {
            Parent = tabBar,
            Size = UDim2.new(0,120,1,-8),
            BackgroundColor3 = i==1 and theme.accent or theme.bg,
            BorderSizePixel = 0,
            Text = tabName,
            TextColor3 = i==1 and theme.bg or theme.text,
            Font = font,
            TextSize = 16,
            AutoButtonColor = false,
        })
        tabBtn.MouseButton1Click:Connect(function()
            for j, v in ipairs(tabBar:GetChildren()) do
                if v:IsA("TextButton") then
                    v.BackgroundColor3 = theme.bg
                    v.TextColor3 = theme.text
                end
            end
            tabBtn.BackgroundColor3 = theme.accent
            tabBtn.TextColor3 = theme.bg
            for idx, frame in ipairs(tabContents) do
                frame.Visible = idx == i
            end
            activeTab = i
        end)
        -- Dois layouts/ScrollViews por aba
        local tabContent = create("Frame", {
            Parent = contentFrame,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = i==1,
        })
        local sv1 = DarkUI:CreateScrollView(tabContent)
        sv1.Position = UDim2.new(0,12,0,0)
        sv1.Size = UDim2.new(0.5,-18,1,-8)
        local sv2 = DarkUI:CreateScrollView(tabContent)
        sv2.Position = UDim2.new(0.5,6,0,0)
        sv2.Size = UDim2.new(0.5,-18,1,-8)
        tabContents[i] = tabContent
        -- Exemplo de inserção de elementos
        DarkUI:CreateFrame(sv1, "Quadro 1 - "..tabName)
        DarkUI:CreateSlider(sv1, 0, 100, 50, function(v) end)
        DarkUI:CreateCheckbox(sv1, "Ativar?", false, function(v) end)
        DarkUI:CreateDropdown(sv1, {"Opção A","Opção B","Opção C"}, 1, function(v) end)
        DarkUI:CreateSquare(sv1, theme.accent)
        DarkUI:CreateFrame(sv2, "Quadro 2 - "..tabName)
        DarkUI:CreateSlider(sv2, 0, 1, 0.5, function(v) end)
        DarkUI:CreateCheckbox(sv2, "Check", true, function(v) end)
        DarkUI:CreateDropdown(sv2, {"Item 1","Item 2","Item 3"}, 2, function(v) end)
        DarkUI:CreateSquare(sv2, Color3.fromRGB(255,0,0))
    end

    --==[ Drag & Lock ]==--
    local dragging = false
    local dragLock = false
    local dragStart, menuStart
    menu.InputBegan:Connect(function(input)
        if not dragLock and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            menuStart = menu.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            menu.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    --==[ Botões Show/Hide e Lock/Unlock ]==--
    local btnFrame = create("Frame", {
        Parent = parent,
        Size = UDim2.new(0,140,0,88),
        Position = UDim2.new(0,12,0.5,-44),
        BackgroundTransparency = 1,
        ZIndex = 100,
    })
    local showState, lockState = true, false
    local showBtn, setShow = DarkUI:CreateButton(btnFrame, "Show", function(state)
        showState = state
        menu.Visible = showState
        setShow(showState)
    end, true, {"Hide","Show"})
    showBtn.Position = UDim2.new(0.5,0,0,0)
    local lockBtn, setLock = DarkUI:CreateButton(btnFrame, "Locked", function(state)
        lockState = state
        dragLock = lockState
        setLock(lockState)
    end, false, {"Unlocked","Locked"})
    lockBtn.Position = UDim2.new(0.5,0,0,48)

    -- Para mobile: aumentar área de toque dos botões e scrolls
    showBtn.TouchLongPress:Connect(function() showBtn.BackgroundColor3 = theme.accent end)
    lockBtn.TouchLongPress:Connect(function() lockBtn.BackgroundColor3 = theme.accent end)

    -- Retorno do menu para uso externo
    return menu
end

return DarkUI
