-- UI Library v1.1 - Compatível com mouse e touch (dedo)
-- Design: Quadrado, borda preta 2px, borda azul interna 1px, fundo escuro.
-- Estrutura: Título + Abas (Scroll horizontal) + ScrollViews verticais lado a lado.
-- Suporte a CheckBox, Slider, Dropdown-CheckBox, Dropdown-Select
-- GitHub: https://github.com/SEU-USUARIO/UI-LIBRARY

local UILibrary = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createBorderedFrame(parent)
    local outer = Instance.new("Frame", parent)
    outer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outer.BorderSizePixel = 0
    outer.Size = UDim2.new(0, 520, 0, 460)
    outer.Position = UDim2.new(0.5, -260, 0.5, -230)
    outer.AnchorPoint = Vector2.new(0.5, 0.5)
    outer.Name = "Outer"

    local inner = Instance.new("Frame", outer)
    inner.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    inner.Position = UDim2.new(0, 2, 0, 2)
    inner.Size = UDim2.new(1, -4, 1, -4)
    inner.BorderSizePixel = 0

    local main = Instance.new("Frame", inner)
    main.BackgroundColor3 = Color3.fromRGB(28, 37, 38)
    main.Position = UDim2.new(0, 1, 0, 1)
    main.Size = UDim2.new(1, -2, 1, -2)
    main.BorderSizePixel = 0
    main.Name = "MainUI"

    return outer, main
end

function UILibrary:CreateWindow(titleText)
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "CustomUILibrary"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local outerFrame, mainUI = createBorderedFrame(gui)

    -- Título
    local title = Instance.new("TextLabel", mainUI)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = titleText or "Interface"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Abas
    local tabScroll = Instance.new("ScrollingFrame", mainUI)
    tabScroll.Size = UDim2.new(1, 0, 0, 35)
    tabScroll.Position = UDim2.new(0, 0, 0, 30)
    tabScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabScroll.BorderSizePixel = 0
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 35)
    tabScroll.ScrollBarThickness = 4
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.Name = "TabScroll"
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.X

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)

    local tabs = {}

    function tabs:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Text = name
        tabBtn.Font = Enum.Font.SourceSansBold
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.TextSize = 18
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = true
        tabBtn.Parent = tabScroll

        local container = Instance.new("Frame", mainUI)
        container.Position = UDim2.new(0, 0, 0, 65)
        container.Size = UDim2.new(1, 0, 1, -65)
        container.Visible = false
        container.Name = name
        container.BackgroundTransparency = 1

        local scrollLeft = Instance.new("ScrollingFrame", container)
        scrollLeft.Size = UDim2.new(0.5, -5, 1, 0)
        scrollLeft.Position = UDim2.new(0, 0, 0, 0)
        scrollLeft.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        scrollLeft.BorderSizePixel = 0
        scrollLeft.ScrollBarThickness = 6
        scrollLeft.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollLeft.Name = "Left"
        local leftLayout = Instance.new("UIListLayout", scrollLeft)
        leftLayout.Padding = UDim.new(0, 4)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local scrollRight = Instance.new("ScrollingFrame", container)
        scrollRight.Size = UDim2.new(0.5, -5, 1, 0)
        scrollRight.Position = UDim2.new(0.5, 5, 0, 0)
        scrollRight.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        scrollRight.BorderSizePixel = 0
        scrollRight.ScrollBarThickness = 6
        scrollRight.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollRight.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollRight.Name = "Right"
        local rightLayout = Instance.new("UIListLayout", scrollRight)
        rightLayout.Padding = UDim.new(0, 4)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function handleClick()
            for _, child in ipairs(mainUI:GetChildren()) do
                if child:IsA("Frame") and child ~= tabScroll and child ~= title then
                    child.Visible = false
                end
            end
            container.Visible = true
        end

        tabBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                handleClick()
            end
        end)

        return { Left = scrollLeft, Right = scrollRight, Name = name }
    end

    -- Componentes adicionais
    function tabs:AddCheckBox(tab, text, default, callback, side)
        local parent = tab[side or "Left"]
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -10, 0, 30); frame.BackgroundTransparency = 1

        local check = Instance.new("TextButton", frame)
        check.Size = UDim2.new(0, 24, 0, 24)
        check.Position = UDim2.new(0, 5, 0.5, -12)
        check.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        check.Text = default and "✔" or ""
        check.TextColor3 = Color3.fromRGB(255, 255, 255)
        check.Font = Enum.Font.SourceSansBold
        check.TextSize = 18
        check.BorderSizePixel = 0

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -35, 1, 0)
        label.Position = UDim2.new(0, 35, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left

        local state = default or false
        check.MouseButton1Click:Connect(function()
            state = not state
            check.Text = state and "✔" or ""
            if callback then callback(state) end
        end)
    end

    function tabs:AddSlider(tab, text, min, max, default, callback, side)
        local parent = tab[side or "Left"]
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, -10, 0, 50); container.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text..": "..tostring(default)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans; label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left

        local sliderBack = Instance.new("Frame", container)
        sliderBack.Position = UDim2.new(0, 0, 0, 28)
        sliderBack.Size = UDim2.new(1, 0, 0, 12)
        sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBack.BorderSizePixel = 0

        local sliderFill = Instance.new("Frame", sliderBack)
        sliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        sliderFill.BorderSizePixel = 0

        local dragging = false
        sliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                             input.UserInputType == Enum.UserInputType.Touch) then
                local rel = input.Position.X - sliderBack.AbsolutePosition.X
                local pct = math.clamp(rel / sliderBack.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max-min)*pct)
                sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                label.Text = text..": "..tostring(value)
                if callback then callback(value) end
            end
        end)
    end

    function tabs:AddDropdownSelect(tab, text, options, callback, side)
        local parent = tab[side or "Left"]
        local open = false

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, -10, 0, 36)
        container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

        local button = Instance.new("TextButton", container)
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Text = text
        button.BackgroundTransparency = 1
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18

        local dropdown = Instance.new("Frame", parent)
        dropdown.Position = UDim2.new(0, 5, 0, 40)
        dropdown.Size = UDim2.new(1, -10, 0, #options * 30)
        dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdown.Visible = false

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropdown)
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.Font = Enum.Font.SourceSans
            optBtn.TextSize = 18
            optBtn.BorderSizePixel = 0

            optBtn.MouseButton1Click:Connect(function()
                button.Text = text..": "..opt
                dropdown.Visible = false
                open = false
                if callback then callback(opt) end
            end)
        end

        button.MouseButton1Click:Connect(function()
            open = not open
            dropdown.Visible = open
        end)
    end

    function tabs:AddDropdownCheckBox(tab, text, options, callback, side)
        local parent = tab[side or "Left"]
        local open = false
        local selected = {}

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1, -10, 0, 36)
        container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

        local button = Instance.new("TextButton", container)
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Text = text
        button.BackgroundTransparency = 1
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSans
        button.TextSize = 18

        local dropdown = Instance.new("Frame", parent)
        dropdown.Position = UDim2.new(0, 5, 0, 40)
        dropdown.Size = UDim2.new(1, -10, 0, #options * 30)
        dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdown.Visible = false

        for _, opt in ipairs(options) do
            local row = Instance.new("Frame", dropdown)
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundTransparency = 1

            local box = Instance.new("TextButton", row)
            box.Size = UDim2.new(0, 24, 0, 24)
            box.Position = UDim2.new(0, 5, 0.5, -12)
            box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.Font = Enum.Font.SourceSansBold
            box.TextSize = 18
            box.BorderSizePixel = 0

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -35, 1, 0)
            lbl.Position = UDim2.new(0, 35, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = opt
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 18
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            box.MouseButton1Click:Connect(function()
                selected[opt] = not selected[opt]
                box.Text = selected[opt] and "✔" or ""
                if callback then
                    local res={}
                    for k,v in pairs(selected) do
                        if v then table.insert(res,k) end
                    end
                    callback(res)
                end
            end)
        end

        button.MouseButton1Click:Connect(function()
            open = not open
            dropdown.Visible = open
        end)
    end

    -- Dragging
    local dragging = false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        outerFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end

    outerFrame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = outerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    outerFrame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return tabs
end

return UILibrary
