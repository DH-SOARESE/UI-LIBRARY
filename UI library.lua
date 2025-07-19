-- UI Library completa com suporte Touch e menu centralizado

local UILibrary = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createBorderedFrame(parent)
    local outer = Instance.new("Frame", parent)
    outer.Size = UDim2.new(0, 520, 0, 460)
    outer.Position = UDim2.new(0.5, -260, 0.5, -230) -- CENTRALIZADO
    outer.AnchorPoint = Vector2.new(0.5, 0.5)
    outer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outer.BorderSizePixel = 0

    local inner = Instance.new("Frame", outer)
    inner.Size = UDim2.new(1, -4, 1, -4)
    inner.Position = UDim2.new(0, 2, 0, 2)
    inner.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    inner.BorderSizePixel = 0

    local main = Instance.new("Frame", inner)
    main.Size = UDim2.new(1, -2, 1, -2)
    main.Position = UDim2.new(0, 1, 0, 1)
    main.BackgroundColor3 = Color3.fromRGB(28, 37, 38)
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
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Área de Abas (Scroll horizontal)
    local tabScroll = Instance.new("ScrollingFrame", mainUI)
    tabScroll.Size = UDim2.new(1, 0, 0, 35)
    tabScroll.Position = UDim2.new(0, 0, 0, 30)
    tabScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabScroll.BorderSizePixel = 0
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 35)
    tabScroll.ScrollBarThickness = 4
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    tabScroll.Name = "TabScroll"

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
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.TextSize = 18
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = true
        tabBtn.Parent = tabScroll

        local container = Instance.new("Frame", mainUI)
        container.Position = UDim2.new(0, 0, 0, 65)
        container.Size = UDim2.new(1, 0, 1, -65)
        container.BackgroundTransparency = 0.1
        container.Visible = false
        container.Name = name
        container.BackgroundTransparency = 1

        local scrollLeft = Instance.new("ScrollingFrame", container)
        scrollLeft.Size = UDim2.new(0.5, -5, 1, 0)
        scrollLeft.Position = UDim2.new(0, 0, 0, 0)
        scrollLeft.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        scrollLeft.BorderSizePixel = 0
        scrollLeft.ScrollBarThickness = 6
        scrollLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollLeft.CanvasSize = UDim2.new(0, 0, 0, 0)
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
        scrollRight.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollRight.CanvasSize = UDim2.new(0, 0, 0, 0)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                handleClick()
            end
        end)

        return {
            Left = scrollLeft,
            Right = scrollRight,
            Name = name
        }
    end

    -- Arrasto do menu (mouse ou toque)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        outerFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end

    outerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = outerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    outerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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


-- Função auxiliar para criar base dos elementos (Toggle, Slider, etc)
local function createBaseElement(text, parent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 36)
    holder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    holder.BorderSizePixel = 0
    holder.Name = text
    holder.Parent = parent

    local label = Instance.new("TextLabel", holder)
    label.Text = text
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left

    return holder, label
end


function UILibrary:AddToggle(tab, side, text, default, callback)
    local parent = tab[side]
    local holder = createBaseElement(text, parent)

    local toggle = Instance.new("TextButton", holder)
    toggle.Size = UDim2.new(0, 30, 0, 30)
    toggle.Position = UDim2.new(1, -35, 0.5, -15)
    toggle.Text = ""
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(100, 100, 100)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false

    local state = default

    local function setState(val)
        state = val
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(100, 100, 100)
        if callback then callback(state) end
    end

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            setState(not state)
        end
    end)
end


function UILibrary:AddSlider(tab, side, text, min, max, default, callback)
    local parent = tab[side]
    local holder, label = createBaseElement(text .. ": " .. tostring(default), parent)

    local sliderBack = Instance.new("Frame", holder)
    sliderBack.Size = UDim2.new(0.6, 0, 0, 6)
    sliderBack.Position = UDim2.new(0, 140, 0.5, -3)
    sliderBack.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    sliderBack.BorderSizePixel = 0

    local fill = Instance.new("Frame", sliderBack)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0

    local dragging = false

    local function setValueFromInput(x)
        local rel = math.clamp((x - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + ((max - min) * rel)) + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = text .. ": " .. tostring(val)
        if callback then callback(val) end
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValueFromInput(input.Position.X)
        end
    end)

    sliderBack.InputEnded:Connect(function(input)
        dragging = false
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            setValueFromInput(input.Position.X)
        end
    end)
end


function UILibrary:AddDropdown(tab, side, text, options, defaultIndex, callback)
    local parent = tab[side]
    local holder, label = createBaseElement(text, parent)

    local button = Instance.new("TextButton", holder)
    button.Size = UDim2.new(0, 100, 1, -8)
    button.Position = UDim2.new(1, -105, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Text = options[defaultIndex] or options[1]
    button.BorderSizePixel = 0

    local dropdownOpen = false
    local dropdownFrame = nil

    local function openDropdown()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
            return
        end

        dropdownFrame = Instance.new("Frame", holder)
        dropdownFrame.Size = UDim2.new(0, 100, 0, math.min(#options * 26, 130))
        dropdownFrame.Position = UDim2.new(1, -105, 1, 0)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.ClipsDescendants = true

        local layout = Instance.new("UIListLayout", dropdownFrame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropdownFrame)
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundTransparency = 0
            optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            optBtn.Text = opt
            optBtn.Font = Enum.Font.SourceSans
            optBtn.TextSize = 16
            optBtn.TextColor3 = Color3.new(1, 1, 1)
            optBtn.BorderSizePixel = 0

            optBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    button.Text = opt
                    if callback then callback(opt) end
                    dropdownFrame:Destroy()
                    dropdownOpen = false
                end
            end)
        end

        dropdownOpen = true
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            openDropdown()
        end
    end)
end


function UILibrary:AddDropdownToggle(tab, side, text, toggles)
    local parent = tab[side]
    local holder, label = createBaseElement(text, parent)

    local button = Instance.new("TextButton", holder)
    button.Size = UDim2.new(0, 100, 1, -8)
    button.Position = UDim2.new(1, -105, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Text = "Abrir"
    button.BorderSizePixel = 0

    local dropdownOpen = false
    local dropdownFrame = nil

    local function openDropdown()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
            return
        end

        dropdownFrame = Instance.new("Frame", holder)
        dropdownFrame.Size = UDim2.new(0, 100, 0, math.min(#toggles * 26, 130))
        dropdownFrame.Position = UDim2.new(1, -105, 1, 0)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdownFrame.BorderSizePixel = 0

        local layout = Instance.new("UIListLayout", dropdownFrame)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, item in ipairs(toggles) do
            local toggle = Instance.new("TextButton", dropdownFrame)
            toggle.Size = UDim2.new(1, 0, 0, 26)
            toggle.Text = "[ ] " .. item.Name
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toggle.Font = Enum.Font.SourceSans
            toggle.TextSize = 16
            toggle.TextColor3 = Color3.new(1, 1, 1)
            toggle.BorderSizePixel = 0

            local value = item.Default or false

            local function updateText()
                toggle.Text = (value and "[✔] " or "[ ] ") .. item.Name
            end

            toggle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    value = not value
                    updateText()
                    if item.Callback then item.Callback(value) end
                end
            end)

            updateText()
        end

        dropdownOpen = true
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            openDropdown()
        end
    end)
end


return UILibrary
