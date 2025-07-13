--[[
    UI Library - Modern Quadrado (Estilo MS-Hub)
    Moderna, quadrada, com foco em usabilidade e visual sofisticado.
    Fácil personalização, integração e execução via loadstring.

    • Layout quadrado com cantos levemente arredondados
    • Controles drag & lock, touch-friendly
    • Abas superiores, categorias verticais à esquerda
    • Features modulares: toggle, slider, dropdown, etc.
    • Configs rápidas: tema, fonte, cor, presets
    • Visual inspirado em MS-Hub: dark, glass, highlight, hover suave
]]

local UI = {}
UI.__index = UI

-- Configuração do Usuário
local UserConfig = {
    font = "Gotham",
    color = Color3.fromRGB(220, 220, 220),
    theme = "MS-Dark",
    preset = "Padrão",
    saved = {},
}

-- Temas
local Themes = {
    ["MS-Dark"] = {
        bg = Color3.fromRGB(32, 35, 38),
        border = Color3.fromRGB(46, 51, 54),
        accent = Color3.fromRGB(0, 120, 215),
        glass = Color3.fromRGB(40, 43, 46),
        hover = Color3.fromRGB(45, 50, 55)
    },
    ["MS-Light"] = {
        bg = Color3.fromRGB(242, 245, 246),
        border = Color3.fromRGB(200, 200, 200),
        accent = Color3.fromRGB(0, 120, 215),
        glass = Color3.fromRGB(245, 247, 250),
        hover = Color3.fromRGB(230, 235, 238)
    },
}
local Fonts = {
    ["Gotham"] = Enum.Font.Gotham,
    ["Arial"] = Enum.Font.Arial,
    ["SciFi"] = Enum.Font.SciFi,
    ["SourceSans"] = Enum.Font.SourceSans,
}

-- Utilitários
local function create(instance, props)
    local obj = Instance.new(instance)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

local function glassFrame(parent, size, position, theme, z)
    return create("Frame", {
        Parent = parent,
        Size = size,
        Position = position,
        BackgroundColor3 = theme.glass,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 1,
        BorderColor3 = theme.border,
        ZIndex = z or 1,
    })
end

local function roundify(obj, r)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, r or 10)
    uiCorner.Parent = obj
    return uiCorner
end

-- UI Core
function UI:ApplyTheme()
    local t = Themes[UserConfig.theme] or Themes["MS-Dark"]
    self.Main.BackgroundColor3 = t.bg
    self.Main.BorderColor3 = t.border
    self.SideBar.BackgroundColor3 = t.glass
    self.TabBar.BackgroundColor3 = t.glass
    self.Highlight.BackgroundColor3 = t.accent
    for _,label in ipairs(self.FontLabels) do
        label.TextColor3 = UserConfig.color
    end
    for _,btn in ipairs(self.AllButtons) do
        btn.BackgroundColor3 = t.glass
        btn.BorderColor3 = t.border
    end
end

function UI:ApplyFont()
    for _,label in ipairs(self.FontLabels) do
        label.Font = Fonts[UserConfig.font] or Fonts["Gotham"]
    end
end

function UI:SaveConfig(name)
    UserConfig.saved[name] = {
        font = UserConfig.font,
        color = UserConfig.color,
        theme = UserConfig.theme,
        preset = UserConfig.preset
    }
end

function UI:LoadConfig(name)
    local cfg = UserConfig.saved[name]
    if cfg then
        for k,v in pairs(cfg) do UserConfig[k]=v end
        self:ApplyTheme()
        self:ApplyFont()
    end
end

function UI:ResetConfig()
    UserConfig.font = "Gotham"
    UserConfig.color = Color3.fromRGB(220,220,220)
    UserConfig.theme = "MS-Dark"
    UserConfig.preset = "Padrão"
    self:ApplyTheme()
    self:ApplyFont()
end

-- Menu Toggle e Lock/Unlock
function UI:CreateMenuToggle()
    local t = Themes[UserConfig.theme]
    local btn = create("TextButton", {
        Parent = self.Screen,
        Size = UDim2.new(0,42,0,42),
        Position = UDim2.new(0,16,0,16),
        Text = "☰",
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        BackgroundColor3 = t.glass,
        BorderSizePixel = 1,
        BorderColor3 = t.border,
        AutoButtonColor = true,
        ZIndex = 10,
    })
    roundify(btn, 8)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = t.hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = t.glass end)
    btn.MouseButton1Click:Connect(function()
        self.Main.Visible = not self.Main.Visible
    end)
    table.insert(self.AllButtons, btn)
end

function UI:CreateLockToggle()
    local t = Themes[UserConfig.theme]
    local btn = create("TextButton", {
        Parent = self.Screen,
        Size = UDim2.new(0,42,0,42),
        Position = UDim2.new(0,16,0,70),
        Text = "🔒",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundColor3 = t.glass,
        BorderSizePixel = 1,
        BorderColor3 = t.border,
        AutoButtonColor = true,
        ZIndex = 10,
    })
    roundify(btn, 8)
    local locked = true
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = t.hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = t.glass end)
    btn.MouseButton1Click:Connect(function()
        locked = not locked
        btn.Text = locked and "🔒" or "🔓"
        self.Main.Active = not locked
        self.Main.Draggable = not locked
    end)
    table.insert(self.AllButtons, btn)
end

-- Tabs & Sidebar
function UI:AddTab(tabName)
    local t = Themes[UserConfig.theme]
    local btn = create("TextButton", {
        Parent = self.SideBar,
        Size = UDim2.new(1, -8, 0, 40),
        Position = UDim2.new(0, 4, 0, 8 + (#self.TabOrder)*48),
        Text = tabName,
        Font = Fonts[UserConfig.font],
        TextSize = 18,
        BackgroundColor3 = t.glass,
        BorderSizePixel = 0,
        TextColor3 = UserConfig.color,
        ZIndex = 3,
    })
    roundify(btn, 7)
    btn.AutoButtonColor = true
    local tabFrame = glassFrame(self.Main, UDim2.new(1,-170,1,-60), UDim2.new(0,160,0,50), t, 2)
    tabFrame.Visible = #self.TabOrder == 0
    roundify(tabFrame, 12)
    self.Tabs[tabName] = {Frame = tabFrame, Btn = btn, Categories = {}}
    table.insert(self.TabOrder, tabName)
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do t.Frame.Visible = false end
        tabFrame.Visible = true
        self.Highlight.Position = UDim2.new(0, 0, 0, btn.Position.Y.Offset)
    end)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = t.hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = t.glass end)
    table.insert(self.AllButtons, btn)
end

function UI:AddCategory(tabName, catName)
    local tab = self.Tabs[tabName]
    assert(tab, "Tab não existe")
    local t = Themes[UserConfig.theme]
    local y = 14 + (#tab.Categories)*54
    local catFrame = glassFrame(tab.Frame, UDim2.new(0,145,0,48), UDim2.new(0,12,0,y), t, 3)
    roundify(catFrame, 7)
    local catLabel = create("TextLabel", {
        Parent = catFrame,
        Size = UDim2.new(1, -14, 1, 0),
        Position = UDim2.new(0,7,0,0),
        Text = catName,
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 4,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    table.insert(self.FontLabels, catLabel)
    tab.Categories[catName] = {Frame = catFrame, ChildCount = 0}
end

-- Features
local function nextY(cat)
    cat.ChildCount = (cat.ChildCount or 0) + 1
    return 54 + (cat.ChildCount-1)*54
end

function UI:AddToggle(tabName, catName, featureName, default, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local t = Themes[UserConfig.theme]
    local frame = glassFrame(cat.Frame, UDim2.new(0, 120, 0, 38), UDim2.new(0,10,0,nextY(cat)), t, 4)
    roundify(frame, 5)
    local toggleBtn = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0,32,1,0),
        Position = UDim2.new(0,4,0,0),
        Text = default and "■" or "□",
        Font = Fonts[UserConfig.font],
        TextSize = 22,
        BackgroundTransparency = 1,
        TextColor3 = t.accent,
        ZIndex = 5,
    })
    local label = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1,-44,1,0),
        Position = UDim2.new(0,40,0,0),
        Text = featureName,
        Font = Fonts[UserConfig.font],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 5,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    table.insert(self.FontLabels, label)
    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "■" or "□"
        if callback then callback(state) end
    end)
end

function UI:AddSlider(tabName, catName, featureName, min, max, default, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local t = Themes[UserConfig.theme]
    local frame = glassFrame(cat.Frame, UDim2.new(0, 120, 0, 38), UDim2.new(0,10,0,nextY(cat)), t, 4)
    roundify(frame, 5)
    local slider = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,4,0,0),
        Text = ("%s: %d"):format(featureName, default),
        Font = Fonts[UserConfig.font],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = t.accent,
        ZIndex = 5,
    })
    table.insert(self.FontLabels, slider)
    slider.MouseButton1Click:Connect(function()
        -- Simula input
        local val = math.random(min,max)
        slider.Text = ("%s: %d"):format(featureName, val)
        if callback then callback(val) end
    end)
end

function UI:AddDropdown(tabName, catName, featureName, options, default, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local t = Themes[UserConfig.theme]
    local frame = glassFrame(cat.Frame, UDim2.new(0, 120, 0, 38), UDim2.new(0,10,0,nextY(cat)), t, 4)
    roundify(frame, 5)
    local dropdown = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        Text = featureName.." +",
        Font = Fonts[UserConfig.font],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = t.accent,
        ZIndex = 5,
    })
    table.insert(self.FontLabels, dropdown)
    local opened = false
    dropdown.MouseButton1Click:Connect(function()
        opened = not opened
        dropdown.Text = featureName..(opened and " -" or " +")
        if opened then
            for i,op in ipairs(options) do
                local optBtn = create("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1,0,0,26),
                    Position = UDim2.new(0,0,0,38+i*26),
                    Text = op,
                    Font = Fonts[UserConfig.font],
                    TextSize = 14,
                    BackgroundColor3 = t.hover,
                    BorderSizePixel = 0,
                    TextColor3 = t.accent,
                    ZIndex = 6,
                })
                roundify(optBtn, 4)
                optBtn.MouseButton1Click:Connect(function()
                    callback(op)
                    dropdown.Text = featureName.." +"
                    opened = false
                    for _,b in ipairs(frame:GetChildren()) do
                        if b:IsA("TextButton") and b ~= dropdown then b:Destroy() end
                    end
                end)
            end
        else
            for _,b in ipairs(frame:GetChildren()) do
                if b:IsA("TextButton") and b ~= dropdown then b:Destroy() end
            end
        end
    end)
end

function UI:AddDropdownToggle(tabName, catName, featureName, options, defaults, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local t = Themes[UserConfig.theme]
    local frame = glassFrame(cat.Frame, UDim2.new(0, 120, 0, 38), UDim2.new(0,10,0,nextY(cat)), t, 4)
    roundify(frame, 5)
    local dropdown = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        Text = featureName.." +",
        Font = Fonts[UserConfig.font],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = t.accent,
        ZIndex = 5,
    })
    table.insert(self.FontLabels, dropdown)
    local opened = false
    local selected = defaults or {}
    dropdown.MouseButton1Click:Connect(function()
        opened = not opened
        dropdown.Text = featureName..(opened and " -" or " +")
        if opened then
            for i,op in ipairs(options) do
                local optBtn = create("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1,0,0,26),
                    Position = UDim2.new(0,0,0,38+i*26),
                    Text = (selected[op] and "■ " or "□ ")..op,
                    Font = Fonts[UserConfig.font],
                    TextSize = 14,
                    BackgroundColor3 = t.hover,
                    BorderSizePixel = 0,
                    TextColor3 = t.accent,
                    ZIndex = 6,
                })
                roundify(optBtn, 4)
                optBtn.MouseButton1Click:Connect(function()
                    selected[op] = not selected[op]
                    optBtn.Text = (selected[op] and "■ " or "□ ")..op
                    callback(selected)
                end)
            end
        else
            for _,b in ipairs(frame:GetChildren()) do
                if b:IsA("TextButton") and b ~= dropdown then b:Destroy() end
            end
        end
    end)
end

function UI:AddLabel(tabName, catName, text)
    local cat = self.Tabs[tabName].Categories[catName]
    local t = Themes[UserConfig.theme]
    local label = create("TextLabel", {
        Parent = cat.Frame,
        Size = UDim2.new(1, -14, 0, 26),
        Position = UDim2.new(0, 7, 0, nextY(cat)),
        Text = text,
        Font = Fonts[UserConfig.font],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 5,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    table.insert(self.FontLabels, label)
end

-- Configuração Tab
function UI:SetupConfigTab()
    self:AddTab("Config")
    local catName = "Opções"
    self:AddCategory("Config", catName)
    self:AddLabel("Config", catName, "Salve, carregue ou resete suas configs:")
    self:AddDropdown("Config", catName, "Preset", {"Padrão","Gamer","Minimalista"}, "Padrão", function(opt)
        UserConfig.preset = opt
    end)
    self:AddDropdown("Config", catName, "Tema", {"MS-Dark","MS-Light"}, "MS-Dark", function(opt)
        UserConfig.theme = opt
        self:ApplyTheme()
    end)
    self:AddDropdown("Config", catName, "Fonte", {"Gotham","Arial","SciFi","SourceSans"}, "Gotham", function(opt)
        UserConfig.font = opt
        self:ApplyFont()
    end)
    self:AddSlider("Config", catName, "Cor da Fonte", 0,255,220, function(val)
        UserConfig.color = Color3.fromRGB(val,val,val)
        self:ApplyFont()
    end)
    self:AddToggle("Config", catName, "Salvar Configuração", false, function()
        self:SaveConfig(UserConfig.preset)
    end)
    self:AddToggle("Config", catName, "Carregar Configuração", false, function()
        self:LoadConfig(UserConfig.preset)
    end)
    self:AddToggle("Config", catName, "Resetar Configuração", false, function()
        self:ResetConfig()
    end)
end

-- Inicialização
function UI:Init()
    self.Screen = Instance.new("ScreenGui")
    self.Screen.Name = "ModernMSHubUI"
    self.Screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local t = Themes[UserConfig.theme]

    self.Main = create("Frame", {
        Parent = self.Screen,
        Size = UDim2.new(0,700,0,500),
        Position = UDim2.new(0.5,-350,0.5,-250),
        BackgroundColor3 = t.bg,
        BorderSizePixel = 1,
        BorderColor3 = t.border,
        Active = false,
        Draggable = false,
        Visible = true,
        ZIndex = 1,
    })
    roundify(self.Main, 12)

    self.SideBar = glassFrame(self.Main, UDim2.new(0,150,1,-20), UDim2.new(0,10,0,10), t, 2)
    roundify(self.SideBar, 8)
    self.TabBar = glassFrame(self.Main, UDim2.new(1,-170,0,40), UDim2.new(0,160,0,10), t, 2)
    roundify(self.TabBar, 8)

    self.Highlight = create("Frame", {
        Parent = self.SideBar,
        Size = UDim2.new(1, -8, 0, 38),
        Position = UDim2.new(0, 4, 0, 8),
        BackgroundColor3 = t.accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    roundify(self.Highlight, 7)

    self.Tabs = {}
    self.TabOrder = {}
    self.FontLabels = {}
    self.AllButtons = {}

    self:CreateMenuToggle()
    self:CreateLockToggle()
    self:SetupConfigTab()
end

-- Export
function UI.New()
    local self = setmetatable({}, UI)
    self:Init()
    return self
end

return UI
