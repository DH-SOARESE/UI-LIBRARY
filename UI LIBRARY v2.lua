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

-- Borda azul externa + branca interna + fundo escuro
local borderOuter = Instance.new("Frame", screenGui)
borderOuter.Size = UDim2.new(0, 500, 0, 400)
borderOuter.Position = UDim2.new(0.3, 0, 0.2, 0)
borderOuter.BackgroundColor3 = Color3.fromRGB(0, 85, 170)
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

-- Área de abas
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

-- Função de atualização de Canvas
local function updateCanvas(scroll)
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll.UIListLayout.AbsoluteContentSize.Y + 10)
end

-- ListLayouts
for _, scroll in pairs({leftScroll, rightScroll}) do
	local list = Instance.new("UIListLayout", scroll)
	list.Padding = UDim.new(0, 6)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scroll.UIListLayout = list

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		updateCanvas(scroll)
	end)
end

-- Feature Generator
function library:AddFeature(side, name, callback, type, options)
	local parent = (side == "Right" and rightScroll) or leftScroll

	local featureFrame = Instance.new("Frame")
	featureFrame.Size = UDim2.new(1, -10, 0, 40)
	featureFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	featureFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	featureFrame.BorderSizePixel = 1
	featureFrame.Name = name

	local label = Instance.new("TextLabel", featureFrame)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name

	if type == "checkbox" then
		local box = Instance.new("TextButton", featureFrame)
		box.Size = UDim2.new(0, 24, 0, 24)
		box.Position = UDim2.new(0, 6, 0.5, -12)
		box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		box.BorderColor3 = Color3.fromRGB(255, 255, 255)
		box.Text = ""
		box.AutoButtonColor = false

		local state = false
		box.MouseButton1Click:Connect(function()
			state = not state
			box.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
			callback(state)
		end)
	elseif type == "slider" then
		local button = Instance.new("TextButton", featureFrame)
		button.Size = UDim2.new(1, -20, 0, 30)
		button.Position = UDim2.new(0, 10, 0, 5)
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		button.BorderColor3 = Color3.fromRGB(100, 100, 100)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 14

		local min, max, value = options.Min or 0, options.Max or 10, options.Default or 5
		button.Text = name .. ": " .. value

		button.MouseButton1Click:Connect(function()
			value = value + 1
			if value > max then value = min end
			button.Text = name .. ": " .. value
			callback(value)
		end)
	else
		local btn = Instance.new("TextButton", featureFrame)
		btn.Size = UDim2.new(1, -20, 0, 30)
		btn.Position = UDim2.new(0, 10, 0, 5)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
		btn.Text = name
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 14
		btn.TextColor3 = Color3.new(1, 1, 1)

		btn.MouseButton1Click:Connect(function()
			callback(true)
		end)
	end

	featureFrame.Parent = parent
end

-- Dragging
local function makeDraggable(frame)
	local dragging, offset
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if dragEnabled then
				dragging = true
				offset = input.Position - frame.Position
			end
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			frame.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

makeDraggable(borderOuter)

-- Botões (Menu e Drag Toggle)
local function createSideButton(name, callback, order)
	local btn = Instance.new("TextButton", screenGui)
	btn.Size = UDim2.new(0, 140, 0, 36)
	btn.Position = UDim2.new(0, 10, 0.5, -60 + order * 40)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.BorderColor3 = Color3.fromRGB(0, 85, 170)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = name
	btn.MouseButton1Click:Connect(callback)
end

createSideButton("📂 Abrir/Fechar Menu", function()
	menuOpen = not menuOpen
	borderOuter.Visible = menuOpen
end, 0)

createSideButton("✋ Drag ON/OFF", function()
	dragEnabled = not dragEnabled
end, 1)

return library