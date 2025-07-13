-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- GhostLibrary Definition
local GhostLibrary = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150),
		},
		-- You can add more themes here
	},
	SelectedTheme = "Default",
	ConfigFolder = nil, -- Renamed from 'Folder' for clarity
	SaveConfig = false, -- Renamed from 'SaveCfg' for clarity
	IsInitialized = false,
}

-- Feather Icons
local Icons = {}

local success, response = pcall(function()
	local iconJson = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json"))
	Icons = iconJson.icons
end)

if not success then
	warn(string.format("Ghost Library - Failed to load Feather Icons. Error: %s", response))
end

local function getIcon(iconName)
	return Icons[iconName]
end

-- Core GUI Setup
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "GhostLibraryUI" -- Renamed for clarity and uniqueness
MainGui.DisplayOrder = 999 -- Ensure it's on top

if syn then
	syn.protect_gui(MainGui)
	MainGui.Parent = game.CoreGui
elseif gethui then -- Fallback for other executors
	MainGui.Parent = gethui()
else
	MainGui.Parent = game.CoreGui
end

-- Clean up existing instances
for _, existingGui in ipairs((gethui and gethui() or game.CoreGui):GetChildren()) do
	if existingGui.Name == MainGui.Name and existingGui ~= MainGui then
		existingGui:Destroy()
	end
end

-- Utility Functions
function GhostLibrary:IsRunning()
	-- Check if the GUI is parented to a valid location
	return MainGui and MainGui.Parent and (MainGui.Parent == game.CoreGui or (gethui and MainGui.Parent == gethui()))
end

local function addConnection(signal, func)
	if not GhostLibrary:IsRunning() then
		return nil
	end
	local connection = signal:Connect(func)
	table.insert(GhostLibrary.Connections, connection)
	return connection
end

-- Automatic connection cleanup
task.spawn(function()
	while GhostLibrary:IsRunning() do
		task.wait(1) -- Periodically check if the GUI is still active
	end

	for _, connection in ipairs(GhostLibrary.Connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(GhostLibrary.Connections)
end)

local function addDraggingFunctionality(dragPoint, mainFrame)
	local isDragging = false
	local initialMousePos: Vector2
	local initialFramePos: UDim2
	local inputChangedConnection

	local function onInputBegan(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			initialMousePos = input.Position
			initialFramePos = mainFrame.Position

			-- Disconnect previous inputChangedConnection if it exists
			if inputChangedConnection then
				inputChangedConnection:Disconnect()
			end

			inputChangedConnection = addConnection(UserInputService.InputChanged, function(changedInput: InputObject)
				if isDragging and (changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch) then
					local delta = changedInput.Position - initialMousePos
					TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Position = UDim2.new(initialFramePos.X.Scale, initialFramePos.X.Offset + delta.X, initialFramePos.Y.Scale, initialFramePos.Y.Offset + delta.Y)
					}):Play()
				end
			end)

			-- Listen for InputEnded globally to ensure dragging stops
			addConnection(UserInputService.InputEnded, function(endedInput: InputObject)
				if endedInput == input then
					isDragging = false
					if inputChangedConnection then
						inputChangedConnection:Disconnect()
						inputChangedConnection = nil
					end
				end
			end)
		end
	end

	addConnection(dragPoint.InputBegan, onInputBegan)
end

local function createInstance(className: string, properties: table, children: table)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	for _, child in pairs(children or {}) do
		child.Parent = instance
	end
	return instance
end

local function createElement(elementName: string, elementFunction: (...any) -> GuiObject)
	GhostLibrary.Elements[elementName] = elementFunction
end

local function makeElement(elementName: string, ...)
	local elementFunc = GhostLibrary.Elements[elementName]
	if elementFunc then
		return elementFunc(...)
	else
		warn(string.format("GhostLibrary: Element '%s' not found.", elementName))
		return nil
	end
end

local function setProperties(element: Instance, properties: table)
	for prop, value in pairs(properties or {}) do
		element[prop] = value
	end
	return element
end

local function setChildren(element: Instance, children: table)
	for _, child in pairs(children or {}) do
		child.Parent = element
	end
	return element
end

local function round(num: number, factor: number)
	return math.floor(num / factor + (math.sign(num) * 0.5)) * factor
end

local function getPropertyToTheme(object: Instance)
	if object:IsA("Frame") or object:IsA("TextButton") or object:IsA("TextBox") then -- Added TextBox here
		return "BackgroundColor3"
	elseif object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif object:IsA("UIStroke") then
		return "Color"
	elseif object:IsA("TextLabel") or object:IsA("TextBox") then
		return "TextColor3"
	elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
		return "ImageColor3"
	end
	return nil
end

local function addThemeObject(object: Instance, themeKey: string)
	if not GhostLibrary.ThemeObjects[themeKey] then
		GhostLibrary.ThemeObjects[themeKey] = {}
	end
	table.insert(GhostLibrary.ThemeObjects[themeKey], object)

	local prop = getPropertyToTheme(object)
	if prop then
		object[prop] = GhostLibrary.Themes[GhostLibrary.SelectedTheme][themeKey]
	else
		warn(string.format("GhostLibrary: Could not find themeable property for object of type '%s'.", object.ClassName))
	end
	return object
end

local function setTheme()
	for themeKey, objects in pairs(GhostLibrary.ThemeObjects) do
		for _, object in pairs(objects) do
			local prop = getPropertyToTheme(object)
			if prop and GhostLibrary.Themes[GhostLibrary.SelectedTheme][themeKey] then
				object[prop] = GhostLibrary.Themes[GhostLibrary.SelectedTheme][themeKey]
			end
		end
	end
end

local function packColor(color: Color3)
	return { R = color.R * 255, G = color.G * 255, B = color.B * 255 }
end

local function unpackColor(packedColor: { R: number, G: number, B: number })
	return Color3.fromRGB(packedColor.R, packedColor.G, packedColor.B)
end

local function loadConfig(configString: string)
	local data = HttpService:JSONDecode(configString)
	for key, value in pairs(data) do
		if GhostLibrary.Flags[key] then
			task.spawn(function()
				if GhostLibrary.Flags[key].Type == "Colorpicker" then
					GhostLibrary.Flags[key]:Set(unpackColor(value))
				else
					GhostLibrary.Flags[key]:Set(value)
				end
			end)
		else
			warn(string.format("Ghost Library Config Loader - Could not find flag '%s'.", key))
		end
	end
end

local function saveConfig(name: string)
	local data = {}
	for key, flag in pairs(GhostLibrary.Flags) do
		if flag.Save then
			if flag.Type == "Colorpicker" then
				data[key] = packColor(flag.Value)
			else
				data[key] = flag.Value
			end
		end
	end
	local savePath = GhostLibrary.ConfigFolder .. "/" .. name .. ".txt"
	pcall(writefile, savePath, HttpService:JSONEncode(data))
end

local WHITELISTED_INPUT_TYPES = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3, Enum.UserInputType.Touch }
local BLACKLISTED_KEYS = { Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape }

local function isKeyInTable(tbl: table, key: any)
	for _, v in ipairs(tbl) do
		if v == key then
			return true
		end
	end
	return false
}

-- Element Creators
createElement("Corner", function(scale: number, offset: number)
	return createInstance("UICorner", {
		CornerRadius = UDim.new(scale or 0, offset or 10)
	})
end)

createElement("Stroke", function(color: Color3, thickness: number)
	return createInstance("UIStroke", {
		Color = color or Color3.fromRGB(255, 255, 255),
		Thickness = thickness or 1
	})
end)

createElement("List", function(scale: number, offset: number)
	return createInstance("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(scale or 0, offset or 0)
	})
end)

createElement("Padding", function(bottom: number, left: number, right: number, top: number)
	return createInstance("UIPadding", {
		PaddingBottom = UDim.new(0, bottom or 4),
		PaddingLeft = UDim.new(0, left or 4),
		PaddingRight = UDim.new(0, right or 4),
		PaddingTop = UDim.new(0, top or 4)
	})
end)

createElement("TransparentFrame", function()
	return createInstance("Frame", { BackgroundTransparency = 1 })
end)

createElement("Frame", function(color: Color3)
	return createInstance("Frame", {
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)

createElement("RoundFrame", function(color: Color3, scale: number, offset: number)
	return createInstance("Frame", {
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		makeElement("Corner", scale, offset)
	})
end)

createElement("Button", function()
	return createInstance("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)

createElement("ScrollFrame", function(color: Color3, width: number)
	return createInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = color,
		BorderSizePixel = 0,
		ScrollBarThickness = width,
		CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
	})
end)

createElement("Image", function(imageID: string)
	local image = createInstance("ImageLabel", {
		Image = imageID,
		BackgroundTransparency = 1
	})

	local icon = getIcon(imageID)
	if icon then
		image.Image = icon
	end
	return image
end)

createElement("ImageButton", function(imageID: string)
	return createInstance("ImageButton", {
		Image = imageID,
		BackgroundTransparency = 1
	})
end)

createElement("Label", function(text: string, textSize: number, transparency: number)
	return createInstance("TextLabel", {
		Text = text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = transparency or 0,
		TextSize = textSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

-- Notification System
local NotificationHolder = setProperties(setChildren(makeElement("TransparentFrame"), {
	setProperties(makeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = MainGui
})

function GhostLibrary:MakeNotification(config: table)
	task.spawn(function()
		config.Name = config.Name or "Notification"
		config.Content = config.Content or "Test Notification"
		config.Image = config.Image or "rbxassetid://4384403532" -- Default Roblox info icon
		config.Time = config.Time or 5 -- Reduced default time

		local notificationParent = setProperties(makeElement("TransparentFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local notificationFrame = setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Main, 0, 10), {
			Parent = notificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0), -- Starts off-screen
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			addThemeObject(makeElement("Stroke", GhostLibrary.Themes.Default.Stroke, 1.2), "Stroke"),
			makeElement("Padding", 12, 12, 12, 12),
			setProperties(makeElement("Image", config.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = GhostLibrary.Themes.Default.Text,
				Name = "Icon"
			}),
			setProperties(makeElement("Label", config.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			setProperties(makeElement("Label", config.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = GhostLibrary.Themes.Default.TextDark,
				TextWrapped = true
			})
		})

		-- Animate in
		TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()

		task.wait(config.Time - 1.5) -- Wait almost the full duration before starting fade
		
		-- Animate out
		local fadeDuration = 0.8
		TweenService:Create(notificationFrame.Icon, TweenInfo.new(fadeDuration * 0.5, Enum.EasingStyle.Quint), { ImageTransparency = 1 }):Play()
		TweenService:Create(notificationFrame, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.9 }):Play()
		task.wait(fadeDuration * 0.3)
		TweenService:Create(notificationFrame.UIStroke, TweenInfo.new(fadeDuration * 0.7, Enum.EasingStyle.Quint), { Transparency = 1 }):Play()
		TweenService:Create(notificationFrame.Title, TweenInfo.new(fadeDuration * 0.7, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		TweenService:Create(notificationFrame.Content, TweenInfo.new(fadeDuration * 0.7, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()

		notificationFrame:TweenPosition(UDim2.new(1, 55, 0, 0), 'Out', 'Quint', 0.8, true, function()
			notificationFrame:Destroy()
		end)
	end)
end

function GhostLibrary:Init()
	if GhostLibrary.IsInitialized then
		warn("GhostLibrary is already initialized.")
		return
	end

	GhostLibrary.IsInitialized = true

	if GhostLibrary.SaveConfig then
		local configFileName = LocalPlayer.Name .. "_" .. game.GameId .. ".json" -- More specific config name
		local fullPath = GhostLibrary.ConfigFolder .. "/" .. configFileName

		pcall(function()
			if isfile(fullPath) then
				loadConfig(readfile(fullPath))
				GhostLibrary:MakeNotification({
					Name = "Configuration Loaded",
					Content = string.format("Loaded configuration for this game from '%s'.", configFileName),
					Time = 5
				})
			else
				-- Optional: Make notification if no config is found initially
				-- GhostLibrary:MakeNotification({
				-- 	Name = "No Config Found",
				-- 	Content = "No saved configuration found for this game.",
				-- 	Time = 3
				-- })
			end
		end)
	end

	-- Initial theme application
	setTheme()
end

function GhostLibrary:MakeWindow(windowConfig: table)
	windowConfig = windowConfig or {}
	windowConfig.Name = windowConfig.Name or "Ghost Library"
	windowConfig.ConfigFolder = windowConfig.ConfigFolder or "GhostLibraryConfigs" -- Default config folder name
	windowConfig.SaveConfig = windowConfig.SaveConfig or false
	windowConfig.HidePremium = windowConfig.HidePremium or false
	windowConfig.IntroEnabled = windowConfig.IntroEnabled ~= false -- Default to true if nil
	windowConfig.IntroText = windowConfig.IntroText or "Ghost Library"
	windowConfig.CloseCallback = windowConfig.CloseCallback or function() end
	windowConfig.ShowIcon = windowConfig.ShowIcon or false
	windowConfig.Icon = windowConfig.Icon or "rbxassetid://8834748103"
	windowConfig.IntroIcon = windowConfig.IntroIcon or "rbxassetid://8834748103"

	GhostLibrary.ConfigFolder = windowConfig.ConfigFolder
	GhostLibrary.SaveConfig = windowConfig.SaveConfig

	if GhostLibrary.SaveConfig and not isfolder(GhostLibrary.ConfigFolder) then
		makefolder(GhostLibrary.ConfigFolder)
	end

	local currentTab: Instance = nil -- Keep track of the currently active tab container

	local tabHolder = addThemeObject(setChildren(setProperties(makeElement("ScrollFrame", GhostLibrary.Themes.Default.Divider, 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		makeElement("List"),
		makeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	addConnection(tabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		tabHolder.CanvasSize = UDim2.new(0, 0, 0, tabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local closeBtn = setChildren(setProperties(makeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		addThemeObject(setProperties(makeElement("Image", "rbxassetid://7072725342"), { -- Close icon
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local minimizeBtn = setChildren(setProperties(makeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		addThemeObject(setProperties(makeElement("Image", "rbxassetid://7072719338"), { -- Minimize icon
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local dragPoint = setProperties(makeElement("TransparentFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local windowStuff = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		addThemeObject(setProperties(makeElement("Frame"), { -- Top accent frame
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"),
		addThemeObject(setProperties(makeElement("Frame"), { -- Right accent frame
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"),
		addThemeObject(setProperties(makeElement("Frame"), { -- Right stroke
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"),
		tabHolder,
		setChildren(setProperties(makeElement("TransparentFrame"), { -- Player info section
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			addThemeObject(setProperties(makeElement("Frame"), { Size = UDim2.new(1, 0, 0, 1) }), "Stroke"), -- Top divider
			addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Divider, 0, 1), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				setProperties(makeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				addThemeObject(setProperties(makeElement("Image", "rbxassetid://4031889928"), { -- Overlay for profile picture (optional)
					Size = UDim2.new(1, 0, 1, 0),
				}), "Second"),
				makeElement("Corner", 1)
			}), "Divider"),
			addThemeObject(setProperties(makeElement("Label", LocalPlayer.DisplayName, windowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = windowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			addThemeObject(setProperties(makeElement("Label", LocalPlayer.Name, 12), { -- Username label
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not windowConfig.HidePremium
			}), "TextDark")
		})
	}), "Second")

	local windowName = addThemeObject(setProperties(makeElement("Label", windowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local windowTopBarLine = addThemeObject(setProperties(makeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local mainWindow = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Main, 0, 10), {
		Parent = MainGui,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		setChildren(setProperties(makeElement("TransparentFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			windowName,
			windowTopBarLine,
			addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				addThemeObject(makeElement("Stroke"), "Stroke"),
				addThemeObject(setProperties(makeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"),
				closeBtn,
				minimizeBtn
			}), "Second"),
		}),
		dragPoint,
		windowStuff
	}), "Main")

	if windowConfig.ShowIcon then
		windowName.Position = UDim2.new(0, 50, 0, -24)
		local windowIcon = setProperties(makeElement("Image", windowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		windowIcon.Parent = mainWindow.TopBar
	end

	addDraggingFunctionality(dragPoint, mainWindow)

	local isMinimized = false
	local isUIHidden = false

	addConnection(closeBtn.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mainWindow.Visible = false
			isUIHidden = true
			GhostLibrary:MakeNotification({
				Name = "Interface Hidden",
				Content = "Press RightShift to reopen the interface.",
				Time = 5
			})
			windowConfig.CloseCallback()
		end
	end)

	addConnection(UserInputService.InputBegan, function(input)
		if input.KeyCode == Enum.KeyCode.RightShift and isUIHidden then
			mainWindow.Visible = true
			isUIHidden = false
		end
	end)

	addConnection(minimizeBtn.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isMinimized then
				TweenService:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 615, 0, 344) }):Play()
				minimizeBtn.Ico.Image = "rbxassetid://7072719338"
				task.wait(0.02)
				mainWindow.ClipsDescendants = true -- Re-enable clipping after resizing up
				windowStuff.Visible = true
				windowTopBarLine.Visible = true
			else
				mainWindow.ClipsDescendants = false -- Disable clipping while minimizing
				windowTopBarLine.Visible = false
				minimizeBtn.Ico.Image = "rbxassetid://7072720870"

				TweenService:Create(mainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, windowName.TextBounds.X + 140, 0, 50) }):Play()
				task.wait(0.1)
				windowStuff.Visible = false
			end
			isMinimized = not isMinimized
		end
	end)

	local function loadSequence()
		mainWindow.Visible = false
		local loadSequenceLogo = setProperties(makeElement("Image", windowConfig.IntroIcon), {
			Parent = MainGui,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local loadSequenceText = setProperties(makeElement("Label", windowConfig.IntroText, 14), {
			Parent = MainGui,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})

		TweenService:Create(loadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
		task.wait(0.8)
		TweenService:Create(loadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -(loadSequenceText.TextBounds.X / 2), 0.5, 0) }):Play()
		task.wait(0.3)
		TweenService:Create(loadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		task.wait(2)
		TweenService:Create(loadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 }):Play()
		mainWindow.Visible = true
		loadSequenceLogo:Destroy()
		loadSequenceText:Destroy()
	end

	if windowConfig.IntroEnabled then
		loadSequence()
	end

	local tabFunctions = {}
	function tabFunctions:MakeTab(tabConfig: table)
		tabConfig = tabConfig or {}
		tabConfig.Name = tabConfig.Name or "New Tab"
		tabConfig.Icon = tabConfig.Icon or ""
		tabConfig.PremiumOnly = tabConfig.PremiumOnly or false

		local tabFrame = setChildren(setProperties(makeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = tabHolder
		}), {
			addThemeObject(setProperties(makeElement("Image", tabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Icon"
			}), "Text"),
			addThemeObject(setProperties(makeElement("Label", tabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		local icon = getIcon(tabConfig.Icon)
		if icon then
			tabFrame.Icon.Image = icon
		end

		local container = addThemeObject(setChildren(setProperties(makeElement("ScrollFrame", GhostLibrary.Themes.Default.Divider, 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = mainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			makeElement("List", 0, 6),
			makeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		addConnection(container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			container.CanvasSize = UDim2.new(0, 0, 0, container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if not currentTab then -- Set first tab as active
			currentTab = container
			tabFrame.Icon.ImageTransparency = 0
			tabFrame.Title.TextTransparency = 0
			tabFrame.Title.Font = Enum.Font.GothamBlack
			container.Visible = true
		end

		addConnection(tabFrame.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				-- Deactivate previous tab
				if currentTab then
					local prevTabButton = tabHolder:FindFirstChild(currentTab.Name) -- Assuming tab name matches button name
					if prevTabButton and prevTabButton:IsA("TextButton") then
						prevTabButton.Title.Font = Enum.Font.GothamSemibold
						TweenService:Create(prevTabButton.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { ImageTransparency = 0.4 }):Play()
						TweenService:Create(prevTabButton.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0.4 }):Play()
					end
					currentTab.Visible = false
				end

				-- Activate new tab
				currentTab = container
				TweenService:Create(tabFrame.Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
				TweenService:Create(tabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
				tabFrame.Title.Font = Enum.Font.GothamBlack
				container.Visible = true
			end
		end)

		local function getElements(itemParent: Instance)
			local elementFunctions = {}

			function elementFunctions:AddLabel(text: string)
				local labelFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(makeElement("Stroke"), "Stroke")
				}), "Second")

				local labelControl = {
					Set = function(toChange: string)
						labelFrame.Content.Text = toChange
					end
				}
				return labelControl
			end

			function elementFunctions:AddParagraph(titleText: string, contentText: string)
				titleText = titleText or "Title"
				contentText = contentText or "Content goes here."

				local paragraphFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", titleText, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					addThemeObject(setProperties(makeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextColor3 = GhostLibrary.Themes.Default.TextDark,
						TextWrapped = true,
						AutomaticSize = Enum.AutomaticSize.Y
					}), "TextDark"),
					addThemeObject(makeElement("Stroke"), "Stroke")
				}), "Second")

				-- Update size when content changes
				addConnection(paragraphFrame.Content:GetPropertyChangedSignal("TextBounds"), function()
					paragraphFrame.Content.Size = UDim2.new(1, -24, 0, paragraphFrame.Content.TextBounds.Y)
					paragraphFrame.Size = UDim2.new(1, 0, 0, paragraphFrame.Content.TextBounds.Y + 35)
				end)

				paragraphFrame.Content.Text = contentText

				local paragraphControl = {
					Set = function(newContent: string)
						paragraphFrame.Content.Text = newContent
					end
				}
				return paragraphControl
			end

			function elementFunctions:AddButton(buttonConfig: table)
				buttonConfig = buttonConfig or {}
				buttonConfig.Name = buttonConfig.Name or "Button"
				buttonConfig.Callback = buttonConfig.Callback or function() end
				buttonConfig.Icon = buttonConfig.Icon or "rbxassetid://3944703587" -- Default checkmark icon

				local clickButton = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local buttonFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", buttonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(setProperties(makeElement("Image", buttonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					addThemeObject(makeElement("Stroke"), "Stroke"),
					clickButton
				}), "Second")

				local buttonControl = {
					Set = function(buttonText: string)
						buttonFrame.Content.Text = buttonText
					end
				}

				addConnection(clickButton.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.1) }):Play()
					end
				end)

				addConnection(clickButton.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
						task.spawn(buttonConfig.Callback)
					end
				end)

				addConnection(clickButton.MouseEnter, function()
					TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
				end)

				addConnection(clickButton.MouseLeave, function()
					TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second }):Play()
				end)

				return buttonControl
			end

			function elementFunctions:AddToggle(toggleConfig: table)
				toggleConfig = toggleConfig or {}
				toggleConfig.Name = toggleConfig.Name or "Toggle"
				toggleConfig.Default = toggleConfig.Default or false
				toggleConfig.Callback = toggleConfig.Callback or function() end
				toggleConfig.Color = toggleConfig.Color or Color3.fromRGB(9, 99, 195)
				toggleConfig.Flag = toggleConfig.Flag or nil
				toggleConfig.Save = toggleConfig.Save or false

				local toggleControl = {
					Value = toggleConfig.Default,
					Save = toggleConfig.Save,
					Type = "Toggle"
				}

				local clickHandler = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local toggleBox = setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Divider, 0, 4), { -- Default off color
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					setProperties(makeElement("Stroke"), {
						Color = GhostLibrary.Themes.Default.Stroke, -- Default stroke color
						Name = "Stroke",
						Transparency = 0.5
					}),
					setProperties(makeElement("Image", "rbxassetid://3944680095"), { -- Checkmark icon
						Size = UDim2.new(0, 8, 0, 8), -- Starts small/hidden
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						ImageTransparency = 1, -- Starts transparent
						Name = "Icon"
					}),
				})

				local toggleFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", toggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(makeElement("Stroke"), "Stroke"),
					toggleBox,
					clickHandler
				}), "Second")

				function toggleControl:Set(value: boolean)
					toggleControl.Value = value
					TweenService:Create(toggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = value and toggleConfig.Color or GhostLibrary.Themes.Default.Divider }):Play()
					TweenService:Create(toggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Color = value and toggleConfig.Color or GhostLibrary.Themes.Default.Stroke }):Play()
					TweenService:Create(toggleBox.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { ImageTransparency = value and 0 or 1, Size = value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8) }):Play()
					toggleConfig.Callback(toggleControl.Value)
				end

				toggleControl:Set(toggleControl.Value) -- Set initial state

				addConnection(clickHandler.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(toggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.1) }):Play()
					end
				end)

				addConnection(clickHandler.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(toggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
						toggleControl:Set(not toggleControl.Value)
						if toggleConfig.Save then
							saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
						end
					end
				end)

				addConnection(clickHandler.MouseEnter, function()
					TweenService:Create(toggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
				end)

				addConnection(clickHandler.MouseLeave, function()
					TweenService:Create(toggleFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second }):Play()
				end)

				if toggleConfig.Flag then
					GhostLibrary.Flags[toggleConfig.Flag] = toggleControl
				end
				return toggleControl
			end

			function elementFunctions:AddSlider(sliderConfig: table)
				sliderConfig = sliderConfig or {}
				sliderConfig.Name = sliderConfig.Name or "Slider"
				sliderConfig.Min = sliderConfig.Min or 0
				sliderConfig.Max = sliderConfig.Max or 100
				sliderConfig.Increment = sliderConfig.Increment or 1
				sliderConfig.Default = sliderConfig.Default or 50
				sliderConfig.Callback = sliderConfig.Callback or function() end
				sliderConfig.ValueName = sliderConfig.ValueName or ""
				sliderConfig.Color = sliderConfig.Color or Color3.fromRGB(9, 149, 98)
				sliderConfig.Flag = sliderConfig.Flag or nil
				sliderConfig.Save = sliderConfig.Save or false

				local sliderControl = {
					Value = sliderConfig.Default,
					Save = sliderConfig.Save,
					Type = "Slider"
				}
				local isDragging = false
				local currentInputObject: InputObject = nil

				local sliderDragBar = setChildren(setProperties(makeElement("RoundFrame", sliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					addThemeObject(setProperties(makeElement("Label", "value", 13), { -- Value label inside drag bar
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local sliderBar = setChildren(setProperties(makeElement("RoundFrame", sliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					setProperties(makeElement("Stroke"), {
						Color = sliderConfig.Color
					}),
					addThemeObject(setProperties(makeElement("Label", "value", 13), { -- Value label for the whole bar (background)
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					sliderDragBar
				})

				local sliderFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", sliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(makeElement("Stroke"), "Stroke"),
					sliderBar
				}), "Second")

				addConnection(sliderBar.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						isDragging = true
						currentInputObject = input
						-- Immediately update on click
						local sizeScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
						sliderControl:Set(sliderConfig.Min + ((sliderConfig.Max - sliderConfig.Min) * sizeScale))
					end
				end)

				addConnection(UserInputService.InputEnded, function(input)
					if input == currentInputObject and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
						isDragging = false
						currentInputObject = nil
						if sliderConfig.Save then
							saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
						end
					end
				end)

				addConnection(UserInputService.InputChanged, function(input)
					if isDragging and input == currentInputObject and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						local sizeScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
						sliderControl:Set(sliderConfig.Min + ((sliderConfig.Max - sliderConfig.Min) * sizeScale))
					end
				end)

				function sliderControl:Set(value: number)
					local clampedValue = math.clamp(round(value, sliderConfig.Increment), sliderConfig.Min, sliderConfig.Max)
					self.Value = clampedValue
					TweenService:Create(sliderDragBar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale((self.Value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 1) }):Play()
					sliderBar.Value.Text = string.format("%g%s", self.Value, sliderConfig.ValueName) -- Use %g for cleaner number formatting
					sliderDragBar.Value.Text = string.format("%g%s", self.Value, sliderConfig.ValueName)
					sliderConfig.Callback(self.Value)
				end

				sliderControl:Set(sliderControl.Value) -- Set initial value
				if sliderConfig.Flag then
					GhostLibrary.Flags[sliderConfig.Flag] = sliderControl
				end
				return sliderControl
			end

			function elementFunctions:AddDropdown(dropdownConfig: table)
				dropdownConfig = dropdownConfig or {}
				dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
				dropdownConfig.Options = dropdownConfig.Options or {}
				dropdownConfig.Default = dropdownConfig.Default or (dropdownConfig.Options[1] or "...") -- Fallback to first option or "..."
				dropdownConfig.Callback = dropdownConfig.Callback or function() end
				dropdownConfig.Flag = dropdownConfig.Flag or nil
				dropdownConfig.Save = dropdownConfig.Save or false

				local dropdownControl = {
					Value = dropdownConfig.Default,
					Options = {}, -- Will be populated by Refresh
					Buttons = {},
					Toggled = false,
					Type = "Dropdown",
					Save = dropdownConfig.Save
				}
				local maxElementsDisplayed = 5 -- Maximum number of options visible without scrolling

				local dropdownListLayout = makeElement("List")

				local dropdownContainer = addThemeObject(setProperties(setChildren(makeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					dropdownListLayout
				}), {
					Parent = itemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 0, 0), -- Starts collapsed
					ClipsDescendants = true,
					Visible = false -- Hidden until toggled
				}), "Divider")

				local toggleClickArea = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local dropdownFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = itemParent,
					ClipsDescendants = true -- Crucial for dropdown collapsing effect
				}), {
					setProperties(setChildren(makeElement("TransparentFrame"), {
						addThemeObject(setProperties(makeElement("Label", dropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						addThemeObject(setProperties(makeElement("Image", "rbxassetid://7072706796"), { -- Down arrow icon
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = GhostLibrary.Themes.Default.TextDark,
							Name = "Icon"
						}), "TextDark"),
						addThemeObject(setProperties(makeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						addThemeObject(setProperties(makeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
						toggleClickArea
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "Header"
					}),
					dropdownContainer,
					addThemeObject(makeElement("Stroke"), "Stroke"),
					makeElement("Corner")
				}), "Second")

				addConnection(dropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y)
				end)

				local function addOptionsToContainer(options: table)
					for _, optionValue in ipairs(options) do
						local optionButton = addThemeObject(setProperties(setChildren(makeElement("Button", Color3.fromRGB(40, 40, 40)), {
							makeElement("Corner", 0, 6),
							addThemeObject(setProperties(makeElement("Label", optionValue, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = dropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")

						addConnection(optionButton.InputEnded, function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								dropdownControl:Set(optionValue)
								if dropdownConfig.Save then
									saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
								end
								-- Auto-close after selection
								dropdownControl.Toggled = false
								dropdownFrame.Header.Line.Visible = false
								TweenService:Create(dropdownFrame.Header.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
								TweenService:Create(dropdownFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 38) }):Play()
								dropdownContainer.Visible = false
							end
						end)

						dropdownControl.Buttons[optionValue] = optionButton
					end
				end

				function dropdownControl:Refresh(newOptions: table, clearExisting: boolean)
					if clearExisting then
						for _, button in pairs(dropdownControl.Buttons) do
							button:Destroy()
						end
						table.clear(dropdownControl.Options)
						table.clear(dropdownControl.Buttons)
					end
					dropdownControl.Options = newOptions
					addOptionsToContainer(dropdownControl.Options)
				end

				function dropdownControl:Set(value: any)
					if not table.find(dropdownControl.Options, value) then
						warn(string.format("GhostLibrary: Dropdown option '%s' not found for '%s'. Setting to default '...' or first option.", value, dropdownConfig.Name))
						value = "..." -- Or dropdownConfig.Options[1] if you prefer
					end

					dropdownControl.Value = value
					dropdownFrame.Header.Selected.Text = tostring(dropdownControl.Value)

					for _, button in pairs(dropdownControl.Buttons) do
						TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
						TweenService:Create(button.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.4 }):Play()
					end

					if dropdownControl.Buttons[value] then
						TweenService:Create(dropdownControl.Buttons[value], TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
						TweenService:Create(dropdownControl.Buttons[value].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
					end

					dropdownConfig.Callback(dropdownControl.Value)
				end

				addConnection(toggleClickArea.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dropdownControl.Toggled = not dropdownControl.Toggled
						dropdownFrame.Header.Line.Visible = dropdownControl.Toggled
						TweenService:Create(dropdownFrame.Header.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Rotation = dropdownControl.Toggled and 180 or 0 }):Play()

						local targetHeight = 38
						if dropdownControl.Toggled then
							dropdownContainer.Visible = true
							local contentHeight = dropdownListLayout.AbsoluteContentSize.Y
							local calculatedHeight = math.min(contentHeight, maxElementsDisplayed * 28) -- 28 is height of each option
							targetHeight = 38 + calculatedHeight
						end

						TweenService:Create(dropdownFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) }):Play()

						if not dropdownControl.Toggled then
							-- Delay hiding of the container until after the tween
							task.delay(0.15, function()
								if not dropdownControl.Toggled then -- Double check if it's still untoggled
									dropdownContainer.Visible = false
								end
							end)
						end
					end
				end)

				dropdownControl:Refresh(dropdownConfig.Options, false)
				dropdownControl:Set(dropdownControl.Value)

				if dropdownConfig.Flag then
					GhostLibrary.Flags[dropdownConfig.Flag] = dropdownControl
				end
				return dropdownControl
			end

			function elementFunctions:AddBind(bindConfig: table)
				bindConfig = bindConfig or {}
				bindConfig.Name = bindConfig.Name or "Bind"
				bindConfig.Default = bindConfig.Default or Enum.KeyCode.Unknown
				bindConfig.Hold = bindConfig.Hold or false
				bindConfig.Callback = bindConfig.Callback or function() end
				bindConfig.Flag = bindConfig.Flag or nil
				bindConfig.Save = bindConfig.Save or false

				local bindControl = {
					Value = bindConfig.Default,
					IsBinding = false, -- Renamed from 'Binding' for clarity
					IsHolding = false, -- Renamed from 'Holding'
					Type = "Bind",
					Save = bindConfig.Save
				}

				local clickArea = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local bindBox = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Main, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					addThemeObject(makeElement("Stroke"), "Stroke"),
					addThemeObject(setProperties(makeElement("Label", bindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local bindFrame = addThemeObject(setChildren(setProperties(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = itemParent
				}), {
					addThemeObject(setProperties(makeElement("Label", bindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(makeElement("Stroke"), "Stroke"),
					bindBox,
					clickArea
				}), "Second")

				addConnection(bindBox.Value:GetPropertyChangedSignal("Text"), function()
					TweenService:Create(bindBox, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, bindBox.Value.TextBounds.X + 16, 0, 24) }):Play()
				end)

				addConnection(clickArea.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						if bindControl.IsBinding then return end -- Prevent re-entry if already binding
						bindControl.IsBinding = true
						bindBox.Value.Text = "..." -- Indicate waiting for input
						-- Optionally, add a timeout to cancel binding if no input is received
						task.delay(5, function()
							if bindControl.IsBinding then
								bindControl.IsBinding = false
								bindControl:Set(bindControl.Value) -- Revert to current bind
								GhostLibrary:MakeNotification({
									Name = "Bind Timeout",
									Content = string.format("Bind for '%s' timed out. No key pressed.", bindConfig.Name),
									Time = 3
								})
							end
						end)
					end
				end)

				addConnection(UserInputService.InputBegan, function(input)
					if UserInputService:GetFocusedTextBox() then return end

					if bindControl.IsBinding then
						local key = nil
						if input.UserInputType == Enum.UserInputType.Keyboard then
							if not isKeyInTable(BLACKLISTED_KEYS, input.KeyCode) then
								key = input.KeyCode
							end
						elseif isKeyInTable(WHITELISTED_INPUT_TYPES, input.UserInputType) then
							key = input.UserInputType
						end

						if key then
							bindControl:Set(key)
							if bindConfig.Save then
								saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
							end
							bindControl.IsBinding = false
						end
					else
						-- Handle normal bind activation
						local activated = false
						if typeof(bindControl.Value) == "EnumItem" then
							if bindControl.Value.EnumType == Enum.EnumType.KeyCode and input.KeyCode == bindControl.Value then
								activated = true
							elseif bindControl.Value.EnumType == Enum.EnumType.UserInputType and input.UserInputType == bindControl.Value then
								activated = true
							end
						end

						if activated then
							if bindConfig.Hold then
								if not bindControl.IsHolding then
									bindControl.IsHolding = true
									bindConfig.Callback(true) -- Pass true for hold
								end
							else
								bindConfig.Callback() -- Immediate trigger for non-hold
							end
						end
					end
				end)

				addConnection(UserInputService.InputEnded, function(input)
					-- Handle release for hold binds
					local released = false
					if typeof(bindControl.Value) == "EnumItem" then
						if bindControl.Value.EnumType == Enum.EnumType.KeyCode and input.KeyCode == bindControl.Value then
							released = true
						elseif bindControl.Value.EnumType == Enum.EnumType.UserInputType and input.UserInputType == bindControl.Value then
							released = true
						end
					end

					if released and bindConfig.Hold and bindControl.IsHolding then
						bindControl.IsHolding = false
						bindConfig.Callback(false) -- Pass false for release
					end
				end)

				-- Hover effects
				addConnection(clickArea.MouseEnter, function()
					TweenService:Create(bindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
				end)

				addConnection(clickArea.MouseLeave, function()
					TweenService:Create(bindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second }):Play()
				end)

				addConnection(clickArea.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(bindFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.1) }):Play()
					end
				end)

				function bindControl:Set(key: EnumItem)
					self.Value = key
					if typeof(self.Value) == "EnumItem" then
						bindBox.Value.Text = self.Value.Name:gsub("Key", ""):gsub("Button", "") -- Clean up enum names
					else
						bindBox.Value.Text = tostring(self.Value)
					end
				end

				bindControl:Set(bindConfig.Default)
				if bindConfig.Flag then
					GhostLibrary.Flags[bindConfig.Flag] = bindControl
				end
				return bindControl
			end

			function elementFunctions:AddTextbox(textboxConfig: table)
				textboxConfig = textboxConfig or {}
				textboxConfig.Name = textboxConfig.Name or "Textbox"
				textboxConfig.Default = textboxConfig.Default or ""
				textboxConfig.TextDisappear = textboxConfig.TextDisappear or false
				textboxConfig.Callback = textboxConfig.Callback or function() end
				textboxConfig.Flag = textboxConfig.Flag or nil -- Added Flag support
				textboxConfig.Save = textboxConfig.Save or false -- Added Save support

				local textboxControl = {
					Value = textboxConfig.Default,
					Save = textboxConfig.Save,
					Type = "Textbox"
				}

				local clickArea = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local textboxActual = addThemeObject(createInstance("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = GhostLibrary.Themes.Default.Text,
					PlaceholderColor3 = GhostLibrary.Themes.Default.TextDark:Lerp(Color3.fromRGB(255, 255, 255), 0.5), -- Lighter placeholder
					PlaceholderText = "Enter Text...",
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), "Text")

				local textContainer = addThemeObject(setChildren(makeElement("RoundFrame", GhostLibrary.Themes.Default.Main, 0, 4), {
					addThemeObject(makeElement("Stroke"), "Stroke"),
					textboxActual
				}), "Main")
				textContainer.Size = UDim2.new(0, 100, 0, 24) -- Default size
				textContainer.Position = UDim2.new(1, -12, 0.5, 0)
				textContainer.AnchorPoint = Vector2.new(1, 0.5)


				local textboxFrame = addThemeObject(setChildren(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					addThemeObject(setProperties(makeElement("Label", textboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					addThemeObject(makeElement("Stroke"), "Stroke"),
					textContainer,
					clickArea
				}), "Second")
				textboxFrame.Size = UDim2.new(1, 0, 0, 38)
				textboxFrame.Parent = itemParent

				addConnection(textboxActual:GetPropertyChangedSignal("Text"), function()
					textboxControl.Value = textboxActual.Text
					TweenService:Create(textContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, math.max(60, textboxActual.TextBounds.X + 16), 0, 24) }):Play() -- Min width
				end)

				addConnection(textboxActual.FocusLost, function(enterPressed)
					if enterPressed then
						textboxConfig.Callback(textboxActual.Text)
						if textboxConfig.Save then
							saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
						end
						if textboxConfig.TextDisappear then
							textboxActual.Text = ""
						end
					end
				end)

				textboxActual.Text = textboxConfig.Default
				textboxControl.Value = textboxConfig.Default

				function textboxControl:Set(value: string)
					textboxActual.Text = value
					textboxControl.Value = value
					-- Trigger property changed for immediate visual update
					textboxActual:GetPropertyChangedSignal("Text"):Fire()
				end

				-- Hover effects
				addConnection(clickArea.MouseEnter, function()
					TweenService:Create(textboxFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
				end)

				addConnection(clickArea.MouseLeave, function()
					TweenService:Create(textboxFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second }):Play()
				end)

				addConnection(clickArea.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(textboxFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.05) }):Play()
						textboxActual:CaptureFocus()
					end
				end)

				addConnection(clickArea.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(textboxFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = GhostLibrary.Themes.Default.Second:Lerp(Color3.fromRGB(255, 255, 255), 0.1) }):Play()
					end
				end)

				if textboxConfig.Flag then
					GhostLibrary.Flags[textboxConfig.Flag] = textboxControl
				end
				return textboxControl
			end

			function elementFunctions:AddColorpicker(colorpickerConfig: table)
				colorpickerConfig = colorpickerConfig or {}
				colorpickerConfig.Name = colorpickerConfig.Name or "Colorpicker"
				colorpickerConfig.Default = colorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				colorpickerConfig.Callback = colorpickerConfig.Callback or function() end
				colorpickerConfig.Flag = colorpickerConfig.Flag or nil
				colorpickerConfig.Save = colorpickerConfig.Save or false

				local hue, saturation, value = 1, 1, 1 -- HSV values

				local colorpickerControl = {
					Value = colorpickerConfig.Default,
					Toggled = false,
					Type = "Colorpicker",
					Save = colorpickerConfig.Save
				}

				local colorSelectionMarker = createInstance("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000" -- Circle marker
				})

				local hueSelectionMarker = createInstance("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000" -- Circle marker
				})

				local colorArea = createInstance("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252" -- Saturation/Value gradient
				}, {
					createInstance("UICorner", { CornerRadius = UDim.new(0, 5) }),
					colorSelectionMarker
				})

				local hueArea = createInstance("Frame", {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					createInstance("UIGradient", {
						Rotation = 270,
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
							ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
							ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
							ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
							ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
						},
					}),
					createInstance("UICorner", { CornerRadius = UDim.new(0, 5) }),
					hueSelectionMarker
				})

				local colorpickerContainer = createInstance("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					hueArea,
					colorArea,
					createInstance("UIPadding", {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				})

				local toggleClickArea = setProperties(makeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local colorDisplayBox = addThemeObject(setChildren(makeElement("RoundFrame", GhostLibrary.Themes.Default.Main, 0, 4), {
					addThemeObject(makeElement("Stroke"), "Stroke")
				}), "Main")
				colorDisplayBox.Size = UDim2.new(0, 24, 0, 24)
				colorDisplayBox.Position = UDim2.new(1, -12, 0.5, 0)
				colorDisplayBox.AnchorPoint = Vector2.new(1, 0.5)


				local colorpickerFrame = addThemeObject(setChildren(makeElement("RoundFrame", GhostLibrary.Themes.Default.Second, 0, 5), {
					setProperties(setChildren(makeElement("TransparentFrame"), {
						addThemeObject(setProperties(makeElement("Label", colorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						colorDisplayBox,
						toggleClickArea,
						addThemeObject(setProperties(makeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "Header"
					}),
					colorpickerContainer,
					addThemeObject(makeElement("Stroke"), "Stroke"),
				}), "Second")
				colorpickerFrame.Size = UDim2.new(1, 0, 0, 38)
				colorpickerFrame.Parent = itemParent


				addConnection(toggleClickArea.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						colorpickerControl.Toggled = not colorpickerControl.Toggled
						local targetSize = colorpickerControl.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)
						TweenService:Create(colorpickerFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = targetSize }):Play()
						colorArea.Visible = colorpickerControl.Toggled
						hueArea.Visible = colorpickerControl.Toggled
						colorpickerFrame.Header.Line.Visible = colorpickerControl.Toggled
					end
				end)

				local currentHueInputConnection: RBXScriptConnection = nil
				local currentSaturationValueInputConnection: RBXScriptConnection = nil

				local function updateColorpicker(position: Vector2, targetFrame: Instance)
					local relativePos = position - targetFrame.AbsolutePosition
					local clampedX = math.clamp(relativePos.X, 0, targetFrame.AbsoluteSize.X)
					local clampedY = math.clamp(relativePos.Y, 0, targetFrame.AbsoluteSize.Y)

					if targetFrame == colorArea then
						colorSelectionMarker.Position = UDim2.new(clampedX / targetFrame.AbsoluteSize.X, 0, clampedY / targetFrame.AbsoluteSize.Y, 0)
						saturation = clampedX / targetFrame.AbsoluteSize.X
						value = 1 - (clampedY / targetFrame.AbsoluteSize.Y)
					elseif targetFrame == hueArea then
						hueSelectionMarker.Position = UDim2.new(0.5, 0, clampedY / targetFrame.AbsoluteSize.Y, 0)
						hue = 1 - (clampedY / targetFrame.AbsoluteSize.Y)
					end

					local currentColor = Color3.fromHSV(hue, saturation, value)
					colorDisplayBox.BackgroundColor3 = currentColor
					colorArea.ImageColor3 = Color3.fromHSV(hue, 1, 1) -- Update base color of saturation area
					colorpickerControl:Set(currentColor) -- Update the control's value and call callback
					if colorpickerConfig.Save then
						saveConfig(LocalPlayer.Name .. "_" .. game.GameId)
					end
				end

				local function startDraggingColor(inputObject: InputObject, targetFrame: Instance)
					if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
						-- Disconnect previous connections if any
						if currentHueInputConnection then currentHueInputConnection:Disconnect() end
						if currentSaturationValueInputConnection then currentSaturationValueInputConnection:Disconnect() end

						local inputChangedFunc = function(input: InputObject)
							if input == inputObject then
								updateColorpicker(input.Position, targetFrame)
							end
						end

						local inputEndedFunc = function(input: InputObject)
							if input == inputObject then
								if currentHueInputConnection then currentHueInputConnection:Disconnect() end
								if currentSaturationValueInputConnection then currentSaturationValueInputConnection:Disconnect() end
								currentHueInputConnection = nil
								currentSaturationValueInputConnection = nil
							end
						end

						if targetFrame == colorArea then
							currentSaturationValueInputConnection = addConnection(UserInputService.InputChanged, inputChangedFunc)
							addConnection(UserInputService.InputEnded, inputEndedFunc)
						elseif targetFrame == hueArea then
							currentHueInputConnection = addConnection(UserInputService.InputChanged, inputChangedFunc)
							addConnection(UserInputService.InputEnded, inputEndedFunc)
						end

						-- Initial update on click
						updateColorpicker(inputObject.Position, targetFrame)
					end
				end

				addConnection(colorArea.InputBegan, function(input)
					startDraggingColor(input, colorArea)
				end)

				addConnection(hueArea.InputBegan, function(input)
					startDraggingColor(input, hueArea)
				end)

				function colorpickerControl:Set(color: Color3)
					self.Value = color
					hue, saturation, value = Color3.toHSV(self.Value)

					colorDisplayBox.BackgroundColor3 = self.Value
					colorArea.ImageColor3 = Color3.fromHSV(hue, 1, 1)

					colorSelectionMarker.Position = UDim2.new(saturation, 0, 1 - value, 0)
					hueSelectionMarker.Position = UDim2.new(0.5, 0, 1 - hue, 0)

					colorpickerConfig.Callback(self.Value)
				end

				colorpickerControl:Set(colorpickerConfig.Default) -- Set initial color and update UI
				if colorpickerConfig.Flag then
					GhostLibrary.Flags[colorpickerConfig.Flag] = colorpickerControl
				end
				return colorpickerControl
			end

			return elementFunctions
		end

		local elementFunctions = {}

		function elementFunctions:AddSection(sectionConfig: table)
			sectionConfig.Name = sectionConfig.Name or "Section"

			local sectionHolderFrame = setChildren(makeElement("TransparentFrame"), {
				addThemeObject(setProperties(makeElement("Label", sectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				setChildren(setProperties(makeElement("TransparentFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					makeElement("List", 0, 6)
				}),
			})
			sectionHolderFrame.Parent = container

			addConnection(sectionHolderFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				sectionHolderFrame.Size = UDim2.new(1, 0, 0, sectionHolderFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				sectionHolderFrame.Holder.Size = UDim2.new(1, 0, 0, sectionHolderFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local sectionControl = {}
			for i, v in pairs(getElements(sectionHolderFrame.Holder)) do
				sectionControl[i] = v
			end
			return sectionControl
		end

		for i, v in pairs(getElements(container)) do
			elementFunctions[i] = v
		end

		if tabConfig.PremiumOnly then
			-- Overwrite functions to do nothing or warn if premium
			for i, _ in pairs(elementFunctions) do
				elementFunctions[i] = function(...)
					warn(string.format("GhostLibrary: '%s' feature is for premium users only on tab '%s'.", i, tabConfig.Name))
					-- Optionally return a dummy control
					return {}
				end
			end
			-- Clear layout and padding for premium message
			if container:FindFirstChild("UIListLayout") then
				container:FindFirstChild("UIListLayout"):Destroy()
			end
			if container:FindFirstChild("UIPadding") then
				container:FindFirstChild("UIPadding"):Destroy()
			end

			setChildren(setProperties(makeElement("TransparentFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = container -- Change to parent to the tab's container
			}), {
				addThemeObject(setProperties(makeElement("Image", "rbxassetid://3610239960"), { -- Lock icon
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				addThemeObject(setProperties(makeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				addThemeObject(setProperties(makeElement("Image", "rbxassetid://4483345875"), { -- Premium/Star icon
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				addThemeObject(setProperties(makeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				addThemeObject(setProperties(makeElement("Label", "This section requires premium access. Check the Discord server for details!", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return elementFunctions
	end

	GhostLibrary:MakeNotification({
		Name = "Ghost Library Loaded",
		Content = "The Ghost Library UI has been successfully initialized!",
		Time = 5
	})

	GhostLibrary:Init() -- Call init after the window is created

	return tabFunctions
end

function GhostLibrary:Destroy()
	MainGui:Destroy()
	table.clear(GhostLibrary.Connections)
	table.clear(GhostLibrary.Elements)
	table.clear(GhostLibrary.ThemeObjects)
	table.clear(GhostLibrary.Flags)
	GhostLibrary.IsInitialized = false
	print("Ghost Library Destroyed.")
end

return GhostLibrary

