local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local library = {}

local dragging = false
local menuOpen = true
local dragEnabled = true

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Name = "UILibrary"

-- Menu com borda azul e borda branca interna
local borderOuter = Instance.new("Frame", screenGui)
borderOuter.Size = UDim2.new(0, 500, 0, 400)
borderOuter.Position = UDim2.new(0.3, 0, 0.2, 0)
borderOuter.BackgroundColor3 = Color3.fromRGB(50, 120, 220) -- azul agradável
borderOuter.BorderSizePixel = 0
borderOuter.Name = "Menu"

local borderInner = Instance.new("Frame", borderOuter)
borderInner.Size = UDim2.new(1, -4, 1, -4)
borderInner.Position = UDim2.new(0, 2, 0, 2)
borderInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
borderInner.BorderSizePixel = 0

local container = Instance.new("Frame", borderInner)
container.Size = UDim2.new(1, -4, 1, -4)
container.Position = UDim2.new(0, 2, 0, 2)
container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
container.BorderSizePixel = 0
container.ClipsDescendants = true

-- Área de abas no topo
local tabArea = Instance.new("Frame", container)
tabArea.Size = UDim2.new(1, 0, 0, 40)
tabArea.Position = UDim2.new(0, 0, 0, 0)
tabArea.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabArea.BorderSizePixel = 0

-- ScrollViews lado a lado
local leftScroll = Instance.new("ScrollingFrame", container)
leftScroll.Size = UDim2.new(0.5, -2, 1, -45)
leftScroll.Position = UDim2.new(0, 2, 0, 42)
leftScroll.BackgroundTransparency = 1
leftScroll.BorderSizePixel = 0
leftScroll.ScrollBarThickness = 4
leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
leftScroll.Name = "Left"

local rightScroll = leftScroll:Clone()
rightScroll.Parent = container
rightScroll.Position = UDim2.new(0.5, 0, 0, 42)
rightScroll.Name = "Right"

-- UIListLayouts para espaçamento
for _, scroll in pairs({leftScroll, rightScroll}) do
	local list = Instance.new("UIListLayout", scroll)
	list.Padding = UDim.new(0, 12) -- espaçamento aumentado
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scroll.UIListLayout = list

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 15)
	end)
end

-- Função para criar botões laterais centralizados verticalmente à esquerda
local function createSideButton(text, callback, index)
	local btn = Instance.new("TextButton", screenGui)
	btn.Size = UDim2.new(0, 140, 0, 36)
	btn.Position = UDim2.new(0, 10, 0.5, (index - 1) * 50 - 25)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.BorderColor3 = Color3.fromRGB(50, 120, 220)
	btn.BorderSizePixel = 2
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.AutoButtonColor = true

	btn.MouseButton1Click:Connect(callback)

	return btn
end

local toggleMenuBtn = createSideButton("📂 Abrir/Fechar Menu", function()
	menuOpen = not menuOpen
	borderOuter.Visible = menuOpen
end, 1)

local toggleDragBtn = createSideButton("✋ Drag ON/OFF", function()
	dragEnabled = not dragEnabled
	toggleDragBtn.Text = dragEnabled and "✋ Drag ON" or "✋ Drag OFF"
end, 2)

-- Função para tornar o menu arrastável (via mouse ou toque)
local function makeDraggable(frame)
	local draggingInput, dragStartPos, startPos
	frame.InputBegan:Connect(function(input)
		if not dragEnabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input == draggingInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStartPos
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end
makeDraggable(borderOuter)

-- Função para criar features estilizados
function library:AddFeature(side, name, callback, ftype, options)
	local parent = (side == "Right" and rightScroll) or leftScroll

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 44)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.fromRGB(75, 110, 180)
	frame.Name = name
	frame.ClipsDescendants = true

	if ftype == "checkbox" then
		local box = Instance.new("TextButton", frame)
		box.Size = UDim2.new(0, 28, 0, 28)
		box.Position = UDim2.new(0, 6, 0.5, -14)
		box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		box.BorderSizePixel = 1
		box.BorderColor3 = Color3.fromRGB(120, 120, 120)
		box.AutoButtonColor = false
		box.Text = ""

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(1, -40, 1, 0)
		label.Position = UDim2.new(0, 40, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.Font = Enum.Font.SourceSansSemibold
		label.TextSize = 16
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local toggled = false
		box.MouseButton1Click:Connect(function()
			toggled = not toggled
			box.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
			callback(toggled)
		end)

	elseif ftype == "slider" then
		local sliderFrame = Instance.new("Frame", frame)
		sliderFrame.Size = UDim2.new(1, -20, 1, -10)
		sliderFrame.Position = UDim2.new(0, 10, 0, 5)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		sliderFrame.BorderSizePixel = 1
		sliderFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
		sliderFrame.ClipsDescendants = true

		local label = Instance.new("TextLabel", sliderFrame)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 16
		label.Text = name .. ": " .. tostring(options and options.Default or 0)
		label.TextXAlignment = Enum.TextXAlignment.Center

		-- Simples incremento ao clicar (exemplo)
		local minV = (options and options.Min) or 0
		local maxV = (options and options.Max) or 100
		local currentValue = (options and options.Default) or minV

		sliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				currentValue = currentValue + 1
				if currentValue > maxV then
					currentValue = minV
				end
				label.Text = name .. ": " .. currentValue
				callback(currentValue)
			end
		end)

	elseif ftype == "button" then
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1, -20, 1, -10)
		btn.Position = UDim2.new(0, 10, 0, 5)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		btn.BorderSizePixel = 1
		btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 16
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = name

		btn.MouseButton1Click:Connect(function()
			callback(true)
		end)
	end

	frame.Parent = parent
end

return library