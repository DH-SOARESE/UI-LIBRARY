local Library = {}

-- Configurações de cores e dimensões
local Colors = {
    Black = Color3.fromRGB(0, 0, 0),
    White = Color3.fromRGB(255, 255, 255),
    DarkBackground = Color3.fromRGB(20, 20, 20),
    FeatureBackground = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 120, 255) -- Cor para realçar elementos interativos
}

local Dimensions = {
    MenuWidth = 400,
    MenuHeight = 500,
    BorderThickness = 2,
    TabHeight = 40,
    FeaturePadding = 10,
    FeatureSize = 80, -- Tamanho de cada item de recurso (quadrado)
    ToggleSize = 30
}

-- Variáveis de estado
local MenuOpen = true
local MenuDraggable = true
local IsDragging = false
local DragStart = Vector2.new(0, 0)
local InitialPosition = Vector2.new(0, 0)

-- Função para criar um novo elemento de UI
local function CreateElement(class, parent)
    local element = Instance.new(class)
    element.Parent = parent
    return element
end

-- Função para otimizar o arrastamento para toque
local function SetupDraggable(element, menuFrame)
    local UserInputService = game:GetService("UserInputService")

    element.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if MenuDraggable and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            IsDragging = true
            DragStart = UserInputService:GetMouseLocation()
            InitialPosition = Vector2.new(menuFrame.Position.X.Offset, menuFrame.Position.Y.Offset)
        end
    end)

    element.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local currentMouseLocation = UserInputService:GetMouseLocation()
            local deltaX = currentMouseLocation.X - DragStart.X
            local deltaY = currentMouseLocation.Y - DragStart.Y

            menuFrame.Position = UDim2.new(0, InitialPosition.X + deltaX, 0, InitialPosition.Y + deltaY)
        end
    end)
end

-- Função principal para criar a UI da biblioteca
function Library:Create(name)
    local screenGui = CreateElement("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = name
    screenGui.DisplayOrder = 999 -- Garante que a UI esteja acima de outras

    local menuFrame = CreateElement("Frame", screenGui)
    menuFrame.Size = UDim2.new(0, Dimensions.MenuWidth, 0, Dimensions.MenuHeight)
    menuFrame.Position = UDim2.new(0.5, -Dimensions.MenuWidth / 2, 0.5, -Dimensions.MenuHeight / 2)
    menuFrame.BackgroundColor3 = Colors.Black
    menuFrame.BorderSizePixel = 0

    -- Borda interna branca
    local innerBorder = CreateElement("Frame", menuFrame)
    innerBorder.Size = UDim2.new(1, -Dimensions.BorderThickness * 2, 1, -Dimensions.BorderThickness * 2)
    innerBorder.Position = UDim2.new(0, Dimensions.BorderThickness, 0, Dimensions.BorderThickness)
    innerBorder.BackgroundColor3 = Colors.White
    innerBorder.BorderSizePixel = 0

    -- Fundo escuro da UI
    local background = CreateElement("Frame", innerBorder)
    background.Size = UDim2.new(1, -Dimensions.BorderThickness * 2, 1, -Dimensions.BorderThickness * 2)
    background.Position = UDim2.new(0, Dimensions.BorderThickness, 0, Dimensions.BorderThickness)
    background.BackgroundColor3 = Colors.DarkBackground
    background.BorderSizePixel = 0

    -- Área de abas
    local tabArea = CreateElement("Frame", background)
    tabArea.Size = UDim2.new(1, 0, 0, Dimensions.TabHeight)
    tabArea.Position = UDim2.new(0, 0, 0, 0)
    tabArea.BackgroundColor3 = Colors.FeatureBackground -- Cor de fundo das abas
    tabArea.BorderSizePixel = 0
    tabArea.ClipsDescendants = true

    local tabLayout = CreateElement("UIListLayout", tabArea)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0, 5)

    -- Container para os ScrollViews e recursos
    local contentArea = CreateElement("Frame", background)
    contentArea.Size = UDim2.new(1, 0, 1, -Dimensions.TabHeight)
    contentArea.Position = UDim2.new(0, 0, 0, Dimensions.TabHeight)
    contentArea.BackgroundColor3 = Colors.DarkBackground
    contentArea.BorderSizePixel = 0

    -- ScrollView vertical 1
    local scrollView1 = CreateElement("ScrollingFrame", contentArea)
    scrollView1.Size = UDim2.new(0.5, 0, 1, 0)
    scrollView1.Position = UDim2.new(0, 0, 0, 0)
    scrollView1.BackgroundColor3 = Colors.DarkBackground
    scrollView1.BorderSizePixel = 0
    scrollView1.ScrollBarThickness = 6
    scrollView1.ScrollBarImageColor3 = Colors.Accent
    scrollView1.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado dinamicamente
    scrollView1.VerticalScrollBarInset = Enum.ScrollBarInset.Always

    local layout1 = CreateElement("UIGridLayout", scrollView1)
    layout1.CellSize = UDim2.new(0, Dimensions.FeatureSize, 0, Dimensions.FeatureSize)
    layout1.CellPadding = UDim2.new(0, Dimensions.FeaturePadding, 0, Dimensions.FeaturePadding)
    layout1.StartCorner = Enum.StartCorner.TopLeft
    layout1.FillDirectionMaxCells = math.floor((Dimensions.MenuWidth / 2 - Dimensions.FeaturePadding * 2) / (Dimensions.FeatureSize + Dimensions.FeaturePadding))
    layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout1.VerticalAlignment = Enum.VerticalAlignment.Top

    -- ScrollView vertical 2
    local scrollView2 = CreateElement("ScrollingFrame", contentArea)
    scrollView2.Size = UDim2.new(0.5, 0, 1, 0)
    scrollView2.Position = UDim2.new(0.5, 0, 0, 0)
    scrollView2.BackgroundColor3 = Colors.DarkBackground
    scrollView2.BorderSizePixel = 0
    scrollView2.ScrollBarThickness = 6
    scrollView2.ScrollBarImageColor3 = Colors.Accent
    scrollView2.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado dinamicamente
    scrollView2.VerticalScrollBarInset = Enum.ScrollBarInset.Always

    local layout2 = CreateElement("UIGridLayout", scrollView2)
    layout2.CellSize = UDim2.new(0, Dimensions.FeatureSize, 0, Dimensions.FeatureSize)
    layout2.CellPadding = UDim2.new(0, Dimensions.FeaturePadding, 0, Dimensions.FeaturePadding)
    layout2.StartCorner = Enum.StartCorner.TopLeft
    layout2.FillDirectionMaxCells = math.floor((Dimensions.MenuWidth / 2 - Dimensions.FeaturePadding * 2) / (Dimensions.FeatureSize + Dimensions.FeaturePadding))
    layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout2.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Função para adicionar uma nova aba
    local function AddTab(tabName)
        local tabButton = CreateElement("TextButton", tabArea)
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Text = tabName
        tabButton.Font = Enum.Font.SourceSansBold
        tabButton.TextColor3 = Colors.White
        tabButton.TextSize = 18
        tabButton.BackgroundColor3 = Colors.FeatureBackground
        tabButton.BorderSizePixel = 0

        local function activateTab()
            for _, child in ipairs(tabArea:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Colors.FeatureBackground
                end
            end
            tabButton.BackgroundColor3 = Colors.Accent
            -- Lógica para trocar o conteúdo do ScrollView baseado na aba ativa (implementar depois)
        end

        tabButton.MouseButton1Click:Connect(activateTab)

        if #tabArea:GetChildren() == 2 then -- O primeiro child é UIListLayout
            activateTab() -- Ativa a primeira aba por padrão
        end

        return {
            -- Função para adicionar um recurso a esta aba
            AddFeature = function(featureName, callback, scrollViewIndex)
                local targetScrollView = (scrollViewIndex == 1 and scrollView1) or scrollView2
                local targetLayout = (scrollViewIndex == 1 and layout1) or layout2

                local featureButton = CreateElement("TextButton", targetScrollView)
                featureButton.Name = featureName
                featureButton.Size = UDim2.new(0, Dimensions.FeatureSize, 0, Dimensions.FeatureSize)
                featureButton.Text = featureName
                featureButton.Font = Enum.Font.SourceSansSemibold
                featureButton.TextColor3 = Colors.White
                featureButton.TextSize = 14
                featureButton.BackgroundColor3 = Colors.FeatureBackground
                featureButton.BorderSizePixel = 0
                featureButton.TextScaled = true -- Para ajustar o texto ao tamanho do botão

                -- Adiciona sombra/borda para melhor visual
                local uiStroke = CreateElement("UIStroke", featureButton)
                uiStroke.Color = Colors.Accent
                uiStroke.Thickness = 1
                uiStroke.LineJoinMode = Enum.LineJoinMode.Round

                featureButton.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)

                -- Ajusta o CanvasSize do ScrollView dinamicamente
                local contentHeight = targetLayout.AbsoluteContentSize.Y + targetLayout.CellPadding.Y.Offset
                targetScrollView.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
            end
        }
    end

    -- Toggle para abrir/fechar o menu
    local menuToggle = CreateElement("TextButton", screenGui)
    menuToggle.Size = UDim2.new(0, Dimensions.ToggleSize * 3, 0, Dimensions.ToggleSize)
    menuToggle.Position = UDim2.new(0, 10, 0, 10)
    menuToggle.Text = "Menu (ON)"
    menuToggle.Font = Enum.Font.SourceSansBold
    menuToggle.TextColor3 = Colors.White
    menuToggle.TextSize = 16
    menuToggle.BackgroundColor3 = Colors.Accent
    menuToggle.BorderSizePixel = 0

    menuToggle.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        menuFrame.Visible = MenuOpen
        menuToggle.Text = "Menu (" .. (MenuOpen and "ON" or "OFF") .. ")"
    end)

    -- Toggle para arrastar/bloquear o menu
    local draggableToggle = CreateElement("TextButton", screenGui)
    draggableToggle.Size = UDim2.new(0, Dimensions.ToggleSize * 3, 0, Dimensions.ToggleSize)
    draggableToggle.Position = UDim2.new(0, 10, 0, 10 + Dimensions.ToggleSize + 10) -- Abaixo do menuToggle
    draggableToggle.Text = "Arrastar (ON)"
    draggableToggle.Font = Enum.Font.SourceSansBold
    draggableToggle.TextColor3 = Colors.White
    draggableToggle.TextSize = 16
    draggableToggle.BackgroundColor3 = Colors.Accent
    draggableToggle.BorderSizePixel = 0

    draggableToggle.MouseButton1Click:Connect(function()
        MenuDraggable = not MenuDraggable
        draggableToggle.Text = "Arrastar (" .. (MenuDraggable and "ON" or "OFF") .. ")"
    end)

    -- Configura o arrastamento para o menuFrame (ou uma área específica do menu)
    -- Pode-se usar o tabArea ou o background como a área de arrastamento para evitar arrastar o menu inteiro clicando em features
    SetupDraggable(tabArea, menuFrame) -- A área de abas é uma boa escolha para arrastamento

    -- Retorna a interface para que os usuários possam adicionar abas e features
    return {
        AddTab = AddTab,
        ScreenGui = screenGui,
        MenuFrame = menuFrame
    }
end

return Library
