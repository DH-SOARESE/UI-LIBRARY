--[[
MSHUB-Inspired UI Library for Roblox (DOORS-ready, Mobile Compatible)

Author: DH-SOARESE
License: MIT
Repo: https://github.com/<your-repo>/<your-library>

Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/<your-repo>/<your-library>/main/lua_ui_library.lua"))()

Features:
- Modern, square, minimal UI
- Tabs, categories, and features (Toggle, Slider, Dropdown, etc.)
- Always-accessible Config tab
- Preset management, theme/font adjustments
- Lock/Unlock & Show/Hide menu controls (now external!)
- 100% Mobile-friendly (touch, drag, tap, click)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LIBRARY_VERSION = "1.0.0"

local DEFAULT_THEME = {
    Background        = Color3.fromRGB(24,24,28),
    TabBar            = Color3.fromRGB(32,32,36),
    TabActive         = Color3.fromRGB(48, 98, 255),
    TabInactive       = Color3.fromRGB(40,40,44),
    Category          = Color3.fromRGB(30,30,32),
    CategoryBorder    = Color3.fromRGB(60,60,70),
    Element           = Color3.fromRGB(45,45,52),
    ElementBorder     = Color3.fromRGB(66,66,76),
    Text              = Color3.fromRGB(240,240,247),
    TextInactive      = Color3.fromRGB(160,160,168),
    ToggleOn          = Color3.fromRGB(48, 98, 255),
    ToggleOff         = Color3.fromRGB(60,60,72),
    SliderBar         = Color3.fromRGB(38,72,180),
    SliderBG          = Color3.fromRGB(44,44,55),
    DropdownBG        = Color3.fromRGB(38,44,55),
    DropdownBorder    = Color3.fromRGB(60,60,70),
    ButtonHighlight   = Color3.fromRGB(48,98,255),
    LockOn            = Color3.fromRGB(255,40,40),
    LockOff           = Color3.fromRGB(40,255,60),
}

local DEFAULT_FONT = Enum.Font.Gotham

local Library = {}
Library.__index = Library

-- Utility: Responsive sizing
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function round(num, bracket)
    bracket = bracket or 1
    return math.floor(num/bracket + 0.5) * bracket
end

local function deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = type(v) == "table" and deepCopy(v) or v
    end
    return t
end

local function saveToLocal(key, tbl)
    pcall(function()
        if writefile then
            writefile(key..".json", HttpService:JSONEncode(tbl))
        end
    end)
end

local function loadFromLocal(key)
    pcall(function()
        if isfile and isfile(key..".json") then
            local dat = readfile(key..".json")
            return HttpService:JSONDecode(dat)
        end
    end)
    return nil
end

-- UI OBJECTS
local function create(objType, props)
    local obj = Instance.new(objType)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- MAIN UI LIBRARY CONSTRUCTOR
function Library.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Library)
    self.theme = deepCopy(DEFAULT_THEME)
    self.font = opts.Font or DEFAULT_FONT
    self.fontColor = self.theme.Text
    self.title = opts.Title or "MSHUB UI"
    self.tabs = {}
    self.tabOrder = {}
    self.selectedTab = nil
    self.presets = {}
    self.config = {}
    self.locked = false
    self.menuVisible = true
    self.mobile = isMobile()
    self.gui = nil
    self:build()
    return self
end

-- TOP-LEVEL UI BUILD
function Library:build()
    if self.gui then self.gui:Destroy() end

    -- Destroy any other instance
    if game.CoreGui:FindFirstChild("MSHUB_UI") then
        game.CoreGui.MSHUB_UI:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "MSHUB_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    self.gui = gui

    -- Main Frame
    local frame = create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = self.theme.Background,
        BorderSizePixel = 0,
        Size = self.mobile and UDim2.new(0, 340, 0, 480) or UDim2.new(0, 420, 0, 540),
        Position = UDim2.new(0.5, -210, 0.5, -270),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = true,
        Parent = gui
    })
    self.mainFrame = frame

    -- Draggable
    self:_makeDraggable(frame)

    -- External Menu Toggle & Lock
    self:_buildExternalMenuToggle(gui)
    self:_buildExternalLockToggle(gui)

    -- Tabs Bar
    local tabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.theme.TabBar,
        BorderSizePixel = 0,
        Parent = frame
    })
    self.tabBar = tabBar

    -- Tab Buttons (dynamic)
    self.tabBtnHolder = create("Frame", {
        Name = "TabBtnHolder",
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Parent = tabBar
    })

    -- Tabs Content Holder
    self.tabContentHolder = create("Frame", {
        Name = "TabContentHolder",
        Size = UDim2.new(1, -0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = frame
    })

    -- Tabs ListLayout
    local tabList = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.tabBtnHolder
    })

    -- Register default Config tab (always last)
    self:addTab("Configuração", true)

    -- Hide/Show hotkey: [RightShift]
    self:_bindHotkey()
end

-- DRAGGABLE
function Library:_makeDraggable(frame)
    local dragToggle, dragInput, dragStart, startPos
    frame.Active = true

    local function update(input)
        if not self.locked then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frame.Position.X.Scale, frame.Position.X.Offset + delta.X,
                frame.Position.Y.Scale, frame.Position.Y.Offset + delta.Y
            )
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or (self.mobile and input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or (self.mobile and input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            update(input)
        end
    end)
end

-- EXTERNAL MENU TOGGLE BUTTON (Show/Hide)
function Library:_buildExternalMenuToggle(gui)
    local btn = create("TextButton", {
        Name = "MenuToggleExternal",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 10, 0, 10), -- Top-left of screen
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Text = self.menuVisible and "H" or "S", -- H for Hide, S for Show
        Font = self.font,
        TextColor3 = self.theme.Text,
        TextSize = 24,
        ZIndex = 5, -- Ensure it's always on top
        Parent = gui
    })
    btn.MouseButton1Click:Connect(function()
        self.menuVisible = not self.menuVisible
        self.mainFrame.Visible = self.menuVisible
        btn.Text = self.menuVisible and "H" or "S"
    end)
    self.menuToggleButton = btn -- Store reference for hotkey update
end

-- EXTERNAL LOCK/UNLOCK BUTTON
function Library:_buildExternalLockToggle(gui)
    local btn = create("TextButton", {
        Name = "LockToggleExternal",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 10, 0, 50), -- Below the menu toggle
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Text = self.locked and "🔒" or "🔓",
        Font = self.font,
        TextColor3 = self.locked and self.theme.LockOn or self.theme.LockOff,
        TextSize = 22,
        ZIndex = 5, -- Ensure it's always on top
        Parent = gui
    })
    btn.MouseButton1Click:Connect(function()
        self.locked = not self.locked
        btn.Text = self.locked and "🔒" or "🔓"
        btn.TextColor3 = self.locked and self.theme.LockOn or self.theme.LockOff
    end)
    self.lockToggleButton = btn -- Store reference for hotkey update
end


-- TABS
function Library:addTab(name, isConfig)
    isConfig = isConfig or false
    if self.tabs[name] then return self.tabs[name] end

    -- Tab content frame
    local tabContent = create("Frame", {
        Name = "Tab_"..name,
        Visible = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Parent = self.tabContentHolder
    })

    -- Tab button
    local tabBtn = create("TextButton", {
        Name = "TabBtn_"..name,
        Text = name,
        Font = self.font,
        TextSize = 18,
        TextColor3 = self.theme.TextInactive,
        BackgroundColor3 = isConfig and self.theme.TabActive or self.theme.TabInactive,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 92, 1, 0),
        LayoutOrder = isConfig and 999 or (#self.tabOrder+1),
        Parent = self.tabBtnHolder
    })

    -- Tab select
    tabBtn.MouseButton1Click:Connect(function()
        self:selectTab(name)
    end)

    -- Record
    self.tabs[name] = {frame = tabContent, btn = tabBtn, categories = {}, isConfig = isConfig}
    if not isConfig then
        table.insert(self.tabOrder, name)
    end

    -- Config tab always at end
    if isConfig then
        tabBtn.LayoutOrder = 999
    end

    -- First tab auto-select
    if not self.selectedTab or isConfig then
        self:selectTab(name)
    end

    return self.tabs[name]
end

function Library:selectTab(name)
    for tabName, tab in pairs(self.tabs) do
        tab.frame.Visible = (tabName == name)
        tab.btn.BackgroundColor3 = tab.isConfig and self.theme.TabActive or (tabName == name and self.theme.TabActive or self.theme.TabInactive)
        tab.btn.TextColor3 = tabName == name and self.theme.Text or self.theme.TextInactive
    end
    self.selectedTab = name
end

-- CATEGORY
function Library:addCategory(tabName, catName)
    assert(self.tabs[tabName], "Tab does not exist: "..tabName)
    local tab = self.tabs[tabName]

    local cat = create("Frame", {
        Name = "Category_"..catName,
        Size = UDim2.new(1, -16, 0, 88),
        BackgroundColor3 = self.theme.Category,
        BorderColor3 = self.theme.CategoryBorder,
        BorderSizePixel = 1,
        Position = UDim2.new(0,8,0, #tab.categories*96 + 12),
        Parent = tab.frame
    })
    local catTitle = create("TextLabel", {
        Name = "CatTitle",
        Text = catName,
        Font = self.font,
        TextSize = 16,
        TextColor3 = self.theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 22),
        Position = UDim2.new(0, 6, 0, 4),
        Parent = cat
    })
    tab.categories[catName] = cat
    return cat
end

-- FEATURE CONTROLS
function Library:addToggle(tabName, catName, params)
    local cat = self.tabs[tabName].categories[catName]
    local toggle = create("TextButton", {
        Name = "Toggle_"..params.Name,
        Size = UDim2.new(0, 108, 0, 38),
        Position = UDim2.new(0, 8 + ((#cat:GetChildren()-1)*116), 0, 30),
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Text = params.Default and "■ "..params.Name or "□ "..params.Name,
        Font = self.font,
        TextColor3 = params.Default and self.theme.ToggleOn or self.theme.ToggleOff,
        TextSize = 16,
        Parent = cat
    })
    local state = params.Default or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "■ "..params.Name or "□ "..params.Name
        toggle.TextColor3 = state and self.theme.ToggleOn or self.theme.ToggleOff
        if params.Callback then params.Callback(state) end
    end)
    return toggle
end

function Library:addSlider(tabName, catName, params)
    local cat = self.tabs[tabName].categories[catName]
    local sliderFrame = create("Frame", {
        Name = "Slider_"..params.Name,
        Size = UDim2.new(0, 148, 0, 38),
        Position = UDim2.new(0, 8 + ((#cat:GetChildren()-1)*156), 0, 30),
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Parent = cat
    })
    local label = create("TextLabel", {
        Name = "SliderLabel",
        Text = params.Name,
        Font = self.font,
        TextSize = 15,
        BackgroundTransparency = 1,
        TextColor3 = self.theme.Text,
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0,6,0,0),
        Parent = sliderFrame
    })
    local sliderBar = create("Frame", {
        Name = "SliderBarBG",
        Size = UDim2.new(0, 60, 0, 6),
        Position = UDim2.new(1, -66, 0.5, -3),
        BackgroundColor3 = self.theme.SliderBG,
        BorderSizePixel = 0,
        Parent = sliderFrame
    })
    local sliderFill = create("Frame", {
        Name = "SliderFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.theme.SliderBar,
        BorderSizePixel = 0,
        Parent = sliderBar
    })
    local valueLabel = create("TextLabel", {
        Name = "SliderValue",
        Text = tostring(params.Default or params.Min or 0),
        Font = self.font,
        TextSize = 14,
        BackgroundTransparency = 1,
        TextColor3 = self.theme.Text,
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, 2, 0, 0),
        Parent = sliderBar
    })
    local min, max = params.Min or 0, params.Max or 100
    local value = params.Default or min
    local function updateSlider(px)
        local percent = math.clamp(px/60, 0, 1)
        value = round((max-min)*percent + min)
        sliderFill.Size = UDim2.new(percent,0,1,0)
        valueLabel.Text = tostring(value)
        if params.Callback then params.Callback(value) end
    end
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or (self.mobile and input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X - sliderBar.AbsolutePosition.X)
            local conn
            conn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement or (self.mobile and move.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(move.Position.X - sliderBar.AbsolutePosition.X)
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    -- Initial
    updateSlider(((value-min)/(max-min))*60)
    return sliderFrame
end

function Library:addDropdown(tabName, catName, params)
    local cat = self.tabs[tabName].categories[catName]
    local ddBtn = create("TextButton", {
        Name = "Dropdown_"..params.Name,
        Size = UDim2.new(0, 148, 0, 38),
        Position = UDim2.new(0, 8 + ((#cat:GetChildren()-1)*156), 0, 30),
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Text = "[ "..params.Name.." + ]",
        Font = self.font,
        TextColor3 = self.theme.Text,
        TextSize = 16,
        Parent = cat
    })
    local ddOpen = false
    local ddFrame
    ddBtn.MouseButton1Click:Connect(function()
        ddOpen = not ddOpen
        ddBtn.Text = ddOpen and "[ "..params.Name.." – ]" or "[ "..params.Name.." + ]"
        if not ddFrame then
            ddFrame = create("Frame", {
                Name = "DropdownList",
                Size = UDim2.new(0, 148, 0, 32*#params.Options),
                Position = UDim2.new(0, ddBtn.Position.X.Offset, 0, ddBtn.Position.Y.Offset+38),
                BackgroundColor3 = self.theme.DropdownBG,
                BorderColor3 = self.theme.DropdownBorder,
                BorderSizePixel = 1,
                Parent = cat
            })
            for i, option in ipairs(params.Options) do
                local optBtn = create("TextButton", {
                    Name = "Option_"..option,
                    Size = UDim2.new(1,0,0,32),
                    Position = UDim2.new(0,0,0,(i-1)*32),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = option,
                    Font = self.font,
                    TextColor3 = self.theme.Text,
                    TextSize = 15,
                    Parent = ddFrame
                })
                optBtn.MouseButton1Click:Connect(function()
                    ddBtn.Text = "[ "..option.." + ]"
                    if params.Callback then params.Callback(option) end
                    ddOpen = false
                    ddFrame:Destroy()
                    ddFrame = nil
                end)
            end
        elseif not ddOpen and ddFrame then
            ddFrame:Destroy()
            ddFrame = nil
        end
    end)
    return ddBtn
end

function Library:addDropdownToggle(tabName, catName, params)
    local cat = self.tabs[tabName].categories[catName]
    local ddBtn = create("TextButton", {
        Name = "DropdownToggle_"..params.Name,
        Size = UDim2.new(0, 148, 0, 38),
        Position = UDim2.new(0, 8 + ((#cat:GetChildren()-1)*156), 0, 30),
        BackgroundColor3 = self.theme.Element,
        BorderColor3 = self.theme.ElementBorder,
        BorderSizePixel = 1,
        Text = "[ "..params.Name.." + ]",
        Font = self.font,
        TextColor3 = self.theme.Text,
        TextSize = 16,
        Parent = cat
    })
    local ddOpen = false
    local ddFrame
    local selected = {}
    ddBtn.MouseButton1Click:Connect(function()
        ddOpen = not ddOpen
        ddBtn.Text = ddOpen and "[ "..params.Name.." – ]" or "[ "..params.Name.." + ]"
        if not ddFrame then
            ddFrame = create("Frame", {
                Name = "DropdownList",
                Size = UDim2.new(0, 148, 0, 32*#params.Options),
                Position = UDim2.new(0, ddBtn.Position.X.Offset, 0, ddBtn.Position.Y.Offset+38),
                BackgroundColor3 = self.theme.DropdownBG,
                BorderColor3 = self.theme.DropdownBorder,
                BorderSizePixel = 1,
                Parent = cat
            })
            for i, option in ipairs(params.Options) do
                local optBtn = create("TextButton", {
                    Name = "Option_"..option,
                    Size = UDim2.new(1,0,0,32),
                    Position = UDim2.new(0,0,0,(i-1)*32),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = "□ "..option,
                    Font = self.font,
                    TextColor3 = self.theme.Text,
                    TextSize = 15,
                    Parent = ddFrame
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected[option] = not selected[option]
                    optBtn.Text = (selected[option] and "■ " or "□ ")..option
                    if params.Callback then params.Callback(selected) end
                end)
            end
            -- Clicking outside closes
            local function closeDD()
                if ddFrame then
                    ddFrame:Destroy()
                    ddFrame = nil
                    ddOpen = false
                    ddBtn.Text = "[ "..params.Name.." + ]"
                end
            end
            -- Add an invisible overlay to detect clicks outside the dropdown
            local overlay = create("Frame", {
                Size = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                ZIndex = ddFrame.ZIndex - 1,
                Parent = ddFrame.Parent.Parent.Parent -- Correct parent to cover the whole screen
            })
            overlay.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or (self.mobile and input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = input.Position
                    local dropdownAbsolutePos = ddFrame.AbsolutePosition
                    local dropdownAbsoluteSize = ddFrame.AbsoluteSize

                    -- Check if click is outside dropdown
                    if not (mousePos.X >= dropdownAbsolutePos.X and mousePos.X <= dropdownAbsolutePos.X + dropdownAbsoluteSize.X and
                            mousePos.Y >= dropdownAbsolutePos.Y and mousePos.Y <= dropdownAbsolutePos.Y + dropdownAbsoluteSize.Y) then
                        closeDD()
                    end
                end
            end)
            ddFrame.DescendantRemoving:Connect(function(child)
                if child == ddFrame then
                    overlay:Destroy() -- Clean up overlay when dropdown is destroyed
                end
            end)
        elseif not ddOpen and ddFrame then
            ddFrame:Destroy()
            ddFrame = nil
        end
    end)
    return ddBtn
end

function Library:addLabel(tabName, catName, params)
    local cat = self.tabs[tabName].categories[catName]
    local label = create("TextLabel", {
        Name = "Label_"..params.Name,
        Size = UDim2.new(1,-24,0,22),
        Position = UDim2.new(0,8,0,30+((#cat:GetChildren()-1)*26)),
        BackgroundTransparency = 1,
        Text = params.Text or params.Name,
        Font = self.font,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = self.theme.Text,
        Parent = cat
    })
    return label
end

-- CONFIG TAB SPECIAL
function Library:_buildConfigTab()
    local tab = self.tabs["Configuração"]
    local cat = self:addCategory("Configuração","Ajustes")

    -- Save/Load/Reset
    self:addToggle("Configuração","Ajustes",{Name="Salvar Configuração", Callback=function()
        saveToLocal("MSHUB_UI_Config", self.config)
    end})
    self:addToggle("Configuração","Ajustes",{Name="Carregar Configuração", Callback=function()
        local loaded = loadFromLocal("MSHUB_UI_Config")
        if loaded then
            self.config = loaded
            -- Optionally: Apply config
        end
    end})
    self:addToggle("Configuração","Ajustes",{Name="Resetar para Padrão", Callback=function()
        self.config = {}
        -- Optionally: Reset all
    end})
    -- Presets
    self:addDropdown("Configuração","Ajustes",{Name="Presets", Options={"Default"}, Callback=function(preset)
        -- Load preset
    end})
    -- Font color
    self:addDropdown("Configuração","Ajustes",{Name="Cor da Fonte", Options={"Branco","Azul","Verde","Roxo"}, Callback=function(option)
        local colors = {
            ["Branco"] = Color3.fromRGB(240,240,247),
            ["Azul"] = Color3.fromRGB(48, 98, 255),
            ["Verde"] = Color3.fromRGB(40,255,60),
            ["Roxo"] = Color3.fromRGB(160,60,255),
        }
        self.fontColor = colors[option] or self.theme.Text
        for _,tab_data in pairs(self.tabs) do
            for _,cat_frame in pairs(tab_data.categories) do
                for _,elem in pairs(cat_frame:GetChildren()) do
                    if elem:IsA("TextLabel") or elem:IsA("TextButton") then
                        elem.TextColor3 = self.fontColor
                    end
                end
            end
        end
        -- Also update external toggles' text color
        if self.menuToggleButton then
            self.menuToggleButton.TextColor3 = self.fontColor
        end
        if self.lockToggleButton then
            self.lockToggleButton.TextColor3 = self.locked and self.theme.LockOn or self.theme.LockOff
        end
    end})
    -- Theme
    self:addDropdown("Configuração","Ajustes",{Name="Tema", Options={"Escuro","Claro"}, Callback=function(option)
        -- Set theme
        -- This would require changing the theme table and then rebuilding/updating the UI elements.
        -- For simplicity, this example just has the callback.
    end})
    -- Font style
    self:addDropdown("Configuração","Ajustes",{Name="Fonte", Options={"Gotham","FredokaOne","Roboto"}, Callback=function(option)
        -- Set font
        -- This would require iterating through all text elements and changing their Font property.
        -- For simplicity, this example just has the callback.
    end})
end

-- HOTKEY BIND
function Library:_bindHotkey()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
            self.menuVisible = not self.menuVisible
            self.mainFrame.Visible = self.menuVisible
            -- Update the external menu toggle text to reflect the change
            if self.menuToggleButton then
                self.menuToggleButton.Text = self.menuVisible and "H" or "S"
            end
        end
    end)
end

-- PUBLIC: Example usage
function Library:Example()
    local mainTab = self:addTab("Principal")
    local cat = self:addCategory("Principal","Geral")
    self:addToggle("Principal","Geral",{Name="Exemplo Toggle", Default=false, Callback=function(val) print("Exemplo Toggle:", val) end})
    self:addSlider("Principal","Geral",{Name="Volume", Min=0, Max=100, Default=50, Callback=function(val) print("Volume:", val) end})
    self:addDropdown("Principal","Geral",{Name="Modo", Options={"Fácil","Normal","Difícil"}, Callback=function(opt) print("Modo selecionado:", opt) end})
    self:addDropdownToggle("Principal","Geral",{Name="Powerups", Options={"Speed","Jump","Invis"}, Callback=function(tbl) print("Powerups selecionados:", tbl) end})
    self:addLabel("Principal","Geral",{Name="Aviso", Text="Bem-vindo ao menu MSHUB UI!"})
    self:_buildConfigTab()
end

return setmetatable(Library, {
    __call = function(_, ...) return Library.new(...) end
})

--[[

How To Use:

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<your-repo>/<your-library>/main/lua_ui_library.lua"))()
UI:Example()

]]
