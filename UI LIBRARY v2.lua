-- UI LIBRARY
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local dragging = false
local dragInput, dragStart, startPos
local currentTab = nil
local tabs = {}
local tabContent = {}

-- Criar GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SquareUILibrary"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.CoreGui

-- Janela principal
local main = Instance.new("Frame")
main.Name = "MainUI"
main.Size = UDim2.new(0, 480, 0, 370)
main.Position = UDim2.new(0.5, -240, 0.5, -185)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Parent = screenGui

-- Bordas
local white = Instance.new("UIStroke", main)
white.Color = Color3.new(1, 1, 1)
white.Thickness = 4

local black = Instance.new("UIStroke", main)
black.Color = Color3.new(0, 0, 0)
black.Thickness = 8
black.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Cabeçalho
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "📦 Square UI Library"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14

-- Área de abas
local tabHolder = Instance.new("Frame", main)
tabHolder.Size = UDim2.new(1, 0, 0, 30)
tabHolder.Position = UDim2.new(0, 0, 0, 32)
tabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local tabLayout = Instance.new("UIListLayout", tabHolder)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)

-- Conteúdo dinâmico por aba
local function switchTab(tabName)
	for name, content in pairs(tabContent) do
		content.Visible = name == tabName
	end
	currentTab = tabName
end

function Library:AddTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 80, 1, 0)
	tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	tabBtn.TextColor3 = Color3.new(1, 1, 1)
	tabBtn.Font = Enum.Font.Gotham
	tabBtn.TextSize = 12
	tabBtn.Text = name
	tabBtn.Parent = tabHolder

	local container = Instance.new("Frame", main)
	container.Position = UDim2.new(0, 0, 0, 62)
	container.Size = UDim2.new(1, 0, 1, -62)
	container.BackgroundTransparency = 1
	container.Visible = false

	local scrollLeft = Instance.new("ScrollingFrame", container)
	scrollLeft.Name = "LeftScroll"
	scrollLeft.Position = UDim2.new(0, 8, 0, 0)
	scrollLeft.Size = UDim2.new(0.5, -12, 1, 0)
	scrollLeft.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	scrollLeft.ScrollBarThickness = 6
	scrollLeft.BorderSizePixel = 0
	scrollLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollLeft.CanvasSize = UDim2.new(0, 0, 0, 0)

	local layoutLeft = Instance.new("UIGridLayout", scrollLeft)
	layoutLeft.CellSize = UDim2.new(0, 100, 0, 32)
	layoutLeft.CellPadding = UDim2.new(0, 6, 0, 6)

	local scrollRight = scrollLeft:Clone()
	scrollRight.Name = "RightScroll"
	scrollRight.Position = UDim2.new(0.5, 4, 0, 0)
	scrollRight.Parent = container

	tabBtn.MouseButton1Click:Connect(function()
		switchTab(name)
	end)

	tabs[name] = tabBtn
	tabContent[name] = container

	if not currentTab then
		switchTab(name)
	end
end

-- Adicionar recurso
function Library:AddFeature(tabName, side, name, callback)
	local tab = tabContent[tabName]
	if not tab then return warn("Tab '" .. tabName .. "' não existe!") end

	local scroll = side == "Left" and tab.LeftScroll or tab.RightScroll
	local btn = Instance.new("TextButton")
	btn.Text = name or "Recurso"
	btn.Size = UDim2.new(0, 100, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = scroll
	btn.MouseButton1Click:Connect(callback or function() end)
end

-- Botão: mostrar/ocultar
local toggleUI = Instance.new("TextButton", screenGui)
toggleUI.Size = UDim2.new(0, 70, 0, 28)
toggleUI.Position = UDim2.new(0, 8, 0.9, 0)
toggleUI.Text = "UI: ON"
toggleUI.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleUI.TextColor3 = Color3.new(1, 1, 1)
toggleUI.Font = Enum.Font.Gotham
toggleUI.TextSize = 13

toggleUI.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	toggleUI.Text = main.Visible and "UI: ON" or "UI: OFF"
end)

-- Botão: ativar/desativar arrasto
local toggleDrag = toggleUI:Clone()
toggleDrag.Text = "Drag: ON"
toggleDrag.Position = UDim2.new(0, 8, 0.9, 34)
toggleDrag.Parent = screenGui

local dragEnabled = true
toggleDrag.MouseButton1Click:Connect(function()
	dragEnabled = not dragEnabled
	toggleDrag.Text = dragEnabled and "Drag: ON" or "Drag: OFF"
end)

-- Drag via toque
header.InputBegan:Connect(function(input)
	if dragEnabled and input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

return Library