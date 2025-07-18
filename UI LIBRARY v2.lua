-- Library: DarkUITabbed
-- Description: A dark-themed UI library with horizontal tabs, ScrollView, and interactive elements
-- Optimized for mobile devices and executors like Delta
-- Version: 1.0
-- Author: [Your Name]

local DarkUITabbed = {}
DarkUITabbed.__index = DarkUITabbed

-- Dependencies (assuming a Roblox-like environment or executor with UI support)
local UserInputService = game:GetService("UserInputService") -- For touch and drag detection
local TweenService = game:GetService("TweenService") -- For smooth animations

-- Helper function to create UI instances
local function create(class, props)
    local instance = Instance.new(class)
    for k, v in pairs(props or {}) do
        instance[k] = v
    end
    return instance
end

-- Main UI Library Constructor
function DarkUITabbed.new()
    local self = setmetatable({}, DarkUITabbed)
    
    -- Main frame (draggable window)
    self.MainFrame = create("ScreenGui", {
        Name = "DarkUITabbed",
        Parent = game.Players.LocalPlayer.PlayerGui,
        ResetOnSpawn = false
    })
    
    self.Window = create("Frame", {
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30), -- Dark theme
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    -- Add subtle border
    create("UIStroke", {
        Color = Color3.fromRGB(50, 50, 50),
        Thickness = 1,
        Parent = self.Window
    })
    
    -- Dragging variables
    self.IsDragging = false
    self.IsLocked = false
    self.IsVisible = true
    
    -- Tab container (horizontal tabs)
    self.TabContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent = self.Window
    })
    
    -- ScrollView for content
    self.ScrollView = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
        CanvasSize = UDim2.new(0, 0, 2, 0), -- Will be updated dynamically
        Parent = self.Window
    })
    
    -- Layout for ScrollView content
    self.ScrollLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.ScrollView
    })
    
    -- Tabs storage
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Control buttons (Show/Hide and Locked/Unlocked)
    self.ControlFrame = create("Frame", {
        Size = UDim2.new(0, 100, 0, 120),
        Position = UDim2.new(0, 10, 0.5, -60),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })
    
    self.ShowHideButton = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 120, 255),
        BorderSizePixel = 2,
        Text = "Hide",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = self.ControlFrame
    })
    
    self.LockButton = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 120, 255),
        BorderSizePixel = 2,
        Text = "Locked",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = self.ControlFrame
    })
    
    -- Initialize drag functionality
    self:SetupDragging()
    self:SetupControlButtons()
    
    return self
end

-- Setup dragging for the window
function DarkUITabbed:SetupDragging()
    local dragStart, startPos
    self.Window.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not self.IsLocked then
            self.IsDragging = true
            dragStart = input.Position
            startPos = self.Window.Position
        end
    end)
    
    self.Window.InputChanged:Connect(function(input)
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.Window.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end)
end

-- Setup control buttons (Show/Hide and Locked/Unlocked)
function DarkUITabbed:SetupControlButtons()
    self.ShowHideButton.MouseButton1Click:Connect(function()
        self.IsVisible = not self.IsVisible
        self.Window.Visible = self.IsVisible
        self.ShowHideButton.Text = self.IsVisible and "Hide" or "Show"
    end)
    
    self.LockButton.MouseButton1Click:Connect(function()
        self.IsLocked = not self.IsLocked
        self.LockButton.Text = self.IsLocked and "Locked" or "Unlocked"
    end)
end

-- Create a new tab
function DarkUITabbed:AddTab(name)
    local tab = {}
    tab.Name = name
    tab.Button = create("TextButton", {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = self.TabContainer
    })
    
    -- Tab content frame
    tab.Content = create("Frame", {
        Size = UDim2.new(1, 0, 0, 600), -- Two layouts per tab
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.ScrollView
    })
    
    -- Layout for content
    tab.Layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = tab.Content
    })
    
    -- Add tab button to layout
    local tabLayout = self.TabContainer:FindFirstChild("UIListLayout") or create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.TabContainer
    })
    
    -- Switch tab on click
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    if not self.CurrentTab then
        self:SwitchTab(tab)
    end
    
    -- Update ScrollView canvas
    self:UpdateCanvasSize()
    return tab
end

-- Switch to a specific tab
function DarkUITabbed:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    self.CurrentTab = tab
    self.CurrentTab.Content.Visible = true
    self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end

-- Update ScrollView canvas size
function DarkUITabbed:UpdateCanvasSize()
    local totalHeight = 0
    for _, tab in pairs(self.Tabs) do
        if tab.Content.Visible then
            totalHeight = tab.Content.AbsoluteSize.Y
        end
    end
    self.ScrollView.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

-- Add a square (button-like element)
function DarkUITabbed:AddSquare(tab, label, callback)
    local square = create("TextButton", {
        Size = UDim2.new(0, 100, 0, 100),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = tab.Content
    })
    
    create("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        Parent = square
    })
    
    square.MouseButton1Click:Connect(callback or function() end)
end

-- Add a slider
function DarkUITabbed:AddSlider(tab, label, min, max, default, callback)
    local sliderFrame = create("Frame", {
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local labelText = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = sliderFrame
    })
    
    local slider = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Text = "",
        Parent = sliderFrame
    })
    
    local knob = create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(0, 120, 255),
        Position = UDim2.new((default - min) / (max - min), -10, 0, -5),
        Parent = slider
    })
    
    local value = default
    slider.MouseButton1Down:Connect(function()
        local mouseConn
        mouseConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * relativeX
                knob.Position = UDim2.new(relativeX, -10, 0, -5)
                if callback then
                    callback(value)
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mouseConn:Disconnect()
            end
        end)
    end)
end

-- Add a checkbox
function DarkUITabbed:AddCheckbox(tab, label, default, callback)
    local checkboxFrame = create("Frame", {
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local checkbox = create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = default and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50),
        Text = "",
        Parent = checkboxFrame
    })
    
    create("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        Parent = checkbox
    })
    
    local labelText = create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = checkboxFrame
    })
    
    local checked = default
    checkbox.MouseButton1Click:Connect(function()
        checked = not checked
        checkbox.BackgroundColor3 = checked and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50)
        if callback then
            callback(checked)
        end
    end)
end

-- Add a dropdown
function DarkUITabbed:AddDropdown(tab, label, options, default, callback)
    local dropdownFrame = create("Frame", {
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundTransparency = 1,
        Parent = tab.Content
    })
    
    local labelText = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = dropdownFrame
    })
    
    local dropdownButton = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = default or options[1],
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        Parent = dropdownFrame
    })
    
    create("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        Parent = dropdownButton
    })
    
    local dropdownList = create("Frame", {
        Size = UDim2.new(1, 0, 0, #options * 30),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Visible = false,
        Parent = dropdownFrame
    })
    
    create("UIStroke", {
        Color = Color3.fromRGB(70, 70, 70),
        Thickness = 1,
        Parent = dropdownList
    })
    
    local listLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownList
    })
    
    for i, option in ipairs(options) do
        local optionButton = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Text = option,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            Font = Enum.Font.Gotham,
            Parent = dropdownList
        })
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownList.Visible = false
            if callback then
                callback(option)
            end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
end

return DarkUITabbed
