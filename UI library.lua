--[[
  MSHUB-Style UI Library for Roblox (DOORS Compatible)
  Author: DH-SOARESE
  Inspired by MSHUB. Minimalist, modern, touch-friendly, and highly customizable.
  Save/Load/Reset Presets, Full Mobile Compatibility, Custom Themes & Fonts.
  Use: loadstring(game:HttpGet("LINK-DO-GITHUB"))()
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--[[
  CORE CONFIGURATION
--]]
local DEFAULTS = {
    Theme = {
        Background = Color3.fromRGB(27, 30, 39),
        Accent = Color3.fromRGB(63, 81, 181),
        Tab = Color3.fromRGB(36, 41, 54),
        Category = Color3.fromRGB(31, 34, 44),
        Border = Color3.fromRGB(50, 53, 65),
        Text = Color3.fromRGB(230, 230, 230),
        ToggleOn = Color3.fromRGB(63, 81, 181),
        ToggleOff = Color3.fromRGB(60, 61, 73),
        Slider = Color3.fromRGB(63, 81, 181),
        Dropdown = Color3.fromRGB(40, 44, 55),
        DropdownSelected = Color3.fromRGB(63, 81, 181),
        Button = Color3.fromRGB(63, 81, 181),
    },
    Font = Enum.Font.Gotham,
    FontSize = Enum.FontSize.Size18
}

local LIBRARY = {
    _version = "1.0.0",
    _theme = DEFAULTS.Theme,
    _font = DEFAULTS.Font,
    _fontSize = DEFAULTS.FontSize,
    _configPresets = {},
    _connections = {},
    _menuOpened = true,
    _menuLocked = false,
    _currentConfig = {},
}

local function deepCopy(tab)
    if type(tab) ~= "table" then return tab end
    local ret = {}
    for k, v in pairs(tab) do
        ret[k] = deepCopy(v)
    end
    return ret
end

--[[
  UTILITY: Save/Load/Reset Config
  (Uses HttpService:SetAsync/GetAsync in an actual game)
--]]
function LIBRARY:SaveConfig(name)
    self._configPresets[name or "Default"] = deepCopy(self._currentConfig)
end

function LIBRARY:LoadConfig(name)
    if self._configPresets[name] then
        for k, v in pairs(self._configPresets[name]) do
            if self._currentConfig[k] ~= nil then
                self._currentConfig[k] = v
            end
        end
        self:RefreshUI()
    end
end

function LIBRARY:ResetConfig()
    self._currentConfig = {}
    self:RefreshUI()
end

--[[
  UI CONSTRUCTION HELPERS
--]]
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function ApplyTheme(obj, key)
    if obj:IsA("GuiObject") then
        obj.BackgroundColor3 = LIBRARY._theme[key] or obj.BackgroundColor3
    end
end

local function ApplyFont(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.Font = LIBRARY._font
        obj.TextColor3 = LIBRARY._theme.Text
        obj.TextSize = tonumber(tostring(LIBRARY._fontSize):gsub("%D+", "")) or 18
    end
end

--[[
  MAIN UI HOLDER
--]]
local screenGui = Create("ScreenGui", {
    Name = "MSHUB_UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = game:GetService("CoreGui")
})

local menuFrame = Create("Frame", {
    Name = "MenuFrame",
    Size = UDim2.new(0, 480, 0, 420),
    Position = UDim2.new(0.5, -240, 0.5, -210),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Visible = true,
    Active = true,
    Draggable = true,
    Parent = screenGui
})
ApplyTheme(menuFrame, "Background")

-- SQUARE BORDERS
local border = Create("UIStroke", {
    Color = LIBRARY._theme.Border,
    Thickness = 1.5,
    Parent = menuFrame
})
Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = menuFrame})

-- MENU HEADER: Title and Tabs
local header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = menuFrame
})

local menuTitle = Create("TextLabel", {
    Name = "MenuTitle",
    Text = "Menu Título",
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = header
})
ApplyFont(menuTitle)

-- TABS HOLDER
local tabsFrame = Create("Frame", {
    Name = "TabsFrame",
    Size = UDim2.new(1, -230, 1, 0),
    Position = UDim2.new(0, 220, 0, 0),
    BackgroundTransparency = 1,
    Parent = header
})

local tabsLayout = Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
    Parent = tabsFrame
})

-- TOGGLE MENU BUTTON (Always visible)
local openToggle = Create("TextButton", {
    Name = "OpenToggle",
    Text = "☰",
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, -46, 0, 5),
    BackgroundColor3 = LIBRARY._theme.Tab,
    BorderSizePixel = 0,
    Parent = menuFrame
})
ApplyFont(openToggle)
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = openToggle})

-- LOCK/UNLOCK BUTTON (Always visible)
local lockToggle = Create("TextButton", {
    Name = "LockToggle",
    Text = "🔒",
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, -92, 0, 5),
    BackgroundColor3 = LIBRARY._theme.Tab,
    BorderSizePixel = 0,
    Parent = menuFrame
})
ApplyFont(lockToggle)
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = lockToggle})

-- Holds all tab contents, only one visible at a time
local contentFrame = Create("Frame", {
    Name = "ContentFrame",
    Size = UDim2.new(1, 0, 1, -46),
    Position = UDim2.new(0, 0, 0, 46),
    BackgroundTransparency = 1,
    Parent = menuFrame
})

--[[
  TAB SYSTEM
--]]
LIBRARY._tabs = {}
local selectedTab = nil

function LIBRARY:Tab(name)
    local tabBtn = Create("TextButton", {
        Name = "Tab_" .. name,
        Text = name,
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = LIBRARY._theme.Tab,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = tabsFrame
    })
    ApplyFont(tabBtn)
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tabBtn})

    local tabContent = Create("Frame", {
        Name = "TabContent_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = contentFrame
    })

    LIBRARY._tabs[name] = {Button = tabBtn, Content = tabContent, Categories = {}}

    tabBtn.MouseButton1Click:Connect(function()
        if selectedTab then
            LIBRARY._tabs[selectedTab].Content.Visible = false
            LIBRARY._tabs[selectedTab].Button.BackgroundColor3 = LIBRARY._theme.Tab
        end
        selectedTab = name
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = LIBRARY._theme.Accent
    end)

    -- If first tab, select it
    if not selectedTab then
        tabBtn:Activate()
        tabBtn.BackgroundColor3 = LIBRARY._theme.Accent
        tabContent.Visible = true
        selectedTab = name
    end

    -- CATEGORY ADDER
    function LIBRARY._tabs[name]:Category(catName)
        local catFrame = Create("Frame", {
            Name = "Category_" .. catName,
            Size = UDim2.new(1, -30, 0, 80),
            BackgroundColor3 = LIBRARY._theme.Category,
            BorderSizePixel = 0,
            Parent = tabContent
        })
        local catStroke = Create("UIStroke", {
            Color = LIBRARY._theme.Border,
            Thickness = 1,
            Parent = catFrame
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = catFrame})

        local catLabel = Create("TextLabel", {
            Name = "CategoryLabel",
            Text = catName,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 10, 0, 5),
            Parent = catFrame
        })
        ApplyFont(catLabel)

        local featuresHolder = Create("Frame", {
            Name = "FeaturesHolder",
            Size = UDim2.new(1, -20, 1, -30),
            Position = UDim2.new(0, 10, 0, 25),
            BackgroundTransparency = 1,
            Parent = catFrame
        })

        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = featuresHolder
        })

        LIBRARY._tabs[name].Categories[catName] = {Frame = catFrame, Features = {}, Holder = featuresHolder}

        -- FEATURE ADDERS
        function LIBRARY._tabs[name].Categories[catName]:Toggle(label, default, callback)
            local key = name .. "_" .. catName .. "_" .. label
            LIBRARY._currentConfig[key] = default
            local btn = Create("TextButton", {
                Text = default and "■ " .. label or "□ " .. label,
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundColor3 = LIBRARY._theme.ToggleOff,
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Parent = featuresHolder
            })
            ApplyFont(btn)
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = btn})

            local function update()
                btn.Text = LIBRARY._currentConfig[key] and "■ " .. label or "□ " .. label
                btn.BackgroundColor3 = LIBRARY._currentConfig[key] and LIBRARY._theme.ToggleOn or LIBRARY._theme.ToggleOff
            end
            update()

            btn.MouseButton1Click:Connect(function()
                LIBRARY._currentConfig[key] = not LIBRARY._currentConfig[key]
                update()
                if callback then callback(LIBRARY._currentConfig[key]) end
            end)
        end

        function LIBRARY._tabs[name].Categories[catName]:Slider(label, min, max, default, callback)
            local key = name .. "_" .. catName .. "_" .. label
            LIBRARY._currentConfig[key] = default
            local sliderFrame = Create("Frame", {
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundColor3 = LIBRARY._theme.Slider,
                Parent = featuresHolder
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = sliderFrame})

            local sliderBar = Create("Frame", {
                Size = UDim2.new(1, -50, 0, 8),
                Position = UDim2.new(0, 10, 0.5, -4),
                BackgroundColor3 = LIBRARY._theme.Border,
                BorderSizePixel = 0,
                Parent = sliderFrame
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = sliderBar})

            local fill = Create("Frame", {
                BackgroundColor3 = LIBRARY._theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                Parent = sliderBar
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = fill})

            local valueLabel = Create("TextLabel", {
                Text = tostring(default),
                Size = UDim2.new(0, 36, 1, 0),
                Position = UDim2.new(1, -36, 0, 0),
                BackgroundTransparency = 1,
                Parent = sliderFrame
            })
            ApplyFont(valueLabel)

            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local function move(input)
                        local rel = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        local value = math.floor((min + (max-min)*rel) + 0.5)
                        LIBRARY._currentConfig[key] = value
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        valueLabel.Text = tostring(value)
                        if callback then callback(value) end
                    end
                    move(input)
                    local conn
                    conn = UserInputService.InputChanged:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
                            move(input2)
                        end
                    end)
                    local endConn
                    endConn = UserInputService.InputEnded:Connect(function(input3)
                        if input3.UserInputType == Enum.UserInputType.MouseButton1 or input3.UserInputType == Enum.UserInputType.Touch then
                            if conn then conn:Disconnect() end
                            if endConn then endConn:Disconnect() end
                        end
                    end)
                end
            end)
        end

        function LIBRARY._tabs[name].Categories[catName]:Dropdown(label, options, default, callback)
            local key = name .. "_" .. catName .. "_" .. label
            LIBRARY._currentConfig[key] = default or options[1]
            local btn = Create("TextButton", {
                Text = "[" .. label .. " +]",
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundColor3 = LIBRARY._theme.Dropdown,
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Parent = featuresHolder
            })
            ApplyFont(btn)
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = btn})

            local open = false
            local dropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, #options * 28),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = LIBRARY._theme.Dropdown,
                Visible = false,
                Parent = btn
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = dropdownFrame})

            for i, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Text = opt,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, (i-1)*28),
                    BackgroundTransparency = 1,
                    Parent = dropdownFrame
                })
                ApplyFont(optBtn)
                optBtn.MouseButton1Click:Connect(function()
                    LIBRARY._currentConfig[key] = opt
                    btn.Text = "[" .. label .. " -]"
                    dropdownFrame.Visible = false
                    open = false
                    if callback then callback(opt) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                btn.Text = open and "[" .. label .. " -]" or "[" .. label .. " +]"
                dropdownFrame.Visible = open
            end)
        end

        function LIBRARY._tabs[name].Categories[catName]:DropdownToggle(label, options, defaults, callback)
            local key = name .. "_" .. catName .. "_" .. label
            LIBRARY._currentConfig[key] = defaults or {}
            local btn = Create("TextButton", {
                Text = "[" .. label .. " +]",
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundColor3 = LIBRARY._theme.Dropdown,
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Parent = featuresHolder
            })
            ApplyFont(btn)
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = btn})

            local open = false
            local dropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, #options * 28),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = LIBRARY._theme.Dropdown,
                Visible = false,
                Parent = btn
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = dropdownFrame})

            local selected = {}
            for i, opt in ipairs(options) do
                selected[opt] = false
                local optBtn = Create("TextButton", {
                    Text = "□ " .. opt,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, (i-1)*28),
                    BackgroundTransparency = 1,
                    Parent = dropdownFrame
                })
                ApplyFont(optBtn)
                optBtn.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    optBtn.Text = selected[opt] and "■ " .. opt or "□ " .. opt
                    local sel = {}
                    for name, v in pairs(selected) do if v then table.insert(sel, name) end end
                    LIBRARY._currentConfig[key] = sel
                    if callback then callback(sel) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                btn.Text = open and "[" .. label .. " -]" or "[" .. label .. " +]"
                dropdownFrame.Visible = open
            end)
        end

        function LIBRARY._tabs[name].Categories[catName]:Label(text)
            local lbl = Create("TextLabel", {
                Text = text,
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = featuresHolder
            })
            ApplyFont(lbl)
        end

        return LIBRARY._tabs[name].Categories[catName]
    end

    return LIBRARY._tabs[name]
end

--[[
  CONFIGURATION TAB (Always last)
--]]
local configTab = LIBRARY:Tab("Configuração")
local configCat = configTab:Category("Ajustes Gerais")

configCat:Label("Gerenciar configurações do menu:")

configCat:Toggle("Salvar Configuração", false, function(val)
    if val then
        LIBRARY:SaveConfig("Usuário")
    end
end)

configCat:Toggle("Carregar Configuração", false, function(val)
    if val then
        LIBRARY:LoadConfig("Usuário")
    end
end)

configCat:Toggle("Resetar Padrão", false, function(val)
    if val then
        LIBRARY:ResetConfig()
    end
end)

configCat:Dropdown("Preset Rápido", {"Default", "Usuário"}, "Default", function(opt)
    LIBRARY:LoadConfig(opt)
end)

configCat:Dropdown("Cor da Fonte", {"Branco", "Azul", "Verde"}, "Branco", function(opt)
    if opt == "Branco" then LIBRARY._theme.Text = Color3.fromRGB(230,230,230)
    elseif opt == "Azul" then LIBRARY._theme.Text = Color3.fromRGB(63, 81, 181)
    elseif opt == "Verde" then LIBRARY._theme.Text = Color3.fromRGB(76, 175, 80)
    end
    LIBRARY:RefreshUI()
end)

configCat:Dropdown("Tema", {"Padrão", "Escuro", "Claro"}, "Padrão", function(opt)
    if opt == "Padrão" then LIBRARY._theme.Background = Color3.fromRGB(27, 30, 39)
    elseif opt == "Escuro" then LIBRARY._theme.Background = Color3.fromRGB(20, 20, 20)
    elseif opt == "Claro" then LIBRARY._theme.Background = Color3.fromRGB(220, 220, 220)
    end
    LIBRARY:RefreshUI()
end)

configCat:Dropdown("Fonte", {"Gotham", "Arial", "FredokaOne"}, "Gotham", function(opt)
    if opt == "Gotham" then LIBRARY._font = Enum.Font.Gotham
    elseif opt == "Arial" then LIBRARY._font = Enum.Font.Arial
    elseif opt == "FredokaOne" then LIBRARY._font = Enum.Font.FredokaOne
    end
    LIBRARY:RefreshUI()
end)

--[[
  MENU FUNCTIONALITY: Open/Close, Lock/Unlock, Dragging, Responsiveness
--]]
openToggle.MouseButton1Click:Connect(function()
    LIBRARY._menuOpened = not LIBRARY._menuOpened
    menuFrame.Visible = LIBRARY._menuOpened
end)

lockToggle.MouseButton1Click:Connect(function()
    LIBRARY._menuLocked = not LIBRARY._menuLocked
    lockToggle.Text = LIBRARY._menuLocked and "🔒" or "🔓"
    menuFrame.Draggable = not LIBRARY._menuLocked
end)

-- Responsive resizing for mobile
local function updateMenuSize()
    if UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
        menuFrame.Size = UDim2.new(0, math.clamp(workspace.CurrentCamera.ViewportSize.X*0.85, 320, 480), 0, math.clamp(workspace.CurrentCamera.ViewportSize.Y*0.70, 320, 480))
        menuFrame.Position = UDim2.new(0.5, -menuFrame.AbsoluteSize.X/2, 0.5, -menuFrame.AbsoluteSize.Y/2)
    end
end
updateMenuSize()
RunService.RenderStepped:Connect(updateMenuSize)

-- Touch/Drag support is automatic with Frame.Draggable, but we refresh .Draggable property on lock/unlock

--[[
  REFRESH UI ON THEME/FONT CHANGE
--]]
function LIBRARY:RefreshUI()
    -- Recursively update all elements
    local function updateAll(obj)
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") then
            if obj.BackgroundColor3 then
                obj.BackgroundColor3 = self._theme.Background
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.Font = self._font
                obj.TextColor3 = self._theme.Text
            end
        end
        for _, child in ipairs(obj:GetChildren()) do
            updateAll(child)
        end
    end
    updateAll(menuFrame)
end

--[[
  SAMPLE USAGE (DELETE BELOW FOR PRODUCTION)
--]]
--[[
local mainTab = LIBRARY:Tab("Tab1")
local catA = mainTab:Category("Categoria 1")
catA:Label("Seção de recursos:")
catA:Toggle("Exemplo Toggle", false, function(val) print("Toggle:", val) end)
catA:Slider("Exemplo Slider", 0, 100, 30, function(val) print("Slider:", val) end)
catA:Dropdown("Exemplo Dropdown", {"A", "B", "C"}, "A", function(opt) print("Dropdown:", opt) end)
catA:DropdownToggle("Exemplo DropdownToggle", {"X", "Y", "Z"}, {}, function(opts) print("DropdownToggle:", opts) end)
--]]

return LIBRARY
