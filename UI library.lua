--[[
UI LIBRARY
Modern, customizable square menu UI for Lua (Roblox/Delta & similar environments)
by DH-SOARESE

Features:
- Easy customization via config
- Config tab: Save/Load/Reset/Presets, Font Color, Theme, Font Style
- Tabs, categories, organized features (toggle, slider, dropdown, multi-dropdown, label)
- Square, modern, touch-friendly, draggable/unlock
- Designed for loadstring use, e.g. loadstring(game:HttpGet("..."))()

USAGE:
local ui = loadstring(game:HttpGet("https://github.com/youruser/uilibrary.lua?raw=true"))()
ui:Open()
-- see bottom for API
]]

local UI = {}
UI.__index = UI

--[[--------- CONFIG -----------]]
local DEFAULT_CONFIG = {
    Theme = "Light",
    FontColor = Color3.fromRGB(30,30,30),
    Font = Enum.Font.Gotham,
    Style = "Square",
    Tab = "Main",
    Preset = "Default",
}
local THEMES = {
    Light = {
        BG = Color3.fromRGB(245,245,245),
        Border = Color3.fromRGB(210,210,210),
        Accent = Color3.fromRGB(30,144,255),
        FontColor = Color3.fromRGB(30,30,30),
    },
    Dark = {
        BG = Color3.fromRGB(25,25,25),
        Border = Color3.fromRGB(50,50,50),
        Accent = Color3.fromRGB(0,160,255),
        FontColor = Color3.fromRGB(240,240,240),
    }
}
local FONTS = {Enum.Font.Gotham, Enum.Font.SourceSans, Enum.Font.Code, Enum.Font.Arial}
local PRESETS = {
    Default = DEFAULT_CONFIG,
    Vibrant = {
        Theme="Light", FontColor=Color3.fromRGB(200,40,60), Font=Enum.Font.Gotham, Style="Square"
    },
    Midnight = {
        Theme="Dark", FontColor=Color3.fromRGB(180,220,255), Font=Enum.Font.Code, Style="Square"
    }
}

--[[------ UTILITIES -------]]
local function clone(t)
    local n = {}; for k,v in pairs(t) do if typeof(v)=="table" then n[k]=clone(v) else n[k]=v end end; return n
end
local function deepCopy(t) return clone(t) end
local function deepMerge(a,b)
    local r = clone(a)
    for k,v in pairs(b) do
        if typeof(v)=="table" and typeof(r[k])=="table" then r[k]=deepMerge(r[k],v)
        else r[k]=v end
    end
    return r
end
local function serializeColor3(c)
    return {c.r*255, c.g*255, c.b*255}
end
local function unserializeColor3(t)
    return Color3.fromRGB(unpack(t))
end

--[[------ UI CONSTRUCTION -------]]
local function create(class, props, children)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k]=v end
    for _,child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

local function makeDraggable(frame, dragToggle)
    -- Frame can be dragged if dragToggle.Value==true
    -- Touch + Mouse support
    local uis = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if dragToggle.Value and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

--[[------ MAIN LIBRARY -------]]
function UI.new(opts)
    local self = setmetatable({}, UI)
    self.ScreenGui = create("ScreenGui", {Name="UILibraryMain", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global})
    self.Config = deepCopy(DEFAULT_CONFIG)
    self.UserConfig = {}
    self.Presets = PRESETS
    self.Tabs = {}
    self.Categories = {}
    self.Features = {}
    self.Theme = THEMES[self.Config.Theme]
    self.Font = self.Config.Font
    self.FontColor = self.Config.FontColor
    self.MenuOpen = false
    self.MenuLocked = false

    -- Build main UI
    self:BuildUI()
    self:AddConfigTab()
    self:ApplyTheme()
    self:SaveConfig("Default") -- default

    return self
end

function UI:BuildUI()
    -- Main Toggle (left side, always visible)
    self.ToggleBtn = create("TextButton", {
        Name="MainToggle", Text="☰", Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,12,0,12),
        AnchorPoint=Vector2.new(0,0), BackgroundTransparency=0, TextSize=22, ZIndex=1000,
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, TextColor3=self.Theme.Accent, Font=self.Font,
        AutoButtonColor=true, Parent=self.ScreenGui
    })
    self.ToggleBtn.MouseButton1Click:Connect(function()
        self:ToggleMenu()
    end)

    -- Menu Frame
    self.MenuFrame = create("Frame", {
        Name="MainMenu", Size=UDim2.new(0,500,0,420), Position=UDim2.new(0,60,0,30),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BackgroundTransparency=0,
        Visible=false, ZIndex=1010, ClipsDescendants=true, Parent=self.ScreenGui
    })

    -- Menu Title
    self.MenuTitle = create("TextLabel", {
        Name="MenuTitle", Text="Menu Título", Size=UDim2.new(1,0,0,36), Position=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, TextSize=22, TextColor3=self.FontColor, Font=self.Font, ZIndex=1011
    }, {})
    self.MenuTitle.Parent = self.MenuFrame

    -- Lock/Unlock toggle
    self.LockToggle = create("TextButton", {
        Name="LockToggle", Text="🔓", Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,40,0,0),
        BackgroundTransparency=1, TextSize=20, TextColor3=self.Theme.Accent, Font=self.Font, ZIndex=1012, Parent=self.MenuFrame
    })
    self.LockToggle.MouseButton1Click:Connect(function()
        self.MenuLocked = not self.MenuLocked
        self.LockToggle.Text = self.MenuLocked and "🔒" or "🔓"
    end)

    -- Tabs bar
    self.TabsFrame = create("Frame", {
        Name="TabsBar", Size=UDim2.new(1, -10, 0, 40), Position=UDim2.new(0, 5, 0, 38),
        BackgroundTransparency=1, ZIndex=1015, Parent=self.MenuFrame
    })

    -- Tab buttons will be parented here
    self.TabButtons = {}

    -- Main content area
    self.ContentFrame = create("Frame", {
        Name="ContentFrame", Size=UDim2.new(1, -30, 1, -90), Position=UDim2.new(0, 15, 0, 80),
        BackgroundTransparency=1, ZIndex=1018, Parent=self.MenuFrame
    })

    -- Draggable
    local dragToggle = Instance.new("BoolValue")
    dragToggle.Value = not self.MenuLocked
    self.LockToggle.MouseButton1Click:Connect(function()
        dragToggle.Value = not self.MenuLocked
    end)
    makeDraggable(self.MenuFrame, dragToggle)

    self.ScreenGui.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer.PlayerGui
end

function UI:ToggleMenu()
    self.MenuOpen = not self.MenuOpen
    self.MenuFrame.Visible = self.MenuOpen
end

function UI:AddTab(tabName)
    if self.Tabs[tabName] then return self.Tabs[tabName] end
    local btn = create("TextButton", {
        Name="Tab_"..tabName, Text=tabName, Size=UDim2.new(0,120,0,38),
        Position=UDim2.new(0,#self.TabButtons*122,0,0),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=19, ZIndex=1016, Parent=self.TabsFrame,
        AutoButtonColor=true,
    })
    local tab = {Name=tabName, Button=btn, Categories={}}
    table.insert(self.TabButtons, btn)
    self.Tabs[tabName] = tab

    btn.MouseButton1Click:Connect(function()
        self:ShowTab(tabName)
    end)
    if #self.TabButtons == 1 then
        self:ShowTab(tabName)
    end
    return tab
end

function UI:ShowTab(tabName)
    for name,tab in pairs(self.Tabs) do
        tab.Button.BackgroundColor3 = (name==tabName) and self.Theme.Border or self.Theme.BG
        if tab.ContentFrame then tab.ContentFrame.Visible = (name==tabName) end
    end
    self.Config.Tab = tabName
end

function UI:AddCategory(tabName, catName)
    local tab = self:AddTab(tabName)
    if tab.Categories[catName] then return tab.Categories[catName] end
    -- Make content frame if not exists
    if not tab.ContentFrame then
        tab.ContentFrame = create("Frame", {
            Name="TabContent_"..tabName, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,0,0,0),
            BackgroundTransparency=1, ZIndex=1020, Visible=false, Parent=self.ContentFrame
        })
    end
    local catFrame = create("Frame", {
        Name="Category_"..catName, Size=UDim2.new(0.5,-12,0,170),
        Position=UDim2.new( (#tab.Categories)%2==0 and 0 or 0.51, 6, 0, 38 + math.floor(#tab.Categories/2)*182 ),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        BackgroundTransparency=0, ZIndex=1021, Parent=tab.ContentFrame
    })
    -- Category Title
    local catTitle = create("TextLabel", {
        Name="CatTitle", Text=catName, Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=0,
        TextColor3=self.FontColor, Font=self.Font, TextSize=17, ZIndex=1022, BackgroundTransparency=0.1
    }, {})
    catTitle.Parent = catFrame

    tab.Categories[catName] = {Name=catName, Frame=catFrame, Features={}}
    return tab.Categories[catName]
end

-- Feature Controls
function UI:AddToggle(tabName, catName, name, default, callback)
    local cat = self:AddCategory(tabName, catName)
    local y = 36 + #cat.Features*36
    local box = create("TextButton", {
        Name=name.."Toggle", Text=default and "■ "..name or "□ "..name,
        Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1023, AutoButtonColor=true,
    })
    local state = default
    box.MouseButton1Click:Connect(function()
        state = not state
        box.Text = state and "■ "..name or "□ "..name
        if callback then callback(state) end
    end)
    box.Parent = cat.Frame
    table.insert(cat.Features, box)
    return box
end

function UI:AddSlider(tabName, catName, name, min, max, default, callback)
    local cat = self:AddCategory(tabName, catName)
    local y = 36 + #cat.Features*36
    local sliderFrame = create("Frame", {
        Name=name.."Slider", Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y),
        BackgroundTransparency=1, ZIndex=1024,
    })
    local value = default or min
    local label = create("TextLabel", {
        Text = name.." "..tostring(value),
        Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1025
    })
    local bar = create("Frame", {
        Size=UDim2.new(0.5,-8,0,18), Position=UDim2.new(0.5,4,0,7),
        BackgroundColor3=self.Theme.Border, BorderSizePixel=0, ZIndex=1026
    })
    local fill = create("Frame", {
        Size=UDim2.new((value-min)/(max-min),0,1,0), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=self.Theme.Accent, BorderSizePixel=0, ZIndex=1027
    })
    fill.Parent = bar
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if dragging then
            local x = (input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X
            x = math.clamp(x,0,1)
            value = math.floor((min + (max-min)*x)+0.5)
            fill.Size = UDim2.new(x,0,1,0)
            label.Text = name.." "..tostring(value)
            if callback then callback(value) end
        end
    end)
    sliderFrame.Parent = cat.Frame
    label.Parent = sliderFrame
    bar.Parent = sliderFrame
    table.insert(cat.Features, sliderFrame)
    return sliderFrame
end

function UI:AddDropdown(tabName, catName, name, options, default, callback, multi)
    local cat = self:AddCategory(tabName, catName)
    local y = 36 + #cat.Features*36
    local selected = multi and {} or (default or options[1])
    local open = false
    local btn = create("TextButton", {
        Name=name.."Dropdown", Text=name.." +", Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1028, AutoButtonColor=true,
    })
    local dropFrame = create("Frame", {
        Name="DropFrame", Size=UDim2.new(1,0,0, math.min(32*#options,160)), Position=UDim2.new(0,0,1,0),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1, Visible=false, ZIndex=1029,
        Parent=btn
    })
    local optionButtons = {}
    local function refreshText()
        if multi then
            local t = {}
            for _,v in ipairs(options) do if selected[v] then table.insert(t,v) end end
            btn.Text = name.." "..(open and "-" or "+").." ["..table.concat(t,",").."]"
        else
            btn.Text = name.." "..(open and "-" or "+").." ["..tostring(selected).."]"
        end
    end
    for i,opt in ipairs(options) do
        local obtn = create("TextButton", {
            Name="Opt_"..opt, Text=opt, Size=UDim2.new(1,0,0,32), Position=UDim2.new(0,0,0,(i-1)*32),
            BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=0,
            TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1030, AutoButtonColor=true,
        })
        obtn.MouseButton1Click:Connect(function()
            if multi then
                selected[opt] = not selected[opt]
                refreshText()
                if callback then callback(selected) end
            else
                selected = opt
                dropFrame.Visible = false
                open = false
                refreshText()
                if callback then callback(selected) end
            end
        end)
        obtn.Parent = dropFrame
        table.insert(optionButtons, obtn)
    end
    btn.MouseButton1Click:Connect(function()
        open = not open
        dropFrame.Visible = open
        refreshText()
    end)
    btn.Parent = cat.Frame
    table.insert(cat.Features, btn)
    return btn
end

function UI:AddLabel(tabName, catName, text)
    local cat = self:AddCategory(tabName, catName)
    local y = 36 + #cat.Features*36
    local lbl = create("TextLabel", {
        Name="Label_"..text, Text=text, Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y),
        BackgroundTransparency=1, TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1031
    })
    lbl.Parent = cat.Frame
    table.insert(cat.Features, lbl)
    return lbl
end

--[[----- CONFIG TAB -------]]
function UI:AddConfigTab()
    local tab = self:AddTab("Configuração")
    local cat = self:AddCategory("Configuração", "Geral")
    local y = 36

    -- Save
    local saveBtn = create("TextButton", {
        Text="Salvar Configuração", Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1041, AutoButtonColor=true,
    })
    saveBtn.MouseButton1Click:Connect(function()
        self:SaveConfig(self.Config.Preset)
    end)
    saveBtn.Parent = cat.Frame

    -- Load
    local loadBtn = create("TextButton", {
        Text="Carregar Configuração", Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y+36),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1042, AutoButtonColor=true,
    })
    loadBtn.MouseButton1Click:Connect(function()
        self:LoadConfig(self.Config.Preset)
    end)
    loadBtn.Parent = cat.Frame

    -- Reset
    local resetBtn = create("TextButton", {
        Text="Resetar para Padrão", Size=UDim2.new(1,-18,0,32), Position=UDim2.new(0,9,0,y+36*2),
        BackgroundColor3=self.Theme.BG, BorderColor3=self.Theme.Border, BorderSizePixel=1,
        TextColor3=self.FontColor, Font=self.Font, TextSize=16, ZIndex=1043, AutoButtonColor=true,
    })
    resetBtn.MouseButton1Click:Connect(function()
        self:ResetConfig()
    end)
    resetBtn.Parent = cat.Frame

    -- Preset dropdown
    local presetBtn = self:AddDropdown("Configuração", "Geral", "Preset", (function() local t = {}; for k,_ in pairs(self.Presets) do table.insert(t,k) end; return t end)(), "Default", function(val)
        self.Config.Preset = (type(val)=="table" and next(val)) or val
    end, false)
    presetBtn.Position = UDim2.new(0,9,0,y+36*3)

    -- Font color picker (simulate via dropdown)
    local colorOpts = {"Preto","Vermelho","Verde","Azul","Roxo","Laranja"}
    local colorMap = {
        ["Preto"]=Color3.fromRGB(30,30,30), ["Vermelho"]=Color3.fromRGB(200,30,60),
        ["Verde"]=Color3.fromRGB(60,180,60), ["Azul"]=Color3.fromRGB(40,120,255),
        ["Roxo"]=Color3.fromRGB(120,60,180), ["Laranja"]=Color3.fromRGB(255,170,40)
    }
    local colorBtn = self:AddDropdown("Configuração", "Geral", "Cor da Fonte", colorOpts, "Preto", function(val)
        self.Config.FontColor = colorMap[val]
        self:ApplyTheme()
    end, false)
    colorBtn.Position = UDim2.new(0,9,0,y+36*4)

    -- Theme dropdown
    local themeBtn = self:AddDropdown("Configuração", "Geral", "Tema", {"Light","Dark"}, "Light", function(val)
        self.Config.Theme = val
        self:ApplyTheme()
    end, false)
    themeBtn.Position = UDim2.new(0,9,0,y+36*5)

    -- Font style dropdown
    local fontBtn = self:AddDropdown("Configuração", "Geral", "Fonte", {"Gotham","SourceSans","Code","Arial"}, "Gotham", function(val)
        local fontMap = {Gotham=Enum.Font.Gotham,SourceSans=Enum.Font.SourceSans,Code=Enum.Font.Code,Arial=Enum.Font.Arial}
        self.Config.Font = fontMap[val]
        self:ApplyTheme()
    end, false)
    fontBtn.Position = UDim2.new(0,9,0,y+36*6)
end

function UI:ApplyTheme()
    self.Theme = THEMES[self.Config.Theme]
    self.Font = self.Config.Font
    self.FontColor = self.Config.FontColor
    -- Update all UI colors/fonts
    local function update(inst)
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            inst.Font = self.Font
            inst.TextColor3 = self.FontColor
        end
        if inst:IsA("Frame") or inst:IsA("TextButton") then
            inst.BackgroundColor3 = self.Theme.BG
            inst.BorderColor3 = self.Theme.Border
        end
        for _,child in ipairs(inst:GetChildren()) do update(child) end
    end
    update(self.MenuFrame)
    self.ToggleBtn.TextColor3 = self.Theme.Accent
    self.LockToggle.TextColor3 = self.Theme.Accent
end

function UI:SaveConfig(name)
    name = name or "Default"
    self.UserConfig[name] = deepCopy(self.Config)
end

function UI:LoadConfig(name)
    name = name or "Default"
    if self.UserConfig[name] then
        self.Config = deepCopy(self.UserConfig[name])
        self:ApplyTheme()
    end
end

function UI:ResetConfig()
    self.Config = deepCopy(DEFAULT_CONFIG)
    self:ApplyTheme()
end

--[[----- PUBLIC API ------]]
function UI:Open() self.MenuOpen = true self.MenuFrame.Visible=true end
function UI:Close() self.MenuOpen = false self.MenuFrame.Visible=false end

--[[----- EXAMPLE USAGE ------
local ui = loadstring(game:HttpGet("https://github.com/youruser/uilibrary.lua?raw=true"))()
ui:AddTab("Jogador")
ui:AddCategory("Jogador","Movimento")
ui:AddToggle("Jogador","Movimento","Super Pulo",false,function(on) print("Super Pulo:",on) end)
ui:AddSlider("Jogador","Movimento","Velocidade",0,100,50,function(val) print("Velocidade:",val) end)
ui:AddDropdown("Jogador","Movimento","Estilo",{"Normal","Parkour","Ninja"},"Normal",function(val) print("Estilo:",val) end)
ui:AddDropdown("Jogador","Movimento","Itens",{"Espada","Escudo","Poção"},{} ,function(val) print("Itens:",val) end,true)
ui:AddLabel("Jogador","Movimento","Upgrades disponíveis")
ui:Open()
---------------------------]]

return setmetatable({
    new = function(...) return UI.new(...) end
},{
    __call = function(_,...) return UI.new(...) end
})
