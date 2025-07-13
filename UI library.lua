--[[
    UI Library - Modern Quadrado
    Feito para fácil personalização e integração.
    Distribuição via GitHub, executável via loadstring.

    • Layout quadrado e bordas sutis
    • Controles touch-ready e drag/lock
    • Abas superiores, categorias, features
    • Configuração completa: presets, cores, temas, fonte
]]

local UI = {}
UI.__index = UI

local UserConfig = {
    font = "Arial",
    color = Color3.fromRGB(20, 20, 20),
    theme = "Claro",
    preset = "Padrão",
    saved = {},
}

-- Utilidades
local function create(instance, props)
    local obj = Instance.new(instance)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

local function roundRect(parent, size, position, color, border)
    return create("Frame", {
        Parent = parent,
        Size = size,
        Position = position,
        BackgroundColor3 = color,
        BorderSizePixel = border or 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        CornerRadius = UDim.new(0, 8)
    })
end

-- Tema e fonte
local Themes = {
    ["Claro"] = {bg = Color3.fromRGB(245,245,245), border = Color3.fromRGB(200,200,200)},
    ["Escuro"] = {bg = Color3.fromRGB(34,34,34), border = Color3.fromRGB(80,80,80)},
}
local Fonts = {
    ["Arial"] = Enum.Font.Arial,
    ["Gotham"] = Enum.Font.Gotham,
    ["SciFi"] = Enum.Font.SciFi,
    ["SourceSans"] = Enum.Font.SourceSans,
}

function UI:ApplyTheme()
    local t = Themes[UserConfig.theme] or Themes["Claro"]
    self.Main.BackgroundColor3 = t.bg
    self.Main.BorderColor3 = t.border
end

function UI:ApplyFont()
    for _,label in ipairs(self.FontLabels) do
        label.Font = Fonts[UserConfig.font] or Fonts["Arial"]
        label.TextColor3 = UserConfig.color
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
    UserConfig.font = "Arial"
    UserConfig.color = Color3.fromRGB(20,20,20)
    UserConfig.theme = "Claro"
    UserConfig.preset = "Padrão"
    self:ApplyTheme()
    self:ApplyFont()
end

-- Menu Toggle e Lock/Unlock
function UI:CreateMenuToggle()
    local toggleBtn = create("TextButton", {
        Parent = self.Screen,
        Size = UDim2.new(0,40,0,40),
        Position = UDim2.new(0,10,0,10),
        Text = "☰",
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        BackgroundColor3 = Color3.fromRGB(240,240,240),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        AutoButtonColor = true,
        ZIndex = 10,
    })
    toggleBtn.MouseButton1Click:Connect(function()
        self.Main.Visible = not self.Main.Visible
    end)
end

function UI:CreateLockToggle()
    local lockBtn = create("TextButton", {
        Parent = self.Screen,
        Size = UDim2.new(0,40,0,40),
        Position = UDim2.new(0,10,0,60),
        Text = "🔒",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundColor3 = Color3.fromRGB(240,240,240),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        AutoButtonColor = true,
        ZIndex = 10,
    })
    local locked = true
    lockBtn.MouseButton1Click:Connect(function()
        locked = not locked
        lockBtn.Text = locked and "🔒" or "🔓"
        self.Main.Active = not locked
        self.Main.Draggable = not locked
    end)
end

-- Tabs & Categorias
function UI:AddTab(tabName)
    local tabBtn = create("TextButton", {
        Parent = self.TabBar,
        Size = UDim2.new(0,120,1,0),
        Position = UDim2.new(#self.Tabs * 0.12, 0, 0, 0),
        Text = tabName,
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(230,230,230),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        AutoButtonColor = true,
        ZIndex = 2,
    })
    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do t.Frame.Visible = false end
        self.Tabs[tabName].Frame.Visible = true
    end)
    local tabFrame = create("Frame", {
        Parent = self.Main,
        Size = UDim2.new(1,-20,1,-60),
        Position = UDim2.new(0,10,0,50),
        BackgroundTransparency = 1,
        Visible = #self.Tabs == 0,
        ZIndex = 1,
    })
    self.Tabs[tabName] = {Frame = tabFrame, Btn = tabBtn, Categories = {}}
end

function UI:AddCategory(tabName, catName)
    local tab = self.Tabs[tabName]
    assert(tab, "Tab não existe")
    local catFrame = create("Frame", {
        Parent = tab.Frame,
        Size = UDim2.new(0,220,0,220),
        Position = UDim2.new(0,#tab.Categories*0.24,0,0),
        BackgroundColor3 = Color3.fromRGB(240,240,240),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 1,
    })
    local catLabel = create("TextLabel", {
        Parent = catFrame,
        Size = UDim2.new(1,0,0,28),
        Position = UDim2.new(0,0,0,0),
        Text = catName,
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
    })
    table.insert(self.FontLabels, catLabel)
    tab.Categories[catName] = {Frame = catFrame}
end

-- Features
function UI:AddToggle(tabName, catName, featureName, default, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local frame = create("Frame", {
        Parent = cat.Frame,
        Size = UDim2.new(0,200,0,40),
        Position = UDim2.new(0,10,0,40 + (#cat.Frame:GetChildren()-2)*45),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 1,
    })
    local toggleBtn = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0,36,1,0),
        Position = UDim2.new(0,2,0,0),
        Text = default and "■" or "□",
        Font = Fonts[UserConfig.font],
        TextSize = 22,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
    })
    local label = create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1,-40,1,0),
        Position = UDim2.new(0,38,0,0),
        Text = featureName,
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
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
    local frame = create("Frame", {
        Parent = cat.Frame,
        Size = UDim2.new(0,200,0,40),
        Position = UDim2.new(0,10,0,40 + (#cat.Frame:GetChildren()-2)*45),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 1,
    })
    local slider = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,2,0,0),
        Text = ("[%s%s%s: %d%s%s]"):format(
            string.rep("=", math.floor((default-min)/(max-min)*10)),
            "=", featureName, default, string.rep("=", math.floor((max-default)/(max-min)*10)), "="
        ),
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
    })
    table.insert(self.FontLabels, slider)
    slider.MouseButton1Click:Connect(function()
        -- Touch: abre popup para input ou slide, simplificado no exemplo
        local val = math.random(min,max) -- Simula
        slider.Text = ("[%s%s%s: %d%s%s]"):format(
            string.rep("=", math.floor((val-min)/(max-min)*10)),
            "=", featureName, val, string.rep("=", math.floor((max-val)/(max-min)*10)), "="
        )
        if callback then callback(val) end
    end)
end

function UI:AddDropdown(tabName, catName, featureName, options, default, callback)
    local cat = self.Tabs[tabName].Categories[catName]
    local frame = create("Frame", {
        Parent = cat.Frame,
        Size = UDim2.new(0,200,0,40),
        Position = UDim2.new(0,10,0,40 + (#cat.Frame:GetChildren()-2)*45),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 1,
    })
    local dropdown = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        Text = featureName.." +",
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
    })
    table.insert(self.FontLabels, dropdown)
    local opened = false
    dropdown.MouseButton1Click:Connect(function()
        opened = not opened
        dropdown.Text = featureName..(opened and " -" or " +")
        if opened then
            -- Show options UI (simplificado)
            for i,op in ipairs(options) do
                local optBtn = create("TextButton", {
                    Parent = frame,
                    Size = UDim2.new(1,0,0,30),
                    Position = UDim2.new(0,0,0,40+i*32),
                    Text = op,
                    Font = Fonts[UserConfig.font],
                    TextSize = 16,
                    BackgroundColor3 = Color3.fromRGB(245,245,245),
                    BorderSizePixel = 1,
                    BorderColor3 = Color3.fromRGB(200,200,200),
                    ZIndex = 3,
                })
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
    -- Igual ao dropdown, mas permite múltiplas escolhas
    -- Simplificado para exemplo
    local cat = self.Tabs[tabName].Categories[catName]
    local frame = create("Frame", {
        Parent = cat.Frame,
        Size = UDim2.new(0,200,0,40),
        Position = UDim2.new(0,10,0,40 + (#cat.Frame:GetChildren()-2)*45),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 1,
    })
    local dropdown = create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        Text = featureName.." +",
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
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
                    Size = UDim2.new(1,0,0,30),
                    Position = UDim2.new(0,0,0,40+i*32),
                    Text = (selected[op] and "■ " or "□ ")..op,
                    Font = Fonts[UserConfig.font],
                    TextSize = 16,
                    BackgroundColor3 = Color3.fromRGB(245,245,245),
                    BorderSizePixel = 1,
                    BorderColor3 = Color3.fromRGB(200,200,200),
                    ZIndex = 3,
                })
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
    local label = create("TextLabel", {
        Parent = cat.Frame,
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 40 + (#cat.Frame:GetChildren()-2)*45),
        Text = text,
        Font = Fonts[UserConfig.font],
        TextSize = 16,
        BackgroundTransparency = 1,
        TextColor3 = UserConfig.color,
        ZIndex = 2,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    table.insert(self.FontLabels, label)
end

-- Configuração Tab
function UI:SetupConfigTab()
    self:AddTab("Configuração")
    local catName = "Opções"
    self:AddCategory("Configuração", catName)
    self:AddLabel("Configuração", catName, "Salve, carregue ou resete suas configs:")
    self:AddDropdown("Configuração", catName, "Preset", {"Padrão","Gamer","Minimalista"}, "Padrão", function(opt)
        UserConfig.preset = opt
    end)
    self:AddDropdown("Configuração", catName, "Tema", {"Claro","Escuro"}, "Claro", function(opt)
        UserConfig.theme = opt
        self:ApplyTheme()
    end)
    self:AddDropdown("Configuração", catName, "Fonte", {"Arial","Gotham","SciFi","SourceSans"}, "Arial", function(opt)
        UserConfig.font = opt
        self:ApplyFont()
    end)
    self:AddSlider("Configuração", catName, "Cor da Fonte", 0,255,20, function(val)
        UserConfig.color = Color3.fromRGB(val,val,val)
        self:ApplyFont()
    end)
    self:AddToggle("Configuração", catName, "Salvar Configuração", false, function()
        self:SaveConfig(UserConfig.preset)
    end)
    self:AddToggle("Configuração", catName, "Carregar Configuração", false, function()
        self:LoadConfig(UserConfig.preset)
    end)
    self:AddToggle("Configuração", catName, "Resetar Configuração", false, function()
        self:ResetConfig()
    end)
end

-- Inicialização
function UI:Init()
    self.Screen = Instance.new("ScreenGui")
    self.Screen.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    self.Main = create("Frame", {
        Parent = self.Screen,
        Size = UDim2.new(0,600,0,400),
        Position = UDim2.new(0.5,-300,0.5,-200),
        BackgroundColor3 = Themes[UserConfig.theme].bg,
        BorderSizePixel = 1,
        BorderColor3 = Themes[UserConfig.theme].border,
        Active = false,
        Draggable = false,
        Visible = true,
        ZIndex = 1,
    })

    self.TabBar = create("Frame", {
        Parent = self.Main,
        Size = UDim2.new(1,-20,0,40),
        Position = UDim2.new(0,10,0,10),
        BackgroundColor3 = Color3.fromRGB(235,235,235),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(200,200,200),
        ZIndex = 2,
    })

    self.Tabs = {}
    self.FontLabels = {}

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
