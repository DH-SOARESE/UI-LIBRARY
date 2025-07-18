-- UI LIBRARY
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

local dragging = false
local dragInput, dragStart, startPos

-- Criar GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SquareUILibrary"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.CoreGui

-- Janela principal
local main = Instance.new("Frame", screenGui)
main.Name = "MainUI"
main.Size = UDim2.new(0, 460, 0, 340)
main.Position = UDim2.new(0.5, -230, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Visible = true

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
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14

-- ScrollViews
local scrollLeft = Instance.new("ScrollingFrame", main)
scrollLeft.Position = UDim2.new(0, 8, 0, 40)
scrollLeft.Size = UDim2.new(0.5, -12, 1, -48)
scrollLeft.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
scrollLeft.ScrollBarThickness = 6
scrollLeft.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollLeft.CanvasSize = UDim2.new(0,0,0,0)
scrollLeft.BorderSizePixel = 0

local scrollRight = scrollLeft:Clone()
scrollRight.Position = UDim2.new(0.5, 4, 0, 40)
scrollRight.Parent = main

-- Layouts quadrados
local layoutLeft = Instance.new("UIGridLayout", scrollLeft)
layoutLeft.CellSize = UDim2.new(0, 100, 0, 32)
layoutLeft.CellPadding = UDim2.new(0, 6, 0, 6)

local layoutRight = layoutLeft:Clone()
layoutRight.Parent = scrollRight

-- TOGGLES

-- Botão: mostrar/ocultar
local toggleUI = Instance.new("TextButton", screenGui)
toggleUI.Size = UDim2.new(0, 70, 0, 28)
toggleUI.Position = UDim2.new(0, 8, 0.9, 0)
toggleUI.Text = "UI: ON"
toggleUI.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleUI.TextColor3 = Color3.new(1,1,1)
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

-- API: adicionar recurso
function Library:AddFeature(side, name, callback)
	local btn = Instance.new("TextButton")
	btn.Text = name or "Recurso"
	btn.Size = UDim2.new(0, 100, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = (side == "Left" and scrollLeft) or scrollRight

	btn.MouseButton1Click:Connect(callback or function() end)
end

return Library