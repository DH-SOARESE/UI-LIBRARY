--[[
    MSHUB-Style UI Library for Roblox DOORS
    Author: DH-SOARESE
    Description:
        A modern, mobile-friendly Lua UI library inspired by MSHUB for Roblox DOORS.
        Features a square, clean aesthetic with robust customization and responsive controls.
        https://github.com/your-github-repo (replace with your repo link)
]]

local MSHUB = {}
MSHUB.__index = MSHUB

-- ROBLOX SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer

-- THEME DEFAULTS
local DEFAULT_THEME = {
    Background = Color3.fromRGB(25, 25, 35),
    Border = Color3.fromRGB(50, 50, 65),
    Accent = Color3.fromRGB(120, 200, 255),
    Text = Color3.fromRGB(230, 230, 240),
    Font = Enum.Font.Gotham,
}

local THEMES = {
    ["Dark"] = DEFAULT_THEME,
    ["Light"] = {
        Background = Color3.fromRGB(235, 235, 245),
        Border = Color3.fromRGB(200, 200, 215),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(25, 25, 35),
        Font = Enum.Font.Gotham,
    },
    -- Add more custom themes as needed
}

-- UTILITIES
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if type(k) == "number" then
            v.Parent = obj
        else
            obj[k] = v
        end
    end
    return obj
end

local function deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = deepCopy(v)
    end
    return copy
end

-- MAIN UI CONSTRUCTOR
function MSHUB.new(config)
    config = config or {}
    local self = setmetatable({}, MSHUB)
    self.Theme = deepCopy(THEMES[config.Theme or "Dark"])
    self.ThemeName = config.Theme or "Dark"
    self.Font = self.Theme.Font
    self.Title = config.Title or "MSHUB UI"
    self.Tabs = {}
    self.Open = false
    self.Dragging = false
    self.Locked = true
    self.Mobile = UserInputService.TouchEnabled
    self.LastSettings = {}

    self:_buildUI()
    self:_buildMenuToggle()
    self:_buildLockToggle()
    self:_buildConfigTab()

    -- Show menu on startup if desired
    self:setOpen(true)

    -- Automatically show the first non-config tab if exists
    RunService.RenderStepped:Wait()
    for _, t in ipairs(self.Tabs) do
        if not t.IsConfig then
            self:ShowTab(t)
            break
        end
    end

    return self
end

-- UI BUILDER METHODS
function MSHUB:_buildUI()
    -- Main container (ScreenGui)
    self.ScreenGui = create("ScreenGui", {
        Name = "MSHUB_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Top-level Frame (Menu)
    self.Menu = create("Frame", {
        Name = "Menu",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 2,
        Visible = false,
    })

    -- Menu Title
    self.TitleLabel = create("TextLabel", {
        Parent = self.Menu,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        Font = self.Theme.Font,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 0),
    })

    -- Tab Bar (ScrollingFrame for horizontal scroll)
    self.TabBar = create("ScrollingFrame", {
        Parent = self.Menu,
        Name = "TabBar",
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    self.TabsList = create("UIListLayout", {
        Parent = self.TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    -- Body (Frame for tab content, with vertical scroll bar at right)
    -- Now: make the menu body area a Frame with a vertical ScrollBar at the right
    -- We'll create a vertical frame container for tabs, and a scrollbar next to it
    -- We'll use a simple custom scrollbar implementation for the menu

    -- Create the tab content container (Frame inside Menu)
    self.BodyContainer = create("Frame", {
        Parent = self.Menu,
        Name = "BodyContainer",
        Position = UDim2.new(0, 0, 0, 74),
        Size = UDim2.new(1, -12, 1, -74), -- leave space for scrollbar
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
    })

    -- The actual content (will be filled by tab bodies)
    self.Body = create("Frame", {
        Parent = self.BodyContainer,
        Name = "Body",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        BorderSizePixel = 0,
    })

    -- Custom vertical scrollbar (at right edge)
    self.ScrollBar = create("Frame", {
        Parent = self.Menu,
        Name = "CustomScrollBar",
        Size = UDim2.new(0, 8, 1, -74),
        Position = UDim2.new(1, -8, 0, 74),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        Visible = true,
        ClipsDescendants = true,
        ZIndex = 10,
    })

    self.ScrollThumb = create("Frame", {
        Parent = self.ScrollBar,
        Name = "ScrollThumb",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 11,
    })

    -- Add scrolling logic
    self.ScrollPosition = 0

    local function updateScrollBar()
        -- Find the currently visible tab's body (ScrollingFrame)
        local visibleTab
        for _, tab in ipairs(self.Tabs) do
            if tab.Body and tab.Body.Visible then
                visibleTab = tab
                break
            end
        end
        if not visibleTab then
            self.ScrollBar.Visible = false
            return
        end

        local body = visibleTab.Body
        if not body:IsA("ScrollingFrame") then
            self.ScrollBar.Visible = false
            return
        end

        local canvas = body.CanvasSize.Y.Offset
        local view = body.AbsoluteWindowSize.Y
        if canvas <= view + 2 then
            self.ScrollBar.Visible = false
            body.CanvasPosition = Vector2.new(0, 0)
            return
        end

        self.ScrollBar.Visible = true
        -- Thumb height
        local ratio = math.clamp(view / canvas, 0.1, 1)
        local thumbHeight = math.max(ratio * self.ScrollBar.AbsoluteSize.Y, 20)
        local maxOffset = canvas - view
        local y = 0
        if maxOffset > 0 then
            y = (body.CanvasPosition.Y / maxOffset) * (self.ScrollBar.AbsoluteSize.Y - thumbHeight)
        end
        self.ScrollThumb.Size = UDim2.new(1, 0, 0, thumbHeight)
        self.ScrollThumb.Position = UDim2.new(0, 0, 0, y)
    end

    -- Scroll from scrollbar drag
    local draggingThumb = false
    local dragStartY, thumbStartY

    self.ScrollThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingThumb = true
            dragStartY = input.Position.Y
            thumbStartY = self.ScrollThumb.Position.Y.Offset
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingThumb and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position.Y - dragStartY
            local newY = math.clamp(thumbStartY + delta, 0, self.ScrollBar.AbsoluteSize.Y - self.ScrollThumb.AbsoluteSize.Y)
            self.ScrollThumb.Position = UDim2.new(0, 0, 0, newY)

            -- Update canvas position of visible tab
            for _, tab in ipairs(self.Tabs) do
                if tab.Body and tab.Body.Visible then
                    local body = tab.Body
                    if body:IsA("ScrollingFrame") then
                        local canvas = body.CanvasSize.Y.Offset
                        local view = body.AbsoluteWindowSize.Y
                        local maxOffset = canvas - view
                        if maxOffset > 0 then
                            local percent = newY / (self.ScrollBar.AbsoluteSize.Y - self.ScrollThumb.AbsoluteSize.Y)
                            body.CanvasPosition = Vector2.new(0, percent * maxOffset)
                        end
                    end
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingThumb = false
        end
    end)

    -- Mouse wheel and touch scroll event
    self.BodyContainer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            for _, tab in ipairs(self.Tabs) do
                if tab.Body and tab.Body.Visible and tab.Body:IsA("ScrollingFrame") then
                    local body = tab.Body
                    -- Scroll up/down
                    local scrollAmount = -input.Position.Z * 32
                    local newPos = math.clamp(body.CanvasPosition.Y + scrollAmount, 0, math.max(0, body.CanvasSize.Y.Offset - body.AbsoluteWindowSize.Y))
                    body.CanvasPosition = Vector2.new(0, newPos)
                    updateScrollBar()
                end
            end
        end
    end)

    -- Keep scrollbar in sync
    RunService.RenderStepped:Connect(updateScrollBar)
end

function MSHUB:_buildMenuToggle()
    self.MenuToggle = create("TextButton", {
        Parent = self.ScreenGui,
        Name = "MenuToggle",
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 20, 0.5, -21),
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 2,
        Text = "≡",
        Font = self.Theme.Font,
        TextSize = 26,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = true,
        AnchorPoint = Vector2.new(0, 0.5),
    })

    self.MenuToggle.MouseButton1Click:Connect(function()
        self:setOpen(not self.Open)
    end)
end

function MSHUB:_buildLockToggle()
    self.LockToggle = create("TextButton", {
        Parent = self.ScreenGui,
        Name = "LockToggle",
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 20, 0.5, 30),
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 2,
        Text = "🔒",
        Font = self.Theme.Font,
        TextSize = 22,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = true,
        AnchorPoint = Vector2.new(0, 0),
    })

    self.LockToggle.MouseButton1Click:Connect(function()
        self.Locked = not self.Locked
        self.LockToggle.Text = self.Locked and "🔒" or "🔓"
    end)

    -- Dragging menu if unlocked
    local dragging, dragStart, startPos
    local function beginDrag(input)
        if self.Locked then return end
        dragging = true
        dragStart = input.Position
        startPos = self.Menu.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end

    local function updateDrag(input)
        if not dragging or self.Locked then return end
        local delta = input.Position - dragStart
        self.Menu.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end

    self.Menu.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)
    self.Menu.InputChanged:Connect(updateDrag)
end

function MSHUB:_buildConfigTab()
    local configTab = self:AddTab("Configuração", {
        IsConfig = true,
        Icon = "⚙️",
        LayoutOrder = 9999,
    })
    configTab:AddCategory("Ajustes", function(cat)
        cat:AddButton("Salvar Configurações", function()
            self:SaveSettings()
        end)
        cat:AddButton("Carregar Configurações", function()
            self:LoadSettings()
        end)
        cat:AddButton("Resetar para Padrão", function()
            self:ResetSettings()
        end)
        cat:AddDropdown("Tema", {"Dark", "Light"}, self.ThemeName, function(selected)
            self:ApplyTheme(selected)
        end)
        cat:AddColorPicker("Cor do Texto", self.Theme.Text, function(color)
            self:ChangeFontColor(color)
        end)
        cat:AddDropdown("Fonte", {"Gotham", "Arial", "SourceSans"}, self.Font.Name, function(fontName)
            self:ChangeFontStyle(fontName)
        end)
    end)
end

-- TAB & CATEGORY API
function MSHUB:AddTab(name, options)
    options = options or {}
    local selfRef = self
    local tab = {
        Name = name,
        Categories = {},
        IsConfig = options.IsConfig,
        Icon = options.Icon or "",
        LayoutOrder = options.LayoutOrder or #self.Tabs + 1,
    }
    table.insert(self.Tabs, tab)

    local tabBtn = create("TextButton", {
        Parent = self.TabBar,
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = (tab.Icon ~= "" and (tab.Icon .. " ") or "") .. name,
        Font = self.Font,
        TextSize = 18,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = true,
        LayoutOrder = tab.LayoutOrder,
        Name = name,
        ZIndex = 2,
    })
    tab.TabButton = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        self:ShowTab(tab)
    end)

    -- Build tab body container (now always present under .Body, only one visible at a time)
    tab.Body = create("ScrollingFrame", {
        Parent = self.Body,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Name = name .. "_Body",
        ScrollBarThickness = 0, -- disable default ScrollBar
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    })

    tab.ListLayout = create("UIListLayout", {
        Parent = tab.Body,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Tab API
    function tab:AddCategory(catName, buildFunc)
        local category = {
            Name = catName,
            Controls = {},
        }
        category.Frame = create("Frame", {
            Parent = tab.Body,
            Size = UDim2.new(1, -24, 0, 0),
            BackgroundColor3 = selfRef.Theme.Background,
            BorderColor3 = selfRef.Theme.Border,
            BorderSizePixel = 1,
            Name = catName,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        category.Title = create("TextLabel", {
            Parent = category.Frame,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = catName,
            Font = selfRef.Font,
            TextSize = 20,
            TextColor3 = selfRef.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 8, 0, 0),
        })
        category.Body = create("Frame", {
            Parent = category.Frame,
            Size = UDim2.new(1, -8, 1, -24),
            Position = UDim2.new(0, 8, 0, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Name = "ControlsBody",
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
        })
        category.BodyLayout = create("UIListLayout", {
            Parent = category.Body,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        -- Control adders (as before, insert controls into category.Body)
        function category:AddToggle(name, default, callback)
            local state = default and true or false
            local btn = create("TextButton", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Text = (state and "■" or "□").." "..name,
                Font = selfRef.Font,
                TextSize = 16,
                TextColor3 = selfRef.Theme.Text,
                AutoButtonColor = true,
                Name = "Toggle_" .. name:gsub("%s+", "_"),
            })
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = (state and "■" or "□").." "..name
                if callback then callback(state) end
            end)
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, btn)
            return btn
        end

        function category:AddSlider(name, min, max, default, callback)
            local value = default or min
            local sliderFrame = create("Frame", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Name = "Slider_" .. name:gsub("%s+", "_"),
            })
            local label = create("TextLabel", {
                Parent = sliderFrame,
                Size = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name..": "..tostring(value),
                Font = selfRef.Font,
                TextSize = 16,
                TextColor3 = selfRef.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            local sliderBar = create("Frame", {
                Parent = sliderFrame,
                Size = UDim2.new(0.55, -12, 0, 14),
                Position = UDim2.new(0.45, 6, 0.5, -7),
                BackgroundColor3 = selfRef.Theme.Border,
                BorderColor3 = selfRef.Theme.Accent,
                BorderSizePixel = 2,
                Name = "SliderBar",
                ClipsDescendants = true,
            })
            local fill = create("Frame", {
                Parent = sliderBar,
                Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
                BackgroundColor3 = selfRef.Theme.Accent,
                BorderSizePixel = 0,
                Name = "Fill",
            })
            local dragging = false

            local function updateSlider(input)
                local rel = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                value = math.floor((min + rel * (max - min)) + 0.5)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = name..": "..tostring(value)
                if callback then callback(value) end
            end

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            sliderBar.InputEnded:Connect(function(input)
                dragging = false
            end)
            sliderBar.InputChanged:Connect(function(input)
                if dragging then updateSlider(input) end
            end)
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, sliderFrame)
            return sliderFrame
        end

        function category:AddDropdown(name, options, default, callback)
            local expanded = false
            local selected = default or options[1]
            local dropdownFrame = create("Frame", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Name = "Dropdown_" .. name:gsub("%s+", "_"),
            })
            local button = create("TextButton", {
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Text = "["..name.." +]",
                Font = selfRef.Font,
                TextSize = 16,
                TextColor3 = selfRef.Theme.Text,
                AutoButtonColor = true,
            })
            local listFrame = create("Frame", {
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, #options*28),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Visible = false,
                ZIndex = 2,
                Name = "DropdownList"
            })
            local layout = create("UIListLayout", {
                Parent = listFrame,
                Padding = UDim.new(0, 0)
            })
            for _, opt in ipairs(options) do
                local optBtn = create("TextButton", {
                    Parent = listFrame,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = opt,
                    Font = selfRef.Font,
                    TextSize = 15,
                    TextColor3 = selfRef.Theme.Text,
                    AutoButtonColor = true,
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    button.Text = "["..name.." +]"
                    listFrame.Visible = false
                    expanded = false
                    if callback then callback(opt) end
                end)
            end
            button.MouseButton1Click:Connect(function()
                expanded = not expanded
                button.Text = "["..name.." "..(expanded and "–" or "+").."]"
                listFrame.Visible = expanded
            end)
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, dropdownFrame)
            return dropdownFrame
        end

        function category:AddDropdownToggle(name, options, default, callback)
            local expanded = false
            local selected = default or {}
            local dropdownFrame = create("Frame", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Name = "DropdownToggle_" .. name:gsub("%s+", "_"),
            })
            local button = create("TextButton", {
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Text = "["..name.." +]",
                Font = selfRef.Font,
                TextSize = 16,
                TextColor3 = selfRef.Theme.Text,
                AutoButtonColor = true,
            })
            local listFrame = create("Frame", {
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, #options*28),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Visible = false,
                ZIndex = 2,
                Name = "DropdownList"
            })
            local layout = create("UIListLayout", {
                Parent = listFrame,
                Padding = UDim.new(0, 0)
            })
            for _, opt in ipairs(options) do
                local state = false
                local optBtn = create("TextButton", {
                    Parent = listFrame,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "□ "..opt,
                    Font = selfRef.Font,
                    TextSize = 15,
                    TextColor3 = selfRef.Theme.Text,
                    AutoButtonColor = true,
                })
                optBtn.MouseButton1Click:Connect(function()
                    state = not state
                    optBtn.Text = (state and "■ " or "□ ")..opt
                    selected[opt] = state
                    if callback then callback(selected) end
                end)
            end
            button.MouseButton1Click:Connect(function()
                expanded = not expanded
                button.Text = "["..name.." "..(expanded and "–" or "+").."]"
                listFrame.Visible = expanded
            end)
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, dropdownFrame)
            return dropdownFrame
        end

        function category:AddLabel(text)
            local label = create("TextLabel", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                Font = selfRef.Font,
                TextSize = 15,
                TextColor3 = selfRef.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Name = "Label_" .. text:gsub("%s+", "_"),
            })
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, label)
            return label
        end

        function category:AddButton(name, callback)
            local btn = create("TextButton", {
                Parent = category.Body,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = selfRef.Theme.Background,
                BorderColor3 = selfRef.Theme.Border,
                BorderSizePixel = 1,
                Text = name,
                Font = selfRef.Font,
                TextSize = 16,
                TextColor3 = selfRef.Theme.Text,
                AutoButtonColor = true,
                Name = "Button_" .. name:gsub("%s+", "_"),
            })
            btn.MouseButton1Click:Connect(callback)
            table.insert(selfRef.Tabs[#selfRef.Tabs].Categories[#selfRef.Tabs[#selfRef.Tabs].Categories].Controls, btn)
            return btn
        end

        function category:AddColorPicker(name, default, callback)
            local colors = {
                ["White"] = Color3.fromRGB(255,255,255),
                ["Black"] = Color3.fromRGB(0,0,0),
                ["Red"] = Color3.fromRGB(255,0,0),
                ["Green"] = Color3.fromRGB(0,255,0),
                ["Blue"] = Color3.fromRGB(0,0,255),
                ["Accent"] = selfRef.Theme.Accent,
            }
            local picker = category:AddDropdown(name, {"White","Black","Red","Green","Blue","Accent"}, "Accent", function(selected)
                if callback then callback(colors[selected] or selfRef.Theme.Text) end
            end)
            picker.Name = "ColorPicker_" .. name:gsub("%s+", "_")
            return picker
        end

        table.insert(tab.Categories, category)
        if buildFunc then buildFunc(category) end
        return category
    end

    return tab
end

function MSHUB:ShowTab(tab)
    -- Hide all tab bodies, show selected one
    for _, t in ipairs(self.Tabs) do
        if t.Body then
            t.Body.Visible = false
        end
        if t.TabButton then
            t.TabButton.BackgroundColor3 = self.Theme.Background
            t.TabButton.TextColor3 = self.Theme.Text
        end
    end
    if tab.Body then
        tab.Body.Visible = true
    end
    if tab.TabButton then
        tab.TabButton.BackgroundColor3 = self.Theme.Accent
        tab.TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function MSHUB:setOpen(bool)
    self.Open = bool
    self.Menu.Visible = bool
end

-- SETTINGS & CONFIG
function MSHUB:SaveSettings()
    self.LastSettings = {
        ThemeName = self.ThemeName,
        FontName = self.Font.Name,
        TextColor = self.Theme.Text,
        -- Add more settings as needed
    }
    warn("Configurações salvas:", self.LastSettings)
end

function MSHUB:LoadSettings()
    if not self.LastSettings then
        warn("Nenhuma configuração salva encontrada.")
        return
    end
    self:ApplyTheme(self.LastSettings.ThemeName)
    self:ChangeFontStyle(self.LastSettings.FontName)
    self:ChangeFontColor(self.LastSettings.TextColor)
    warn("Configurações carregadas.")
end

function MSHUB:ResetSettings()
    self:ApplyTheme("Dark")
    self:ChangeFontStyle("Gotham")
    self:ChangeFontColor(DEFAULT_THEME.Text)
    warn("Configurações resetadas para o padrão.")
end

function MSHUB:ApplyTheme(themeName)
    local theme = THEMES[themeName]
    if not theme then return end
    self.Theme = deepCopy(theme)
    self.ThemeName = themeName
    self.Font = self.Theme.Font
    self:RefreshTheme()
end

function MSHUB:ChangeFontColor(color)
    self.Theme.Text = color
    self:RefreshTheme()
end

function MSHUB:ChangeFontStyle(fontName)
    self.Theme.Font = Enum.Font[fontName] or Enum.Font.Gotham
    self.Font = self.Theme.Font
    self:RefreshTheme()
end

function MSHUB:RefreshTheme()
    self.Menu.BackgroundColor3 = self.Theme.Background
    self.Menu.BorderColor3 = self.Theme.Border
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.Font = self.Theme.Font

    self.MenuToggle.BackgroundColor3 = self.Theme.Background
    self.MenuToggle.BorderColor3 = self.Theme.Border
    self.MenuToggle.TextColor3 = self.Theme.Text
    self.MenuToggle.Font = self.Theme.Font

    self.LockToggle.BackgroundColor3 = self.Theme.Background
    self.LockToggle.BorderColor3 = self.Theme.Border
    self.LockToggle.TextColor3 = self.Theme.Text
    self.LockToggle.Font = self.Theme.Font

    self.ScrollBar.BackgroundColor3 = Color3.fromRGB(40,40,60)
    self.ScrollBar.BorderColor3 = self.Theme.Border
    self.ScrollThumb.BackgroundColor3 = self.Theme.Accent

    for _, tab in ipairs(self.Tabs) do
        if tab.TabButton then
            tab.TabButton.BackgroundColor3 = (tab.Body and tab.Body.Visible and self.Theme.Accent) or self.Theme.Background
            tab.TabButton.BorderColor3 = self.Theme.Border
            tab.TabButton.TextColor3 = (tab.Body and tab.Body.Visible and Color3.fromRGB(255, 255, 255)) or self.Theme.Text
            tab.TabButton.Font = self.Theme.Font
        end

        for _, category in ipairs(tab.Categories) do
            if category.Frame then
                category.Frame.BackgroundColor3 = self.Theme.Background
                category.Frame.BorderColor3 = self.Theme.Border
            end
            if category.Title then
                category.Title.TextColor3 = self.Theme.Text
                category.Title.Font = self.Theme.Font
            end

            if category.Controls then
                for _, control in ipairs(category.Controls) do
                    if control:IsA("TextButton") then
                        control.BackgroundColor3 = self.Theme.Background
                        control.BorderColor3 = self.Theme.Border
                        control.TextColor3 = self.Theme.Text
                        control.Font = self.Theme.Font
                    elseif control:IsA("TextLabel") then
                        control.TextColor3 = self.Theme.Text
                        control.Font = self.Theme.Font
                    elseif control:IsA("Frame") and control.Name:find("Slider") then
                        local sliderBar = control:FindFirstChild("SliderBar")
                        if sliderBar then
                            sliderBar.BackgroundColor3 = self.Theme.Border
                            sliderBar.BorderColor3 = self.Theme.Accent
                            local fill = sliderBar:FindFirstChild("Fill")
                            if fill then
                                fill.BackgroundColor3 = self.Theme.Accent
                            end
                        end
                        local label = control:FindFirstChildOfClass("TextLabel")
                        if label then
                            label.TextColor3 = self.Theme.Text
                            label.Font = self.Theme.Font
                        end
                    elseif control:IsA("Frame") and control.Name:find("Dropdown") then
                        local button = control:FindFirstChildOfClass("TextButton")
                        if button then
                            button.BackgroundColor3 = self.Theme.Background
                            button.BorderColor3 = self.Theme.Border
                            button.TextColor3 = self.Theme.Text
                            button.Font = self.Theme.Font
                        end
                        local listFrame = control:FindFirstChild("DropdownList")
                        if listFrame then
                            listFrame.BackgroundColor3 = self.Theme.Background
                            listFrame.BorderColor3 = self.Theme.Border
                            for _, itemBtn in ipairs(listFrame:GetChildren()) do
                                if itemBtn:IsA("TextButton") then
                                    itemBtn.TextColor3 = self.Theme.Text
                                    itemBtn.Font = self.Theme.Font
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

return MSHUB
