local UILibrary = {}

local UserInputService = game:GetService("UserInputService")

function UILibrary:CreateWindow(titleText)
	local player = game:GetService("Players").LocalPlayer
	local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	gui.Name = "CustomUI"
	gui.ResetOnSpawn = false

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 500, 0, 400)
	main.Position = UDim2.new(0.5, -250, 0.5, -200)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.BorderSizePixel = 1
	main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	main.Active = true
	main.Draggable = true

	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(0, 120, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.4

	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = titleText or "Menu"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22

	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(1, 0, 0, 30)
	tabsHolder.Position = UDim2.new(0, 8, 0, 40) -- padding 8px para não encostar na borda
	tabsHolder.BackgroundTransparency = 1

	local tabLayout = Instance.new("UIListLayout", tabsHolder)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	local contentHolder = Instance.new("Frame", main)
	contentHolder.Position = UDim2.new(0, 0, 0, 70)
	contentHolder.Size = UDim2.new(1, 0, 1, -70)
	contentHolder.BackgroundTransparency = 1

	local tabs = {}

	-- Botões laterais (fora do menu)
	local buttonFrame = Instance.new("Frame", gui)
	buttonFrame.Size = UDim2.new(0, 100, 0, 100)
	buttonFrame.Position = UDim2.new(0, 10, 0.5, -50)
	buttonFrame.BackgroundTransparency = 1

	local function styleSideButton(btn)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = true
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16

		local uiStroke = Instance.new("UIStroke", btn)
		uiStroke.Color = Color3.fromRGB(0, 120, 255)
		uiStroke.Thickness = 1
		uiStroke.Transparency = 0.6

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		end)
	end

	local showBtn = Instance.new("TextButton", buttonFrame)
	showBtn.Size = UDim2.new(1, 0, 0.5, -2)
	showBtn.Position = UDim2.new(0, 0, 0, 0)
	showBtn.Text = "Hide"
	styleSideButton(showBtn)

	local lockBtn = Instance.new("TextButton", buttonFrame)
	lockBtn.Size = UDim2.new(1, 0, 0.5, -2)
	lockBtn.Position = UDim2.new(0, 0, 0.5, 2)
	lockBtn.Text = "Unlocked"
	styleSideButton(lockBtn)

	local visible = true
	showBtn.MouseButton1Click:Connect(function()
		visible = not visible
		main.Visible = visible
		showBtn.Text = visible and "Hide" or "Show"
	end)

	local locked = false
	lockBtn.MouseButton1Click:Connect(function()
		locked = not locked
		main.Active = not locked
		lockBtn.Text = locked and "Locked" or "Unlocked"
	end)

	-- Cria aba
	function UILibrary:CreateTab(name)
		local btn = Instance.new("TextButton", tabsHolder)
		btn.Size = UDim2.new(0, 100, 1, 0)
		btn.Text = name
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		btn.BorderSizePixel = 1
		btn.BorderColor3 = Color3.fromRGB(0, 120, 255)
		btn.AutoButtonColor = true
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 15

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		end)

		local tabContent = Instance.new("Frame", contentHolder)
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.Visible = false
		tabContent.BackgroundTransparency = 1

		local leftTitle = Instance.new("TextLabel", tabContent)
		leftTitle.Position = UDim2.new(0, 0, 0, 0)
		leftTitle.Size = UDim2.new(0.5, -5, 0, 20)
		leftTitle.Text = "Seção Esquerda"
		leftTitle.TextColor3 = Color3.new(1, 1, 1)
		leftTitle.BackgroundTransparency = 1
		leftTitle.Font = Enum.Font.GothamBold
		leftTitle.TextSize = 14

		local rightTitle = Instance.new("TextLabel", tabContent)
		rightTitle.Position = UDim2.new(0.5, 5, 0, 0)
		rightTitle.Size = UDim2.new(0.5, -5, 0, 20)
		rightTitle.Text = "Seção Direita"
		rightTitle.TextColor3 = Color3.new(1, 1, 1)
		rightTitle.BackgroundTransparency = 1
		rightTitle.Font = Enum.Font.GothamBold
		rightTitle.TextSize = 14

		local leftScroll = Instance.new("ScrollingFrame", tabContent)
		leftScroll.Position = UDim2.new(0, 0, 0, 20)
		leftScroll.Size = UDim2.new(0.5, -5, 1, -20)
		leftScroll.ScrollBarThickness = 5
		leftScroll.BackgroundTransparency = 1
		leftScroll.CanvasSize = UDim2.new(0, 0, 10, 0)
		leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local rightScroll = leftScroll:Clone()
		rightScroll.Parent = tabContent
		rightScroll.Position = UDim2.new(0.5, 5, 0, 20)

		local leftLayout = Instance.new("UIListLayout", leftScroll)
		leftLayout.Padding = UDim.new(0, 4)

		local rightLayout = Instance.new("UIListLayout", rightScroll)
		rightLayout.Padding = UDim.new(0, 4)

		btn.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do t.TabFrame.Visible = false end
			tabContent.Visible = true
		end)

		table.insert(tabs, {TabFrame = tabContent})

		local api = {}

		local function applyHoverEffects(button)
			button.MouseEnter:Connect(function()
				button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			end)
			button.MouseLeave:Connect(function()
				button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end)
		end

		function api:AddButton(text, callback, side)
			local parent = side == "Right" and rightScroll or leftScroll
			local btn = Instance.new("TextButton", parent)
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Text = text
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BorderSizePixel = 1
			btn.BorderColor3 = Color3.fromRGB(0, 120, 255)
			btn.AutoButtonColor = true
			applyHoverEffects(btn)
			btn.MouseButton1Click:Connect(callback)
		end

		function api:AddToggle(text, default, callback, side)
			local parent = side == "Right" and rightScroll or leftScroll
			local toggle = Instance.new("TextButton", parent)
			toggle.Size = UDim2.new(1, -10, 0, 30)
			toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			toggle.TextColor3 = Color3.new(1, 1, 1)
			toggle.BorderSizePixel = 1
			toggle.BorderColor3 = Color3.fromRGB(0, 120, 255)
			toggle.AutoButtonColor = true

			local state = default or false
			local function update() toggle.Text = text .. ": " .. (state and "ON" or "OFF") end
			update()

			applyHoverEffects(toggle)

			toggle.MouseButton1Click:Connect(function()
				state = not state
				update()
				callback(state)
			end)
		end

		function api:AddDropdown(text, options, callback, side)
			local parent = side == "Right" and rightScroll or leftScroll
			local dropdown = Instance.new("TextButton", parent)
			dropdown.Size = UDim2.new(1, -10, 0, 30)
			dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			dropdown.TextColor3 = Color3.new(1, 1, 1)
			dropdown.Text = text
			dropdown.BorderSizePixel = 1
			dropdown.BorderColor3 = Color3.fromRGB(0, 120, 255)
			dropdown.AutoButtonColor = true

			local open = false
			local opts = {}

			local function closeDropdown()
				for _, o in pairs(opts) do o:Destroy() end
				opts = {}
				open = false
			end

			dropdown.MouseButton1Click:Connect(function()
				if open then
					closeDropdown()
				else
					for _, val in ipairs(options) do
						local opt = Instance.new("TextButton", parent)
						opt.Size = UDim2.new(1, -10, 0, 25)
						opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
						opt.TextColor3 = Color3.new(1, 1, 1)
						opt.Text = "› " .. val
						opt.BorderSizePixel = 1
						opt.BorderColor3 = Color3.fromRGB(0, 120, 255)
						opt.AutoButtonColor = true
						opt.MouseButton1Click:Connect(function()
							dropdown.Text = text .. ": " .. val
							callback(val)
							closeDropdown()
						end)
					end
					open = true
				end
			end)
		end

		function api:AddDropdownToggle(text, callback, side)
			local parent = side == "Right" and rightScroll or leftScroll
			local dtoggle = Instance.new("TextButton", parent)
			dtoggle.Size = UDim2.new(1, -10, 0, 30)
			dtoggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			dtoggle.TextColor3 = Color3.new(1, 1, 1)
			dtoggle.Text = text .. ": OFF"
			dtoggle.BorderSizePixel = 1
			dtoggle.BorderColor3 = Color3.fromRGB(0, 120, 255)
			dtoggle.AutoButtonColor = true

			local state = false
			dtoggle.MouseButton1Click:Connect(function()
				state = not state
				dtoggle.Text = text .. ": " .. (state and "ON" or "OFF")
				callback(state)
			end)
		end

		function api:AddSlider(text, min, max, default, callback, side)
			local parent = side == "Right" and rightScroll or leftScroll
			local sliderHolder = Instance.new("Frame", parent)
			sliderHolder.Size = UDim2.new(1, -10, 0, 50)
			sliderHolder.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", sliderHolder)
			label.Size = UDim2.new(1, 0, 0.3, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.Text = text .. ": " .. tostring(default)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14

			local slider = Instance.new("Frame", sliderHolder)
			slider.Size = UDim2.new(1, 0, 0.4, 0)
			slider.Position = UDim2.new(0, 0, 0.6, 0)
			slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			slider.BorderSizePixel = 1
			slider.BorderColor3 = Color3.fromRGB(0, 120, 255)
			slider.ClipsDescendants = true

			local fill = Instance.new("Frame", slider)
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)

			local dragging = false

			local function updateSlider(inputPosX)
				local relativeX = math.clamp(inputPosX - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
				local percent = relativeX / slider.AbsoluteSize.X
				local value = math.floor(min + (max - min) * percent)
				fill.Size = UDim2.new(percent, 0, 1, 0)
				label.Text = text .. ": " .. value
				callback(value)
			end

			local function inputBegan(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateSlider(input.Position.X)
				end
			end

			local function inputChanged(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateSlider(input.Position.X)
				end
			end

			local function inputEnded(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end

			slider.InputBegan:Connect(inputBegan)
			slider.InputChanged:Connect(inputChanged)
			slider.InputEnded:Connect(inputEnded)

			return sliderHolder
		end

		return api
	end

	return UILibrary
end

return UILibrary
