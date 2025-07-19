--[[ 
    UI Library - Estrutura Quadrada com ScrollViews Duplos
    Autor: DH-SOARESE
    Compatível com: Executors como Delta (loadstring)
    GitHub: https://github.com/SEU-USUARIO/UI-LIBRARY
]]

local UILibrary = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createBorderedFrame(parent)
    -- Borda preta
    local outer = Instance.new("Frame", parent)
    outer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outer.BorderSizePixel = 0
    outer.Size = UDim2.new(0, 520, 0, 460)
    outer.Position = UDim2.new(0.5, -260, 0.5, -230)
    outer.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Borda azul interna
    local inner = Instance.new("Frame", outer)
    inner.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    inner.Position = UDim2.new(0, 2, 0, 2)
    inner.Size = UDim2.new(1, -4, 1, -4)
    inner.BorderSizePixel = 0

    -- Fundo escuro principal
    local main = Instance.new("Frame", inner)
    main.BackgroundColor3 = Color3.fromHex("#1C2526")
    main.Position = UDim2.new(0, 1, 0, 1)
    main.Size = UDim2.new(1, -2, 1, -2)
    main.BorderSizePixel = 0
    main.Name = "MainUI"

    return main
end

function UILibrary:CreateWindow(titleText)
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "CustomUILibrary"
    gui.ResetOnSpawn = false

    local mainUI = createBorderedFrame(gui)

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

    -- Área de Abas (Tabs)
    local tabScroll = Instance.new("ScrollingFrame", mainUI)
    tabScroll.Size = UDim2.new(1, 0, 0, 35)
    tabScroll.Position = UDim2.new(0, 0, 0, 35)
    tabScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabScroll.BorderSizePixel = 0
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 35)
    tabScroll.ScrollBarThickness = 4
    tabScroll.Name = "TabScroll"
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)

    local function createTab(name)
        local button = Instance.new("TextButton")
        button.Text = name
        button.Font = Enum.Font.SourceSansBold
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 18
        button.Size = UDim2.new(0, 100, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        return button
    end

    local tabs = {}

    function tabs:CreateTab(name)
        local tabBtn = createTab(name)
        tabBtn.Parent = tabScroll

        local container = Instance.new("Frame", mainUI)
        container.Position = UDim2.new(0, 0, 0, 70)
        container.Size = UDim2.new(1, 0, 1, -70)
        container.Visible = false
        container.Name = name
        container.BackgroundTransparency = 1

        -- Scroll Left
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

        -- Scroll Right
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

        tabBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(mainUI:GetChildren()) do
                if child:IsA("Frame") and child ~= tabScroll and child ~= title then
                    child.Visible = false
                end
            end
            container.Visible = true
        end)

        return {
            Left = scrollLeft,
            Right = scrollRight,
            Name = name
        }
    end

    return tabs
end

return UILibrary
