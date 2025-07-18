local DarkUI = {}

-- Configurações iniciais
DarkUI.settings = {
    theme = {
        background = Color3.fromRGB(30, 30, 30),
        foreground = Color3.fromRGB(45, 45, 45),
        accent = Color3.fromRGB(0, 120, 215),
        text = Color3.fromRGB(255, 255, 255),
        border = Color3.fromRGB(70, 70, 70)
    },
    font = Enum.Font.SourceSansBold,
    textSize = 14,
    cornerRadius = UDim.new(0, 6),
    elementPadding = 10
}

-- Variáveis de estado
DarkUI.menuVisible = true
DarkUI.menuLocked = false
DarkUI.dragStartPos = nil
DarkUI.menuPosition = nil

-- Função para criar um frame básico
function DarkUI.createFrame(parent, size, position, bgColor, transparency, name)
    local frame = Instance.new("Frame")
    frame.Name = name or "Frame"
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = bgColor or DarkUI.settings.theme.foreground
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    return frame
end

-- Função para criar texto
function DarkUI.createText(parent, text, size, position, color, name)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = name or "TextLabel"
    textLabel.Size = size or UDim2.new(1, 0, 0, 20)
    textLabel.Position = position or UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text or ""
    textLabel.TextColor3 = color or DarkUI.settings.theme.text
    textLabel.TextSize = DarkUI.settings.textSize
    textLabel.Font = DarkUI.settings.font
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = parent
    return textLabel
end

-- Função para criar botão
function DarkUI.createButton(parent, text, size, position, callback, name)
    local button = Instance.new("TextButton")
    button.Name = name or "Button"
    button.Size = size or UDim2.new(0, 120, 0, 30)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = DarkUI.settings.theme.background
    button.TextColor3 = DarkUI.settings.theme.text
    button.Text = text or "Button"
    button.TextSize = DarkUI.settings.textSize
    button.Font = DarkUI.settings.font
    button.AutoButtonColor = true
    
    -- Estilização
    local corner = Instance.new("UICorner")
    corner.CornerRadius = DarkUI.settings.cornerRadius
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = DarkUI.settings.theme.accent
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- Interações para mobile
    button.TouchLongPress:Connect(function()
        if callback then callback() end
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    button.Parent = parent
    return button
end

-- Função para criar checkbox
function DarkUI.createCheckbox(parent, text, defaultValue, callback, name)
    local container = Instance.new("Frame")
    container.Name = name or "CheckboxContainer"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local checkbox = Instance.new("Frame")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = DarkUI.settings.theme.background
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkbox
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = DarkUI.settings.theme.accent
    stroke.Thickness = 2
    stroke.Parent = checkbox
    
    local checkmark = Instance.new("ImageLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
    checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://7072718162" -- Ícone de check
    checkmark.ImageColor3 = DarkUI.settings.theme.accent
    checkmark.Visible = defaultValue or false
    checkmark.Parent = checkbox
    
    local label = DarkUI.createText(container, text, UDim2.new(1, -30, 1, 0), UDim2.new(0, 30, 0, 0))
    
    checkbox.Parent = container
    
    -- Interações
    local function toggle()
        checkmark.Visible = not checkmark.Visible
        if callback then callback(checkmark.Visible) end
    end
    
    checkbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
    
    return {
        container = container,
        checkbox = checkbox,
        checkmark = checkmark,
        setValue = function(self, value)
            checkmark.Visible = value
            if callback then callback(value) end
        end
    }
end

-- Função para criar slider
function DarkUI.createSlider(parent, text, min, max, defaultValue, callback, name)
    local container = Instance.new("Frame")
    container.Name = name or "SliderContainer"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local title = DarkUI.createText(container, text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0))
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, 0, 0, 10)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = DarkUI.settings.theme.background
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = sliderTrack
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = DarkUI.settings.theme.border
    stroke.Thickness = 1
    stroke.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = DarkUI.settings.theme.accent
    
    local cornerFill = Instance.new("UICorner")
    cornerFill.CornerRadius = UDim.new(1, 0)
    cornerFill.Parent = sliderFill
    
    local sliderThumb = Instance.new("Frame")
    sliderThumb.Name = "SliderThumb"
    sliderThumb.Size = UDim2.new(0, 20, 0, 20)
    sliderThumb.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0.5, -10)
    sliderThumb.BackgroundColor3 = DarkUI.settings.theme.accent
    sliderThumb.ZIndex = 2
    
    local cornerThumb = Instance.new("UICorner")
    cornerThumb.CornerRadius = UDim.new(1, 0)
    cornerThumb.Parent = sliderThumb
    
    local strokeThumb = Instance.new("UIStroke")
    strokeThumb.Color = DarkUI.settings.theme.text
    strokeThumb.Thickness = 2
    strokeThumb.Parent = sliderThumb
    
    local valueLabel = DarkUI.createText(container, tostring(defaultValue), UDim2.new(0, 50, 0, 20), UDim2.new(1, -50, 0, 0))
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    sliderFill.Parent = sliderTrack
    sliderThumb.Parent = sliderTrack
    sliderTrack.Parent = container
    
    -- Lógica de interação
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        local value = min + (max - min) * relativeX
        value = math.floor(value * 100) / 100 -- Arredonda para 2 casas decimais
        
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderThumb.Position = UDim2.new(relativeX, -10, 0.5, -10)
        valueLabel.Text = tostring(value)
        
        if callback then callback(value) end
    end
    
    sliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    return {
        container = container,
        setValue = function(self, value)
            local relativeX = (value - min) / (max - min)
            relativeX = math.clamp(relativeX, 0, 1)
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderThumb.Position = UDim2.new(relativeX, -10, 0.5, -10)
            valueLabel.Text = tostring(value)
            
            if callback then callback(value) end
        end
    }
end

-- Função para criar dropdown
function DarkUI.createDropdown(parent, text, options, defaultOption, callback, name)
    local container = Instance.new("Frame")
    container.Name = name or "DropdownContainer"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = parent
    
    local title = DarkUI.createText(container, text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0))
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0, 0, 0, 25)
    dropdownButton.BackgroundColor3 = DarkUI.settings.theme.background
    dropdownButton.TextColor3 = DarkUI.settings.theme.text
    dropdownButton.Text = defaultOption or (options and options[1] or "Select")
    dropdownButton.TextSize = DarkUI.settings.textSize
    dropdownButton.Font = DarkUI.settings.font
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = DarkUI.settings.cornerRadius
    corner.Parent = dropdownButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = DarkUI.settings.theme.accent
    stroke.Thickness = 2
    stroke.Parent = dropdownButton
    
    local dropdownIcon = Instance.new("ImageLabel")
    dropdownIcon.Name = "DropdownIcon"
    dropdownIcon.Size = UDim2.new(0, 20, 0, 20)
    dropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
    dropdownIcon.AnchorPoint = Vector2.new(1, 0.5)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Image = "rbxassetid://7072723420" -- Ícone de seta para baixo
    dropdownIcon.ImageColor3 = DarkUI.settings.theme.accent
    dropdownIcon.Parent = dropdownButton
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 0, 60)
    dropdownList.BackgroundColor3 = DarkUI.settings.theme.foreground
    dropdownList.ScrollBarThickness = 5
    dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.Visible = false
    
    local cornerList = Instance.new("UICorner")
    cornerList.CornerRadius = DarkUI.settings.cornerRadius
    cornerList.Parent = dropdownList
    
    local strokeList = Instance.new("UIStroke")
    strokeList.Color = DarkUI.settings.theme.border
    strokeList.Thickness = 1
    strokeList.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList
    
    -- Criar itens do dropdown
    local function createDropdownItems()
        for i, option in ipairs(options) do
            local itemButton = Instance.new("TextButton")
            itemButton.Name = "Item_" .. option
            itemButton.Size = UDim2.new(1, -10, 0, 30)
            itemButton.Position = UDim2.new(0, 5, 0, (i-1)*32)
            itemButton.BackgroundColor3 = DarkUI.settings.theme.background
            itemButton.TextColor3 = DarkUI.settings.theme.text
            itemButton.Text = option
            itemButton.TextSize = DarkUI.settings.textSize
            itemButton.Font = DarkUI.settings.font
            itemButton.TextXAlignment = Enum.TextXAlignment.Left
            
            local cornerItem = Instance.new("UICorner")
            cornerItem.CornerRadius = UDim.new(0, 4)
            cornerItem.Parent = itemButton
            
            itemButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                dropdownList.Visible = false
                dropdownIcon.Image = "rbxassetid://7072723420" -- Ícone de seta para baixo
                container.Size = UDim2.new(1, 0, 0, 60)
                if callback then callback(option) end
            end)
            
            itemButton.Parent = dropdownList
        end
    end
    
    if options then
        createDropdownItems()
    end
    
    -- Alternar dropdown
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        if dropdownList.Visible then
            dropdownIcon.Image = "rbxassetid://7072708252" -- Ícone de seta para cima
            container.Size = UDim2.new(1, 0, 0, 60 + math.min(150, #options * 32))
        else
            dropdownIcon.Image = "rbxassetid://7072723420" -- Ícone de seta para baixo
            container.Size = UDim2.new(1, 0, 0, 60)
        end
    end)
    
    dropdownButton.Parent = container
    dropdownList.Parent = container
    
    return {
        container = container,
        setOptions = function(self, newOptions)
            -- Limpar itens existentes
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Criar novos itens
            options = newOptions
            createDropdownItems()
            
            -- Resetar seleção
            dropdownButton.Text = options[1] or "Select"
            dropdownList.Visible = false
            dropdownIcon.Image = "rbxassetid://7072723420" -- Ícone de seta para baixo
            container.Size = UDim2.new(1, 0, 0, 60)
        end,
        setSelected = function(self, option)
            if table.find(options, option) then
                dropdownButton.Text = option
                if callback then callback(option) end
            end
        end
    }
end

-- Função para criar uma aba
function DarkUI.createTab(parent, name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.BackgroundColor3 = DarkUI.settings.theme.background
    tabButton.TextColor3 = DarkUI.settings.theme.text
    tabButton.Text = name
    tabButton.TextSize = DarkUI.settings.textSize
    tabButton.Font = DarkUI.settings.font
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = DarkUI.settings.theme.border
    stroke.Thickness = 1
    stroke.Parent = tabButton
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "TabContent"
    tabContent.Size = UDim2.new(1, 0, 1, -40)
    tabContent.Position = UDim2.new(0, 0, 0, 40)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 5
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, DarkUI.settings.elementPadding)
    contentLayout.Parent = tabContent
    
    tabButton.Parent = parent
    tabContent.Parent = parent
    
    return {
        button = tabButton,
        content = tabContent,
        name = name
    }
end

-- Função para criar o menu principal
function DarkUI.createMenu()
    -- Criar a tela de fundo do menu
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkUIMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Frame principal do menu
    local mainFrame = DarkUI.createFrame(screenGui, UDim2.new(0, 300, 0, 400), UDim2.new(0.5, -150, 0.5, -200), DarkUI.settings.theme.foreground, 0, "MainFrame")
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = DarkUI.settings.cornerRadius
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = DarkUI.settings.theme.border
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Barra de título
    local titleBar = DarkUI.createFrame(mainFrame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), DarkUI.settings.theme.background, 0, "TitleBar")
    local titleText = DarkUI.createText(titleBar, "Dark UI", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    
    -- Container de abas
    local tabsContainer = DarkUI.createFrame(mainFrame, UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 35), nil, 1, "TabsContainer")
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsListLayout.Padding = UDim.new(0, 5)
    tabsListLayout.Parent = tabsContainer
    
    -- Criar abas de exemplo
    local tabs = {}
    local tabContents = {}
    
    local function switchTab(tabName)
        for _, tab in ipairs(tabs) do
            tab.content.Visible = tab.name == tabName
            tab.button.BackgroundColor3 = tab.name == tabName and DarkUI.settings.theme.accent or DarkUI.settings.theme.background
        end
    end
    
    -- Aba 1
    local tab1 = DarkUI.createTab(mainFrame, "Aba 1")
    table.insert(tabs, tab1)
    
    -- Conteúdo da Aba 1
    local section1 = DarkUI.createFrame(tab1.content, UDim2.new(1, -10, 0, 150), UDim2.new(0, 5, 0, 5), DarkUI.settings.theme.background, 0, "Section1")
    local cornerSection = Instance.new("UICorner")
    cornerSection.CornerRadius = DarkUI.settings.cornerRadius
    cornerSection.Parent = section1
    
    local strokeSection = Instance.new("UIStroke")
    strokeSection.Color = DarkUI.settings.theme.border
    strokeSection.Thickness = 1
    strokeSection.Parent = section1
    
    -- Adicionar elementos à seção 1
    DarkUI.createText(section1, "Seção 1", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 5))
    
    local checkbox1 = DarkUI.createCheckbox(section1, "Checkbox 1", false, function(value)
        print("Checkbox 1:", value)
    end)
    
    local slider1 = DarkUI.createSlider(section1, "Slider", 0, 100, 50, function(value)
        print("Slider value:", value)
    end)
    
    -- Seção 2
    local section2 = DarkUI.createFrame(tab1.content, UDim2.new(1, -10, 0, 150), UDim2.new(0, 5, 0, 165), DarkUI.settings.theme.background, 0, "Section2")
    cornerSection:Clone().Parent = section2
    strokeSection:Clone().Parent = section2
    
    DarkUI.createText(section2, "Seção 2", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 5))
    
    local dropdown1 = DarkUI.createDropdown(section2, "Dropdown", {"Opção 1", "Opção 2", "Opção 3"}, "Opção 1", function(value)
        print("Dropdown selecionado:", value)
    end)
    
    -- Aba 2
    local tab2 = DarkUI.createTab(mainFrame, "Aba 2")
    table.insert(tabs, tab2)
    
    -- Conteúdo da Aba 2
    local section3 = DarkUI.createFrame(tab2.content, UDim2.new(1, -10, 0, 200), UDim2.new(0, 5, 0, 5), DarkUI.settings.theme.background, 0, "Section3")
    cornerSection:Clone().Parent = section3
    strokeSection:Clone().Parent = section3
    
    DarkUI.createText(section3, "Outros Elementos", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 5))
    
    local button1 = DarkUI.createButton(section3, "Botão 1", UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 30), function()
        print("Botão 1 pressionado")
    end)
    
    local button2 = DarkUI.createButton(section3, "Botão 2", UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 70), function()
        print("Botão 2 pressionado")
    end)
    
    -- Configurar eventos das abas
    for _, tab in ipairs(tabs) do
        tab.button.MouseButton1Click:Connect(function()
            switchTab(tab.name)
        end)
    end
    
    -- Ativar a primeira aba
    switchTab("Aba 1")
    
    -- Botões de controle
    local controlButtons = DarkUI.createFrame(screenGui, UDim2.new(0, 120, 0, 70), UDim2.new(0, 10, 0.5, -35), nil, 1, "ControlButtons")
    
    local showHideButton = DarkUI.createButton(controlButtons, "Hide", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), function()
        DarkUI.menuVisible = not DarkUI.menuVisible
        mainFrame.Visible = DarkUI.menuVisible
        showHideButton.Text = DarkUI.menuVisible and "Hide" or "Show"
    end, "ShowHideButton")
    
    local lockUnlockButton = DarkUI.createButton(controlButtons, "Unlocked", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 40), function()
        DarkUI.menuLocked = not DarkUI.menuLocked
        lockUnlockButton.Text = DarkUI.menuLocked and "Locked" or "Unlocked"
    end, "LockUnlockButton")
    
    -- Função para arrastar o menu
    local function startDrag(input)
        if DarkUI.menuLocked then return end
        DarkUI.dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        DarkUI.menuPosition = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                DarkUI.dragStartPos = nil
            end
        end)
    end
    
    local function updateDrag(input)
        if DarkUI.menuLocked or not DarkUI.dragStartPos then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - DarkUI.dragStartPos
        mainFrame.Position = UDim2.new(
            DarkUI.menuPosition.X.Scale, 
            DarkUI.menuPosition.X.Offset + delta.X,
            DarkUI.menuPosition.Y.Scale, 
            DarkUI.menuPosition.Y.Offset + delta.Y
        )
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)
    
    -- Adicionar ao jogo
    screenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        tabs = tabs,
        showHideButton = showHideButton,
        lockUnlockButton = lockUnlockButton
    }
end

-- Inicializar a UI
DarkUI.menu = DarkUI.createMenu()

return DarkUI
